extends Node3D

@onready var sfx_metal_hit: Resource = load("res://assets/sounds/sfx/metal_hit.ogg")
@onready var hit_sounds: Array = [sfx_metal_hit]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
