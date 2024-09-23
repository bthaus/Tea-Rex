extends Sprite2D
class_name ShieldSprite
var mat=material as ShaderMaterial
func set_dissolve_state(val:float):
	material.set_shader_parameter("dissolve_value",val)
	pass;
var val=0	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"scroll_up"):
		val+=delta
		set_dissolve_state(val)
	if Input.is_action_just_pressed(&"scroll_down"):
		val-=delta
		set_dissolve_state(val)	
