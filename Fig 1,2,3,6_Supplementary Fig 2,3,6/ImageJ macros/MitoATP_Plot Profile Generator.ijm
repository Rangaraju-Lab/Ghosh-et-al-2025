//Plot profile generator via ridge selection
//Path to Main Folder where the SlideBook exported images are located
//Main = "Z:/DATA/Ilika/mitoATP/91623 dish1 control/";
Main = "Path_to_input_images_folder";

//Find Input file location where stacks created by Concatenate.ijm are present
Input = Main+"output/"
//Make Output Directory within Input file location
//Output = Input+"Profile/"
//File.makeDirectory(Main);
//Get list of all files from Input
filelist = getFileList(Input);


//Detect which Stimulation Point are we analyzing
stimpoint = 1;
for (i = 0; i < lengthOf(filelist); i++) {
    //if (endsWith(filelist[i], ".csv")  && indexOf(filelist[i], "StimPoint") >= 0 )  {
    if (indexOf(filelist[i], "StimPoint") >= 0 )  {    	
    	name = File.getNameWithoutExtension(Input+filelist[i]);
		stimpoint = split(name, "Profile_Traces_StimPoint_TimePoint");
		stimpoint = stimpoint[0];
		stimpoint = parseInt(stimpoint) + 1;
    }
}
//Make Output Directory within Input file location
Output = Input+"Profile_StimPoint"+stimpoint+ "/"
File.makeDirectory(Output);


//Open Ca_Stack from input folder
open(Input+"Ca_Stack.tif");
getPixelSize(unit, pixelWidth, pixelHeight);
name = File.nameWithoutExtension;
run("Z Project...", "projection=[Average Intensity]");
close("\\Others");
setTool("oval");
run("Set Measurements...", "center redirect=None decimal=3");

//Mark Spine on GCaMP_Stack Avg Project to identify spine
waitForUser("Mark Spine", "Circle Stimulated Spine");
run("Measure");
SpineX = getResult("XM", 0)/pixelWidth;
SpineY = getResult("YM", 0)/pixelWidth;
close("Results");

//Detected Ridges in the GCaMP_Stack i.e. detect dendrites (truncated at branch points)
run("8-bit");
run("Ridge Detection", "line_width=5 high_contrast=230 low_contrast=87 add_to_manager method_for_overlap_resolution=NONE sigma=3.39 lower_threshold=0.51 upper_threshold=1.19 minimum_line_length=25 maximum=[]");
//run("Ridge Detection", "line_width=5 high_contrast=230 low_contrast=87 add_to_manager method_for_overlap_resolution=NONE sigma=3.39 lower_threshold=0.51 upper_threshold=1.19 minimum_line_length=25 maximum=[]");
run("Remove Overlay");

//Remove junctions from Roi Manager
RemoveJunctions();

//Keep ridge roi only under spine of interest
sdia = 100;
makeOval(SpineX - sdia/2, SpineY - sdia/2, sdia, sdia);
roiManager("add");
RemoveRidges();

//Find coordinates and split the ridge right under the spine
XY0 = RidgeIntercept(SpineX, SpineY)
roiManager("show all");

//waitForUser("Check Ridges", "Proofread Ridges.");

//Trim each split ridge to 40 um length
max_len = 40;
roiManager("select", 1);
TrimLine(max_len, "ridge1");
roiManager("select", 2);
TrimLine(max_len, "ridge2");
roiManager("select", newArray(0,1,2));
roiManager("delete");


//Open Fluorescence_Stack  
open(Input+"F_Stack.tif");
getPixelSize(unit, pixelWidth, pixelHeight);
name = File.nameWithoutExtension;
close("\\Others");


//Snap vertices of ridges to trace F_Stack
n = roiManager("count");
for (j = 0; j < n; j++) {
	roiManager("select", j);
	SnapVertices(j);   	
}	 
for (j = 0; j < n; j++) {
	roiManager("select", 0);
	roiManager("delete");  	
}

