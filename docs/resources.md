# Gaea's resources

Gaea takes advantage of Godot's **resources**. In this addon, they're used for the generators' settings, to hold data for each cell in the grid, and for the modifiers.

## GaeaGrid

Probably the most important resource in Gaea, it holds a dictionary of cells and their values, filled by the various generators found in the add-on. It can be easily saved using various methods, which means you can keep the world you generated without problem.

## TileInfo
This resource is stored in a certain position in the generator's grid. The base class is empty, but the subclasses such as `TilemapTileInfo` contain data that the renderer takes and uses to draw the grid.

`id`: A string value that represents your `TileInfo`. (e.g "grass"). This is used for filtering modifiers and more.\
`layer`: The `GaeaGrid` layer the TileInfo will be placed on. If it doesn't exist yet, it will automatically be created. 

## GeneratorSettings
Each generator has a unique `GeneratorSettings` resource, which includes variables like world size, rules, and the modifiers that will be applied to your generation.

You can use these resources to create different world types, floors for a roguelike dungeon, or more. Just by changing the resource, and without creating a new scene, you can have a totally different generation from your last one.

## Modifiers
Modifiers take the generation and change it algorithmically, similar to how Blender's modifiers work. They're non-destructive, meaning you can remove them, change their order, etc. without worrying about breaking your generator.

