extends GameObject2D
class_name TurretCore
var level = 1;
var barrels = []
var bullets = []
var turret_mods = []

var type: Turret.Hue = Turret.Hue.BLUE
var extension: Turret.Extension = Turret.Extension.DEFAULT

var onCooldown = false;
var cooldown_reduction_factor=1
var direction: Vector2;

var functional=true
var action_speed=1:
	set(value):
		action_speed=clamp(value,0,10)

@export_range(0, 10) var speed: float = 1;
@export_range(0, 10) var cooldown: float = 1;
@export_range(0, 10) var damage: float = 1;
@export_range(0, 10) var turretRange: int = 1;
@export var penetrations: int = 1;
@export var instantHit: bool = false;
@export var range_precision = 24
@export var projectile_precision = 1
@export var wall_hack=false
@export var damage_types:Array[GameplayConstants.DamageTypes]=[GameplayConstants.DamageTypes.NORMAL]
@export var targetable_enemy_types: Array[Monster.MonsterMovingType] = [Monster.MonsterMovingType.GROUND]

var cdt;
var trueRangeSquared;

var speedfactor = 1;
var damagefactor = 1;
var cooldownfactor = 1;

var stacks = 1
var max_stacks=GameplayConstants.MAX_TURRET_LEVEL
var lightamount = 1.5;
var killcount = 0;
var damagedealt = 0
var average_minions_hit = 1

static var camera;

var baseinstantHit = false;
var placed

var coveredCells = []
var recentCells = []
var mapPosition;
var referenceCells = []
var path_cells = []


var holder;
var id;
static var counter = 0;
static var collisionReference: CollisionReference;
var waitingDelayed = false;
static var inhandTurrets = []

var ref_proj: Projectile;

var minions;
var target;
var buildup = 0;
var targetposition;

func get_average_damage():
	var val = damage * damagefactor / (cooldown * cooldownfactor) * average_minions_hit
	return 1 # val
	pass ;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	
	barrels = get_children()
	#for b in barrels:
		#remove_child(b)
	pass # Replace with function body.
	
func clear_path():
	path_cells.clear()
	pass ;
func register_path(cell):
	path_cells.append(cell)
	pass ;
func add_damage_type(damage_type:GameplayConstants.DamageTypes):
	if damage_types.has(damage_type):return
	damage_types.append(damage_type)
	pass;
func setupCollision(clearing):
	if GameState.gameState==null:return
	if collisionReference == null:
		collisionReference = GameState.gameState.collisionReference

	#if not placed: return ;
	
	if clearing: coveredCells.clear()
	recentCells.clear()
	coveredCells.append_array(getReferences(referenceCells))

	pass ;
func getReferences(cells):
	return collisionReference.getCellReferences(global_position, turretRange, self, cells,wall_hack)
	pass ;
func setUpTower(holder):
	self.holder = holder
	
	if placed: minions = GameState.gameState.minions
	
	trueRangeSquared = turretRange * GameboardConstants.TILE_SIZE + GameboardConstants.TILE_SIZE
	trueRangeSquared = trueRangeSquared * trueRangeSquared;
	
	if ref_proj == null and placed: ref_proj = Projectile.create(type, damage * damagefactor, speed * speedfactor, self, extension, penetrations);
	if ref_proj!=null: ref_proj.visible = false;

	for mod in turret_mods:
		mod.initialise(self)
		#if not placed:
			#mod.visual.visible=false
	setLevel(stacks)	
	setupCollision(true)
	after_built()
	pass ;
func on_destroy():
	for mod in turret_mods:
		mod.remove()
	pass;	
func after_built():
	
	pass ;
func reduceCooldown(delta):

	if not onCooldown:
		return ;
	holder.reduceCooldown(delta)
	cdt = cdt - delta*cooldown_reduction_factor;
	if cdt < 0:
		onCooldown = false;
	pass

var waitingForMinions = false;
func on_target_found(monster: Monster):
	monster.status_changed.connect(checkTarget)
	monster.monster_died.connect(func():
		target=null)
	monster.reached_spawn.connect(func(m): on_target_lost())
	pass ;
	
func on_hit(monster: Monster, damage, color: Turret.Hue, killed, projectile: Projectile):
	if killed: on_target_killed(monster)
	addDamage(damage)
	for mod in turret_mods:
		mod.on_hit(projectile,monster)
	pass ;
func on_projectile_removed(projectile: Projectile):
	for mod in turret_mods:
		mod.on_remove(projectile)
	pass ;
func on_target_killed(monster: Monster):
	addKill()
	for mod in turret_mods:
		mod.on_kill(monster)
	pass ;
func on_shoot(projectile: Projectile):
	for mod in turret_mods:
		mod.on_shoot(projectile)
	pass ;
func on_fly(projectile: Projectile):
	for mod in turret_mods:
		mod.on_cell_traversal(projectile)
	pass ;
func on_target_lost():
	
	pass ;
	
func do(delta):
	var children=get_children()
	
	if not functional:return
	delta*=action_speed
	reduceCooldown(delta)
	apply_status_effects(delta)
	if !onCooldown:
		if target != null: checkTarget()
		if target == null: getTarget()
		if ref_proj == null: ref_proj = Projectile.create(type, damage, speed, self, penetrations, extension)
			
	if target != null:
		direction = (target.global_position - holder.global_position).normalized();
		rotation = direction.angle() + PI / 2.0;
	attack(delta)
	pass ;
