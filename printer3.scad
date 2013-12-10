//printer3.scad 3D printer with parallel X and Y axes (ultimaker-like). The Built platform moves in the X & Y direction, a second X carriage moves extruder cassettes  to the middle of the machine, while a Z-axis lifts them from the built platform.
/* copyright 2013 Jelle Boomstra, jelle.boomstra@gmail.com*/
/* All the works in this distribution are licensed to you under the terms of the Creative Commons Attribution Share Alike (CC-BY-SA, http://creativecommons.org/licenses/by-sa/3.0/) license.
*/

use <nema17.scad> ;
include <milledDiBondSlotsAndTabs.scad>;
 

X=300;
Y=300;
Z=300;
Rx=4;
R2x=6;
Ry=4;
Rz=6;
tol=0.150;
// tol=2;
thickness=6;
thickness2=3;
depth=2;
bevel=5;
diBondRadius=(6*2/3.1415) - 2;
rimFront=X/8;
rimBack=max(X/6, 42);
//rimTop=Y/8;
rimTop=rimFront;
// rimBottom=max(Y/6,39 + 2*thickness); 
// rimBottom= max(42 + 2, 2*AxisOffset + AxisPlaneDistance);
Rbearing=8;
RboltHead=3;
Rbolt=1.5;
nutWidth=5.5; //-tol? Width of M3 nut between flats
nutThickness=2.4; //-tol?
tSlotWidth=3;
tSlotLength=10;

AxisOffset=21; //sized for nema17 motor direct drive
// AxisOffset= max ((11/2 + 1 + 2), Rbearing + 2); //bushing outer diameter + wall thickness of its holder + margin
// ZaxisOffset=32/2 + 1; //how far should the Z-axis be from the side. Also used to calculate clearance for the back X axis.
ZaxisOffset=42 + thickness + 1;
ZaxisSpread=150; //how far apart are the two Z-axis rails?
AxisOffsetBack=AxisOffset + Rz + ZaxisOffset + 1;
AxisPlaneDistance=18;
X2offset=50; //determines how far back(Y) from the center of the machine the axes are placed
Ztravel=50;  //maximum travel of the Z-stage (mounted on the X2 stage)
rimBottom=  2*AxisOffset + AxisPlaneDistance;

pulleyWidth= 21; //effective (max) width of the belt over the pulleys


//derived from above:
windowFrontX = X;
windowFrontY = rimBottom;
windowSideX = Y/2;
windowSideY = Z;
windowTopX = X - 2* AxisOffset - 2*Rx - 2*bevel ;
windowTopY = Y - AxisOffset -AxisOffsetBack - 2*Ry - 2*bevel;

tableHeight= 2*AxisOffset + AxisPlaneDistance + 2* thickness2 + thickness; //


ZaxisLenght=Z-rimBottom-3*thickness;

module bearingAssembly(bx, by, bz, rot=[0,0,0], holesOnly=0)
{
	

