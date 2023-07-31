# Gaea's structure

Gaea takes advantage of Godot's **Resources**. In this addon, they're used for the generators' settings, telling the generators which tiles from the TileMap to use, and for the modifiers.

## GeneratorSettings

Each generator has a unique **GeneratorSettings** resource, which includes variables like world size, rules, and the modifiers that will be applied to your generation.

You can use these resources to create different world types, floors for a roguelike dungeon, or more. Just by changing the resource, and without creating a new scene, you can have a totally different generation from your last one.

## TileInfo

This resource contains your tile's position in the TileSet. It is used both by the generators and by certain modifiers (like the GenerateBorders one) to determine which tiles to place.

If your tile's a **single cell**, you can set it's source id, atlas coordinates, and (optional) alternative tile. If it's a **terrain**, you can determine the terrain and the set where it comes from.
