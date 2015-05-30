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


if (len(sys.argv) < 5):
    print '$> show_voltage.sh caja stadistics_file fecha_inicial fecha_final'
    print 'EJEMPLO: $> ./show_voltage.sh 002 ../logs/Stadistics.log 2014-01-1508:15:00 2014-01-1508:17:10'
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


with open(fichero_stadistics, 'r') as f:
	try:
		m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
		try:
			while True:
				line=m.readline()
				if line == '': break

				dia_llegada = line[1:11]
				hora_llegada = line[12:20]
				    
				from datetime import datetime
				fecha = datetime.strptime(dia_llegada + hora_llegada, '%Y-%m-%d%H:%M:%S')

				milisg = time.mktime(fecha.timetuple())
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
								voltage_raveon = vector_prave[10]
								print hora_llegada + " -> " + voltage_raveon
		except:
			pass
	except:
		pass