extends SubViewport

@export var target_fps: float = 5.0  # Desired FPS for the SubViewport

var frame_count: int = 0
var update_interval: int = 12  # Default estimate based on 60 FPS
var fps_check_timer: float = 0.0

func _ready() -> void:
	# Set an estimated interval first (assuming 60 FPS)
	update_interval = max(1, int(60 / target_fps))

func _process(delta: float) -> void:
	frame_count += 1

	# Periodically check FPS and recalculate update interval
	fps_check_timer += delta

	# Update viewport at the calculated interval
	if frame_count % update_interval == 0:
		render_target_update_mode = SubViewport.UPDATE_ONCE  # Force update
