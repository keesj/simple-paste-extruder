use <external/rack_and_pinion.scad>
use <MCAD/metric_fastners.scad>

tooth_width=4;
tooth_height=7;
small_wheel_tooth_count=12;
big_wheel_tooth_count=50;

pi=3.14;



/*
ECHO: "Teeth:", 10, " Pitch radius:", 6.3662
ECHO: "Root radius =", 4.96563, "\nPitch radius=", 6.3662, "\n Tip radius=", 7.63944, "\n"

ECHO: "Teeth:", 50, " Pitch radius:", 31.831
ECHO: "Root radius =", 30.4304, "\nPitch radius=", 31.831, "\n Tip radius=", 33.1042, "\n"

*/

/* 
  the following values where taken from the debug output. because we generate
  an item with a integer amount of teeth the radius depend on that
*/
r_small_outer= 6.3662;
r_small_pitch=7.63944;
r_big_outer=33.1042;
r_big_pitch=31.831;

module big_pinion(){
	difference() {
		pinion(tooth_width,big_wheel_tooth_count,tooth_height,5);
		bolt(8,30);
	}
}

module small_pinion(teeth_count) {
	pinion(tooth_width,teeth_count,tooth_height ,5);	
}

/*
                      
   _________________________________________
   |                                        |
   |_______________________________________ |
   | |                                    | |
   | |                                    | |
   | |____________________________________| |
   | |____________________________________| |
   | |                                    | |
   | |                                    | |
   | |                                    | |
  a| |b                                   | |
   | |                                    | |
	| |_________              _____________| |
   |___________|            |_______________|
                            


*/

thikness=8; //e.g. base thinkess in areas like a-b
base_height=12; //not visible in the picture above give we are using 8MM bolts we need a bit of room around it
pinion_height=10;//not greatly named.. but this is the height of the big pignion + some room for the bold and perhaps washers
r_seringe=16;//The lower are contains a holder for the seringe r is the radius of that seringe
bolt_length=85;//determines +- the amount of motion we can generate. depends on the bolt lenght and the seringe sizes


x_tot = r_big_outer * 2 + 2 + 2* thikness;// total width

module lower_base() {
	linear_extrude(height=base_height) 
		difference() {
			square([x_tot, 1.5* thikness + bolt_length + thikness]);
			translate([thikness,bolt_length,0]) square([r_big_outer * 2 + 2, pinion_height]);
			translate([thikness,thikness,0]) square([r_big_outer * 2 + 2, bolt_length - pinion_height - thikness /4]);
   		   translate([(x_tot  )/2 - r_seringe,0 ]) square([r_seringe *2,thikness]);
      }
	
}

module seringe_holder() {
	translate([x_tot/2,0,base_height/2]) rotate([-90,0,0]) 
	difference() {
		cylinder(h=thikness ,r=r_seringe + thikness);
		cylinder(h=thikness ,r=r_seringe );
		translate([-x_tot/2,0,0]) cube([x_tot,r_seringe + thikness,thikness ]);
	}
}




dx = r_small_pitch + r_big_pitch;
angle=-0;


module base() {
difference() {
	union() {
		lower_base();
		seringe_holder();
		translate([0,4,0]) {
		   /* holder for the stepper motor */			
			translate([dx * sin(angle),0 ,dx * cos(angle)])
		 	translate([x_tot/2,thikness + bolt_length + 4,base_height/2])rotate([90,angle,0]) stepper_mount(); 
			/* connection between the holder and the base */
			translate([dx * sin(angle),0 ,dx * cos(angle)])
		 	translate([x_tot/2,thikness + bolt_length + 4,base_height/2])rotate([90,angle,0]) translate([-10,-38,0]) cube([20,30,4]); 
		}
		}
	
	translate([x_tot/2,bolt_length + thikness *2 + pinion_height + 20,base_height/2]) rotate([90,0,0]) bolt(8,bolt_length);


}
}

//sizes taken from the stepper28BYJ datasheet
//just 3 circles where the hole are supposed to be
//we move them around a bit to 
module stepper_holder(){
	for(i=[-2:2]){
		translate([0,8 +i,0]) circle(r=4.5);// the hole for the gear(not used in this design
		translate([17.5,i,0]) circle(r=2.4);//left hole for the nut
		translate([-17.5,i,0]) circle(r=2.4);//right hole for the nut
		translate([0,i,0]) circle(r=14);//size of the inner circle 
	}
}

module stepper_mount() {
	linear_extrude(height=4) translate([0,8,0]) rotate([0,0,180]) difference() {
		circle(r=23); // Create the outer circle

		//make it hollow by eating "creating a tooth"
		translate([-28/2,-28,0]) square([28,28]);		

		stepper_holder();
	}
	
}


module extruder_view() {
	rotate([90,0,0])
	union() {
		translate([x_tot/2,thikness + bolt_length,base_height/2]) rotate([90,0,0]) big_pinion();

		translate([x_tot/2,thikness + bolt_length,base_height/2 + dx]) rotate([90,0,0]) small_pinion(small_wheel_tooth_count);
		base();
	}
}

module extruder_print(){
	rotate([0,0,90])base();
	translate([-r_big_outer -thikness -4 ,x_tot /2,0]) big_pinion();
	translate([+r_small_outer +6 ,x_tot /2,0]) small_pinion(small_wheel_tooth_count);
	translate([+r_small_outer +6  ,x_tot /2 + 20,0]) small_pinion(small_wheel_tooth_count +1); //Create two more ponion to allow play with 
	translate([+r_small_outer +6  ,x_tot /2 - 20,0]) small_pinion(small_wheel_tooth_count +2); //less teeth
}

extruder_view();
