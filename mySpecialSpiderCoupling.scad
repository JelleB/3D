//my own special spider coupling!
//this is a special spider coupling meant to fit into a (extruded) aluminium tube, initially with ID of ~10

ID=9.5;
Height=20;
Base=20;
tol=0.05;


module topLock(Radius=5)
{
	translate([0,0,0])
	{
		difference()
		{
			union()
			{
				translate([0,0,Height/2 + 1])
					cylinder(r=Radius, h= Height/2, $fn=36);
				translate([0,0,Height/2])
					cylinder(r1=Radius-0.7, r2 = Radius, h=1, $fn=36);	
			}
			//tapered hole for M3 bolt to lock the spider in place
			translate([0,0,Height/2])
				cylinder(r1=1.6, r2=1.2, h= Height/2 +1 , $fn=36);
		}
	}	
}

module topCross(Radius=5)
{
	translate([0,0,0])
	{
		difference()
		{
			union()
			{
				translate([0,0,0])
					cylinder(r=Radius, h= Height/2-1, $fn=36);
				translate([0,0,Height/2-1])
					cylinder(r2=Radius-0.7, r1 = Radius, h=1, $fn=36);	
			}
			//tapered hole for M3 bolt to lock the spider in place
			translate([0,0,0])
				cylinder(r=1.7, h= Height/2 +1 , $fn=36);
			translate([0,0,0])
				cylinder(r=3, h=Height/2 -1, $fn=36);
			//one half of cross
			for (i=[-1,1])
			{
				//translate([2*i*Radius/3,0,0])
				rotate([0,0,i*45])
					cube([2*Radius/3,2*Radius, Height/2 ], center=true );
			}
			cube([2*Radius, Radius, Height/2 ], center=true);
		}
	}
}

module bottomCross(Radius=4.5)
{
	translate([0,0,0])
	{
		difference()
		{
			union()
			{
				translate([0,0,-Height/4])
					cylinder(r=Radius, h= Height/2, $fn=36);
				translate([0,0,-Height/4 -10])
					cylinder(r=7, h= 10, $fn=36);	
			}
			//hole for 5mm axis on stepper
			translate([0,0,-Height/2 -10])
				cylinder(r1=2.7, r2=2.5 ,h= Height +10 , $fn=36);
			//one half of cross
			for (i=[-1,1])
			{
				translate([0,0,Height/8 + tol])
				rotate([0,0,i*45])
					cube([2*Radius/3,2*Radius, Height/4 ], center=true );
			}
			translate([0,0,Height/8 + tol ])
				cube([Radius, 2*Radius, Height/4 ], center=true);
			translate([0,0,-Height/1.3])
				cube([Base, 0.05* Base, Height], center=true);	
			for (i=[-1,1])
			{
				translate([i*Base/4,0,-Height/2])
					rotate([90,0,0])
						cylinder(r1=2, r2=1.25, h=Base, center=true, $fn=6);

				#translate([i*Base/4,3,-Height/2])
					rotate([-90,0,0])
						cylinder(r=3, h=6, , $fn=18);
			}			
		}
	}
}

//topLock(ID/2);
//topCross(ID/2);
bottomCross(ID/2-0.5);