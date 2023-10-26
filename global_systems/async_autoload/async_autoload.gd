extends Node

signal resource_loaded
var loading_url : String
var progress_array: Array
var loaded_resources : Array


func _ready():
	set_process(false)

func clear():
	loaded_resources = []

func load_resource(_resource_path: String):
	loading_url = _resource_path
	ResourceLoader.load_threaded_request(loading_url)
	set_process(true)
	await self.resource_loaded
	var loaded_resource = ResourceLoader.load_threaded_get(loading_url)
	loaded_resources.append(loaded_resource)
	return loaded_resource


func _process(_delta):
#	printt("inprocees", loading_url, ResourceLoader.load_threaded_get_status(loading_url, progress_array), progress_array)

	if ResourceLoader.load_threaded_get_status(loading_url) == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		emit_signal("resource_loaded")
