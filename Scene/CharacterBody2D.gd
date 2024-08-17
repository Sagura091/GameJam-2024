extends CharacterBody2D

var speed = 200
var gravity = 500
var jump_force = -300
var wall_slide_speed = 50
var wall_jump_force = Vector2(-300, -400)
var is_on_wall = false
var is_wall_sliding = false
var is_grabbing_wall = false


func _input(event):
	handle_grab(event)
	handle_jump(event)
	
func handle_grab(event):
	if event.is_action_pressed("grab"):
		is_grabbing_wall = true
	elif event.is_action_released("grab"):
		is_grabbing_wall = false
		
func handle_jump(event):
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump()
		elif is_wall_sliding:
			wall_jump()


func process_movement():
	velocity.x = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= speed


func _physics_process(delta):
	apply_gravity(delta)
	process_movement()
	check_wall_interaction()
	apply_movement()


func apply_gravity(delta):
	velocity.y += gravity * delta


func check_wall_interaction():
	if is_on_wall and not is_on_floor():
		if is_grabbing_wall:
			grab_wall()
		else:
			start_wall_slide()
	else:
		stop_wall_slide()


func apply_movement():
	move_and_slide()
	
func jump():
	velocity.y = jump_force

func wall_jump():
	velocity.y = wall_jump_force.y
	velocity.x = wall_jump_force.x * -sign(velocity.x)


func start_wall_slide():
	is_wall_sliding = true
	velocity.y = min(velocity.y, wall_slide_speed)

func stop_wall_slide():
	is_wall_sliding = false

func grab_wall():
	velocity.y = 0  # Stop falling
