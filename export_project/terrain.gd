extends Node3D

@export var num_grasses : int = 1000  # Nombre d'instances d'herbe
@export var area_size : Vector3 = Vector3(20, 1, 20)  # Taille de la zone
@export var terrain : Node3D  # Référence au terrain (le terrain doit être un mesh ou une surface)

@onready var multi_mesh_instance : MultiMeshInstance3D = $MultiMeshInstance3D  # Référence à l'instance dans l'éditeur
@onready var multi_mesh_instance_smg : MultiMeshInstance3D = $small_grass_multi  # Référence à l'instance dans l'éditeur

@onready var raycast : RayCast3D = $RayCast3D  # Référence à un RayCast3D dans la scène

var menu_scene = preload("res://menu.tscn")
var menu_instance : Node = null

func multi_mesh_start(multi_mesh_inst : MultiMeshInstance3D, scmin, scmax) -> void:
	# Assurer que le RayCast3D est configuré pour pointer vers le bas
	raycast.target_position = Vector3(0, -20, 0)  # On lance le rayon vers le bas pour 10 unités.
	
	# Vérifie si le MultiMeshInstance3D est bien défini
	if multi_mesh_inst:
		var multi_mesh = multi_mesh_inst.multimesh  # Obtenir le MultiMesh associé
		
		# Assurez-vous que le nombre d'instances correspond
		#multi_mesh.instance_count = num_grasses
		
		# Positionner les instances d'herbe de manière aléatoire
		for i in range(multi_mesh.instance_count):
			var random_pos = Vector3(
				randf_range(-area_size.x / 2, area_size.x / 2),
				5,  # La hauteur initiale sera corrigée avec le RayCast3D
				randf_range(-area_size.z / 2, area_size.z / 2)
			)
			
			# Positionner le RayCast à la position aléatoire de l'herbe
			raycast.position = random_pos
			#print(raycast.position.x, " ", raycast.position.y  , " ", raycast.position.z)
			raycast.force_raycast_update()
			
			var collider = raycast.get_collider()
			# Vérifier si le RayCast touche quelque chose
			if raycast.is_colliding() and collider.is_in_group("ground"):
				#print("collision")
				# Obtenir la position du terrain (Y) à cette position X, Z
				var hit_position = raycast.get_collision_point()
				
				# Ajuster la position de l'instance d'herbe pour respecter le terrain
				random_pos.y = hit_position.y  # Ajuste la hauteur à la collision du terrain
			else:
				random_pos = Vector3(0, 0, 0)
			
			var _transform = Transform3D(Basis())  # Position seulement (pas de rotation ici)
			var sz = randf_range(scmin, scmax)
			_transform = transform.scaled(Vector3(sz, sz, sz))  # Appliquer le scale après
			_transform.origin = random_pos
			# Appliquer la transformation à l'instance
			multi_mesh.set_instance_transform(i, _transform)
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multi_mesh_start(multi_mesh_instance, 0.5, 1.5)
	multi_mesh_start(multi_mesh_instance_smg, 0.01, 0.015)
	
	show_menu()
	
func show_menu():
	# Vérifier si le menu est déjà affiché
	if menu_instance == null:
		# Instancier la scène du menu
		menu_instance = menu_scene.instantiate()

		# Ajouter le menu à la scène principale
		add_child(menu_instance)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func process_slider_hauteur_grass()->void:
	var slider = menu_instance.get_node("Panel/HSlider")  # Accéder au nœud Slider
	var hauteur = slider.value / 200.0
	
	var slidernb = menu_instance.get_node("Panel/HSliderNombreGrass")  # Accéder au nœud Slider
	multi_mesh_instance.multimesh.instance_count = slidernb.value
	
	multi_mesh_start(multi_mesh_instance, hauteur, hauteur + 1.0)