func searchForMinionsInRecent() -> bool:
	for cell in recentCells:
		if not cell.is_empty():
			target = cell.back()
			if target != null:
				on_target_found(target)
				return true;
			else:
				var erase=[]
				var found=false;
				for m in cell:
					if !util.valid(m):
						erase.append(m)
					else:
						target = m
						on_target_found(target)
						found=true;
				for m in erase:
					cell.erase(m)
				return found			
	return false;
func getTarget():
	
	if minions.get_child_count() == 0:
		return ;
	#check cells where minions have been found recently
	if searchForMinionsInRecent(): return
	
#region search in path
	for cell in path_cells:

		if !cell.is_empty():
			target = cell.back()
			
			if target != null:
				if is_out_of_range(target):
					target = null
					continue
				on_target_found(target)
				if recentCells.find(cell) == - 1:
					recentCells.push_back(cell)
				return ;
			else:
				for m in cell:
					if not is_instance_valid(m):
						cell.erase(m)
					else:
						target = m
						on_target_found(target)
#endregion						
#region search everywhere
	for cell in coveredCells:
		if !cell.is_empty():
			target = cell.back()
			
			if target != null:
				if is_out_of_range(target):
					target = null
					continue
				on_target_found(target)
				if recentCells.find(cell) == - 1:
					recentCells.push_back(cell)
				return ;
			else:
				for m in cell:
					if not is_instance_valid(m):
						cell.erase(m)
					else:
						target = m
						on_target_found(target)
#endregion
	pass ;
func target_override(monster:Monster):
	if target!=null:
		if target.core is MainAttraction:
			return
		on_target_lost()
	target=monster
	on_target_found(target)
	checkTarget()
	
	pass;	
func return_targets(non_select=null):
	if minions.get_child_count() == 0:
		return ;
	var t
	var minions = []
	for cell in coveredCells:
		if !cell.is_empty():
			t = cell.back()
			if t == non_select: continue
			if t != null:
				if is_out_of_range(t):
					t = null
					continue
				minions.append(t)
	return minions
	pass
func do_all(tasks: Array[Callable]):
	for t in tasks:
		t.call()
	pass ;
func checkTarget():
	if !util.valid(target):return
	if is_out_of_range(target):
		print("target lost!")
		target = null;
	if target == null or !is_instance_valid(target):
		on_target_lost()
		
	pass ;

func is_out_of_range(t):
	#tinypfusch to avoid code duplication
	if !targetable_enemy_types.has(t.moving_type):
		return true
	if not t.is_targettable():
		return true;	
	var start=t.global_position
	if !ref_proj.ghost_projectile:
		while start!=global_position:
			start=start.move_toward(global_position,10)
			if GameState.gameState.collisionReference.hit_wall(GameState.board.local_to_map(start)):
				return true	
		
	var distancesquared = global_position - t.global_position
	distancesquared = distancesquared.length_squared()
	return distancesquared > abs(trueRangeSquared)
	pass ;
func is_out_of_range_pos(pos):
	var distancesquared = global_position - pos
	distancesquared = distancesquared.length_squared()
	return distancesquared > abs(trueRangeSquared)
	pass ;
func attack(delta):
	if target != null:
		if not onCooldown:
			shoot(target);
		
	pass ;
func shoot(target):
	var barrels = getBarrels();
	var b = barrels[0]
	var bp = b.get_child(0).global_position;
	var shot = get_projectile()
	shot.global_position = global_position
	shot.shoot(target);
	on_shoot(shot)
	startCooldown()
	return shot
	pass ;
func get_projectile():
	return Projectile.create(type, damage * damagefactor, speed * speedfactor, self, penetrations, extension);

	pass ;
func startCooldown():
	var time = cooldown * cooldownfactor
	cdt = time;
	onCooldown = true;
	pass ;
func reset_cooldown():
	onCooldown=false
	pass;	
func showRangeOutline():
	if placed:
		for c in referenceCells:
			var pos = collisionReference.getGlobalFromReference(c)
			GameState.gameState.gameBoard.show_outline(pos)
				
	else:
		var showCells = []
		holder.unregister_turret()
		getReferences(showCells)
		referenceCells = showCells
		holder.register_turret()
		for c in showCells:
			var pos = collisionReference.getGlobalFromReference(c)
			GameState.gameState.gameBoard.show_outline(pos)
	pass ;

func addKill():
	killcount = killcount + 1;
	pass ;
func addDamage(Damage):
	damagedealt = damagedealt + Damage;
	pass ;
	
func setLevel(lvl: int):
	stacks=lvl
	for mod:TurretBaseMod in turret_mods:
		mod.on_level_up(lvl)
	damagefactor=lvl	
	#var children = barrels
	#level = lvl;
	#for i in range(lvl):
		#if i < children.size():
			#add_child(children[i])
			#children[i].visible = true;

	pass ;
	
func getBarrels():
	var children = get_children()
	var ret = []
	for i in range(level):
		if i < children.size():
			ret.append(children[i])
	return ret;
# Called every frame. 'delta' is the elapsed time since the previous frame.
