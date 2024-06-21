# How to optimize your generators

Procedural generation can be sloooow. But thanks to threading, you can improve your speeds by a LOT. 

## ThreadedRenderer(s) and ThreadedChunkLoader(s)

Gaea offers 2 renderers, the `TileMap` one and the `GridMap` one. Both of these have **threaded** variants. **Multithreading** allows code to run parallel of the main thread of your game, meaning it won't interrupt it and will reduce stutters significantly. This _could_ cause some visual lag as the chunks get generated or the tiles get rendered one after the other, but it will make the gameplay experience better, **especially** in 3D.

By replacing your `ChunkLoader` with a `ThreadedChunkLoader`, you'll see improvements in the performance. You can always disable threading with a toggle if it's causing problems.

![Nodes](<../assets/tutorials/optimization/nodes.png>)

![Unthreaded version vs threaded version in a 3D scene](<../assets/tutorials/optimization/unthreaded-vs-threaded.gif>)
> **Unthreaded** chunk loader + **threaded** renderer (left) vs. **threaded** chunk loader & renderer (right). 

You can see how much it stutters without threading (it even crashed later!), vs how smooth it runs with it enabled. 

> `ThreadedRenderer`s also have an additional parameter, `task_limit`. It decides the maximum number of WorkerThreadPool tasks that can be created before queueing new tasks. A negative value (-1) means there is no limit.

This all also works in 2D, although it's not always necessary, as 2D requires much less computing power. Eitherway, it's recommended for large worlds, large resolutions and more.

## It's still running poorly...

Additional optimizations include changing chunk size, the `ChunkLoader`'s loading radius or update rate, etc.