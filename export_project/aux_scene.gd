extends Node3D


@onready var anim_player = $Node/AnimationPlayer
@onready var rigidbody3d = $Node/Skeleton3D/RigidBody3D #$Node/Skeleton3D/RigidBody3D

@onready var twist_pivot := $Node/Skeleton3D/RigidBody3D/TwistPivot #$Node/Skeleton3D/RigidBody3D/TwistPivot
@onready var pitch_pivot := $Node/Skeleton3D/RigidBody3D/TwistPivot/PitchPivot #$Node/Skeleton3D/RigidBody3D/TwistPivot/PitchPivot
@onready var camera := $Node/Skeleton3D/RigidBody3D/TwistPivot/PitchPivot/Camera3D #$Node/Skeleton3D/RigidBody3D/TwistPivot/PitchPivot/Camera3D

@export var jump_force: float = 300.0
@export var gravity_force: float = -50.0

var twist_speed = 2.0 # Vitesse de rotation en radians/seconde
var is_jumping: bool = false
var vertical_velocity: float = 0.0
var is_on_ground = true

var mouse_sensitivity := 0.01
var twist_input := 0.0
var pitch_input := 0.0
var play := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.make_current()
	rigidbody3d.body_entered.connect(_on_body_entered)
	rigidbody3d.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	# Traitement lors de la collision
	
	if body.is_in_group("ground"):
		print("Collision char avec :", body.name)
		is_on_ground = true
		
func _on_body_exited(body: Node):
	# Traitement lors de la collision
	
	if body.is_in_group("ground"):
		print("UnCollision char  avec :", body.name)
		is_on_ground = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_mx = Input.get_action_strength("move_left_monster") 
	var input_px = Input.get_action_strength("move_right_monster")* -1
	var input_mz = Input.get_action_strength("move_back_monster") * -1
	var input_pz = Input.get_action_strength("move_forward_monster")

	var input_f = Vector3.ZERO
	input_f.x = input_mx + input_px
	input_f.z = input_mz + input_pz
	
	if is_on_ground:
		if Input.is_action_just_pressed("jump_joypad"):
			vertical_velocity = jump_force
			is_jumping = true
			print("Jump !")
		else:
			vertical_velocity = 0.0
			is_jumping = false
	else:
		vertical_velocity = gravity_force

		
	var movement_force = twist_pivot.basis * Vector3(input_f.x, 0, input_f.z) * 1200.0 * delta
	movement_force.y = vertical_velocity
	
	if Input.is_action_just_pressed("reset_monster"):
		rigidbody3d.linear_velocity = Vector3.ZERO  # Remettre la vitesse à zéro
		vertical_velocity = 0.0
		# Réinitialiser la position
		rigidbody3d.global_transform.origin = Vector3(0, 5, 0)
		
	else:
		rigidbody3d.apply_central_force(movement_force)
	
	if rigidbody3d.linear_velocity.length() >= 0.1:
		anim_player.play("FastRun")
	else:
		anim_player.play("MutantIdle")
	
	twist_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if twist_input > 0.1:
		twist_pivot.rotate_y(-twist_speed * delta)
	elif twist_input < -0.1:
		twist_pivot.rotate_y(twist_speed * delta)
		
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-10), deg_to_rad(30))
	
	twist_input = 0.0
	pitch_input = 0.0


func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventJoypadMotion:
		#if event.axis == JOY_AXIS_RIGHT_X:
		#	twist_input = -event.axis_value
			
		if event.axis == JOY_AXIS_RIGHT_Y:
			pitch_input = -event.axis_value * 0.1
			
		
		
