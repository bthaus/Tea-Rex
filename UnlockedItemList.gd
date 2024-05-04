extends ItemList
var gamestate:GameState
@export var menu:Node2D;
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	for a in Stats.TurretColor.keys():
		if a!="GREY":
			add_item(a,load("res://Assets/Turrets/Bases/"+a+"_base.png"))
			
	pass # Replace with function body.

func refreshlist(name,type):
	
	
	add_item(name,load("res://Assets/MenuItems/"+name+"_menu.png"))
		
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass



func _on_menu_state_propagation(gamestate):
	self.gamestate=gamestate
	gamestate.level_up.connect(refreshlist)
	pass # Replace with function body.
