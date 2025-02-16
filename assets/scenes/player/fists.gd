extends AnimatedSprite3D

var left_available: bool = true
var right_available: bool = true
var bob: float = 0

var emotes: Array = ["emote_watch", "emote_thumbs_up"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("idle_fists")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation == "idle_fists":
		bob += delta + .1
		position.y = -0.243 + sin(bob) / 50
	else: 
		position.y = 0

func emote() -> void:
	var emote: String = emotes.pick_random()
	play(emote)

func punch() -> void:
	play("punch_left")

func regret() -> void:
	play("regret")

func _on_animation_finished() -> void:
	play("idle_fists")
