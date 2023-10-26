class_name ChoosableAllyCard extends TextureButton


var ally : Ally 
var has_been_chosen : bool

@onready var _price_label : Label = $PriceLabel


func initialize_card():
	_set_texture()
	_set_price_label()
	self.focus_mode = FOCUS_NONE
	

func _set_texture():
	self.texture_normal = ally.normal_btn_texture

func _set_price_label():
	_price_label.text = str(ally.price)
