#kid script

extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_zone: Area2D = $PickupZone


const lines: Array[String] = [
	"me want food", 
	"me want to music box",
	"I want my mommy","call my  Mommy","Her room...",
	"Iz cownectid to de vents"
]

var has_food: bool = false
var has_music_box: bool = false
var current_line_index: int = 0

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.body_exited.connect(_on_body_exited)
	
	# Connect pickup zone
	pickup_zone.body_entered.connect(_on_pickup_zone_body_entered)

func _on_interact():
	# Determine which line to show based on item progress
	if !has_food:
		current_line_index = 0
	elif has_food && !has_music_box:
		current_line_index = 1
	else:
		# After getting both items, show lines 2, 3, 4, 5 in sequence
		if current_line_index < 2:
			current_line_index = 2
		else:
			current_line_index = min(current_line_index + 1, lines.size() - 1)
	
	# Show the appropriate dialog line
	var current_lines: Array[String] = [lines[current_line_index]]
	
	DialogManager.start_dialog(global_position, current_lines, null)
	
	# Flip sprite based on player position
	if interaction_area.get_overlapping_bodies().size() > 0:
		var player = interaction_area.get_overlapping_bodies()[0]
		sprite.flip_h = true if player.global_position.x < global_position.x else false
	
	await DialogManager.dialog_finished

func _on_body_exited(body: Node):
	# Close dialog when player leaves area
	if body.is_in_group("player") and DialogManager.is_dialog_active:
		DialogManager.end_dialog()

func _on_pickup_zone_body_entered(body: Node):
	print("Pickup zone entered by: ", body.name)
	print("Body groups: ", body.get_groups())
	
	# Check for milk (food)
	if body.is_in_group("milk") and !has_food:
		print("Milk detected! Giving to kid...")
		has_food = true
		body.queue_free()
		print("Kid got milk!")
	
	# Check for music box (requires food first)
	elif body.is_in_group("music_box") and has_food and !has_music_box:
		print("Music box detected! Giving to kid...")
		has_music_box = true
		body.queue_free()
		print("Kid got music box!")
