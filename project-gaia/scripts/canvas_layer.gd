extends CanvasLayer
@onready var aud: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatableBody2D
@onready var anima: AnimatedSprite2D = $AnimatableBody2D2

func _ready():
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func fade_to_black():
	$AnimationPlayer.play("fadeout")

func _on_animation_finished(anim_name):
	if anim_name == "fadeout":
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func play():
	anima.visible = false
	anim.visible = true
	aud.play()
	anim.play()
