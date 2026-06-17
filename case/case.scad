// -----------------------------------------------------------------------------
// Ferris Sweep MX Case Generator
// Author: Lukas Stürmlinger
// Requires: OpenSCAD 2021+ and ferris_sweep_bling_mx.dxf in the same directory.
// Description: Builds top/bottom shells, switch-plate foam, slider, reset button,
//              and optional tent support by extruding DXF layers via extrude_layer().
// Usage: Set PART to "top_case", "bottom_case", etc., then F6 to render.
// Notes: All dimensions in millimeters; DXF layers listed below must be kept in sync.
// CI: Every push triggers .github/workflows/build-stls-on-push.yml to render all STLs via GitHub Actions.
// -----------------------------------------------------------------------------
$fn = 100;

// Dimensions & geometry
// -------------------- Parameters --------------------
// top case
fillet_radius = 2.5;
top_case_thickness = 3;
case_wall_thickness = 3;
controller_cover_thickness = 1;
keycaps_gap = 0.5;
keycaps_cutout_height = 8.5;
decoration_cutout_depth = 1.0;

// bottom case
bottom_thickness = 2;
bottom_gap = 1.5;

// rim
rim = 0.5;
rim_height = 1;
rim_clear = 0.2;

// PCB + plate
kailh_sockets_thickness = 2;
fr4_thickness = 1.6;
switch_plate_foam_thickness = 3.3;

// gasket
gasket_thickness = 2;
compression = 0.5;
compressed_gasket_thickness = gasket_thickness * (1 - compression);
gasket_rim = 1.5;

// switches
switch_protrusion = 1;
slider_immersion_depth = 0.5;
slider_total_height =
  switch_protrusion + bottom_thickness + bottom_gap + kailh_sockets_thickness + fr4_thickness - 0.5;
MSK_thickness = 1.4;
B3U_thickness = 1.6;

// USB
w_shell = 8.94;
h_shell = 3.26;
r_corner = 1.2;
pcb_usb_distance = 9;
Z_USB = h_shell / 2 + bottom_gap + kailh_sockets_thickness + fr4_thickness + pcb_usb_distance;
usb_main_offset = [ 139.9, -76, Z_USB ];
usb_tunnel_offset = [ 139.9, -28, Z_USB ];
usb_tunnel_len_mm = 50;

// Screw positions & sizes
heat_sink_insert_diameter = 2.7;
heat_sink_insert_depth = 3.1;
screw_diameter = 2.5;
thread_length = 4;
head_diameter = 4.5;
thread_intrusion = 2;
screw_support_diameter = 7;
screw_marker_diameter = 1;

// Rubber feet
insert_height = 3;
foot_height = 1.5;
hollow_diameter = head_diameter - 0.9;

// Clearances
clear_pcb_mm = 1.0;
clear_gasket_mm = 0.5;
clear_usb_mm = 0.5;
clear_switch_mm = 0.2;
screw_support_clearance = 0.2;

// Derived Heights
z_bottom_gap = bottom_thickness;
z_kailh_sockets = z_bottom_gap + bottom_gap;
z_pcb = z_kailh_sockets + kailh_sockets_thickness;
z_switchplate_foam = z_pcb + fr4_thickness;
z_switchplate = z_switchplate_foam + switch_plate_foam_thickness;
z_keycaps_cutout = z_switchplate + fr4_thickness;

// bases and tops
z_bottom_case_top = z_keycaps_cutout;
z_top_case_base = z_bottom_case_top;
z_top_case_top = z_bottom_case_top + keycaps_cutout_height;

// Derived
total_height_bottom_case = z_keycaps_cutout;
total_height_top_case = keycaps_cutout_height;

// Single DXF file + layer names
DXF = "ferris_sweep_bling_mx.dxf";

