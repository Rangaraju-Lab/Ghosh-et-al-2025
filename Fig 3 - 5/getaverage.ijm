//To measure the intensities of ROIs generated through mannual segmentation and added as overlays.
//Input files should be two-channel multi-frame stack images.
//ROIs to be measured should be saved as overlay with names in the format of "x_ROItype", 
//where x specifies the stimulation point number, "ROItype" = "sp" for spine; "stim" for mito, dendrite or ER; and "bg" for background



//Specify input directory. 
file1= "";
//Specify output directory, create a new folder if file2 is not exisiting
file2= "";
File.makeDirectory(file2);

//Set batch mode
setBatchMode(true);

//Clear exisiting data in the results table, if any.
run("Clear Results");

//Loop through all files in the input folder file1.
//Open the file and measure the fluorescent intensities of all ROIs saved as overlays.
list1= getFileList(file1);
for (f=0;f<list1.length; f++){ 
	open(file1+list1[f]);
	t = File.nameWithoutExtension;
	
	//The file should be a multi-frame, single-slice image to be processed in the following steps. 
	//Switch the slice and frame dimension if otherwise. 
	Stack.getDimensions(width, height, channels, slices, frames);
	if ((slices>1)&(frames==1)){
		run("Properties...", "channels=channels frames=slices slices=1");
		Stack.getDimensions(width, height, channels, slices, frames);
	}
	//Check if there is any ROIs saved as overlay.
	//Display error message and close the image if no overlay has been saved.
	if (Overlay.size==0){
		 print(t + " has no overlay!");
		 run("Close All");
	}
	else{
		//Add overlay to ROI manager to retrieve all the ROIs saved before.
		//Measure all the mean intensities in both channels and display on the result table.
		run("To ROI Manager");
		for (i=0;i<roiManager("count");i++){
			roiManager("Select", i);
			name = Roi.getName;
			for (n=0;n<channels;n++){
				for (j=0;j<frames;j++){
					Stack.setPosition(n+1,slices, j+1);
					mean = getValue("Mean");
					setResult("C"+n+"_"+name,j,mean);
				}
			}		
			updateResults;		
		}
		
		//Save the result into csv files
		
		saveAs("Results", file2+t+".csv");
		run("Clear Results");
		run("Close All");
		print(t + " finished");
	}
	
}

print("All done!");