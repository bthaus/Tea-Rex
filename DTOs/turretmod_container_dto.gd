extends BaseDTO
class_name TurretModContainerDTO
#has a container for turretmods
#we start with a 4x4 container, but we can change it later if we want to
#is stored in account, at the start you own 6 instances of 4x4 containers
#you can store your mods in it, they are saved
#you can put a blueprint _on_ a battleslot, so the turret of the slots color has the mods from 
#this container
var turret_mods: Array[ItemBlockDTO] = []

var color: Turret.Hue

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
