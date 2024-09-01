extends BaseDTO
class_name BlockCycleEntryDTO

var piece_positions = []

func _init(piece_positions: Array = []):
	self.piece_positions = piece_positions

func get_object():
	var pieces = []
	for pos in piece_positions:
		pieces.append(Block.Piece.new(Vector2(pos.x, pos.y), Turret.Hue.WHITE, 1))
	return Block.new(pieces)
func get_compact_string():
	var s=""
	for piece in piece_positions:
		s+=str(piece["x"])+"_"+str(piece["y"])+"§"
	s+="&&"
	return s	
static func cycles_from_string(s):
	var arr=[] as Array[BaseDTO]
	var packed=s.split("&&")
	for p in packed:
		var pieces=p.split("§")
		var block=[]
		for piece in pieces:
			if piece.count("_")!=1 :continue
			var c=piece.split("_")
			block.append({"x"=float(c[0]),
						"y"=float(c[1])})	
		var dto=BlockCycleEntryDTO.new()
		dto.piece_positions=block
		if block.is_empty():continue
		arr.append(dto)				
	return arr
	
	
