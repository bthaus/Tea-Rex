shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture, filter_linear_mipmap;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment(){
	vec2 distort= SCREEN_UV + texture(TEXTURE,UV).a*0.1*sin(TIME);
	
	vec4 text=texture(SCREEN_TEXTURE,distort);
	COLOR=text;
	
	
	
	
	
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
