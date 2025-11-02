extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const speech_sound = preload("res://assets/SFX/just-sans-talking.wav")

const lines: Array[String] = [
	"Hey There You Must Be...",
	"A Lost Soul!","This Is The Purgatory My Friend",
	"If You Wish To Ascend To Heaven",
	"You Must Do Something Good",
	"In The Human World!","But In Order For You To Intervene",
	"You Must Take A Physical Body","Don't Worry I Got You Covered",
	"Though It Might Be","A Bit Small...","Just Find Ways To Reach Things",
	"Anyways",
	"There Is A Child Who Needs Help","He Is Left By His Mother",
	"In The House To Go Somewhere", "It Has Been 2 Days",
	"And The Mother Has Not Come Home","The Child Is Starving!",
	"Find A Way","To Get External Help","Now Go Enter The Door!",
	"GOOD LUCK!"
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.body_exited.connect(_on_body_exited)  # Connect Area2D signal

func _on_interact():
	DialogManager.start_dialog(global_position, lines, speech_sound)
	sprite.flip_h = true if interaction_area.get_overlapping_bodies()[0].global_position.x < global_position.x else false
	await DialogManager.dialog_finished

func _on_body_exited(body: Node):
	# Close dialog when player leaves area
	if body.is_in_group("player") and DialogManager.is_dialog_active:
		DialogManager.end_dialog()
