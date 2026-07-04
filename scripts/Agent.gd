extends CharacterBody2D
## A single pathfinding agent.
## NavigationAgent2D computes an avoidance-aware velocity each physics frame;
## CharacterBody2D executes it via move_and_slide().

const SPEED := 160.0

var agent_id: int      = 0
var agent_color: Color = Color.GREEN

var _is_moving: bool = false

@onready var _nav:       NavigationAgent2D = $NavigationAgent2D
@onready var _sprite:    Polygon2D         = $Sprite
@onready var _path_line: Line2D            = $PathLine


func _ready() -> void:
	_sprite.color            = agent_color
	_path_line.default_color = Color(agent_color.r, agent_color.g, agent_color.b, 0.45)

	# Wire up NavigationAgent2D callbacks.
	_nav.navigation_finished.connect(_on_nav_finished)
	_nav.velocity_computed.connect(_on_velocity_computed)


func _physics_process(_delta: float) -> void:
	if not _is_moving:
		_path_line.points = PackedVector2Array()
		return

	if _nav.is_navigation_finished():
		_is_moving = false
		velocity   = Vector2.ZERO
		_path_line.points = PackedVector2Array()
		return

	var next: Vector2 = _nav.get_next_path_position()
	var dir: Vector2  = global_position.direction_to(next)

	# Rotate sprite to face the direction of travel.
	# The polygon arrow points upward (+PI/2 compensates for the -Y default).
	if dir.length_squared() > 0.01:
		_sprite.rotation = dir.angle() + PI * 0.5

	# Hand desired velocity to NavigationAgent2D; avoidance layer adjusts it.
	_nav.set_velocity(dir * SPEED)

	# Update path visualisation (converted to local-space for Line2D).
	_refresh_path_line()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_nav_finished() -> void:
	_is_moving         = false
	velocity           = Vector2.ZERO
	_path_line.points  = PackedVector2Array()


## Called by Main when the user clicks a new destination.
func set_target(target: Vector2) -> void:
	_nav.target_position = target
	_is_moving           = true


func is_moving() -> bool:
	return _is_moving


func _refresh_path_line() -> void:
	var path := _nav.get_current_navigation_path()
	if path.is_empty():
		_path_line.points = PackedVector2Array()
		return
	var local_pts := PackedVector2Array()
	for pt in path:
		local_pts.append(to_local(pt))
	_path_line.points = local_pts
