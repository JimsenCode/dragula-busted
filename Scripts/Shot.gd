extends Area2D

onready var bullet = get_node('Bullet')
onready var blood = get_node('Blood')

var direction = Vector2(0, 0)
var damage = 40
var speed = 350
var type = 'Blood'

func _ready():
	if type == 'Blood':
		bullet.set('visibility/visible', false)
	elif type == 'Bullet':
		blood.set('visibility/visible', false)
	set_rot(atan2(direction.x, direction.y) - PI/2)
	set_process(true)

func _process(delta):
	translate(direction * speed * delta)

func destroy():
	set_process(false)
	self.queue_free()

func _on_VisibilityNotifier2D_exit_screen():
	self.destroy()
