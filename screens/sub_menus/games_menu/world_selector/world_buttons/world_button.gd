class_name WorldButton extends TextureButton

@export var world : World
@export var is_selected:bool :set = _set_is_selected


func _set_is_selected(new_value:bool):
	is_selected = new_value
	update_button_texture()

func update_button_texture():

	if is_selected:
		self.texture_normal = world.selected_button_texture
		self.z_index = 10
	
	else:
		self.texture_normal = world.normal_button_texture
		self.z_index = 0

