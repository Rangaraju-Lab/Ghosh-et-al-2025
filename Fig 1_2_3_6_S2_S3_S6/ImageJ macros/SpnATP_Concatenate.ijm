//Concatenate all fluorescence and luminescence frames of baseline and post-induction
//Find Input file location using an opened image from the folder
Input = getDirectory("image");
//Make Output Directory within Input file location
Output = Input+"/Output"
File.makeDirectory(Output);
//Close the opened image
close("*");
//Get list of al files from Input
filelist = getFileList(Input);
//Open only Fluorescence Files
for (i = 0; i < lengthOf(filelist); i++) {
	//if condition checks whether file is a tiff file then performs tasks within {}
    if (endsWith(filelist[i], ".tif")) {
    	 if (indexOf(filelist[i], "C1") >= 0) {
    	 		open(filelist[i]);
    	 		if (indexOf(filelist[i], "LUM") >= 0) {
					close();
    	 		}
    	 		if (indexOf(filelist[i], "1LP") >= 0) {
    	 			close();
    	 		}
    	 }
    	 if (indexOf(filelist[i], "1LP") >= 0) {
    	 		if (indexOf(filelist[i], "C0") >= 0){
    	 			open(filelist[i]);
    	 			run("Slice Remover", "first=1 last=59 increment=1");
    	 		}	    	 	
    	}
    	
	}
}

//Get Image Name, Width and Pixel Size 
width = getWidth();
getPixelSize(unit, pixelWidth, pixelHeight);

//open Concatenate Window and Arrange Sequence Manually
run("Concatenate...");

//Runs SIFT based feature detection and Stack Alignment and save aligned stack
run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size="+width+" feature_descriptor_size=8 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=15 inlier_ratio=0.20 expected_transformation=Rigid interpolate");
run("Set Scale...", "distance="+(1/pixelWidth)+" known=1 unit="+unit);
saveAs("Tiff", Output +"/Aligned_All_Fluorescence");
close("*");

//Open only Luminescence Files
for (i = 0; i < lengthOf(filelist); i++) {
	//if condition checks whether file is a tiff file then performs tasks within {}
    if (endsWith(filelist[i], ".tif")) {
    	 if (indexOf(filelist[i], "C0") >= 0) {
    	 	open(filelist[i]);    	 	
    	 }
    	 if (indexOf(filelist[i], "C0") >= 0) {
    	 	if (indexOf(filelist[i], "LUM") >= 0){
    	 		open(filelist[i]);
    	 	}    	 	
    	 }
    }
}
//open Concatenate Window and Arrange Sequence Manually
run("Concatenate...");
saveAs("Tiff", Output +"/All_Luminescence");
close("*");
close("Log");