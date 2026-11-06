extends Control

const MENU_REFERENCE_SIZE := Vector2(1050, 600)

@onready var menu_anchor: Control = $MenuAnchor
@onready var start_button: Button = $MenuAnchor/Content/Actions/Start

func _ready() -> void:
	resized.connect(_fit_menu)
	_fit_menu()
	start_button.grab_focus()

func _fit_menu() -> void:
	var fit := minf(size.x / MENU_REFERENCE_SIZE.x, size.y / MENU_REFERENCE_SIZE.y)
	menu_anchor.scale = Vector2.ONE * minf(fit, 1.0)

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/toturial.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
