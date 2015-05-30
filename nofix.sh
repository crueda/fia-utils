#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2013-10-16
# mail: carlos.rueda@deimos-space.com


import datetime
import time
import os
import sys

gprs_count = 0
uhf_count = 0
igprs_count = 0
iuhf_count = 0
nofix_count = 0    
sifix_count = 0    
#gprs_nofix_count = 0    
#uhf_nofix_count = 0    
uhf_beacons = ""
gprs_beacons = ""

str_box = sys.argv[1]
fichero_stadistics = sys.argv[2]
str_fecha_inicial = sys.argv[3]
str_fecha_final = sys.argv[4]

from datetime import datetime
fecha_inicial = datetime.strptime(str_fecha_inicial, '%Y-%m-%d%H:%M:%S')
fecha_final = datetime.strptime(str_fecha_final, '%Y-%m-%d%H:%M:%S')
milisg_inicial = time.mktime(fecha_inicial.timetuple())  
milisg_final = time.mktime(fecha_final.timetuple())  

#print milisg_inicial
#print milisg_final
tramas_totales_teoricas = (milisg_final-milisg_inicial)/10

fichero = open(fichero_stadistics, 'rb')
for line in fichero:
   
    dia_llegada = line[1:11]
    hora_llegada = line[12:20]
    
    if (line.find('fix')>0):
		try:
			indice = line.index('fix')
			box = line[indice+8:indice+11]
			event = line[indice+11:indice+12]
			beacon = line[indice+12:indice+14]
		except:
			c=1
    else:
		try:
			indice = line.index('rrectos')
			box = line[indice+10:indice+13]
			event = line[indice+13:indice+14]
			beacon = line[indice+14:indice+16]
		except:
			b=1

    #print box + " - " +event + " - " + beacon
    
    try:
    	from datetime import datetime
    	fecha = datetime.strptime(dia_llegada + hora_llegada, '%Y-%m-%d%H:%M:%S')

    	#print box + " - " + str_box
    	milisg = time.mktime(fecha.timetuple())
    	if (milisg>milisg_inicial and milisg<milisg_final):
    		#print "en fecha"
    		if (str_box == box):
    			if line.find('TRAMA GPRS con datos correctos')>0 :
        			gprs_count +=1
        			if event == 'B' :
       		 			gprs_beacons = "B" + beacon + " " + gprs_beacons
    			if line.find('TRAMA UHF con datos correctos')>0 :
       		 		uhf_count +=1
        			if event == 'B' :
       		 			uhf_beacons = "B" + beacon + " " + uhf_beacons
    			if line.find('TRAMA GPRS con datos incorrectos')>0 :
        			igprs_count +=1
    			if line.find('TRAMA UHF con datos incorrectos')>0 :
       		 		iuhf_count +=1
    			if line.find('fix 0')>0 :
       		 		nofix_count +=1
    			
    except:
    	a=1
    

fichero.close

print " "
print "______________________________________________________"
print "Caja: " + str_box
print "Rango horario: " + str_fecha_inicial + " - " + str_fecha_final
print "______________________________________________________"
print "Tramas TEORICAS      :   " + str(tramas_totales_teoricas)
print "Tramas UHF correctas :   " + str(uhf_count)
print " -> UHF              :   " + str(uhf_count*100/tramas_totales_teoricas)
print "Tramas GPRS correctas:   " + str(gprs_count)
print " -> GPRS             :   " + str(gprs_count*100/tramas_totales_teoricas)
print "Tramas UHF incorrectas:  " + str(iuhf_count)
print "Tramas GPRS incorrectas: " + str(igprs_count)
print "Balizas UHF:             " + uhf_beacons
print "Balizas GPRS:            " + gprs_beacons
print "No fix (tramas SIN fix): " + str(nofix_count)
print "______________________________________________________"
print " "
