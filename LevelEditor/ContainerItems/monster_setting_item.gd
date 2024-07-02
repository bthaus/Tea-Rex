extends Panel

var monster_count = 0

func _on_increase_button_pressed():
	if monster_count < 50:
		monster_count += 1
		$CountLabel.text = str(monster_count)
	
func _on_decrease_button_pressed():
	if monster_count > 0:
		monster_count -= 1
		$CountLabel.text = str(monster_count)
