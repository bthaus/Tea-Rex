extends Button

var _id: int
signal clicked

func set_item(id: int, texture: Texture, name: String):
	self._id = id
	$Item.texture = texture
	$Name.text = name

func _on_pressed():
	clicked.emit(_id)
