//Spine tracker to measure luminescence intensity from the concatenated frames of baseline and post-induction
//Open concatenated image stack and then hit run
//Once the intensity values are saved open stack again to measure the next spine

Spine = getString("Spine Number:", "1");
Spine = "Spine_"+Spine

//Find Input file location
Input = getDirectory("image");
//Make Output Directory same as Input file location
Output = Input

close("Roi Manager");
close("Results");
run("Set Measurements...", "mean redirect=None decimal=3");

d = 5; //diameter of final ROI
shift_point = 4;
first_set = 3;

for (s = 1; s <= shift_point; s+=first_set) { 
	setSlice(s);
	setTool("Rectangle");
	waitForUser("Make a rough ROI around Spine, then Press \"OK\"");
	getSelectionBounds(x, y, w, h);
	if (s < shift_point) {
		loop_size = first_set;
	}
	else {
		loop_size = nSlices - first_set;
	}

	for (n = s; n < s+loop_size; n++) {
		run("Clear Results");
		setSlice(n);
		makeRectangle(x, y, w, h);
		//Scans ROI using circle of diameter d
		for (i = 0; i < w-d; i++) {
			for (j = 0; j < h-d; j++) {
				makeOval(x+i, y+j, d, d);	
				roiManager("add");
			}
		}
		roiManager("deselect");
		roiManager("measure");
		
		//Finds circle with Max Mean 
		Mean_Table = Table.getColumn("Mean");
		Mean_Table = Array.slice(Mean_Table,n-1,Mean_Table.length);
		Array.getStatistics(Mean_Table, min, max, mean, stdDev);
		//Deletes rest and keeps circle with Max Mean  
		for (i = 0; i < lengthOf(Mean_Table)-1; i++) {
			run("Clear Results");
			roiManager("Select", n-1);
			roiManager("Measure");
			if (getResult("Mean", 0) != max) {
				roiManager("delete");
			}
			else{
				roiManager("Select", n);
				roiManager("delete");
					
			}
		}
		run("Clear Results");
		run("Select None");
	}

}

waitForUser("Everything will be saved under:\n" + Input +"\nYou're Welcome! Press \"OK\" to Measure and Save All");

roiManager("deselect");
roiManager("measure");
roiManager("Select", 0);
roiManager("deselect");
saveAs("Results", Output + "/L_Raw_"+Spine+".csv");
roiManager("Save", Output + "/L_ROIs_"+Spine+".zip");

//Close All Open Items
close("*");
close("Roi Manager");
close("Results");
close("Log");  		