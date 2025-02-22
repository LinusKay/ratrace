extends Control
class_name UI

@export var player: CharacterBody3D

@onready var mascot_polyfox: AnimatedSprite2D = $PlayerHeadCameraRect/MascotSpritePolyfox

var wealth_tracker: Array = []
var wealth_plot: RefCounted
var wealth: int = 0
var plot_colour: Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_combo(0)
	ready_wealth_graph()
	mascot_polyfox.play("polyfox")
	#$MascotSprite2.play("malpal")
	#$MascotSprite3.play("srimp")
	$PlayerHeadCameraRect.texture = player.get_node("Head/HeadCameraViewport").get_texture()
	#mascot_polyfox.play("polyfox")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_combo(_combo_count: int) -> void:
	$ComboLabel.text = "" + str(_combo_count)
	$ComboLabel.label_settings.font_size = randi_range(75, 120)
	$ComboLabel.rotation = randf_range(-.2, .5)
	update_combo_colour(_combo_count)

func update_combo_colour(_combo_count: int) -> void:
	var colors: Array[Color] = [
		Color.WHITE,       # 0+
		Color.LIGHT_YELLOW, # 5+
		Color.YELLOW,       # 10+
		Color.ORANGE,       # 15+
		Color.ROYAL_BLUE,   # 20+
		Color.BLUE,         # 25+
		Color.PURPLE,        # 30+
		Color.PINK,
		Color.HOT_PINK,
		Color.DEEP_PINK,
		Color.RED,
	]

	$ComboLabel.label_settings.font_color = colors[min(_combo_count / 5, colors.size() - 1)]

func update_wealth(_wealth: int) -> void:
	wealth = _wealth
	$WealthLabel.text = "$" + str(wealth)

func ready_wealth_graph() -> void:
	wealth_plot = $WealthGraph.add_plot_item(
		"",
		plot_colour,
		1
		)

func clear_wealth_graph() -> void:
	wealth_plot.remove_all()

func update_wealth_graph() -> void:
	wealth_tracker.append(wealth)
	if wealth_tracker.size() >= $WealthGraph.x_max:
		wealth_tracker.pop_front()
	clear_wealth_graph()
	var wealth_peak: int = 0
	var wealth_trough: int = wealth_tracker[0]
	for _index: int in wealth_tracker.size():
		var wealth_point: int = wealth_tracker[_index]
		if wealth_point > wealth_peak:	 wealth_peak = wealth_point
		if wealth_point < wealth_trough: wealth_trough = wealth_point
		wealth_plot.add_point(Vector2(_index, wealth_point))
	$WealthGraph.y_max = wealth_peak * 1.1
	$WealthGraph.y_min = wealth_trough * 1.1
	if(wealth_tracker.size() > 1):
		if wealth_tracker[-1] > wealth_tracker[-2]:
			wealth_plot.color = Color.GREEN
		else:
			wealth_plot.color = Color.RED

func _on_wealth_graph_timer_timeout() -> void:
	update_wealth_graph()
