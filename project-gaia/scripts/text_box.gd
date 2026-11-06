extends MarginContainer

@export var label_path: NodePath = ^"MarginContainer/Label"

@onready var label: Label = get_node(label_path)
@onready var timer: Timer = $LetterDisplayTimer

const MAX_WIDTH = 256

@export var screen_space := false

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.02

signal finished_displaying()
signal letter_displayed()  # THIS MUST EXIST

func _ready() -> void:
	if screen_space:
		get_viewport().size_changed.connect(_fit_hud_width)
		_fit_hud_width()

func _fit_hud_width() -> void:
	var half_width := clampf((get_viewport_rect().size.x - 32.0) * 0.5, 0.0, 240.0)
	offset_left = -half_width
	offset_right = half_width

func display_text(text_to_display: String):
	text = text_to_display
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	label.text = text_to_display
	if screen_space:
		label.visible_characters = 0
		_display_letter()
		return

	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x * scale.x / 2
	global_position.y -= size.y * scale.y + 24
	
	label.visible_characters = 0
	_display_letter()
	
func _display_letter():
	label.visible_characters = letter_index + 1
	letter_displayed.emit()  # EMIT THE SIGNAL HERE
	
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

func _on_letter_display_timer_timeout() -> void:
	_display_letter()
