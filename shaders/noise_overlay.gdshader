shader_type canvas_item;

uniform sampler2D noise_texx1;
uniform sampler2D noise_texx2;
uniform vec4 color_texture ;
uniform sampler2D alpha_texture;
uniform vec2 dir1;
uniform vec2 dir2;

void fragment(){
    vec4 main_texture = texture(TEXTURE, UV);
    float dissolve_value = mix(0.5, 0.6, sin(TIME));
    float noise_texture1 = texture(noise_texx1, UV + dir1 * TIME).r;
    float noise_texture2 = texture(noise_texx1, UV + dir2 * TIME).r; //texture(noise_texx1, UV+vec2(10.0*sin(TIME/5.0),10.0*cos(TIME/5.0))/5.0);
	vec2 energyx = vec2(noise_texture1 * noise_texture2);
    vec4 noise_texture = texture(alpha_texture,energyx);
    vec4 mult = (noise_texture*1.0);
	//vec4 color_texture1 = texture(color_texture,UV);
    main_texture = mult * color_texture;
    main_texture.a *= texture(TEXTURE,UV).a;
	
    COLOR = main_texture;
}