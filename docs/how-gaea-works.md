# How Gaea Works

Gaea uses only 2 nodes (and some more for optional functionality): the **generator** and the **renderer**. Let's start with the **generator**, the most important part:

## The Generator

Adding the `GaeaGenerator` to your scene tree and selecting it will open a panel in the bottom of your editor. Clicking **Add New Resource** will create a `GaeaData` resource. You're now ready to get started! Add nodes to the graph by right clicking. 

The graph will already have a node: the output node. For now, this accepts one input: map data for layer 0. The **map data** type consists of a grid where each cell has its own `GaeaMaterial`, telling the `GaeaRenderer` nodes what to draw (we'll get to that in a minute).

The other data type you should know about is the **data grid**, a grid of numbers used in various different ways across the addon. From noise textures, to paths, and anything else. You can convert these to maps through various nodes, especially the **mapper** nodes. Check them out for a description!

Learn more about the graph in [Anatomy of a Graph](tutorials/anatomy-of-a-graph.md).

## The Renderer

The `GaeaRenderer` takes what the generator creates, and draws it in the game. Gaea has 2 available already: the `TileMapRenderer` and the `GridMapRenderer`. They use `TileMapMaterial`s and `GridMapMaterial`s respectively, which tell them which tiles in the tileset or which elements in the gridmap to draw on screen.

## Tutorials

Check out the tutorials for specifics on certain nodes and/or functionality!