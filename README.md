# MUFFINN
MUFFINN is a method for prioritizing cancer genes accounting for not only for mutations of individual genes but also those of neighbors in functional networks, MUFFINN (**MU**tations **F**or **F**unctional **I**mpact on **N**etwork **N**eighbors).

##Requirements for installation
1. **Linux/Unix** environment
2. **Perl**: Perl is one of the program languages, which is available for most operating systems. If you are in UNIX/Linux, it is probably already installed.
3. **R**: R is a free software environment for statistical computing and graphics. You can freely download R at www.r-project.org 

We tested the code in 1) Ubuntu 12.04 and 2) OS X 10.9.5 (Mavericks) environments.

##Running MUFFINN
Unzip MUFFINN.zip which you can download tab in www.inetbio.org/muffinn/
You can run MUFFINN as follow

    perl muffinn.pl [Mutation occurrence data] [output prefix] 

+ **Mutation occurrence data**: path to tab-separated files containing gene (entrez ID) in first column and mutational occurrences in second column. See example file **MutationOccurrence_Breast.example**. Note that only genes in Concensus CDS will be used for running MUFFINN. 
+ **Output prefix**: prefix for output file names.

You can try example run as follow.

    perl muffinn.pl MutationOccurrence_Breast.example BRCA

It would use both HumanNet and STRING v10 for running MUFFINN. If you need to run MUFFINN with other networks, you can run MUFFINN as follow. 

    perl muffinn_with_NW.pl [mutation occurrence data] [Network] [output prefix] 

+ **Network**: path to tab-separated network files containing gene pair (entrez ID) in the first and second columns, and edge weights in third column. If the third column is not available, the edge weights would be regarded as 1 when running MUFFINN. See example file **UnProcessedNW_STRINGv10.example**. Note that only genes in Concensus CDS will be used for running MUFFINN.
+ Mutation occurrence data and output prefix are same as above. 

You can try example run as follow.

    perl muffinn_with_NW.pl MutationOccurrence_Breast.example UnProcessedNW_STRINGv10.example BRCA_STRING

##Outputs
Output files are generated in 'output' directory. Genes are prioritized with their MUFFINN scores, and the presence of each gene in five validation sets is indicated by Y (presence), or N (absence).

