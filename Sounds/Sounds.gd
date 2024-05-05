extends AudioStreamPlayer2D
class_name Sounds
static var StartBattlePhase=load("res://Sounds/Soundeffects/new sounds/Start.wav")
static var explosionSounds=[
	load("res://Sounds/Soundeffects/explosion/Explosion 2 1.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2 2.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2 3.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2.wav")
]
static var startBuildPhase=load("res://Sounds/Soundeffects/new sounds/End sound.wav")
static var unlock=load("res://Sounds/Soundeffects/new sounds/Unlock sound.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	player=self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static var player:AudioStreamPlayer2D
static func start(sound):
	player.stream=sound
	player.play()
	pass;
