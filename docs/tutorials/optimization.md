# How to optimize your generators

Procedural generation can be sloooow. But with some clever tricks, you can prevent this reality from bogging down your players. 

## Multithreading your Renderers and Chunk Loaders

**Multithreading** allows code to run parallel to the main thread of your game, meaning it won't interrupt your gameplay while doing heavy, complicated work. From the player's perspective, offloading work from the main thread can fix stuttering, lag, and freezes.

The issues multithreading aims to solve scale with the amount of work that needs to be done as well as how often. Large world or chunk sizes, large resolutions, frequent refresh rates, and the use of multiple generation passes or modifiers are examples of heavy, complicated work.

### Threaded Tilemap and Gridmap Renderers
Gaea offers 2 renderers with **threaded** variants, the `TileMapRenderer` and the `GridMapRenderer`; they are called `ThreadedTileMapRenderer` and `ThreadedGridMapRenderer`. These threaded variants are an answer to lag and stuttering that comes from drawing many tile changes to the screen all at once.

These threaded renderers will also render multiple chunks in parallel (at the same time) when used alongside a Chunk Loader. This means **threaded** renderers can render the same amount of chunks in a shorter amount of time compared to an **unthreaded** one.

![Nodes](<../assets/tutorials/optimization/nodes.png>)

As such, `ThreadedRenderer`s have an additional parameter, `task_limit`. It decides the maximum number of WorkerThreadPool tasks that can be created and run concurrently. A default, negative value (-1) means there is no limit. In most cases, you'll leave the `task_limit` parameter at this default value.
> As an example, a value of 8 suggests that a maximum of 8 chunks are allowed to be rendered at one time. Any chunks sent to the renderer beyond this limit will be queued, then rendered as soon as space becomes available.

### Threaded Chunk Loader
Gaea offers a **threaded** variant of the `ChunkLoader`, called `ThreadedChunkLoader`. This variant allows chunk data to be generated off of the main thread, a process that can cause very long freezes as entire chunks try to generate on a single frame, interupting gameplay.

#### Comparison
Most **threaded** variations include a way to toggle multi-threading on and off. This is included to debug errors that could be hidden as a result of running in a thread, as well as just for the sake of comparison.

![Unthreaded version vs threaded version in a 3D scene](<../assets/tutorials/optimization/unthreaded-vs-threaded.gif>)
> **Unthreaded** chunk loader + **threaded** renderer (left) vs. **threaded** chunk loader & renderer (right). 

You can see how much it stutters without threading (it even crashed later!), vs how smooth it runs with threading enabled.

## It's still running poorly...

Additional optimizations include changing chunk size, the `ChunkLoader`'s loading radius or update rate, etc.