extends Node2D
## Main controller for the Pathfinding Agent Demo.
## Builds the navigation mesh at runtime, spawns agents, and routes click events.

const AGENT_SCENE := preload("res://scenes/Agent.tscn")

const AGENT_COUNT := 5
const MAP_W := 1280.0
const MAP_H := 720.0

# Each entry: [center: Vector2, half_size: Vector2]
# Obstacles are rendered and also punched out of the navigation polygon.
const OBSTACLE_DATA := [
	[Vector2(320, 200), Vector2(70, 45)],
	[Vector2(720, 160), Vector2(55, 80)],
	[Vector2(520, 410), Vector2(85, 45)],
	[Vector2(210, 520), Vector2(45, 65)],
	[Vector2(920, 460), Vector2(70, 50)],
	[Vector2(660, 560), Vector2(55, 35)],
	[Vector2(430, 300), Vector2(40, 40)],
	[Vector2(850, 260), Vector2(60, 35)],
]

# Spread starting positions in the top-left open area.
const AGENT_STARTS := [
	Vector2(90, 90),
	Vector2(140, 90),
	Vector2(90, 140),
	Vector2(140, 140),
	Vector2(115, 115),
]

# Distinct hues for each agent so they are easy to tell apart.
const AGENT_HUES := [0.33, 0.58, 0.08, 0.75, 0.95]

var _agents: Array[Node] = []

@onready var _nav_region: NavigationRegion2D = $NavigationRegion2D
@onready var _obstacles_root: Node2D   = $Obstacles
@onready var _agents_root: Node2D      = $Agents
@onready var _click_dot: Polygon2D     = $ClickIndicator
@onready var _hud: CanvasLayer         = $HUD


func _ready() -> void:
	_build_obstacles()
	_build_navigation_polygon()
	_spawn_agents()
	_hud.set_agent_count(AGENT_COUNT)
	_hud.set_status("Click anywhere to set destination")
	_click_dot.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var target := get_global_mouse_position()
		_dispatch_target(target)


func _process(_delta: float) -> void:
	# Update moving-count readout each frame.
	var moving := 0
	for agent in _agents:
		if agent.is_moving():
			moving += 1
	_hud.set_moving_count(moving, _agents.size())


# ---------------------------------------------------------------------------
# Map construction
# ---------------------------------------------------------------------------

func _build_obstacles() -> void:
	for data in OBSTACLE_DATA:
		var center: Vector2 = data[0]
		var half: Vector2   = data[1]
		_create_obstacle(center, half * 2.0)


func _create_obstacle(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	_obstacles_root.add_child(body)

	# Visual fill
	var rect := ColorRect.new()
	rect.size = size
	rect.position = -size * 0.5
	rect.color = Color(0.55, 0.28, 0.08)
	body.add_child(rect)

	# Thin border for visual clarity
	var border := ColorRect.new()
	border.size = size + Vector2(2, 2)
	border.position = -size * 0.5 - Vector2(1, 1)
	border.color = Color(0.8, 0.5, 0.15, 0.6)
	border.z_index = -1
	body.add_child(border)

	# Physics collision
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)


func _build_navigation_polygon() -> void:
	var nav_poly := NavigationPolygon.new()
	var source_geometry := NavigationMeshSourceGeometryData2D.new()
	var margin := 22.0

	# Let the server parse any region-attached geometry first.
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_geometry, _nav_region)

	# Outer walkable boundary — added first, clockwise in screen space.
	source_geometry.add_traversable_outline(PackedVector2Array([
		Vector2(margin, margin),
		Vector2(MAP_W - margin, margin),
		Vector2(MAP_W - margin, MAP_H - margin),
		Vector2(margin, MAP_H - margin),
	]))

	# Punch a hole for each obstacle (plus agent-clearance padding).
	# Counter-clockwise in screen space (opposite winding from the outer boundary).
	var clearance := 20.0
	for data in OBSTACLE_DATA:
		var center: Vector2 = data[0]
		var h: Vector2      = data[1] + Vector2(clearance, clearance)
		source_geometry.add_obstruction_outline(PackedVector2Array([
			center + Vector2(-h.x, -h.y),
			center + Vector2(-h.x,  h.y),
			center + Vector2( h.x,  h.y),
			center + Vector2( h.x, -h.y),
		]))

	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geometry)
	_nav_region.navigation_polygon = nav_poly


# ---------------------------------------------------------------------------
# Agent management
# ---------------------------------------------------------------------------

func _spawn_agents() -> void:
	for i in AGENT_COUNT:
		var agent: Node = AGENT_SCENE.instantiate()
		_agents_root.add_child(agent)
		agent.position        = AGENT_STARTS[i]
		agent.agent_id        = i
		agent.agent_color     = Color.from_hsv(AGENT_HUES[i], 0.75, 0.95)
		_agents.append(agent)


func _dispatch_target(target: Vector2) -> void:
	# Show a brief click marker at the destination.
	_click_dot.position = target
	_click_dot.visible  = true

	for agent in _agents:
		agent.set_target(target)

	_hud.set_status("Navigating...")

	# Hide the indicator after a short delay.
	await get_tree().create_timer(0.8).timeout
	_click_dot.visible = false
