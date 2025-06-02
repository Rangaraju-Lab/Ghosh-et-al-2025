//To plot the spatial profile of fluorescent signals along a mannually plotted line (drawn from the stimulated spine along the dendrite up to 40um distal or proximal)
//Input files should be two-channel two-slice images containing polyline ROIs saved as overlay
//The names of the ROI should be in the format of "x_ROItype"
	//where x specifies the stimulation point number;
	//"ROItype" = "p" (positive) for polyline on the distal sides of the stimulated spine;
	//"n" (negative) for polyline on the proximal sides of the stimulated spine;
	//"bg" for background, one ROI for each stimulated point
//The output files are csv files with the following columns:
	//X: x coordinates of each point along the polyline, with an increment of 0.2um (or 1 pixel). Positive: distal; negative: proximal.
	//BG: background values for each stimulated point on each frame of each channel 
	//Y_pre_Cx: Baseline fluorescent values for each point along the polyline in channel x (0 = CytoRCaMP, 1 = MitoGCaMP or OMMGCaMP)
	//Y-bg_pre_Cx: Y_pre_Cx substracting background
	//Y_post_Cx: Poststim fluorescent values for each point along the polyline in channel x (0 = CytoRCaMP, 1 = MitoGCaMP or OMMGCaMP)
	//Y-bg_post_Cx: Y_post_Cx substracting background

//Function to find the index of an ROI with a specific name
function findRoiWithName(roiName) { 
	nR = roiManager("Count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
	return -1; 
}



//Specify input directory. 
file1= "Z:/DATA/Ruolin New/MitoATP/mitogcamp plot profile/plot profile/selected/";
list1= getFileList(file1);

//Specify output directory, create a new folder if file2 is not exisiting
file2= "Z:/DATA/Ruolin New/MitoATP/mitogcamp plot profile/plot profile data 060225/";
File.makeDirectory(file2);

//Set batch mode
setBatchMode(true);

//Loop through each image in the folder
for (f=0;f<list1.length; f++){ 
	open(file1+list1[f]);
	Stack.getDimensions(width, height, channels, slices, frames);
	t = getTitle();
	run("To ROI Manager");
	n = roiManager("count");
	
	//Collect all the stimulated points in one string "select_str"
	nSelect = newArray(0);
	for (j=0;j<n;j++){
		roiManager("Select",j);
		name = getInfo("selection.name");
		select_str = String.join(nSelect,"");
		if (select_str.contains(substring(name,0,1))==false){
			nSelect = Array.concat(nSelect, substring(name,0,1));
		}
	}
	select_str = String.join(nSelect,"");

	//Loop through each stimulated point
	for (j2=0;j2<select_str.length;j2++){
		name_bg = substring(select_str,j2,j2+1)+"_bg";
		name_n = substring(select_str,j2,j2+1)+"_n";
		name_p = substring(select_str,j2,j2+1)+"_p";
		
		//Loop through each channel
		for (c=0;c<channels;c++){
			
			//Obtain and save the background values for each slice and each channel
			roiManager("Select",findRoiWithName(name_bg));
			selectWindow(t);
			Stack.setPosition(c+1, slices, 1);
			bg1 = getValue("Mean");
			setResult("BG",2*c+0,bg1);
			Stack.setPosition(c+1, slices, 2);
			bg2 = getValue("Mean");
			setResult("BG",2*c+1,bg2);


			//Use "Plot Profile" function to obtain the fluorescent profile along the distal side of the polyline on the first slice (baseline)
			roiManager("Select",findRoiWithName(name_p));
			selectWindow(t);
			Stack.setPosition(c+1, slices, 1);
			run("Plot Profile");
			Plot.getValues(xpoints1, ypoints1);
			close();
			//Save the values from the plot to the result table
			for (i1=0; i1<xpoints1.length; i1++){
			     setResult("X", i1, xpoints1[i1]);
			     setResult("Y_pre_C"+c, i1, ypoints1[i1]);
			     setResult("Y-bg_pre_C"+c, i1, ypoints1[i1]-bg1);
			 }
			updateResults;
			
			//Repeat the above process on the second slice (poststim)
			selectWindow(t);
			Stack.setPosition(c+1, slices, 2);
			run("Plot Profile");
			Plot.getValues(xpoints1, ypoints2);
			close();
			for (i1=0; i1<xpoints1.length; i1++){
			     setResult("Y_post_C"+c, i1, ypoints2[i1]);
			     setResult("Y-bg_post_C"+c, i1, ypoints2[i1]-bg2);
			 }
			updateResults;

			//Repeat the same to the proximal side of the polyline
			roiManager("Select",findRoiWithName(name_n));
			selectWindow(t);
			Stack.setPosition(c+1, slices, 1);
			run("Plot Profile");
			Plot.getValues(xpoints2, ypoints3);
			close();
			for (i2=0; i2<xpoints2.length; i2++){
			     setResult("X", xpoints1.length+i2, -xpoints2[i2]);
			     setResult("Y_pre_C"+c, xpoints1.length+i2, ypoints3[i2]);
			     setResult("Y-bg_pre_C"+c, xpoints1.length+i2, ypoints3[i2]-bg1);
			 }
			updateResults;
			selectWindow(t);
			Stack.setPosition(c+1, slices, 2);
			run("Plot Profile");
			Plot.getValues(xpoints2, ypoints4);
			close();
			for (i2=0; i2<xpoints2.length; i2++){
			     setResult("Y_post_C"+c, xpoints1.length+i2, ypoints4[i2]);
			     setResult("Y-bg_post_C"+c, xpoints1.length+i2, ypoints4[i2]-bg2);
			 }
			updateResults;
			
		}

		//Save the result table as a csv file with the same name of the image file, plus a suffix of the stimulation point number "_x"
		saveAs("Results", file2+t+"_"+substring(select_str,j2,j2+1)+".csv");
		run("Clear Results");
		
	}
	
	run("Close All");
	
	//Close the result table after each file.
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Close");
	}

	print(t + " finished");
		
}
	
print("All done!");