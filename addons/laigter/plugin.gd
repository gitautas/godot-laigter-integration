@tool
extends EditorPlugin

var plugin
var laigter_path = ProjectSettings.get_setting("filesystem/import/laigter/laigter_path")

func _enter_tree():
    register_settings()
    ProjectSettings.settings_changed.connect(verify_laigter_path)
    verify_laigter_path()

    plugin = preload("res://addons/laigter/laigter.gd")
    add_inspector_plugin(plugin.LaigterPlugin.new())


func _exit_tree():
    remove_inspector_plugin(plugin)


func register_settings():
    if ProjectSettings.get_setting("filesystem/import/laigter/laigter_path") == null:
        ProjectSettings.set_setting("filesystem/import/laigter/laigter_path", "laigter")

    ProjectSettings.set_initial_value("filesystem/import/laigter/laigter_path", "laigter")
    ProjectSettings.add_property_info({
        "name": "filesystem/import/laigter/laigter_path",
        "type": TYPE_STRING,
        "hint": PROPERTY_HINT_GLOBAL_FILE
    })
    ProjectSettings.set_as_basic("filesystem/import/laigter/laigter_path", true)


func verify_laigter_path():
    var current_path = ProjectSettings.get_setting("filesystem/import/laigter/laigter_path")

    if laigter_path == current_path:
        return

    laigter_path = current_path
    check_laigter_binary()


func check_laigter_binary():
    var output = []
    var exit_code = OS.execute(laigter_path, ["-h"], output, true, false)

    if exit_code != 0:
        push_error("Failed to verify Laigter binary. Set the path to the Laigter binary in Project Settings -> Input:")
        for line in output:
            push_error(line)
