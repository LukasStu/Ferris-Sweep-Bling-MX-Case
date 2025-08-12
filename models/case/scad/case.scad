// -----------------------------------------------------------------------------
// --------------- Key Parameters, Fine-Tuning Here ---------------------------
// -----------------------------------------------------------------------------

$fn = 100;                // Resolution for bore edges
fillet_radius = 2;     // Radius of fillet, if desired
wall_thickness = 5.5;    // Wall thickness
separation = 0;          // Separation offset

// Layer thicknesses
keycaps_cutout_height = 8;
seal_thickness = 0.5; //top buffer or gap
pcb_and_plate_thickness = 8.5; //from top switch plate to kailh sockets
kailh_sockets_thickness = 2;
bottom_foam_thickness = 2-kailh_sockets_thickness;// foam touches pcb because of the kailh cutouts
immersion_depth = 1;
thickness = 1.5;
keycaps_gap = 0.5;
switch_protruction = 1;
slider_total_height = thickness + immersion_depth + kailh_sockets_thickness + 0.5;  // make fork a bit higher

//USB Dims
w_shell = 8.94;
h_shell = 3.26;
r_corner = 1.2;

// DXF files (leave names unchanged)
dxf_plate = "sweep-bling-mx__bottom-Edge_Cuts.dxf";
dxf_cavity = "sweep-bling-mx__plate-Edge_Cuts-outline.dxf";
dxf_controller = "controller_cutout.dxf";
dxf_usb = "usb-flat-cutout.dxf";
dxf_reset = "reset.dxf";
dxf_pwr_slider = "power_switch/slider_part.dxf";
dxf_pwr_cutout = "power_switch/slider_cutout.dxf";
dxf_pwr_overhang = "power_switch/overhang.dxf";
dxf_pwr_overhang_cutout = "power_switch/overhang_cutout.dxf";
dxf_slider_label = "power_switch/slider_label.dxf";


// Screw hole positions: centers of the 5 screws [X, Y] in mm
screw_positions = [
  [136.5, -147],  // Screw 1
  [33,  -125],  // Screw 2
  [34.5, -65],  // Screw 3
  [120,  -53],  // Screw 4
  [152, -90]  // Screw 5
];

// Case screw parameters
case_screw_diameter = 2.7;  // Hole diameter in case
case_screw_depth = 3.1;     // Countersink depth

// Lid screw parameters
lid_screw_diameter = 2.5;   // Through-hole diameter in lid

// Total height calculation
total_height = keycaps_cutout_height + pcb_and_plate_thickness + bottom_foam_thickness + immersion_depth;


// -----------------------------------------------------------------------------
// --------------------------- Module Definitions ------------------------------
// -----------------------------------------------------------------------------

// Outer case body
module outer_case() {
        // Lower part (sharp edges)
    linear_extrude(height = fillet_radius)
        offset(delta = wall_thickness)
            import(dxf_plate);
    
    minkowski() {
        // Abrundungskörper (Kugel)
        sphere(fillet_radius);

        // Geometrie: 2D -> schrumpfen -> extrudieren -> hochheben
        translate([0, 0, fillet_radius])
            linear_extrude(height = total_height - 2 * fillet_radius)
                offset(delta = wall_thickness -  fillet_radius)
                    import(dxf_plate);
    }
}


// PCB + switch plate stack
module pcb_stack() {
    translate([0, 0, 0])
        linear_extrude(height = bottom_foam_thickness + pcb_and_plate_thickness + immersion_depth + seal_thickness)
            offset(delta = 0.3) // allow some space for the pcb
                import(dxf_plate);
}

// Keycap recess
module keycaps_cutout() {
    translate([0, 0, 0]) {
        linear_extrude(height = total_height)
            offset(delta = 2 * keycaps_gap)
                import(dxf_cavity);
    }
}


// Flat USB cutout
module flat_usb_cutout() {
    translate([0,0,0]) 
    linear_extrude(height = total_height - 1)
        offset(delta = 0.5)
            import(dxf_usb);
}


// Lid body
module lid() {

            // Lid base
            translate([0,0, -thickness + separation])
                linear_extrude(height = thickness)
                    offset(delta = wall_thickness)
                        import(dxf_plate);