for (j = 0; j < n; j++) {
	roiManager("select", j);
	roiManager("Rename", "Ridge"+ toString(j+1));
}

roiManager("show all");

//Open Luminescence_Stack
open(Input+"L_Stack.tif");
getPixelSize(unit, pixelWidth, pixelHeight);
name = File.nameWithoutExtension;
roiManager("show all");


waitForUser("Check Ridges", "Proofread Ridges.");

//Save L/F ratios for each time frame
for (i = 1; i <= nSlices; i++) {
    selectWindow("L_Stack.tif");
    setSlice(i);
    Profiler("L");
    
    selectWindow("F_Stack.tif");
    setSlice(i);
    Profiler("F");
    for (j = 0; j < nResults(); j++) {
    	L = getResult("L_Intensity", j);
    	F = getResult("F_Intensity", j);
    	setResult("LbyF", j, L/F);
	}
	updateResults();
	saveAs("Results", Output+"LF_Profile_StimPoint"+stimpoint+ "_TimePoint"+ i + ".csv");
    close("Results");
    // do something here;
}

roiManager("deselect");
roiManager("Save", Input+ "Traces_StimPoint"+stimpoint+ ".zip");
close("*");
close("Roi Manager");




function RemoveJunctions() { 
	n = roiManager("count");
	del_arr = newArray(1);
	for (i = 0; i < n; i++) {
	    roiManager("select", i);
	    if (selectionType() != 7){
	    	del_arr = Array.concat(del_arr,i);
	    }
	}
	del_arr = Array.deleteIndex(del_arr, 0);
	
	roiManager("select", del_arr);
	roiManager("delete");
}


function median(x){
	x=Array.sort(x);
	if (x.length%2>0.5) {
		m=x[floor(x.length/2)];
	}else{
		m=(x[x.length/2]+x[x.length/2-1])/2;
	};
	return m
}


function RemoveRidges() { 
	del_arr = newArray();
	n = roiManager("count");
	for (i = 0; i < n-1; i++) {
	    roiManager("select", newArray(n-1, i));
	    roiManager("AND");
	    if (selectionType() == -1){
	    	del_arr = Array.concat(del_arr, i);
	    	//print("N");
	    }
	}
	del_arr = Array.concat(del_arr, n-1);
	roiManager("select", del_arr);
	roiManager("delete");
}


function RidgeIntercept(SpineX, SpineY) { 
	roiManager("select", 0);
	Roi.getCoordinates(xpoints, ypoints);
	ed_arr = newArray();
	for (i = 0; i < lengthOf(xpoints); i++) {
		x2 = xpoints[i];
		y2 = ypoints[i];
		
		x1 = SpineX;
		y1 = SpineY;
		ed =  Math.sqrt(Math.sqr(x2 - x1) + Math.sqr(y2 - y1)) ;
		ed_arr = Array.concat(ed_arr,ed);
	}
	//Array.print(ed_arr);
	Array.getStatistics(ed_arr, min, max, mean, stdDev);
	for (i = 0; i < lengthOf(ed_arr); i++) {
		if (ed_arr[i] == min) {
			XY0 = newArray(xpoints[i], ypoints[i]);
			ridge1x = Array.slice(xpoints,0,i);
			ridge1y = Array.slice(ypoints,0,i);
			
			ridge2x = Array.slice(xpoints,i,lengthOf(xpoints));
			ridge2y = Array.slice(ypoints,i,lengthOf(ypoints));
		}
	}
	
	makeSelection("freeline", ridge1x, ridge1y);
	roiManager("add");
	makeSelection("freeline", ridge2x, ridge2y);
	roiManager("add");
	return XY0;
	//makePoint(XY0[0], XY0[1]);
}


