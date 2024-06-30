extends Button

func set_item(texture: Texture, name: String):
	$Item.texture = texture
	$Name.text = name
