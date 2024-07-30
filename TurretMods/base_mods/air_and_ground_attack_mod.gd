extends TurretBaseMod
class_name AirAndGroundAttackMod

func on_turret_build(core:TurretCore):
	core.targetable_enemy_types.append(Monster.MonsterMovingType.AIR)
	super(core)
	pass
