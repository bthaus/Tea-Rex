extends Panel

var monster_wave_count = [0]
var wave = 0

func update(wave: int):
	self.wave = wave
	if wave >= monster_wave_count.size():
		for i in wave - monster_wave_count.size() + 1:
			monster_wave_count.append(0)
			
	_set_monster_count_text(monster_wave_count[wave])

func _on_increase_button_pressed():
	if monster_wave_count[wave] < 50:
		monster_wave_count[wave] += 1
		_set_monster_count_text(monster_wave_count[wave])
	
func _on_decrease_button_pressed():
	if monster_wave_count[wave] > 0:
		monster_wave_count[wave] -= 1
		_set_monster_count_text(monster_wave_count[wave])

func _set_monster_count_text(count: int):
	$CountLabel.text = str(count)
