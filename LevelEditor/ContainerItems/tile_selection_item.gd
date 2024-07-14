extends Button

var tile: LevelEditor.TileItem
signal clicked

func set_tile(tile: LevelEditor.TileItem, texture: Texture):
	self.tile = tile
	$Item.texture = texture
	$Name.text = tile.name

func _on_pressed():
	clicked.emit(tile)
