# Wave Function Generator

**Wave Function Collapse** is an algorithm made by [Maxim Gumin](https://github.com/mxgmn), which can procedurally generate anything using a **set of rules** about which tiles can be placed next to what.

<video src="../assets/wave_function_showcase.mp4" controls title="Title"></video>

## How does it work?

In Gaea, these rules are determined by **WaveFunctionEntry** resources. These resources have a TileInfo, and Arrays for all four sides which contain the ids of the tiles that can be placed next to that tile in that direction. For example, a barrel would only be placed when it has a terrain tile below it and air or other decorations around it.

The generator's settings resource has an Array of these entries. At start, it generates an empty grid of size `world_size`. It then chooses a random cell, narrows it down to one option, and starts collapsing its neighbors. This means that it removes all possibilities that arent in that tile's valid neighbors list, and it propagates that throughout the whole grid.

This gets repeated until there's only one option in every cell, finishing the generation.

> For more information about this algorithm, check out its [original repository](https://github.com/mxgmn/WaveFunctionCollapse).

