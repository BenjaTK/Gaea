@tool
class_name GaeaGraphNode
extends GraphNode
## The in-editor representation of a [GaeaNodeResource] to be used in the Gaea bottom panel.

const _PreviewTexture = preload("uid://dns7s4v8lom4t")

## Emitted when a save is needed from the Gaea panel.
signal save_requested
## Emitted when connections to this node are updated.
signal connections_updated
## Emitted when this node is removed from the graph.
signal removed

## The [GaeaNodeResource] this acts as an editor of.
@export var resource: GaeaNodeResource

## The currently associated generator.
var generator: GaeaGenerator
## List of connections that goes to this node from other nodes.
## Used by the generator during runtime. This list is updated
## from [method update_connections] method.
var connections: Array[Dictionary]
# Holds a cache of the generated titlebar styleboxes for each [enum GaeaValue.Type].
# Updated if the type's color changes.
static var _titlebar_styleboxes: Dictionary[GaeaValue.Type, Dictionary]
var _preview: _PreviewTexture
var _preview_container: VBoxContainer
var _finished_loading: bool = false : set = set_finished_loading, get = has_finished_loading
var _editors: Dictionary[StringName, GaeaGraphNodeParameterEditor]


func _ready() -> void:
	_on_added()

	if is_instance_valid(resource):
		set_tooltip_text(GaeaNodeResource.get_formatted_text(resource.description))

	connections_updated.connect(_update_arguments_visibility)
	removed.connect(_on_removed)


## Initializes the node with a preview if needed, a salt value and instantiates all the
## [GaeaGraphNodeParameterEditor] and [GaeaGraphNodeOutput] nodes.
func _on_added() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	resource.node = self
	_editors.clear()

	for argument in resource.get_arguments_list():
		var scene: PackedScene = GaeaValue.get_editor_for_type(resource.get_argument_type(argument))
		var node: GaeaGraphNodeParameterEditor = scene.instantiate()
		add_child(node)
		node.initialize(
			self,
			resource.get_argument_type(argument),
			resource.get_argument_display_name(argument),
			resource.get_argument_default_value(argument)
		)
		_editors.set(argument, node)
		node.param_value_changed.connect(_on_param_value_changed.bind(node, argument))

	var preview_button_group: ButtonGroup = ButtonGroup.new()
	preview_button_group.allow_unpress = true

	for output in resource.get_output_ports_list():
		var node: GaeaGraphNodeOutput = preload("uid://cqpby5jyv71l0").instantiate()
		add_child(node)
		node.initialize(
			self,
			resource.get_output_port_type(output),
			resource.get_output_port_display_name(output)
		)
		if GaeaValue.has_preview(resource.get_output_port_type(output)):
			node.get_toggle_preview_button().show()

			if not is_instance_valid(_preview):
				_preview_container = VBoxContainer.new()
				_preview = _PreviewTexture.new()
				_preview.node = self
				generator.generation_finished.connect(_preview.update.unbind(1))

			node.get_toggle_preview_button().button_group = preview_button_group
			node.get_toggle_preview_button().toggled.connect(_preview.toggle.bind(output).unbind(1))

#

#
	#if resource.salt == 0:
		#resource.salt = randi()
#
	#var idx: int = 0
#
	#for param in resource.params:
		#add_child(param.get_node(self, idx))
		#idx += 1
#
	#for output in resource.outputs:
		#var node := output.get_node(self, idx)
		#add_child(node)
		#idx += 1

#
	if is_instance_valid(_preview_container):
		add_child(_preview_container)
		_preview_container.add_child(_preview)
		_preview_container.hide()

	title = resource.get_title()
	#resource.node = self
#
	var type: GaeaValue.Type = resource.get_type()
	var titlebar: StyleBoxFlat
	var titlebar_selected: StyleBoxFlat
	if type != GaeaValue.Type.NULL:
		if not _titlebar_styleboxes.has(type) or _titlebar_styleboxes.get(type).get("for_color", Color.TRANSPARENT) != resource.get_title_color():
			titlebar = get_theme_stylebox("titlebar", "GraphNode").duplicate()
			titlebar_selected = get_theme_stylebox("titlebar_selected", "GraphNode").duplicate()
			titlebar.bg_color = titlebar.bg_color.blend(Color(resource.get_title_color(), 0.3))
			titlebar_selected.bg_color = titlebar.bg_color
			_titlebar_styleboxes.set(type, {"titlebar": titlebar, "selected": titlebar_selected, "for_color": resource.get_title_color()})
		else:
			titlebar = _titlebar_styleboxes.get(type).get("titlebar")
			titlebar_selected = _titlebar_styleboxes.get(type).get("selected")
		add_theme_stylebox_override("titlebar", titlebar)
		add_theme_stylebox_override("titlebar_selected", titlebar_selected)


