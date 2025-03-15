shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float red = COLOR.r;
	float green = COLOR.g;
	float blue = COLOR.b;

	// Find the maximum value among the color components.
	float max_color = max(red, max(green, blue));
	COLOR.rgb = COLOR.ggg;
	//if (max_color == red) {
	    //COLOR.rgb = COLOR.rrr;
	//} else if (max_color == green) {
	    //COLOR.rgb = COLOR.ggg;
	//} else if (max_color == blue) {
	    //COLOR.rgb = COLOR.bbb;
	//}


	//COLOR.rbg = COLOR.bbb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
