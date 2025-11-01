extends CharacterBody2D

# --- Movement constants ---
const SPEED := 110.0
const PUSH_SPEED := 20.0     # slower when pushing
const JUMP_VELOCITY := -150.0

# --- References ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# --- State ---
var is_pushing := false
var is_controlled: bool = false    # <- possession toggle

func _ready() -> void:
	add_to_group("possessable")

func enable_control(state: bool) -> void:
	is_controlled = state
	if not state:
		velocity = Vector2.ZERO  # stop moving when unpossessed

func _physics_process(delta: float) -> void:
	if not is_controlled:
		return  # no control unless possessed

	is_pushing = false  # reset each frame

	# --- Apply gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Handle jump ---
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Get horizontal input (-1 = left, 1 = right) ---
	var direction := Input.get_axis("Left", "Right")

	# --- Flip sprite horizontally ---
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# --- MOVE PLAYER ---
	velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)

	# --- Move and handle collisions ---
	move_and_slide()

	# --- PUSH DETECTION ---
	var pushing_this_frame := false
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			if collision.get_collider() is RigidBody2D:
				var normal := collision.get_normal()
				var push_force := -normal * 20.0
				collision.get_collider().apply_central_impulse(push_force)

				if (direction > 0 and normal.x < 0) or (direction < 0 and normal.x > 0):
					pushing_this_frame = true

	# --- APPLY SLOWDOWN IF PUSHING ---
	if pushing_this_frame and is_on_floor():
		velocity.x = move_toward(velocity.x, direction * PUSH_SPEED, SPEED)

	is_pushing = pushing_this_frame

	update_animation(direction)


func update_animation(direction: float) -> void:
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("Left")
	else:
		animated_sprite_2d.play("No_Ghost")


func teleport(target_teleporter: Teleporter, offset: Vector2):
	global_position = target_teleporter.global_position + offset
