extends Control
class_name UI

var wealth_tracker: Array = []
var wealth_plot: RefCounted
var wealth: int = 0
var plot_colour: Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_combo(0)
	ready_wealth_graph()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_combo(_combo_count: int) -> void:
	$ComboLabel.text = "" + str(_combo_count)
	$ComboLabel.label_settings.font_size = randi_range(75, 120)
	$ComboLabel.rotation = randf_range(-.2, .5)
	if(_combo_count >= 0):
		$ComboLabel.label_settings.font_color = Color.WHITE
	if(_combo_count >= 5):
		$ComboLabel.label_settings.font_color = Color.LIGHT_YELLOW
	if(_combo_count >= 10):
		$ComboLabel.label_settings.font_color = Color.YELLOW
	if(_combo_count >= 15):
		$ComboLabel.label_settings.font_color = Color.ORANGE
	if(_combo_count >= 20):
		$ComboLabel.label_settings.font_color = Color.ROYAL_BLUE
	if(_combo_count >= 25):
		$ComboLabel.label_settings.font_color = Color.BLUE
	if(_combo_count >= 30):
		$ComboLabel.label_settings.font_color = Color.PURPLE

func update_wealth(_wealth: int) -> void:
	wealth = _wealth
	$WealthLabel.text = "Wealth: $" + str(wealth)

func ready_wealth_graph() -> void:
	wealth_plot = $WealthGraph.add_plot_item(
		"Wealth",
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
