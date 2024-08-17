extends CharacterBody2D

var SPEED = 500.0
var JUMP_VELOCITY = -900.0
var landed = true
var canjump = false
var walljumppushback = 400.0
var wall_slide_speed = 30.0  # Speed at which the player slides down the wall
var is_grabbing = false
var can_grab_wall = true  # Boolean to determine if the player can grab the wall
var wall_grab_cooldown = 1.0  # 1-second cooldown
var grab_cooldown_timer = 0.0

var scale_timer = 0.0  # Timer to control scaling
var scale_rate = 0.1  # Rate at which the character scales over time
var original_scale = Vector2(1, 1)  # Store the original scale

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Reference to the player sprite and the collision area (assuming you have an Area2D node)
@onready var player_sprite = $PlayerSprite  # Change 'PlayerSprite' to the actual name of your Sprite2D node
@onready var collision_area = $Area2D  # Reference to your Area2D node for detecting collisions

func _ready():
	# Initialize the scale of the character
	scale = original_scale
	
	# Debug print to confirm that _ready is being called
	print("Player script ready.")
	
	# Connect the body_entered signal to the _on_body_entered method
	if collision_area:
		collision_area.connect("body_entered", Callable(self, "_on_body_entered"))
		print("Signal connected to _on_body_entered")  # Debug print to confirm signal connection

func _physics_process(delta):
	# Handle the wall grab cooldown timer
	if grab_cooldown_timer > 0:
		grab_cooldown_timer -= delta
	else:
		can_grab_wall = true

	# Add gravity.
	if not is_on_floor() and !is_grabbing:
		velocity.y += gravity * delta

	# Handle wall grab.
	if Input.is_action_pressed("grab") and is_on_wall() and can_grab_wall:
		is_grabbing = true
		velocity.y = wall_slide_speed  # Slow down the vertical velocity to slide slowly down
	else:
		is_grabbing = false

	# Handle jumping.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_grabbing:
			velocity.y = JUMP_VELOCITY
			# Push the player away from the wall slightly when jumping off the wall.
			if Input.is_action_pressed("right"):
				velocity.x = -walljumppushback
			elif Input.is_action_pressed("left"):
				velocity.x = walljumppushback
			
			# Start the wall grab cooldown
			can_grab_wall = false
			grab_cooldown_timer = wall_grab_cooldown

	# Handle movement.
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor() and !Input.is_action_pressed("ui_accept"):
		canjump = true
	else:
		canjump = false

	if is_on_floor() and velocity.y == 0:
		landed = true
	else:
		landed = false

	move_and_slide()

	# Flip the sprite based on direction.
	if velocity.x > 0:
		player_sprite.flip_h = false  # Flip sprite to face right
	elif velocity.x < 0:
		player_sprite.flip_h = true   # Flip sprite to face left

	# Scale the character over time
	scale_timer += delta
	var new_scale = Vector2(scale.x + scale_rate * delta, scale.y + scale_rate * delta)
	scale = new_scale

func _on_area_2d_body_entered(body):
	print("Body entered:", body.name)  # Debug print to show which body entered the collision area
	scale = original_scale  # Reset the player scale to the original size
