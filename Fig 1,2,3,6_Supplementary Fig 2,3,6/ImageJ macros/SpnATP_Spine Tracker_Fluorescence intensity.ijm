//Spine tracker to measure fluorescence intensity from the concatenated frames of baseline and post-induction
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
run("Set Measurements...", "area mean center redirect=None decimal=3");

d = 5 //diameter of final ROI



waitForUser("Make a rough ROI around Spine, then Press \"OK\"");


for (i = 1; i <= nSlices; i++) {
  	setSlice(i);
  	roiManager("Add");
}
  	
for (i = 1; i <= nSlices; i++) {
  	roiManager("Select", i-1);
	run("Find Maxima...", "prominence=10 exclude output=[Point Selection]");
	run("Measure");
	X = getResult("XM", 0);
	Y = getResult("YM", 0);
	run("Select None");
	makePoint(X, Y, "small yellow hybrid");
	makeOval(X-((d-1)/2), Y-((d-1)/2), d, d);
	roiManager("Add");
	roiManager("deselect");
	run("Clear Results");
}

for (i = 1; i <= nSlices; i++) {
  	roiManager("Select", 0);
  	roiManager("delete");
}

//for (i = 1; i <= nSlices; i++) {
//  	roiManager("Select", i-1);
//  	roiManager("Rename", "Spine 1");
//}

roiManager("deselect");
run("Set Measurements...", "mean redirect=None decimal=3");
roiManager("measure");

saveAs("Results", Output + "/F_Raw_"+Spine+".csv");
roiManager("Save", Output + "/F_ROIs"+Spine+".zip");

//Close All Open Items
waitForUser("Everything is saved under:\n" + Input +"\nYou're Welcome! Press \"OK\" to Close All");
close("*");
close("Roi Manager");
close("Results");
close("Log");  	