@tool
extends GaeaGraphNodeParameter


@onready var grid_container: GridContainer = $GridContainer
@onready var drop_button: TextureButton = $DropButton



func _ready() -> void:
	super()
	var button_group: ButtonGroup = ButtonGroup.new()
	for button: Button in grid_container.get_children():
		button.text = str(button.get_index() + 1)
		button.tooltip_text = "Bit %s, value %s" % [button.get_index() + 1, 1 << button.get_index()]

		if is_instance_valid(resource):
			if resource.type == GaeaNodeArgument.Type.BITMASK_EXCLUSIVE:
				button.button_group = button_group

		button.toggled.connect(_on_value_changed.unbind(1))

	drop_button.texture_normal = EditorInterface.get_base_control().get_theme_icon(&"GuiOptionArrow", &"EditorIcons")
	drop_button.toggled.connect(_on_drop_button_toggled)


func _on_drop_button_toggled(toggled_on: bool) -> void:
	for button: Button in grid_container.get_children():
		if button.get_index() >= 8:
			button.visible = toggled_on
	drop_button.flip_v = toggled_on


func _on_value_changed() -> void:
	param_value_changed.emit(get_param_value())


func get_param_value() -> Variant:
	if super() != null:
		return super()

	if resource.type != GaeaNodeArgument.Type.FLAGS:
		var num: int = 0
		for button: Button in grid_container.get_children():
			if button.button_pressed:
				num |= 1 << button.get_index()
		return num
	else:
		var flags: Array[int]
		for button: Button in grid_container.get_children():
			if button.button_pressed:
				flags.append(1 << button.get_index())
		return flags


func set_param_value(new_value: Variant) -> void:


	if resource.type != GaeaNodeArgument.Type.FLAGS:
		if typeof(new_value) != TYPE_INT:
			return

		for button: Button in grid_container.get_children():
			button.set_pressed_no_signal(new_value & (1 << button.get_index()))
	else:
		if typeof(new_value) != TYPE_ARRAY:
			return

		for button: Button in grid_container.get_children():
			button.set_pressed_no_signal(new_value.has(1 << button.get_index()))
