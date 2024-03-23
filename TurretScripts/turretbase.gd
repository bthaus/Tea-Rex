@tool
extends Node2D
@export var range=1;
@export var detector:EnemyDetector;

@export var type: Stats.TurretColor;



# Called when the node enters the scene tree for the first time.
func _ready():
	detector.setRange(Stats.getRange(type));
	if type==Stats.TurretColor.YELLOW:
		util.p("implement custom yellow range",self,"Bodo","potential");
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	pass

func _get_configuration_warnings():
	var arr=PackedStringArray([])
	var children=get_children();
	var detector=false;
	var sprite=false;
	var missile=false;
	for a in children:
		if a.name=="EnemyDetector":
			detector=true;
	if !detector:
		arr.append("Add a detector to your turret");		
	return arr;
