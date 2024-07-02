extends Panel

var minion_count = 0


func _on_increase_button_pressed():
	if minion_count < 50:
		minion_count += 1
		$CountLabel.text = str(minion_count)
	
func _on_decrease_button_pressed():
	if minion_count > 0:
		minion_count -= 1
		$CountLabel.text = str(minion_count)
