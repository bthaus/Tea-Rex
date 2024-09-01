extends BaseDTO
class_name MapDTO

var entities: Array[BaseDTO]

var waves
#TODO: change that to an actual number
var number_of_waves: int = 2
var map_name: String = ""
var battle_slots: BattleSlotDTO
var block_cycle: Array[BaseDTO]
var color_cycle: Array

var _reduced_entities=""
var _reduced_waves=""

func _init(entities: Array[BaseDTO] = [], waves = [], block_cycle: Array[BaseDTO] = [], color_cycle: Array = [], mapname = ""):
	self.entities = entities
	self.waves = waves
	self.block_cycle = block_cycle
	self.color_cycle = color_cycle
	self.map_name=mapname

func restore(dest,acc="",dir="maps"):
	super.restore("map_"+dest,"",dir+"/"+dest)
	var packed=_reduced_entities.split("-")
	for p in packed:
		if p.count("_",0)!=2:continue
		var t=p.split("_")
		
		entities.append(EntityDTO.new(int(t[0]),int(t[1]),int(t[2])))
	var ws=_reduced_waves.split("&&")	
	for w in ws:
		var monsters=w.split("-")
		var wave_dtos=[]
		for m in monsters:
			if m.count("_",0)!=2:continue
			var ma=m.split("_")
			wave_dtos.append(MonsterWaveDTO.new(int(ma[0]),int(ma[1]),int(ma[2])))
		if wave_dtos.is_empty():continue
		waves.append(wave_dtos)	
		
		
func save(dest,acc="",dir="maps"):
	MapNameDTO.add_map_name(dest)
	var keep_arr=[] as Array[BaseDTO]
	for e in entities:
		if e is PortalDTO:
			keep_arr.append(e)
			continue
		if e is SpawnerDTO:
			keep_arr.append(e)
			continue
		if e is PlayerBaseDTO:
			keep_arr.append(e)
			continue
		_reduced_entities+=(str(e.tile_id)+"_"+str(e.map_x)+"_"+str(e.map_y)+"-")
	entities=keep_arr
	for wave in waves:
		for m in wave:
			_reduced_waves+=str(m.spawner_id)+"_"+str(m.monster_id)+"_"+str(m.count)+"-"
		_reduced_waves+="&&"
	waves.clear()		
	return super.save("map_"+dest,"",dir+"/"+dest)
		
