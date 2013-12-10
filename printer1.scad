//printer1.scad 3D printer with parallel X and Y axes. The Built platform is cantilevered and moved along the Z-axis in the back.
/* copyright 2013 Jelle Boomstra, jelle@protospace.nl*/
/* All the creative works in this distribution are licensed to you under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE. */
/* Details can be found in the file 'LICENSE'.*/

use <nema17.scad> ;
use <tSlotsAndTabs.scad>;

/* 
dimensions of LMK type linear bearings, from: 
http://www.cyrus-linear.com/product-detail.php?id=18&lang=en

PCD is the dimension we need in this case.

model No.	main size	main dimensios	
			dr	D	L	Df	K	t	P.C.D	d1	d2	h	

LMK-06-LUU 	6 	12 	35 	28 	22 	5 	20 	3.5	6 	3.1 	
LMK-08-LUU 	8 	15 	45 	32 	25 	5 	24 	3.5	6 	3.1 	
LMK-10-LUU 	10 	19 	55 	40 	30 	6 	29 	4.5	7.5	4.1 	
LMK-12-LUU 	12 	21 	57 	42 	32 	6 	32 	4.5	7.5	4.1 	
LMK-13-LUU 	13 	23 	61 	43 	34 	6 	33 	4.5	7.5	4.1 	
LMK-16-LUU 	16 	28 	70 	48 	37 	6 	38 	4.5	7.5	4.1 	
LMK-20-LUU 	20 	32 	80 	54 	42 	8 	43 	5.5	9	5.1 	
	
 */
 /*the dimensions of the sintered bronze bushing used on UM are ID 8mm, OD 11mm and lenght 30mm */
 

X=600;
Y=600;
Z=950;
Rx=6;
Ry=6;
Rz=8;
tol=0.150;
thickness=6;
thickness2=4;
bevel=10;
rimFront=X/8;
rimBack=max(X/6, 42);
//rimTop=Y/8;
rimTop=rimFront;
rimBottom=max(Y/6,39 + 2*thickness); 
Rbearing=14;
RboltHead=3;
Rbolt=1.5;
nutWidth=5.5; //-tol? Width of M3 nut between flats
nutThickness=2.4; //-tol?
tSlotWidth=3;
tSlotLength=10;

//AxisOffset=Rbearing + RboltHead + 2;
AxisOffset= max ((11/2 + 1 + 2), Rbearing + 2); //bushing outer diameter + wall thickness of its holder + margin
ZaxisOffset=32/2 + 1; //how far should the Z-axis be from the side. Also used to calculate clearance for the back X axis.
ZaxisSpread=150; //how far apart are the two Z-axis rails?
AxisOffsetBack=AxisOffset + Rz + ZaxisOffset + 1;
AxisPlaneDistance=18;

shortBelt=80;

//fancy UM-like feet
footHeight=10;
footWidth=48;
footRadius=5;


//derived from above:
windowFrontX = X - rimFront -rimFront - bevel- bevel;
windowFrontY = Z - rimTop -rimBottom - bevel - bevel;
windowSideX = Y - rimBack - rimFront - bevel -bevel;
windowSideY = Z - rimTop -rimBottom - bevel - bevel;
windowTopX = X - 2* AxisOffset - 2*Rx - 2*bevel ;
windowTopY = Y - AxisOffset -AxisOffsetBack - 2*Ry - 2*bevel;

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