	if (holesOnly == 1)
	{
		translate([bx,by, bz]) rotate(rot)
		{
			cylinder(r=Rbearing, h= thickness + 2* tol,$fn=36);
			for (i=[-1,1])
					translate([i* (Rbearing + Rbolt + 1),0,0])
						cylinder(r=Rbolt, h= thickness + 2*tol, $fn=18);
				
		}	
	}
	else
	{
		translate([bx,by, bz]) rotate(rot)
		{
			translate([0,0,thickness-tol])
				hull()
				{
					cylinder(r=Rbearing + 1, h= thickness2,$fn=36);
					for (i=[-1,1])
							translate([i* (Rbearing + Rbolt + 1 ),0,0])
								cylinder(r=RboltHead, h= thickness2, $fn=36);
				}
			translate([0,0,-thickness+tol])
				difference()
				{
					hull()
					{
						cylinder(r=Rbearing + 1, h= thickness2,$fn=36);
						for (i=[-1,1])
								translate([i* (Rbearing + Rbolt + 1),0,0])
									cylinder(r=RboltHead, h= thickness2, $fn=36);
					}
					cylinder(r=Rx, h=thickness + 2*tol, $fn=36);
				}	
		}
	}

}
module ZAxisCover(bx, by, bz, rot=[0,0,0], holesOnly=0)
{
	ZCoverBoltSpacing=30;
	if (holesOnly == 1)
	{
		translate([bx,by, bz]) rotate(rot)
		{
			cylinder(r=Rz, h= thickness + 2* tol,$fn=36);
			for (i=[-1,1])
					translate([i* ZCoverBoltSpacing/2,0,0])
						cylinder(r=Rbolt, h= thickness + 2*tol, $fn=18);
				
		}	
	}
	else
	{
		translate([bx,by, bz]) rotate(rot)
		{
			translate([0,0,thickness-tol])
				hull()
				{
					cylinder(r=Rz + 1, h= thickness2,$fn=36);
					for (i=[-1,1])
							translate([i* ZCoverBoltSpacing/2,0,0])
								cylinder(r=Rz +1, h= thickness2, $fn=36);
				}
			translate([0,0,-thickness+tol])
				difference()
				{
					hull()
					{
						cylinder(r=Rz + 1, h= thickness2,$fn=36);
						for (i=[-1,1])
								translate([i* ZCoverBoltSpacing/2,0,0])
									cylinder(r=Rz + 1, h= thickness2, $fn=36);
					}
					cylinder(r=Rx, h=thickness + 2*tol, $fn=36);
				}	
		}
	}
}	

module Xmot(mountingHoles=false)
{
	translate([AxisOffset + thickness, Y -AxisOffsetBack + AxisOffset + thickness +20 ,AxisOffset])
		rotate([90,0,0])
			{
				if (!mountingHoles)
				{
					nema17(); //note that the motor is positioned around its axis and front face.
					// translate([0,0,17])
						// import("mySpecialSpiderCoupling-Bottom.stl");
				} 
				else 
				{
					nema17MountingHoles(40);
				}	

			}	
}
module Ymot(mountingHoles=false)
{	
	translate([X - AxisOffset, Y -AxisOffsetBack + AxisOffset + thickness + 20 ,AxisOffset + AxisPlaneDistance])
		rotate([0,90,0])
			{
				if (!mountingHoles)
				{
					nema17(); //note that the motor is positioned around its axis and front face.
					translate([0,0,0])
						import("GT2-2mm25t.stl");
				}
				else 
				{
					nema17MountingHoles(40);
				}	
					
			}	
}

module Xaxes(add=true)
{
	if (add==true)
	{
		translate([0,Y-AxisOffsetBack,AxisOffset+AxisPlaneDistance])
			rotate([0, 90, 0])
				cylinder(r=Rx, h=X , $fn=36);
		translate([0,AxisOffset,AxisOffset+AxisPlaneDistance])
			rotate([0, 90, 0])
				cylinder(r=Rx, h=X , $fn=36);		
	}
	else
	{
		translate([-thickness,Y-AxisOffsetBack,AxisOffset+AxisPlaneDistance])
			rotate([0, 90, 0])
				cylinder(r=Rbearing, h=X + 2* thickness, $fn=36);
		translate([-thickness,AxisOffset,AxisOffset+AxisPlaneDistance])
			rotate([0, 90, 0])
				cylinder(r=Rbearing, h=X + 2 * thickness, $fn=36);		
	}
}
module X2axes(add=true)
{
	if(add==true)
	{
		translate([-thickness,Y/2 + X2offset,tableHeight + Ztravel + R2x])
			rotate([0, 90, 0])
				cylinder(r=R2x, h=X + 2* thickness, $fn=36);
		translate([-thickness,Y/2 + X2offset,Z -Ztravel - R2x])
			rotate([0, 90, 0])
				cylinder(r=R2x, h=X + 2* thickness, $fn=36);
	}
	else
	{
		translate([-thickness -tol,Y/2 + X2offset,tableHeight + Ztravel + R2x])
			rotate([0, 90, 0])
				cylinder(r=R2x, h=X + 2* thickness + 2*tol, $fn=36);
		translate([-thickness -tol ,Y/2 + X2offset,Z -Ztravel - R2x])
			rotate([0, 90, 0])
				cylinder(r=R2x, h=X + 2* thickness + 2*tol, $fn=36);
	}		
}
module Yaxes(add=true)
{
	if(add==true)
	{
		translate([X-AxisOffset,0,AxisOffset])
			rotate([-90, 0, 0])
				cylinder(r=Ry, h=Y - AxisOffsetBack + AxisOffset, $fn=36);
		translate([AxisOffset + thickness,0,AxisOffset])
			rotate([-90, 0, 0])
				cylinder(r=Ry, h=Y - AxisOffsetBack + AxisOffset, $fn=36);		
	}
	else
	{
		translate([X-AxisOffset,-2*thickness,AxisOffset])
			rotate([-90, 0, 0])
				cylinder(r=Rbearing, h=Y - AxisOffsetBack + AxisOffset + 4* thickness, $fn=36);
		translate([AxisOffset + thickness,-2*thickness, AxisOffset])
			rotate([-90, 0, 0])
				cylinder(r=Rbearing, h=Y - AxisOffsetBack + AxisOffset + 4* thickness, $fn=36);
	}
}
module Zaxes()
{
	translate([X/2 - ZaxisSpread/2 ,Y - ZaxisOffset ,0])
		rotate([0, 0, 0])
			cylinder(r=Rz, h=Z, $fn=36);
	translate([X/2 + ZaxisSpread/2 ,Y - ZaxisOffset, 0])
		rotate([0, 0, 0])
			cylinder(r=Rz, h=Z, $fn=36);	
}

