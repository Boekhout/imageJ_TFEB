# imageJ_TFEB
This script was used to help determine nuclear/cytoplasmic ratio from microscopy images. The required input is an image that can shows segmented cells, for this purpose we used Cellpose, of which the seprate cells are changed into ROIs in the first part of this script. The second part takes a separate ROI, determines the nucleus in the other channel, and puts all measurements in .csv file. 
The accompanying manuscript is here (... Glycofridis et al.). 
