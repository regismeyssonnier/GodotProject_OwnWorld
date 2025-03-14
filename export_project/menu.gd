extends Node2D
# Références aux éléments UI
@onready var slider = $Panel/HSlider
@onready var label = $Panel/Label
@onready var slidernb = $Panel/HSliderNombreGrass
@onready var labelnb = $Panel/Lable_Nombre_Grass
@onready var fps_label = $Panel/LabelFPS

@export var hauteur = 1.0

# Variable de hauteur de l'herbe
var grass_height = 1.0  # Valeur initiale de la hauteur de l'herbe

func _ready():
	# Connecter le signal de changement de valeur du slider
	slider.connect("value_changed", _on_slider_value_changed)
	slidernb.connect("value_changed", _on_slidernb_value_changed)
	label.text = "Hauteur %.2f" % grass_height
	
# Fonction qui sera appelée lors du changement de valeur du slider
func _on_slider_value_changed(value: float):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Mettre à jour la hauteur de l'herbe
	grass_height = value
	
	var parent = get_parent()
	if parent.has_method("process_slider_hauteur_grass"):
		parent.process_slider_hauteur_grass()
	
	# Mettre à jour le label pour afficher la nouvelle valeur
	label.text = "Hauteur %.2f" % grass_height

# Fonction qui sera appelée lors du changement de valeur du slider
func _on_slidernb_value_changed(value: float):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var parent = get_parent()
	if parent.has_method("process_slider_hauteur_grass"):
		parent.process_slider_hauteur_grass()
	
	# Mettre à jour le label pour afficher la nouvelle valeur
	labelnb.text = "Nombre %.2f" % value

func _process(delta):
	fps_label.text = "FPS : " + str(Engine.get_frames_per_second())
	
