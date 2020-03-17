#!/usr/bin/perl -w
use strict;

#用法：perl 程序.pl all.pep.fasta all.cds.fasta 1_1_group_pair.txt
#读所有物种的序列；

sub Usage(){
	print STDERR "
	kaks_calculator.pl <all.pep.fasta> <all.cds.fasta> <1_1_group_pair.txt>
	\n";
	exit(1);
}
&Usage() unless $#ARGV==2;


my $genename;
my %hash_1;

open my $fasta1, "<", $ARGV[0] or die "Can't open file!";
while (<$fasta1>) {
	chomp();
	if (/^>(\S+)/){
		$genename = $1;
	} else {
		$hash_1{$genename} .= $_;
	}
}
close $fasta1;

my $cds_id;
my %hash_cds;

open my $fasta2, "<", $ARGV[1] or die "Can't open cds file!\n";
while (<$fasta2>) {
	chomp();
	if (/^>(\S+)/) {
		$cds_id = $1;
	} else {
		$hash_cds{$cds_id} .= $_;
	}
}
close $fasta2;

`mkdir kaks_result`;

open my $Group, "<", $ARGV[2] or die "Cant't open group file!";
while (<$Group>) {
	chomp();
	my @array1 = split /\s/, $_;
	my $group_nogood = shift @array1;
	my @array2 = split /:/, $group_nogood;
	my $group = $array2[0];
	`mkdir $group`;
	open OUT1, ">","$group\.pep.fasta";
	foreach (@array1) {
		print OUT1 ">".$_."\n".$hash_1{$_}."\n";
	}
	close OUT1;
	open OUT2, ">","$group\.cds.fasta";
	foreach (@array1) {
		print OUT2 ">".$_."\n".$hash_cds{$_}."\n";
	}
	close OUT2;
	`mv $group\.pep.fasta $group`;
	`mv $group\.cds.fasta $group`;
	`mafft --auto $group/$group\.pep.fasta >$group\/$group\.pep.mafft.fasta`;
	`mkdir $group\/for_kaks`;
	`perl pal2nal.pl $group\/$group\.pep.mafft.fasta $group\/$group\.cds.fasta -output fasta -nogap >$group\/for_kaks/test.codon.fasta`;
	open my $codon_ala, "<", "$group\/for_kaks/test.codon.fasta" or die "can't open test.codon.fasta in $group !\n";
	open OUT3, ">", "$group\/for_kaks/test.codon.axt";
	my $id;
	my %hash_axt;
	while (<$codon_ala>) {
		chomp();
		if (/^>(\S+)/) {
			$id = $1;
		} else {
			$hash_axt{$id} .= $_;
		}
	}
	print OUT3 $group."\n";
	foreach my $key (keys %hash_axt) {
		print OUT3 $hash_axt{$key}."\n";
	}
	print OUT3 "\n";
	close $codon_ala;
	close OUT3;
	chdir "$group\/for_kaks";
	print "$group\:Start kaks calculator 2.0 !\n";
	`KaKs_Calculator -i test.codon.axt -o out.kaks`;
	print "$group\:kaks calculator 2.0 DONE!\n";
	open my $kaksout, "<", "out.kaks" or die "can't open out.kaks file in $group !\n";
	open OUT4, ">", "$group\.kaks.result";
	while (<$kaksout>) {
		chomp();
		if (/^$group/) {
			my @array = split /\t/, $_;
			my $ka = $array[2];
			my $ks = $array[3];
			my $kaks = $array[4];
			print OUT4 $group."\t".$ka."\t".$ks."\t".$kaks."\t";
		}
	}
	close OUT4;
	`cp $group\.kaks.result ..\/..\/kaks_result`;
#	`cp ..\/wasp.tree $group\/for_paml`;
#	`mkdir $group\/for_paml\/null`;
#	`cp ..\/Null.ctl $group\/for_paml\/null`;
#	`mkdir $group\/for_paml\/alter`;
#	`cp ..\/Alter.ctl $group\/for_paml\/alter`;
#	chdir "$group\/for_paml\/null";
#	print "$group\:Start PAML for Null!\n";
#	`codeml Null.ctl`;
#	print "$group\:PAML for Null DONE!\n";
#	open my $null_mlc, "<", "mlc" or die "can't open null mlc file in $group !\n";
#	open OUT4, ">", "$group\.null.result";
#	while (<$null_mlc>) {
#		chomp();
#		if (/^lnL.*np:\s(\d+)\):\s+(\S+).*/) {
#			print OUT4 $group."\t".$1."\t".$2."\t";
#		} 
#	}
#	close OUT4;
#	`cp $group\.null.result ..\/..\/..\/paml_result`;
#	chdir "..\/alter";
#	print "$group\:Start PAML for Alter!\n";
#	`codeml Alter.ctl`;
#	print "$group\:PAML for Alter DONE!\n";
#	open my $alter_mlc, "<", "mlc" or die "can't open alter mlc file in $group!\n";
#	open OUT5, ">", "$group\.alter.result";
#	while (<$alter_mlc>) {
#		chomp();
#		if (/^lnL.*np:\s(\d+)\):\s+(\S+).*/) {
#			print OUT5 $group."\t".$1."\t".$2."\n";
#		} 
#	}
#	close OUT5;
#	`cp $group\.alter.result ..\/..\/..\/paml_result`;
	print "where is next!?\n";
	chdir "..\/..\/";
}
close $Group;




