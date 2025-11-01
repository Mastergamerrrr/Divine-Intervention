extends Control

@onready var start_button = $Start
@onready var exit_button = $EXIT

func _ready():
	start_button.connect("pressed", _on_start_game_pressed)
	exit_button.connect("pressed", _on_exit_pressed)

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/toturial.tscn")

func _on_exit_pressed():
	get_tree().quit()
