@tool
class_name MeshGaeaRenderer
extends GaeaRenderer3D


@export var mesh_instance: MeshInstance3D
## If [code]true[/code], normals will not be smoothed,
## meaning the mesh will look more low-poly.
@export var flat_normals: bool = false


func _draw_area(area: AABB) -> void:
	if area.size == Vector3.ZERO:
		mesh_instance.mesh = null
		return

	var array_mesh: ArrayMesh = ArrayMesh.new()
	var surface_tool: SurfaceTool = SurfaceTool.new()

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	if flat_normals:
		surface_tool.set_smooth_group(-1)

	for z in range(area.position.z, area.end.z + 1):
		for x in range(area.position.x, area.end.x + 1):
			var max_height: int
			for y in range(area.position.y, area.end.y + 1):
				var tile_position := Vector3(x, y, z)

				if not generator.grid.has(tile_position):
					continue

				max_height = maxi(
					tile_position.y, max_height
				)

			surface_tool.add_vertex(Vector3(x, max_height, z))


	var vert: int = 0
	for z in area.size.z:
		for x in area.size.x:
			surface_tool.add_index(vert)
			surface_tool.add_index(vert + 1)
			surface_tool.add_index(vert + area.size.x + 1)
			surface_tool.add_index(vert + area.size.x + 1)
			surface_tool.add_index(vert + 1)
			surface_tool.add_index(vert + area.size.x + 2)
			vert += 1
		vert += 1

	surface_tool.generate_normals()

	array_mesh = surface_tool.commit()

	mesh_instance.mesh = array_mesh

