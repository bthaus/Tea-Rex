shader_type canvas_item;
uniform sampler2D text_map;

uniform float scale_factor = 0.5; // Adjust how much smaller the edges should be



uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;
uniform float speed = 1.0;
uniform vec2 dissolve_movement_direction = vec2(1.0, 1.0); // Direction to move the dissolve texture
uniform sampler2D texture2;
uniform vec2 second_dissolve_directoin=vec2(-1.2,-1.4);
void fragment(){
	vec2 uv = FRAGCOORD.xy; // Use the fragment coordinates directly
    vec2 center = vec2(0.5, 0.5); // Center of the texture, assuming it's 0 to 1 range

    // Calculate the distance from the center
    float distance = distance(uv, center);

    // Scale based on distance
    float scale = smoothstep(0.0, 1.0, distance * scale_factor);

    // Adjust UV coordinates
    vec2 scaled_uv = uv * (1.0 - scale);
	
	
	
    // Create animated UVs and ensure they wrap properly
    vec2 animated_uv = fract(UV + TIME * speed * dissolve_movement_direction);
	
    vec4 main_texture = texture(TEXTURE, UV);
	
    vec4 noise_texture = texture(dissolve_texture, animated_uv);
	
	
	// This is needed to avoid keeping a small burn_color dot with dissolve being 0 or 1
	float burn_size_step = burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
	float threshold = smoothstep(noise_texture.x - burn_size_step, noise_texture.x, dissolve_value);
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);
	
	COLOR.a *= threshold;
	COLOR.rgb = mix(burn_color.rgb, main_texture.rgb, border);
}