L_pcb_outline = "pcb_outline";
L_outer_shape = "outer_shape";
L_outer_shape_decor = "outer_shape_decor";
L_decor_lines = "decor_lines";
L_keycaps_outline = "keycaps_outline";
L_controller_cutout = "controller_cutout";
L_reset = "reset";
L_pwr_lid_cutout = "pwr_lid_cutout";
L_pwr_body = "pwr_body";
L_pwr_circ = "pwr_circ";
L_pwr_body_support = "pwr_body_support";
L_pwr_knob_cutout = "pwr_knob_cutout";
L_pwr_body_overhang = "pwr_body_overhang";
L_pwr_overhang_cutout = "pwr_overhang_cutout";
L_pwr_on_label = "pwr_on_label";
L_switches = "switches";
L_switchplate_outline = "switchplate_outline";
L_gasket_supports = "gasket_supports";
L_gasket_supports_rim = "gasket_supports_rim";
L_screw_markers = "screw_markers";
L_trrs = "trrs";

// -----------------------------------------------------------------------------
// ------------------------------- Helpers -------------------------------------
// -----------------------------------------------------------------------------

module extrude_layer(layer, z = 0, h = 1, delta = 0) {
  translate([ 0, 0, z ]) linear_extrude(height = h) offset(delta = delta) import(file = DXF, layer = layer);
}

module screw_hole_layer(z = 0, h = 1, target_diameter = screw_marker_diameter) {
  marker_delta = (target_diameter - screw_marker_diameter) / 2;
  extrude_layer(L_screw_markers, z = z, h = h, delta = marker_delta);
}

// -----------------------------------------------------------------------------
// ------------------------------ Top und bottom basics ------------------------
// -----------------------------------------------------------------------------

module outer_shape_top() {
  difference() {
    union() {
      extrude_layer(L_outer_shape, z = z_top_case_base, h = fillet_radius);
      minkowski() {
        sphere(fillet_radius);
        translate([ 0, 0, z_top_case_base + fillet_radius ])
            extrude_layer(L_outer_shape, h = total_height_top_case - 2 * fillet_radius, delta = -fillet_radius);
      }
    }
    extrude_layer(L_outer_shape, z_top_case_base, h = total_height_top_case - top_case_thickness,
                  delta = -case_wall_thickness);
  }
}

module outer_shape_bottom() {
  difference() {
    union() {
      extrude_layer(L_outer_shape, z = fillet_radius, h = total_height_bottom_case - fillet_radius);
      minkowski() {
        sphere(fillet_radius);
        translate([ 0, 0, fillet_radius ])
            extrude_layer(L_outer_shape, h = total_height_bottom_case - 2 * fillet_radius, delta = -fillet_radius);
      }
    }
    extrude_layer(L_outer_shape, z = z_bottom_gap, h = total_height_bottom_case - bottom_thickness,
                  delta = -case_wall_thickness);
  }
}

module case_rim(delta = 0) {
  difference() {
    extrude_layer(L_outer_shape, z = z_bottom_case_top, h = rim_height + delta,
                  delta = -case_wall_thickness / 2 + rim / 2 + delta / 2);
    extrude_layer(L_outer_shape, z = z_bottom_case_top, h = rim_height + delta,
                  delta = -case_wall_thickness / 2 - rim / 2 - delta / 2);
  }
}

// -----------------------------------------------------------------------------
// ------------------------------ Top und bottom basics ------------------------
// -----------------------------------------------------------------------------

module upper_gasket_taps() {
  difference() {
    extrude_layer(L_gasket_supports, z = z_switchplate + compressed_gasket_thickness,
                  h = fr4_thickness + keycaps_cutout_height - decoration_cutout_depth - compressed_gasket_thickness,
                  delta = 0.2);
    extrude_layer(L_pcb_outline, z = z_switchplate + compressed_gasket_thickness,
                  h = fr4_thickness + keycaps_cutout_height - decoration_cutout_depth - compressed_gasket_thickness,
                  delta = 0.2);
  }
}

module lower_gasket_taps() {
  difference() {
    extrude_layer(L_gasket_supports, z = z_bottom_gap,
                  h = bottom_gap + kailh_sockets_thickness + fr4_thickness - compressed_gasket_thickness);
    extrude_layer(L_pcb_outline, z = z_bottom_gap,
                  h = bottom_gap + kailh_sockets_thickness + fr4_thickness - compressed_gasket_thickness,
                  delta = clear_gasket_mm);
  }
}

