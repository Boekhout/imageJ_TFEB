/*In this macro the objective is to define regions of interest of the cytoplasm. Required:
 * - output from cellpose
 * - the plugin Morhpholib (specifically for the function 'label boundaries'
 * 
 * This script first uses the output from cellpose to determine single cells
 * than loops over those single cells
 * separates nucleus from cytoplasm
 * and saves this as a separate file per cell (this might be inconvenient...)
 */

//define directory
//index files
// open
MyMaskDirectory = getDirectory("Which folder contains your cellpose output files?");
MyInputDirectory = getDirectory("Where are your GFP images located?");
ROISaveDirectory = getDirectory("Save ROIs of the cellpose in which folder?");
MeasurementDirectory = getDirectory("Designate a folder save your result files (measurements)?");
ListOfFiles = getFileList(MyMaskDirectory);
NumberOfFiles = ListOfFiles.length;

roiManager("reset");
run("Clear Results");
run("Close All");

//first make interpretable ROIs from the cellpose mask
for (i=0; i<NumberOfFiles; i++) {
	run("Bio-Formats Importer", "open=["+MyMaskDirectory+ListOfFiles[i]+"] color_mode = Composite view=Hyperstack stack_order=XYCZT stitch_tiles");
	Imagename = getTitle();
	rename("cellpose_mask");
	run("Duplicate...", " ");
	run("Colors...", "foreground=white background=black selection=yellow");
	run("Options...", "iterations=1 count=1 black do=Nothing");
	run("Label Boundaries");
	run("Invert");
	run("Erode");
	run("Divide...", "value=255");
	selectWindow("cellpose_mask-1-bnd");
	run("Enhance Contrast", "saturated=0.35");
	imageCalculator("Multiply create 32-bit", "cellpose_mask-1-bnd","cellpose_mask-1");
	selectWindow("Result of cellpose_mask-1-bnd");
	run("8-bit");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=1-Infinity overlay add");
	roiManager("Select All");
	if (roiManager("count")>0) roiManager("Save", ROISaveDirectory+Imagename+"totalcellROIs.zip");
	roiManager("reset");
	run("Close All");
	
}

	//in the next section, we couple the ROIs to the original image, and put the  measurements in the results table.. might be something off with the loops <- double check
	
ListOfOriginals = getFileList(MyInputDirectory); 
NumberOfOriginals = ListOfOriginals.length;

for (j=0; j<NumberOfOriginals; j++) {
	run("Bio-Formats Importer", "open=["+MyInputDirectory+ListOfOriginals[j]+"] color_mode = Composite view=Hyperstack stack_order=XYCZT stitch_tiles");
	Nameholder = getTitle();
	NewName = replace(Nameholder, ".tif", "_mask.tif");
	roiManager("Open", ROISaveDirectory+NewName+"totalcellRois.zip");
	countCells = roiManager("count");
	arrayCells = newArray(countCells);
			for (k=0; k<countCells; k++) {
			arrayCells[k] = k;
			selectWindow(Nameholder);
			roiManager("Select", k);
			run("Duplicate...", "duplicate title="+k);
			run("Clear Outside", "stack");
			Stack.setChannel(1);
			run("Enhance Contrast", "saturated=0.35");
			Stack.setChannel(2);
			run("Enhance Contrast", "saturated=0.35");
			Property.set("CompositeProjection", "Sum");
			Stack.setDisplayMode("composite");	
		//waitForUser;
			}	

		countWindows = roiManager("count"); 
		arrayWindows = newArray(countWindows); 
			for (h=0; h<countWindows; h++) {
				arrayWindows[h] = h;
			selectWindow(arrayWindows[h]);
		roiManager("Reset");
		roiManager("add"); // this is the entire cell region, maybe name it as so including the cell #?
		run("Split Channels");
		selectWindow("C1-"+h);
		run("Gaussian Blur...", "sigma=5");
		run("Auto Threshold", "method=Otsu white"); //previously used intermodes, but that sometimes led to undefined nuclei (DAPI background in cytoplasm?)
		//selectWindow("C1-"+h);
		run("Analyze Particles...", "size=1-Infinity pixel overlay add"); // this should be just the nucleus
		selectWindow("C2-"+h);
		roiManager("Select all"); 
		roiManager("XOR");	
		roiManager("add"); // this is entire cell - nucleus = cytoplasm
		run("Set Measurements...", "area mean modal min shape integrated median area_fraction limit redirect=None decimal=2");
		roiManager("Select all");
		roiManager("Measure");
		
		//waitForUser("have a check, mate"); 
		selectWindow("Results");
			
		}		
		resultsfile = "measured"+File.nameWithoutExtension+"_.xls";
		saveAs("text", MeasurementDirectory+resultsfile);
		run("Clear Results");
		roiManager("reset");
		//waitForUser("another spot to take a break");
		run("Close All");	
		
}
	
 

