extends Button

var tile: LevelEditor.TileItem
const default_stylebox = preload("res://LevelEditor/Styles/default_button.tres")
const selected_stylebox = preload("res://LevelEditor/Styles/selected_button.tres")
signal clicked

func set_tile(tile: LevelEditor.TileItem, texture: Texture):
	self.tile = tile
	$Item.texture = texture
	$Name.text = tile.name

func _on_pressed():
	clicked.emit(self, tile)

func set_selected(selected: bool):
	var style_box = selected_stylebox if selected else default_stylebox	
	add_theme_stylebox_override("normal", style_box)
	add_theme_stylebox_override("hover", style_box)
	add_theme_stylebox_override("pressed", style_box)
	add_theme_stylebox_override("focus", style_box)
