#!/usr/bin/Rscript

#<Logistic_regression.R: Calculating probability scores based on logistic regression>
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

args<-commandArgs(TRUE)
file<-args[1]
output <-args[2]

data<-read.table(file, sep="\t")
colnames(data) <- c("gene", "score", "cancer")
result_glm<- glm(cancer ~ score, family = binomial, data = data)


co <- result_glm$coefficients
b0 <- co[1]
b1 <- co[2]
for(i in 1:length(data[,1])){
	a <- data[i,2]
	b <- (exp(b0+(b1*a)))/(1+exp(b0+(b1*a)))
	data[i,4] <- b
} #for
colnames(data) <- c("gene", "score", "cancer", "logit")

write.table(data, file=output, sep="\t", quote=FALSE)

