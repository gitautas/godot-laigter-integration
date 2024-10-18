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

    enum TextureType {
        NORMAL,
        SPECULAR
    }

    func _init(object, type):
        parent = object
        if type == "normal_texture":
            texture_type = TextureType.NORMAL
        elif type == "specular_texture":
            texture_type = TextureType.SPECULAR

        add_child(property_control)
        add_focusable(property_control)

        property_control.pressed.connect(generate)
        property_control.text = "Generate"

    func generate():
        var diffuse_texture = parent.diffuse_texture.resource_path.replace("res://", ProjectSettings.globalize_path("res://"))
        var diff_file = parent.diffuse_texture.resource_path.get_file()

        var extension = ""
        var type_arg = ""

        match texture_type:
            TextureType.NORMAL:
                extension = "_n"
                type_arg = "-n"
            TextureType.SPECULAR:
                extension = "_s"
                type_arg = "-c"

        var gen_file = diff_file.get_basename() + extension + "." + diff_file.get_extension()
        var gen_path = parent.diffuse_texture.resource_path.replace(diff_file, gen_file)

        var output = []
        var exit_code = OS.execute(laigter_path, ["-g", "-d", diffuse_texture, type_arg], output, true, false)

        if exit_code != 0:
            push_error("Laigter: Error generating texture: " + "\n".join(output))
            return

        var image = Image.load_from_file(gen_path)
        var texture = ImageTexture.create_from_image(image)

        match texture_type:
            TextureType.NORMAL:
                parent.normal_texture = texture
                print("Laigter: Generated normal texture")
            TextureType.SPECULAR:
                parent.specular_texture = texture
                print("Laigter: Generated specular texture")
