#!/usr/bin/perl -w
#<DNmax.pl: Prioritizing genes by DNmax method>
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

open(DATA, $ARGV[0]) or die "
usage:
0: freq
1: NW
2: output_withAnnot\n";

my %freq = ();
my %all = ();
while(<DATA>){
	my $line = $_; chomp $line;
	my @element = split /\t/, $line;
	$freq{$element[0]} = $element[1];
	$all{$element[0]} = "x";
}
close(DATA);


open(NET,"$ARGV[1]") or die "NW\n!!!";
my %nw = ();
my %deg = ();
while(<NET>){
	my $line = $_; chomp $line;
	my @ele = split /\t/, $line;
	$nw{$ele[0]}{$ele[1]} = $ele[2];
	$nw{$ele[1]}{$ele[0]} = $ele[2];
	$deg{$ele[0]} ++;
	$deg{$ele[1]} ++;
	$all{$ele[0]} = "x";
	$all{$ele[1]} = "x";
}#while net
close(NET);

my %final = ();
foreach my $gene (keys%all){
	my $max = 0;
	if(exists$freq{$gene}){#gene is mutated
		if(exists$deg{$gene}){#gene is in NW
			foreach my $gene2 (keys %{$nw{$gene}}){
				if(exists $freq{$gene2}){
					if($max < $freq{$gene2} * $nw{$gene}{$gene2} ){
						$max = $freq{$gene2} * $nw{$gene}{$gene2};
					}
				}
			}
			$final{$gene} = $freq{$gene} + $max;
		}#gene is mutated and in NW
		else{ #gene is not in NW
			$final{$gene} = $freq{$gene};
		}
	} #if
	else{ #gene is not mutated
		if(exists$deg{$gene}){ #gene is in NW
			foreach my $gene2 (keys %{$nw{$gene}}){
				if(exists$freq{$gene2}){
					if($max < $freq{$gene2} *  $nw{$gene}{$gene2}){
						$max = $freq{$gene2} * $nw{$gene}{$gene2};
					}
				}
			}
		}
		$final{$gene} = $max;
	}#gene is not mutated 
}
	



open(O, ">$ARGV[2]") or die;

foreach my $final_gene (sort{$final{$b} <=> $final{$a}} (keys %final)){
	if($final{$final_gene} ==0){next;}
	print O "$final_gene\t$final{$final_gene}\n";
}