module lower_gasket_taps_rims() {
  difference() {
    extrude_layer(L_gasket_supports_rim, z = z_bottom_gap,
                  h = bottom_gap + kailh_sockets_thickness + fr4_thickness + compressed_gasket_thickness + gasket_rim);
    extrude_layer(L_pcb_outline, z = z_bottom_gap,
                  h = bottom_gap + kailh_sockets_thickness + fr4_thickness + compressed_gasket_thickness + gasket_rim,
                  delta = clear_gasket_mm);
  }
}

module keycaps_cutout() {
  extrude_layer(L_keycaps_outline, h = z_top_case_top, delta = 2 * keycaps_gap);
}

module controller_cutout() {
  extrude_layer(L_controller_cutout, h = z_top_case_top - controller_cover_thickness, delta = clear_usb_mm);
}

// -----------------------------------------------------------------------------
// ------------------------------ Buttons, Switches, USB------------------------
// -----------------------------------------------------------------------------

module pwr_switch_slider_cutout(delta = 0) {
  extrude_layer(L_pwr_lid_cutout, h = bottom_thickness, delta = delta);
}

module power_switch_overhang_cutout(delta = 0) {
  extrude_layer(L_pwr_overhang_cutout, z = bottom_thickness - slider_immersion_depth, h = slider_total_height,
                delta = delta);
}

module power_switch_slider() {
  body_h = MSK_thickness + compressed_gasket_thickness + 1;
  overhang_h = slider_immersion_depth + bottom_gap + kailh_sockets_thickness + fr4_thickness - MSK_thickness -
               compressed_gasket_thickness - 0.5;
  body_z = z_bottom_gap + overhang_h;

  difference() {
    union() {
      extrude_layer(L_pwr_circ, z = -switch_protrusion, h = bottom_thickness + switch_protrusion);
      extrude_layer(L_pwr_body_overhang, z = z_bottom_gap - slider_immersion_depth, h = slider_immersion_depth);
      extrude_layer(L_pwr_body_overhang, z = z_bottom_gap, h = overhang_h);
      extrude_layer(L_pwr_body, z = body_z, h = body_h);
    }
    extrude_layer(L_pwr_knob_cutout, z = body_z, h = body_h);
    extrude_layer(L_pwr_on_label, z = -switch_protrusion, h = 0.4);
  }
}

module power_body_support() {
  extrude_layer(L_pwr_body_support, z = bottom_thickness, h = 2);
}

module reset_cutout(delta = 0) {
  extrude_layer(L_reset, h = bottom_thickness, delta = delta);
}

module reset_switch_button() {
  extrude_layer(L_reset, z = -switch_protrusion, h = bottom_thickness + switch_protrusion);
  extrude_layer(L_reset, z = z_bottom_gap, h = bottom_gap, delta = 1);
}

module usb_c_cutout_2d(cw = 0.1, ch = 0.1) {
  w = w_shell + 2 * cw;
  h = h_shell + 2 * ch;
  minkowski() {
    square([ w - 2 * r_corner, h - 2 * r_corner ], center = true);
    circle(r = r_corner, $fn = 64);
  }
}

module usb_c_cutout_position() {
  translate(usb_main_offset) rotate([ 90, 0, 0 ]) linear_extrude(height = 5) usb_c_cutout_2d();
  translate(usb_tunnel_offset) rotate([ 90, 0, 0 ]) linear_extrude(height = usb_tunnel_len_mm)
      usb_c_cutout_2d(1.1, 1.65);
}

// Note: This cutout is only needed if the TRRS jack is mounted on the PCB and protrudes above the case bottom. Adjust z and h as needed. Very basic rectangular cutout...
module trrs_cutout() {
  extrude_layer(L_trrs, z = z_bottom_gap, h = bottom_gap + kailh_sockets_thickness + fr4_thickness);
}
// -----------------------------------------------------------------------------
// ------------------------------ Threads and screws -----------------------------
// -----------------------------------------------------------------------------

module supports_pcb_clearance() {
  extrude_layer(L_pcb_outline, h = total_height_bottom_case + total_height_top_case, delta = clear_pcb_mm);
}