## Returns the current value set in the [GaeaGraphNodeParameterEditor] for the argument of [param arg_name].
func get_arg_value(arg_name: String) -> Variant:
	var editor: GaeaGraphNodeParameterEditor = _editors.get(arg_name, null)
	if is_instance_valid(editor):
		return editor.get_param_value()
	return null


## Sets the [GaeaGraphNodeParameterEditor] associated to the argument of [param arg_name] to [param value].
func _set_arg_value(arg_name: String, value: Variant) -> void:
	var editor: GaeaGraphNodeParameterEditor = _editors.get(arg_name, null)
	if is_instance_valid(editor):
		editor.set_param_value(value)


func _on_param_value_changed(_value: Variant, _node: GaeaGraphNodeParameterEditor, _param_name: String) -> void:
	resource.notify_argument_list_changed()
	if _finished_loading:
		save_requested.emit()
		if is_instance_valid(_preview):
			_preview.update()

# Makes argument editors invisible if there's a wire connected to their input slot.
func _update_arguments_visibility() -> void:
	var input_idx: int = -1
	for child in get_children():
		if not is_slot_enabled_left(child.get_index()):
			continue
		input_idx += 1

		if child is GaeaGraphNodeParameterEditor:
			child.set_param_visible(not connections.any(_is_connected_to.bind(input_idx)))

	auto_shrink()


func _on_removed() -> void:
	pass


func _request_save() -> void:
	save_requested.emit()


## Emit [signal connections_updated].
func notify_connections_updated() -> void:
	connections_updated.emit()


func _is_connected_to(connection: Dictionary, idx: int) -> bool:
	return connection.to_port == idx and connection.to_node == name


## Resizes the node to its minimum possible size, and updates wire display accordingly.
func auto_shrink() -> void:
	size = get_combined_minimum_size()
	# This is used to force the wire to redraw at the correct location
	await get_tree().process_frame
	for i: int in get_child_count():
		slot_updated.emit.call_deferred(i)


## Returns the data to be saved to [GaeaData]. Includes [member Node.name], [member GraphElement.position_offset] and [member GaeaNodeResource.salt].
func get_save_data() -> Dictionary:
	var dictionary: Dictionary = {
		"name": name,
		"position": position_offset,
		"salt": resource.salt
	}
	dictionary.set("arguments", {})
	for argument in resource.get_arguments_list():
		var value: Variant = get_arg_value(argument)
		if value == null:
			continue
		if value != resource.get_argument_default_value(argument):
			dictionary.data[argument] = get_arg_value(argument)
	print(dictionary)
	return dictionary


## Loads data with the same format as seen in [method get_save_data].
func load_save_data(saved_data: Dictionary) -> void:
	if saved_data.has("position"):
		position_offset = saved_data.position
	if saved_data.has("arguments"):
		var data = saved_data.get("arguments")
		for argument: StringName in resource.get_arguments_list():
			var editor: GaeaGraphNodeParameterEditor = _editors.get(argument)
			if not is_instance_valid(editor):
				break

			if not data.has(argument):
				data.set(argument, resource.get_argument_default_value(argument))

			if data.get(argument) != null:
				editor.set_param_value(data.get(argument))

		#for child in get_children():
			#if child is GaeaGraphNodeParameterEditor:


	_finished_loading = true


func _make_custom_tooltip(for_text: String) -> Object:
	var rich_text_label: RichTextLabel = RichTextLabel.new()
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	rich_text_label.bbcode_enabled = true
	rich_text_label.text = for_text
	rich_text_label.fit_content = true
	rich_text_label.custom_minimum_size.x = 256.0
	return rich_text_label


## Sets whether or not this node has finished its loading process.
func set_finished_loading(value: bool) -> void:
	_finished_loading = value


## Returns [code]true[/code] if this node has finished its loading process.
func has_finished_loading() -> bool:
	return _finished_loading
