extends BaseDTO
class_name AccountInfoDTO

var account_name:String
var account_progress=[]#:Array=[]
var unlocked_colors=[]#:Array[Turret.Hue]
var unlocked_treasures=[]#:Array[String]
var unlocked_maps=[]
var unlocked_turret_mods=[]#: Array[ItemBlockDTO]

#array of blueprintsDTOs 
var blueprints=[]
var id=1;

var turret_mod_containers#: Array[TurretModContainerDTO]


var _active_token=""

func _init(name="-1"):
	account_name=name
	turret_mod_containers = []
	for key in Turret.Hue.keys():
		var container = TurretModContainerDTO.new()
		container.color = Turret.Hue.get(key)
		turret_mod_containers.append(container)
		
	_insert_test_items()
	super()
	pass;

func _insert_test_items():
	unlocked_turret_mods.append_array([FireTrailMod.new(), PenetratingAmmunition.new()])
	
	turret_mod_containers[0].turret_mods.append(FireAmmunitionMod.new().get_item())
func add_unlocked_mod(mod:TurretBaseMod):
	for m in unlocked_turret_mods:
		if mod.equals(m):return; 
	unlocked_turret_mods.append(mod)
	pass;
func add_unlocked_map(map:String):
	if unlocked_maps.has(map):return;
	unlocked_maps.append(map)
	pass;	
func save(name="-1",acc="-1",dir="-1"):
	if name=="-1" and account_name!=null:
		name=account_name
		
	AccountNamesDTO.add_account_name(name)
	print(unlocked_turret_mods[0] is GDScript)
	print(typeof(unlocked_turret_mods[0]))
	super.save(name,"","acc_infos/"+name)
	pass;

func restore(name,acc="-1",dir="-1"):
	super.restore(name,"","acc_infos/"+name)
	pass;
#this method for sure returns the progress dto of a player. For sake of ease, if none is found, a progressdto is created
#this way we dont have to worry about creating progress dtos for all accounts everytime we create a new map	
func get_map_progress_dto_by_name(name)-> MapStatusDTO:
	for ms in account_progress:
		if ms.map_name==name:
			return ms
	var new_dto= MapStatusDTO.new(name)
	account_progress.append(new_dto)
	return new_dto	


