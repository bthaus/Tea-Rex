extends Sprite2D
class_name Base
var level = 1;
var barrels = []

var type: Stats.TurretColor = Stats.TurretColor.BLUE
var extension: Stats.TurretExtension = Stats.TurretExtension.DEFAULT

var onCooldown = false;
var direction: Vector2;

var speed;
var cooldown;
var cdt;
var damage;
var turretRange;
var trueRangeSquared;
var speedfactor = 1;
var damagefactor = 1;
var cooldownfactor = 1;
var stacks = 1
var lightamount = 1.5;
var killcount = 0;
var damagedealt = 0

static var camera;
var instantHit = false;
var baseinstantHit = false;
var placed = true;

var coveredCells = []
var recentCells = []

var on_shoot: Array[Callable] = []
var on_hit: Array[Callable] = []
var on_fly: Array[Callable] = []
var on_target_found: Array[Callable] = []
var on_target_lost: Array[Callable] = []
var on_target_died: Array[Callable] = []
var after_built:Array[Callable] = []

var holder;
var id;
static var counter = 0;
static var collisionReference: CollisionReference;
var waitingDelayed = false;
static var inhandTurrets = []

var projectile;

var mapPosition;
var referenceCells = []

var minions;
var target;
var buildup = 0;
var targetposition;

# Called when the node enters the scene tree for the first time.
func _ready():
	barrels = get_children()
	for b in barrels:
		remove_child(b)
	
	
	pass # Replace with function body.

func setupCollision(clearing):
	if collisionReference == null:
		collisionReference = GameState.gameState.collisionReference

	if not placed: return ;
	
	if clearing: coveredCells.clear()
	recentCells.clear()
	coveredCells.append_array(getReferences(referenceCells))
	
	#if type==Stats.TurretColor.RED and extension==Stats.TurretExtension.DEFAULT:
	#	coveredCells.append_array(collisionReference.getNeighbours(global_position,referenceCells))	
	#else:
	pass ;
func getReferences(cells):
	return collisionReference.getCellReferences(global_position, turretRange, self, cells)
	pass;	
func setUpTower(holder):
	self.holder = holder
	minions = GameState.gameState.get_node("MinionHolder")
	setLevel(stacks)
	instantHit = Stats.getInstantHit(type, extension);
	baseinstantHit = instantHit;
	turretRange = Stats.getRange(type, extension);
	trueRangeSquared = turretRange * Stats.block_size
	trueRangeSquared = trueRangeSquared * trueRangeSquared;
	cooldown = Stats.getCooldown(type, extension);
	damage = Stats.getDamage(type, extension);
	speed = Stats.getMissileSpeed(type, extension);
	if projectile == null: projectile = Projectile.create(type, damage * damagefactor, speed * speedfactor, self, extension);
	projectile.visible = false;
	#if type == Stats.TurretColor.RED:
	#	projectile.scale = Vector2(1, 1)
	#	projectile.z_index = 0;
	#	projectile.visible = placed
	#	projectile.modulate = Color(1, 1, 1, 1)
	#	$AudioStreamPlayer2D.finished.connect(func(): if inRange(): $AudioStreamPlayer2D.play)
	
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y) * stacks
	
	setupCollision(true)
	do_all(after_built)
	pass ;

func reduceCooldown(delta):

	if not onCooldown:
		return ;
	holder.reduceCooldown(delta)
	remap(255, 0, 0, 1, 254)
	cdt = cdt - delta;
	if cdt < 0:
		onCooldown = false;
	pass

var waitingForMinions = false;
func do(delta):
	reduceCooldown(delta)
	if !onCooldown:
		if target != null: checkTarget()
		if target == null: getTarget()
		if projectile == null: projectile = Projectile.create(type, damage, speed, self, extension)
			
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
				do_all(on_target_found)
				return true;
			else:
				for m in cell:
					if not is_instance_valid(m):
						cell.erase(m)
					else:
						do_all(on_target_found)
						target = m
						return true;
	return false;
func getTarget():
	
	if minions.get_child_count() == 0:
		return ;
	#check cells where minions have been found recently
	if searchForMinionsInRecent(): return
	for cell in coveredCells:
		if !cell.is_empty():
			target = cell.back()
			
			if target != null:
				do_all(on_target_found)
				if recentCells.find(cell) == - 1:
					recentCells.push_back(cell)
				return ;
			else:
				for m in cell:
					if not is_instance_valid(m):
						cell.erase(m)
					else:
						do_all(on_target_found)
						target = m
	pass ;
func do_all(tasks: Array[Callable]):
	for t in tasks:
		t.call()
	pass ;
func checkTarget():
	
	var distancesquared = abs(global_position.distance_squared_to(target.global_position))
	if distancesquared > abs(trueRangeSquared):
		target = null;
	
	pass ;
	
func attack(delta):
	if target != null:
		if !onCooldown:
			shoot(target);
		
	pass ;
func shoot(target):
	var barrels = getBarrels();
	for b in barrels:
		var bp = b.get_child(0).global_position;
		var shot = Projectile.create(type, damage * damagefactor, speed * speedfactor, self, extension);
		shot.global_position = bp;
		do_all(on_shoot)
		#if type == Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR == extension:
		#		Explosion.create(Stats.TurretColor.YELLOW, 0, bp, self, 0.1)
		if instantHit:
			shot.global_position = target.global_position
			shot.hitEnemy(target)
			shot.global_position = global_position
		else:
			shot.shoot(target);
	startCooldown(cooldown * cooldownfactor)
	pass ;
func startCooldown(time):

	cdt = time;
	onCooldown = true;
	pass ;
	
func showRangeOutline():
	if placed:
		for c in referenceCells:
			var pos = collisionReference.getGlobalFromReference(c)
			GameState.gameState.gameBoard.show_outline(pos)
				
	else:
		var showCells = []
		getReferences(showCells)
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
	var children = barrels
	level = lvl;
	for i in range(lvl):
		if i < children.size():
			add_child(children[i])
			children[i].visible = true;

	pass ;
	
func getBarrels():
	var children = get_children()
	var ret = []
	for i in range(level):
		if i < children.size():
			ret.append(children[i])
	return ret;
# Called every frame. 'delta' is the elapsed time since the previous frame.
