extends CanvasLayer
@export var gameState:GameState


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_menu") and not Card.isCardSelected:
		$MainMenu.visible=!$MainMenu.visible
		
	pass


func _on_start_button_pressed():
	$MainMenu/Banner.visible=false;
	gameState.get_node("Spawner").visible=true;
	gameState.get_node("GameBoard").visible=true;
	$UI.visible=true;
	$MainMenu.visible=false;
	$MainMenu/StartButton.text="continue"
	pass # Replace with function body.


func _on_unlocked_button_pressed():
	$MainMenu/StartButton.visible=false;
	$MainMenu/UnlockedButton.visible=false;
	$MainMenu/UnlockedItems.visible=true;
	pass # Replace with function body.
