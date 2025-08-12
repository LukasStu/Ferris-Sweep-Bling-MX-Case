$fn = 100;  
dxf_keys = "keys.dxf";
dxf_outline= "outline.dxf";

h = 3.3;

module keys() {
    translate([0, 0, 0]) {
        linear_extrude(height = h)
            offset(delta = 0.3)
                import(dxf_keys);
    }
}

module outline() {
    translate([0, 0, 0]) {
        linear_extrude(height = h)
            offset(delta = -0.3)
                import(dxf_outline);
    }
}

difference() {
    outline();
    keys();
}