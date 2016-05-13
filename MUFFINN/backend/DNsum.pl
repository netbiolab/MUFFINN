#!/usr/bin/perl -w
#<DNsum.pl: Prioritizing genes by DNsum method>
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
	if(exists$freq{$gene}){#gene is mutated
		if(exists$deg{$gene}){#gene is in NW
			$final{$gene} = $freq{$gene};
			foreach my $gene2 (keys %{$nw{$gene}}){
				if(exists $freq{$gene2}){
					$final{$gene} += $freq{$gene2}/$deg{$gene2};
				}
			}
		}
		else{ #gene is not in NW
			$final{$gene} = $freq{$gene};
		}
	} #if
	else{ #gene is not mutated
		if(exists$deg{$gene}){ #gene is in NW
			$final{$gene} = 0;
			foreach my $gene2 (keys %{$nw{$gene}}){
				if(exists$freq{$gene2}){
					$final{$gene} += $freq{$gene2}/$deg{$gene2};
				}
			}
		}
	}
}
	



open(O, ">$ARGV[2]") or die;

foreach my $gene_final (sort{$final{$b} <=> $final{$a}} (keys %final)){
	if($final{$gene_final} ==0){next;}
	print O "$gene_final\t$final{$gene_final}\n";
}
close(O);
