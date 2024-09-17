extends BaseDTO

class_name ItemBlockDTO

var color: Turret.Hue
var block_shape: Block.BlockShape
var rotation: int
var tile_id: int
var map_position: Vector2
var turret_mod

func _init(color: Turret.Hue = Turret.Hue.BLUE, block_shape: Block.BlockShape = Block.BlockShape.O, tile_id: int = -1, rotation: int = 0, map_position: Vector2 = Vector2(-1, -1)):
	self.color = color
	self.block_shape = block_shape
	self.tile_id = tile_id
	self.rotation = rotation
	self.map_position = map_position
	
func clone() -> ItemBlockDTO:
	var item_block = ItemBlockDTO.new(color, block_shape, tile_id, rotation, map_position)
	item_block.turret_mod = turret_mod
	return item_block
	
#func get_json():
	#if turret_mod==null: return super()
	#var props=turret_mod.get_property_list()
	#turret_mod=props[2]["hint_string"]
	#return super()
	#pass;	

#func restore(a=-1,b=-1,c=-1):
	#super(a,b,c)
	#pass;
