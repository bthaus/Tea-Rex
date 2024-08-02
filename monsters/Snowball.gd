extends Projectile


func hit_cell():
	var pos=get_map()
	if last_hit_cell==pos:return
	var moornot=GameState.gameState.collisionReference.get_turret_from_global(get_global())
	if moornot!=null:
		last_hit_cell=pos
		var debuff=FreezeTowerDebuff.new()
		debuff.register(moornot)
		remove()
	pass;	
