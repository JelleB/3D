//Printer2.scad parametric 3D printer, XY gantry mounted on Z axis
use <nema17.scad> ;
use <tSlotsAndTabs.scad>;

X=350; 	//outer dimension in X Y and Z
Y=350; 
Z=300;
//XY_plane_offset=30; 
Rx=4;	//Diameter of the axes
Ry=4;
Rz=4;
Rworm=0;
WormPitchDist=Rz + 11.4;
tol=0.05;
innerMargin = 1;
thickness=6;
thickness2=4;
bevel=5;
rimFront=X/8;
rimBack=max(X/6, 42);
rimTop=Y/8;
rimBottom=max(Y/6,39 + 2*thickness); 
Rbearing=9.5;	//size of the bearings for X and Y
RboltHead=3;	//size of a M3 bolt head (approximate)
Rbolt=1.5;		//nominal size of M3 thread
//AxisOffset=Rbearing + RboltHead + 2; 
AxisOffset=Rbearing+1; 
YAxisOffset=max(AxisOffset + 2*RboltHead, 10);
ZaxisOffset=55 + thickness ; //needs to fit electronics and motors
AxisOffsetBack=AxisOffset + ZaxisOffset;
AxisPlaneDistance=18; //distance between the two parallel planes of the X and Y axis


tSlotWidth=3;	//width of the t-slot. probably should be the nominal width of your bolts, but it could be a little less to allow for alaser kerf width.
tSlotLength=6; //length/depth of the t-slot. It should fit the intended bolt (bolt < thickness + tSlotLength).
nutWidth=5.5; 	//-tol? Width of M3 nut between flats
nutThickness=2.4; //-tol?




//derived from above:
i=thickness + thickness2 + innerMargin;
Xi = X - 2*i; 
Yi = Y - 2*i;
Zi = max((AxisPlaneDistance + 2* YAxisOffset + Rworm + 2), 20);

windowFrontX = X - rimFront -rimFront - bevel- bevel;
windowFrontY = Z - rimTop -rimBottom - bevel - bevel;
windowSideX = Y - rimBack - rimFront - bevel -bevel;
windowSideY = Z - rimTop -rimBottom - bevel - bevel;
windowTopX = X - rimFront -rimFront - bevel -bevel;
windowTopY = Y - rimFront -rimBack - bevel - bevel;

XAxisLength=Xi + 2*thickness -2;
YAxisLength=Yi -2 -AxisOffsetBack +AxisOffset + 2* thickness;
ZaxisLenght=Yi+ 2* thickness + 2*thickness2; //note: these hold the Z-pinion gears

//tell it like it is...
echo("X,Y,Z: " , X , Y , Z);
echo("inners: Xi,Yi,Zi: " ,Xi,Yi,Zi);
echo("AxisOffset: ", AxisOffset);
echo("Y-axisOffset:" , YAxisOffset);
echo("AxisPlaneDistance:",AxisPlaneDistance);
echo("Axis Length X,Y,Z:" ,XAxisLength, YAxisLength , ZaxisLenght);
echo("tSlotLength:" , tSlotLength);


module bearingAssembly(bx, by, bz, holesOnly=0)
{
	if (holesOnly == 1)
	{
		translate([bx,by, bz])
		{
			cylinder(r=Rbearing, h= thickness + 2* tol,$fn=36);
			for (i=[-1,1])
				translate([0,i* (Rbearing + RboltHead),0])
					cylinder(r=Rbolt, h= thickness + 2*tol, $fn=18);
				
		}	
	}
	else
	{
		translate([bx,by, bz])
		{
			translate([0,0,thickness-tol])
				hull()
				{
					cylinder(r=Rbearing + 1, h= thickness2,$fn=36);
					for (i=[-1,1])
						translate([0,i* (Rbearing + RboltHead),0])
							cylinder(r=RboltHead, h= thickness2, $fn=36);
				}
			translate([0,0,-thickness+tol])
				difference()
				{
					hull()
					{
						cylinder(r=Rbearing + 1, h= thickness2,$fn=36);
						for (i=[-1,1])
							translate([0, i* (Rbearing + RboltHead),0])
								cylinder(r=RboltHead, h= thickness2, $fn=36);
					}
					cylinder(r=Rx, h=thickness + 2*tol, $fn=36);
				}	
		}
	}
}	
// module tabs(startC, length, rotation, number)
// {
	// translate(startC)
		// rotate([0,0,rotation])
			// for (n=[1:number])
			// {
				// translate([n*length/number - length/(2*number) -1.5*thickness,0,-tol])
					// cube([3*thickness, thickness + tol, thickness + 2*tol]);
					cube([2, 1, 1]);
			// }	
