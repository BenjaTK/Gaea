@tool
extends GaeaNodeResource
class_name GaeaNodeReroute
## Allows rerouting a connection within the Gaea graph.
##
## Can be placed by pressing [kbd]Right Click[/kbd] in a connection wire and selecting the option,
## and it'll automatically adapt to the type of the selected wire.


enum EnumList {
	RerouteType
}


func _get_title() -> String:
	return "Reroute"


func _get_description() -> String:
	return "Allows rerouting a connection within the Gaea graph."


#region Enum
func _get_enums_count() -> int:
	return EnumList.size()


func _get_enum_options(enum_idx: int) -> Dictionary:
	match enum_idx:
		EnumList.RerouteType:
			var list = {}
			for type_name in GaeaValue.Type:
				if GaeaValue.is_wireable(GaeaValue.Type[type_name]):
					list.set(type_name, GaeaValue.Type[type_name])
			return list
	return {}


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()
#endregion


#region Arguments
func _get_arguments_list() -> Array[StringName]:
	return [&"value"]


@warning_ignore("unused_parameter")
func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	@warning_ignore("int_as_enum_without_cast")
	return get_enum_selection(EnumList.RerouteType)
#endregion


#region Outputs
func _get_output_ports_list() -> Array[StringName]:
	return _get_arguments_list()


@warning_ignore("unused_parameter")
func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	@warning_ignore("int_as_enum_without_cast")
	return get_enum_selection(EnumList.RerouteType)
#endregion


func _get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Variant:
	return _get_arg(output_port, area, generator_data)


func _use_caching(_output_port: StringName, _generator_data:GaeaData) -> bool:
	return false
