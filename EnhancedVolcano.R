EnhancedVolcano <- function(toptable, NominalCutoff, AdjustedCutoff, LabellingCutoff, FCCutoff, main)
{
	toptable$Significance <- "NS"
	toptable$Significance[(abs(toptable$log2FoldChange) > FCCutoff)] <- "FC"
	toptable$Significance[(toptable$padj<AdjustedCutoff)] <- "FDR"
	toptable$Significance[(toptable$padj<AdjustedCutoff) & (abs(toptable$log2FoldChange)>FCCutoff)] <- "FC_FDR"
	table(toptable$Significance)
	toptable$Significance <- factor(toptable$Significance, levels=c("NS", "FC", "FDR", "FC_FDR"))

	plot <- ggplot(toptable, aes(x=log2FoldChange, y=-log10(padj))) +

		#Add points:
		#	Colour based on factors set a few lines up
		#	'alpha' provides gradual shading of colour
		#	Set size of points
		geom_point(aes(color=factor(Significance)), alpha=1/2, size=0.8) +

		#Choose which colours to use; otherwise, ggplot2 choose automatically (order depends on how factors are ordered in toptable$Significance)
		scale_color_manual(values=c(NS="grey30", FC="forestgreen", FDR="royalblue", FC_FDR="red2"), labels=c(NS="NS", FC=paste("LogFC>|", FCCutoff, "|", sep=""), FDR=paste("FDR Q<", AdjustedCutoff, sep=""), FC_FDR=paste("FDR Q<", AdjustedCutoff, " & LogFC>|", FCCutoff, "|", sep=""))) +

		#Set the size of the plotting window
		theme_bw(base_size=24) +

		#Modify various aspects of the plot text and legend
		theme(legend.background=element_rect(),
			plot.title=element_text(angle=0, size=12, face="bold", vjust=1),

			panel.grid.major=element_blank(),	#Remove gridlines
			panel.grid.minor=element_blank(),	#Remove gridlines

			axis.text.x=element_text(angle=0, size=12, vjust=1),
			axis.text.y=element_text(angle=0, size=12, vjust=1),
			axis.title=element_text(size=12),

			#Legend
			legend.position="top",			#Moves the legend to the top of the plot
			legend.key=element_blank(),		#removes the border
			legend.key.size=unit(0.5, "cm"),	#Sets overall area/size of the legend
			legend.text=element_text(size=8),	#Text size
			title=element_text(size=8),		#Title text size
			legend.title=element_blank()) +		#Remove the title

		#Change the size of the icons/symbols in the legend
		guides(colour = guide_legend(override.aes=list(size=2.5))) +

		#Set x- and y-axes labels
		xlab(bquote(~Log[2]~ "fold change")) +
		ylab(bquote(~-Log[10]~adjusted~italic(P))) +

		#Set the axis limits
		#xlim(-6.5, 6.5) +
		#ylim(0, 100) +

		#Set title
		ggtitle(main) +

		#Tidy the text labels for a subset of genes
		geom_text(data=subset(toptable, padj<LabellingCutoff & abs(log2FoldChange)>FCCutoff),
			aes(label=rownames(subset(toptable, padj<LabellingCutoff & abs(log2FoldChange)>FCCutoff))),
			size=2.25,
			#segment.color="black", #This and the next parameter spread out the labels and join them to their points by a line
			#segment.size=0.01,
			check_overlap=TRUE,
			vjust=1.0) +

		#Add a vertical line for fold change cut-offs
		geom_vline(xintercept=c(-FCCutoff, FCCutoff), linetype="longdash", colour="black", size=0.4) +

		#Add a horizontal line for P-value cut-off
		geom_hline(yintercept=-log10(AdjustedCutoff), linetype="longdash", colour="black", size=0.4)
}
