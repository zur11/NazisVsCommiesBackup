class_name UserStatsContainer extends Node2D

var user_name : String : set = _set_user_name
var user_balance : int : set = _set_user_balance
var _stats_opened : bool 

@onready var _balance_label : Label = $"%BalanceLabel"
@onready var _user_name_label : Label = $"%UserNameLabel"


func _set_user_name(new_value:String):
	user_name = new_value
	
	_user_name_label.text = user_name

func _set_user_balance(new_value:int):
	user_balance = new_value
	
	_balance_label.text = str(user_balance)

func _on_username_container_pressed():
	if _stats_opened == false:
		$Arrow.visible = false
		$AnimationPlayer.play("_drop_down")
		_stats_opened = true
	elif _stats_opened == true:
		$AnimationPlayer.play("_close")
		_stats_opened = false

func _on_username_container_mouse_entered():
	if _stats_opened == false:
		$Arrow.visible = true
	$Arrow/AnimationPlayer.play("_appear")
	$Arrow/AnimationPlayer.queue("_bounce")

func _on_username_container_mouse_exited():
	$Arrow/AnimationPlayer.play_backwards("_appear")
