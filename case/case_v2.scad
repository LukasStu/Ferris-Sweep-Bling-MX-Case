// -----------------------------------------------------------------------------
// --------------- Key Parameters, Fine-Tuning Here ---------------------------
// -----------------------------------------------------------------------------

// Fast preview toggle (reduces $fn and simplifies rounded case for snappier F5)
FAST_PREVIEW = false;

// Resolution for round geometry
$fn = FAST_PREVIEW ? 32 : 100;

fillet_radius = 2;    // Radius of fillet, if desired
wall_thickness = 5.5; // Wall thickness

// Layer thicknesses
keycaps_cutout_height     = 8;
seal_thickness            = 0.5;           // top buffer or gap
pcb_and_plate_thickness   = 8.5;           // from top switch plate to kailh sockets
kailh_sockets_thickness   = 2;
bottom_foam_thickness     = 2 - kailh_sockets_thickness; // foam touches pcb because of kailh cutouts
immersion_depth           = 1;
thickness                 = 1.5;
keycaps_gap               = 0.5;
switch_protruction        = 1;
slider_total_height       = thickness + immersion_depth + kailh_sockets_thickness + 0.5; // make fork a bit higher

// USB Dims (shell)
w_shell   = 8.94;
h_shell   = 3.26;
r_corner  = 1.2;

// DXF files (leave names unchanged)
dxf_plate      = "sweep-bling-mx__bottom-Edge_Cuts.dxf";
dxf_cavity     = "sweep-bling-mx__plate-Edge_Cuts-outline.dxf";
dxf_controller = "controller_cutout.dxf";
dxf_usb        = "usb-flat-cutout.dxf";
dxf_reset      = "reset.dxf";
dxf_pwr        = "power_switch/lid_cutout.dxf";
dxf_pwr_slider = "power_switch/slider_part.dxf";
dxf_pwr_cutout = "power_switch/slider_cutout.dxf";
dxf_pwr_overhang = "power_switch/overhang.dxf";
dxf_pwr_overhang_cutout = "power_switch/overhang_cutout.dxf";
dxf_slider_label = "power_switch/slider_label.dxf";

// Screw hole positions: centers of the 5 screws [X, Y] in mm
screw_positions = [
    [ 136.5, -147 ], // Screw 1
    [ 33,    -125 ], // Screw 2
    [ 34.5,   -65 ], // Screw 3
    [ 120,    -53 ], // Screw 4
    [ 152,    -90 ]  // Screw 5
];

// Case screw parameters
case_screw_diameter = 2.7; // Hole diameter in case
case_screw_depth    = 3.1; // Countersink depth

// Lid screw parameters
lid_screw_diameter  = 2.5; // Through-hole diameter in lid

// Clearances (tolerances)
clear_pcb_mm    = 0.3;
clear_usb_mm    = 0.5;
clear_switch_mm = 0.2;
reset_button_thick = 0.2;

// Derived heights
total_height = keycaps_cutout_height + pcb_and_plate_thickness + bottom_foam_thickness + immersion_depth;

// --------------------------- Z Reference Planes ------------------------------
Z0                  = 0;
Z_LID_BASE          = -thickness;
Z_LID_TOP           = Z_LID_BASE + thickness;
Z_IMMERSION_LIP_TOP = Z_LID_TOP + immersion_depth;
Z_CASE_TOP          = total_height;

// --------------------------- “Magic numbers” named ---------------------------
usb_face_Z        = immersion_depth + kailh_sockets_thickness + 9; // was "H"
usb_main_offset   = [139.9, -76, h_shell/2];
usb_tunnel_offset = [139.9, -78 + 50, h_shell/2];
usb_tunnel_len_mm = 50;

// Exploded view control (use 0 to assemble)
EXPLODE = 10;

// --------------------------- Sanity checks -----------------------------------
assert(bottom_foam_thickness >= 0, "bottom_foam_thickness became negative");
expected_total = keycaps_cutout_height + pcb_and_plate_thickness + bottom_foam_thickness + immersion_depth;
assert(abs(total_height - expected_total) < 1e-6, "total_height mismatch");

echo(total_height=total_height, slider_total_height=slider_total_height, usb_face_Z=usb_face_Z);

// -----------------------------------------------------------------------------
// ------------------------------- Helpers -------------------------------------
// -----------------------------------------------------------------------------
module extrude_file(file, z=0, h=1, delta=0) {
    translate([0,0,z])
        linear_extrude(height = h)
            offset(delta = delta)
                import(file);
}

module drill_holes(positions, d, z, h) {
    for (p = positions)
        translate([p[0], p[1], z]) cylinder(d = d, h = h);
}

module rounded_case_extrude() {
    if (FAST_PREVIEW) {
        linear_extrude(height = fillet_radius)
            offset(delta = wall_thickness)
                import(dxf_plate);
        translate([0,0,fillet_radius])
            linear_extrude(height = total_height - fillet_radius)
                offset(delta = wall_thickness)
                    import(dxf_plate);
    } else {
        linear_extrude(height = fillet_radius)
            offset(delta = wall_thickness)
                import(dxf_plate);
        minkowski() {
            sphere(fillet_radius);
            translate([0, 0, fillet_radius])
                linear_extrude(height = total_height - 2 * fillet_radius)
                    offset(delta = wall_thickness - fillet_radius)
                        import(dxf_plate);
        }
    }
}

