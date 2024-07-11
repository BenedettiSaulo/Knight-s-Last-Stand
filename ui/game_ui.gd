extends CanvasLayer

@onready var timer_label = %TimerLabel
#@onready var gold_label = %GoldLabel
@onready var meat_label = %MeatLabel

func _process(delta: float) -> void:
	# Update labels
	timer_label.text = GameManager.time_elapsed_str
	meat_label.text = str(GameManager.meat_counter)

