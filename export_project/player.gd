extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

@onready var ground_ray = $GroundRayCast # RayCast3D pointant vers le sol
@export var height_above_surface: float = 0.2  # Hauteur à maintenir (20 cm)

@export var jump_force: float = 1000.0
@export var gravity_force: float = -50.0
@export var move_force: float = 1200.0
@export var air_drag: float = 5.0  # Plus grand = ralentit plus vite dans les airs

var vertical_velocity: float = 0.0
var is_jumping: bool = false
var jump_direction: Vector3 = Vector3.ZERO

var is_on_ground = true
var is_resetting = false
		
# Called when the node enters the scene tree for the first time.
func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Connecte le signal "body_entered" dynamiquement
	contact_monitor = true
	max_contacts_reported = 5

	# Utilise bind() pour lier l'argument au signal
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	# Traitement lors de la collision
	
	if body.is_in_group("ground"):
		print("Collision avec :", body.name)
		is_on_ground = true
		
func _on_body_exited(body: Node):
	# Traitement lors de la collision
	
	if body.is_in_group("ground"):
		print("UnCollision avec :", body.name)
		is_on_ground = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_mx = Input.get_action_strength("move_left") * -1
	var input_px = Input.get_action_strength("move_right")
	var input_mz = Input.get_action_strength("move_back")
	var input_pz = Input.get_action_strength("move_forward") * -1

	var input_f = Vector3.ZERO
	input_f.x = input_mx + input_px
	input_f.z = input_mz + input_pz

	#is_on_ground = ground_ray.is_colliding()
	
	#print("pos ", global_transform.origin.x, " ", global_transform.origin.y, " " , global_transform.origin.y)
	
	
	# Gestion du saut
	if is_on_ground:
		if Input.is_action_just_pressed("jump"):
			vertical_velocity = jump_force
			is_jumping = true
			print("Jump !")
		else:
			vertical_velocity = 0.0
			is_jumping = false
	else:
		# Si en l'air, applique la gravité
		#if global_transform.origin.y >= 0:
		#print("hey")
		#var target_position = ground_ray.get_collision_point()
		#print("col ", target_position.x, " ", target_position.y, " " , target_position.y)
		vertical_velocity = gravity_force

	# Combine le mouvement horizontal avec la verticale
	input_f.y = vertical_velocity * delta

	# Appliquer la force totale au joueur
	var movement_force = twist_pivot.basis * Vector3(input_f.x, 0, input_f.z) * move_force * delta
	movement_force.y = vertical_velocity
		
	
	
	if Input.is_action_just_pressed("reset"):
		linear_velocity = Vector3.ZERO  # Remettre la vitesse à zéro
		vertical_velocity = 0.0
		# Réinitialiser la position
		global_transform.origin = $MeshInstance3D.transform.origin
		global_transform.origin.y += 5  # Positionne l'objet 2 unités plus haut
	else:
		apply_central_force(movement_force)
		
	
	# Gestion souris et cam
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))

	twist_input = 0.0
	pitch_input = 0.0
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
