extends Node2D

var value: int = 0

func _ready() -> void:
	%Label.text = str(value)
