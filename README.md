# Gaea
Procedural generation add-on for Godot 4.

### Why Gaea?
Gaea is the greek personification of the Earth. What does this have to do with procedural generation? Uhhh... Earth... Terrain? It just sounded cool.

# 💡 Features

## 🚶‍♀️ WalkerGenerator

Generates a dungeon/cave using walkers that move in random directions and place tiles.
Inspired by [Nuclear Throne](https://store.steampowered.com/app/242680/Nuclear_Throne/)

![walker generator demo](docs/assets/walker-generator.gif)

## ⬜ CellularGenerator

Generates terrain using Cellular Automata by generating a noise grid then smoothing it out.

![cellular generator demo](docs/assets/cellular-generator.gif)

## 🌱 HeightmapGenerator

Generates terrain using a noise-based heightmap, similar to games like Terraria.

![terraria-like terrain using 2 generators and a carver modifier](docs/assets/terraria-like-generation.png)

## 🛠 Modifiers

Like in Blender, you can add modifiers to your generations to smooth out terrain, add walls, carve holes and more.

## More to come...

Island generators, dungeons with rooms, more modifiers. Soon™

# 📦 Installation

1. Download the project files
2. Place the `gaea` folder into your `/addons` folder withing the Godot project.
3. Enable the addon in the project settings.
