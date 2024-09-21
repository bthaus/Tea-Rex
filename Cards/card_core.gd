extends Sprite2D
class_name CardCore
@export var phase:GameState.GamePhase
@export var soundeffect:AudioStream
@export var turn_sound_effect:AudioStream
@export var discardable=true;
var gameState
var player=AudioStreamPlayer.new()
var done:Callable
func _ready() -> void:
	add_child(player)
	gameState=GameState.gameState
	pass;
func select(done:Callable):
	self.done=done
	pass;
	
func _trigger_turn_effect():
	if turn_sound_effect!=null:
		player.stream=turn_sound_effect
		player.play(0)
	pass;
	
func _trigger_play_effect():
	pass;
	
func on_hover():
	pass;		

func interrupt():
	pass
	
func get_text():
	return texture
	
	
func on_discard():
	pass
	
func addKill():
	pass ;
	
func addDamage(damage):
	pass ;
func isPhaseValid() -> bool:
	return gameState.phase == phase||phase == GameState.GamePhase.BOTH||gameState.phase == GameState.GamePhase.BOTH
	
func get_mouse_pos():
	var screen_mouse_position = get_viewport().get_mouse_position() # Get the mouse position on the screen
	# Convert it to world coordinates
	var mouse_pos = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse() * screen_mouse_position
	return mouse_pos	
