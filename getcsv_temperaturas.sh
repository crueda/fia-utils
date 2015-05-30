#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2014-06-09
# mail: carlos.rueda@deimos-space.com

import time
import datetime
import os
import sys
import mmap


if (len(sys.argv) < 4):
    print '$> getcsv_temperaturas.sh caja stadistics_file fichero_salida'
    print 'EJEMPLO: $> ./getcsv_temperaturas.sh 002 ../logs/Stadistics.log out_temp.csv'
    exit()
    
str_box = sys.argv[1]
fichero_stadistics = sys.argv[2]
fichero_out_name = sys.argv[3]

fichero_out = open(fichero_out_name, 'w')

with open(fichero_stadistics, 'r') as f:
	try:
		m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
		try:
			while True:
				line=m.readline()
				if line == '': break

				
				if line.find('PRAVE')>0 :
					dia_llegada = line[1:11]
					hora_llegada = line[12:20]
				    
					from datetime import datetime
					fecha = datetime.strptime(dia_llegada + hora_llegada, '%Y-%m-%d%H:%M:%S')

					index_separador = line.find(">")
					if (index_separador>-1):
						trama = line[index_separador+1:len(line)]
						vector_prave = trama.split(',')
						box_number = trama[8:11]
						#print box_number
						if box_number == str_box:                        
							temp_raveon = vector_prave[9]
							fichero_out.writelines('%s,%s\r\n' %(str(fecha),str(temp_raveon)))
		except:
			pass
	except:
		pass