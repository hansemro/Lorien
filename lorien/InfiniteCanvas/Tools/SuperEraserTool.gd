class_name SuperEraserTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _last_mouse_motion: InputEventMouseMotion
var _removed_strokes := [] # BrushStroke -> Vector2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_motion = event
		_cursor.global_position = xform_vector2(event.global_position)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed && _last_mouse_motion != null:
				_last_mouse_motion.global_position = event.global_position
				_last_mouse_motion.position = event.position
				performing_stroke = true
			elif !event.pressed:
				performing_stroke = false

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke && _last_mouse_motion != null:
		_remove_stroke(_last_mouse_motion.global_position)
		_add_undoredo_action_for_erased_strokes()
		_last_mouse_motion = null

# ------------------------------------------------------------------------------------------------
func _stroke_intersects_circle(stroke, circle_position: Vector2, circle_radius: float) -> bool:
	for i in stroke.points.size() - 1:
		var start = _calc_abs_stroke_point(stroke.points[i], stroke)
		var end = _calc_abs_stroke_point(stroke.points[i + 1], stroke)
		if Geometry.segment_intersects_circle(start, end, circle_position, circle_radius) >= 0:
			return true
	return false

# -------------------------------------------------------------------------------------------------
func _remove_stroke(brush_position: Vector2) -> void:
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		# check if brush intersects stroke (and not already being removed)
		if "BrushStroke" in stroke.name:
			if !_removed_strokes.has(stroke) && _stroke_intersects_circle(stroke, brush_position,
					float(_cursor._brush_size)/2):
				# Add stroke to remove to _removed_strokes
				_removed_strokes.append(stroke)
		elif "ImageStroke" in stroke.name:
			var top_left := _calc_abs_stroke_point(stroke.top_left_pos, stroke)
			var bottom_right := _calc_abs_stroke_point(stroke.bottom_right_pos, stroke)
			var bounding_box := Utils.calculate_rect(top_left, bottom_right)
			if !_removed_strokes.has(stroke) && bounding_box.has_point(brush_position):
				_removed_strokes.append(stroke)

# ------------------------------------------------------------------------------------------------
func _calc_abs_stroke_point(p: Vector2, stroke) -> Vector2:
	return (p + stroke.position - _canvas.get_camera_offset()) / _canvas.get_camera_zoom()

# ------------------------------------------------------------------------------------------------
func _add_undoredo_action_for_erased_strokes() -> void:
	var project: Project = ProjectManager.get_active_project()
	if _removed_strokes.size():
		project.undo_redo.create_action("Erase Stroke")
		for stroke in _removed_strokes:
			_removed_strokes.erase(stroke)
			print("Attempting to remove stroke %s" % stroke.get_instance_id())
			project.undo_redo.add_do_method(_canvas, "_do_delete_stroke", stroke)
			project.undo_redo.add_undo_method(_canvas, "_undo_delete_stroke", stroke)
		project.undo_redo.commit_action()
		project.dirty = true
