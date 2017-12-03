extends Node

onready var effect = get_node('Tween') 
onready var title = get_node('Titlework')
onready var room = get_node('Room')
onready var newse = get_node('Newspaper_Eve')
onready var newsm = get_node('Newspaper_Mor')
onready var hud = get_node('HUD')
onready var hp_bar = get_node('HUD/hp_prog')
onready var spd_bar = get_node('HUD/spd_prog')
onready var chr_bar = get_node('HUD/chr_prog')
onready var cap_bar = get_node('HUD/cap_prog')
onready var hp_but = get_node('HUD/hp_but')
onready var spd_but = get_node('HUD/spd_but')
onready var chr_but = get_node('HUD/chr_but')
onready var cap_but = get_node('HUD/cap_but')
onready var score_label = get_node('HUD/Score')

const CHANGE = 50 #Stat change per second
var state = 1 #Game State
#Stats
var score = 0
var HP setget set_hp,get_hp
var speed setget set_spd,get_spd
var charge setget set_charge,get_charge
var shot_spd setget set_sspd,get_sspd

#Stats Cap
var hp_cap = 800
var spd_cap = 200
var chr_cap = 200
var sspd_cap = 200

func _ready():
	#Initiliazer
	hud.set('visibility/opacity', 0)
	
	set_fixed_process(true)
	pass

#Game Loop
func _fixed_process(delta):
	if state == 1:
		if Input.is_action_pressed("space"):
			game_start()
	elif state == 2:
		score += 1 * delta
		check_input(delta)
		score_label.set_text('Score: ' + str(int(score)))
	elif state == 3:
		if Input.is_action_pressed("space"):
			game_retry()

func game_start():
	set_hp(660)
	set_spd(80)
	set_charge(80)
	set_sspd(80)
	score = 0
	
	newse.set_rot(0)
	effect.interpolate_property(newse, 'visibility/opacity', 1, 0, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect.interpolate_property(title, 'visibility/opacity', 1, 0, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect.interpolate_property(get_node('Vampire/Sprite'), 'visibility/opacity', 0, 1, 0.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect.interpolate_property(hud, 'visibility/opacity', 0, 1, 0.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect.start()
	
	randomize()
	state = 2

func game_over():
	state = 3
	
	newse.set_rot(15 * 3.14/ 180)
	effect.interpolate_property(newse, 'visibility/opacity', 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	effect.interpolate_property(title, 'visibility/opacity', 0, 1, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	effect.interpolate_property(get_node('Vampire/Sprite'), 'visibility/opacity', 1, 0, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect.start()

func game_retry():
	for child in room.get_children():
		child.queue_free()
	get_node('Vampire').shot_delay = 30
	get_node('Vampire').set_pos(get_viewport_rect().size/2)
	effect.interpolate_property(newsm, 'visibility/opacity', 1, 0, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	game_start()

#Getters and Setters
func set_hp(value):
	HP = value
	if HP <= 0:
		game_over()
	hp_bar.set_value(HP + 70)

func get_hp():
	return HP

func set_spd(value):
	speed = value
	spd_bar.set_value(speed + 70)

func get_spd():
	return speed

func set_charge(value):
	charge = value
	chr_bar.set_value(charge + 70)

func get_charge():
	return charge

func set_sspd(value):
	shot_spd = value
	cap_bar.set_value(shot_spd + 70)

func get_sspd():
	return shot_spd

func check_input(delta):
	#Increase HP from other 3 stats
	hp_but.set_pressed(false)
	spd_but.set_pressed(false)
	chr_but.set_pressed(false)
	cap_but.set_pressed(false)
	if Input.is_action_pressed("shift"):
		hp_but.set_pressed(true)
		var chang = 0;
		if speed - CHANGE * 2 * delta < 0:
			chang += speed
			set_spd(0)
		else:
			chang += CHANGE * 2
			set_spd(speed - CHANGE * 2 * delta)
		if charge - CHANGE * 2 * delta < 0:
			chang += charge * 2
			set_charge(0)
		else:
			chang += CHANGE * 2
			set_charge(charge - CHANGE * 2 * delta)
		if shot_spd - CHANGE * 2 * delta < 0:
			chang += shot_spd
			set_sspd(0)
		else:
			chang += CHANGE * 2
			set_sspd(shot_spd - CHANGE * 2 * delta)
			
		set_hp(HP + chang * delta)
	elif HP > 100:
		#Increase Speed by pressing Z
		if Input.is_action_pressed("z"):
			spd_but.set_pressed(true)
			if HP - CHANGE*delta < 100:
				set_spd(speed + (HP - 100) * delta)
				set_hp(100)
			elif speed + CHANGE*delta > spd_cap:
				set_hp(HP - (spd_cap - speed) * delta)
				set_spd(spd_cap)
			else:
				set_hp(HP - CHANGE * delta)
				set_spd(speed + CHANGE * delta)
		
		#Decrease Charge by pressing X
		if Input.is_action_pressed("x"):
			chr_but.set_pressed(true)
			if HP - CHANGE*delta < 100:
				set_charge(charge + (HP - 100) * delta)
				set_hp(100)
			elif charge + CHANGE*delta > chr_cap:
				set_hp(HP - (chr_cap - charge) * delta)
				set_charge(chr_cap)
			else:
				set_hp(HP - CHANGE * delta)
				set_charge(charge + CHANGE * delta)
		
		#Increase shot damage by pressing C
		if Input.is_action_pressed("c"):
			cap_but.set_pressed(true)
			if HP - CHANGE*delta < 100:
				set_sspd(shot_spd + (HP - 100) * delta)
				set_hp(100)
			elif shot_spd + CHANGE*delta > sspd_cap:
				set_hp(HP - (sspd_cap - shot_spd) * delta)
				set_sspd(sspd_cap)
			else:
				set_hp(HP - CHANGE * delta)
				set_sspd(shot_spd + CHANGE * delta)

func _on_Tween_tween_complete( object, key ):
	if newse.get_opacity() == 1:
		newsm.get_node('AnimationPlay').play("Out")

func _on_Area2D_area_enter( area ):
	print("Got Hit in Game!")
	if area.type != 'Blood':
		set_hp(get_hp() - area.damage)
		area.destroy()
