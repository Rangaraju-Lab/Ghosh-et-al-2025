//To concatenate all GCaMP image stacks from baseline, pre- and post-stimulus frames
//Open any GCaMP image file to mark folder path and hit run
//Upload each image stack as mentioned below and say ok
//@File(label = "Output Folder", style = "directory") output
//@File(label = "Base Fluorescence", style = "file") prebaseF 
//@File(label = "Prestimulus Fluorescence", style = "file") baseF 
//@File(label = "Stimulus Fluorescence", style = "file") stimF
//@File(label = "Poststimulus Fluorescence", style = "file") postF
//First opens average Z stack of stimululation frames to identify spine
//Then stacks last frame of stimulus, baseline, pre- and post-stimulus frames
//Applies rolling ball background subtraction of the concatenated stack


// Save Concatenated Fluorescence images
open(prebaseF)
open(baseF);
open(stimF);
open(postF);
saveAs("Tiff", output+"/StimF_copy.tiff");
open(postF);
run("Concatenate...", "open image1 image2 image3 image4");
saveAs("Tiff", output+"/F_all.tiff");
run("Make Substack...", "slices=66,1,2,3,4,5,6,67,68,69,70,71,72,73,74,75,76");
close("\\Others");
saveAs("Tiff", output+"/F17.tiff");
close("*");

//Z project only Stimulus
open(output+"/StimF_copy.tiff");
run("Z Project...", "projection=[Average Intensity]");
close("\\Others");


//Add Z project as initial image to stack of 17 and save all 18 individually
open(output+"/F17.tiff");
run("Concatenate...", "open image1 image2");
saveAs("Tiff", output+"/F18.tiff");
run("Image Sequence... ", "select=["+output+"] dir=["+output+"] format=TIFF");
close("*");

//Background subtract F18 stack, and save each background subtracted frames
open(output+"/F18.tiff");
run("Subtract Background...", "rolling=50 stack");
saveAs("Tiff", output+"/F18_bg.tiff");
close("*");

open(output+"/F18_bg.tiff");
run("Image Sequence... ", "select=["+output+"] dir=["+output+"] format=TIFF");
close("*");



