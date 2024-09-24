shader_type canvas_item;
uniform sampler2D texture2;
uniform sampler2D texture1;
uniform sampler2D colorTexture;
uniform vec2 scroll1=vec2(0.1,0.1);
uniform vec2 scroll2=vec2(0.2,0.2);

void fragment() {
	float t1=texture(texture1,UV+scroll1*TIME).r;
	float t2=texture(texture2,UV+scroll2*TIME).r;
	float energy=t1*t2;
	//vec4 color=texture(colorTexture,vec2(energy));
	COLOR=vec4(energy,energy,energy,1);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
