class_name SceneManager extends Resource


var _container: Node2D

var _history_manager: IHistoryManager

func _init(_is_container_historied: bool):
	if _is_container_historied: _history_manager = TrackedHistoryManager.new()
	else: _history_manager = UntrackedHistoryManager.new()

# FUNCTIONS USED IN NAZIS VS COMMIES 
func goto_scene(instantiated_scene_to_go: Node):
	if _validate_scene_to_go(instantiated_scene_to_go): return

	_history_manager.add_new_scene(instantiated_scene_to_go)

	_change_scene(instantiated_scene_to_go)
	
func _change_scene(instanced_scene_to_go: Node):
	for child in _container.get_children():
		_container.remove_child(child)
		await _container.get_tree().process_frame
		child.free()
	_container.add_child(instanced_scene_to_go)


func _validate_scene_to_go(instantiated_scene_to_go: Node) -> bool:
	if instantiated_scene_to_go == null: 
		push_error("Trying to goto_scene to a Null Scene")
		return true
	var current_scene = _history_manager.get_current_instantiated_scene()
	if current_scene and (current_scene == instantiated_scene_to_go): 
		return true
	return false
 
func exit_scene():
	_container.exit_scene_with_curtain_animation()


# FUNCTIONS USED IN OTHER PROJECTS 
func goto_previous_scene():
	if !_history_manager.get_previous_instantiated_scene() : return

	_change_scene(_history_manager.get_previous_instantiated_scene())
	
	_history_manager.remove_last_scene()

func update_theme(new_theme: String):

	_history_manager.update_themes(new_theme)

	_change_scene(_history_manager.get_current_instantiated_scene())

