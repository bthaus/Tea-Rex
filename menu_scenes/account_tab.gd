extends Node2D
class_name AccountTab
@export var gameState:GameState
@export var accountsTab:Node2D
var accountentries;	

# Called when the node enters the scene tree for the first time.
func _ready():
	gameState=GameState.gameState
	refreshAccountList()
	blinkHint(true)
	pass # Replace with function body.
func _input(event):
	if event.is_action_pressed("scroll_down")  and accountentries.global_position.y>-350*accountentries.get_child_count()+1200:
		accountentries.translate(Vector2(0,-100))
	if event.is_action_pressed("scroll_up")  and accountentries.global_position.y<500  :
		accountentries.translate(Vector2(0,100))		
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_just_pressed("delete"):
		if accountsTab.visible:
			for entry in AccountEntry.allEntries:
				if entry.clicked:
					removeAcc(entry.accountName)
					refreshAccountList()
	
	pass






func showAccounts():
	refreshAccountList()
	blinkHint(true)	
	$Sprite2D2/AccountNameHint.text="Enter your name to start"
	$Sprite2D2/AccountNameHint.modulate=Color(1,1,1,1)
	pass;

func initAccs():
	var accs=[]
	GameSaver.save(JSON.stringify(accs),"accounts","global")
	pass;

func loadAccs():
	var json=GameSaver.loadfile("accounts","global")
	if json==""||JSON.parse_string(json).size()==0:
		initAccs()
	var acs=JSON.parse_string(json)
	
	return acs
	pass;
func saveAccs(accs):
	var json=JSON.stringify(accs)
	GameSaver.save(json,"accounts","global")
	pass;
	
func selectAcc(name):
	#gameState.account=name
	#GameSaver.restoreGame(gameState)
	continue_to_select()
	pass;
	
func continue_to_select():
	print("here?")
	MainMenu.change_content(MainMenu.level_select)
	pass		
func saveNewAcc(name):
	var accs=loadAccs()
	gameState.account=name
	if accs!=null and accs.find(name)!=-1:
		$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.text="Name taken!"
		$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.modulate=Color(1,0,0,1)
		return
	accs.append(name);
	saveAccs(accs)
	GameSaver.restoreBaseGame(gameState)
	continue_to_select()
		
	pass;
func removeAcc(name):
	GameSaver.remove(name)
	var accs=loadAccs()
	accs.erase(name)
	saveAccs(accs)
	
	pass;
	

func refreshAccountList():
	var accs=loadAccs();
	for entry in $EntryPosition/pos.get_children():
		entry.free()
	AccountEntry.allEntries.clear()
	#$MainMenu/AccountsTab/EntryPosition/pos.global_position=Vector2(-24,-405)
	accountentries=$EntryPosition/pos
	var offset=0
	for a in accs:
		var entry=AccountEntry.create(a)
		if entry==null:
			removeAcc(a)
			continue
		$EntryPosition/pos.add_child(entry)
		entry.translate(Vector2(0,offset))
		offset=offset+350;
		entry.start.connect(selectAcc)
	pass;
func _on_account_input_text_submitted(new_text):
	var accs=loadAccs()
	saveNewAcc(new_text)
	refreshAccountList()
	pass # Replace with function body.



func _on_account_list_item_activated(index):
	var selected=$MainMenu/AccountsTab/AccountList.get_item_text(index)
	selectAcc(selected)
	pass # Replace with function body.



func _on_account_input_focus_entered():
	create_tween().tween_property($MainMenu/AccountsTab/Sprite2D/accountlight,"energy",1.4,0.5)
	pass # Replace with function body.


func _on_account_input_focus_exited():
	create_tween().tween_property($MainMenu/AccountsTab/Sprite2D/accountlight,"energy",0,1.5)
	pass # Replace with function body.
static var blinking=true;
func blinkHint(show):
	if blinking==false:
		return;
	$typehint.visible=show
	create_tween().tween_callback(blinkHint.bind(!show)).set_delay(0.5)
	pass;
func _on_account_input_text_changed(new_text):
	if new_text=="":
		blinking=true;
		blinkHint(true);
	else:blinking=false;	
	$accountnametext.text=new_text
	pass # Replace with function body.

func _on_button_2_pressed():
	var accs=loadAccs()
	saveNewAcc("unknown"+str(randi_range(0,1000000)))
	refreshAccountList()
	pass # Replace with function body.
