extends Node2D
class_name TutorialHolder;
enum tutNames {ColorRestriction,NoBlocking, Pathfinding, RotateBlock,UpgradeBlocks,UpgradeBlocks2,Starting,EXP,Information,Outside,Controls}
static var instance=load("res://tutorial_node.tscn").instantiate() as TutorialHolder 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func showTutorial(name:tutNames,gameState:GameState,done:Callable=func():print("nothing happens")):
	var tut= instance.get_node(tutNames.find_key(name)).duplicate()
	tut.done=done;
	if tut.isSeen() or not gameState.showTutorials:
		done.call()
		return false
	gameState.menu.show_tutorial(tut)
	gameState.gameBoard.ignore_input=true;
	
	return true;
	
static func getTutorial(name:tutNames):
	return instance.get_node(tutNames.find_key(name)).duplicate()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_button_toggled(toggled_on):
	GameState.gameState.showTutorials=!toggled_on;
	GameSaver.saveGame(GameState.gameState)
	pass # Replace with function body.


func _on_button_pressed():
	pass # Replace with function body.
