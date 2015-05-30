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

if (len(sys.argv) < 3):
    print '$> tupir.sh fichero_entrada fichero_salida'
    print 'EJEMPLO: $> ./tupir.sh  ./in.csv out.csv'
    exit()
    
file_in = sys.argv[1]
file_out = sys.argv[2]

fichero_entrada = open(file_in, 'rb')
fichero_salida = open(file_out, 'w')

nline = 0

for line in fichero_entrada:
	datos = line.split(',')
	fecha = datos[0]
	lat = datos[1]
	lon = datos[2]
	vel = datos[3]
	rssi = datos[4]
	sat = datos[5]
	voltaje = datos[6]

	if nline == 0:
		fichero_salida.writelines('%s,%s,%s,%s,%s,%s,%s' %(fecha,lat,lon,vel,rssi,sat,voltaje))
	else:
		new_lat = (float(lat) + float(old_lat)) / 2
		new_lon = (float(lon) + float(old_lon)) / 2
		new_vel = (float(vel) + float(old_vel)) / 2
		fichero_salida.writelines('%s,%s,%s,%s,%s,%s,%s' %(fecha,lat,lon,vel,rssi,sat,voltaje))
		fichero_salida.writelines('%s,%s,%s,%s,%s,%s,%s' %(fecha,str(new_lat),str(new_lon),str(new_vel),rssi,sat,voltaje))
	
	old_lat = lat
	old_lon = lon
	old_vel = vel

	nline +=1