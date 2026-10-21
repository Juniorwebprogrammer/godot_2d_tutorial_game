extends Area2D

@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var collisions: CollisionShape2D = $CollisionShape2D
@onready var collected_sound: AudioStreamPlayer2D = $collected_sound

signal collected

var is_collected: bool = false


func _on_body_entered(body: Node2D) -> void:
	if is_collected or body.name != "Player":
		return
	is_collected = true
	collected_sound.play()
	animations.animation = "collected"
	collected.emit()
	collisions.set_deferred("disabled", true)


func _on_animated_sprite_2d_animation_looped() -> void:
	if animations.animation == "collected":
		queue_free()
