extends CanvasLayer  # or whatever your node type is

func _ready():
	# Connect the signal
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	
	# Play your animation
	$AnimationPlayer.play("cutscene")

func _on_animation_finished(anim_name):
	if anim_name == "cutscene":
		get_tree().change_scene_to_file("res://assets/sprites/heaven/heaven.tscn")