module axes()
{
	Xaxes();
	Yaxes();
	// Zaxes();
	X2axes(add=true);
}

module rimPanel(add=true)
{
	render()
	{
		difference()
		{
			translate([0,-thickness,0]) union()
			{
				echo("add" , add);
				if (add==true)
					cube([X , thickness, rimBottom]);
				else
					translate([-2*tol, -tol, -tol]) cube([X + 4*tol, thickness + 2* tol, rimBottom + 2*tol]);
				// bearingAssembly(AxisOffset, thickness + tol, Z-AxisOffset, [90,45,0], 0);
				// bearingAssembly(X-AxisOffset, thickness + tol , Z-AxisOffset , [90,-45,0], 0);
				tSlotsAndTabs([0,thickness,0], X , [90,0,0], 2, true, !add, add);
				tSlotsAndTabs([0,0,rimBottom], X, [-90,0,0], 2, true, !add, add);
				// fancyFeet([0,0,tol], X , [0,0,0], true);
			}	
			//bearing holes
			// bearingAssembly(AxisOffset + thickness, tol, AxisOffset, [90,45,0], 1);
			// bearingAssembly(X-AxisOffset, tol, AxisOffset , [90,45,0], 1);
			Yaxes(false); //will cut out the bearing holes, not screw holes for covers.
			
			//the cut-out portion of the tSlots
			tSlotsAndTabs([0,0,0], X , [90,0,0], 2, false,add, add);
			tSlotsAndTabs([0,0-thickness,rimBottom], X, [-90,0,0], 2, false, add, add);
			
			//single tSlot in the side
			translate([thickness,0,thickness + rimBottom/1.5]) rotate([90,90,0]) tSlot(add);
			translate([X-thickness,0,thickness + rimBottom/1.5]) rotate([90,90,180]) tSlot(add);
			//cutout in the sides so two prongs remain.
			translate([0,-thickness -2* tol,thickness])
			{	
				cube([thickness + 2*tol, thickness + 4* tol, rimBottom - 2* thickness]);
			}
			
			translate([X-thickness,-thickness -2*tol,thickness])
			{	
				cube([thickness + 2* tol, thickness + 4* tol, rimBottom - 2* thickness]);
			}
			
		}	
	}	
}
module frontPanel(add=true)
{
	translate([0,thickness,0])
		rimPanel(add);
}
module midPanel(add=true)
{
	translate([0, Y - AxisOffsetBack + AxisOffset,0])
		difference()
		{
			rimPanel(add);
			translate([X -thickness -7 ,-thickness -tol,AxisOffset+AxisPlaneDistance - pulleyWidth/2]) cube([7 + tol, thickness + 2*tol, pulleyWidth]);
		}	
}

