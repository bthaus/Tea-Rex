extends TurretBaseMod
class_name AirAndGroundAttackMod

func initialise(core:TurretCore):
	core.targetable_enemy_types.append(Monster.MonsterMovingType.AIR)
	super(core)
	pass
