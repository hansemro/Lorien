extends Sprite
class_name ImageStroke

# ------------------------------------------------------------------------------------------------
const COLLIDER_NODE_NAME := "StrokeCollider"

# ------------------------------------------------------------------------------------------------
const GROUP_ONSCREEN 		:= "onscreen_stroke"

const MAX_VECTOR2 := Vector2(2147483647, 2147483647)
const MIN_VECTOR2 := -MAX_VECTOR2

# ------------------------------------------------------------------------------------------------
onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
var points: Array # Array<Vector2>
var top_left_pos: Vector2
var bottom_right_pos: Vector2

# ------------------------------------------------------------------------------------------------
func _ready():
	_visibility_notifier.rect = get_rect()
	top_left_pos = get_rect().position
	bottom_right_pos = get_rect().end
	points.append(position)
	points.append(top_left_pos)
	points.append(bottom_right_pos)
	print("ImageStroke: _ready for instance %s" % get_instance_id())
	print("  position: %s" % str(position))
	print("  top_left_pos: %s" % str(top_left_pos))
	print("  bottom_right_pos: %s" % str(bottom_right_pos))

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_entered(viewport: Viewport) -> void: 
	add_to_group(GROUP_ONSCREEN)
	print("ImageStroke %s ONSCREEN" % get_instance_id())
	visible = true

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	remove_from_group(GROUP_ONSCREEN)
	print("ImageStroke %s OFFSCREEN" % get_instance_id())
	visible = false

# -------------------------------------------------------------------------------------------------
func enable_collider(enable: bool) -> void:
	pass
