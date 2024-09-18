extends GameObject2D
class_name MonsterCore
signal death_animation_done
## The speed the monster moves at. Clamped at 0 and 9999
@export var speed:MonsterFactory.MonsterSpeed = MonsterFactory.MonsterSpeed.Normal :
	set(val):
		speed=clamp(val,0,9999);
## Max Hp of the monster.		
@export var hp:MonsterFactory.MonsterHP =MonsterFactory.MonsterHP.Normal ;
## Damage it deals to the playerbase
@export var damage:MonsterFactory.MonsterDamage = MonsterFactory.MonsterDamage.Normal;
## The time between each special attack of the monster. Ignored if no special attack is present. 
@export var special_cooldown:MonsterFactory.MonsterCooldown=MonsterFactory.MonsterCooldown.Normal		
## Used to differentiate between bosses and regular minions
@export var type:Monster.Monstertype
## Determines where this monster can move. If it has no moving type it cant move. 
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
func _ready():
	$Animation.animation_finished.connect(func():
		$Animation.play("move"))
func on_move():
	
	pass;
func on_death():
	holder.monster_died.emit(holder)
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
	#$Animation.play("hit")
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