module tSlotsnTabs(tab, tslot, add=true)
{
	echo ("tab , tSlot:" , tab, tslot);
	tSlotsAndTabs([0,0,0], X, [0,0,0], 3, tab, tslot, add);
	tSlotsAndTabs([X,0,0], Y,[0,0,90], 3, tab, tslot, add);
	tSlotsAndTabs([X,Y,0], X, [0,0,180], 3, tab, tslot, add);
	tSlotsAndTabs([0,Y,0], Y, [0,0,-90], 3, tab, tslot, add);
}
module fancyFeet(startC=[0,0,0], length=X, rotation=[0,0,0], add=true)
{
	/// startC: top-left-front corner of feet. The cutout (add==false) wil go footHeight higher.
	translate(startC)
		rotate(rotation)
			{
				if (add==true) 
					oneFoot();	
				else 
					negativeFoot();
				translate([length, thickness,0])
					rotate([0,0,180])
						if (add == true) 
							oneFoot();
						else
							negativeFoot();
			}
		
}
module oneFoot()
{
	render() union()
	{
		hull()
		{
			translate([0,0,-tol]) cube([footWidth -footRadius,thickness,tol]);
			translate([footRadius,0,-footRadius]) rotate([-90,0,0])
				cylinder(r=footRadius, h=thickness, $fn=36);
			translate([footWidth-3*footRadius,0,-footRadius]) rotate([-90,0,0])
				cylinder(r=footRadius, h=thickness, $fn=36);	
		}
		difference()
		{
			translate([0,0,-footRadius/1.5]) cube([footWidth,thickness,footRadius/1.5]);
			translate([footWidth,-tol,-footRadius*2]) rotate([-90,0,0])
				cylinder(r=footRadius*2, h=thickness + 2*tol, $fn=72);

		}
	}
}
module negativeFoot()
{
	render() translate([0,0,footHeight]) union()
	{
		translate([-tol,-tol,0]) oneFoot();
		translate([-tol,tol,0]) oneFoot();
		
		difference()
		{
			translate([-tol,-tol,-1.5*footHeight]) cube([footRadius,thickness + 2*tol ,1.5*footHeight]);
			translate([footRadius,-1.5*tol,-1.5*footHeight]) rotate([-90,0,0])
				cylinder(r=footRadius, h=thickness + 3*tol, $fn=72);

		}
	}
}
module Xmot(mountingHoles=false)
{
	translate([X-21, Y -17  ,Z-AxisOffset-shortBelt])
		rotate([-90,0,0])
			{
				if (!mountingHoles)
				{
					nema17(); //note that the motor is positioned around its axis and front face.
					// translate([0,0,17])
						// import("mySpecialSpiderCoupling-Bottom.stl");
				} 
				else 
				{
					nema17MountingSlots(40);
				}	

			}	
}
module Ymot(mountingHoles=false)
{
	translate([17, Y -21  ,Z-AxisOffset-shortBelt-AxisPlaneDistance])
		rotate([-90,0,90])
			{
				if (!mountingHoles)
				{
					nema17(); //note that the motor is positioned around its axis and front face.
					// translate([0,0,17])
						// import("mySpecialSpiderCoupling-Bottom.stl");
				} 
				else 
				{
					nema17MountingSlots(40);
				}	

			}	
}

