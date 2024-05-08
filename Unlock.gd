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
	$Sprite2D/AnimatedSprite2D.play("default")
	var name;
	var desc;
	if card.card is SpecialCard:
		name=Stats.getStringFromSpecialCardEnum(card.card.cardName)
		desc=Stats.getBigDescription(name)
		name=name.to_lower().capitalize();
		
	if card.card is BlockCard:
		var n=Stats.TurretExtension.find_key(card.card.block.extension);
		name=Stats.getName(n)
		desc=Stats.getBigDescription(n)
	$Title.text=name+" unlocked!"
	$desc.text=desc;
	create_tween().tween_property(self,"modulate",Color(1,1,1,1),1).set_ease(Tween.EASE_IN_OUT)
	pass # Replace with function body.
static func create(card:Card):
	var t=load("res://Unlockable.tscn").instantiate()
	t.card=card
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
	
	card.get_child(0).mouse_filter=2
	
	pass # Replace with function body.


func _on_button_pressed():
	card.reparent(GameState.gameState.hand)
	card.get_child(0).mouse_filter=0
	card.scale=Vector2(1,1)
	$Button.mouse_filter=2
	
	create_tween().tween_property(self,"modulate",Color(0,0,0,0),2)
	create_tween().tween_callback(queue_free).set_delay(2)
	if done!=null:done.call()
	pass # Replace with function body.
