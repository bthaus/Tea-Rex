extends ItemList
var gamestate:GameState
@export var menu:Node2D;
# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate=GameState.gameState
	gamestate.level_up.connect(refreshlist)
	refresh()	
	pass # Replace with function body.

func refreshlist(name):
	refresh()	
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func refresh():
	clear()
	for a in Stats.TurretColor.keys():
		if a!="GREY":
			add_item(Stats.getDescription(a),load("res://Assets/Turrets/Bases/"+a+"_base.png"))
	
	for e in gamestate.unlockedExtensions:
		if e == 1: continue
		var string=Stats.TurretExtension.keys()[e-1]
		var text=load("res://Assets/MenuItems/"+string+"_menu.png")
		add_item(Stats.getDescription(string), text )
	for e in gamestate.unlockedSpecialCards:
		var string=Stats.SpecialCards.keys()[e-1]
		add_item(Stats.getDescription(string),load("res://Assets/MenuItems/"+string+"_menu.png"))
		
		
	pass;

func _on_menu_state_propagation(gamestate):
	self.gamestate=gamestate
	gamestate.level_up.connect(refreshlist)
	pass # Replace with function body.
