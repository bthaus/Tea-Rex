extends Node2D

func _on_exit_game_pressed():
	pass # Replace with function body.


#DEBUG ONLY


func _on_delete_all_maps_pressed():
	var dir=DirAccess.open("user://maps")
	var dirs=[]
	delete_dir(dir,dirs)
	var root=DirAccess.open("user://")
	
	dirs.reverse()
	for directory in dirs:
		directory.erase(0,7)
		root.remove(directory)
		
	dirs.clear()

func delete_dir(dir:DirAccess, dirs:Array):
	if dir==null:return
	for file in dir.get_files():
		dir.remove(file)
	
	dirs.append(dir.get_current_dir())
	for d in dir.get_directories():
		var temp=DirAccess.open(dir.get_current_dir()+"/"+d )
		delete_dir(temp,dirs)


func _on_delete_all_accounts_pressed():
	var dir=DirAccess.open("user://acc_infos")	
	var dirs=[]
	var root=DirAccess.open("user://")
	delete_dir(dir,dirs)
	
	dirs.reverse()
	for directory in dirs:
		directory.erase(0,7)
		root.remove(directory)
