# A tool to provide extended filesystem editor functionallity
class_name EditorFileSystemControls
extends RefCounted


# Register the given context menu to the filesystem dock
# Is called when the plugin is activated
# The filesystem popup is connected to the EditorFileSystemContextMenuHandler
static func register_context_menu(menu: Array[GdUnitContextMenuItem]) -> void:
	Engine.get_main_loop().root.add_child.call_deferred(EditorFileSystemContextMenuHandler.new(menu))


# Unregisteres all registerend context menus and gives the EditorFileSystemContextMenuHandler> free
# Is called when the plugin is deactivated
static func unregister_context_menu() -> void:
	EditorFileSystemContextMenuHandler.dispose()


static func _print_menu(popup: PopupMenu) -> void:
	for itemIndex in popup.item_count:
		prints("get_item_id", popup.get_item_id(itemIndex))
		prints("get_item_accelerator", popup.get_item_accelerator(itemIndex))
		prints("get_item_shortcut", popup.get_item_shortcut(itemIndex))
		prints("get_item_text", popup.get_item_text(itemIndex))
		prints()
