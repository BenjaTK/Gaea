@tool
@icon("../assets/data.svg")
class_name GaeaData
extends Resource
## Resource that holds the saved data for a Gaea graph.


const CURRENT_SAVE_VERSION := 2

## Emitted when the size of [member layers] is changed, or when one of its values is changed.
signal layer_count_modified

## Flags used for determining what to log during generation. See [member logging].
enum Log {
	None=0,
	Execute=1, ## Log execution data such as current area & current layer.
	Traverse=2, ## Log traverse data (which nodes are being traversed in the graph).
	Data=4,  ## Log which data is being generated from which port.
	Args=8  ## Log which arguments are being grabbed.
}

## [GaeaLayer]s as seen in the Output node in the graph. Can be used
## to allow more than one [GaeaMaterial] in a single tile.
@export var layers: Array[GaeaLayer] = [GaeaLayer.new()] :
	set(value):
		layers = value
		layer_count_modified.emit()
		emit_changed()
@export_group("Debug")
## Selection of what to print in the Output console during generation. See [enum Log].
@export_flags("Execute", "Traverse", "Data", "Args") var logging:int = Log.None
## List of all connections between nodes. The dictionaries contain the following properties:
## [codeblock]
## {
##    from_node: int, # Index of the node in [member resources]
##    from_port: int, # Index of the port of the node
##    to_node: int,   # Index of the node in [member resources]
##    to_port: int,   # Index of the port of the node
##    keep_alive: bool
## }
## [/codeblock]
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var connections: Array[Dictionary]
## List of all UIDs of the [GaeaNodeResource]s in the graph.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var resource_uids: Array[String]
## Used for migration of old save data.
var resources: Array[GaeaNodeResource]
## Saved data for each [GaeaNodeResource] such as position in the graph and changed arguments.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var node_data: Array[Dictionary]
## List of parameters created with [GaeaNodeParameter].
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
## Use [method set_parameter] instead.
@export_storage var parameters: Dictionary[StringName, Variant]
## Other saved data, such as [GraphFrame] information.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var other: Dictionary

## The currently related generator.
var generator: GaeaGenerator
## Cache used during generation to avoid calculating data more than once when unnecessary.
var cache: Dictionary[GaeaNodeResource, Dictionary] = {}


func _init() -> void:
	resource_local_to_scene = true
	notify_property_list_changed()

## Get the parameter of [param name] from [member parameters].
func get_parameter(name: StringName) -> Variant:
	return _get(name)


