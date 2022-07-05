class_name InfiniteCanvasGrid
extends Node2D

# -------------------------------------------------------------------------------------------------
const COLOR := Color.red

# -------------------------------------------------------------------------------------------------
export var camera_path: NodePath
var _enabled: bool
var _camera: Camera2D
var _grid_size := Config.DEFAULT_GRID_SIZE
var _grid_color: Color

var _major_grid_ver_scale := 20.0
var _major_grid_hor_scale := 20.0 * sqrt(2)
var _major_grid_width := 10.0

var _minor_grid_ver_scale := 1.0
var _minor_grid_hor_scale := 1.0 * sqrt(2)
var _minor_grid_width := 1.0

# -------------------------------------------------------------------------------------------------
func _ready():
	_camera = get_node(camera_path)
	_camera.connect("zoom_changed", self, "_on_zoom_changed")
	_camera.connect("position_changed", self, "_on_position_changed")
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

# -------------------------------------------------------------------------------------------------
func enable(e: bool) -> void:
	set_process(e)
	visible = e

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(zoom: float) -> void: update()
func _on_position_changed(pos: Vector2) -> void: update()
func _on_viewport_size_changed() -> void: update()

# -------------------------------------------------------------------------------------------------
func set_canvas_color(c: Color) -> void:
	_grid_color = c * 1.25

# -------------------------------------------------------------------------------------------------
func set_grid_scale(size: float):
	_grid_size = Config.DEFAULT_GRID_SIZE * size
	update()

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	var size = get_viewport().size  * _camera.zoom
	var zoom = _camera.zoom.x
	var offset = _camera.offset
	
	var grid_size = _grid_size
	if zoom > 50:
		grid_size *= 50
	elif zoom > 25:
		grid_size *= 25
	elif zoom > 10:
		grid_size *= 10
	elif zoom > 5:
		grid_size *= 5

	# Major Grid: Vertical lines
	var major_start_index := int((1.0 / _major_grid_ver_scale) * (offset.x - size.x) / grid_size) - 1
	var major_end_index := int((1.0 / _major_grid_ver_scale) * (size.x + offset.x) / grid_size) + 1
	for i in range(major_start_index, major_end_index):
		draw_line(Vector2(_major_grid_ver_scale * i * grid_size, offset.y + size.y), Vector2(_major_grid_ver_scale * i * grid_size, offset.y - size.y), _grid_color, _major_grid_width)
	
	# Major Grid: Horizontal lines
	major_start_index = int((1.0 / _major_grid_hor_scale) * (offset.y - size.y) / grid_size) - 1
	major_end_index = int((1.0 / _major_grid_hor_scale) * (size.y + offset.y) / grid_size) + 1
	for i in range(major_start_index, major_end_index):
		draw_line(Vector2(offset.x + size.x, _major_grid_hor_scale * i * grid_size), Vector2(offset.x - size.x, _major_grid_hor_scale * i * grid_size), _grid_color, _major_grid_width)

	# Minor Grid: Vertical lines
	var minor_start_index := int((1.0 / _minor_grid_ver_scale) * (offset.x - size.x) / grid_size) - 1
	var minor_end_index := int((1.0 / _minor_grid_ver_scale) * (size.x + offset.x) / grid_size) + 1
	for i in range(minor_start_index, minor_end_index):
		draw_line(Vector2(_minor_grid_ver_scale * i * grid_size, offset.y + size.y), Vector2(_minor_grid_ver_scale * i * grid_size, offset.y - size.y), _grid_color, _minor_grid_width)
	
	# Minor Grid: Horizontal lines
	minor_start_index = int((1.0 / _minor_grid_hor_scale) * (offset.y - size.y) / grid_size) - 1
	minor_end_index = int((1.0 / _minor_grid_hor_scale) * (size.y + offset.y) / grid_size) + 1
	for i in range(minor_start_index, minor_end_index):
		draw_line(Vector2(offset.x + size.x, _minor_grid_hor_scale * i * grid_size), Vector2(offset.x - size.x, _minor_grid_hor_scale * i * grid_size), _grid_color, _minor_grid_width)
