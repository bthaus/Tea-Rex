extends MarginContainer
class_name cardbase
var CardName = 'Testcard'
var CardShape = Stats.BlockShape.ARROW
var CardColor = Stats.TurretColor.BLUE
var Level = 1
#TODO extension

@onready var GameBoard = get_parent().get_parent().gameBoard
@onready var CardImg = str("res://Assets/cards/", "Testcard.png")
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var t = 0
var DRAWTIME = 1
var ORGANISETIME = 0.5

@onready var Orig_scale = scale
enum{
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}
var state = InHand

var setup = true
var startscale = Vector2()
var Cardpos = Vector2()
var ZoomInSize = 1.2
var ZOOMINTIME = 0.2
var ReorganiseNeighbours = true
var NumberCardsHand = 0
var Card_Numb = 0
var NeighbourCard
var Move_Neightbour_Card_Check = false
var Zooming_In=true
var oldstate = INF
var CARD_SELECT = true
var INMOUSETIME = 0.1
#TODO possible not needed var CardClicked = false


func _ready(): #set card texture
	$Card.texture = load(CardImg);	#todo change to final assets
	$Label.text = CardName;
	



func _input(event):
	match state:
		FocusInHand, InMouse:
			if event.is_action_pressed("left_click"): #&& !CardClicked:
				if CARD_SELECT:
					state=InMouse
					setup = true
					oldstate = state
					CARD_SELECT = true
					

func _physics_process(delta):
	
	match state:
		InMouse:			
			if setup:
				Setup()
			GameBoard.select_piece(CardShape, CardColor, Callable(cardPlayed), Level) #TODO: add cases for bulldozer/move card
			#CardClicked = true
			state = InPlay
			
		InPlay:
			$Card.visible = false
			$Focus.visible=false
			$Focus.mouse_filter = MOUSE_FILTER_IGNORE
			$Label.visible = false
			#CardClicked = true
			
			
		FocusInHand:
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				position = startpos.lerp(targetpos, t)
				rotation_degrees = startrot * (1-t) + 0*t
				scale = startscale * (1-t) + Orig_scale*ZoomInSize*t
				t += delta/float(ZOOMINTIME)
				#if ReorganiseNeighbours:
				#	ReorganiseNeighbours = false
				#	NumberCardsHand = $'../../'.NumberCardsHand - 1 # offset for zeroth item
				#	if Card_Numb - 1 >= 0:
				#		Move_Neighbour_Card(Card_Numb - 1,true,1) # true is left!
				#	if Card_Numb - 2 >= 0:
				#		Move_Neighbour_Card(Card_Numb - 2,true,0.25)
				#	if Card_Numb + 1 <= NumberCardsHand:
				#		Move_Neighbour_Card(Card_Numb + 1,false,1)
				#	if Card_Numb + 2 <= NumberCardsHand:
				#		Move_Neighbour_Card(Card_Numb + 2,false,0.25)
			else:
				position = targetpos
				rotation = 0
				scale = Orig_scale*ZoomInSize
				
		MoveDrawnCardToHand: #animate from the deck to my hand
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation_degrees = startrot * (1-t) + targetrot*t
				scale.x = Orig_scale.x * abs(2*t-1)
				if $CardBack.visible:
					if t >= 0.5:
						$CardBack.visible = false
				t += delta/float(DRAWTIME)
			else:
				position = targetpos
				rotation_degrees = targetrot
				state = InHand
				t=0
				
		ReOrganiseHand:
			if setup:
				Setup()
			if t <= 1: # Always be a 1
				if Move_Neightbour_Card_Check:
					Move_Neightbour_Card_Check = false
				position = startpos.lerp(targetpos, t)
				rotation_degrees = startrot * (1-t) + targetrot*t
				scale = startscale * (1-t) + Orig_scale*t
				t += delta/float(ORGANISETIME)
				if ReorganiseNeighbours == false:
					ReorganiseNeighbours = true
					if Card_Numb - 1 >= 0:
						Reset_Card(Card_Numb - 1) # true is left!
					if Card_Numb - 2 >= 0:
						Reset_Card(Card_Numb - 2)
					if Card_Numb + 1 <= NumberCardsHand:
						Reset_Card(Card_Numb + 1)
					if Card_Numb + 2 <= NumberCardsHand:
						Reset_Card(Card_Numb + 2)
			else:
				position = targetpos
				rotation_degrees = targetrot
				scale = Orig_scale
				state = InHand

func Move_Neighbour_Card(Card_Numb,Left,Spreadfactor):
	NeighbourCard = $'../'.get_child(Card_Numb)
	if Left:
		NeighbourCard.targetpos = NeighbourCard.Cardpos - Spreadfactor*Vector2(65,0)
	else:
		NeighbourCard.targetpos = NeighbourCard.Cardpos + Spreadfactor*Vector2(65,0)
	NeighbourCard.setup = true
	NeighbourCard.state = ReOrganiseHand
	NeighbourCard.Move_Neightbour_Card_Check = true
	
func Reset_Card(Card_Numb):
	if NeighbourCard.Move_Neightbour_Card_Check == false:
		NeighbourCard = $'../'.get_child(Card_Numb)
		if NeighbourCard.state != FocusInHand:
			NeighbourCard.state = ReOrganiseHand
			NeighbourCard.targetpos = NeighbourCard.Cardpos
			NeighbourCard.setup = true

func Setup():
	startpos = position
	#startrot = rotation
	startscale = scale
	t = 0
	setup = false



func _on_focus_mouse_entered():
	match state:
		InHand, ReOrganiseHand:
			#if CardClicked == false:
				setup = true
				rotation = 0
				#targetrot = 0
				targetpos = Cardpos
				targetpos.y = get_viewport().size.y - $'../../'.CardSize.y*ZoomInSize
				print ("position: ", get_viewport().size)
				state = FocusInHand


func _on_focus_mouse_exited():
	match state:
		FocusInHand:
			setup = true
			rotation_degrees = targetrot
			targetpos = Cardpos
			state = ReOrganiseHand

func setNameAndColor():
	var split = CardName.split("_")
	CardColor = Stats.getColorFromString(split[0])
	CardShape = Stats.getShapeFromString(split[1])
	

func cardPlayed (CardPlayed: bool):
	
	 #Check if card was placed or not, either delete card or put it back into hand
	if CardPlayed:
		get_parent().remove_child($Card)
		NumberCardsHand -=1
		
	else:
		CARD_SELECT = true
		$Card.visible = true
		$Focus.visible=true
		$Focus.mouse_filter = MOUSE_FILTER_PASS
		$Label.visible = true
		#CardClicked = true
		Setup()
		state = FocusInHand
		_on_focus_mouse_exited()
	
	
	
	
