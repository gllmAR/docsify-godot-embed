@tool
extends EditorPlugin

func _enter_tree():
	# Add the autoload
	add_autoload_singleton("SceneManagerGlobal", "res://addons/dynamic_scene_browser/scene_manager_autoload.gd")
	
	# Add the export plugin
	add_export_plugin(preload("res://addons/dynamic_scene_browser/export_plugin.gd").new())
	
	print("✅ Dynamic Scene Browser plugin enabled")

func _exit_tree():
	# Remove the autoload
	remove_autoload_singleton("SceneManagerGlobal")
	
	# Remove export plugin
	remove_export_plugin(preload("res://addons/dynamic_scene_browser/export_plugin.gd").new())
	
	print("❌ Dynamic Scene Browser plugin disabled")