function TrimLine(max_len, ridge) { 
	Roi.getCoordinates(xpoints, ypoints);
	run("Measure");
	line_len = getResult("Length", 0);
	close("Results");
	while (line_len > max_len) {
		if (ridge == "ridge1") {
			xpoints = Array.slice(xpoints, 1, lengthOf(xpoints));
			ypoints = Array.slice(ypoints, 1, lengthOf(ypoints));
			makeSelection("freeline", xpoints, ypoints);
			run("Measure");
			line_len = getResult("Length", 0);
			close("Results");
		}
		
		if (ridge == "ridge2") {
			xpoints = Array.slice(xpoints, 0, lengthOf(xpoints)-1);
			ypoints = Array.slice(ypoints, 0, lengthOf(ypoints)-1);
			makeSelection("freeline", xpoints, ypoints);
			run("Measure");
			line_len = getResult("Length", 0);
			close("Results");
		}
		
	}
	makeSelection("freeline", xpoints, ypoints);
	roiManager("add");
}

function SnapToMax(selected_roi, sr) { 
	run("Set Measurements...", "mean center redirect=None decimal=3");
	roiManager("select", selected_roi);
	Roi.getCoordinates(xpoints, ypoints);
	x0 = xpoints[0] - sr;
	y0 = ypoints[0] - sr;
	
	x_arr = Array.getSequence(sr*2+1);
	y_arr = Array.getSequence(sr*2+1);
	
	for (i = 0; i < lengthOf(x_arr); i++) {
		x_arr[i] = x_arr[i] - sr;
		y_arr[i] = y_arr[i] - sr;
	}
	
	//Array.print(x_arr);
	//Array.print(y_arr);
	ctr = 0;
	for (i = 0; i < lengthOf(x_arr); i++) {
		for (j = 0; j < lengthOf(y_arr); j++) {
			//roiManager("select", 0);
			RoiManager.translate(x_arr[i], y_arr[j]);
			roiManager("Measure");
			//print(x_arr[i], y_arr[j]);
			//print(-x_arr[i], -y_arr[j]);
			setResult("X", ctr, x_arr[i]);
			setResult("Y", ctr, y_arr[j]);
			ctr += 1;
			//roiManager("add");
			//wait(100);
			RoiManager.translate(-x_arr[i], -y_arr[j]);
			//wait(100);
			//roiManager("Measure");
			//print(x_arr[i], y_arr[j]);
			//roiManager("Measure");
			//print(y_arr[j]);
			//roiManager("add");
			//wait(100);
		}
	}
	Mean_col = Table.getColumn("Mean");
	Array.getStatistics(Mean_col, min, max, mean, stdDev);
	print(max);
	for (i = 0; i < lengthOf(Mean_col); i++) {
		if (Mean_col[i] ==  max) { 
			max_row = i;
		}
	}
	print(max_row);
	X_max = getResult("X", max_row);
	Y_max = getResult("Y", max_row);
	print(X_max, Y_max);
	roiManager("select", selected_roi);
	RoiManager.translate(X_max, Y_max);
	close("Results");
	close("Log");
		

}


function BgS() {
	run("Set Measurements...", "mean center redirect=None decimal=3");
	setTool("rectangle");
	waitForUser("Background Subtraction", "Make  Background ROI");
	Roi.getBounds(x, y, width, height);
	run("Select None");
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
	    makeRectangle(x, y, width, height);
	    run("Measure");
		Bg = getResult("Mean", 0);
	    run("Select None");
	    run("Subtract...", "value="+Bg+" slice");
	    
	}
	setSlice(1);
	resetMinAndMax();
	close("Results");
}

