extends Panel

var _monster_id
var _monster_amount = [0]
var _wave = 0

func set_monster_id(id: int):
	_monster_id = id
	
func get_monster_id() -> int:
	return _monster_id
	
func update(wave: int):
	self._wave = wave
	_set_monster_count_text(_monster_amount[_wave])
	
func set_number_of_waves(amount: int):
	if _monster_amount.size() < amount:
		for i in amount - _monster_amount.size():
			_monster_amount.append(0)
	elif _monster_amount.size() > amount:
		_monster_amount = _monster_amount.slice(0, amount)

#Returns this format: [1, 5, 8, ...] indicating the amount of ONE monster type that appears in wave 1, 2, 3...
func get_monsters():
	return _monster_amount

func _on_increase_button_pressed():
	if _monster_amount[_wave] < 50:
		_monster_amount[_wave] += 1
		_set_monster_count_text(_monster_amount[_wave])
	
func _on_decrease_button_pressed():
	if _monster_amount[_wave] > 0:
		_monster_amount[_wave] -= 1
		_set_monster_count_text(_monster_amount[_wave])

func _set_monster_count_text(count: int):
	$CountLabel.text = str(count)
