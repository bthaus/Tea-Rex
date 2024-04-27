extends Node
class_name util

static func p(msg:String,fromperson:String="Someone",type:String="Debug"):
	print("Type: "+type +" From: "+ fromperson+ " MSG: "+msg);
	pass;

class Distance:
	var from: int
	var to: int
	func _init(from: int, to: int):
		self.from = from
		self.to = to


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
