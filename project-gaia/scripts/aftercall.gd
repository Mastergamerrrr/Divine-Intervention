extends CanvasLayer

const FRAME_SIZE := Vector2(576, 324)
const CREDITS := "res://assets/sprites/heaven/heaven.tscn"
const CAMERA_FOCUS := Vector2(269, 161)

@onready var frame: Control = $Frame
@onready var world: Node2D = $Frame/World
@onready var call_shots: Node2D = $Frame/Call
@onready var call_bear: Sprite2D = $Frame/Call/CallBear
@onready var receiver: Sprite2D = $Frame/Call/Receiver
@onready var phone_cord: Line2D = $Frame/Call/Cord
@onready var dialing_audio: AudioStreamPlayer = $Dialing
@onready var operator_audio: AudioStreamPlayer = $Operator
@onready var child_audio: AudioStreamPlayer = $ChildAudio
@onready var ghost: AnimatedSprite2D = $Frame/World/Ghost
@onready var rescue: Node2D = $Frame/World/Rescue
@onready var rescue_light: Sprite2D = $Frame/World/Rescue/Light
@onready var sky_ghost: AnimatedSprite2D = $Frame/World/SkyGhost
@onready var sky: TextureRect = $Frame/World/Sky
@onready var phone: Sprite2D = $Frame/World/Phone
@onready var bear: Sprite2D = $Frame/World/Bear
@onready var spotlight: ColorRect = $Frame/World/Spotlight
@onready var source_light: Sprite2D = $Frame/World/SourceLight
@onready var ascent_sound: AudioStreamPlayer = $AscentSound
@onready var caption: Control = $Caption
@onready var speaker: Label = $Caption/Padding/Copy/Speaker
@onready var line: Label = $Caption/Padding/Copy/Line
@onready var fade: ColorRect = $Fade
@onready var siren: AudioStreamPlayer = $Siren
@onready var music: AudioStreamPlayer = $Music

var showing_farewell := false

func _ready() -> void:
	_use_crisp_pixel_font(speaker)
	_use_crisp_pixel_font(line)
	get_viewport().size_changed.connect(_fit_frame)
	_fit_frame()
	_play_call()

func _use_crisp_pixel_font(label: Label) -> void:
	var font := label.get_theme_font("font").duplicate() as FontFile
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	label.add_theme_font_override("font", font)

func _fit_frame() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var fit := minf(viewport_size.x / FRAME_SIZE.x, viewport_size.y / FRAME_SIZE.y)
	frame.scale = Vector2.ONE * fit
	frame.position = (viewport_size - FRAME_SIZE * fit) * 0.5
	caption.offset_left = roundf(frame.position.x + 64.0 * fit)
	caption.offset_right = roundf(frame.position.x + 512.0 * fit)
	var caption_top := 132.0 if showing_farewell else 248.0
	caption.offset_top = roundf(frame.position.y + caption_top * fit)
	caption.offset_bottom = roundf(frame.position.y + (caption_top + 60.0) * fit)
	speaker.add_theme_font_size_override("font_size", maxi(8, floori(fit) * 8))
	line.add_theme_font_size_override("font_size", maxi(8, floori(fit * 1.5) * 8))

func _play_call() -> void:
	_show_caption("EMERGENCY CALL", "The bear dials for help.")
	var opening := create_tween()
	opening.tween_property(fade, "color:a", 0.0, 0.55)
	dialing_audio.play()
	_frame_call(1.28)
	var camera_move := create_tween()
	camera_move.tween_method(_frame_call, 1.28, 1.36, 4.5)
	var dialing_pose := create_tween()
	dialing_pose.tween_property(call_bear, "rotation", -0.10, 0.32).set_trans(Tween.TRANS_SINE)
	dialing_pose.tween_property(call_bear, "rotation", 0.0, 0.30).set_trans(Tween.TRANS_SINE)
	await dialing_audio.finished

	camera_move.kill()
	phone_cord.show()
	var pick_up := create_tween()
	pick_up.tween_property(receiver, "position", Vector2(356, 158), 0.42).set_trans(Tween.TRANS_QUAD)
	pick_up.parallel().tween_property(receiver, "rotation", -PI / 2.0, 0.42)
	pick_up.parallel().tween_property(receiver, "scale", Vector2(2.65, 2.65), 0.42)
	pick_up.parallel().tween_method(_frame_call, call_shots.scale.x, 1.05, 0.55).set_trans(Tween.TRANS_SINE)
	await pick_up.finished
	_show_caption("EMERGENCY CALL", "The operator answers.")
	operator_audio.play()
	await operator_audio.finished

	_show_caption("EMERGENCY CALL", "A child is crying.")
	child_audio.play()
	await get_tree().create_timer(2.7).timeout
	var cut := create_tween()
	cut.tween_property(fade, "color:a", 1.0, 0.55)
	cut.parallel().tween_property(child_audio, "volume_linear", 0.0, 0.55)
	await cut.finished
	child_audio.stop()
	caption.modulate.a = 0.0
	call_shots.hide()
	_play_ending()

