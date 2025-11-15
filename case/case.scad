// -----------------------------------------------------------------------------
// --------------- Key Parameters, Fine-Tuning Here ---------------------------
// -----------------------------------------------------------------------------

$fn =  100;

// Dimensions & geometry
// -------------------- Parameters --------------------
fillet_radius = 2.5;
wall_thickness_outer = 5;
wall_thickness_inner = 2;
keycaps_cutout_height = 8;
seal_thickness = 0.5;
controller_wall_thickness = 1;

fr4_thickness = 1.6;
switchplate_thickness = 3.3;
kailh_sockets_thickness = 2;
bottom_foam_thickness = 2;
pcb_and_plate_thickness = bottom_foam_thickness + switchplate_thickness + 2 * fr4_thickness;

actual_bottom_foam_thickness = bottom_foam_thickness - kailh_sockets_thickness;

immersion_depth = 1;
lid_thickness = 1.5;
keycaps_gap = 0.5;
switch_protruction = 1;
slider_total_height = lid_thickness + immersion_depth + kailh_sockets_thickness + 0.5;

// USB
w_shell = 8.94;
h_shell = 3.26;
r_corner = 1.2;
pcb_usb_distance = 9;
Z_USB = h_shell / 2 + immersion_depth + kailh_sockets_thickness + pcb_usb_distance;
usb_main_offset = [139.9, -76, Z_USB];
usb_tunnel_offset = [139.9, -28, Z_USB];
usb_tunnel_len_mm = 50;

// Single DXF file + layer names
DXF = "ferris_sweep_bling_mx.dxf";

L_plate = "pcb_outline";
L_outer_shape = "outer_shape";
L_outer_shape_decor = "outer_shape_decor";
L_decor_lines = "decor_lines";
L_cavity = "keycaps_outline";
L_usb = "controller_cutout";
L_reset = "reset";
L_pwr = "pwr_lid_cutout";
L_pwr_slider = "pwr_body";
L_pwr_cutout = "pwr_knob_cutout";
L_pwr_overhang = "pwr_body_overhang";
L_pwr_overhang_cutout = "pwr_overhang_cutout";
L_slider_label = "pwr_on_label";
L_switches = "switches";
L_switchplate = "switchplate_outline";

// Screw positions & sizes
screw_positions = [[140, -152], [29.5, -132], [30, -32], [152, -32], [153.5, -90]];
case_screw_diameter = 2.7;
case_screw_depth = 3.1;
lid_screw_diameter = 2.5;

// Clearances
clear_pcb_mm = 0.3;
clear_usb_mm = 0.5;
clear_switch_mm = 0.2;
reset_button_thick = 0.2;

// Derived
Z_LID_BASE = -lid_thickness;
total_height_top_case = keycaps_cutout_height + pcb_and_plate_thickness + actual_bottom_foam_thickness + immersion_depth;
EXPLODE = 10;

// -----------------------------------------------------------------------------
// ------------------------------- Helpers -------------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: extrude_layer --------------------
module extrude_layer(layer, z = 0, h = 1, delta = 0) { translate([0, 0, z]) linear_extrude(height=h) offset(delta=delta) import(file=DXF, layer=layer); }

// -------------------- Module: drill_holes --------------------
module drill_holes(positions, d, z, h) { for (p = positions) translate([p[0], p[1], z]) cylinder(d=d, h=h); }

// -----------------------------------------------------------------------------
// ------------------------------ Components -----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: rounded_case_extrude --------------------
module rounded_case_extrude() {
  extrude_layer(L_outer_shape, h=fillet_radius, delta=0);
  minkowski() { sphere(fillet_radius); translate([0, 0, fillet_radius]) extrude_layer(L_outer_shape, h=total_height_top_case - 2 * fillet_radius, delta= - fillet_radius); }
}

module pcb_holder() {
    difference() {
        extrude_layer(L_outer_shape, h=total_height_top_case-8, delta=-wall_thickness_outer);
        extrude_layer(L_plate, h=total_height_top_case-8, delta=wall_thickness_inner);
    }
}
// -------------------- Module: usb_c_cutout_2d --------------------
module usb_c_cutout_2d(cw = 0.1, ch = 0.1) {
  w = w_shell + 2 * cw;
  h = h_shell + 2 * ch;
  minkowski() { square([w - 2 * r_corner, h - 2 * r_corner], center=true); circle(r=r_corner, $fn=64); }
}

// -------------------- Module: outer_case --------------------
module outer_case() { rounded_case_extrude(); }

