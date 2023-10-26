class_name UserBalanceDisplayer extends Node2D


var balance : int : set = _set_user_balance 
@onready var _balance_label : Label = $%BalanceLabel
@onready var _amount_received : Label = $AmountReceived
@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var displayer_texture : TextureRect = $Texture

func move_up():
	_animation_player.play("_move_up")

func move_down():
	_animation_player.play("_move_down")

func _set_user_balance(new_value:int):
	balance = new_value 
	_update_balance_label()

func add_coins_to_balance(coins_value:int):
	balance += coins_value
	_amount_received.text = "+" + str(coins_value)
	_animation_player.play("_receive_coins_from_box")
	await get_tree().create_timer(2).timeout
	_update_balance_label()

func remove_coins_from_balance(coins_value:int):
	balance -= coins_value
	_update_balance_label()

func _update_balance_label():
	_balance_label.text = str(balance)
