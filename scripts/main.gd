extends Node2D
@onready var levelBoot = $LevelBoot
@onready var scoreLabel = $HUC/ScorePanel/ScoreLabel
@onready var winLabel = $HUC/WinLabel
@onready var fate = $HUC/Fate
@onready var music = $Music

var level_path
var enemies
var appels
var exit
var tween
var finish

var current_level_root: Node = null
var level: int = 3
var score: int = 0
var total_collectabled_item_for_level: int = 0
var first_load: bool = true
var reset_score: bool = true
var can_pass_level: bool = false
var win_the_game: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.finished.connect(music.play)
	winLabel.visible = false
	fate.modulate.a = 1.0
	current_level_root = get_node("LevelBoot") 
	await _load_level(level, first_load, reset_score)

# Level Management

func _load_level(dlevel: int, first_load: bool, reset_score: bool) -> void:
	if not first_load:
		await _fate(1.0)

	level_path = "res://scenes/level_boot_%s.tscn" % level

	score = 0
	scoreLabel.text = "SCORE: %s" % score

	if current_level_root:
		current_level_root.queue_free()

	current_level_root = load(level_path).instantiate()
	call_deferred("add_child", current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level()

	await _fate(0.0)

func _setup_level() -> void:
	enemies = current_level_root.get_node_or_null("Enemies")
	appels = current_level_root.get_node_or_null("Appels")
	exit = current_level_root.get_node_or_null("Exit")
	finish = current_level_root.get_node_or_null("Finish")
	
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
			
	if appels:
		for appel in appels.get_children():
			appel.collected.connect(_increase_score)
	
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	if finish:
		finish.body_entered.connect(_on_win_body_entered)
		
	_count_appels(appels)

func _win_the_game() -> void:
	await _fate(1.0)
	winLabel.visible = true
	music.stop()

# Signal handlers

func _on_player_died(body) -> void:
	body.die()
	await _load_level(level, first_load, reset_score)

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player" && can_pass_level == true:
		can_pass_level = false
		level += 1
		body.can_move = false
		first_load = false
		reset_score = false
		await _load_level(level, first_load, reset_score)

func _on_win_body_entered(body: Node2D) -> void:
	if body.name != "Player" or not can_pass_level or win_the_game:
		return
	win_the_game = true
	body.can_move = false
	await _win_the_game()

# Score
func _count_appels(appels) -> void:
	total_collectabled_item_for_level = appels.get_child_count() if appels else 0
	can_pass_level = total_collectabled_item_for_level == 0

func _increase_score() -> void:
	score += 1
	scoreLabel.text = "SCORE: %s" % score
	_catch_total_collectabled_item()

func _catch_total_collectabled_item() -> void:
	if score == total_collectabled_item_for_level:
		can_pass_level = true
		_open_door(can_pass_level)

func _open_door(can_pass_level: bool) -> void:
	var door = current_level_root.get_node_or_null("Door")
	if door && can_pass_level == true:
		door.open()

# Fate

func _fate(to_alpha: float) -> void:
	tween = create_tween()
	tween.tween_property(fate, "modulate:a", to_alpha, 1.5)
	await tween.finished
