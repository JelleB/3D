motorWidth=42;
motorHeight=38;

slotLenght=8;
slotOffset=(slotLenght -3)/2;

module nema17()
{
	translate([0,0,-38])
	difference()
	{
		union()
		{
			//central axis
			cylinder(r=2.5, h=65, $fn=18);
			cylinder(r=11, h=39, $fn=36);
			translate([-19,-19,0])
				minkowski()
				{
					cylinder(r=2, h=0.05, $fn=4);
					cube([38,38,38]);
				}
		}//union	
		for (xn=[-1,1])
		{
			for (yn=[-1,1])
			{
				translate([15.5*xn, 15.5*yn, -1])
					cylinder(r=1.5, h=60, $fn=18);
				
			}
		}
	}	
	
}
module nema17MountingHoles(height=12)
{
	cylinder(r=11, h=height, $fn=36);
	for (xn=[-1,1])
	{
		for (yn=[-1,1])
		{
			translate([15.5*xn, 15.5*yn, -1])
				cylinder(r=1.5, h=height, $fn=18);
			
		}
	}
}
module nema17MountingSlots(height=12)
{
	hull()
	{
		translate([0,-slotOffset,0]) cylinder(r=11, h=height, $fn=36);
		translate([0,slotOffset,0]) cylinder(r=11, h=height, $fn=36);
	}	
	for (xn=[-1,1])
	{
		for (yn=[-1,1])
		{
			hull()
			{
				translate([15.5*xn, 15.5*yn +slotOffset, -1]) cylinder(r=1.5, h=height, $fn=18);
				translate([15.5*xn, 15.5*yn -slotOffset, -1]) cylinder(r=1.5, h=height, $fn=18);
			}	
		}
	}
}
nema17();