extends ModProduce


func trigger_minion(monster:Monster):
	if monster.monstertype==Monster.Monstertype.BOSS:return
	monster.hit(Turret.Hue.RED,monster.hp*2)
	super(monster)
	pass;
