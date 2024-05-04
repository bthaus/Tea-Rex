extends Node2D
class_name Unlockable
var card;
var counter=500;

var done;
# Called when the node enters the scene tree for the first time.
func _ready():
	$Lock.play()
	$sound.stream=Sounds.unlock
	$Button.z_index=counter
	counter=counter-1
	
	pass # Replace with function body.
static func create(card:Card):
	var t=load("res://Unlockable.tscn").instantiate()
	t.card=card
	
	return t;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_lock_animation_finished():
	$Lock.queue_free()
	$Card.queue_free()
	$sound.play()
	add_child(card)
	
	card.get_child(0).mouse_filter=2
	
	pass # Replace with function body.


func _on_button_pressed():
	card.reparent(GameState.gameState.hand)
	card.get_child(0).mouse_filter=0
	card.scale=Vector2(1,1)
	queue_free()
	if done!=null:done.call()
	pass # Replace with function body.