module Xaxes()
{
	translate([0,Y-AxisOffsetBack,Z-(AxisOffset+AxisPlaneDistance)])
		rotate([0, 90, 0])
			cylinder(r=Rx, h=X, $fn=36);
	translate([0,AxisOffset,Z-(AxisOffset+AxisPlaneDistance)])
		rotate([0, 90, 0])
			cylinder(r=Rx, h=X, $fn=36);		
}
module Yaxes()
{
	translate([X-AxisOffset,0,Z-AxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Ry, h=Y, $fn=36);
	translate([AxisOffset,0,Z-AxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Ry, h=Y, $fn=36);		
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

module frontPanel(add=true)
{
	render()
	{
		difference()
		{
			translate([0,-thickness,0]) union()
			{
				cube([X, thickness, Z + thickness *1.5]);
				// bearingAssembly(AxisOffset, thickness + tol, Z-AxisOffset, [90,45,0], 0);
				// bearingAssembly(X-AxisOffset, thickness + tol , Z-AxisOffset , [90,-45,0], 0);
				tSlotsAndTabs([0,0,0], Z , [0,-90,-90], 3, true, !add, add);
				tSlotsAndTabs([X,thickness,0], Z, [-90,-90,180], 3, true, !add, add);
				fancyFeet([0,0,tol], X , [0,0,0], true);
			}	
			//cut out window
			translate([rimFront+bevel, -thickness/2,rimBottom+bevel])
			{	
				minkowski()
				{
					
					rotate([90,0,0]) cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowFrontX, 2* thickness, windowFrontY], center=false);
				}
			}
			//bearing holes
			bearingAssembly(AxisOffset, tol, Z-AxisOffset, [90,45,0], 1);
			bearingAssembly(X-AxisOffset, tol, Z-AxisOffset , [90,-45,0], 1);
			
			tSlotsAndTabs([0,-thickness,0], Z , [0,-90,-90], 3, false,add, add);
			tSlotsAndTabs([X+tol,0,0], Z, [-90,-90,180], 3, false, add, add);
			topPanel(false);
			bottomPanel(false);
			//translate([0,0,Z]) tabsTopPanel();
			fancyFeet([0,-thickness,Z], X , [0,0,0], false);
			
		}	
	}	
}
module backPanel(add=true)
{
	{
		render() difference()
		{
				translate([X,Y + thickness,0])
					rotate([0,0,180]) 
						union()
							{
								cube([X, thickness, Z + thickness *1.5]);
								//%bearingAssembly(AxisOffset, thickness + tol, Z-AxisOffset, [90,45,0], 0);
								//%bearingAssembly(X-AxisOffset, thickness + tol, Z-AxisOffset , [90,-45,0], 0);
								// tabs([0,thickness ,0], Z , [0,-90,90], 3); //left
								// tabs([X,0,0], Z, [-90,-90,0], 3); //right
								tSlotsAndTabs([0,0,0], Z , [0,-90,-90], 3, true, !add, add);
								tSlotsAndTabs([X,thickness,0], Z, [-90,-90,180], 3, true, !add, add);
								fancyFeet([0,0,tol], X , [0,0,0], add=true);
							}	
			
			//bearing holes
			bearingAssembly(AxisOffset, Y+thickness + tol, Z-AxisOffset, [90,45,0], 1);
			bearingAssembly(X-AxisOffset, Y+thickness + tol, Z-AxisOffset , [90,-45,0], 1);
			topPanel(false);
			bottomPanel(false);
			tSlotsAndTabs([0,0,0], Z , [0,-90,-90], 3, false, add, add);
			tSlotsAndTabs([X,thickness,0], Z, [-90,-90,180], 3, false, add, add);
			Xmot(mountingHoles=true);
			fancyFeet([0,Y,Z], X , [0,0,0], add=false);
		}	
	}	
}

module leftPanel()
{
	render()
	rotate([0,0,0 ])
	{
		difference()
		{
			translate([-thickness,0,0]) union()
			{
				translate([0,-1.5*thickness,0])cube([thickness,Y + 3* thickness,Z + 1.5*thickness]);
				// %bearingAssembly(-tol, Y-AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance),[90,45,90], 0);
				// %bearingAssembly(-tol, AxisOffset, Z-(AxisOffset+AxisPlaneDistance),[90,-45,90] , 0);
				fancyFeet([thickness,-1.5*thickness,tol], Y+3*thickness, [0,0,90], add=true);
			}	
			//cut out window
			//translate([rimBack+bevel,rimBottom+bevel, -tol])
			translate([-1.5*thickness,rimFront + bevel ,rimBottom+bevel])
			{	
				minkowski()
				{
					
					rotate([0,90,0]) cylinder(r=bevel, h= thickness, $fn=36);
					cube([2* thickness, windowSideX, windowFrontY, ], center=false);
				}
			}
			//bearing holes
			bearingAssembly(-thickness-tol, Y-AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance),[90,45,90], 1);
			bearingAssembly(-thickness-tol, AxisOffset, Z-(AxisOffset+AxisPlaneDistance),[90,-45,90] , 1);
			topPanel(false);
			bottomPanel(false);
			frontPanel(false);
			backPanel(false);
			Ymot(mountingHoles=true);
			fancyFeet([0,-1.5*thickness,Z], Y+3*thickness, [0,0,90], add=false);
			
		}	
	}	
}
module rightPanel()
{
	// translate([X,0,0])
	// rotate([0,0,0])
	render()
	{
		difference()
		{
			translate([X,0,0]) union()
			{
				translate([0,-1.5 * thickness,0]) cube([thickness,Y + 3* thickness,Z + 1.5*thickness]);
				// bearingAssembly(-tol, AxisOffset, Z-(AxisOffset+AxisPlaneDistance) ,[90,-45,90] , 0);
				// bearingAssembly(-tol, Y-AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance), [90,45,90], 0);
				fancyFeet([thickness,-1.5*thickness,tol], Y+3*thickness, [0,0,90], add=true);
			}	
			//cut out window
			translate([X-0.5*thickness , rimFront+bevel,rimBottom+bevel ])
			{	
				minkowski()
				{
					
					rotate([0,90,0]) cylinder(r=bevel, h= thickness, $fn=36);
					cube([2* thickness, windowSideX, windowFrontY], center=false);
				}
			}
			//bearing holes
			bearingAssembly(X-tol, AxisOffset, Z-(AxisOffset+AxisPlaneDistance) ,[90,-45,90] , 1);
			bearingAssembly(X-tol, Y-AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance), [90,45,90], 1);
			topPanel(false);
			bottomPanel(false);
			frontPanel(false);
			backPanel(false);
			fancyFeet([X + thickness,-1.5*thickness,Z], Y+3*thickness, [0,0,90], add=false);
			
		}	
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
				tSlotsnTabs(true, !add, add);
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
	render() translate([0,0,rimBottom- thickness]) 
	{
		difference()
		{
			union()
			{
				cube([X,Y, thickness]);
				// ZAxisCover(X/2 - ZaxisSpread/2,Y - ZaxisOffset , -tol, [0,0,0], 0);
				// ZAxisCover(X/2 + ZaxisSpread/2,Y - ZaxisOffset, -tol,[0,0,0], 0);
				// tabs([X,tol,0], X, [0,0,180], 3);
				// tabs([tol,0,0], Y,[0,0,90], 4);
				// tabs([0,Y-tol,0], X, [0,0,0], 4);
				// tabs([X-tol,Y-tol,0], Y, [0,0,-90], 4);				
				tSlotsnTabs(true, !add, add);

			}
			//Z-axis holes
			ZAxisCover(X/2 - ZaxisSpread/2,Y - ZaxisOffset , -tol, [0,0,0], 1);
			ZAxisCover(X/2 + ZaxisSpread/2,Y - ZaxisOffset, -tol,[0,0,0], 1);
			tSlotsnTabs(false, add, add);
			// tSlotsAndTabs([0,0,0], X, [0,0,0], 3, add);
			// tSlotsAndTabs([X,0,0], Y,[0,0,90], 4, add);
			// tSlotsAndTabs([X,Y,0], X, [0,0,180], 4, add);
			// tSlotsAndTabs([0,Y,0], Y, [0,0,-90], 4, add);
			
		}	
	}	
}

