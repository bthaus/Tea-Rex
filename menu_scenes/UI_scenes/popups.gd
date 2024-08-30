extends Control

@onready var popup_panel = $UI/PopupPanel
@onready var container = $UI/PopupPanel/Container
var max_width: float = 500.0

func show_popup(sender, content: PopupContent):
	if content == null:
		return
	
	for item in container.get_children():
		container.remove_child(item)
		item.queue_free()
	
	for c in content.content:
		if c is RichTextLabel:
			popup_panel.get_child(0).add_child(c)
			_resize_label(c)
	
	popup_panel.size = Vector2i.ZERO
	var rect = Rect2(Vector2i(sender.global_position), Vector2(sender.size))
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	var padding = 4
 
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2(rect.size.x + padding, 0)
	else:
		correction = -Vector2(popup_panel.size.x + padding, 0)
 
	popup_panel.popup(Rect2i(rect.position + correction, popup_panel.size))

func hide_popup():
	popup_panel.hide()
	
func _resize_label(label: RichTextLabel):
	var font = label.get_theme_font("normal_font")
	var font_size = label.get_theme_font_size("normal_font_size")
	var text_size = font.get_multiline_string_size(label.get_parsed_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	label.custom_minimum_size = text_size
	
#func _resize(label: RichTextLabel):
	#while label.get_visible_line_count() < label.get_line_count():
		#label.custom_minimum_size.y += 10
		#await get_tree().process_frame
		#var t = label.get_theme_font("normal_font")
		#t.get_multiline_string_size(label.text)
		
class PopupContent:
	var content: Array = []
	
	func append_title(bbcode: String):
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		_set_font_size(label, 25)
		label.append_text(bbcode)
		content.append(label)
	
	func _set_font_size(label: RichTextLabel, font_size: int):
		label.add_theme_font_size_override("normal_font_size", font_size)
		label.add_theme_font_size_override("bold_font_size", font_size)
		label.add_theme_font_size_override("bold_font_size", font_size)
		label.add_theme_font_size_override("italics_font_size", font_size)
		label.add_theme_font_size_override("mono_font_size", font_size)



