extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var wall_ray: RayCast2D = $WallRay

signal player_died
const SPEED = 50.0
var direction = -1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("Player")
	if player:
		wall_ray.add_exception(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wall_ray.is_colliding():
		_turn_around()
	position.x += direction * SPEED * delta


func _on_timer_timeout() -> void:
	_turn_around()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		emit_signal("player_died", body)

func _turn_around() -> void:
	direction *= -1
	_update_facing()
	timer.start()

func _update_facing() -> void:
	animated_sprite_2d.flip_h = direction > 0
	wall_ray.target_position.x = absf(wall_ray.target_position.x) * direction
	wall_ray.force_raycast_update()
