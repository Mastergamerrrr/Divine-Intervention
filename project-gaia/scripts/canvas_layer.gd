extends CanvasLayer

func _ready():
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func fade_to_black():
	$AnimationPlayer.play("fadeout")

func _on_animation_finished(anim_name):
	if anim_name == "fadeout":
		get_tree().change_scene_to_file("res://scenes/game.tscn")
