extends CharacterBody3D

@export var hud: UI
@export var audio_controller: AudioStreamPlayer

@onready var head: Node3D = $Head
@onready var spring_arm: SpringArm3D = $Head/SpringArm3D
@onready var camera: Camera3D = $Head/SpringArm3D/Camera3D
@onready var fists: AnimatedSprite2D = hud.get_node("FistPlacement/FistSprite")
@onready var hitbox: Area3D = %Hitbox
@onready var combo_timer: Timer = $ComboTimer

@onready var sfx_emote: Resource = load("res://assets/sounds/sfx/honk.ogg")
@onready var sfx_swish: Resource = load("res://assets/sounds/sfx/swish.ogg")
@onready var sfx_swish_short: Resource = load("res://assets/sounds/sfx/swish_short.ogg")
@onready var sfx_hit1: Resource = load("res://assets/sounds/sfx/hit1.ogg")
@onready var sfx_hit2: Resource = load("res://assets/sounds/sfx/hit2.ogg")
@onready var sfx_hit3: Resource = load("res://assets/sounds/sfx/hit3.ogg")
@onready var sfx_hit4: Resource = load("res://assets/sounds/sfx/hit4.ogg")
@onready var sfxgroup_hit: Array = [sfx_hit1, sfx_hit2, sfx_hit3, sfx_hit4]

const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const SLIDE_SPEED = 15.0
const SPRINT_SLIDE_TIMEOUT = 0.5
const SLIDE_TIME = 0.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
const CAMERA_LIMIT_DOWN = -60
const CAMERA_LIMIT_UP = 80
const MELEE_DAMAGE = 10000
const COMBO_TIMEOUT = 1.0
const EMOTE_TIMEOUT = 1.0

var wealth: float = 1000
var desired_speed: float
var speed: float
var t_bob: float = 0.0
var fov_lock: bool = false
var is_attacking: bool = false
var combo_count: int = 0
var is_sliding: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event: InputEvent) -> void:
		
	if Input.is_action_just_pressed("attack"):
		melee()
	
	if Input.is_action_just_pressed("emote"):
		emote()
	
	# Quit game on ESC
	if Input.is_action_pressed("debug_quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("debug_restart"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("debug_hurt"):
		wealth -= 5756
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		spring_arm.rotate_x(-event.relative.y * SENSITIVITY)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(CAMERA_LIMIT_DOWN), deg_to_rad(CAMERA_LIMIT_UP))


func _physics_process(delta: float) -> void:
	hud.update_wealth(wealth)
	wealth -= 1

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

		
	# Handle Sprint
	if Input.is_action_pressed("sprint"):
		desired_speed = SPRINT_SPEED
		$SprintSlideTimer.start(SPRINT_SLIDE_TIMEOUT)
		fists.run()
	else:
		if !is_sliding:
			fists.walk()
			desired_speed = WALK_SPEED
	
	if Input.is_action_pressed("crouch"):
		head.position.y = 1
		if !$SprintSlideTimer.is_stopped():
			$SlideTimer.start(SLIDE_TIME)
			is_sliding = true
			fists.slide()
	
	if Input.is_action_just_released("crouch"):
		is_sliding = false
		head.position.y = 1.5
	
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")

	if is_sliding: 
		desired_speed = SLIDE_SPEED - (SLIDE_TIME / $SlideTimer.time_left)
		
	speed = clampf(lerpf(speed, desired_speed, .5), 0, 100)
	
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	if is_sliding: t_bob = 0
	else: t_bob += delta * velocity.length() * float(is_on_floor())
	spring_arm.transform.origin = _headbob(t_bob)

	if(!fov_lock):
		var velocity_clamped: float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
	
	# Head Camera follow/bob
	%HeadCameraNode.global_position = head.global_position
	%HeadCameraNode.transform.basis = head.transform.basis
	%HeadCamera.transform.origin = %SpringArm3D.transform.origin
	

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func melee() -> void:
	fists.punch()
	audio_controller.play_sfx(sfx_swish)
	for body: Object in hitbox.get_overlapping_bodies():
		print(body)
		if body.is_in_group("hittable"):
			audio_controller.play_sfx_random(sfxgroup_hit)
		if body.is_in_group("enemy"):
			var enemy_killed: float = body.hurt(MELEE_DAMAGE)
			melee_success()
			if enemy_killed > 0:
				wealth += enemy_killed * combo_count/10
				fists.regret()

func melee_success() -> void:
	combo_increase()

func combo_increase() -> void:
	$ComboTimer.start(COMBO_TIMEOUT)
	combo_count += 1
	hud.update_combo(combo_count)
	pass

func combo_clear() -> void:
	combo_count = 0
	hud.update_combo(combo_count)
	pass

func _on_combo_timer_timeout() -> void:
	combo_clear()


func _on_slide_timer_timeout() -> void:
	is_sliding = false

func emote() -> void:
	if $EmoteTimer.is_stopped():
		$EmoteTimer.start(EMOTE_TIMEOUT)
		combo_increase()
		fists.emote()
		audio_controller.queue_sfx([sfx_swish_short, sfx_emote])
