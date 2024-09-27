extends Sprite2D
class_name ShieldSprite
var mat=material as ShaderMaterial
func set_dissolve_state(val:float):
	material.set_shader_parameter("dissolve_value",val)
	pass;
func shine():
	var mat=get_child(0).material as ShaderMaterial
	var tw=create_tween()
	tw.tween_method(set_param.bind("my_time",mat),0.0,2.0,1)
	tw.finished.connect(set_param.bind(0,"my_time",mat))
	pass;
func set_param(tweenval:float,paramname,mat:ShaderMaterial):
	mat.set_shader_parameter(paramname,tweenval)
	pass;	
