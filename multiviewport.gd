extends Sprite2D
class_name MultiViewPort
@export var shader_array:Array[ShaderMaterial]=[]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shader_array.is_empty():return
	var nodes:Array[PortNode]=[]
		
	var previous_pass:Sprite2D
	for shader in shader_array:
		var node=create_port_node(shader)
		nodes.append(node)
	var root=self
	for node:PortNode in nodes:
		add_child(node.viewport)
		root=node
	root.sprite.texture=texture
	var leaf=root;
	nodes.erase(leaf)
	nodes.reverse()
	for node in nodes:
		node.sprite.texture=leaf.viewport.get_texture()
		leaf=node
	texture=leaf.viewport.get_texture()	

	
	
		
	pass # Replace with function body.
func create_port_node(shader)->PortNode:
	var sprite=Sprite2D.new()
	sprite.material=shader
	var viewport=SubViewport.new()
	viewport.transparent_bg=true
	var camera=Camera2D.new()
	
	viewport.add_child(sprite)
	viewport.add_child(camera)
	return PortNode.new(sprite,viewport,shader)
	
class PortNode:
	var sprite:Sprite2D
	var viewport:SubViewport
	var shader:ShaderMaterial
	func _init(s,v,sh) -> void:	
		self.sprite=s;
		self.viewport=v
		self.shader=sh
