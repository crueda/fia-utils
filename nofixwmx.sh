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

if (len(sys.argv) < 5):
    print '$> nofixwmx.sh caja stadistics_file fecha_inicial fecha_final'
    print 'EJEMPLO: $> ./nofixwmx.sh 014 ../logs/Stadistics.log 2013-11-1314:18:00 2013-11-1316:10:10'
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

#print milisg_inicial
#print milisg_final
tramas_totales_teoricas = (milisg_final-milisg_inicial)/10

fichero = open(fichero_stadistics, 'rb')
for line in fichero:
   
    dia_llegada = line[1:11]
    hora_llegada = line[12:20]
    
    index_separador = line.find(">")
    trama = line[index_separador+1:len(line)]
    box = trama[1:4]
    evento = trama[4:5]
    beacon = trama[5:7]

    try:
    	from datetime import datetime
    	fecha = datetime.strptime(dia_llegada + hora_llegada, '%Y-%m-%d%H:%M:%S')

    	#print box + " - " + str_box
    	milisg = time.mktime(fecha.timetuple())
    	if (milisg>milisg_inicial and milisg<milisg_final):
    		#print "en fecha"
            evento = trama[4:5]
            beacon = trama[5:7]
            #if (evento=='S'):
                #print evento
            if (str_box == box):
                #print 'trama: '+line
                if line.find('TRAMA GPRS YOK')>0 :
                    gprs_count +=1
                    if evento == "S" :
                        gprs_beacons = "S" + beacon + " " + gprs_beacons
                if line.find('TRAMA WMX YOK')>0 :
                    #print 'dentro'
                    uhf_count +=1
                    if evento == 'S' :
                        uhf_beacons = "S" + beacon + " " + uhf_beacons
                if line.find('TRAMA GPRS NOK')>0 :
                    igprs_count +=1
                if line.find('TRAMA UHF NOK')>0 :
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
print "Tramas TEORICAS:         " + str(tramas_totales_teoricas)
print "Tramas UHF correctas:    " + str(uhf_count)
print " -> Porcentaje UHF:      " + str(uhf_count*100/tramas_totales_teoricas)
print "Tramas GPRS correctas:   " + str(gprs_count)
print " -> Procentaje GPRS:     " + str(gprs_count*100/tramas_totales_teoricas)
print "Tramas UHF incorrectas:  " + str(iuhf_count)
print "Tramas GPRS incorrectas: " + str(igprs_count)
print "Balizas UHF:             " + uhf_beacons
print "Balizas GPRS:            " + gprs_beacons
print "No fix (tramas SIN fix): " + str(nofix_count)
print "______________________________________________________"
print " "
