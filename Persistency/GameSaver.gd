extends  GameObject2D
class_name GameSaver
@export var state:GameState;

static func save(content:String, destination:String, save:String="",directory:String=""):
	var dir=DirAccess.open("user://")
	if not dir.dir_exists(directory):
		dir.make_dir("user://"+directory)
	var file = FileAccess.open("user://"+directory+"/save_game"+destination+"_"+save+".dat", FileAccess.WRITE)
	var err=FileAccess.get_open_error()
	if err>0:
		print("error loading file with "+save)
		print(err)
		return "-1";
	file.store_string(content)
	
	pass;

static func loadfile(destination:String, save:String="",directory:String=""):
	var file = FileAccess.open("user://"+directory+"/save_game"+destination+"_"+save+".dat", FileAccess.READ)
	var err=FileAccess.get_open_error()
	if err>0:
		print("error loading file with "+save +" " + destination +" at "+directory)
		return "";
	var content = file.get_as_text()
	return content


