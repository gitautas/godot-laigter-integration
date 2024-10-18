class LaigterPlugin extends EditorInspectorPlugin:
    const SUPPORTED_TEXTURES = ["normal_texture", "specular_texture"]

    func _can_handle(object):
        return object is CanvasTexture

    func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
        if name in SUPPORTED_TEXTURES:
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
        texture_type = _get_texture_type(type)

        add_child(property_control)
        add_focusable(property_control)

        property_control.pressed.connect(_on_generate_pressed)
        property_control.text = "Generate"

    func _get_texture_type(type):
        match type:
            "normal_texture":
                return TextureType.NORMAL
            "specular_texture":
                return TextureType.SPECULAR
            _:
                return null

    func _on_generate_pressed():
        var diffuse_texture_path = _get_diffuse_texture_path()
        var gen_file_path = _get_generated_file_path(diffuse_texture_path)

        var output = []
        var exit_code = OS.execute(laigter_path, ["-g", "-d", diffuse_texture_path, _get_type_arg()], output, true, false)

        if exit_code != 0:
            push_error("Laigter: Error generating texture: " + "\n".join(output))
            return

        _load_and_assign_texture(gen_file_path)

    func _get_diffuse_texture_path():
        return parent.diffuse_texture.resource_path.replace("res://", ProjectSettings.globalize_path("res://"))

    func _get_generated_file_path(diffuse_texture_path):
        var diff_file = parent.diffuse_texture.resource_path.get_file()
        var extension = _get_extension()
        var gen_file = diff_file.get_basename() + extension + "." + diff_file.get_extension()
        return parent.diffuse_texture.resource_path.replace(diff_file, gen_file)

    func _get_extension():
        match texture_type:
            TextureType.NORMAL:
                return "_n"
            TextureType.SPECULAR:
                return "_s"

    func _get_type_arg():
        match texture_type:
            TextureType.NORMAL:
                return "-n"
            TextureType.SPECULAR:
                return "-c"

    func _load_and_assign_texture(gen_file_path):
        var image = Image.load_from_file(gen_file_path)
        var texture = ImageTexture.create_from_image(image)

        match texture_type:
            TextureType.NORMAL:
                parent.normal_texture = texture
                print("Laigter: Generated normal texture")
            TextureType.SPECULAR:
                parent.specular_texture = texture
                print("Laigter: Generated specular texture")
