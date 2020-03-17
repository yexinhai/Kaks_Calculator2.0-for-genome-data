#!/bin/bash
# Xinhai Ye, yexinhai@zju.edu.cn

input_table_list=./pp_pv_input_table/pp.pv.input.table

for i in `cat $input_table_list`
do
	exec 3>$i.sh

	echo "#!/bin/bash" >&3
	echo "#!/bin/bash" >&3
	echo "#SBATCH -J kaks_calculator" >&3
	echo "#SBATCH -e kaks_calculator_err_%j" >&3
	echo "#SBATCH -o kaks_calculator_output_%j" >&3
	echo "#SBATCH --mem=32000" >&3
	echo "#SBATCH -t 120:00:00" >&3
	echo "#SBATCH --cpus-per-task=1" >&3
	echo "#SBATCH -p standard" >&3
	echo "#SBATCH --mail-type=ALL" >&3
	echo "#SBATCH --mail-user=NONE" >&3

	echo "module load mafft/7.313" >&3
	echo "module load kaks-calculator/2.0" >&3

	echo "perl kaks_calculator.pl ../all.pep.fasta ../all.cds.fasta $i" >&3
done