module top_insert_support() {
  screw_support_diameter_delta = (screw_support_diameter - screw_marker_diameter) / 2;
  heat_sink_insert_diameter_delta = (heat_sink_insert_diameter - screw_marker_diameter) / 2;
  difference() {
    extrude_layer(L_screw_markers, z = z_top_case_top - top_case_thickness - heat_sink_insert_depth,
                  h = heat_sink_insert_depth, delta = screw_support_diameter_delta);
    extrude_layer(L_screw_markers, z = z_top_case_top - top_case_thickness - heat_sink_insert_depth,
                  h = heat_sink_insert_depth, delta = heat_sink_insert_diameter_delta);
    supports_pcb_clearance();
  }
}

module bottom_screw_support() {
  screw_support_diameter_delta = (screw_support_diameter - screw_marker_diameter) / 2;
  head_diameter_delta = (head_diameter - screw_marker_diameter) / 2;
  screw_diameter_delta = (screw_diameter - screw_marker_diameter) / 2;
  difference() {
    extrude_layer(L_screw_markers, z = z_bottom_gap,
                  h = z_top_case_top - bottom_thickness - top_case_thickness - heat_sink_insert_depth -
                      screw_support_clearance,
                  delta = screw_support_diameter_delta);
    extrude_layer(L_screw_markers, z = z_bottom_gap,
                  h = z_top_case_top - bottom_thickness - top_case_thickness - (thread_length - thread_intrusion) -
                      heat_sink_insert_depth,
                  delta = head_diameter_delta);
    extrude_layer(L_screw_markers, z = z_bottom_gap,
                  h = z_top_case_top - bottom_thickness - top_case_thickness - heat_sink_insert_depth,
                  delta = screw_diameter_delta);
    supports_pcb_clearance();
  }
}

module bottom_screw_holes() {
  screw_hole_layer(h = z_bottom_gap, target_diameter = head_diameter);
}

// -----------------------------------------------------------------------------
// ------------------------------ Decorations ----------------------------------
// -----------------------------------------------------------------------------

module top_plate_decor_cutout() {
  extrude_layer(L_outer_shape_decor, z = z_top_case_top - decoration_cutout_depth, h = decoration_cutout_depth);
}

module top_plate_decor_lines_cutout() {
  extrude_layer(L_decor_lines, z = z_top_case_top - decoration_cutout_depth, h = decoration_cutout_depth);
}
// -----------------------------------------------------------------------------
// ------------------------------ Assemblies -----------------------------------
// -----------------------------------------------------------------------------

// -------------------- Module: top_case --------------------
module top_case() {
  difference() {
    union() {
      outer_shape_top();
      top_insert_support();
      upper_gasket_taps();
    }
    power_switch_overhang_cutout(delta = clear_switch_mm);
    keycaps_cutout();
    top_plate_decor_cutout();
    top_plate_decor_lines_cutout();
    controller_cutout();
    usb_c_cutout_position();
    case_rim(rim_clear);
    //trrs_cutout();
  }
}

// -------------------- Module: bottom_case --------------------
module bottom_case() {
  difference() {
    union() {
      outer_shape_bottom();
      lower_gasket_taps();
      lower_gasket_taps_rims();
      power_body_support();
      case_rim();
      bottom_screw_support();
    }
    reset_cutout(0.2);
    bottom_screw_holes();
    pwr_switch_slider_cutout(delta = clear_switch_mm);
    power_switch_overhang_cutout(delta = clear_switch_mm);
    usb_c_cutout_position();
    //trrs_cutout();
  }
}

// -------------------- Module: switchplate foam --------------------
module switchplate_foam() {
  difference() {
    union() {
      extrude_layer(L_gasket_supports, z = z_switchplate_foam, h = switch_plate_foam_thickness);
      difference() {
        extrude_layer(L_switchplate_outline, z = z_switchplate_foam, h = switch_plate_foam_thickness);
        extrude_layer(L_switches, z = z_switchplate_foam, h = switch_plate_foam_thickness, delta = 0.3);
      }
    }
    extrude_layer(L_gasket_supports_rim, z = bottom_thickness + kailh_sockets_thickness + bottom_gap + fr4_thickness,
                  h = switch_plate_foam_thickness, delta = 0.5);
  }
}

