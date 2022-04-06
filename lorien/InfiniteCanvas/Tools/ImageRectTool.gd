class_name ImageRectTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
enum Mode {
	NONE,
	COPY_START,
	COPY_DONE,
	PASTE_START,
	PASTE_DONE
}
const COPY_ACTION = 268435523
const PASTE_ACTION = 268435542

# -------------------------------------------------------------------------------------------------
var _last_mouse_motion: InputEventMouseMotion
var _mode: int = Mode.NONE

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_motion = event
		_cursor.global_position = xform_vector2(event.global_position)
	if event is InputEventKey:
		print("Phys. Scancode + Modifier: %d" % event.get_physical_scancode_with_modifiers())
		#print("%s" % OS.get_name())
		if event.pressed and event.get_physical_scancode_with_modifiers() == PASTE_ACTION:
			_mode = Mode.PASTE_START

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _mode == Mode.PASTE_START:
		print("Paste action")
		if OS.get_name() == "X11":
			var output = []
			OS.execute("bash", ["-c", "xclip -out -target TARGETS -selection clipboard"], true, output)
			print(output)
			if "image/png" in output[0]:
				print("image/png found!")
				OS.execute("bash", ["-c", "xclip -selection clipboard -target image/png -out | xxd -ps -c 1"], true, output)
				var image_byte_array = _xxd_to_byte_array(output[0])
				#print(image_byte_array)
				var test_sprite = Sprite.new()
				var texture = ImageTexture.new()
				var image = Image.new()
				image.load_png_from_buffer(image_byte_array)
				texture.create_from_image(image)
				test_sprite.set_texture(texture)
				test_sprite.position = _cursor.global_position
				_add_undoredo_action_for_image_paste(test_sprite)
			else:
				print("no valid image in clipboard")
		else:
			print("Cannot paste on unsupported platform")
		_mode = Mode.PASTE_DONE

# -------------------------------------------------------------------------------------------------
func _xxd_to_byte_array(xxd_output: String) -> PoolByteArray:
	var arr = PoolByteArray([])
	var xxd_split = xxd_output.rsplit("\n")
	for byte in xxd_split:
		if byte != "":
			byte = ("0x" + byte).hex_to_int()
			arr.append(byte)
	return arr

# -------------------------------------------------------------------------------------------------
func add_image(image_sprite: Sprite) -> void:
	_canvas._strokes_parent.add_child(image_sprite)
	_canvas._current_project.strokes.append(image_sprite)

# -------------------------------------------------------------------------------------------------
func delete_image(image_sprite: Sprite) -> void:
	var index = _canvas._current_project.strokes.find(image_sprite)
	_canvas._current_project.strokes.remove(index)
	_canvas._strokes_parent.remove_child(image_sprite)

# ------------------------------------------------------------------------------------------------
func _add_undoredo_action_for_image_paste(image_sprite: Sprite) -> void:
	var project: Project = ProjectManager.get_active_project()
	project.undo_redo.create_action("Paste Image")
	project.undo_redo.add_do_method(self, "add_image", image_sprite)
	project.undo_redo.add_undo_method(self, "delete_image", image_sprite)
	project.undo_redo.commit_action()
	project.dirty = true
