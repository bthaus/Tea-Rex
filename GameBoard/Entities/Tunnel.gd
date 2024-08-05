extends BaseEntity
class_name Tunnel

func trigger_minion(m:Monster):
	var hidden=HiddenStatusEffect.new()
	hidden.register(m)
	pass;
func on_cell_left(m:Monster):
	m.remove_status_effect(StatusEffect.Name.HIDDEN)	
	pass;
