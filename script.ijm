// Background Removing
imageTitle = getTitle();
run("Duplicate...", "title=BG");
run("Gaussian Blur...", "sigma=80");
imageCalculator("Subtract create 32-bit", imageTitle,"BG");
run("8-bit");

// Histogram Based Contrast Adjustment
makeRectangle(0, 0, 1024, 686);
run("Crop");

run("8-bit");
blocksize = 127;
histogram_bins = 256;
maximum_slope = 3;
mask = "*None*";
fast = true;
process_as_composite = true;

getDimensions( width, height, channels, slices, frames );
isComposite = channels > 1;
parameters =
  "blocksize=" + blocksize +
  " histogram=" + histogram_bins +
  " maximum=" + maximum_slope +
  " mask=" + mask;
if ( fast )
  parameters += " fast_(less_accurate)";
if ( isComposite && process_as_composite ) {
  parameters += " process_as_composite";
  channels = 1;
}
  
for ( f=1; f<=frames; f++ ) {
  Stack.setFrame( f );
  for ( s=1; s<=slices; s++ ) {
    Stack.setSlice( s );
    for ( c=1; c<=channels; c++ ) {
      Stack.setChannel( c );
      run( "Enhance Local Contrast (CLAHE)", parameters );
    }
  }
}


// Measurements for Grain Size
run("Invert LUTs");
run("Smooth");
run("Convert to Mask");
run("Options...", "iterations=3 count=6 black pad do=Open");

run("Watershed");

run("Clear Results");
setTool("oval");
waitForUser("Measure one cell diameter with (Ctrl+M) then click <OK>");

// Retrieve the area from the results table
area = getResult("Area", nResults-1);
print("Area of the selection: " + area);

min = area*0.2;
max = area*5.0;
run("Clear Results");

setThreshold(255, 255);
run("Convert to Mask");
run("Analyze Particles...", "size=min-max circularity=0.65-1.00 show=[Overlay Masks] display exclude clear summarize overlay add");
