#!/usr/bin/perl -w
#<CCDS.pl: Excluding genes which are 1) not in CCDS list 2) not mutated>
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
my $ccds_file = $ARGV[1];
my $non_ccds_file = $ARGV[2];

##### open CCDS file
my %ccds = ();
open(C, "./backend/hs_18499.CCDS.geneIDs") or die " Can't open CCDS_gene_list_file \(hs_18499.CCDS.geneIDs\)\n\n" ;
while(<C>){
	my $line = $_; chomp $line;
	$ccds{$line} = "x";
}
close(C);

open(I, $input_file) or die " \n\n Can't open mutation occurrence file \( $input_file \) \n\n";
open (O, "> $ccds_file") or die;
open (O_N, "> $non_ccds_file") or die;

while(<I>){
	my $line = $_; chomp $line;
	my ($gene, $cnt) = split /\t/, $line;
	if(exists$ccds{$gene}){
		if($cnt != 0){
			print O "$gene\t$cnt\n";
		}
	}
	else{
		print O_N "$gene\t$cnt\n";
	}
}
close(I);
close(O);
close(O_N);
