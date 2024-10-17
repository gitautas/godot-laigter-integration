extends EditorProperty

# The main control for editing the property.
var property_control = Button.new()
var parent
var texture_type

func _init(object, type):
	parent = object
	texture_type = type
	property_control.tooltip_text

	add_child(property_control)
	add_focusable(property_control)
	property_control.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if texture_type == "normal_texture":
		generate("-n")
	elif texture_type == "specular_texture":
		generate("-c")


func generate(type):
	var laigter_path = ProjectSettings.get_setting("filesystem/import/laigter/laigter_path")
	var diffuse_texture = parent.diffuse_texture.resource_path.replace("res://", ProjectSettings.globalize_path("res://"))
	var diff_file = parent.diffuse_texture.resource_path.get_file()

	var extension = "_n" if type == "-n" else "_s"

	var gen_file = parent.diffuse_texture.resource_path.get_file().split(".")
	gen_file[0] += extension
	gen_file = ".".join(gen_file)

	var gen_path = parent.diffuse_texture.resource_path.replace(diff_file, gen_file)

	var output = []
	var exit_code = OS.execute(laigter_path, ["-g", "-d", diffuse_texture, type], output, true, false)
	if exit_code != 0:
		push_error(output)
		return

	var image = Image.load_from_file(gen_path)
	var t = ImageTexture.create_from_image(image)

	if type == "-n":
		parent.normal_texture = t
	elif type == "-c":
		parent.specular_texture = t
	print("Generated texture")
