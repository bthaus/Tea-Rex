extends Node2D

var labels=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var first
var current
var running=false;
signal selected(tiles)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_just_pressed("left_click") and Input.is_action_pressed("shift"): 
		first=get_global_mouse_position()
		running=true
		
	if Input.is_action_pressed("left_click") and running:
		current=get_global_mouse_position()
		queue_redraw()
	if Input.is_action_just_released("left_click") and running:
		selected.emit(get_tiles_under_rectangle())
		running=false
		stop()
		return
		
	
	pass
func stop():

	first=Vector2(0,0)
	current=first
	queue_redraw()
	pass;	
func _draw():
	if current==first:return
	var size=current-first
	var rect = Rect2(first, size)
	draw_rect(rect, Color(1, 0, 0,0.5))	
	
func get_tiles_under_rectangle() -> Array:
	var tiles = []
	var corner1=first
	var corner2=current
	var tile_size=GameboardConstants.TILE_SIZE
	# Determine the actual top-left and bottom-right corners
	var tl_x = min(corner1.x, corner2.x)
	var tl_y = min(corner1.y, corner2.y)
	var br_x = max(corner1.x, corner2.x)
	var br_y = max(corner1.y, corner2.y)
	
	# Calculate tile indices for the adjusted corners
	var tl_tile_x = int(tl_x / tile_size)
	var tl_tile_y = int(tl_y / tile_size)
	var br_tile_x = int(br_x / tile_size)
	var br_tile_y = int(br_y / tile_size)
	
	# Iterate over the tile range and collect tile indices
	for x in range(tl_tile_x, br_tile_x + 1):
		for y in range(tl_tile_y, br_tile_y + 1):
			var mpos=Vector2(x, y)
			tiles.append(mpos)
			
	
	return tiles	
