extends Sprite2D
class_name SpecialCardBase
var done:Callable
enum Cardname{Fireball, DUMMY}
func select(done):
	self.done=done
	pass;
