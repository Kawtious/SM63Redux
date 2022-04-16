tool
extends Node2D

export(int, 2) var type = 0 setget set_type

onready var main = $"/root/Main/Items"
onready var hover = $Hover
onready var rocket = $Rocket
onready var turbo = $Turbo

var fludd = preload("res://actors/items/fludd_box/fludd_pickup.tscn").instance()
var break_anim = preload("res://actors/items/fludd_box/box_break.tscn").instance()

func set_type(new_type):
	type = new_type
	match new_type:
		2:
			hover.visible = false
			rocket.visible = false
			turbo.visible = true
		1:
			hover.visible = false
			rocket.visible = true
			turbo.visible = false
		_:
			hover.visible = true
			rocket.visible = false
			turbo.visible = false


func _on_FluddBox_body_entered(body):
	if body.vel.y > -2 && body.position.y < position.y: #TODO: give mario feet collision
		main.call_deferred("add_child", break_anim)
		break_anim.position = Vector2(position.x, position.y)
		match type:
			2:
				break_anim.animation = "bounce_turbo"
			1:
				break_anim.animation = "bounce_rocket"
			_:
				break_anim.animation = "bounce_hover"
		main.call_deferred("add_child", fludd)
		fludd.position = Vector2(position.x, position.y + 8.5)
		fludd.call_deferred("switch_type", type)
		Singleton.collected_nozzles[type] = true
		body.vel.y = -6 * 32 / 60
		$Open.play()
		$CollisionShape2D.queue_free()
		hover.visible = false
		rocket.visible = false
		turbo.visible = false


func _on_Open_finished():
	queue_free()
