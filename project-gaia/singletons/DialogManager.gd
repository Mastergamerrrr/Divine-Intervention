extends Node

@onready var text_box_scene = preload("res://textbox/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false
var tail_pos: float

var sfx: AudioStream
var audio_player: AudioStreamPlayer

signal dialog_finished()

func _ready():
	# Create audio player properly
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	print("AudioStreamPlayer created for DialogManager")

func start_dialog(position: Vector2, lines: Array[String], speech_sfx: AudioStream, tail_position = 0.5):
	if is_dialog_active:
		# Clean up existing dialog
		if text_box and is_instance_valid(text_box):
			text_box.queue_free()
		is_dialog_active = false
		
	dialog_lines = lines
	text_box_position = position
	current_line_index = 0
	sfx = speech_sfx
	_show_text_box()
	
	is_dialog_active = true

func end_dialog():
	if text_box and is_instance_valid(text_box):
		text_box.queue_free()
	is_dialog_active = false
	current_line_index = 0
	dialog_lines = []
	dialog_finished.emit()

func _show_text_box():
	if current_line_index >= dialog_lines.size():
		end_dialog()
		return
		
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(on_text_box_finished_displaying)
	
	# Check if text_box has the letter_displayed signal before connecting
	if text_box.has_signal("letter_displayed"):
		text_box.letter_displayed.connect(_on_letter_displayed)
	else:
		print("Warning: text_box doesn't have letter_displayed signal")
	
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false

func on_text_box_finished_displaying():
	can_advance_line = true

func _on_letter_displayed():
	if sfx and audio_player:
		# Stop any current sound first
		audio_player.stop()
		audio_player.stream = sfx
		audio_player.play()
		
		# Choose ONE of these methods, not both:
		
		# Method A: Skip by percentage
		# var skip_percentage = 0.1  # 10%
		# var start_time = sfx.get_length() * skip_percentage
		
		# Method B: Skip by fixed time
		var start_time = 0.99  # Start at 50ms
		
		audio_player.seek(start_time)
		
		audio_player.volume_db = -10
		audio_player.pitch_scale = 1.2
		print("Playing speech sound from ", start_time, " seconds")  # Debug

func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("advance_dialog") &&
		is_dialog_active &&
		can_advance_line
	):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			end_dialog()
		else:
			_show_text_box()
