extends TurretBaseMod
class_name AirBlockMod
static var called=false
func before_game_start(color:Turret.Hue):
	if called:return
	called=true
	GameState.gameState.gameBoard.register_blocking_color(Monster.MonsterMovingType.AIR,color)
	super(color)
	