// -------------------- Module: rubber feet --------------------
module rubber_feet() {
  hollow_delta = (hollow_diameter - screw_marker_diameter) / 2;
  insert_delta = (head_diameter - screw_marker_diameter) / 2;
  foot_delta = (head_diameter + 2 - screw_marker_diameter) / 2;
  difference() {
    union() {
      extrude_layer(L_screw_markers, h = insert_height, delta = insert_delta);
      extrude_layer(L_screw_markers, z = -foot_height, h = foot_height, delta = foot_delta);
    }
    extrude_layer(L_screw_markers, z = -foot_height, h = foot_height + insert_height, delta = hollow_delta);
  }
}

// -----------------------------------------------------------------------------
// --------------------------- Optional Tent Support ---------------------------
// -----------------------------------------------------------------------------
// Render by setting PART = "tent"
// Note: Changing tenting_angle requires adjusting tent_lowering.

// ---- Tenting Parameters ----
tenting_angle = 7;
tent_base_thickness = 0;
tent_support_base_thickness = 0.0001;
tent_support_base_width = 10;
tent_support_wall_thickness = 1.5;
tent_support_wall_height = 3;
tent_clearance = 0.2;
tent_lowering = 3.0;

// Outline (uses main PCB outline layer) expanded by case wall_thickness
module tent_case_outline() {
  offset(delta = 0) import(file = DXF, layer = L_outer_shape);
}

module tent_base_plate() {
  linear_extrude(tent_base_thickness) projection() rotate([ 0, -tenting_angle, 0 ]) linear_extrude(0.0001)
      offset(delta = tent_clearance + tent_support_wall_thickness) tent_case_outline();
}

module tent_support_base() {
  linear_extrude(tent_support_base_thickness) difference() {
    offset(delta = tent_clearance + tent_support_wall_thickness) tent_case_outline();
    offset(delta = -tent_support_base_width) tent_case_outline();
  }
}

module tent_support_walls() {
  translate([ 0, 0, tent_support_base_thickness ]) linear_extrude(tent_support_wall_height) difference() {
    offset(delta = tent_clearance + tent_support_wall_thickness) tent_case_outline();
    offset(delta = tent_clearance) tent_case_outline();
  }
}

module tent_support() {
  translate([ 0, 0, tent_base_thickness ]) union() {
    translate([ 0, 0, tent_support_base_thickness - tent_lowering ]) rotate([ 0, -tenting_angle, 0 ]) union() {
      tent_support_base();
      tent_support_walls();
    }

    difference() {
      linear_extrude() projection() rotate([ 0, -tenting_angle, 0 ]) linear_extrude(0.0001) projection()
          tent_support_base();

      translate([ 0, 0, tent_support_base_thickness - tent_lowering ]) rotate([ 0, -tenting_angle, 0 ]) linear_extrude()
          offset(delta = 100) projection() tent_support_base();
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
EXPLODE = 10;

// -------------------- Module: build --------------------
module build() {
  if (PART == "exploded") {
    translate([ 0, 0, EXPLODE ]) top_case();
    translate([ 0, 0, -EXPLODE ]) switchplate_foam();
    translate([ 0, 0, -2 * EXPLODE ]) power_switch_slider();
    translate([ 0, 0, -2 * EXPLODE ]) reset_switch_button();
    translate([ 0, 0, -3 * EXPLODE ]) bottom_case();
    translate([ 0, 0, -4 * EXPLODE ]) rubber_feet();
  } else if (PART == "top_case")
    top_case();
  else if (PART == "switch_plate_foam")
    switchplate_foam();
  else if (PART == "power_switch_slider")
    power_switch_slider();
  else if (PART == "reset_switch_button")
    reset_switch_button();
  else if (PART == "bottom_case")
    bottom_case();
  else if (PART == "tent")
    tent();
  else if (PART == "rubber_feet")
    rubber_feet();
  else
    echo(str("Unknown PART: ", PART));
}

build();
