extends TurretBaseMod
class_name StackIncreaseMod
static var called
func before_game_start(color:Turret.Hue):
	if called:return
	called=true
	GameState.gameState.gameBoard.increase_max_stacks(color,1)
	super(color)
	pass
