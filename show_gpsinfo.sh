#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2014-01-15
# mail: carlos.rueda@deimos-space.com

import time
import datetime
import os
import sys
import mmap

#$PRAVE,0048,0300,4432.4334,603.6925,123251,2,8,739,23,12.4,0,-70,0,0,,*50 WHO_SEND:gprs
#TRAMA GPRS YOK R094 FIX 1 RSSI 0 LENG 24 SEQ 0>R094Axx12:34:08.50014.01.201410144.4470112,6.0321416,0,19.490000000000002,5.46,0,0,0,0 ( 82 48 57 52 65 36 112 -114 -125 34 42 -8 26 126 19 96 3 -104 110 -120 7 -99 2 34) WHO_SEND:gprs
#R094Axx12:34:08.50014.01.201410144.4470112

if (len(sys.argv) < 5):
    print '$> show_gpsinfo.sh caja stadistics_file fecha_inicial fecha_final'
    print 'EJEMPLO: $> ./show_gpsinfo.sh 002 ../logs/Stadistics.log 2014-01-1508:15:00 2014-01-1508:17:10'
    exit()
    
str_box = sys.argv[1]
fichero_stadistics = sys.argv[2]
str_fecha_inicial = sys.argv[3]
str_fecha_final = sys.argv[4]

from datetime import datetime
fecha_inicial = datetime.strptime(str_fecha_inicial, '%Y-%m-%d%H:%M:%S')
fecha_final = datetime.strptime(str_fecha_final, '%Y-%m-%d%H:%M:%S')
milisg_inicial = time.mktime(fecha_inicial.timetuple())  
milisg_final = time.mktime(fecha_final.timetuple())  

trama = ""
line = ""

with open(fichero_stadistics, 'r') as f:
	try:
		m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
		try:
			while True:
				line=m.readline()
				if line == '': break

				dia_llegada = line[1:11]
				hora_llegada = line[12:20]
				milisg = 0

				from datetime import datetime
				try:
					fecha = datetime.strptime(dia_llegada + hora_llegada, '%Y-%m-%d%H:%M:%S')
					milisg = time.mktime(fecha.timetuple())
				except:
					pass
				if (milisg>milisg_inicial and milisg<milisg_final):
					#print "dentro"
					if line.find('PRAVE')>0 :
						#print "prave"
						index_separador = line.find(">")
						if (index_separador>-1):
							trama = line[index_separador+1:len(line)]
							vector_prave = trama.split(',')
							box_number = trama[8:11]
							#print box_number
							if box_number == str_box:                        
								lat_prave = vector_prave[3]
								lat_grados = int (lat_prave[0:2]) 
								lat_minutos = float (lat_prave[2:len(lat_prave)]) 
								lat = lat_grados + lat_minutos/60
								lon_prave = vector_prave[4]
								lon_grados = int (lon_prave[0:1]) 
								lon_minutos = float (lon_prave[1:len(lat_prave)]) 
								lon = lon_grados + lon_minutos/60
								date_prave = vector_prave[5]
								vel_prave = vector_prave[13]
								satellites_raveon = vector_prave[7]
								voltage_raveon = vector_prave[10]
								rssi_raveon = vector_prave[12]
								#print date_prave + "," + str(lat) + "," + str(lon) + "," + vel_prave + "," + rssi_raveon + "," + satellites_raveon + "," + voltage_raveon
								print str(milisg) + "," + str(lat) + "," + str(lon) + "," + vel_prave + "," + rssi_raveon + "," + satellites_raveon + "," + voltage_raveon
								#print trama
					elif line.find('GPRS YOK')>0 :
						index_separador = line.find(">")
						if (index_separador>-1):
								trama = line[index_separador+1:len(line)]
								#print trama
								box_number = trama[1:4]
								if box_number == str_box: 
									#print trama
									vector_gprs = trama.split(',')
									str_lat_gprs = vector_gprs[0]
									lat_gprs = str_lat_gprs[32:len(str_lat_gprs)]
									lon_gprs = vector_gprs[1]
									vel_gprs = vector_gprs[3]
									vel_gprs = float(vel_gprs) * 3.6
									print str(milisg) + "," + str(lat_gprs) + "," + str(lon_gprs) + "," + str(vel_gprs) + "," + "0" + "," + "0" + "," + "0"
								
		except Exception as e: 
			print(e)
			print line
	except Exception as e: print(e)