shader_type canvas_item;
uniform vec4 replace_color = vec4(0.57, 0.245, 0.325, 1.0); // #D84040
bool is_brown(vec3 color) {
    float r = color.r;
    float g = color.g;
    float b = color.b;

    // Brown detection: Red is dominant, green is moderate, blue is low
    bool is_brownish = (r > 0.2 && g > 0.2 && b < 0.2) && (r > g && g > b);
    
    return is_brownish;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (is_brown(tex_color.rgb)) {
        tex_color = replace_color; // Completely replace brown with new color
    }

    COLOR = tex_color;
}
