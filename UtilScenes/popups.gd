extends Control

@onready var panel = $UI/Panel
@onready var container = $UI/Panel/MarginContainer/Container
@onready var animation = $UI/Panel/OpenCloseScaleAnimation

var max_width: float = 500.0
var is_opening = true

func show_popup(sender, content: PopupContent):
	var extent
	if sender is Sprite2D and sender.texture!=null:
		extent=sender.texture.get_size()
	elif sender is Node2D:
		extent=Vector2(20,20)
	else:	
		extent=sender.size	
	var rect = Rect2(Vector2i(sender.global_position), Vector2(extent))
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	var padding = 4
	
	panel.size = Vector2i.ZERO
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2(rect.size.x + padding, 0)
	else:
		correction = -Vector2(panel.size.x + padding, 0)
	
	show_popup_at(rect.position + correction, content)

func show_popup_at(position: Vector2, content: PopupContent):
	if content == null:
		return
	
	is_opening = true
	
	for item in container.get_children():
		container.remove_child(item)
		item.queue_free()
	
	for item in content.content:
		container.add_child(item)
		if item is RichTextLabel:
			_resize_label(item)
	
	panel.size = Vector2i.ZERO
	panel.set_global_position(position)
	
	animation.setup()
	animation.open()

func hide_popup():
	is_opening = false
	animation.close(func():
		if not is_opening: #Another component wants to open it, dont hide in that case
			panel.hide()
		)
	
func _resize_label(label: RichTextLabel):
	var font = label.get_theme_font("normal_font")
	var font_size = label.get_theme_font_size("normal_font_size")
	var alignment = label
	var text_size = font.get_multiline_string_size(label.get_parsed_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	label.custom_minimum_size = text_size

class PopupContent:
	var content: Array = []
	
	func append_title(bbcode: String):
		var text = "[center]%s[/center]" % bbcode
		var label = _create_label(text, 25)
		content.append(label)
	
	func append_description(bbcode: String):
		var label = _create_label(bbcode, 16)
		content.append(label)
		
	func append_image(texture: Texture2D, size: Vector2):
		var rect = TextureRect.new()
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.custom_minimum_size = size
		rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rect.texture = texture
		content.append(rect)
	
	func append_scene(scene, size: Vector2):
		var panel = Panel.new()
		panel.custom_minimum_size = size
		panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		panel.add_child(scene)
		content.append(panel)
	
	func _create_label(bbcode: String, font_size: int) -> RichTextLabel:
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		_set_font_size(label, font_size)
		label.append_text(bbcode)
		return label
	
	func _set_font_size(label: RichTextLabel, font_size: int):
		label.add_theme_font_size_override("normal_font_size", font_size)
		label.add_theme_font_size_override("bold_font_size", font_size)
		label.add_theme_font_size_override("bold_font_size", font_size)
		label.add_theme_font_size_override("italics_font_size", font_size)
		label.add_theme_font_size_override("mono_font_size", font_size)



