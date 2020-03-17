#!/usr/bin/python

from sys import argv

with open(argv[1]) as singlecopylist:
	list1 = singlecopylist.readlines()

SC = []

for line in list1:
    line = line.strip()
    SC.append(line)

with open(argv[2]) as OG_table:
	list2 = OG_table.readlines()

for line in list2:
    line = line.strip()
    a = line.split(' ')
    b = a[0].split(':')
    if b[0] in SC:
        print (line)
