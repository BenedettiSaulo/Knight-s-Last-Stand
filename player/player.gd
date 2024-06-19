class_name Player
extends CharacterBody2D

@export_category("Moviment")
@export var speed: float = 3

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_player: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

func _process(delta: float) -> void:
	GameManager.player_position = position
	randf()
	#Ler input
	read_input()
	
	#Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Processar animação e rotação da sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Processar dano
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#if is_running: 
			#animation_player.play("idle")
			#is_running = false
		#else:
			#animation_player.play("run")
			#is_running = true

func _physics_process(delta: float) -> void:
	# Movimentos bruscos
	#velocity = input_vector * speed * 100
	
	# Movimentos suaves - Modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.1)
	
	move_and_slide()

func update_attack_cooldown(delta: float) -> void:
	# Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta # 0.6 - 0.016   0.584
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	# Criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	

func read_input() -> void:
	# Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up","move_down")
	
	# Apagando deadzone do input vector
	var deadzone = 0.15
	# Eixo X
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	#Eixo Y
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
	
		# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation() -> void:
	# Tocar animação quando nao estiver ataquando
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	# Girar sprite
	if input_vector.x > 0:
		# Desmarcar Flip H do Sprite2D
		sprite_player.flip_h = false
	elif input_vector.x < 0:
		# Marcar Flip H do Sprite2D
		sprite_player.flip_h = true

func attack() -> void:
	if is_attacking:
		return
	
	# attack_side_1
	# attack_side_2
	
	animation_player.play("attack_side_1")
	
	# Configurar temporizador conforme o tempo da animação
	attack_cooldown = 0.6
	
	is_attacking = true

func deal_demage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enimy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite_player.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enimy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)
	
	
	# Acessar todos os inimigos
	# Chamar a função "demage"
		#Com "sword_damage" como primeiro parametro
	#var enemies = get_tree().get_nodes_in_group("enemies")
	#for enemy in enemies:
		#enemy.damage(sword_damage)

func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frequência (2x por segundo)
	hitbox_cooldown = 0.5
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount)
	
	# Piscar o inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar morte
	if health <= 0:
		die()

func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player morreu!")
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health)
	return health
