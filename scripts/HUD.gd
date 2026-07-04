extends CanvasLayer
## Heads-up display: reflects live agent state to the user.

@onready var _agent_count: Label = $Panel/Margin/VBox/AgentCount
@onready var _status:      Label = $Panel/Margin/VBox/Status
@onready var _moving:      Label = $Panel/Margin/VBox/MovingCount


func set_agent_count(count: int) -> void:
	_agent_count.text = "Agents: %d" % count


func set_status(text: String) -> void:
	_status.text = "Status: %s" % text


func set_moving_count(moving: int, total: int) -> void:
	_moving.text = "Moving: %d / %d" % [moving, total]
