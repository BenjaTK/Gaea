# Gaea's resources

Gaea takes advantage of Godot's **resources**. In this addon, they're used for the generators' settings, telling the generators which tiles from the TileMap to use, and for the modifiers.

### GeneratorSettings
Each generator has a unique `GeneratorSettings` resource, which includes variables like world size, rules, and the modifiers that will be applied to your generation.

You can use these resources to create different world types, floors for a roguelike dungeon, or more. Just by changing the resource, and without creating a new scene, you can have a totally different generation from your last one.

### Modifiers
Modifiers take the generation and change it algorithmically, similar to how Blender's modifiers work. They're non-destructive, meaning you can remove them, change their order, etc. without worrying about breaking your generator.

### TileInfo
This resource is stored in a certain position in the generator's grid. The base class is empty, but the subclasses such as `TilemapTileInfo` contain data that the renderer takes and uses to draw the grid.
