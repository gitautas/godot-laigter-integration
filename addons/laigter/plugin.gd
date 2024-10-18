@tool
extends EditorPlugin

const SETTING_LAIGTER_PATH = "filesystem/import/laigter/laigter_path"

var plugin
var laigter_path = ProjectSettings.get_setting(SETTING_LAIGTER_PATH)

func _enter_tree():
    register_settings()
    ProjectSettings.settings_changed.connect(verify_laigter_path)
    verify_laigter_path()

    plugin = preload("res://addons/laigter/laigter.gd")
    add_inspector_plugin(plugin.LaigterPlugin.new())


func _exit_tree():
    remove_inspector_plugin(plugin)


func register_settings():
    if ProjectSettings.get_setting(SETTING_LAIGTER_PATH) == null:
        ProjectSettings.set_setting(SETTING_LAIGTER_PATH, "laigter")

    ProjectSettings.set_initial_value(SETTING_LAIGTER_PATH, "laigter")
    ProjectSettings.add_property_info({
        "name": SETTING_LAIGTER_PATH,
        "type": TYPE_STRING,
        "hint": PROPERTY_HINT_GLOBAL_FILE
    })
    ProjectSettings.set_as_basic(SETTING_LAIGTER_PATH, true)


func verify_laigter_path():
    var current_path = ProjectSettings.get_setting(SETTING_LAIGTER_PATH)

    if laigter_path != current_path:
        laigter_path = current_path
        check_laigter_binary()


func check_laigter_binary():
    var output = []
    var exit_code = OS.execute(laigter_path, ["-h"], output, true, false)

    if exit_code != 0:
        push_error("Failed to verify Laigter binary. Set the path to the Laigter binary in Project Settings -> Input:")
        push_error("\n".join(output))
