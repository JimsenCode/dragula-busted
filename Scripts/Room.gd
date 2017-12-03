extends Area2D

onready var bullet = preload('res://Scene/Shot.tscn')
onready var soldier = preload('res://Scene/Soldier.tscn')
onready var game = get_node('..')
onready var vamp = get_node('../Vampire')
onready var audio = get_node('../SamplePlayer')

var counter = 0

func _ready():
	set_process(true)
	pass

func _process(delta):
	if game.state == 2:
		if counter <= 0:
			add_enemy()
			counter = 5000
		else:
			counter -= 1000 * delta

func add_enemy():
	var solder = soldier.instance()
	solder.connect('shoot', self, 'on_soldier_shoot')
	solder.connect('hit', self, 'on_soldier_hit')
	var dim = get_viewport_rect().size
	if randf() >= 0.5:
		solder.set_pos(Vector2((dim.x + 80) * float (randi()%2) - 40, randf() * dim.y))
	else:
		solder.set_pos(Vector2(randf() * dim.x, (dim.y + 160) * float (randi()%2) - 80))
	self.add_child(solder)

func on_soldier_shoot(value):
	var b = bullet.instance()
	b.type = 'Bullet'
	var val = vamp.get_pos() - value 
	b.direction = val / val.length()
	b.speed *= rand_range(1, 1.4) #from 490 to 770 speed
	b.set_pos(value + Vector2(0, 15))
	audio.play('beep')
	game.add_child(b)

func on_soldier_hit():
	audio.play('hit')
	game.score += 5