extends Node2D

@export var regeneration_amout: int = 10

func _ready() -> void:
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amout)
		queue_free()