function SnapVertices(selected_roi){
	Roi.getCoordinates(xpoints, ypoints);
	makeSelection("polyline", xpoints, ypoints);
	intp_intv = 10;
	run("Interpolate", "interval="+intp_intv+" smooth adjust");
	//Vertex Fit Radius
	vfrx = 3;
	vfry = 3;
	//Vertex Search Radius
	vsrx = 1;
	vsry = 1;
	//Vertex Circle Coordinate offset
	vccox = (vfrx-1)/2;
	vccoy = (vfrx-1)/2;	

	roi_slice = roiManager("count");
	run("Set Measurements...", "mean center redirect=None decimal=3");
	Roi.getCoordinates(xpoints, ypoints);
	x_len = xpoints.length;
	new_xpoints = xpoints;
	new_ypoints = ypoints;
			
	// Anchor First Vertex
	vx = xpoints[0];
	vy = ypoints[0];
	new_xpoints[0] = vx;
	new_ypoints[0] = vy;
			
	//Find Maxima's around intermediate vertices
	for (i = 1; i < x_len-1; i++) {
		roi_count = roiManager("count");
		vx = xpoints[i] - vccox;
		vy = ypoints[i] - vccoy;
		for (j = vx-vsrx; j <= vx+vsrx; j++) {
			for (k = vy-vsry; k <= vy+vsry; k++) {
				j = round(j); //Silence for subpixel accuracy
				k = round(k); //Silence for subpixel accuracy
				makeOval(j, k, vfrx, vfry);
				roiManager("Add");
			}
		}
		roiManager("Deselect");
		roiManager("Measure");
		Mean_Table = Table.getColumn("Mean");
		close("Results");
		Mean_Table = Array.slice(Mean_Table, roi_count, lengthOf(Mean_Table));
		ind_max_res = Array.findMaxima(Mean_Table, 0);
		ind_max_roi = ind_max_res[0] + roi_count;
		roiManager("deselect");
		roiManager("select", ind_max_roi);
		Roi.getBounds(vx, vy, vbboxw, vbboxh);
		vx = vx + vccox;
		vy = vy + vccoy;
		new_xpoints[i] = vx;
		new_ypoints[i] = vy;
		roiManager("deselect");
		all_fits = Array.getSequence(roiManager("count"));
		all_fits = Array.slice(all_fits, roi_count, lengthOf(all_fits));
		unfits = Array.deleteValue(all_fits, ind_max_roi);
		roiManager("select", unfits);
		roiManager("Delete");
		roiManager("deselect");
	}
			
	// Anchor Last Vertex
	vx = xpoints[x_len-1];
	vy = ypoints[x_len-1];
	new_xpoints[x_len-1] = vx;
	new_ypoints[x_len-1] = vy;	
	
	//Make Fit Line using Updated Vertices
	makeSelection( "freeline", new_xpoints, new_ypoints );
	//Roi.setStrokeWidth(1);
	roiManager("Add");
			
	//Delete Vertex Fits
	vert_fits = Array.getSequence(roiManager("count"));
	vert_fits = Array.slice(vert_fits, roi_slice, vert_fits.length - 1);
	roiManager("select", vert_fits);
	roiManager("Delete");
}

function Profiler(prefix) { 
	roiManager("select", 0);
	roiManager("Set Color", "#66ffff00");
	roiManager("Set Line Width", 5);
	profile1 = getProfile();
	dSpine1 = newArray(lengthOf(profile1));
	for (i = 0; i < lengthOf(dSpine1); i++) {
		dSpine1[i] = -i*pixelWidth;
	}
	dSpine1 = Array.reverse(dSpine1);
	roiManager("select", 1);
	roiManager("Set Color", "#66ffff00");
	roiManager("Set Line Width", 5);
	profile2 = getProfile();
	dSpine2 = newArray(lengthOf(profile2));
	for (i = 0; i < lengthOf(dSpine2); i++) {
		dSpine2[i] = i*pixelWidth;
	}
	
	profile = Array.concat(profile1, profile2);
	dSpine = Array.concat(dSpine1, dSpine2);
	Table.setColumn(prefix+"_Distance", dSpine);
	Table.setColumn(prefix+"_Intensity", profile);
}
