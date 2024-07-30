extends TurretBaseMod
class_name AirAttackMod

func initialise(core:TurretCore):
	core.targetable_enemy_types.clear()
	core.targetable_enemy_types.append(Monster.MonsterMovingType.AIR)
	super(core)
	pass
