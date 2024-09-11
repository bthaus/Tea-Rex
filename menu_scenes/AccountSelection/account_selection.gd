extends Node2D

@onready var accounts_container = $ScrollContainer/AccountsContainer
const ACCOUNT_PREFIX = "Slot "

func _ready():
	for child in accounts_container.get_children():
		accounts_container.remove_child(child)
		child.queue_free()
	
	var accounts = AccountNamesDTO.get_names()
	
	for i in GameplayConstants.NUMBER_OF_ACCOUNTS:
		var account_name = str(ACCOUNT_PREFIX, i+1)
		if not accounts.has(account_name):
			AccountNamesDTO.add_account_name(account_name)
			AccountInfoDTO.new(account_name).save(account_name)
		
		var account = AccountInfoDTO.new()
		account.restore(account_name)
		var item = load("res://menu_scenes/AccountSelection/account_selection_item.tscn").instantiate()
		item.set_account(account)
		accounts_container.add_child(item)


#functions i may need later...

#if AccountNamesDTO.exists_account_name(name):
#AccountNamesDTO.remove_account(name)
