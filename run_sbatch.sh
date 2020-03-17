#!/bin/bash

input_table_list=./pp_pv_input_table/pp.pv.input.table

for i in `cat $input_table_list`
do
	mkdir $i
	cd $i
	ln -s ../kaks_calculator.pl .
	ln -s ../pp_pv_input_table/$i .
	cp ../shell/$i.sh .
	sbatch $i.sh
	cd ..
done
