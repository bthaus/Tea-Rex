extends GameObject2D
class_name MonsterCore
signal death_animation_done
@export var speed:MonsterFactory.MonsterSpeed = MonsterFactory.MonsterSpeed.Normal :
	set(val):
		speed=clamp(val,0,9999);
@export var hp:MonsterFactory.MonsterHP =MonsterFactory.MonsterHP.Normal ;
@export var damage:MonsterFactory.MonsterDamage = MonsterFactory.MonsterDamage.Normal;

@export var special_cooldown:MonsterFactory.MonsterCooldown=MonsterFactory.MonsterCooldown.Normal		
@export var type:Monster.Monstertype
@export var movable_cells:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.GROUND]
var cooldown=special_cooldown
var name_id
var holder:Monster
var dodge_chance=0
var died=false
# Called when the node enters the scene tree for the first time.
func change_status_effect():
	holder.status_changed.emit()
	pass;

func on_move():
	
	pass;
func on_death():
	$Animation.play("die")
	$Animation.animation_finished.connect(func():death_animation_done.emit())
	pass;
func on_spawn():
	cooldown=special_cooldown	
	$Animation.play("spawn")
	pass;
func on_cell_traversal():
	
	pass;
func on_hit():
	$Animation.play("hit")
	pass;

func do(delta):
	if cooldown<0:
		cooldown=special_cooldown
		do_special()
	cooldown-=delta	
	apply_status_effects(delta)
	pass;
func do_special():
	
	pass;
func hit(color: Turret.Hue, damage, type="default", noise=true):
	if hp<=0: return false;
	if randi_range(0,100)<dodge_chance:
		print("missed!")
		return
	on_hit()
	hp = hp - damage #* mod;
	if hp <= 0 and not died:
		died = true
		GameState.gameState.collisionReference.removeMonster(self)
		on_death()
		return true;
	return false;


