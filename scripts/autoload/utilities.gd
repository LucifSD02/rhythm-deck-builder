extends Node

const IMAGE_EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func load_resources_in_folder(folder: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var directory: DirAccess = DirAccess.open(folder)
	if directory == null:
		push_error("Could not open folder '%s': %s" % [folder, error_string(DirAccess.get_open_error())])
		return resources

	directory.list_dir_begin()
	var file_name: String = directory.get_next()

	while file_name != "":
		if not directory.current_is_dir():
			var file_path: String = folder + "/" + file_name
			var loaded_resource: Resource = load(file_path)
			resources.append(loaded_resource)
		file_name = directory.get_next()

	return resources


func load_images_in_folder(folder: String) -> Array[Texture2D]:
	var textures: Array[Texture2D]
	var directory: DirAccess = DirAccess.open(folder)
	if directory == null:
		push_error("Could not open folder '%s': %s" % [folder, error_string(DirAccess.get_open_error())])
		return textures

	directory.list_dir_begin()
	var file_name: String = directory.get_next()

	while file_name != "":
		var extension: String = file_name.get_extension().to_lower()
		if not directory.current_is_dir() and extension in IMAGE_EXTENSIONS:
			var file_path: String = folder + "/" + file_name
			var texture: Texture2D = load(file_path) as Texture2D
			if texture != null:
				textures.append(texture)
		file_name = directory.get_next()

	return textures


func format_string(input_text: String) -> String:
	return input_text.to_lower().replace(" ", "_")


func force_editor_file_refresh(absolute_path: String) -> void:
	var global_path: String = ProjectSettings.globalize_path(absolute_path)
	OS.execute("powershell", ["-Command", "(Get-Item '" + global_path + "').LastWriteTime = [DateTime]::Now"])