// }

module tSlotsnTabs(tab, tslot, add=true)
{
	echo ("tab , tSlot:" , tab, tslot);
	#tSlotsAndTabs([tol,tol,0], Xi - 2* tol, [0,0,0], 3, tab, tslot, add);
	tSlotsAndTabs([Xi+tol,tol,0], Yi - 2* tol,[0,0,90], 3, tab, tslot, add);
	tSlotsAndTabs([Xi+tol,Yi+tol,0], Xi- 2* tol, [0,0,180], 3, tab, tslot, add);
	tSlotsAndTabs([tol,Yi+tol,0], Yi - 2* tol, [0,0,-90], 3, tab, tslot, add);
}

module Xaxes()
{
	translate([i +1 , Y-AxisOffsetBack -i,Z-(YAxisOffset+AxisPlaneDistance)])
		rotate([0, 90, 0])
			cylinder(r=Rx, h=Xi, $fn=36);
	translate([i +1 -thickness, AxisOffset +i,Z-(YAxisOffset+AxisPlaneDistance)])
		rotate([0, 90, 0])
			cylinder(r=Rx, h=Xi, $fn=36);		
}
module Yaxes()
{
	translate([X-AxisOffset -i,i+1 -thickness,Z-YAxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Ry, h=YAxisLength, $fn=36);
	translate([AxisOffset+ i,i+1 -thickness,Z-YAxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Ry, h=YAxisLength, $fn=36);		
}
module Zaxes() //axles that have a pinion gear at each end to mesh with the rack of the outer casing
{
	translate([X-AxisOffset -i,1,Z-AxisPlaneDistance - 2* YAxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Rz, h=ZaxisLenght, $fn=36);
	translate([AxisOffset+ i,1,Z-AxisPlaneDistance - 2* YAxisOffset])
		rotate([-90, 0, 0])
			cylinder(r=Rz, h=ZaxisLenght, $fn=36);		
}

module outerFrontPanel(mounted= 1)
{
	translate([0,0,0])
	rotate([90* mounted,0,0])
	{
		difference()
		{
			union()
			{
				cube([X,Z, thickness]);
				//bearingAssembly(AxisOffset, Z-AxisOffset, -tol, 0);
				//bearingAssembly(X-AxisOffset, Z-AxisOffset, -tol, 0);
			}	
			//cut out window
			translate([rimFront+bevel,rimBottom+bevel, -tol])
			{	
				minkowski()
				{
					
					cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowFrontX, windowFrontY, 2* thickness], center=false);
				}
			}
			// bearing holes
			// bearingAssembly(AxisOffset +i, Z-AxisOffset, -tol, 1);
			// bearingAssembly(X-AxisOffset -i, Z-AxisOffset, -tol, 1);
			
		}	
	}	
}
module outerBackPanel(mounted= 1)
{
	translate([X,Y,0])
	rotate([90* mounted,0,180])
	{
		difference()
		{
			union()
			{
				cube([X,Z, thickness]);
				//bearingAssembly(AxisOffset, Z-AxisOffset, -tol, 0);
				//bearingAssembly(X-AxisOffset, Z-AxisOffset, -tol, 0);
			}	
			
			//bearing holes
			// bearingAssembly(AxisOffset +i, Z-AxisOffset, -tol, 1);
			// bearingAssembly(X-AxisOffset -i, Z-AxisOffset, -tol, 1);
			
		}	
	}	
}
module outerLeftPanel(mounted=0)
{
	translate([0,Y,0])
	rotate([90* mounted,0,-90 * mounted])
	{
		difference()
		{
			union()
			{
				cube([Y,Z, thickness]);
				//bearingAssembly(AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance) , -tol, 0);
				//bearingAssembly(Y-AxisOffset, Z-(AxisOffset+AxisPlaneDistance), -tol, 0);
			}	
			//cut out window
			translate([rimBack+bevel,rimBottom+bevel, -tol])
			{	
				minkowski()
				{
					
					cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowSideX, windowFrontY, 2* thickness], center=false);
				}
			}
			//bearing holes
			// bearingAssembly(AxisOffsetBack + i, Z-(AxisOffset+AxisPlaneDistance) , -tol, 1);
			// bearingAssembly(Y-AxisOffset -i, Z-(AxisOffset+AxisPlaneDistance), -tol, 1);
			
		}	
	}	
}
module outerRightPanel(mounted=0)
{
	translate([X,0,0])
	rotate([90* mounted,0,90 * mounted])
	{
		difference()
		{
			union()
			{
				cube([Y,Z, thickness]);
				//bearingAssembly(AxisOffset, Z-(AxisOffset+AxisPlaneDistance) , -tol, 0);
				//bearingAssembly(Y-AxisOffsetBack, Z-(AxisOffset+AxisPlaneDistance), -tol, 0);
			}	
			//cut out window
			translate([rimFront+bevel,rimBottom+bevel, -tol])
			{	
				minkowski()
				{
					
					cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowSideX, windowFrontY, 2* thickness], center=false);
				}
			}
			//bearing holes
			// bearingAssembly(AxisOffset +i, Z-(AxisOffset+AxisPlaneDistance) , -tol, 1);
			// bearingAssembly(Y-AxisOffsetBack -i, Z-(AxisOffset+AxisPlaneDistance), -tol, 1);
			
		}	
	}	
}
module outerTopPanel(mounted= 1)
{
	translate([0,0,Z])
	rotate([0,0,0])
	{
		difference()
		{
			union()
			{
				cube([X,Y, thickness]);
				//bearingAssembly(AxisOffset, Z-AxisOffset, -tol, 0);
				//bearingAssembly(X-AxisOffset, Z-AxisOffset, -tol, 0);
				
			}	
			//cut out window
			translate([rimFront+bevel,rimFront+bevel, -tol])
			{	
				minkowski()
				{
					
					cylinder(r=bevel, h= thickness, $fn=36);
					cube([windowTopX, windowTopY, thickness + 2* tol], center=false);
				}
			}
			//Z-axis holes
			// bearingAssembly(X/4 ,Y - ZaxisOffset -1 , -tol, 1);
			// bearingAssembly(3*X/4,Y - ZaxisOffset -1, -tol, 1);
			
		}	
	}	
}
module outerBottomPanel(mounted= 1)
{
	translate([0,0,-thickness])
	rotate([0,0,0])
	{
		difference()
		{
			union()
			{
				cube([X,Y, thickness]);

			}
			//Z-axis holes
			//bearingAssembly(X/4 ,Y - ZaxisOffset -1 , -tol, 1);
			//bearingAssembly(3*X/4,Y - ZaxisOffset -1, -tol, 1);
			
		}	
	}	
}
module innerTopPanel(add=true)
{
	render() difference()
	{
		translate([0,0,Z])
		rotate([0,0,0])
		{
			translate([i + tol,i + tol,0])
			difference()
			{
				union()
				{
					cube([Xi -2* tol,Yi -2* tol, thickness]);
					// tabs([Xi,0,0], Xi, 180, 5);
					// tabs([0, 0,0], Yi,90, 5);
					// tabs([0,Yi,0], Xi, 0, 5);
					// tabs([Xi,Yi,0], Yi, -90, 5);
					// tabs([Xi,0,0], Xi, 180, 5);
					// tabs([0, 0,0], Yi - ZaxisOffset,90, 5);
					// tabs([0,Yi,0], Xi, 0, 5);
					// tabs([Xi,Yi -ZaxisOffset,0], Yi -ZaxisOffset, -90, 5);
					tSlotsnTabs(true, !add, add);
				}	
				//cut out window
				translate([AxisOffset + bevel + Rx, AxisOffset + bevel + Ry, -tol])
				{	
					minkowski()
					{
						
						cylinder(r=bevel, h= thickness, $fn=36);
						cube([(Xi- AxisOffset*2 -bevel*2 -Rx*2), (Yi -AxisOffset -AxisOffsetBack -bevel*2 -Ry*2), thickness + 2* tol], center=false);
					}
				}
				//Z-axis holes
				//bearingAssembly(X/4 ,Y - ZaxisOffset -1 , -tol, 1);
				//bearingAssembly(3*X/4,Y - ZaxisOffset -1, -tol, 1);
				tSlotsnTabs(false, add, add);
				
			}	
		}
	Zmot(mountingHoles=true);
	ZGears(mountingHoles=true);

	}	
}
module innerFrontPanel(add=true)
{
	render()
	difference()
	{
		rotate([90,0,0])
		{
			difference()
			{
				union()
				{
					translate([i,Z-Zi,-i])
					{
						cube([Xi ,Zi, thickness]);
						//rim for slots
						translate([0,-thickness*1.5,0])  
							cube([Xi,thickness*1.5,thickness]);
						translate([0,Zi,0])  
							cube([Xi,thickness*1.5,thickness]);	
						//tabs([0,0,0], Zi , 90, 1); //left
						translate([-thickness,Zi/2,0])
							cube([thickness,Zi/2 + thickness * 1.5 ,thickness ]);
						//tabs([Xi,Zi,0], Zi, -90, 1); //right	
						translate([Xi,Zi/2,0])
							cube([thickness,Zi/2 + thickness*1.5 ,thickness ]);
					}		
					// bearingAssembly(AxisOffset + i, Z-YAxisOffset, -i -tol, 0);
					// bearingAssembly(X-AxisOffset - i, Z-YAxisOffset, -i -tol, 0);
					 
				}	
				//bearing holes
				bearingAssembly(AxisOffset +i, Z-YAxisOffset, -tol -i, 1);
				bearingAssembly(X-AxisOffset -i, Z-YAxisOffset, -tol -i, 1);
				//tabs([Xi + i,Z-Zi,-i], Xi, 180, 5);		
			}	
		}
	innerBottomPanel(add=false);
	innerTopPanel(add=false);
	Zaxes();
	}
}
module innerMidPanel(mounted= 1)
{
	