module backPanel(add=true)
{
	{
		render() difference()
		{
				translate([X,Y,0])
					rotate([0,0,180]) 
						union()
							{
								cube([X, thickness, Z]);
								//%bearingAssembly(AxisOffset, thickness + tol, Z-AxisOffset, [90,45,0], 0);
								//%bearingAssembly(X-AxisOffset, thickness + tol, Z-AxisOffset , [90,-45,0], 0);
								// tabs([0,thickness ,0], Z , [0,-90,90], 3); //left
								// tabs([X,0,0], Z, [-90,-90,0], 3); //right
								// tSlotsAndTabs([0,0,0], Z , [0,-90,-90], 3, true, !add, add);
								// tSlotsAndTabs([X,thickness,0], Z, [-90,-90,180], 3, true, !add, add);
								// fancyFeet([0,0,tol], X , [0,0,0], add=true);
							}	
			
			leftPanel(add=false);
			rightPanel(add=false);
			//bearing holes
			// bearingAssembly(AxisOffset, Y+thickness + tol, AxisOffset, [90,45,0], 1);
			// bearingAssembly(X-AxisOffset, Y+thickness + tol, AxisOffset , [90,-45,0], 1);
			// topPanel(false);
			// bottomPanel(false);
			// tSlotsAndTabs([0,0,0], Z , [0,-90,-90], 3, false, add, add);
			// tSlotsAndTabs([X,thickness,0], Z, [-90,-90,180], 3, false, add, add);
			// Xmot(mountingHoles=true);
			// fancyFeet([0,Y,Z], X , [0,0,0], add=false);
		}	
	}	
}

module sidePanel(add=true)
{
	render()
	rotate([0,0,0 ])
	{
		difference()
		{
			translate([-tol,0,tol]) union()
			{
				difference()
				{
					cube([thickness-2* tol,Y,Z]);
					//cut out window
					//translate([rimBack+bevel,rimBottom+bevel, -tol])
					translate([-0.5*thickness, -Y/2 + X2offset - 2* R2x,rimBottom+bevel])
					{	
						minkowski()
						{					
							rotate([0,90,0]) cylinder(r=bevel, h= thickness, $fn=36);
							cube([2* thickness, Y-2*bevel, Z ], center=false);
						}
					}
				}	
				
				//slanted frontside.				
				translate([0,-thickness,0]) 
					cube([thickness, thickness, rimBottom]);
				translate([0,-thickness,0]) 			
					intersection()
					{
						translate([0,0,rimBottom])
							rotate([45 +180,0,0]) 
								cube([thickness,1.5*rimBottom,rimBottom]);
								
								
						translate([0,-2*rimBottom,0]) 
							cube([thickness,2*rimBottom,rimBottom]);
					}
				//tabs and tSlots at the bottomPanel
				tSlotsAndTabs([0,-rimBottom -4 * thickness,tol], Y + rimBottom + 8 * thickness, [90,0,90], 3, true, !add, add);
				//tabs and tSlots at the backPanel
				tSlotsAndTabs([0,Y,0], Z, [0,-90,180], 3, true, !add, add);
				//tabs and tSlots at the rimtop
				#tSlotsAndTabs([thickness,0,rimBottom -tol], Y - ZaxisOffset , [-90,0,90], 1, true, !add, add);	
			}	

			//bearing holes
			// bearingAssembly(-tol, Y-AxisOffsetBack, AxisOffset+AxisPlaneDistance,[90,45,90], 1);
			// bearingAssembly(-tol, AxisOffset, AxisOffset+AxisPlaneDistance,[90,-45,90] , 1);
			Xaxes(false);
			X2axes(false);
			
			tSlotsAndTabs([0,-rimBottom -4*thickness,0], Y + rimBottom + 8* thickness, [90,0,90], 3, false, add, add);
			tSlotsAndTabs([0,Y,0], Z, [0,-90,180], 3, false, add, add);
			Ymot(true);
		}	
	}	
}