            // Immersion lip
            translate([0,0, -thickness + separation + thickness])
                linear_extrude(height = immersion_depth)
                    import(dxf_plate);
  

}

// Case screw holes
module case_screw_holes() {
    for (pos = screw_positions) {
        translate([pos[0], pos[1], 0])
            cylinder(d = case_screw_diameter, h = case_screw_depth);
    }
}

// Lid screw holes
module lid_screw_holes() {
    for (pos = screw_positions) {
        translate([pos[0], pos[1], -thickness + separation])
            cylinder(d = lid_screw_diameter, h = thickness);
    }
}

module usb_c_cutout_2d(clearance = 0.1) {

    w = w_shell + 2*clearance;
    h = h_shell + 2*clearance;
    minkowski() {
        square([w - 2*r_corner, h - 2*r_corner], center = true);
        circle(r = r_corner, $fn = 64);
    }
}

module usb_c_cutout_position() {
    H = immersion_depth+kailh_sockets_thickness+9;
    translate([0, 0, h_shell/2]){
    translate([139.9, -76, H])
        rotate([90, 0, 0])
            linear_extrude(height = wall_thickness)
                usb_c_cutout_2d();
    translate([139.9, -78+50, H])
        rotate([90, 0, 0])
            linear_extrude(height = 50)
                usb_c_cutout_2d(1.5);
    }
}

// power switch lid and case cutout
module pwr_switch_slider_cutout(delta = 0.0) {
    translate([0, 0, - thickness  + separation])
        linear_extrude(height = thickness + immersion_depth)
            offset(delta = delta)
                import(dxf_pwr);
}

module power_switch_overhang_cutout(delta = 0.0) {
    translate([0,0, 0 + separation])
            linear_extrude(height = slider_total_height)
                offset(delta = delta)
                    import(dxf_pwr_overhang_cutout);  



    
}
    
module power_switch_slider() {

    difference(){
        // slider body
        translate([0,0, -thickness - switch_protruction + separation])
            linear_extrude(height = slider_total_height + switch_protruction)
                import(dxf_pwr_slider);
        // slider cutout
        translate([0,0, -thickness + immersion_depth + 0.5 + separation])
            linear_extrude(height = slider_total_height - immersion_depth)
                import(dxf_pwr_cutout);
        // slider label
        translate([0,0, -thickness - switch_protruction + separation])
            linear_extrude(height = 0.2)
                import(dxf_slider_label);
        
    }
    // slider body overhang
    translate([0,0, separation])
        linear_extrude(height = immersion_depth)
            import(dxf_pwr_overhang);
}


module reset_cutout(delta = 0.0) {
        translate([0,0, -thickness + separation])
            linear_extrude(height = thickness + immersion_depth)
                offset(delta = delta)
                    import(dxf_reset);
}

reset_button_thick = 0.2;
module reset_overhang_cutout(delta = 0.0) {
        translate([0,0,0 + separation])
            linear_extrude(height = immersion_depth)
                offset(delta = delta)
                    import(dxf_reset);
}

module reset_switch_button() {
        translate([0,0,-thickness - 0.5 + separation])
            linear_extrude(height = thickness + 0.5)
                offset(delta = 0)
                    import(dxf_reset);
         translate([0,0,separation])
            linear_extrude(height = immersion_depth + 0.5)
                offset(delta = reset_button_thick)
                    import(dxf_reset);
    
}

// -----------------------------------------------------------------------------
// ---------------------------- Main Assembly -----------------------------------
// -----------------------------------------------------------------------------

// Bottom half with screw holes
module top_case(){
    difference() {
        outer_case();
        pcb_stack();
        keycaps_cutout();
        power_switch_overhang_cutout(delta = 0.2);
        case_screw_holes();
        usb_c_cutout_position();
        flat_usb_cutout();
    }
}

// Render lid separately
module bottom_case(){
    difference() {
        lid();
        reset_cutout(0.2);
        reset_overhang_cutout(reset_button_thick + 0.2);
        lid_screw_holes();
        pwr_switch_slider_cutout(delta = 0.2);
        power_switch_overhang_cutout(delta = 0.2);
    }
}

//top_case();
//bottom_case();
power_switch_slider();
//reset_switch_button();