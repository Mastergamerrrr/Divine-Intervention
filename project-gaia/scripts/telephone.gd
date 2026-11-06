extends StaticBody2D

@onready var aud: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var aud2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var aud3: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@export var target_scene: String = "res://scenes/aftercall.tscn"

# Reference to the InteractionArea child
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	# Connect the interact callable to our play function
	interaction_area.interact = play

func play():
	aud.play()
	await aud.finished  # Wait for audio 1 to finish playing
	aud2.play()
	await aud2.finished  # Wait for audio 2 to finish playing
	aud3.play()
	await get_tree().create_timer(3.0).timeout 
	aud3.stop()
	get_tree().change_scene_to_file(target_scene)
