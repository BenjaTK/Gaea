# Modifiers

**Modifiers** are similar to those in software like Blender. You add these to your GeneratorSettings, and they get applied after the generation is finished, giving you varied results and possibilities. You can think of them this way: each cell in the grid is checked, and if it meets a certain condition, it will get modified (deleted, replaced with another `TileInfo` or a `TileInfo` will be placed in the same spot on a different layer).

> **NOTE**: In Gaea, the modifiers' array order matters. Modifiers get applied in this order, so different sequences can give different results.

## Filtering

Modifiers can be filtered. This means it will only modify certain tiles. 

`filter_type`: can be NONE, BLACKLIST, WHITELIST, or ONLY_EMPTY_TILES.

`filter_ids`: in BLACKLIST, it will NOT attempt to modify tiles with an `id` that can be found in this list (`id`s are strings that make identifying `TileInfo`s easier, see [Gaea's Resources](resources.md)). WHITELIST will invert this logic. _For example, using a `NoisePainter` to only place gold ore in tiles with the `id` "stone"._

`filter_layers`: it will only check in these layers for the `id`s mentioned above or, if `filter_type` is ONLY_EMPTY_TILES, for an empty tile. Leaving this array empty, the filtering will check for all layers.

## List

There are a few modifiers in Gaea at the moment:

### <img src="assets/icons/generate_borders.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Generate Borders

Generate border tiles around already placed tiles.

### <img src="assets/icons/fill.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Fill 

Fills the full rectangle of tiles.

![fill showcase](assets/fill-showcase.png)
*Using Fill to generate autotiled walls around a WalkerGenerator's generation.*

### <img src="assets/icons/carver.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Carver <sup>2D/3D</sup>

Carves holes into the map using a noise texture.

### <img src="assets/icons/smooth.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Smooth

Smoothes the map using Cellular Automata.

### <img src="assets/icons/walls.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Walls

Adds tiles to those below already placed tiles that aren't the Generator's default tile.

![walls modifier showcase](assets/walls-modifier-showcase.png)

In this example, the walls are added after both the floor and ceiling *(using the Fill modifier)* are added, giving the dungeon a different perspective.<br>
An example without the Walls modifier looks like this:

![without walls modifier](assets/walls-modifier-showcase-before.png)

### <img src="assets/icons/noise_painter.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Noise Painter <sup>2D/3D</sup>

Replaces tiles in the map with another tile based on a noise texture and a threshold.

### <img src="assets/icons/heightmap_painter.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Heightmap Painter <sup>2D/3D</sup>

Replaces tiles in the map with another tile based on a noise heightmap.

### <img src="assets/icons/remove_disconnected.svg" width="24" height="24" style="float:left;margin:0px 8px 0px 0px"> Remove Disconnected

Uses flood fill to remove all tiles that aren't connected to `starting_tile`.