module usb_c_cutout_2d(clearance = 0.1) {
    w = w_shell + 2 * clearance;
    h = h_shell + 2 * clearance;
    minkowski() {
        square([ w - 2 * r_corner, h - 2 * r_corner ], center = true);
        circle(r = r_corner, $fn = 64);
    }
}

// -----------------------------------------------------------------------------
// --------------------------- Module Definitions ------------------------------
// -----------------------------------------------------------------------------
module outer_case() {
    rounded_case_extrude();
}

module pcb_stack() {
    extrude_file(dxf_plate, z = 0,
        h = bottom_foam_thickness + pcb_and_plate_thickness + immersion_depth + seal_thickness,
        delta = clear_pcb_mm);
}

module keycaps_cutout() {
    extrude_file(dxf_cavity, z = 0, h = total_height, delta = 2 * keycaps_gap);
}

module flat_usb_cutout() {
    extrude_file(dxf_usb, z = 0, h = total_height - 1, delta = clear_usb_mm);
}

module lid() {
    extrude_file(dxf_plate, z = Z_LID_BASE, h = thickness, delta = wall_thickness);
    extrude_file(dxf_plate, z = Z_LID_BASE + thickness, h = immersion_depth, delta = 0);
}

module case_screw_holes() {
    drill_holes(screw_positions, case_screw_diameter, 0, case_screw_depth);
}

module lid_screw_holes() {
    drill_holes(screw_positions, lid_screw_diameter, Z_LID_BASE, thickness);
}

module usb_c_cutout_position() {
    translate(usb_main_offset)
        rotate([90, 0, 0])
            linear_extrude(height = wall_thickness)
                usb_c_cutout_2d(0.1);
    translate(usb_tunnel_offset)
        rotate([90, 0, 0])
            linear_extrude(height = usb_tunnel_len_mm)
                usb_c_cutout_2d(1.5);
}

module pwr_switch_slider_cutout(delta = 0.0) {
    extrude_file(dxf_pwr, z = Z_LID_BASE, h = thickness + immersion_depth, delta = delta);
}

module power_switch_overhang_cutout(delta = 0.0) {
    extrude_file(dxf_pwr_overhang_cutout, z = 0, h = slider_total_height, delta = delta);
}

module power_switch_slider() {
    difference() {
        extrude_file(dxf_pwr_slider, z = Z_LID_BASE - switch_protruction,
            h = slider_total_height + switch_protruction, delta = 0);
        extrude_file(dxf_pwr_cutout, z = Z_LID_BASE + immersion_depth + 0.5,
            h = slider_total_height - immersion_depth, delta = 0);
        translate([0,0,Z_LID_BASE - switch_protruction])
            linear_extrude(height = 0.2)
                import(dxf_slider_label);
    }
    extrude_file(dxf_pwr_overhang, z = 0, h = immersion_depth, delta = 0);
}

module reset_cutout(delta = 0.0) {
    extrude_file(dxf_reset, z = Z_LID_BASE, h = thickness + immersion_depth, delta = delta);
}

module reset_overhang_cutout(delta = 0.0) {
    extrude_file(dxf_reset, z = 0, h = immersion_depth, delta = delta);
}

module reset_switch_button() {
    extrude_file(dxf_reset, z = Z_LID_BASE - 0.5, h = thickness + 0.5, delta = 0);
    extrude_file(dxf_reset, z = 0, h = immersion_depth + 0.5, delta = reset_button_thick);
}

// -----------------------------------------------------------------------------
// ---------------------------- Main Assembly ----------------------------------
// -----------------------------------------------------------------------------
module top_case() {
    difference() {
        outer_case();
        pcb_stack();
        keycaps_cutout();
        power_switch_overhang_cutout(delta = clear_switch_mm);
        case_screw_holes();
        usb_c_cutout_position();
        flat_usb_cutout();
    }
}

module bottom_case() {
    difference() {
        lid();
        reset_cutout(0.2);
        reset_overhang_cutout(reset_button_thick + 0.2);
        lid_screw_holes();
        pwr_switch_slider_cutout(delta = clear_switch_mm);
        power_switch_overhang_cutout(delta = clear_switch_mm);
    }
}

PART = "all";

module build() {
    if (PART == "all") {
        translate([0, 0,  1*EXPLODE]) top_case();
        translate([0, 0, -3*EXPLODE]) bottom_case();
        translate([0, 0, -1*EXPLODE]) power_switch_slider();
        translate([0, 0, -2*EXPLODE]) reset_switch_button();
    } else if (PART == "top_case") {
        top_case();
    } else if (PART == "bottom_case") {
        bottom_case();
    } else if (PART == "power_switch_slider") {
        power_switch_slider();
    } else if (PART == "reset_switch_button") {
        reset_switch_button();
    } else {
        echo(str("Unknown PART: ", PART));
    }
}

build();