## Set the parameter of [param name] from [member parameters] to [param value].
func set_parameter(name: StringName, value: Variant) -> void:
	_set(name, value)


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	list.append({
		"name": "Parameters",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	for variable in parameters.values():
		if variable == null:
			parameters.erase(parameters.find_key(variable))
			continue

		list.append(variable)

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property and typeof(value) == variable.type:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			return variable.value
	return


func _setup_local_to_scene() -> void:
	#Data migration from 2.0 beta. See PR #305. Remove before releasing 2.X.
	if other.get(&"save_version", -1) != CURRENT_SAVE_VERSION:
		_migrate_data()
	resources = []
	for idx in resource_uids.size():
		var base_uid = resource_uids[idx]
		var data: Dictionary = node_data[idx]
		var resource: GaeaNodeResource = load(base_uid).new()
		if not resource is GaeaNodeResource:
			push_error("Something went wrong, the resource at %s is not a GaeaNodeResource" % base_uid)
			return
		resource = resource._instantiate_duplicate()
		resource._load_save_data(data)
		resources.append(resource)


#region Migration from previous save format
# Data migration from 2.0 beta. See PR #305. Remove before releasing 2.X.
func _migrate_data() -> void:
	# Contains all migration data.
	# Each key is the previous UID.
	# The value can either be:
	# - A String: for a simple direct mapping to a new UID.
	# - An Array:
	#     - First element: the new UID.
	#     - Second element: the values to assign in the data array.
	#     - Third element: the keys to rename in the arguments Dictionary.
	var node_map: Dictionary[String, Variant] = {
		"uid://bbkdvyxkj2slo": "uid://dol7xviglksx4", #output_node_resource.tres
		"uid://kdn03ei2yp6e": "uid://bgqqucap4kua4", #reroute_node_resource.tres

		"uid://b2bpg5nt6l31": "uid://bq3vxxpkxn5ds", #root/conditional/constants/bool_constant.tres
		"uid://c1k7e0whh2ewx": "uid://cq66v7je7qj85", #root/scalar/constants/float_constant.tres
		"uid://cql58fvdlebeu": "uid://c2336gqnb6ym3", #root/scalar/constants/int_constant.tres
		"uid://cs1wgu81ww5lr": "uid://qmbp427uv8sx", #root/vector/constants/vector2_constant.tres
		"uid://n2su2s1w248e": "uid://bqn35k1o7lpso", #root/vector/constants/vector3_constant.tres

		"uid://cta2ipm8oe120": "uid://coltk43t8om1t", #root/conditional/variables/bool_variable.tres
		"uid://ce7tbrfosey37": "uid://ry32fdv76f2o", #root/scalar/variables/float_variable.tres
		"uid://37ihrctuxf3": "uid://buonx1umcjin8", #root/scalar/variables/int_variable.tres
		"uid://dwpdb8ltkg43a": "uid://b3up843psvqnl", #root/vector/variables/vector2i_variable.tres
		"uid://bf3aefanhvr6l": "uid://p8ajvshxenm3", #root/vector/variables/vector2_variable.tres
		"uid://btf8xr1jdb3xf": "uid://dcdrs7xlfy83j", #root/vector/variables/vector3i_variable.tres
		"uid://dskijywvj2y8d": "uid://dul1tbuy0b13a", #root/vector/variables/vector3_variable.tres
		"uid://r4woxxrppbhr": "uid://cumythno5ccu3", #root/resources/variables/material_gradient_variable.tres
		"uid://byrhtfsduac1x": "uid://cqs1w714pbfql", #root/resources/variables/material_variable.tres

		"uid://ch7u7802bkv3v": "uid://b7naniphpp341", #root/data/basic/fill.tres
		"uid://pisw6udylbhn": "uid://741f2tjbjf7c", #root/data/border/border.tres
		"uid://bjgl7hlbbjuws": "uid://dnj3grm2qv20y", #root/data/filters/distance_filter.tres
		"uid://dvk2wlxbo4wyv": "uid://craai02gndxaq", #root/data/filters/flags_filter.tres
		"uid://cu6746ccrvp44": "uid://b38syakgm25ya", #root/data/filters/random_filter.tres
		"uid://cunarm8apr55l": "uid://d3ahx5mfke6wg", #root/data/filters/threshold_filter.tres

		"uid://b1vj6la3lmq5f": ["uid://0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.COMPLEMENT]}], #root/data/functions/data_complement.tres
		"uid://c4ks3ukknfqkm": ["uid://0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.DIFFERENCE]}], #root/data/functions/data_difference.tres
		"uid://bekpvvtetmvgm": ["uid://0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.INTERSECTION]}], #root/data/functions/data_intersection.tres
		"uid://4ybwu0m8kw1a": ["uid://0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.UNION]}], #root/data/functions/data_union.tres

		"uid://blm6fqdfqa5bh": "uid://cgnbu4kly4sls", #root/data/generation/falloff.tres
		"uid://b7ad0bauchvyu": ["uid://blx812352t3jj", {&"enums": [GaeaNodeFloorWalker.AxisType.XY]}], #root/data/generation/floor_walker_xy.tres
		"uid://nh1dr3qjpivi": ["uid://blx812352t3jj", {&"enums": [GaeaNodeFloorWalker.AxisType.XZ]}], #root/data/generation/floor_walker_xz.tres
		"uid://bh1u4kqfvh0fy": "uid://d0bgv7yf1t1m6", #root/data/generation/snake_path_2d.tres

		"uid://dhey5y1gvfgxg": "uid://cgjyi804j05dy", #root/data/noise/simplex_smooth_2D.tres
		"uid://bumgueaiw5d1f": "uid://c3xxswfpt3mny", #root/data/noise/simplex_smooth_3D.tres

		"uid://b5x1wxss4spod": ["uid://c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.Add]}, {&"value": &"b"}], #root/data/operations/add.tres
		"uid://b3q8md2biskfq": ["uid://c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.Subtract]}, {&"value": &"b"}], #root/data/operations/substract.tres
		"uid://coi1put8oap60": ["uid://c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.Multiply]}, {&"value": &"b"}], #root/data/operations/multiply.tres
		"uid://d4f3kftfw2inw": ["uid://c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.Divide]}, {&"value": &"b"}], #root/data/operations/divide.tres

		"uid://drhtdob82hwua": ["uid://dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.Add]}], #root/data/operations/add_datas.tres
		"uid://bb81ds61i41r1": ["uid://dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.Subtract]}], #root/data/operations/substract_datas.tres
		"uid://dv5677k1v6n": ["uid://dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.Multiply]}], #root/data/operations/multiply_datas.tres
		"uid://f6ycpjqowl41": ["uid://dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.Divide]}], #root/data/operations/divide_datas.tres

		"uid://dyk8vkdntdudc": ["uid://fc8vogh4mvhw", {&"enums": [GaeaNodeInput.InputVar.WORLD_SIZE]}], #root/input/world_size.tres

		"uid://40kjl8ojif34": "uid://coh5skum82ue3", #root/map/filters/random_filter.tres

		"uid://dp08ix2q7gxas": ["uid://d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.DIFFERENCE]}], #root/map/functions/map_difference.tres
		"uid://c3kfx8jda3ghq": ["uid://d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.INTERSECTION]}], #root/map/functions/map_intersection.tres
		"uid://dtgm8q3pqox6c": ["uid://d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.UNION]}], #root/map/functions/map_union.tres

		"uid://dnr2f2kgvmyjd": "uid://dux0bq53p61ls", #root/map/mappers/basic_mapper.tres
		"uid://dpienqmp335jg": "uid://bdwxrdlr0267t", #root/map/mappers/flags_mapper.tres
		"uid://dvedjf7t120jr": "uid://c4yhilhmhasb2", #root/map/mappers/gradient_mapper.tres
		"uid://conft7neua4ww": "uid://djjvx650evm0n", #root/map/mappers/threshold_mapper.tres
		"uid://6tctdjrjbard": "uid://cd25npsj1ey2n", #root/map/mappers/value_mapper.tres
		"uid://c2u75oyoi2lne": "uid://br8gcsyc04ksj", #root/map/placing/rules_placer.tres
		"uid://buu32u5bluejt": "uid://bjmyuomcmtwq6", #root/map/random/random_scatter.tres


		"uid://dtc6nrgjvi8pw": ["uid://yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.Add]}], #root/scalar/operations/add.tres
		"uid://167vhd3o81mk": ["uid://yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.Subtract]}], #root/scalar/operations/substract.tres
		"uid://rcvehn8ulhem": ["uid://yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.Multiply]}], #root/scalar/operations/multiply.tres
		"uid://cs35p7d6oiu4w": ["uid://yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.Divide]}], #root/scalar/operations/divide.tres

		"uid://bmjbf86en6cas": ["uid://c1koyt7wh4c4v", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2]}, {&"min": &"x", &"max": &"y"}], #root/other/composition/compose_range.tres
		"uid://dv28660onn7fl": ["uid://c1koyt7wh4c4v", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2]}], #root/vector/composition/compose_vector2.tres
		"uid://dfjr83x416ec4": ["uid://c1koyt7wh4c4v", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3]}], #root/vector/composition/compose_vector3.tres
		"uid://o054c8xv8xb": ["uid://b1vu2sfwynxql", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2]}], #root/vector/decomposition/decompose_vector2.tres
		"uid://evg3g607sf40": ["uid://b1vu2sfwynxql", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3]}], #root/vector/decomposition/decompose_vector3.tres
		
		"uid://cm0wp1if8nc6k": "", #root/vector/operations/add_vector2.tres
		"uid://bq878twqcc5f": "", #root/vector/operations/add_vector3.tres
		"uid://cgd05tlepxucw": "", #root/vector/operations/divide_vector2.tres
		"uid://hut3x2e74y85": "", #root/vector/operations/divide_vector3.tres
		"uid://cktjgkxfx8pyh": "", #root/vector/operations/multiply_vector2.tres
		"uid://cq0gpnw7juqpk": "", #root/vector/operations/multiply_vector3.tres
		"uid://d20pwbkvqkqnq": "", #root/vector/operations/substract_vector2.tres
		"uid://boe1a3sogwvyw": "", #root/vector/operations/substract_vector3.tres
	}

	for idx in resource_uids.size():
		var base_uid = resource_uids[idx]
		
		if node_data[idx].has("data"):
			node_data[idx].set(&"arguments", node_data[idx].get("data"))
			node_data[idx].erase("data")

		if node_map.has(base_uid):
			var target_data = node_map.get(base_uid)
			if typeof(target_data) == TYPE_STRING:
				resource_uids[idx] = target_data
			else:
				# Resource UID
				resource_uids[idx] = target_data[0]
				# Static data to set
				if target_data.size() > 1:
					for data_key in target_data[1]:
						node_data[idx].set(data_key, target_data[1].get(data_key))
				# Argument keys to rename
				if target_data.size() > 2:
					for old_key in target_data[2].keys():
						var arguments: Dictionary = node_data[idx].get(&"arguments")
						arguments.set(target_data[2].get(old_key), arguments.get(old_key))
						arguments.erase(old_key)
#endregion
