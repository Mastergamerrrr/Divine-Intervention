extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_open: bool = false
var can_teleport: bool = true
var audio_pitch_scale: float = 2.0  # Speed up the audio

# Teleporter properties
@export var is_teleporter: bool = false
@export var target_door: NodePath
@export var transition_enter: Transition.Type = Transition.Type.INSTANT_IN
@export var transition_exit: Transition.Type = Transition.Type.FADE_OUT
@export var teleport_cooldown: float = 1.0
@export var spawn_marker_name: String = "SpawnMarker"  # Configurable marker name

func _ready() -> void:
	if is_teleporter:
		interaction_area.action_name = "enter"
	else:
		interaction_area.action_name = "open"
	
	interaction_area.interact = Callable(self, "_on_interact")
	anim.animation_finished.connect(_on_animation_finished)
	audio.pitch_scale = audio_pitch_scale

func _on_interact():
	if is_teleporter:
		if can_teleport:
			can_teleport = false
			_disable_player_movement()  # Disable player movement
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
	# If teleporter door finished opening, trigger teleport then close
	if is_teleporter and anim_name == "open" and is_open:
		# Wait 0.2 seconds before teleporting
		await get_tree().create_timer(0.2).timeout
		await _teleport_player()
		
		_enable_player_movement()
		# Wait 0.5 seconds before closing the door
		await get_tree().create_timer(0.5).timeout
		anim.play("close")
		is_open = false
		
		# Reset cooldown after everything is done
		await get_tree().create_timer(teleport_cooldown).timeout
		can_teleport = true

func _teleport_player():
	if target_door.is_empty():
		_enable_player_movement()  # Make sure to re-enable if teleport fails
		return
		
	var target = get_node(target_door)
	if not target:
		_enable_player_movement()  # Make sure to re-enable if teleport fails
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		_enable_player_movement()  # Make sure to re-enable if teleport fails
		return
	
	# Fade to black (beginning of teleport)
	await _fade_to_black()
	
	# Teleport player to the marker position if it exists, otherwise use default position
	if target.has_node(spawn_marker_name):
		var spawn_marker = target.get_node(spawn_marker_name)
		player.global_position = spawn_marker.global_position
	else:
		# Fallback to original behavior if no marker found
		print("Warning: No SpawnMarker found on target teleporter, using default position")
		player.global_position = target.global_position
	
	# Fade from black (end of teleport)
	await _fade_from_black()

func _fade_to_black():
	# Create a black color rect that covers the entire screen
	var fade_color_rect = ColorRect.new()
	fade_color_rect.color = Color.BLACK
	fade_color_rect.size = get_viewport().get_visible_rect().size
	fade_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Start fully transparent
	fade_color_rect.color.a = 0.0
	
	# Add to canvas layer so it appears above everything
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(fade_color_rect)
	get_tree().root.add_child(canvas_layer)
	
	# Animate fade in (from transparent to black)
	var tween = create_tween()
	tween.tween_property(fade_color_rect, "color:a", 1.0, 0.3)
	await tween.finished
	
	# Keep the reference to remove later
	canvas_layer.set_meta("fade_layer", true)

func _fade_from_black():
	# Find the fade layer we created
	var fade_layer = null
	for child in get_tree().root.get_children():
		if child is CanvasLayer and child.has_meta("fade_layer"):
			fade_layer = child
			break
	
	if fade_layer:
		var fade_color_rect = fade_layer.get_child(0)
		# Animate fade out (from black to transparent)
		var tween = create_tween()
		tween.tween_property(fade_color_rect, "color:a", 0.0, 0.3)
		await tween.finished
		fade_layer.queue_free()

func _disable_player_movement():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)

func _enable_player_movement():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(true)
