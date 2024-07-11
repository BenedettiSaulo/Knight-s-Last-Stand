extends Node

@export var speed: float = 1.0

#@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var enemy: Enemy
var sprite: AnimatedSprite2D


func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over: return
	
	#Calcular direção
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()
	
	#Movimento
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()
	
	# Girar sprite
	if input_vector.x > 0:
		# Desmarcar Flip H do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar Flip H do Sprite2D
		sprite.flip_h = true
