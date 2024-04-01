# TODO set possible cards the player can draw from here

static var cardList = []

static func fillCardDeck():
	for color in Stats.TurretColor:
		for block in Stats.BlockShape:
			print(color,'_', block)
			cardList.push_back(str(color,'_', block))
			