// -------------------- Module: pcb_stack --------------------
module pcb_stack() { extrude_layer(L_plate, h=actual_bottom_foam_thickness + pcb_and_plate_thickness + immersion_depth + seal_thickness, delta=clear_pcb_mm); }

// -------------------- Module: keycaps_cutout --------------------
module keycaps_cutout() { extrude_layer(L_cavity, h=total_height_top_case, delta=2 * keycaps_gap); }

// -------------------- Module: flat_usb_cutout --------------------
module flat_usb_cutout() { extrude_layer(L_usb, h=total_height_top_case - controller_wall_thickness, delta=clear_usb_mm); }

// -------------------- Module: lid --------------------
module lid() {
  extrude_layer(L_outer_shape, z=Z_LID_BASE, h=lid_thickness, delta=0);
  extrude_layer(L_plate, z=Z_LID_BASE + lid_thickness, h=immersion_depth);
}

// -------------------- Module: case_screw_holes --------------------
module case_screw_holes() { drill_holes(screw_positions, case_screw_diameter, 0, case_screw_depth); }

// -------------------- Module: lid_screw_holes --------------------
module lid_screw_holes() { drill_holes(screw_positions, lid_screw_diameter, Z_LID_BASE, lid_thickness); }

// -------------------- Module: usb_c_cutout_position --------------------
module usb_c_cutout_position() {
  translate(usb_main_offset) rotate([90, 0, 0]) linear_extrude(height=5) usb_c_cutout_2d();
  translate(usb_tunnel_offset) rotate([90, 0, 0]) linear_extrude(height=usb_tunnel_len_mm) usb_c_cutout_2d(1.1, 1.65);
}

// -------------------- Module: pwr_switch_slider_cutout --------------------
module pwr_switch_slider_cutout(delta = 0) { extrude_layer(L_pwr, z=Z_LID_BASE, h=lid_thickness + immersion_depth, delta=delta); }

// -------------------- Module: power_switch_overhang_cutout --------------------
module power_switch_overhang_cutout(delta = 0) { extrude_layer(L_pwr_overhang_cutout, h=slider_total_height, delta=delta); }

// -------------------- Module: power_switch_slider --------------------
module power_switch_slider() {
  difference() {
    extrude_layer(L_pwr_slider, z=Z_LID_BASE - switch_protruction, h=slider_total_height + switch_protruction);
    extrude_layer(L_pwr_cutout, z=Z_LID_BASE + immersion_depth + 0.5, h=slider_total_height - immersion_depth);
    translate([0, 0, Z_LID_BASE - switch_protruction]) linear_extrude(height=0.2) import(file=DXF, layer=L_slider_label);
  }
  extrude_layer(L_pwr_overhang, h=immersion_depth);
}

// -------------------- Module: reset_cutout --------------------
module reset_cutout(delta = 0) { extrude_layer(L_reset, z=Z_LID_BASE, h=lid_thickness + immersion_depth, delta=delta); }

// -------------------- Module: reset_overhang_cutout --------------------
module reset_overhang_cutout(delta = 0) { extrude_layer(L_reset, h=immersion_depth, delta=delta); }

// -------------------- Module: reset_switch_button --------------------
module reset_switch_button() {
  extrude_layer(L_reset, z=Z_LID_BASE - 0.5, h=lid_thickness + 0.5);
  extrude_layer(L_reset, h=immersion_depth + 0.5, delta=reset_button_thick);
}

module top_plate_decor_cutout() {
    extrude_layer(L_outer_shape_decor, z=total_height_top_case-0.5 , h=0.5, delta=1.0);  
}

module top_plate_decor() {
    difference(){
        extrude_layer(L_outer_shape_decor, z=total_height_top_case-0.5 , h=0.5, delta=0.0); 
        keycaps_cutout();
    }
}

module top_plate_decor_lines_cutout() {
    extrude_layer(L_decor_lines, z=total_height_top_case-0.5 , h=0.5, delta=0);  
}

// -----------------------------------------------------------------------------
// ------------------------------ Assemblies -----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: top_case --------------------
module top_case() {
  difference() {
    outer_case();
    pcb_stack();
    power_switch_overhang_cutout(delta=clear_switch_mm);
    keycaps_cutout();
    case_screw_holes();
    top_plate_decor_cutout();
    top_plate_decor_lines_cutout()
    usb_c_cutout_position();
    flat_usb_cutout();
    pcb_holder();
  }
  top_plate_decor();
}

