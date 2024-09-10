extends Panel

var _amount: int
var max_amount: int

func _ready():
	_amount = $AmountEdit.text as int
	max_amount = Turret.Hue.keys().size()

func get_amount() -> int:
	return _amount

func load_settings(battle_slot_dto: BattleSlotDTO):
	_amount = battle_slot_dto.amount
	$AmountEdit.text = str(_amount)

func _on_amount_increase_button_pressed():
	if _amount < max_amount:
		_amount += 1
		$AmountEdit.text = str(_amount)

func _on_amount_decrease_button_pressed():
	if _amount > 1:
		_amount -= 1
		$AmountEdit.text = str(_amount)


func _on_amount_edit_focus_exited():
	var str = $AmountEdit.text.strip_edges()
	if not util.is_str_valid_positive_int(str):
		$AmountEdit.text = str(_amount)
		return

	var new_amount = str as int
	if new_amount <= 0 or new_amount > max_amount:
		$AmountEdit.text = str(_amount)
		return
	
	_amount = new_amount
	$AmountEdit.text = str(_amount)
