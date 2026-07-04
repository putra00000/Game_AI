# Pathfinding Agent Demo
A real-time 2D multi-agent navigation demo built in Godot 4.

## Demo
[Watch the demo video] https://youtu.be/nIq9jNMhX2s

## Overview
Five autonomous agents navigate a 2D environment in real time, dynamically routing around obstacles to reach a destination set by the user. Click anywhere on the map to redirect all agents simultaneously.

## Features
- **Multi-agent navigation** using Godot 4's NavigationAgent2D
- **RVO (Reciprocal Velocity Obstacle) avoidance** — agents avoid each other without overlapping
- **Dynamic navigation mesh** built at runtime using NavigationMeshSourceGeometryData2D
- **Live path visualization** — each agent draws its current route in real time
- **HUD** displaying agent count, movement status, and instructions
- **Click-to-navigate** — left-click anywhere to set a new destination for all agents
 
## Tech Stack
- **Engine:** Godot 4.6
- **Language:** GDScript
- **Key systems:** NavigationRegion2D, NavigationAgent2D, CharacterBody2D, NavigationServer2D

## How to Run
1. Clone the repo
2. Open Godot 4 and import `project.godot`
3. Press F5 to run
4. Left-click anywhere on the map to set agent destinations 

## Project Structure
```
├── scenes/
│   ├── Main.tscn        # Root scene with nav region, obstacles, HUD
│   └── Agent.tscn       # Reusable agent prefab
├── scripts/
│   ├── Main.gd          # Nav mesh builder, agent spawner, input handler
│   ├── Agent.gd         # Per-agent movement and path visualization
│   └── HUD.gd           # Live status display
└── project.godot
```
