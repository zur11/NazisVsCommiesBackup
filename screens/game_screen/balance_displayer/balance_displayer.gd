class_name BalanceDisplayer extends TextureRect

var balance : int = 0
@onready var balance_label : Label = $BalanceLabel

#func initial_setup(levelbalance : int):
#	balance = levelbalance
#	_updatebalance_display()

func add_value_to_balance(value_to_add:int):
	balance += value_to_add
	_update_balance_display()

func substract_value_from_balance(value_to_substract:int):
	balance -= value_to_substract
	_update_balance_display()

func _update_balance_display():
	balance_label.text = str(balance)
