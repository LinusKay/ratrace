extends CharacterBody3D

@export var player: CharacterBody3D
@export var wealth: int = 100000
@export var wealth_reward: int = 100000

@onready var hitbox: Area3D = %Hitbox

var melee_damage: int = wealth * 0.1

var is_staring: bool = false
var is_speaking: bool = false
var wealth_min: int = 10000
var wealth_max: int = 1000000

var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_timer: float = 0.0

var speed: float = 2.0
var speed_min: float = 1.0
var speed_max: float = 3.0
var speed_chase: float = 4.0
var rotation_speed: float = 8.0

var rotation_goal: Quaternion

var activities: Array[String] = [
	"stand",
	"roam",
	#"chase"
]
@export_enum("random", "stand", "roam", "chase") var activity: String = "random"

#var activity: String = activities.pick_random()
var hurt_reaction: String

var personality_bank: Dictionary = {
	"investor_bad" = {
		"speech" : [
			"I lost all my SpinkCoin on Gobler...",
			"That's it, I'm selling all my GobCoin",
			""
		],
		"speech_hurt": [
			"Just take all my money...",
			"Why",
			"Do I owe you money?",
			"Do your worst."
		],
		"wealth": [0, 10000],
		"hurt_reaction": ["freeze", "flight"]
	},
	"investor_good" = {
		"speech": [
			"I need to diversify into more milk-based brands.",
			"YOU'RE FIRED!",
			"YOU'RE HIRED!",
			"BUY BUY BUY!",
			"SELL SELL SELL!",
			"Dump it.",
			"Pump it.",
			"I need to be making money off of this somehow.",
			"I could make you a millionare.",
			"I need to go all in on GlobuTron Limited.",
			"I need to go all in on MarkWahlbergCoin.",
			"You're too close to me.",
			"How can I make more money off my children?",
			"I'm late to my organ appointment",
		],
		"speech_hurt": [
			"I'm above this.",
			"Ew.",
			"Disgusting.",
			"Uncouth.",
			"I'll buy you out.",
			"Name your price.",
			"Do you know who I am?"
		],
		"wealth": [10000, 1000000],
		"hurt_reaction": ["fight", "flight"]
	},
	"terminally_online" = {
		"speech": [
			"i cant stop buying slime on the internet",
			"i wish i Owned more Objects",
			"i want to be online forever",
			"i cant wait to go home and\nwatch nobbo Live on my\n500\" plasma television",
			"i NEED to watch the new Gobster video NOW",
			"can i post u on my HogTown page?",
			"why do u look like that",
			"please stop making eye contact with me",
			"how many followers do u have",
			"have u seen bugboy on grinchTv yet",
			"i cannot see one more bugboy post",
			"yeah. just posted another banger on slimetime.",
			"im streaming u rn",
			"can i dox u"
		],
		"speech_hurt": [
			"YEOWCH",
			"someone clip this",
		],
		"wealth": [],
		"hurt_reaction": ["flight", "freeze"]
	},
	"insane" = {
		"speech": [
			"you're not real",
			"i'm not real",
			"where even is here?",
			"i see right through you",
			"i'm just kidding",
			"they're watching from inside little boxes",
		],
		"speech_hurt": [
			"I KNEW IT WAS YOU",
			"NO NO NO NO",
			"YEEEARRRRRHHGHHHGHH",
			"I am invincible",
			"I am bulletproof"
		],
		"wealth": [10000, 30000],
		"hurt_reaction": ["fight", "flight"]
	},
	":3" = {
		"speech": [
			":3",
			":3333c",
			"miau",
			">>>>:D",
			"><",
			"૮ ˶ᵔ ᵕ ᵔ˶ ა",
			"(˶˃ ᵕ ˂˶) .ᐟ.ᐟ",
			"ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧",
			"♡",
			"₍^. .^₎⟆"
		],
		"speech_hurt": [
			"˙◠˙",
			"(っ◞‸◟ c)",
			"૮(˶ㅠ︿ㅠ)ა",
			"(˚ ˃̣̣̥⌓˂̣̣̥ )"
		],
		"wealth": [10000, 100000],
		"hurt_reaction": ["freeze", "flight"]
	},
	"bot" = {
		"speech": [
			"beep",
			"boop",
			"beep boop",
			"(&V*%)NWw#f$38by%hu^$^8f9",
			"fh8DF*&dfh9DS*()jf",
			"JFGHSDH(F0jdf9DS8fdo)",
			")(9HBW#B#J(0rjg8fd9g))",
			"#########################",
			"beep boop beep boop",
			"weeooowweweweeooooeoeoeo",
			"bonk"
		],
		"speech_hurt": [
			":[]",
			":["
		],
		"wealth": [10000, 50000],
		"hurt_reaction": ["freeze", "flight", "fight"]
	}
}

