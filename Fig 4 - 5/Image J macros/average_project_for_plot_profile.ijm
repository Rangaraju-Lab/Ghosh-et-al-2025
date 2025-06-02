//This is for generating average projected images for baseline time points and post-stim time points for plot profile analysis
//Input files should be two-channel multi-frame stack images.
//Output files are two-channel two-slice images with each frame the average projection of baseline frames and post-stim frames, respectively

//Specify input directory. 
file1= "";
list1= getFileList(file1);

//Specify output directory, create a new folder if file2 is not exisiting
file2= "";
File.makeDirectory(file2);

//Set batch mode
setBatchMode(true);


list1= getFileList(file1);
for (i=0;i<list1.length; i++){ 
	open(file1+list1[i]);
	t = split(list1[i], ".");
	name = t[0];
	ext = t[1];

//Average project the baseline frames, which is 1 to 5 frames of the time lapse
	run("Duplicate...", "duplicate slices=1-5");
	run("Z Project...", "projection=[Average Intensity]");

//Slice and average project the post-stim frames (the first frame after each stimulation pulse)
	selectWindow(list1[i]);
	run("Split Channels");
	selectWindow("C2-"+list1[i]);
	run("Slice Keeper", "first=6 last=45 increment=4");
	run("Z Project...", "projection=[Average Intensity]");
	selectWindow("C1-"+list1[i]);
	run("Slice Keeper", "first=6 last=45 increment=4");
	run("Z Project...", "projection=[Average Intensity]");
	run("Merge Channels...", "c1=[AVG_C1-"+list1[i]+" kept stack] c2=[AVG_C2-"+list1[i]+" kept stack] create");
	run("Concatenate...", "open image1=[AVG_"+name+"-1."+ ext+"] image2=Composite");

//Save the images by adding "AVG_" to the original name	
	saveAs("Tiff", file2+"AVG_"+name);
	run("Close All");
}

print("All done!");

	
