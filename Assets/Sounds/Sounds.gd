extends AudioStreamPlayer2D
class_name Sounds
static var sound = true;
static var StartBattlePhase = load("res://Assets/Sounds/Soundeffects/new sounds/Start.wav")
static var explosionSounds = [
	load("res://Assets/Sounds/Soundeffects/explosion/Explosion 2 1.wav"),
	load("res://Assets/Sounds/Soundeffects/explosion/Explosion 2 2.wav"),
	load("res://Assets/Sounds/Soundeffects/explosion/Explosion 2 3.wav"),
	load("res://Assets/Sounds/Soundeffects/explosion/Explosion 2.wav")
]
static var placeBlock = [
	load("res://Assets/Sounds/Soundeffects/BlockPlacementSounds/Block sound.wav"),
	load("res://Assets/Sounds/Soundeffects/BlockPlacementSounds/Block sound 1.wav")
]
static var startBuildPhase = load("res://Assets/Sounds/Soundeffects/new sounds/End sound.wav")
static var unlock = load("res://Assets/Sounds/Soundeffects/new sounds/Unlock sound.wav")
static var music = [
	load("res://Assets/Sounds/Music/background1.wav"),
	load("res://Assets/Sounds/Music/background2.wav"),
	load("res://Assets/Sounds/Music/background3.wav"),
	load("res://Assets/Sounds/Music/background4.wav"),
	load("res://Assets/Sounds/Music/background5.wav"),
	load("res://Assets/Sounds/Music/background6.wav"),
		
]
static var bleep = load("res://Assets/Sounds/Soundeffects/new sounds/bleep.wav")
static var level_down = load("res://Assets/Sounds/Soundeffects/level_down_sound.wav")
static var loop = load("res://Assets/Sounds/Music/menu music looppart.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.stream = music[0]
	#$Music.play()
	player = self
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func playFromCamera(gamestate, sound, oneshot=true, callback=func(): ):
	var a = AudioStreamPlayer2D.new()
	a.volume_db = a.volume_db - 5
	a.stream = sound
	if !util.valid(gamestate.getCamera()):return
	gamestate.getCamera().add_child(a)
	a.play()
	a.finished.connect(callback)
	if oneshot:
		
		a.finished.connect(func(): a.queue_free())
		
	return a;
	pass
static var player: AudioStreamPlayer2D
static func start(sound):
	player.stream = sound
	player.play()
	pass ;

func _on_music_finished():
	$Music.stream = music.pick_random()
	$Music.play()
	pass # Replace with function body.
