extends Button

var tile: TileSelection.TileItem
const default_stylebox = preload("res://Styles/default_button.tres")
const selected_stylebox = preload("res://Styles/selected_button.tres")
signal clicked

func set_tile(tile_item: TileSelection.TileItem, texture: Texture):
	self.tile = tile_item
	$Item.texture = texture
	$Name.text = tile_item.name

func _on_pressed():
	clicked.emit(self, tile)

func set_selected(selected: bool):
	var style_box = selected_stylebox if selected else default_stylebox	
	add_theme_stylebox_override("normal", style_box)
	add_theme_stylebox_override("hover", style_box)
	add_theme_stylebox_override("pressed", style_box)
	add_theme_stylebox_override("focus", style_box)
