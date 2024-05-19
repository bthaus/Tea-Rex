extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for b in get_children():
		if b.shot:
			b.translate(b.direction * delta * b.speed);
		
		if abs(b.global_position.x) > 3000||abs(b.global_position.y) > 1.5 * GameState.gameState.board_height * Stats.block_size:
			b.remove()
	pass
