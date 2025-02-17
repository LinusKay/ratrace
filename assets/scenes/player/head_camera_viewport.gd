extends SubViewport

@export var target_fps: float = 5.0  # Desired FPS for the SubViewport

var frame_count: int = 0
var update_interval: int = 12  # Default estimate based on 60 FPS
var fps_check_timer: float = 0.0

func _ready() -> void:
	# Set an estimated interval first (assuming 60 FPS)
	update_interval = max(1, int(60 / target_fps))
	#print("Initial estimated update interval:", update_interval)

	# Delay actual FPS calculation to let the engine stabilize
	await get_tree().create_timer(1.0).timeout  # Wait 1 second
	calculate_update_interval()

func calculate_update_interval() -> void:
	var engine_fps: float = Engine.get_frames_per_second()
	if engine_fps > 0 and target_fps > 0:
		update_interval = max(1, int(engine_fps / target_fps))  # Ensure at least 1
		#print("Recalculated update interval:", update_interval)

func _process(delta: float) -> void:
	frame_count += 1

	# Periodically check FPS and recalculate update interval
	fps_check_timer += delta
	if fps_check_timer >= 1.0:  # Update every second
		calculate_update_interval()
		fps_check_timer = 0.0

	# Update viewport at the calculated interval
	if frame_count % update_interval == 0:
		render_target_update_mode = SubViewport.UPDATE_ONCE  # Force update
