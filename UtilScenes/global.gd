extends Node

var _account_dto: AccountInfoDTO = AccountInfoDTO.new()
var is_playing_custom_level = false

func get_account() -> AccountInfoDTO:
	return _account_dto

func set_account(account_dto: AccountInfoDTO):
	_account_dto = account_dto