	difference()
	{
		rotate([90,0,0]) //Y and Z axis are swapped by this rotation
		{
			difference()
			{
				union()
				{
					translate([i,Z-Zi,-Yi -i -thickness + AxisOffsetBack -AxisOffset])
					{
						cube([Xi ,Zi, thickness]);
						// rim for slots
						// translate([0,-thickness,0])  
							// cube([Xi,thickness,thickness]);
						// translate([0,Zi,0])  
							// cube([Xi,thickness,thickness]);	
						// tabs([0,0,0], Zi , 90, 1); //left
						// tabs([Xi,Zi,0], Zi, -90, 1); //right	
						translate([-thickness,Zi/2,0])
							cube([thickness,Zi/2  ,thickness ]);
						//tabs([Xi,Zi,0], Zi, -90, 1); //right	
						translate([Xi,Zi/2,0])
							cube([thickness,Zi/2 ,thickness ]);
					}		
					// bearingAssembly(AxisOffset + i, Z-YAxisOffset, -i -tol, 0);
					// bearingAssembly(X-AxisOffset - i, Z-YAxisOffset, -i -tol, 0);
					
					 
				}	
				//bearing holes
				bearingAssembly(AxisOffset +i, Z-YAxisOffset, -Yi -i -thickness + AxisOffsetBack -AxisOffset, 1);
				bearingAssembly(X-AxisOffset -i, Z-YAxisOffset, -Yi -i -thickness + AxisOffsetBack -AxisOffset, 1);
				
				//mounting holes for Nema 17 motor (around bearing)
				// translate([AxisOffset +i, Z-YAxisOffset, -Yi -i -thickness + AxisOffsetBack -AxisOffset]) 
					// rotate([0,0,0])
						// nema17MountingHoles(100);
					
					

				
			}	
		}
	//inner BottomPanel(1);
	//inner TopPanel(1);
	Xmot(mountingHoles=true);
	// acces hole to let in the timing belt for the motor behind this panel.
	translate([i+Xi-25,i+Yi-AxisOffsetBack + AxisOffset,Z-Zi+YAxisOffset -12.5 ])
		cube([20,thickness + tol,25]);
	Zaxes();	
	}
}
module innerBackPanel(mounted= 1)
{
	render()
	difference()
	{
		translate([X ,Y , 0])
		rotate([90,0,180])
		{
			difference()
			{
				union()
				{
					translate([i,Z-Zi,-i])
					{
						cube([Xi,Zi, thickness]);
						translate([0,Zi,0])
							cube([Xi,thickness*1.5, thickness]);
						translate([0,-thickness*1.5, 0])
							cube([Xi,thickness*1.5, thickness]);	
						tabs([0,0,0], Zi , 90, 1); //left
						tabs([Xi,Zi,0], Zi, -90, 1); //right							
					}	
					//bearingAssembly(AxisOffset +i, Z-YAxisOffset, -tol -i, 0);
					//bearingAssembly(X-AxisOffset -i, Z-YAxisOffset, -tol -i, 0);
				}	
				
				//bearing holes
				//bearingAssembly(AxisOffset + i, Z-YAxisOffset, -tol -i, 1);
				//bearingAssembly(X-AxisOffset -i, Z-YAxisOffset, -tol -i, 1);
				
			}	
		}	
	innerTopPanel(add=false);
	innerBottomPanel(add=false);
	Zaxes();
	}	
}
module innerLeftPanel(mounted=0)
{
	difference()
	{
		translate([0,Y,Z -Zi])
		rotate([90,0,-90])
		{
			difference()
			{
				translate([i,0,-i])
					union()
				{
					cube([Yi,Zi, thickness]);
					translate([0,-thickness*1.5,0])  		//top
						cube([Yi,thickness*1.5,thickness]); 
					translate([0,Zi,0])  					//bottom
						cube([Yi,thickness*1.5,thickness]);	
					translate([-thickness,-1.5*thickness,0])  					//left
						cube([thickness,Zi + 3* thickness,thickness]);
					translate([Yi,-1.5*thickness,0])  					//right
						cube([thickness,Zi + 3* thickness,thickness]);						
					
					//bearingAssembly(AxisOffsetBack, Zi-(YAxisOffset+AxisPlaneDistance) , -tol, 0);
					//bearingAssembly(Yi-AxisOffset, Zi-(YAxisOffset+AxisPlaneDistance),  -tol, 0);
				}	
				//bearing holes
				bearingAssembly(AxisOffsetBack +i, Zi-(YAxisOffset+AxisPlaneDistance) , -i -tol, 1);
				bearingAssembly(Yi-AxisOffset +i, Zi-(YAxisOffset+AxisPlaneDistance), -i -tol, 1);
				
				
			}	
		}
		innerTopPanel(1);
		innerMidPanel(1);
		innerBottomPanel(1);
		innerFrontPanel(1);
		innerBackPanel(1);
		translate([-10,0,0]) 
			Xmot(mountingHoles=false);
	}	
}
module innerRightPanel(add=true)
{
	difference()
	{
		translate([X,0,Z-Zi])
		rotate([90,0,90])
		{
			translate([i,0,-i])
			difference()
			{
				union()
				{
					cube([Yi,Zi, thickness]);
					translate([0,-thickness*1.5,0])  
						cube([Yi,thickness*1.5,thickness]);
					translate([0,Zi,0])  
						cube([Yi,thickness*1.5,thickness]);	
					translate([-thickness,-1.5*thickness,0])  					//left
						cube([thickness,Zi + 3* thickness,thickness]);
					translate([Yi,-1.5*thickness,0])  					//right
						cube([thickness,Zi + 3* thickness,thickness]);	
						
					bearingAssembly(AxisOffset, Zi-(YAxisOffset+AxisPlaneDistance) , -tol, 0);
					bearingAssembly(Yi-AxisOffsetBack, Zi-(YAxisOffset+AxisPlaneDistance), -tol, 0);
				}	
				//bearing holes
				bearingAssembly(AxisOffset, Zi-(YAxisOffset+AxisPlaneDistance) , -tol, 1);
				bearingAssembly(Yi-AxisOffsetBack, Zi-(YAxisOffset+AxisPlaneDistance), -tol, 1);
				
			}	
		}
		innerTopPanel(1);
		innerMidPanel(1);
		innerBottomPanel(1);
		innerFrontPanel(1);
		innerBackPanel(1);
		Ymot(mountingHoles=true); //mounting holes for Y motor
	}	
}

