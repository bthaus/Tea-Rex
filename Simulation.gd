extends Node2D
class_name Simulation

var gameState:GameState

var mods=[]
#enum Hue {WHITE=1, GREEN=2, RED=3, YELLOW=4, BLUE=5, MAGENTA=6};

var color_index=6
var mod_set_index=0
@export var sim_speed=25
var results=""

static var instance
# Called when the node enters the scene tree for the first time.
func _ready():
	
	instance=self
	gameState=load("res://Game/main_scene.tscn").instantiate()
	
	var map=MapDTO.new()
	map.restore("testbase")
	var ent=map.entities
	var turrets=[]
	for e:EntityDTO in ent:
		if e.tile_id==GameboardConstants.TURRET_BASE_RED_TILE_ID:
			turrets.append(Turret.create(Turret.Hue.RED,1,1))
		if e.tile_id==GameboardConstants.TURRET_BASE_GREEN_TILE_ID:
			turrets.append(Turret.create(Turret.Hue.GREEN,1,1))
		if e.tile_id==GameboardConstants.TURRET_BASE_YELLOW_TILE_ID:
			turrets.append(Turret.create(Turret.Hue.YELLOW,1,1))		
		if e.tile_id==GameboardConstants.TURRET_BASE_MAGENTA_TILE_ID:
			turrets.append(Turret.create(Turret.Hue.MAGENTA,1,1))
		if e.tile_id==GameboardConstants.TURRET_BASE_BLUE_TILE_ID:
			turrets.append(Turret.create(Turret.Hue.BLUE,1,1))
	var cont=TurretModContainerDTO.new()
	cont.color=Turret.Hue.BLUE
	cont.turret_mods.append_array([
		MultipleShotsMod.new().get_item(),
		FrostAmmunitionMod.new().get_item()
	])
	var red=TurretModContainerDTO.new()
	red.color=Turret.Hue.RED
	red.turret_mods.append_array([
		FireTrailMod.new().get_item(),
		ForkingAmmunitionMod.new().get_item()
	])
					
	gameState.map_dto=map
	gameState.register_battle_slot_containers([cont,red])
	add_child(gameState)
	test_scenario(turrets)
	return
	for s in gameState.spawners:
		s._is_simulation=true
	gameState.game_speed
	gameState.start_build_phase.connect(_next_test)
	_setup_mods()
	_next_test()
	pass # Replace with function body.
	
func test_scenario(turrets):
	
	pass;	
func _setup_mods():
	GameplayConstants.register_mods_for_sim()
	for i in TurretBaseMod.implemented_mods.size():
		for mod in TurretBaseMod.implemented_mods.values()[i]:
			for j in TurretBaseMod.implemented_mods.size():
				if i!=j:
					for other_mod in TurretBaseMod.implemented_mods.values()[j]:
						mods.append([mod,other_mod])
				
	pass;
func _next_test():
	
	running=true
	if current_turret!=null:
		current_turret.queue_free()
		var res=current_turret.get_info()+"\n"
		print(res)
		results=results+res+"\n"
		#get_tree().create_timer(5).timeout.connect(_test_turret.bind(color_index,mods[mod_set_index]))
		#return
	if mod_set_index>=mods.size():
		mod_set_index=0
		color_index=color_index+1
	if color_index>Turret.Hue.size():
		_finish_simulation()
		return		
		
	_test_turret(color_index,mods[mod_set_index])
	mod_set_index=mod_set_index+1
	pass;
func _finish_simulation():
	var time=Time.get_datetime_string_from_system()
	time=time.replace(":","_")
	time=time.replace("-","_")
	GameSaver.save(results,"t_"+time,"","tests")
	get_tree().quit()
	pass;
static func wave_done():
	
	instance._next_test()
	pass;	
var current_turret:Turret=null
func _test_turret(color:Turret.Hue, mod_names):
	var mods=[]
	for mod in mod_names:
		mods.append(mod.new())
	var turret=Turret.create(color,1,Turret.Extension.DEFAULT,true,mods)
	turret.global_position=gameState.board.map_to_local(Vector2(11,4))
	add_child(turret)
	turret.base.turret_mods=mods
	for mod in mods:
		mod.initialise(turret.base)
	current_turret=turret
	gameState.phase=gameState.GamePhase.BATTLE
	gameState.start_wave(0)
	GameState.game_speed=sim_speed
	Engine.time_scale=sim_speed
	gameState.wave=0
	gameState.HP=10000
	pass;
var running=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
