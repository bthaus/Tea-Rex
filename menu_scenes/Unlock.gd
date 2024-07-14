extends GameObject2D
class_name Unlockable
var card;
var counter=500;
static var z_counter=0;
var done;
# Called when the node enters the scene tree for the first time.
func _ready():
	z_index=z_index+z_counter
	z_counter=z_counter+3
	$Lock.play()
	$sound.stream=Sounds.unlock
	$Button.z_index=counter
	counter=counter-1
	$Sprite2D/AnimatedSprite2D.play("default")
	var name;
	var desc;

	if card.card is BlockCard:
		var n=Stats.TurretExtension.find_key(card.card.block.extension);
		name="blockcard"
		desc="duh"
		
	$Title.text=name+" unlocked!"	
	if name=="Updraw":
		$Title.text=name+" received!"	
	$desc.text=desc;
	create_tween().tween_property(self,"modulate",Color(1,1,1,1),1).set_ease(Tween.EASE_IN_OUT)
	pass # Replace with function body.
static func create(card:Card,done:Callable=func():print("nothing")):
	var t=load("res://menu_scenes/Unlockable.tscn").instantiate()
	t.card=card
	t.done=done
	if card.card is BlockCard:
		t.get_node("Card").texture=load("res://Assets/Cards/Testcard_"+Stats.getStringFromEnumLowercase(card.card.block.color)+".png")
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
	$Button.disabled=false;
	
	card.get_child(0).mouse_filter=2
	
	pass # Replace with function body.


func _on_button_pressed():
	card.reparent(GameState.gameState.hand)
	card.get_child(0).mouse_filter=0
	card.scale=Vector2(1,1)
	$Button.mouse_filter=2
	
	create_tween().tween_property(self,"modulate",Color(0,0,0,0),2)
	create_tween().tween_callback(queue_free).set_delay(2)
	if done.is_valid() and not done.is_null() :done.call()
	pass # Replace with function body.
