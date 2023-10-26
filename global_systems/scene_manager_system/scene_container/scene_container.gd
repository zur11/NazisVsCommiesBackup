@tool class_name SceneContainer extends Node2D

@export var autoload_name = "SceneManagerSystem"
@export var is_historied: bool = false

var scene_manager: SceneManager

func _get_configuration_warnings():
	var warning_messages :PackedStringArray = []
	if !_validate_container_name().is_empty(): warning_messages.append(_validate_container_name())
	return warning_messages
	
func _validate_container_name() -> String:
	var validation_result := ""
	if self.name == "SceneContainer":
		validation_result += "SceneContainer is the generic name for this Scene. If you instantiated more than once make sure they don't have the same name. It would cause a crash when instantiated at runtime.\n   Consider changing the name of the node of instantiated scene."
	return validation_result

func _ready():
	scene_manager = SceneManager.new(is_historied)
	scene_manager._container = self
	
	if !Engine.is_editor_hint():
		_register_in_system()

func _exit_tree():
	if !Engine.is_editor_hint():
		unregister_in_system()

func _register_in_system():
	get_node("/root/"+autoload_name).register_new_container(self)

func exit_scene_with_curtain_animation():
	if self.get_child_count() == 0:
		print("Trying to exit a scene not existent in called SceneContainer")
	
	var screen_size : Vector2i = DisplayServer.screen_get_size(0)
	var screen_height : float = screen_size.y * 1.5
	var tween : Tween = create_tween()
	
	tween.tween_property($".", "position", Vector2(0, -screen_height), 0.5)
	await get_tree().create_timer(1).timeout
	_remove_current_scene_from_container()

func _remove_current_scene_from_container():
	self.get_child(0).queue_free()

func unregister_in_system():
	get_node("/root/"+autoload_name).unregister_container(self)