module leftPanel(add=true)
{
	difference()
	{
		sidePanel(add);
		frontPanel(false);
		// midPanel(false);
	}	
}
module rightPanel(add=true)
{
	difference()
	{
		rotate([0,0,0 ])
		{
			difference()
			{
				translate([X,0,0]) 
					mirror([1,0,0]) 
						sidePanel(add);
			}	
		}	
		// frontPanel(false);
		// midPanel(false);
		Ymot(true);
	}	
}
module topPanel(add=true)
{
	render() 
		translate([0,0,Z])
			rotate([0,0,0])
	{
		difference()
		{
			union()
			{
				translate([tol,tol,0]) cube([X-2*tol,Y-2*tol, thickness]);
				// ZAxisCover(X/2 - ZaxisSpread/2,Y - ZaxisOffset , -tol, [0,0,0], 0);
				// ZAxisCover(X/2 + ZaxisSpread/2,Y - ZaxisOffset, -tol,[0,0,0], 0);
				// tabs([X,tol,0], X, [0,0,180], 3);
				// tabs([tol,0,0], Y,[0,0,90], 3);
				// tabs([0,Y-tol,0], X, [0,0,0], 3);
				// tabs([X-tol,Y-tol,0], Y, [0,0,-90], 3);
				// tabsTopPanel(add);
				// tSlotsnTabs(true, !add, add);
			}	
			//cut out window
			translate([AxisOffset+Rx+bevel,AxisOffset+Ry+bevel, -thickness/2])
			{	
				minkowski()
				{
					
					cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowTopX, windowTopY, thickness + 2* tol], center=false);
				}
			}
			//Z-axis holes
			ZAxisCover(X/2 - ZaxisSpread/2,Y - ZaxisOffset , -tol, [0,0,0], 1);
			ZAxisCover(X/2 + ZaxisSpread/2,Y - ZaxisOffset, -tol,[0,0,0], 1);
			// #tSlotsAndTabs([0,0,0], X, [0,0,0], 3, add);
			// #tSlotsAndTabs([X,0,0], Y,[0,0,90], 3, add);
			// #tSlotsAndTabs([X,Y,0], X, [0,0,180], 3, add);
			// #tSlotsAndTabs([0,Y,0], Y, [0,0,-90], 3, add);
			tSlotsnTabs(false, add, add);
			
		}	
	}	
}
module bottomPanel(add=true)
{
	// render() 
	color("silver") translate([0,0,0]) 
	{
		difference()
		{
			union()
			{
				translate([tol,-rimBottom +tol,-thickness2])
					cube([X -2*tol,Y + rimBottom -2*tol, thickness2]);
				// tSlotsnTabs(true, !add, add);

			}
			//Z-axis holes
			// ZAxisCover(X/2 - ZaxisSpread/2,Y - ZaxisOffset , -tol, [0,0,0], 1);
			// ZAxisCover(X/2 + ZaxisSpread/2,Y - ZaxisOffset, -tol,[0,0,0], 1);
			// tSlotsnTabs(false, add, add);
			leftPanel(false);
			rightPanel(false);
		}	
	}	
}



//projections
module proj()
{
	// projection(cut=true) 
	{
		translate([0,0,-2])
		{
			translate([0,0,thickness -tol]) rotate([-90,0,0]) frontPanel(true); 
			translate([0, 2* rimBottom + 2* thickness, -Y + AxisOffsetBack - AxisOffset + thickness])  rotate([90, 0,0]) midPanel(true);
			// translate([0,Z + 2* thickness,-tol])  rotate([90, 0,-180]) translate([-X, -Y,0]) backPanel(true);
			// translate([Y + X + 4* thickness,0,thickness -tol]) rotate([-90,0,0]) rotate([0,0,90]) leftPanel(true);
			// translate([X + 4* thickness, Z + 2* thickness, thickness -tol]) rotate([-90,0,0]) rotate([0,0,-90]) translate([-X,0,0]) rightPanel(true);
			// translate([X + Y + 4* thickness + 4* thickness, 1.5* thickness, -tol -Z]) rotate([0,0,0]) topPanel(add=true);
			// translate([X + Y + 4* thickness + 4* thickness, Y + 6* thickness ,-tol - rimBottom + thickness]) rotate([0,0,0]) bottomPanel(add=true);
		}	
	}
}

// frontPanel(true);
// midPanel(true);
// backPanel();
// leftPanel(true);
// rightPanel();
// topPanel(true);
// bottomPanel(true);
// axes();
// Xaxes();
// Yaxes();
// Zaxes();
proj();
// Xmot();
// Ymot();
// fancyFeet(add=false);