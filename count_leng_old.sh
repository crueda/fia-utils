#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# fecha: 2013-10-16
# mail: carlos.rueda@deimos-space.com

import datetime
import time
import os
import sys


uhf_count = 0

tramas_leng  = [0] * 35

if (len(sys.argv) < 1):
    print '$> count_leng.sh stadistics_file'
    print 'EJEMPLO: $> ./count_leng.sh ../logs/Stadistics.log'
    exit()

fichero_stadistics = sys.argv[1]

fichero = open(fichero_stadistics, 'rb')
for line in fichero:
    try:
        if line.find('TRAMA WMX')>0 :
            uhf_count +=1
            indice = line.find('LENG')
            try:
                len = int(line[indice+5:indice+7])
            except:
                len = 0

        if (len > 0):
            tramas_leng[len]+=1
    except:
        a=1

fichero.close

print " "
print "______________________________________________________"
print "Total tramas WMX: " + str(uhf_count)
print "______________________________________________________"

for i in range(35):
    if (tramas_leng[i]>0):
        print "Longitud " + str(i) + " : " + str(tramas_leng[i])
print "______________________________________________________"
print " "