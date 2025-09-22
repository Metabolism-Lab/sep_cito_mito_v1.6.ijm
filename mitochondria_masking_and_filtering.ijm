// Mitochondria ROI Masking and Background Subtraction
// ImageJ/Fiji Macro (.ijm)
// Author: Daniela Rauseo (2025)
// Description:
// 1) Ask for a frame number (in C2) to compute threshold for ROI-based mask via Mixture Modeling.
// 2) Create binary mask from user-entered "Real threshold".
// 3) Apply mask to C1 and C2 to create filtered stacks.
// 4) Compute per-stack minimum intensity (from unmasked stacks) and subtract it from filtered stacks.
// Requirements: "Mixture Modeling" and "Slice Keeper" plugins must be available.
// Assumes windows named "C1" and "C2" are open; adjust names below if different.

requires("1.53");

function ensureWindow(name) {
    if (!isOpen(name)) exit("Window '" + name + "' not found. Please open your data and name channels 'C1' and 'C2'.");
}

// ---- User input: frame used to compute the threshold ----
f = getNumber("Enter the frame number to use for calculation of threshold:", 1);

// ---- Prepare C2 copy and isolate frame f ----
ensureWindow("C2");
selectWindow("C2");
sliceSize = nSlices();
run("Select None");
run("Duplicate...", "title=[C2 full dup] duplicate");
selectWindow("C2 full dup");
run("Slice Keeper", "first=" + f + " last=" + f + " increment=1");
run("Restore Selection"); // if a ROI was defined before

// Convert to 8-bit and prepare duplicates
run("8-bit");
run("Select None");
rename("original");
run("Duplicate...", "title=1");
run("Duplicate...", "title=2");
selectWindow("original");
run("Restore Selection");

// ---- Mixture Modeling to estimate optimal threshold ----
run("Mixture Modeling");
selectWindow("Histogram"); close();
selectWindow("Threshold"); run("Create Selection");
selectWindow("1");
run("Restore Selection");
setForegroundColor(0, 0, 0);
run("Fill", "slice");
selectWindow("2");
run("Select All");
run("Make Inverse");
run("Restore Selection");
run("Fill", "slice");
selectWindow("Threshold"); close();
selectWindow("1"); close();
selectWindow("2"); close();
if (isOpen("Results")) { selectWindow("Results"); run("Close"); } // close transient results

// ---- User enters the 'Real threshold' from Mixture Modeling ----
t = getNumber("Enter the -Real threshold- value", 0);

// ---- Create mask from C2 using that threshold ----
selectWindow("C2 full dup");
run("8-bit");
setAutoThreshold("Default");
setThreshold(0, t);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Light black list");
waitForUser("This mask will be applied");
run("Invert", "stack");
run("Subtract...", "value=254 stack");
rename("binary mask");

// ---- Apply mask to C1 and C2 ----
ensureWindow("C1");
imageCalculator("Multiply create stack", "C1","binary mask");
selectWindow("Result of C1"); rename("filtered C1");

imageCalculator("Multiply create stack", "C2","binary mask");
selectWindow("Result of C2"); rename("filtered C2");

// ---- Compute per-stack minima from original (unfiltered) stacks and subtract ----
run("Set Measurements...", "min redirect=None decimal=3");

// Channel C1 minimum
selectWindow("C1");
saveSettings();
setOption("Stack position", true);
run("Clear Results");
for (n=1; n<=nSlices; n++) {
    setSlice(n);
    run("Measure");
}
b2 = 1e9;
for (i=0; i<sliceSize; i++) {
    b = getResult("Min", i);
    if (b < b2) b2 = b;
}
stackMin = b2;
selectWindow("filtered C1");
run("Subtract...", "value=" + stackMin + " stack");

// Channel C2 minimum
selectWindow("C2");
run("Clear Results");
for (n=1; n<=nSlices; n++) {
    setSlice(n);
    run("Measure");
}
c2 = 1e9;
for (i=0; i<sliceSize; i++) {
    c = getResult("Min", i);
    if (c < c2) c2 = c;
}
stackMin = c2;
selectWindow("filtered C2");
run("Subtract...", "value=" + stackMin + " stack");

restoreSettings();

// Cleanup
if (isOpen("C2 full dup")) close();
if (isOpen("original")) close();
if (isOpen("Results")) { selectWindow("Results"); run("Close"); }

showMessage("Done", "Generated:\n- binary mask\n- filtered C1 (min-subtracted)\n- filtered C2 (min-subtracted)");