module innerBottomPanel()
{
	render() difference()
	{
		translate([i,i,Z - Zi- thickness])
		rotate([0,0,0])
		{
			difference()
			{
				union()
				{
					cube([Xi,Yi, thickness]);
					// tabs([Xi,0,0], Xi, 180, 5);
					// tabs([0, 0,0], Yi - ZaxisOffset,90, 5);
					// tabs([0,Yi,0], Xi, 0, 5);
					// tabs([Xi,Yi -ZaxisOffset,0], Yi -ZaxisOffset, -90, 5);
					tSlotsnTabs(true, !add, add);
				}
				
				translate([AxisOffset + bevel,AxisOffset + bevel, -tol])
				{	
					minkowski()
					{
						
						cylinder(r=bevel, h= thickness, $fn=36);
						cube([(Xi- AxisOffset*2 -bevel*2), (Yi -AxisOffset -AxisOffsetBack -bevel*2), thickness + 2* tol], center=false);
					}
				}	
				//Z-axis holes
				//bearingAssembly(X/4 ,Y - ZaxisOffset -1 , -tol, 1);
				//bearingAssembly(3*X/4,Y - ZaxisOffset -1, -tol, 1);
				tSlotsnTabs(false, add, add);

				
			}	
		}	
		// Zmot(mountingHoles=true);
		ZGears(mountingHoles=true);
	}	
}

