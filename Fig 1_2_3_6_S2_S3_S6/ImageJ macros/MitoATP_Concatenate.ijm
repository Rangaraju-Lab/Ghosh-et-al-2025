//Enter main file path for folder containing baseline and post-stimulus frames under Main
//Define Input and Output folders and hit Run
//Once concatenated stack is saved, BG subtract using time series analyzer

Main = "Path_to_experiment_folder";


//Find Input file location using any opened image from the folder
Input = Main+"input_images_subfolder"
//Make Output Directory within Input file location
Output = Main+"input_images_subfolder/output/"
File.makeDirectory(Output);
//Get list of all files from Input
filelist = getFileList(Input);

//Concatenate Luminescence Images
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "PREBASE3MIN") >= 0 && indexOf(filelist[i], "C0") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name1 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "BASE3MIN") >= 0 && indexOf(filelist[i], "C0") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name2 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMLUM") >= 0 && indexOf(filelist[i], "C0")>= 0)  {
    	open(Input+"/"+filelist[i]);
    	name3 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMFL10MIN") >= 0 && indexOf(filelist[i], "C0") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name4 = File.nameWithoutExtension;
    }
}

run("Concatenate...", "  title=LumStack image1=["+name1+".tif] image2=["+name2+".tif] image3=["+name3+".tif] image4=["+name4+".tif]");
saveAs("Tiff", Output+"L_Stack");
close("*");

//Concatenate Fluorescence Images
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "PREBASE3MIN") >= 0 && indexOf(filelist[i], "C1") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name1 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "BASE") >= 0 && indexOf(filelist[i], "C1") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name2 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMFL10MIN") >= 0 && indexOf(filelist[i], "C1") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	run("Slice Remover", "first=2 last="+nSlices+" increment=1");
    	rename("Copied Slice.tif");
    	name3 = "Copied Slice";
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMFL10MIN") >= 0 && indexOf(filelist[i], "C1") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name4 = File.nameWithoutExtension;
    }
}

run("Concatenate...", "  title=F_Stack image1=["+name1+".tif] image2=["+name2+".tif] image3=["+name3+".tif] image4=["+name4+".tif]");
saveAs("Tiff", Output+"F_Stack");
close("*");

//Concatenate GCaMP Images
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "PREBASE") >= 0 && indexOf(filelist[i], "C2") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name1 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "BASE") >= 0 && indexOf(filelist[i], "C2") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name2 = File.nameWithoutExtension;
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMFL10MIN") >= 0 && indexOf(filelist[i], "C2") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	run("Slice Remover", "first=2 last="+nSlices+" increment=1");
    	rename("Copied Slice.tif");
    	name3 = "Copied Slice";
    }
}

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")  && indexOf(filelist[i], "AFTERSTIMFL10MIN") >= 0 && indexOf(filelist[i], "C2") >= 0)  {
    	open(Input+"/"+filelist[i]);
    	name4 = File.nameWithoutExtension;
    }
}

run("Concatenate...", "  title=Ca_Stack image1=["+name1+".tif] image2=["+name2+".tif] image3=["+name3+".tif] image4=["+name4+".tif]");
saveAs("Tiff", Output+"Ca_Stack");
close("*");