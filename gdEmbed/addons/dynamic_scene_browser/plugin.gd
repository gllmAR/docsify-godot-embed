@tool
extends EditorPlugin

func _enter_tree():
	# Add the autoload
	add_autoload_singleton("SceneManagerGlobal", "res://addons/dynamic_scene_browser/scene_manager_autoload.gd")
	
	# Add the export plugin
	add_export_plugin(preload("res://addons/dynamic_scene_browser/export_plugin.gd").new())
	
	# Add project settings for configuration
	_add_project_settings()
	
	print("✅ Dynamic Scene Browser plugin enabled")

func _exit_tree():
	# Remove the autoload
	remove_autoload_singleton("SceneManagerGlobal")
	
	# Remove export plugin
	remove_export_plugin(preload("res://addons/dynamic_scene_browser/export_plugin.gd").new())
	
	print("❌ Dynamic Scene Browser plugin disabled")

func _add_project_settings():
	"""Add project settings for addon configuration"""
	if not ProjectSettings.has_setting("dynamic_scene_browser/base_path"):
		ProjectSettings.set_setting("dynamic_scene_browser/base_path", "res://scenes/")
	if not ProjectSettings.has_setting("dynamic_scene_browser/auto_generate_manifests"):
		ProjectSettings.set_setting("dynamic_scene_browser/auto_generate_manifests", true)
	if not ProjectSettings.has_setting("dynamic_scene_browser/default_scene"):
		ProjectSettings.set_setting("dynamic_scene_browser/default_scene", "")
	if not ProjectSettings.has_setting("dynamic_scene_browser/show_browser_on_empty_scene"):
		ProjectSettings.set_setting("dynamic_scene_browser/show_browser_on_empty_scene", true)
	ProjectSettings.save()
