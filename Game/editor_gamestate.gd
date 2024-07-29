extends GameState
class_name EditorGameState


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	ui.hide()
	hand.hide()
	remove_child($Camera2D)
	
	pass # Replace with function body.

func startBattlePhase():
	
	return
func start_wave(wave):
	
	pass;
func startBuildPhase():
	pass	
func startGame():
	portals.clear()
	spawners.clear()
	collisionReference.initialise(self,map_dto)
	for entity in map_dto.entities:
		entity.get_object().place_on_board(board)
	for s in spawners:
		s.refresh_path()
		
	pass;		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
