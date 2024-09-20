extends Panel

var _monster_id: int
var _monster_amount = [0]
var _wave = 0

func set_monster(monster: Monster.MonsterName):
	_monster_id = monster
	$NameLabel.text = util.format_name_string(Monster.MonsterName.keys()[monster])
	
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

func set_monster_count_for_wave(wave: int, count: int):
	_monster_amount[wave] = count

func _on_count_edit_focus_exited():
	var str = $CountEdit.text.strip_edges()
	if not util.is_str_valid_positive_int(str):
		$CountEdit.text = str(_monster_amount[_wave])
		return
	
	var new_count = str as int
	if new_count > GameplayConstants.MAX_NUMBER_OF_MONSTERS_PER_TYPE:
		$CountEdit.text = str(_monster_amount[_wave])
		return
	
	_set_monster_count_text(new_count)
	_monster_amount[_wave] = new_count

func _on_increase_button_pressed():
	if _monster_amount[_wave] < GameplayConstants.MAX_NUMBER_OF_MONSTERS_PER_TYPE:
		_monster_amount[_wave] += 1
		_set_monster_count_text(_monster_amount[_wave])
	
func _on_decrease_button_pressed():
	if _monster_amount[_wave] > 0:
		_monster_amount[_wave] -= 1
		_set_monster_count_text(_monster_amount[_wave])

func _set_monster_count_text(count: int):
	$CountEdit.text = str(count)
