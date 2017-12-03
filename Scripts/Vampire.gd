extends KinematicBody2D

onready var shot = preload("res://Scene/Shot.tscn")
onready var game = get_node('..') #<--This is not efficient
onready var effe = get_node('Red_Effect')
onready var text = get_node('Sprite')
onready var audio = get_node('../SamplePlayer')

var movement = Vector2()
var lastMove = Vector2(1, 0)
var lifesteal = 20
var modulation = Color(1, 1, 1)

var shot_delay = 30

func _ready():
	get_node('Sprite').set('visibility/opacity', 0)
	set_pos(get_viewport_rect().size/2)
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	if game.state == 2:
		#Input movement
		movement.x = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")
		movement.y = Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
		if movement.x != 0 and movement.y != 0:
			movement *= 0.67
		if movement.x != 0 or movement.y != 0:
			lastMove = movement
		
		#Shooting Blood
		if Input.is_action_pressed("space") and shot_delay <= 0:
			var blood = shot.instance()
			blood.type = 'Blood'
			blood.direction = lastMove
			blood.speed += 150#game.get_sspd() * 1.5
			blood.damage += game.get_sspd() * 0.2
			blood.set_pos(get_pos() + Vector2(0, -5))
			game.add_child(blood)
			shot_delay = (game.chr_cap - game.get_charge()) * 0.4 + 20
		
		if movement.x > 0:
			get_node('Sprite').set_flip_h(false)
		elif movement.x < 0:
			get_node('Sprite').set_flip_h(true)
		movement *= game.get_spd() + 100
		move(movement * delta)
		
		if shot_delay > 0:
			shot_delay -= 100 * delta
		
		if game.get_hp() < 160:
			modulation = Color(1, 0.6, 0.6)
		else:
			modulation = Color(1, 1, 1)
		text.set_modulate(modulation)

func _on_Area2D_area_enter( area ):
	if game.state == 2:
		#If touches enemy, suck their blood
		if area.is_in_group('enemy'):
			audio.play('suck')
			game.score += 2
			if game.get_hp() + lifesteal <= game.hp_cap:
				area.set_health(area.health - lifesteal)
				game.set_hp(game.get_hp() + lifesteal)
			elif game.get_hp() < game.hp_cap:
				area.set_health(area.health - (game.hp_cap - game.get_hp()))
				game.set_hp(game.hp_cap)
		#If get shot, get hurt of course
		if area.is_in_group('shot') and area.type != 'Blood':
			audio.play('hurt')
			effe.interpolate_property(text, 'modulate', Color(1, 0.3, 0.3), modulation, 0.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
			effe.start()
			game.set_hp(game.get_hp() - area.damage)
			area.destroy()
