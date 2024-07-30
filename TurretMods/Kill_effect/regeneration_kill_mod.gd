extends TurretBaseMod
class_name RegenerateKillMod

func on_kill(m:Monster):
	var hp=m.maxHp
	GameState.gameState.changeHealth(hp/REGENERATION_DIVISOR)
	super(m)
	pass;
