extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_open: bool = false
var can_interact: bool = true
var audio_pitch_scale: float = 2.0  # Speed up the audio

# Scene transition properties
@export var is_scene_transition: bool = true
@export var target_scene: String = "res://scenes/possessbear.tscn"

func _ready() -> void:
	if is_scene_transition:
		interaction_area.action_name = "enter"
	else:
		interaction_area.action_name = "open"
	
	interaction_area.interact = Callable(self, "_on_interact")
	anim.animation_finished.connect(_on_animation_finished)
	audio.pitch_scale = audio_pitch_scale

func _on_interact():
	if is_scene_transition:
		if can_interact:
			can_interact = false
			_disable_player_movement()
			audio.play()
			anim.play("open")
			is_open = true
	else:
		_toggle_door()

func _toggle_door():
	if is_open:
		anim.play("close")
		is_open = false
	else:
		anim.play("open") 
		is_open = true

func _on_animation_finished(anim_name: String):
	# If scene transition door finished opening, trigger scene change
	if is_scene_transition and anim_name == "open" and is_open:
		# Wait a moment before transitioning
		await get_tree().create_timer(0.5).timeout
		_change_scene()

func _change_scene():
	# Simple scene change without fade
	get_tree().change_scene_to_file(target_scene)

func _disable_player_movement():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)
