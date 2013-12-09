// T-Slots and Tabs
// This collection of modules will create interlocking slots and tabs for you, to be used in fastening lasercut (or milled) sheet material.
// usage:
// TODO

// variables:
// These variables are set to a default in this file. Either use the defaults, re-set them after including the file, or use them and define all variables yourself.

X=300; 			//default length 
thickness=6; 	//thickness of the primary sheet material.
depth=thickness;		//how much the teeth stick out.
tol=0.05; 		//tolerance amount to overcome scad difficulties. Could be redefined to stand in for a lasercut offset?
tSlotWidth=3;	//width of the t-slot. probably should be the nominal width of your bolts, but it could be a little less to allow for alaser kerf width.
tSlotLength=6; //length/depth of the t-slot. It should fit the intended bolt (bolt < thickness + tSlotLength).
nutWidth=5.5; 	//-tol? Width of M3 nut between flats
nutThickness=2.4; //-tol?

//create one single tab, the material side is along the X-axis towards you.
module tab(add=true)
{
	if (add==true)
	{
		translate([-1.5*thickness,0,0])
			cube([3*thickness, depth -tol, thickness]);
	}
	else
	{	
		translate([-1.5*thickness,0,0])
			cube([3*thickness, depth + tol, thickness]);
	}
}

//create a side of tabs only, no screw holes and t-slots.
module tabs(startC=[0,0,0], length=X, rotation=[0,0,0], number)
{
	translate(startC)
		rotate(rotation)
			for (n=[1:number])
			{
				translate([n*length/number - length/(2*number),0,0])
					cube([3*thickness, thickness + 3*tol, thickness]);
					//cube([2, 1, 1]);
			}	
}

//create one single t-slot to be subtracted from the side of your sheet. 
//to make things more complicated, sheet material is now all in the positive quadrant, along the X axis away from you. :)
module tSlot(add=true)
{
	if (add==true)
		{	
			translate([-0.5*tSlotWidth,0,-tol]) cube([tSlotWidth, tSlotLength, thickness + 2*tol]);
			translate([-nutWidth/2,tSlotLength/2,-tol]) cube([nutWidth,nutThickness, thickness + 2* tol]);
			
		}
		else
		{
			translate([0,0,thickness/2])
				rotate([90,0,0]) 
					cylinder(r=tSlotWidth/2, h= 4* thickness, $fn=18, center=true);
		}
}
//create a side of evenly spaced t-slots with tabs on on both sides
//startC: 	starting coordinate
//length: 	length to be used for this strip, can be more or less than the actual side.
//rotation: rotate before translation.
//number: 	amount of tab-slot-tab combos.
//tab:		false if no tabs are required in this invokation
//tSlot: 	false if no tSlots are required.
//add:		true if making additions to shape, false if their negative counterparts are to be removed.
module tSlotsAndTabs(startC=[0,0,0], length=X, rotation=[0,0,0], number, tab, tSlot, add=true)
{
	translate(startC)
		rotate(rotation)
			for (n=[1: number])
			{
				translate([(-0.5 + n)*length/number ,0,0])
				{
					
					if (tab) translate([5* thickness,-thickness,0]) tab(add);
					if (tSlot) tSlot(add);
					if (tab) translate([-5* thickness,-thickness,0]) tab(add);
				}	
			}	
}