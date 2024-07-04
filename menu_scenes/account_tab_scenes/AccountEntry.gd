extends GameObject2D
class_name AccountEntry
var accountName="";
var lvl=0;
var wave=0;
static var scene=load("res://menu_scenes/account_tab_scenes/account_entry.tscn")
var clicked=false;
signal start(accountname)

var hovered=false;
static var allEntries=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.text=accountName;
	allEntries.append(self)
	pass # Replace with function body.

static func create(name):
	var temp=scene.instantiate()
	temp.accountName=name
	return temp;
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _input(event):
	if Input.is_action_just_pressed("accept") and (hovered or clicked):
		_on_button_pressed()
	pass;

func _on_button_pressed():
	if clicked: start.emit(accountName); return;
	disableOthers()
	$Light.enabled=true;
	if hovertween!=null and hovertween.is_running(): hovertween.kill()
	create_tween().tween_property($Light,"energy",2,0.5)
	create_tween().tween_property($hint,"modulate",Color(1,1,1,1),1).set_delay(3)
	clicked=true;	
	pass # Replace with function body.



var hovertween;
func _on_button_mouse_entered():
	hovered=true
	if not clicked:
		hovertween=create_tween()
		hovertween.tween_property($Light,"energy",0.5,1)
	#create_tween().tween_property($Sprite2D2/selected,"modulate",Color(1,1,1,1),1)
	pass # Replace with function body.


func _on_button_mouse_exited():
	hovered=false;
	if clicked:return;
	if not clicked:
		create_tween().tween_property($Light,"energy",0,1)
	create_tween().tween_property($hint,"modulate",Color(0,0,0,0),1)
	
	pass # Replace with function body.


func disableOthers():
	for entry in allEntries:
		if entry!=self:
			entry.hovered=false;
			entry.clicked=false;
			create_tween().tween_property(entry.get_node("Light"),"energy",0,1)
			create_tween().tween_property(entry.get_node("hint"),"modulate",Color(0,0,0,0),1)
			
			entry._on_button_mouse_exited()
		
		
	pass # Replace with function body.