// -------------------- Module: bottom_case --------------------
module bottom_case() {
  difference() {
    lid();
    reset_cutout(0.2);
    reset_overhang_cutout(reset_button_thick + 0.2);
    lid_screw_holes();
    pwr_switch_slider_cutout(delta=clear_switch_mm);
    power_switch_overhang_cutout(delta=clear_switch_mm);
  }
}

// -------------------- Module: switchplate foam --------------------
module switchplate_foam() {
  difference() {
    extrude_layer(L_switchplate, z=fr4_thickness, h=switchplate_thickness, delta=-0.3);
    extrude_layer(L_switches, z=fr4_thickness, h=switchplate_thickness, delta=0.3);
  }
}

// -------------------- Module: bottom foam --------------------
module bottom_foam() {
  difference() {
    extrude_layer(L_switchplate, z=immersion_depth, h=bottom_foam_thickness, delta=-0.3);
    extrude_layer(L_switches, z=immersion_depth, h=bottom_foam_thickness, delta=0.3);
  }
}

// -----------------------------------------------------------------------------
// --------------------------- Optional Tent Support ---------------------------
// -----------------------------------------------------------------------------
// Render by setting PART = "tent"
// Note: Changing tenting_angle requires adjusting tent_lowering.

// ---- Tenting Parameters ----
tenting_angle = 10;
tent_base_thickness = 1;
tent_support_base_thickness = 0.0001;
tent_support_base_width = 2;
tent_support_wall_thickness = 1.5;
tent_support_wall_height = 6;
tent_clearance = 0.2;
tent_lowering = 5.5;

// Outline (uses main PCB outline layer) expanded by case wall_thickness
module tent_case_outline() { offset(delta=0) import(file=DXF, layer=L_outer_shape); }

module tent_base_plate() {
  linear_extrude(tent_base_thickness)
    projection()
      rotate([0, -tenting_angle, 0])
        linear_extrude(0.0001)
          offset(delta=tent_clearance + tent_support_wall_thickness)
            tent_case_outline();
}

module tent_support_base() {
  linear_extrude(tent_support_base_thickness)
    difference() {
      offset(delta=tent_clearance + tent_support_wall_thickness)
        tent_case_outline();
      offset(delta=-tent_support_base_width)
        tent_case_outline();
    }
}

module tent_support_walls() {
  translate([0, 0, tent_support_base_thickness])
    linear_extrude(tent_support_wall_height)
      difference() {
        offset(delta=tent_clearance + tent_support_wall_thickness)
          tent_case_outline();
        offset(delta=tent_clearance)
          tent_case_outline();
      }
}

module tent_support() {
  translate([0, 0, tent_base_thickness])
    union() {
      translate([0, 0, tent_support_base_thickness - tent_lowering])
        rotate([0, -tenting_angle, 0])
          union() {
            tent_support_base();
            tent_support_walls();
          }

      difference() {
        linear_extrude()
          projection()
            rotate([0, -tenting_angle, 0])
              linear_extrude(0.0001)
                projection()
                  tent_support_base();

        translate([0, 0, tent_support_base_thickness - tent_lowering])
          rotate([0, -tenting_angle, 0])
            linear_extrude()
              offset(delta=100)
                projection()
                  tent_support_base();
      }
    }
}

// Full tent assembly (base + support structure)
module tent() {
  tent_base_plate();
  tent_support();
}

// -----------------------------------------------------------------------------
// ------------------------------ Build Select ---------------------------------
// -----------------------------------------------------------------------------
PART = "exploded";

// -------------------- Module: build --------------------
module build() {
  if (PART == "exploded") {
    translate([0, 0, EXPLODE]) top_case();
    translate([0, 0, -EXPLODE]) switchplate_foam();
    translate([0, 0, -2 * EXPLODE]) power_switch_slider();
    translate([0, 0, -2 * EXPLODE]) reset_switch_button();
    translate([0, 0, -3 * EXPLODE]) bottom_foam();
    translate([0, 0, -4 * EXPLODE]) bottom_case();
  } else if (PART == "top_case")
    top_case();
  else if (PART == "switch_plate_foam")
    switchplate_foam();
  else if (PART == "power_switch_slider")
    power_switch_slider();
  else if (PART == "reset_switch_button")
    reset_switch_button();
  else if (PART == "bottom_foam")
    bottom_foam();
  else if (PART == "bottom_case")
    bottom_case();
  else if (PART == "tent")
    tent();
  else
    echo(str("Unknown PART: ", PART));
}

build();
