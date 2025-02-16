extends CharacterBody3D

@export var wealth: int = 100000
@export var wealth_reward: int = 100000

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	$WealthLabel.text = "Wealth: $" + str(wealth)


func hurt(_damage: int) -> float: 
	wealth -= _damage
	if wealth <= 0:
		die()
		return wealth_reward
	else: 
		return 0

func die() -> void:
	queue_free()
