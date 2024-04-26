extends ItemList
@export var gamestate:GameState

# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate.level_up.connect(refreshlist)
	for a in Stats.TurretColor.keys():
		if a!="GREY":
			add_item(a,load("res://Assets/Turrets/Bases/"+a+"_base.png"))
	pass # Replace with function body.

func refreshlist(unlocked,base):
	
	var name=Stats.TurretExtension.keys()[unlocked-1]
	add_item(name,load("res://Assets/Turrets/Bases/"+name+"_base.png"))
		
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_button_pressed():
	visible=false;
	get_parent().get_node("StartButton").visible=true;
	get_parent().get_node("UnlockedButton").visible=true
	
	pass # Replace with function body.
