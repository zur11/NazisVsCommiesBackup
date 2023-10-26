extends Node2D

func _ready():
	var initial_screen : Node = load("res://screens/loading_screen/loading_screen.tscn").instantiate()

	SceneManagerSystem.get_container("CurtainSceneContainer").goto_scene(initial_screen)