//projections
module proj()
{
	render(2) projection(cut=false) 
	{
		translate([0,0,-2])
		{
			translate([-i,-(Z-Zi),thickness ]) rotate([-90,0,0]) innerFrontPanel(1); 
			
			// translate([-i, -Z + 2*(Zi + thickness) + thickness ,thickness -tol])  rotate([90, 0,-180]) translate([-X, -Y + AxisOffsetBack -AxisOffset,0]) innerMidPanel(1);
			 
			// translate([-i, -Z + 3*(Zi + 2* thickness) ,thickness -tol])  rotate([90, 0,-180]) translate([-X,-Y,0]) innerBackPanel(1);

			// translate([X -i,-Z + 4*(Zi + 3* thickness),thickness -tol]) rotate([-90,0,0]) rotate([0,0,90]) innerLeftPanel(1);
			// translate([X -i,-Z + 5*(Zi + 4* thickness), thickness2 + X - i]) rotate([-90,0,0]) rotate([0,0,90]) innerRightPanel(1);
			// translate([-i,-i + 6*(Zi + 3*thickness),-tol -Z]) rotate([0,0,0]) innerTopPanel(1);
			// translate([-i,-i + 6*(Zi + 3*thickness) + Y ,-tol -Z + Zi + thickness]) rotate([0,0,0]) innerBottomPanel(1);
		}	
	}
}

