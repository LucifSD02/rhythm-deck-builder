extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func load_resources_in_folder(folder: String) -> Array[Resource]:
	var resources: Array[Resource]
	var directory: DirAccess = DirAccess.open(folder)
	var error: Error = directory.list_dir_begin()
	if error:
		print("Critical error with listing folder ", error, " path = ", folder)
	var file_name: String = directory.get_next()

	while file_name != "":
		if not directory.current_is_dir():
			var file_path: String = folder + "/" + file_name
			var loaded_resource: Resource = load(file_path)
			resources.append(loaded_resource)
			file_name = directory.get_next()

	return resources

func format_string(input_text: String) -> String:
	return input_text.to_lower().replace(" ", "_")

func force_editor_file_refresh(absolute_path: String) -> void:
	var global_path : String = ProjectSettings.globalize_path(absolute_path)
	OS.execute("powershell", ["-Command", "(Get-Item '" + global_path + "').LastWriteTime = [DateTime]::Now"])
