# Anatomy of a Graph

Graphs in Gaea all have to lead to the Output Node in order for the generation to work. Let's take a look at what each element in the nodes mean:

## Slots

![A screenshot highlighting the input and output slots of nodes](../assets/tutorials/anatomy-of-a-graph/slots.png)

Gaea nodes have input and output slots. On the left side of the node, we have the input ones, and on the right, the output ones. Input slots for arguments (such as in the SimplexSmooth2D node, allow for overriding the values set in the node interface, but are optional).

This is how you'll connect nodes to each other. 

### Slot Types
Slot types are differentiated by their colors:

| Type | Color | Description | Example |
| --- | --- | --- | --- |
| Number | Light Gray | Can be a `float` or an `int`. | ![FloatVariable node](../assets/tutorials/anatomy-of-a-graph/float_example.png) |
| Material | Red | A `GaeaMaterial` resource. Learn more about it in [How Gaea Works](../how-gaea-works.md) | ![MaterialVariable node](../assets/tutorials/anatomy-of-a-graph/material_example.png) |
| Data | Gray | A grid of floats. | ![SimplexSmooth2D node](../assets/tutorials/anatomy-of-a-graph/data_example.png) |
| Map | Light Green | A grid of `GaeaMaterial`s. | ![MergeMaps node](../assets/tutorials/anatomy-of-a-graph/map_example.png) | 
| Range | Dark Gray | A range between one number and another | ![ComposeRange node](../assets/tutorials/anatomy-of-a-graph/range_example.png) |
| Boolean | Green | True or false | ![BoolVariable node](../assets/tutorials/anatomy-of-a-graph/bool_example.png) |

# Special Nodes

## Frame

![A frame holding 3 nodes, with the title "Create noise and map tiles to it"](../assets/tutorials/anatomy-of-a-graph/frame.png)

Frames can be used to organize your graphs. You can attach nodes to them, and they'll automatically resize to fit them. Select them, then right click to get a list of options, including changing its title to whatever you want.