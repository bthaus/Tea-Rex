extends TextureButton

var deckSize = INF
var CardsInHand = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _gui_input(event):
	if Input.is_action_just_released("left_click"):
		if deckSize > 0 && CardsInHand < 5:
			deckSize = $'../../'.drawCard()
			CardsInHand=CardsInHand+1
			if deckSize == 0 || CardsInHand == 5:
				disabled = true
