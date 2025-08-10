// ===== USER PARAMETERS =====
total_height = 20;       // Total height INCLUDING bevel
bevel_height = 2;        // Height of beveled top section
bevel_steps = 10;        // Number of steps in bevel
top_offset = -bevel_height;         // Total offset at the top (negative = shrink)
$fn = 20;                // Smoothness for curves
dxf_file = "sweep-bling-mx__bottom-Edge_Cuts.dxf";  // Your DXF shape

// ===== BASE SHAPE =====
module base_shape() {
    import(dxf_file);
}

// ===== MAIN STRAIGHT BODY (below bevel) =====
module straight_body() {
    linear_extrude(height = total_height - bevel_height)
        base_shape();
}

// ===== LINEAR BEVEL MODULE =====
module linear_bevel() {
    for (i = [0 : bevel_steps - 1]) {
        t = i / (bevel_steps - 1);                  // 0 to 1
        offset_amt = t * top_offset;                // interpolate offset
        zpos = i * bevel_height / bevel_steps;      // step Z height

        translate([0, 0, zpos])
            linear_extrude(height = bevel_height / bevel_steps)
                offset(delta = offset_amt)
                    base_shape();
    }
}

// ===== COMBINED FINAL MODEL =====
module beveled_model() {
    union() {
        straight_body();

        // Position bevel on top of body
        translate([0, 0, total_height - bevel_height])
            linear_bevel();
    }
}

// ===== RENDER =====
beveled_model();