var personality: String = personality_bank.keys().pick_random()


func _ready() -> void:
	is_staring = false
	if activity == "random": activity = activities.pick_random()
	look_random()
	hurt_reaction = personality_bank[personality]["hurt_reaction"].pick_random()
	if personality_bank[personality]["wealth"] != []:
		wealth_min = personality_bank[personality]["wealth"][0]
		wealth_max = personality_bank[personality]["wealth"][1]
	wealth = randi_range(wealth_min, wealth_max)
	$SpeechTimer.start(randf_range(0.1, 2.0))


func _physics_process(delta: float) -> void:
	$WealthLabel.text = "$" + str(wealth)

	# Handle knockback
	if knockback_timer > 0:
		velocity += knockback_velocity
		knockback_timer -= delta
		knockback_velocity *= 0.2  # Reduce knockback over time for a smoother effect
	else:
		knockback_velocity = Vector3.ZERO  # Reset knockback force

	# If knockback is active, override movement logic
	if knockback_timer <= 0:
		if is_staring:
			set_rotation_goal_to_player()
		
		if activity == "stand":
			velocity = Vector3.ZERO
			if global_position.distance_to(player.global_position) < 3.0:
				is_staring = true
			else: 
				is_staring = false
			
		elif activity == "roam":
			velocity = -basis.z * speed
			
		elif activity == "chase":
			set_rotation_goal_to_player()
			velocity = -basis.z * speed_chase
			if %AttackTimer.is_stopped():
				for body: Object in hitbox.get_overlapping_bodies():
					if body.is_in_group("player"):
						_attack()

	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta * 10
	
	rotate_towards(rotation_goal, delta)
	move_and_slide()


func look_random() -> void:
	var random_rotation: Basis = Basis()
	random_rotation = random_rotation.rotated(Vector3.UP, randf_range(-PI, PI))  # Random Y-axis rotation
	rotation_goal = Quaternion(random_rotation)  # Store as target rotation

func rotate_towards(target_rotation: Quaternion, delta: float) -> void:
	var current_quat: Quaternion = Quaternion(transform.basis)
	transform.basis = Basis(current_quat.slerp(target_rotation, rotation_speed * delta))

func set_rotation_goal_to_player() -> void:
	var direction_to_player: Vector3 = (player.global_transform.origin - global_transform.origin).normalized()
	var target_quat: Quaternion = Quaternion(Basis().looking_at(direction_to_player, Vector3.UP))
	rotation_goal = target_quat  # Set the rotation goal to face the player

func hurt(_damage: int) -> float: 
	_react_hurt()
	wealth -= _damage

	if wealth <= 0:
		die()
		return wealth_reward
	else: 
		return 0


func _react_hurt() -> void:
	_speak_hurt()
	
	# Apply knockback force away from the player
	var knockback_direction: Vector3 = (global_transform.origin - player.global_transform.origin).normalized()
	knockback_velocity = knockback_direction * 5.0  # Increase this value if needed
	knockback_timer = 0.1  # Duration of knockback effect

	if hurt_reaction == "fight":
		activity = "chase"


func die() -> void:
	queue_free()


func _speak() -> void:
	$SpeechLabel.text = personality_bank[personality]["speech"].pick_random()
	$SpeechLabel.show()
	$SpeechTimer.start(5.0)
	is_speaking = true

func _speak_hurt() -> void:
	$SpeechLabel.text = personality_bank[personality]["speech_hurt"].pick_random()
	$SpeechLabel.show()
	$SpeechTimer.start(2.0)
	is_speaking = true


func _attack() -> void:
	player.hurt(melee_damage)
	var next_attack: float = randf_range(1.0, 3.0)
	%AttackTimer.start(next_attack)

func _on_speech_timer_timeout() -> void:
	if is_speaking:
		$SpeechLabel.hide()
		is_speaking = false
		$SpeechTimer.start(randf_range(1, 2.0))
	else:
		_speak()


func _on_direction_timer_timeout() -> void:
	if activity == "roam":
		look_random()
		speed = randf_range(speed_min, speed_max)
		var timer_rand: float = randf_range(1.0, 15.0)
		$DirectionTimer.start(timer_rand)


#func _on_attack_timer_timeout() -> void:
	#if activity == "chase":
		#%AttackTimer.start(1.0)
		#_attack()
