extends BaseDTO
class_name MapChapterDTO

var chapter_dictionary:Dictionary

func save(a="",b="",c=""):
	super.save("chapter_dictionary","","maps")

func restore(a="",b="",c=""):
	if not super.restore("chapter_dictionary","","maps"):
		save()

func add_map_to_chapter(mapname,chaptername):
	if not chapter_dictionary.has(chaptername):
		chapter_dictionary[chaptername]=[mapname]
	else:
		chapter_dictionary[chaptername].append(mapname)	
	save()
	pass;
	
func remove_map_from_chapter(mapname,chaptername):
	if not chapter_dictionary.has(chaptername): return;
	else: chapter_dictionary[chaptername].erase(mapname)
	save()	
	pass;

func get_chapter_of_map(mapname):
	for key in chapter_dictionary.keys():
		if chapter_dictionary[key].has(mapname):
			return key
	return null
	
	
func get_mapnames_from_chapter(chaptername):
	if not chapter_dictionary.has(chaptername): return [];
	else: return chapter_dictionary[chaptername]
func get_maps_without_chapter():
	var mapnames=MapNameDTO.new()
	mapnames.restore()
	var unused_maps=[]
	for name in mapnames.names:
		if get_chapter_of_map(name)==null:
			unused_maps.append(name)
	return unused_maps		
	pass;	
func add_chapter(chaptername):
	if  not chapter_dictionary.has(chaptername): 
		chapter_dictionary[chaptername]=[]
	save()	
	pass;	

func remove_chapter(chaptername):
	chapter_dictionary.erase(chaptername)
	save()
	pass;	