func _frame_call(zoom: float) -> void:
	call_shots.scale = Vector2.ONE * zoom
	call_shots.position = Vector2(352, 161) * (1.0 - zoom)
	phone_cord.set_point_position(0, receiver.position + Vector2(-6, 16))

func _play_ending() -> void:
	var sequence := create_tween()
	sequence.tween_property(fade, "color:a", 0.0, 0.85)
	sequence.parallel().tween_method(_push_in, 0.0, 1.0, 21.9)
	sequence.parallel().tween_subtween(_story_beats())
	sequence.tween_property(fade, "color:a", 1.0, 1.45)
	sequence.parallel().tween_property(music, "volume_db", -42.0, 1.45)
	sequence.tween_callback(_show_farewell)
	sequence.tween_property(caption, "modulate:a", 1.0, 0.35)
	sequence.tween_interval(2.8)
	sequence.tween_property(caption, "modulate:a", 0.0, 0.35)
	sequence.tween_callback(_enter_credits)

func _story_beats() -> Tween:
	var beats := create_tween()
	beats.stop()
	beats.tween_interval(0.8)
	beats.tween_callback(siren.play)
	beats.tween_method(_rescue_light, 0.0, 1.0, 3.8)
	beats.parallel().tween_callback(_show_caption.bind(
		"AFTER THE CALL", "Help arrived. The child was safe."
	)).set_delay(0.7)
	beats.tween_callback(_show_caption.bind(
		"AFTER THE CALL", "After the divorce, their mother left.\nNo one had come back for the child."
	))
	beats.tween_interval(5.2)
	beats.parallel().tween_property(rescue, "modulate:a", 0.0, 1.4).set_delay(0.65).set_trans(Tween.TRANS_SINE)
	beats.parallel().tween_property(siren, "volume_linear", 0.0, 3.9).set_delay(1.3).set_trans(Tween.TRANS_SINE)
	beats.tween_callback(siren.stop)
	beats.tween_callback(music.play)
	beats.tween_callback(ascent_sound.play)
	beats.tween_property(spotlight, "modulate:a", 0.88, 2.1).set_trans(Tween.TRANS_SINE)
	beats.parallel().tween_property(source_light, "modulate:a", 0.90, 2.1)
	beats.parallel().tween_property(caption, "modulate:a", 0.0, 0.65)
	beats.tween_property(ghost, "modulate:a", 1.0, 1.25)
	beats.parallel().tween_property(ghost, "position:y", 104.0, 4.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	beats.tween_property(sky, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)
	beats.parallel().tween_property(spotlight, "offset_bottom", 475.0, 2.0).set_trans(Tween.TRANS_SINE)
	beats.parallel().tween_property(phone, "modulate:a", 0.0, 1.55)
	beats.parallel().tween_property(bear, "modulate:a", 0.0, 1.55)
	beats.parallel().tween_property(ghost, "modulate:a", 0.0, 0.45)
	beats.parallel().tween_property(sky_ghost, "modulate:a", 1.0, 0.85).set_delay(0.45)
	beats.parallel().tween_property(sky_ghost, "position:y", 7.0, 5.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	beats.parallel().tween_property(sky_ghost, "modulate:a", 0.0, 1.15).set_delay(2.85).from(1.0)
	return beats

func _show_farewell() -> void:
	showing_farewell = true
	caption.z_index = fade.z_index + 1
	caption.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	speaker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speaker.text = "THE GUIDE"
	line.text = "You did well, lost soul.\nHeaven is waiting."
	_fit_frame()

func _show_caption(who: String, words: String) -> void:
	speaker.text = who
	line.text = words
	caption.modulate.a = 1.0

func _push_in(progress: float) -> void:
	var zoom := lerpf(1.0, 1.08, smoothstep(0.0, 1.0, progress))
	world.scale = Vector2.ONE * zoom
	world.position = CAMERA_FOCUS * (1.0 - zoom)

func _rescue_light(progress: float) -> void:
	var tint := Color(0.40, 0.55, 1.0).lerp(Color(1.0, 0.29, 0.28), smoothstep(0.32, 0.67, progress))
	tint.a = sin(progress * PI) * 0.54
	rescue_light.modulate = tint

func _enter_credits() -> void:
	if get_tree().change_scene_to_file(CREDITS) != OK:
		fade.color.a = 0.0
		push_error("The ending finished, but the credits could not load.")

