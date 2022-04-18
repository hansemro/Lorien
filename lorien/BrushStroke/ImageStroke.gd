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

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_entered(viewport: Viewport) -> void: 
	add_to_group(GROUP_ONSCREEN)
	print("ImageStroke ONSCREEN")
	visible = true

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	remove_from_group(GROUP_ONSCREEN)
	print("ImageStroke OFFSCREEN")
	visible = false

# -------------------------------------------------------------------------------------------------
#func _to_string() -> String:
#	return "Size: %d, Points: %s" % [size, points]

# -------------------------------------------------------------------------------------------------
func enable_collider(enable: bool) -> void:
	pass
	# Remove current collider
	var collider = get_node_or_null(COLLIDER_NODE_NAME)
	if collider != null:
		remove_child(collider)
		collider.queue_free()
	
	# Create new collider
	if enable:
		var body := StaticBody2D.new()
		body.name = COLLIDER_NODE_NAME
		var idx := 0
		var col := CollisionObject2D.new()
		var shape := RectangleShape2D.new()
		shape.extents = get_rect().size
		print("rect shape extents: " + str(shape.extents))
		body.add_child(col)
		add_child(body)
