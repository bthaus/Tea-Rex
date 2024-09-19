extends BaseDTO
class_name TurretModContainerDTO
#has a container for turretmods
#we start with a 4x4 container, but we can change it later if we want to
#is stored in account, at the start you own 6 instances of 4x4 containers
#you can store your mods in it, they are saved
#you can put a blueprint _on_ a battleslot, so the turret of the slots color has the mods from 
#this container
var turret_mods = []

var color: Turret.Hue
