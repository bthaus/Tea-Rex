extends CanvasLayer
@export var gameState:GameState
@export var main:Node2D
@export var unlockedTab:Node2D
@export var accountsTab:Node2D
@export var menu:Node2D
@export var ui:Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#var map=BitMap.new()
	#map.create_from_image_alpha(load("res://Assets/UI/ShowUnlockedBUtton.png"),0)
	#$MainMenu/Main/UnlockedButton.texture_click_mask=map
	#var map2=BitMap.new()
	#map2.create_from_image_alpha(load("res://Assets/UI/ShowAccountsButton.png"),0)
	#$MainMenu/Main/Accounts
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_menu") and not Card.isCardSelected:
		menu.visible=!menu.visible
		
	pass


func _on_start_button_pressed():
	if gameState.account=="":
		showAccounts()
		return
	$MainMenu/Banner.visible=false;
	gameState.get_node("Spawner").visible=true;
	gameState.get_node("GameBoard").visible=true;
	ui.visible=true;
	menu.visible=false;
	$MainMenu/Main/StartButton/Label.text="continue"
	gameState.startGame()
	pass # Replace with function body.


func _on_unlocked_button_pressed():
	print("pressed")
	main.visible=false;
	unlockedTab.visible=true;
	pass # Replace with function body.
func _on_accounts_pressed():
	main.visible=false;
	showAccounts()
	pass # Replace with function body.

func _on_menu_state_propagation(gamestate):
	
	self.gameState=gamestate
	pass # Replace with function body.

func showAccounts():
	accountsTab.visible=true
	refreshAccountList()
		
	pass;

func initAccs():
	var accs=["Bodo","Jojo","CC","Betti","Luki"]
	GameSaver.save(JSON.stringify(accs),"accounts","global")
	pass;

func loadAccs():
	var json=GameSaver.loadfile("accounts","global")
	if json=="":
		initAccs()
	var acs=JSON.parse_string(json)
	print(acs)
	return acs
	pass;
func saveAccs(accs):
	var json=JSON.stringify(accs)
	GameSaver.save(json,"accounts","global")
	pass;	
func saveNewAcc(name):
	var accs=loadAccs()
	if accs!=null and accs.find(name)!=-1:
		print("accountname already taken!")
		return
	accs.append(name);
	saveAccs(accs)
		
	pass;
func refreshAccountList():
	var accs=loadAccs();
	var list=$MainMenu/AccountsTab/AccountList as ItemList
	list.clear()
	for a in accs:
		list.add_item(a)
	pass;
func _on_account_input_text_submitted(new_text):
	print(new_text)
	var accs=loadAccs()
	saveNewAcc(new_text)
	refreshAccountList()
	pass # Replace with function body.


func HideAccounts():
	accountsTab.visible=false;
	main.visible=true
	pass # Replace with function body.


func _on_unlocked_tab_visibility_changed():
	print("visibility changed")
	pass # Replace with function body.


func _on_button_pressed():
	pass # Replace with function body.


func hideUnlocks():
	unlockedTab.visible=false;
	main.visible=true;
	pass # Replace with function body.
