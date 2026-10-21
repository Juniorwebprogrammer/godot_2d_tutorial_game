extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var collision_shape: CollisionShape2D = $AnimatedSprite2D/CollisionShape2D

var is_open: bool = false

func open() -> void:
	if is_open:
		return
	is_open = true
	for child in find_children("*", "CollisionShape2D", true, false):
		child.set_deferred("disabled", true)
	animation_player.play("up")
