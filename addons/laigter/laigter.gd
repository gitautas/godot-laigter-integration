class LaigterPlugin extends EditorInspectorPlugin:
    func _can_handle(object):
        return object is CanvasTexture


    func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
        if name in ["normal_texture", "specular_texture"]:
            add_property_editor("laigter", LaigterEditor.new(object, name), true, "Laigter")
        return false


class LaigterEditor extends EditorProperty:
    var property_control = Button.new()
    var laigter_path = ProjectSettings.get_setting("filesystem/import/laigter/laigter_path")
    var parent
    var texture_type

    func _init(object, type):
        parent = object
        texture_type = type
        add_child(property_control)
        add_focusable(property_control)
        property_control.pressed.connect(_on_button_pressed)
        property_control.text = "Generate"

    func _on_button_pressed():
        generate()

    func generate():
        var diffuse_texture = parent.diffuse_texture.resource_path.replace("res://", ProjectSettings.globalize_path("res://"))
        var diff_file = parent.diffuse_texture.resource_path.get_file()
        var extension
        var type_arg

        if texture_type == "normal_texture":
            extension = "_n"
            type_arg =  "-n"
        elif texture_type == "specular_texture":
            extension = "_s"
            type_arg =  "-c"

        var gen_file = diff_file.get_basename() + extension + "." + diff_file.get_extension()
        var gen_path = parent.diffuse_texture.resource_path.replace(diff_file, gen_file)

        var output = []
        var exit_code = OS.execute(laigter_path, ["-g", "-d", diffuse_texture, type_arg], output, true, false)

        if exit_code != 0:
            push_error("Error generating texture: " + output.join("\n"))
            return

        var image = Image.load_from_file(gen_path)
        var texture = ImageTexture.create_from_image(image)

        if texture_type == "normal_texture":
            parent.normal_texture = texture
        elif texture_type == "specular_texture":
            parent.specular_texture = texture
        print("Generated " + " ".join(texture_type.split("_")))
