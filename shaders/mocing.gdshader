shader_type canvas_item;
uniform sampler2D text1:repeat_enable;
void fragment(){
	vec4 t1=texture(text1,UV + vec2(0.1,0.1)*TIME);
	COLOR=t1;
	
}