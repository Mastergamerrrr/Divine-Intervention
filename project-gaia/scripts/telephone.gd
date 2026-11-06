extends StaticBody2D

@export var target_scene := "res://scenes/aftercall.tscn"

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.action_name = "call for help"
	interaction_area.interact = _start_call

func _start_call() -> void:
	if get_tree().change_scene_to_file(target_scene) != OK:
		push_error("The telephone call scene could not load.")
