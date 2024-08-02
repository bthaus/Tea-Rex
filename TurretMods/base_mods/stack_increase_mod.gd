extends TurretBaseMod
class_name StackIncreaseMod

func initialise(core:TurretCore):
	super(core)
	core.max_stacks+=1
	pass;
