extends Sprite2D
class_name ShieldSprite
var mat=material as ShaderMaterial
func set_dissolve_state(val:float):
	material.set_shader_parameter("dissolve_value",val)
	pass;
