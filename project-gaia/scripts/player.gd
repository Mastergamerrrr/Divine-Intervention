extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -150.0
@onready var animated_sprite: AnimatedSprite2D = $Playeranimate

var movement_enabled: bool = true

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# GETS INPUT DIRECTION
	var direction := 0.0
	if movement_enabled:
		direction = Input.get_axis("Left", "Right")
	
	# FLIP SPRITE
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# APPLY MOVEMENT
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation(direction)

func update_animation(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func set_movement_enabled(enabled: bool):
	movement_enabled = enabled

# Add to your player script
func teleport(target_teleporter: Teleporter, offset: Vector2):
	global_position = target_teleporter.global_position + offset
