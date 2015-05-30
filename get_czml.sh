#!/usr/bin/env python
#-*- coding: UTF-8 -*-


import datetime
import time
import os
import sys
import csv
import MySQLdb as mdb


vehicle_license = '001'
pos_date1 = 1396769374000
pos_date2 = 1396772974000
indice = 0

try:

    con = mdb.connect('192.168.24.9', 'root', 'r000.tdei.fia', 'KyrosFia')
     
    cur = con.cursor()

    cur.execute("SELECT POS_LATITUDE_DEGREE, POS_LATITUDE_MIN, POS_LONGITUDE_DEGREE, POS_LONGITUDE_MIN, ALTITUDE  FROM TRACKING WHERE VEHICLE_LICENSE='"+vehicle_license+ "' and POS_DATE > " + str(pos_date1)+ " and POS_DATE < "+ str(pos_date2) + " ORDER BY POS_DATE")
    numrows = int(cur.rowcount)
    for i in range(numrows):
        row = cur.fetchone()
        lat_deg = row[0]
        lat_min = row[1]
        lon_deg = row[2]
        lon_min = row[3]
        alt = row[4]

        lat = lat_deg + lat_min/60
        lon = lon_deg + lon_min/60

        if (alt > 0.0):
            print str(indice*10) + "," + str (lon) + "," + str(lat) + "," + str(alt+60) + ","
            indice += 1

except mdb.Error, e:
  
    print "Error %d: %s" % (e.args[0], e.args[1])
    sys.exit(1)

finally:
    
    if con:
        con.close()
        

   