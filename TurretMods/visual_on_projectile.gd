@tool
extends Node2D
class_name EmissionPropagation

var emitting=false:
	set(value):
		emitting=value
		for child in get_children():
			child.emitting=value;
