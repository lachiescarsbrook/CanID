args <- commandArgs(trailingOnly=TRUE)
#Load required libraries
library(ggplot2)
#Reads evec output
evec=args[1]
data_evec=read.table(evec, sep = "")
new_column_names=c("Sample","PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","Group")
colnames(data_evec) <- new_column_names
data_evec <-data_evec[!data_evec$Group %in% "Outgroup", ]
#Reads eval output and calculates percentage variance
eval=args[2]
data_eval=read.table(eval, sep = "", header = F, col.names = c("Eigenvalue"))
data_eval$PC=paste0("PC", 1:nrow(data_eval))
eval_sum=sum(data_eval$Eigenvalue)
data_eval$Percentage=round((data_eval$Eigenvalue/eval_sum)*100,3)
#Create PCA plot
pdf(args[3])
ggplot(data_evec, aes(x=PC1, y=PC2, colour = Group, shape = Group, label = Sample)) + geom_point() + scale_color_manual(values=c("#00bf62","#0099d0", "#00c8ba", "#ffd876", "#cc4d16", "#7f6cd2","#f59730","red","#632610")) + scale_shape_manual(values=c(0,1,2,5,0,6,1,8,2)) + theme(panel.background = element_blank(), axis.line.x = element_line(color="black", size = 0.5), axis.line.y = element_line(color="black", size = 0.5)) + labs(x = paste("PC1 (",data_eval$Percentage[1],"%)"),y = paste("PC2 (",data_eval$Percentage[2],"%)"))
dev.off()
