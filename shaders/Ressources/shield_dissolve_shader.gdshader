shader_type canvas_item;
uniform sampler2D text_map;

uniform float scale_factor = 0.5; // Adjust how much smaller the edges should be



uniform sampler2D dissolve_texture : source_color,repeat_enable;
uniform sampler2D texture2:repeat_enable;
uniform float dissolve_value : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;
uniform float speed = 1.0;
uniform vec2 dissolve_movement_direction = vec2(1.0, 1.0); // Direction to move the dissolve texture

uniform vec2 second_dissolve_directoin=vec2(-1.2,-1.4);
void fragment(){
	float t1=texture(dissolve_texture,UV+dissolve_movement_direction*TIME*speed).r;
	float t2=texture(texture2,UV+second_dissolve_directoin*TIME*speed).r;
	float energy=t1*t2;
	vec4 energy_texture=vec4(energy,energy,energy,1);
    // Create animated UVs and ensure they wrap properly
    vec2 animated_uv = fract(UV + TIME * speed * dissolve_movement_direction);

    vec4 main_texture = texture(TEXTURE, UV);

    vec4 noise_texture = energy_texture;


	// This is needed to avoid keeping a small burn_color dot with dissolve being 0 or 1
	float burn_size_step = burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
	float threshold = smoothstep(noise_texture.x - burn_size_step, noise_texture.x, dissolve_value);
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);

	COLOR.a *= threshold;
	COLOR.rgb = mix(burn_color.rgb, main_texture.rgb, border);
}
