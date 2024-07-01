extends TurretCore
class_name RedLaserTurretCore

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attack(delta):
	
	#if !$AudioStreamPlayer2D.playing and buildup > 0:
		#$AudioStreamPlayer2D.play()
	#if buildup < 0.1:
		#$AudioStreamPlayer2D.stop()
		#
	if target != null and buildup <= 1:
		buildup = buildup + 1 * delta * 2;
	if target == null and buildup > 0:
		buildup = buildup - 2 * delta;
	
	queue_redraw()
	super.attack(delta)
	pass;
func _draw():
	
	if target != null:
		targetposition = target.global_position;
	if target == null&&buildup < 0:
		buildup = 0;
		holder.point.buildup = buildup
		holder.point.queue_redraw();
		return
	holder.point.type = extension
	holder.point.target = target
	holder.point.buildup = buildup
	holder.point.targetposition = targetposition
	holder.point.direction = direction
	holder.point.queue_redraw();
	return
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