module axes()
{
	Xaxes();
	Yaxes();
	Zaxes();
}

//projections
module proj()
{
	// projection(cut=true) 
	{
		translate([0,0,-2])
		{
			translate([0,0,-tol]) rotate([-90,0,0]) frontPanel(); 
			// translate([0,Z + 2* thickness,-tol])  rotate([90, 0,-180]) translate([-X, -Y,0]) backPanel();
			// translate([Y + X + 4* thickness,0,-tol]) rotate([-90,0,0]) rotate([0,0,90]) leftPanel(0);
			// translate([X + 4* thickness, Z + 2* thickness]) rotate([-90,0,0]) rotate([0,0,-90]) translate([-X,0,0]) rightPanel(0);
			// translate([X + Y + 4* thickness + 4* thickness, 1.5* thickness, -tol -Z]) rotate([0,0,0]) topPanel(add=true);
			translate([X + Y + 4* thickness + 4* thickness, Y + 6* thickness ,-tol - rimBottom + thickness]) rotate([0,0,0]) bottomPanel(add=true);
		}	
	}
}

frontPanel(true);
// backPanel();
// leftPanel();
// rightPanel();
// topPanel(true);
// bottomPanel(true);
// axes();
// Xaxes();
// Yaxes();
// Zaxes();
// proj();
// Xmot();
// Ymot();
// fancyFeet(add=false);