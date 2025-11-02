extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const lines: Array[String] = [
	"me want food"
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.body_exited.connect(_on_body_exited)  # Connect Area2D signal

func _on_interact():
	DialogManager.start_dialog(global_position, lines, null)  # Added null for speech_sound
	sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else false
	await DialogManager.dialog_finished

func _on_body_exited(body: Node):
	# Close dialog when player leaves area
	if body.is_in_group("player") and DialogManager.is_dialog_active:
		DialogManager.end_dialog()
