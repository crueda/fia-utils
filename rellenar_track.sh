#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2013-04-03
# mail: carlos.rueda@deimos-space.com

import datetime
import time
import os
import sys
import csv
import MySQLdb as mdb
import math
import haversine

import httplib
import urllib
import urllib2

GPRS_count = 0
UHF_count = 0 

fichero_entrada = sys.argv[1]
fichero_salida = sys.argv[2]
tabla_cartodb = sys.argv[3]

fichero = csv.reader(open(fichero_entrada, 'rb'))
fichero_out = open(fichero_salida, 'w')

fecha_out = 0
fecha_trama_ms_anterior = 0

pos1_lat = 0.0
pos1_lon = 0.0
pos2_lat = 0.0
pos2_lon = 0.0

step = 0.0
cont = 0

try:

    con = mdb.connect('192.168.24.3', 'root', 'r000.tdei.fia', 'KyrosFia')
     
    cur = con.cursor()

    for index,row in enumerate(fichero):
        parte1 = row[0]
        parte2 = row[1]
        parte3 = row[2]

        hora_llegada = parte1[12:22]

        if parte2.find('TRAMA GPRS con datos correctos')>0 :
            GPRS_count +=1
        elif parte2.find('TRAMA UHF con datos correctos')>0 :
            UHF_count +=1
            parte22 = parte2.split(':')
            parte221 = parte22[1]
            parte222 = parte22[2]
            parte223 = parte22[3]

            hora_trama = parte221[len(parte221)-2:len(parte221)]
            minutos_trama = parte222[len(parte222)-2:len(parte222)]
            segundos_trama = parte223[0:2]
            hora_trama_completa = hora_trama + ":" + minutos_trama + ":" + segundos_trama

            datos = parte2.split('.')
            datos2 = datos[2]
            grados_lat = datos2[len(datos2)-2:len(datos2)]
            lat = grados_lat + "." + datos[3]
            
            datos = parte3.split('.')
            grados_lon = datos[0]
            datos2 = datos[1].split('.')
            min_lon = datos2[0]
            lon = grados_lon + "." + min_lon

            from datetime import datetime
            datetime_llegada = datetime.strptime(hora_llegada, '%H:%M:%S')
            datetime_trama = datetime.strptime(hora_trama_completa, '%H:%M:%S')

            fecha_llegada_ms = time.mktime(datetime_llegada.timetuple()) 
            fecha_trama_ms = time.mktime(datetime_trama.timetuple()) 

            if fecha_trama_ms_anterior == 0:
                fecha_out = 0
                pos1_lat = lat
                pos1_lon = lon
            else:    
                fecha_out = fecha_out + (fecha_trama_ms - fecha_trama_ms_anterior)
                pos2_lat = lat
                pos2_lon = lon

            #print datetime_trama
            

            

            # Rellenar posiciones entre pos1 y pos2
            if fecha_out != 0:
                cur = con.cursor()
                cur.execute("SELECT ID FROM STAGE_ROUTE WHERE LATITUDE IS NOT NULL ORDER BY sqrt(pow((LATITUDE-("+str(pos1_lat)+")),2) + pow((LONGITUDE-("+str(pos1_lon)+")),2)) ASC LIMIT 1")        
                row = cur.fetchone()
                id1 = row[0]

                cur2 = con.cursor()
                cur2.execute("SELECT ID FROM STAGE_ROUTE WHERE LATITUDE IS NOT NULL ORDER BY sqrt(pow((LATITUDE-("+str(pos2_lat)+")),2) + pow((LONGITUDE-("+str(pos2_lon)+")),2)) ASC LIMIT 1")
                row2 = cur2.fetchone()
                id2 = row2[0]

                #print ("-----> " + str(id1) + " - " + str(id2))
                #print ("---pos1--> " + str(pos1_lat) + " - " + str(pos1_lon))
                #print ("---pos2--> " + str(pos2_lat) + " - " + str(pos2_lon))

                cur3 = con.cursor()
                cur3.execute("SELECT * FROM STAGE_ROUTE WHERE ID > " + str(id1)+ " and ID < "+ str(id2) + " ORDER BY ID")

                numrows = int(cur3.rowcount)
                if numrows == 0:
                    step = 0.0
                else:
                    step = (fecha_trama_ms - fecha_trama_ms_anterior) / (numrows + 1)
                    #print ("dif:" + str(fecha_trama_ms - fecha_trama_ms_anterior))
                    #print ("numrows:"+str(numrows))
                    #print ("STEP:" + str(step))

                fecha_out_trama = fecha_out - (fecha_trama_ms - fecha_trama_ms_anterior)

                

                
                if numrows !=0:
                    for i in range(numrows):
                        row3 = cur3.fetchone()
                        lat_t = row3[3]
                        lon_t = row3[2]

                        fecha_out_trama = fecha_out_trama + step
                        #print ("T-> " + str(fecha_out_trama) + " - " + str(lat_t) + " - " + str(lon_t))
                        url = "http://carlrue.cartodb.com"
                        params = "/api/v2/sql?q=INSERT INTO " + tabla_cartodb + " (cartodb_id, the_geom) VALUES ("+str(fecha_out_trama)+", ST_SetSRID(ST_MakePoint("+str(lon_t)+","+str(lat_t)+"), 4326))&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c"
                        urllib.urlopen(url+params)

                        

                pos1_lat = lat
                pos1_lon = lon

            fichero_out.writelines ( '%s,%s,%s\r\n' % (fecha_out, lat, lon))
            #print ("-> " + str(fecha_out) + " - " + lat + " - " + lon)
            url = "http://carlrue.cartodb.com"
            params = "/api/v2/sql?q=INSERT INTO " + tabla_cartodb + " (cartodb_id, the_geom) VALUES ("+str(fecha_out)+", ST_SetSRID(ST_MakePoint("+lon+","+lat+"), 4326))&api_key=7bab444d7b809f85afd0b489e2467d412c62a47c"
            urllib.urlopen(url+params)

            print (str(cont) + "-> " + str (fecha_trama_ms - fecha_trama_ms_anterior))
            cont = cont + 1;

            fecha_trama_ms_anterior = fecha_trama_ms

                
except mdb.Error, e:
  
    print "Error %d: %s" % (e.args[0], e.args[1])
    sys.exit(1)

finally:
    
    if con:
        con.close()
        
#fichero.close
fichero_out.close

   