module Xmot(mountingHoles=false)
{
	translate([i + AxisOffset,i + Yi -AxisOffsetBack + AxisOffset + thickness +12 ,Z-YAxisOffset])
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
	translate([i + Xi - AxisOffset -10,i + Yi -AxisOffsetBack + AxisOffset + thickness + 20 ,Z-YAxisOffset-AxisPlaneDistance])
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
module Zmot(mountingHoles=false)
{
translate([i + Xi - AxisOffset -75,i + Yi -AxisOffsetBack + AxisOffset + thickness + 20 ,Z -20])
		rotate([0,0,0])
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
module ZGears(mountingHoles=false)
{
	translate([i + AxisOffset + WormPitchDist, i + Yi -WormPitchDist ,Z-Zi - thickness])
	{
		cylinder(r=4, h=Zi + 2* thickness, $fn=18);
		if (!mountingHoles)
		{	
			translate([0,0,Zi+ thickness -20])
				import("GT2-2mm25t.stl");
		}
	}	
	translate([i + Xi - AxisOffset - Rworm - 6,i + Yi -Rworm ,Z-Zi -thickness])
	{	
		cylinder(r=4, h=Zi + 2* thickness, $fn=18);		
		if (!mountingHoles)
		{	
			translate([0,0,Zi+ thickness -20])
				import("GT2-2mm25t.stl");
		}
	}
	if (!mountingHoles)
	{
		
	}
}

module testProjection()
{
	projection(cut=false)
		rotate([0,90,0])
			nema17();
}
innerFrontPanel(1);
innerMidPanel(1);
innerBackPanel(1);
innerLeftPanel(1);
innerRightPanel(1);
innerTopPanel();
// innerBottomPanel(1);
// outerFrontPanel(1);
// outerBackPanel(1);
// outerLeftPanel(1);
// outerRightPanel(1);
// outerTopPanel(1);
// outerBottomPanel(1);
// Xaxes();
// Yaxes();
// Zaxes();
// nema17();
// Xmot(mountingHoles=false);
// Ymot(mountingHoles=false);
// Zmot(mountingHoles=false);
// ZGears();
// proj();
// testProjection();
// tabs([X,Y,0], X, 180, 5);