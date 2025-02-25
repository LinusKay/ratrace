extends AnimatedSprite2D

var bob: float = 0

var is_running: bool = false
var is_sliding: bool = false

var emote_bank: Array = ["emote_watch", "emote_thumbs_up", "emote_newspaper", "emote_fingergun"]
var emotes: Array = emote_bank.duplicate()
var emote_previous: Array = []

var punch_bank: Array = ["punch_left", "punch_right", "kick_right", "the_belt", "elbow_left"]
var punches: Array = punch_bank.duplicate()
var punch_previous: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("idle_fists")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation == "idle_fists":
		if is_running:
			animation = "run"
		if is_sliding:
			animation = "slide"
		bob += delta + .1
		position.y = sin(bob) * 10
	elif animation == "run":
		if !is_running: 
			animation = "idle_fists"
		if is_sliding:
			animation = "slide"
		bob += delta + .2
		position.y = sin(bob) * 30
	elif animation == "slide":
		if !is_sliding:
			animation = "idle_fists"
		if is_running:
			animation = "run"
		bob += delta + .5
		position.y = sin(bob) * 5
	else: 
		position.y = 0

func emote() -> void:
	var emote: String = emotes.pick_random()
	play(emote)
	if(emotes.size() > 1):
		emotes.erase(emote)
		emote_previous.append(emote)
	else:
		emotes = emote_bank.duplicate()

func punch() -> void:
	var punch: String = punches.pick_random()
	play(punch)
	if(punches.size() > 1):
		punches.erase(punch)
		punch_previous.append(punch)
	else:
		punches = punch_bank.duplicate()

func regret() -> void:
	play("regret")

func run() -> void:
	is_running = true
	is_sliding = false
	
func walk() -> void:
	is_running = false
	is_sliding = false

func slide() -> void:
	is_running = false
	is_sliding = true

func _on_animation_finished() -> void:
	if is_running:
		play("run")
	elif is_sliding:
		play("slide")
	else:
		play("idle_fists")
