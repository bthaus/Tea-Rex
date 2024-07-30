extends TurretBaseMod
class_name WallhackMod

func on_turret_build(core:TurretCore):
	core.wall_hack=true
	super(core)
	pass
