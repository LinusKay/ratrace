extends Node3D

@onready var player: Player = get_parent().player

var enemy: Resource = load("res://assets/scenes/enemy/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_enemy() -> void:
	var enemy_instance: CharacterBody3D = enemy.instantiate()
	get_parent().add_child.call_deferred(enemy_instance)
	enemy_instance.player = player
	enemy_instance.activity =  "random"
	enemy_instance.position = position
	print(position, ", ", enemy_instance.position)

func spawn_enemy_nearby(distance: int = 5) -> void:
	var enemy_instance: CharacterBody3D = enemy.instantiate()
	get_parent().add_child.call_deferred(enemy_instance)
	enemy_instance.player = player
	enemy_instance.activity =  "random"
	var rand_x: float = randf_range(-distance, distance)
	var rand_z: float = randf_range(-distance, distance)
	enemy_instance.position.x = position.x + rand_x
	enemy_instance.position.z = position.z + rand_z
	print(position, ", ", enemy_instance.position)
	
