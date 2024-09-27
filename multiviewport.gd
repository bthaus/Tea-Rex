extends Sprite2D
class_name MultiViewPort
@export var shader_array:Array[ShaderMaterial]=[]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var nodes:Array[PortNode]=[]
	var previous_pass:Sprite2D
	for shader in shader_array:
		var node=create_port_node(shader)
		nodes.append(node)
	var last_pass=nodes.pop_back() as PortNode
	last_pass.sprite.texture=texture
	var first_pass=last_pass
	for node:PortNode in nodes:
		node.sprite.texture=last_pass.viewport.get_texture()
		last_pass=node
	texture=last_pass.viewport.get_texture()	
	nodes.reverse()
	nodes.push_back(first_pass)
	var root=self
	for node:PortNode in nodes:
		root.add_child(node.viewport)
		root=node.viewport
		
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
