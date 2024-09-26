extends Sprite2D
class_name CardCore
@export var phase:GameState.GamePhase
@export var soundeffect:AudioStream
@export var turn_sound_effect:AudioStream
@export var discardable=true;
@export var discard_effect:ShaderMaterial
@export var animated_discard=false;
@export var ditch_effect=preload("res://shaders/Ressources/discard_effect.tres")
var discard_done:Callable
var gameState
var player=AudioStreamPlayer.new()
var done:Callable
var holder:Card
func _random_seed(mat:ShaderMaterial):
	randomize()
	var noise=mat.get_shader_parameter("noise") as NoiseTexture2D
	if noise!=null:
		var noise_text=noise.get_noise() as FastNoiseLite
		noise_text.seed=randi_range(0,500)
		mat.set_shader_parameter("noise",noise)
			
	pass;
func _ready() -> void:
	add_child(player)
	if discard_effect!=null:
		discard_effect=discard_effect.duplicate()
		_random_seed(discard_effect)
		
	if ditch_effect!=null:
		ditch_effect=ditch_effect.duplicate()
		_random_seed(ditch_effect)
	gameState=GameState.gameState
	gameState.start_combat_phase.connect(on_battle_phase_started)
	gameState.start_build_phase.connect(on_build_phase_started)
	
	gameState.start_combat_phase.connect(toggle_shine)
	gameState.start_build_phase.connect(toggle_shine)
	
	#var mat=holder.shine.material as ShaderMaterial
	#var shine_wait_cylces_rand=randi_range(3,8)
	#mat.set_shader_parameter("wait_cycles",shine_wait_cylces_rand)
	toggle_shine()
	pass;

func toggle_shine():
	if !util.valid(holder):return
	var mat=holder.shine.material as ShaderMaterial
	mat.set_shader_parameter("active",isPhaseValid())
	pass;
func on_battle_phase_started():
	
	pass;
	
func on_build_phase_started():
	
	pass;		
func select(done:Callable):
	self.done=done
	pass;
func on_click():
	
	pass;	
func on_drop():
	
	pass;	
	
func _trigger_turn_effect():
	if turn_sound_effect!=null:
		player.stream=turn_sound_effect
		player.play(0)
	pass
	
func _trigger_play_effect():
	pass;
	
func on_hover():
	pass;		
func on_unhover():
	pass;
	
func interrupt():
	pass
	
func get_text():
	return texture
	
	
func on_discard(discard_done:Callable):
	self.discard_done=discard_done
	if animated_discard:return
	on_discard_done()
	pass
func on_ditched(ditch_done:Callable):
	var tw= create_tween()
	material=ditch_effect
	tw.tween_method(_set_param.bind("dissolve_value",material),1.0,0.0,2);
	tw.finished.connect(ditch_done)
	pass;
func _set_param(tweenval:float,paramname,mat:ShaderMaterial):
	print(tweenval)
	mat.set_shader_parameter(paramname,tweenval)
	pass;	
		
func addKill():
	pass ;
	
func addDamage(damage):
	pass ;
func isPhaseValid() -> bool:
	return gameState.phase == phase||phase == GameState.GamePhase.BOTH
	
func get_mouse_pos():
	var screen_mouse_position = get_viewport().get_mouse_position() # Get the mouse position on the screen
	# Convert it to world coordinates
	var mouse_pos = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse() * screen_mouse_position
	return mouse_pos	

func on_discard_done():
	discard_done.call()
	pass;
