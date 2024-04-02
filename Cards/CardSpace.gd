extends Node2D


const CardSize = Vector2(116,192)
const CardBase = preload("res://CardBase.tscn")
const PlayerHand = preload("res://Cards/PlayerHand.gd")
var CardSelected = []
var deckSize = 0

@onready var CentreCardOval = Vector2(get_viewport().size) * Vector2(0.5,1.3)
@onready var Hor_rad = get_viewport().size.x*0.45
@onready var Ver_rad = get_viewport().size.y*0.4
var angle = 0
var CardSpread = 0.25
var Card_Number = 0
var NumberCardsHand = 0
var OvalAngleVector = Vector2()
enum{InHand, InPlay, InMouse, FocuseInHand, MoveDrawnCardToHand, ReOrganiseHand}

func _ready():
	PlayerHand.fillCardDeck()
	deckSize = PlayerHand.cardList.size()

func drawCard():
	angle = PI/2 + CardSpread*(float(NumberCardsHand)/2 - NumberCardsHand)
	var new_card = CardBase.instantiate()
	CardSelected = randi() % deckSize
	new_card.CardName = PlayerHand.cardList[CardSelected]
	new_card.setNameAndColor()
	OvalAngleVector = Vector2(Hor_rad*cos(angle), -Ver_rad*sin(angle))
	new_card.startpos = $Deck.position - CardSize/2
	new_card.targetpos = CentreCardOval + OvalAngleVector - CardSize
	new_card.Cardpos = new_card.targetpos
	new_card.startrot = 0
	new_card.targetrot = (90 - angle)/4
	new_card.state = MoveDrawnCardToHand
	Card_Number = 0
	for Card in $Cards.get_children(): #reorganise hand
		angle = PI/2.0 + CardSpread*(float(NumberCardsHand/2.0 - Card_Number))
		OvalAngleVector = Vector2(Hor_rad*cos(angle), -Ver_rad*sin(angle))
		Card.targetpos = CentreCardOval + OvalAngleVector - CardSize
		Card.Cardpos = Card.targetpos	#card default position
		Card.startrot = Card.rotation
		Card.targetrot = (90 - angle)/4
		Card_Number+=1
		if Card.state == InHand:
			Card.state = ReOrganiseHand
			Card.startpos = Card.position
		elif Card.state == MoveDrawnCardToHand:
			Card.startpos = Card.targetpos - ((Card.targetpos)/(1-Card.t))
	$Cards.add_child(new_card)
	PlayerHand.cardList.erase(PlayerHand.cardList[CardSelected])
	angle +=0.25
	deckSize-=1
	NumberCardsHand += 1
	Card_Number += 1
	
	return deckSize
