extends Node2D

const PRACTICE_EDGE := -76.0
const GUIDE_APPROACH := -12.0
const DOOR_APPROACH := 79.0

@onready var player: CharacterBody2D = $player_test
@onready var camera: Camera2D = $player_test/Camera2D
@onready var heading: Label = $TutorialHUD/FieldGuide/Copy/Heading
@onready var controls: Label = $TutorialHUD/FieldGuide/Copy/Controls

var current_hint := -1

func _ready() -> void:
	get_viewport().size_changed.connect(_frame_room)
	_frame_room()

func _frame_room() -> void:
	var extra_height := maxf(get_viewport_rect().size.y - 360.0, 0.0)
	camera.offset.y = -5.0 - minf(extra_height * 0.055, 18.0)

func _process(_delta: float) -> void:
	var player_x := player.position.x
	if player_x < PRACTICE_EDGE:
		_show_hint(0, "Practice with the blocks", "Q  Grab or release   /   A and D  Move")
	elif player_x < GUIDE_APPROACH:
		_show_hint(1, "Find the guide to your right", "A and D  Move   /   Space  Jump")
	elif player_x < DOOR_APPROACH:
		_show_hint(2, "Speak with the guide", "E  Talk or advance dialogue")
	else:
		_show_hint(3, "Enter the house", "E  Open the door when you get close")

func _show_hint(hint: int, title: String, input_hint: String) -> void:
	if hint == current_hint:
		return

	current_hint = hint
	heading.text = title
	controls.text = input_hint
