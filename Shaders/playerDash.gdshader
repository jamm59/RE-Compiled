shader_type canvas_item;
render_mode blend_mix;
uniform int particles_anim_h_frames;
uniform int particles_anim_v_frames;
uniform bool particles_anim_loop;
uniform bool facing_left;

void vertex() {
    float h_frames = float(particles_anim_h_frames);
    float v_frames = float(particles_anim_v_frames);
    VERTEX.xy /= vec2(h_frames, v_frames);
    float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
    float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
    if (!particles_anim_loop) {
        particle_frame = clamp(particle_frame, 0.0, particle_total_frames - 1.0);
    } else {
        particle_frame = mod(particle_frame, particle_total_frames);
    }
    vec2 scale_uv = UV / vec2(h_frames, v_frames);
    UV = scale_uv + vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);

    if (facing_left) {
        UV.x = 1.0 - UV.x;
    }

}
