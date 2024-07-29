extends BaseDTO

class_name ItemBlockDTO

var color: Turret.Hue
var block_shape: Block.BlockShape
var rotation: int
var tile_id: int
var map_position: Vector2
var turret_mod

func _init(color: Turret.Hue = Turret.Hue.BLUE, block_shape: Block.BlockShape = Block.BlockShape.O, rotation: int = 0, tile_id: int = -1, map_position: Vector2 = Vector2(-1, -1)):
	self.color = color
	self.block_shape = block_shape
	self.rotation = rotation
	self.tile_id = tile_id
	self.map_position = map_position
func get_json():
	if turret_mod==null: return super()
	var props=turret_mod.get_script_property_list() as Array
	turret_mod=props.pop_front()["hint_string"]
	return super()
	pass;	

func restore(a=-1,b=-1,c=-1):
	super(a,b,c)
	pass;
