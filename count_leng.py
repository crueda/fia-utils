import os
import sys


uhf_count = 0
uhf_count_bad = 0

tramas_leng  = [0] * 35
tramas_bad  = [0] * 150

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
            longitud = int(line[indice+5:indice+7])
            tramas_leng[longitud]+=1   
            indice = line.find("TRAMA WMX")
            box_number = line[indice+15:indice+18]
            if (longitud > 12 and longitud < 16):
                uhf_count_bad += 1
                print box_number
                try:
                    nbox = int (box_number)                    
                except:
                    nbox = 150
                if nbox > 150:
                    nbox = 150
                tramas_bad[nbox] +=1      
    except:
        print "EXCEPCION!"
        
fichero.close

print " "
print "______________________________________________________"
print "Total tramas WMX: " + str(uhf_count)
print "______________________________________________________"

for i in range(35):
    if (tramas_leng[i]>0):
        print "Longitud " + str(i) + " : " + str(tramas_leng[i])
print "______________________________________________________"
print "Total tramas con longitud entre 12 y 16: " + str(uhf_count_bad)
print "______________________________________________________"
for i in range(150):
    if (tramas_bad[i]>0):
        print "Caja " + str(i) + " : " + str(tramas_bad[i]) + " tramas"
print " "
print "______________________________________________________"
print " "