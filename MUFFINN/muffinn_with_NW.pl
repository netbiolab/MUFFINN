#!/usr/bin/perl -w
#<muffinn_with_NW.pl: Run MUFFINN with user-defined network>
#Copyright (C) <2016>  <Ara Cho>

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
use strict;

my $input_file = $ARGV[0];
my $nw_input_file = $ARGV[1];
my $tag = $ARGV[2];

#my @method_arr = ("DNmax");
my @method_arr = ("DNmax", "DNsum");

my $temp_file = $tag."_temp";


##### filter onlyCCDS
print "\n\nFiltering out genes not in CCDS...\n";
my $ccds_file = "./output/".$tag.".MutatedCCDS";
my $non_ccds_file = "./output/".$tag."_Non_CCDS";
system "./backend/CCDS.pl $input_file $ccds_file $non_ccds_file";

##### sort 
system "sort -k2 -rg $ccds_file > $temp_file";
system "mv $temp_file $ccds_file";

#### Pre-process network
print "\nPre-processing network ...\n";
my $nw_file = "./output/".$tag.".Network";
system "./backend/NW_process_sortByShell.pl $nw_input_file $nw_file";

##### read mutational occurrence file
my %mut = (); #key = entrezID value = mutational occurrence
open(C, $ccds_file) or die;
while(<C>){
	my $line = $_; chomp $line;
	my @ele = split /\t/, $line;
	$mut{$ele[0]} = $ele[1];
}
close(C);


##### Read cancer gene list
my @val_arr = ("CGC", "CGCpointMut", "2020Rule", "HCD", "MouseMut");
my %val_gene = (); #key1 = cancer gene list name, key2 = gene, value = dummy
foreach my $val (@val_arr){
	my $val_file = "./backend/Cancer_GeneSet/".$val;
	open(V, $val_file) or die;
	while(<V>){
		my $line = $_; chomp $line;
		$val_gene{$val}{$line} = "x";
	} #while V
	close(V);
} 

##### Read gene symbol
my %symbol = ();  #key = entrezID value = symbol
my $xref_file = "./backend/hs_18499.CCDS.xref";
open(X, $xref_file) or die;
while(<X>){
	my $line = uc($_); chomp $line;
	my @ele = split /\t/, $line;
	$symbol{$ele[0]} = $ele[1];
}
close(X);

#######
my $gs = "./backend/Cancer_GeneSet/AllCancerGene";
my $command = "";
	foreach my $method (@method_arr){
		print "\t\t$method ...\n";

##### Do MUFFINN
		my $output_file = "./output/".$method."_".$tag.".userNW";
		$command = "./backend/".$method.".pl $ccds_file $nw_file $output_file";
		system "$command";

##### Mark Training set 
		$command = "./backend/Logistic_regression.pl $gs $output_file $temp_file";
		system "$command";
		system "mv $temp_file $output_file";

##### Calculate probabilistic scores
		$command = "./backend/Logistic_regression.R $output_file $temp_file";
		system "$command";
#		system "mv $temp_file $output_file";

##### write_output_file 
		open(O, " > $output_file") or die;
		open(I, $temp_file) or die;
		my $dummy = <I>; 
		print O "Rank\tGene_ID\tGene_Symbol\tCGC\tCGCpointMut\t2020Rule\tHCD\tMouseMut\tMutationOccurrence\tScore\n";
		while(<I>){
			my $line = $_; chomp $line;
			my ($rank, $gene, $raw, $cancer, $p) = split /\t/, $line;
			print O "$rank\t$gene";
			print O "\t$symbol{$gene}";
			foreach my $val_type (@val_arr){
				if(exists$val_gene{$val_type}{$gene}){
					print O "\tY";
				}
				else{
					print O "\tN";
				}
			}
			if(exists$mut{$gene}){
				print O "\t$mut{$gene}";
			}
			else{
				print O "\t0";
			}
			print O "\t$p\n";
		}
		close(I);
		close(O);
		system "rm $temp_file";
	}

