extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const GUIDE_BOX := preload("res://textbox/tutorial_text_box.tscn")
const speech_sound = preload("res://assets/SFX/just-sans-talking.wav")

const lines: Array[String] = [
	"Lost soul? This is Purgatory.",
	"To ascend, help someone.",
	"You'll need a body first.",
	"I can lend you one.",
	"A child is alone in that house.",
	"His mother left two days ago.",
	"He needs food and help.",
	"Find someone who can reach him.",
	"Take the door to the house."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.body_exited.connect(_on_body_exited)  # Connect Area2D signal

func _on_interact():
	DialogManager.start_dialog(global_position, lines, speech_sound, 0.5, GUIDE_BOX)
	sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else false
	await DialogManager.dialog_finished

func _on_body_exited(body: Node):
	# Close dialog when player leaves area
	if body.is_in_group("player") and DialogManager.is_dialog_active:
		DialogManager.end_dialog()
