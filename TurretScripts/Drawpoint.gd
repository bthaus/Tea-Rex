extends Node2D

var base
var target
var buildup=0
var targetposition
var type
var direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _draw():

	if target!=null:
		targetposition=target.global_position;
	if target==null&&buildup<=0:
		return
	if targetposition==null:
		return
	var thickness=3;
	if buildup>0&&Stats.TurretColor.RED==type:
		direction=(targetposition-self.global_position).normalized();
	#	$Barrel.rotation=direction.angle() + PI / 2.0;
		var color=Color(500,0.2+(0.2*buildup*sin(Time.get_ticks_usec())),0.2+(0.2*buildup*sin(Time.get_ticks_usec())),buildup)
		color=color.lightened(0.5*sin(Time.get_ticks_usec()))
		var it=0;
		for b in base.getBarrels():
			
			
			it=it+1;
			if it==1:
				thickness=5;
			else:
				thickness=1
			var bgp=b.get_child(0).global_position;
			var bp=b.get_child(0).position;
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness/2*buildup,true)
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness*buildup+(3*buildup*sin(Time.get_ticks_usec())),true)
		
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
