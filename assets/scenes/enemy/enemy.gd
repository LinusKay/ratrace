extends CharacterBody3D

@export var wealth: int = 100000
@export var wealth_reward: int = 100000

var is_speaking: bool = false
var wealth_min: int = 10000
var wealth_max: int = 1000000

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
		"wealth": [0, 10000]
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
		"wealth": [10000, 1000000]
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
		"wealth": []
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
		"wealth": [10000, 30000]
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
		"wealth": [10000, 100000]
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
		"wealth": [10000, 50000]
	}
}

var personality: String = personality_bank.keys().pick_random()



func _ready() -> void:
	if personality_bank[personality]["wealth"] != []:
		wealth_min = personality_bank[personality]["wealth"][0]
		wealth_max = personality_bank[personality]["wealth"][1]
	wealth = randi_range(wealth_min, wealth_max)
	$SpeechTimer.start(randf_range(0.1, 2.0))
	pass
	
func _process(delta: float) -> void:
	$WealthLabel.text = "$" + str(wealth)

func hurt(_damage: int) -> float: 
	_speak_hurt()
	wealth -= _damage
	if wealth <= 0:
		die()
		return wealth_reward
	else: 
		return 0

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

func _on_speech_timer_timeout() -> void:
	if is_speaking:
		$SpeechLabel.hide()
		is_speaking = false
		$SpeechTimer.start(randf_range(1, 2.0))
	else:
		_speak()
