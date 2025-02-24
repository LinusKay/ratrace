extends AudioStreamPlayer

#@onready var bgm_softstabs: Resource = load("res://assets/sounds/music/softstabs.ogg")
#@onready var bgm_noptune: Resource = load("res://assets/sounds/music/noptune.ogg")
@onready var bgm_pigcity: Resource = preload("res://assets/sounds/music/pigcity.ogg")
@onready var bgms: Array = [bgm_pigcity]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_bgm(bgms.pick_random())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_sfx(_sfx: Resource) -> void:
	var audio_node: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = _sfx
	audio_node.bus = "Sound Effects"
	audio_node.play()
	await audio_node.finished
	audio_node.queue_free()

func queue_sfx(_sfx_queue: Array) -> void:
	for _sfx_index in _sfx_queue.size():
		var _sfx_item: Resource = _sfx_queue[_sfx_index]
		var audio_node: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(audio_node)
		audio_node.stream = _sfx_item
		audio_node.bus = "Sound Effects"
		audio_node.play()
		await audio_node.finished
		audio_node.queue_free()

func play_sfx_random(_sfxgroup: Array) -> void:
	var _choice: Resource = _sfxgroup.pick_random()
	play_sfx(_choice)

func set_bgm(_bgm: Resource) -> void:
	stream = _bgm
	play()

func play_bgm() -> void:
	play()

func pause_bgm() -> void:
	stop()
