#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2014-02-14
# mail: carlos.rueda@deimos-space.com

import time
import datetime
import os
import sys
import MySQLdb as mdb
import math

def distance(origin, destination):
    lat1, lon1 = origin
    lat2, lon2 = destination
    radius = 6371.137 # km

    dlat = math.radians(lat2-lat1)
    dlon = math.radians(lon2-lon1)
    a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = radius * c

    return d

if (len(sys.argv) < 3):
    print '$> nearby_positions.sh latitude longitude radius'
    print 'EJEMPLO: $> ./nearby_positions.sh 60.060700 13.289517 500'
    exit()
    
lat = float(sys.argv[1])
lon = float(sys.argv[2])
radius = int(sys.argv[3])

lat_grados = int(lat)
lat_minutos = (lat - lat_grados)*60
lon_grados = int(lon)
lon_minutos = (lon - lon_grados)*60

num_pos = 0
num_pos_wrc = 0
sum_velocidades = 0
sum_rssi = 0

try:
	#con = mdb.connect('192.168.24.3', 'root', 'r000.tdei.fia', '140115_KyrosFia_Montecarlo')
	con = mdb.connect('192.168.24.3', 'root', 'r000.tdei.fia', 'KyrosFia')
	cur = con.cursor()
	cur2 = con.cursor()

    # Recorrer toda la tabla TRACKING calculando distancia. Filtrar 1 minuto arriba, abajo, derecha e izquierda
	query = "SELECT VEHICLE_LICENSE, POS_LATITUDE_DEGREE, POS_LATITUDE_MIN, POS_LONGITUDE_DEGREE, POS_LONGITUDE_MIN, RSSI, GPS_SPEED FROM TRACKING where POS_LATITUDE_MIN<"+str(lat_minutos+1)+" and POS_LATITUDE_MIN>"+str(lat_minutos-1)+" and POS_LONGITUDE_MIN<"+str(lon_minutos+1)+" and POS_LONGITUDE_MIN>"+str(lon_minutos-1)
	cur.execute(query)

 	numrows = int(cur.rowcount)
 	#print numrows
 	for i in range(numrows):
		# Comprobar si ese punto esta a distancia del radio
		row = cur.fetchone()
		license = row[0]
		pos_lat_deg = row[1]
		pos_lat_min = row[2]
		pos_lon_deg = row[3]
		pos_lon_min = row[4]
		rssi = row[5]
		speed = row[6]

		# Escojer solo las posiciones UHF
		if (rssi>0):
			pos_lat = pos_lat_deg + (pos_lat_min)/60
			pos_lon = pos_lon_deg + (pos_lon_min)/60
			d = (distance([lat,lon],[pos_lat,pos_lon]))*1000
			#print "->"+str(pos_lat)+","+str(pos_lon)+"-"+str(d)
			if (d<radius):
				num_pos+=1
				sum_rssi+=rssi
				sum_velocidades+=speed

				query2 = "select FLEET_ID from HAS where VEHICLE_LICENSE='"+license+"'"
				cur2.execute(query2)
 				numrows2 = int(cur2.rowcount)
				for j in range(numrows2):
					row2 = cur2.fetchone()
					fleet = row2[0]
				if (fleet==489):
					num_pos_wrc+=1
	

except mdb.Error, e:
    print "Error %d: %s" % (e.args[0], e.args[1])
    sys.exit(1)

finally:
    if con:
        con.close()

print "Done!"
print " -----> Numero de posiciones:     "+str(num_pos)
print " -----> Numero de posiciones WRC: "+str(num_pos_wrc)
try:
	print " -----> Velocidad media:      "+str(sum_velocidades/num_pos)
	print " -----> RSSI medio:           "+str(sum_rssi/num_pos)
except:
	pass