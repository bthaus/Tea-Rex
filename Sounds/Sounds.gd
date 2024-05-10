extends AudioStreamPlayer2D
class_name Sounds
static var StartBattlePhase=load("res://Sounds/Soundeffects/new sounds/Start.wav")
static var explosionSounds=[
	load("res://Sounds/Soundeffects/explosion/Explosion 2 1.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2 2.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2 3.wav"),
	load("res://Sounds/Soundeffects/explosion/Explosion 2.wav")
]
static var placeBlock=[
	load("res://Sounds/Soundeffects/BlockPlacementSounds/Block sound.wav"),
	load("res://Sounds/Soundeffects/BlockPlacementSounds/Block sound 1.wav")
]
static var startBuildPhase=load("res://Sounds/Soundeffects/new sounds/End sound.wav")
static var unlock=load("res://Sounds/Soundeffects/new sounds/Unlock sound.wav")
static var music=[
	load("res://Sounds/Music/background1.wav"),
	load("res://Sounds/Music/background2.wav"),
	load("res://Sounds/Music/background3.wav"),
	load("res://Sounds/Music/background4.wav"),
	load("res://Sounds/Music/background5.wav"),
	load("res://Sounds/Music/background6.wav"),
		
]
static var bleep=load("res://Sounds/Soundeffects/new sounds/bleep.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.stream=music[0]
	#$Music.play()
	player=self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func playFromCamera(gamestate,sound):
	var a=AudioStreamPlayer2D.new()
	a.volume_db=a.volume_db-5
	a.stream=sound
	gamestate.getCamera().add_child(a)
	a.play()
	a.finished.connect(func():a.queue_free())
	return a;
	pass
static var player:AudioStreamPlayer2D
static func start(sound):
	player.stream=sound
	player.play()
	pass;


func _on_music_finished():
	$Music.stream=music.pick_random()
	$Music.play()
	pass # Replace with function body.
