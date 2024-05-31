args <- commandArgs(trailingOnly=TRUE)
#Load required libraries
library(MASS)
library(dplyr)
#Reads smartpca output
file=args[1]
data=read.table(file, sep = "")
new_column_names=c("Sample","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","Group")
colnames(data) <- new_column_names
data <-data[!data$Group %in% "Outgroup", ]
#Separates reference panel and unknown individuals
data$Group <- gsub(".*_Dogs", "Dogs", data$Group)
data$Group <- gsub(".*_Wolves", "Wolves", data$Group)
reference=data %>% filter(!grepl('Unknown', Group))
unknown=data %>% filter(grepl('Unknown', Group))
#Performs linear discriminant analysis on first 10 principal components, with groups representing dog/wolf distinction
lda_model<-lda(Group ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=reference)
lda_predict <- predict(lda_model, unknown)
lda_posterior<-round(lda_predict$posterior, 4)
#Output results
new_row_names <- unknown$Sample
rownames(lda_posterior) <- new_row_names
output_file=args[2]
write.table(lda_posterior, output_file, col.names=TRUE, row.names=TRUE)
