library("gplots")
# Read in data
#HeatMap_Data = read.csv("Heatmap.csv")

HeatMap_Data = read.csv("MSK-PCa1-7_70Genes_v3.txt", sep="\t")
rownames(HeatMap_Data) = HeatMap_Data$X
HeatMap_Data = HeatMap_Data[,-c(1)]

Group = substring(colnames(HeatMap_Data),1,2)

Group.Color = c("yellow","cyan","blue","black","red","green")

ColSideColors = Group.Color[match(Group, unique(Group))];


###################################################
# Create Heap Maps with raw values and no "dendrogram" clustering
win.graph()
heatmap.2(as.matrix(HeatMap_Data), cexRow = 0.8, dendrogram = "none", scale ="none", Rowv = NA, Colv = NA, col=greenred(75), key=TRUE, symkey=FALSE, density.info="none", trace="none")


win.graph()

# Create Heap Maps with z score value on row, and no "dendrogram" clustering, and ColSideColors

heatmap.2(as.matrix(HeatMap_Data), na.rm = T, cexRow = 0.8, dendrogram = "none", scale ="row", Rowv = NA, Colv = NA, col=greenred(75), key=TRUE, symkey=FALSE, density.info="none", trace="none", ColSideColors=ColSideColors)



win.graph()

# Create Heap Maps with z score value on row, with clustering on rows and columns, and ColSideColors

heatmap.2(as.matrix(HeatMap_Data), na.rm = T, cexRow = 0.8, dendrogram = "both", scale ="row", Rowv = TRUE, Colv = TRUE, col=greenred(75),  key=TRUE, symkey=FALSE, density.info="none", trace="none", ColSideColors=ColSideColors)





win.graph()

# Create Heap Maps with z score value on row, with clustering on rows and columns, and ColSideColors

heatmap.2(as.matrix(t(HeatMap_Data)), na.rm = T, cexRow = 0.8, dendrogram = "both", scale ="col", Rowv = TRUE, Colv = TRUE, col=greenred(75),  key=TRUE, symkey=FALSE, density.info="none", trace="none")
