extends GameObjectCounted

class_name InputUtils

#Alternate functions instead of Input.is_action_just_released, which should only be used in process()
#These ones can be used in _input :)
static func is_action_just_pressed(event: InputEvent, action: StringName) -> bool:
	return event.is_action(action) and event.is_pressed() and not event.is_echo()

static func is_action_just_released(event: InputEvent, action: StringName) -> bool:
	return event.is_action(action) and event.is_released() and not event.is_echo()
