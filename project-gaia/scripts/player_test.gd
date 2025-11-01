# player script with push/pull functionality
extends CharacterBody2D

# --- Movement constants ---
const SPEED := 110.0
const PUSH_SPEED := 40.0     # slower when pushing
const JUMP_VELOCITY := -150.0

# --- References ---
@onready var animated_sprite: AnimatedSprite2D = $Playeranimate

# --- State ---
var is_pushing := false
var is_grabbing := false
var grabbed_object: RigidBody2D = null
var grab_offset := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	is_pushing = false  # reset each frame

	# Handle grab/release input
	handle_grab_input()

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get horizontal input (-1 = left, 1 = right)
	var direction := Input.get_axis("Left", "Right")

	# Flip sprite horizontally
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# --- MOVE PLAYER ---
	if is_grabbing and grabbed_object:
		# Slower movement when grabbing
		velocity.x = move_toward(velocity.x, direction * PUSH_SPEED, SPEED)
		
		# Update grabbed object position
		update_grabbed_object()
	else:
		# Normal movement
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)

	# Move and handle collisions
	move_and_slide()

	# --- PUSH DETECTION (only when not grabbing) ---
	var pushing_this_frame := false
	if get_slide_collision_count() > 0 and not is_grabbing:
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			if collision.get_collider() is RigidBody2D:
				var normal := collision.get_normal()
				# Push the block
				var push_force := -normal * 40.0
				collision.get_collider().apply_central_impulse(push_force)
				
				# If player is pressing toward the block, we're pushing it
				if (direction > 0 and normal.x < 0) or (direction < 0 and normal.x > 0):
					pushing_this_frame = true

	# --- APPLY SLOWDOWN IF PUSHING ---
	if pushing_this_frame and is_on_floor() and not is_grabbing:
		velocity.x = move_toward(velocity.x, direction * PUSH_SPEED, SPEED)

	is_pushing = pushing_this_frame

	update_animation(direction)

func handle_grab_input() -> void:
	if Input.is_action_just_pressed("grab"):
		if not is_grabbing:
			# Try to grab nearby object
			try_grab_object()
		else:
			# Release currently grabbed object
			release_object()

func try_grab_object() -> void:
	# Check for nearby RigidBody2D objects in front of player using area detection
	var grab_area = $GrabArea  # We'll add this Area2D node
	
	# If we don't have a grab area, use overlap query
	if not grab_area:
		# Alternative method: check area around player
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		
		# Create a small detection area in front of player
		var shape = RectangleShape2D.new()
		shape.size = Vector2(10, 10)
		query.shape = shape
		
		# Position in front of player based on facing direction
		var facing_dir = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		query.transform = Transform2D(0, global_position + facing_dir * 5)
		query.collision_mask = 1  # Adjust to match your block's collision layer
		query.exclude = [self]
		
		var results = space_state.intersect_shape(query, 1)
		
		for result in results:
			if result.collider is RigidBody2D:
				grab_object(result.collider)
				break
	else:
		# Use the grab area method
		var bodies = grab_area.get_overlapping_bodies()
		for body in bodies:
			if body is RigidBody2D and body != self:
				grab_object(body)
				break

func grab_object(obj: RigidBody2D) -> void:
	grabbed_object = obj
	is_grabbing = true
	
	# Make the object kinematic while grabbed (for smooth movement)
	grabbed_object.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	grabbed_object.freeze = true
	
	# Calculate offset from player to object
	grab_offset = grabbed_object.global_position - global_position

func release_object() -> void:
	if grabbed_object and is_instance_valid(grabbed_object):
		# Restore physics properties
		grabbed_object.freeze = false
		grabbed_object.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		
		# Apply some velocity based on player movement
		grabbed_object.linear_velocity = velocity * 0.5
	
	grabbed_object = null
	is_grabbing = false
	grab_offset = Vector2.ZERO

func update_grabbed_object() -> void:
	if grabbed_object and is_instance_valid(grabbed_object):
		# Calculate target position (slightly in front of player)
		var facing_dir = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		var target_position = global_position + facing_dir * 12
		
		# Smoothly move the object to target position
		grabbed_object.global_position = target_position
		
		# Prevent object rotation while grabbed
		grabbed_object.rotation = 0
	else:
		# Object was destroyed or became invalid
		release_object()

func update_animation(direction: float) -> void:
	if is_on_floor():
		if direction == 0:
			if is_grabbing:
				animated_sprite.play("idle")  # Use regular idle for now
			else:
				animated_sprite.play("idle")
		else:
			if is_grabbing:
				animated_sprite.play("run")  # Use regular run for now
			else:
				animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func teleport(target_teleporter: Teleporter, offset: Vector2):
	# Release object when teleporting
	if is_grabbing:
		release_object()
	global_position = target_teleporter.global_position + offset
