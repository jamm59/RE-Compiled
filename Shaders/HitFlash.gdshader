shader_type canvas_item;

uniform bool active = false;
uniform bool black_white = false;

uniform float tolerance : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec4 prev_color : source_color = vec4(1.0);
uniform vec4 new_color : source_color = vec4(1.0);

void fragment() {
    // Fetch the texture color at the current fragment's UV coordinates
    vec4 texture_color = texture(TEXTURE, UV);

    // Initialize output color with the base texture color
    vec4 output_color = texture_color;

    // Apply the "active" condition: Replace the color with white
    if (active) {
        vec4 white_color = vec4(0.969, 0.969, 0.969, texture_color.a);
        output_color = white_color;
    }

    // Apply black-and-white transformation
    if (black_white) {
        output_color.rgb = COLOR.ggg; // Average the RGB channels
    }

    // Blend colors based on distance between prev_color and the texture color
	if (!active){
	    float color_distance = distance(prev_color, texture_color);
	    if (color_distance <= tolerance) { // Ensure blending occurs within tolerance range
	        vec4 blended_color = mix(new_color, texture_color, color_distance / tolerance);
	        blended_color.a = texture_color.a; // Preserve the alpha channel
	        output_color = blended_color;
	    }
	}

    // Set the final fragment color
    COLOR = output_color;
}