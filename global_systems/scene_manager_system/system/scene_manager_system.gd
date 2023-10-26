extends Node

var _registered_containers :Array = []

var _err

func _validate_new_container_name(new_container:SceneContainer) -> String:
	var validation_result = ""
	for container in _registered_containers:
		if container.name == new_container.name:
			validation_result += "Node: "+ str(new_container) + " and other container have the same name. Change one of their names."
	return validation_result

func register_new_container(new_container:SceneContainer):
	_err = _validate_new_container_name(new_container)
	_registered_containers.append(new_container)

func get_container(container_name:String) -> SceneManager:
	var returned_container = null
	for container in _registered_containers:
		if container.name == container_name:
			returned_container = container
	assert(returned_container, 'There is no container with these name: '+ container_name)
	return returned_container.scene_manager

func get_container_node(container_name:String) -> SceneContainer:
	var returned_container = null
	for container in _registered_containers:
		if container.name == container_name:
			returned_container = container
	assert(returned_container, 'There is no container with these name: '+ container_name)
	return returned_container

func set_orientation(orientation):
	if !OS.is_debug_build(): DisplayServer.screen_set_orientation(orientation)
	if orientation == DisplayServer.SCREEN_LANDSCAPE: 
		get_viewport().content_scale_size = Vector2(1920, 1080)
		if OS.is_debug_build(): DisplayServer.window_set_size(Vector2(640,360))
	elif orientation == DisplayServer.SCREEN_PORTRAIT:
		get_viewport().content_scale_size = Vector2(1080, 1920)
		if OS.is_debug_build(): DisplayServer.window_set_size(Vector2(360,640))

func unregister_container(container: SceneContainer):
	_registered_containers.erase(container)

func update_theme(new_theme: String) -> void:
	for container in _registered_containers:
		container.update_theme(new_theme)
