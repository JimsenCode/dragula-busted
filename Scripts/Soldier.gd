extends Area2D
#I made enemies Area2D instead of RigidBody2D, welp!
onready var game = preload('res://Scene/Game.tscn')
onready var health_bar = get_node('health_bar')
signal shoot
signal hit

var health
var speed = 80
var movement = Vector2(1, 0)
var move_ch = 0
var move_sec = 3
var charge = 2
var rng = 0.5

func _ready():
	rand_move()
	set_health(200)
	health_bar.set_max(health)
	set_process(true)

func _process(delta):
	#Movement
	if move_ch <= 0:
		translate(movement * speed * delta)
		if move_sec <= 0:
			rand_move()
		elif move_sec > 0:
			move_sec -= delta
	elif move_ch > 0:
		move_ch -= delta
	
	#Shooting
	if charge <= 0:
		emit_signal('shoot', get_pos())
		charge = (randi() % 6 + 1) #from 1 to 5 sec shot delay
	elif charge > 0:
		charge -= delta

func rand_move():
	move_ch = randi() % 6 + 1
	move_sec = randi() % 3 + 1
	var dim = get_viewport_rect().size/2 - get_pos()
	dim = dim / dim.length()
	movement = Vector2(rand_range(dim.x - rng, dim.x + rng), rand_range(dim.y - rng, dim.y + rng))
	speed = randi() % 50 + 50

func _on_Soldier_area_enter( area ):
	if area.is_in_group('shot'):
		if area.type == 'Blood':
			emit_signal('hit')
			set_health(health - area.damage)
			area.destroy()
	if health <= 0:
		self.destruct()

func set_health(value):
	health = value
	health_bar.set_value(health)

func destruct():
	self.queue_free()