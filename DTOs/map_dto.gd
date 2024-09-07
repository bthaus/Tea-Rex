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
var description:String="This is a map."

var _reduced_entities=""
var _reduced_waves=""
var _reduced_shapes=""

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
		if p=="":continue
		entities.append(EntityDTO.parse_compact_string(p))
		#var t=p.split("_")
		
		#entities.append(EntityDTO.new(int(t[0]),int(t[1]),int(t[2])))
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
	block_cycle=BlockCycleEntryDTO.cycles_from_string(_reduced_shapes)	
func reduce():
	_reduced_entities=""
	_reduced_waves=""
	_reduced_shapes=""
	for e in entities:
		_reduced_entities+=e.get_compact_string()
	
	for wave in waves:
		for m in wave:
			_reduced_waves+=str(m.spawner_id)+"_"+str(m.monster_id)+"_"+str(m.count)+"-"
		_reduced_waves+="&&"
	
	for block in block_cycle:
		_reduced_shapes+=block.get_compact_string()
	
	pass;		
func save(dest,acc="",dir="maps"):
	MapNameDTO.add_map_name(dest)
	reduce()
	waves.clear()	
	block_cycle.clear()	
	entities.clear()
	return super.save("map_"+dest,"",dir+"/"+dest)
		
