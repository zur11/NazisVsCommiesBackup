class_name UserDataPersistent extends Node

const _FILE_NAME : String = "user://user_data.tres"

static func save_to_disk(new_value:UserData):
	var result := ResourceSaver.save(new_value, _FILE_NAME)
	assert(result == OK)

static func load_from_disk() -> UserData:
	if ResourceLoader.exists(_FILE_NAME):
		return ResourceLoader.load(_FILE_NAME) as UserData
	else:
		return UserData.new()
