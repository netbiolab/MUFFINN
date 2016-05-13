#!/usr/bin/perl -w

#<Pre-processing network 1) Exclusion of genes not in CCDS 2) Exclusion of homo-pair (A-A) and Redundant pair (A-B, B-A) 3) Normalize edge weights.>
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
my $nw_file = $ARGV[1];

##### open CCDS file
my %ccds = ();
open(C, "./backend/hs_18499.CCDS.geneIDs") or die " Can't open CCDS_gene_list_file \(hs_18499.CCDS.geneIDs\)\n\n" ;
while(<C>){
   my $line = $_; chomp $line;
   $ccds{$line} = "x";
}
close(C);

my %score = ();
open(I, $input_file) or die " \n\n Can't open nw file \( $input_file \) \n\n";
open(O, "> $nw_file") or die;
my $max = 0;
while(<I>){
	my $line = $_; chomp $line;
	my @ele = split /\t/, $line;
	if($ele[0] eq $ele[1]){next;}
	my $weight = 1;
	if((scalar@ele) > 2){
		$weight = $ele[2];
	}
	if($max < $weight){
		$max = $weight;
	}
	if(exists$ccds{$ele[0]}){
		if(exists$ccds{$ele[1]}){
			my $temp_pair = "";
			if ($ele[0] lt $ele[1]){			
				$temp_pair = "$ele[0]\t$ele[1]";
			}
			else{
				$temp_pair = "$ele[1]\t$ele[0]";
			}
			if(exists$score{$temp_pair}){
				if($score{$temp_pair} < $weight){
					$score{$temp_pair} = $weight;
				}
			}
			else{
				$score{$temp_pair} = $weight;
			}
		} #ccds
	} #ccds

} #while
foreach my $pair (sort {$score{$b} <=> $score{$a}}(keys %score)){
	my $norm = $score{$pair} / $max;
	print O "$pair\t$norm\n";
}
close(O);
close(I);
