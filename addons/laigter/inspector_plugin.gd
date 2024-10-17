extends EditorInspectorPlugin

var LaigterEditor = preload("res://addons/laigter/laigter.gd")

func _can_handle(object):
	if object is CanvasTexture:
		return true
	else: return false


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "normal_texture" or name == "specular_texture":
		add_property_editor("generate", LaigterEditor.new(object, name), true, "Generate")
	return false
