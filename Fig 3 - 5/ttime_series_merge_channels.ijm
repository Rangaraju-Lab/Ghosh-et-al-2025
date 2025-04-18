//Two generate a two-channel stack image from two single-channel images
//Input files should be .tif or .tiff files with suffixes "Cx" with x specifying channel number.
//The images from two different channels should be saved in separate folders.
//The name of files from the same image acquisition should only be different by the channel number.

//Specify input directory 1 (channel 1). 
file1= "";
list1= getFileList(file1);

//Specify input directory 2 (channel 2). 
file2= "";
list2= getFileList(file2);

//Specify output directory, create a new folder if file2 is not exisiting 
file3= "";
File.makeDirectory(file3);

//Set batch mode
setBatchMode(true);

//The number of files in the two input folders should be the same.
//If not, an error message will be displayed and script will be terminated.
if (list1.length == list2.length) {
	for (i=0;i<list1.length; i++){ 
		open(file1+list1[i]);
		t1 = getTitle();
		name = File.nameWithoutExtension;
		open(file2+substring(t1,0,t1.length-5)+"1.tif");
		//Defalt is for .tif files. If the extension is tiff, use the code below instead:
		//open(file2+substring(t1,0,t1.length-6)+"1.tiff");
		t2 = getTitle();
		run("Merge Channels...", "c1=["+t2+"] c2=["+t1+"] create");
		saveAs("Tiff", file3+substring(name,0,name.length-3)+".tiff");
		print(substring(name,0,name.length-3)+" finished");
		close();		
	}
}
else{
	print("file number not matching!");
}

print("All done!");
	