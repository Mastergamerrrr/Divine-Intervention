extends CanvasLayer

const STAGE_SIZE := Vector2(576, 324)
const PORTAL_CLOSED_SCALE := Vector2(0.04, 0.08)
const RUN_END_X := 242.0
const HOUSE_SCENE := "res://scenes/game.tscn"

@onready var stage: Node2D = $Stage
@onready var portal: Node2D = $Stage/Portal
@onready var ghost: AnimatedSprite2D = $Stage/Ghost
@onready var bear: Sprite2D = $Stage/Bear
@onready var glow: Sprite2D = $Stage/Glow
@onready var burst: AnimatedSprite2D = $Stage/Burst
@onready var fade: ColorRect = $Fade
@onready var portal_sound: AudioStreamPlayer = $PortalSound
@onready var impact_sound: AudioStreamPlayer = $ImpactSound
@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	get_viewport().size_changed.connect(_fit_stage)
	_fit_stage()
	_play_cutscene()

func _fit_stage() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var fit := minf(viewport_size.x / STAGE_SIZE.x, viewport_size.y / STAGE_SIZE.y)
	stage.scale = Vector2.ONE * fit
	stage.position = (viewport_size - STAGE_SIZE * fit) * 0.5

func _play_cutscene() -> void:
	var rest_y := bear.position.y
	var hop_y := rest_y - 9.0
	var sequence := create_tween()
	sequence.tween_property(fade, "color:a", 0.0, 0.55)
	sequence.tween_callback(_open_portal)
	sequence.tween_property(portal, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	sequence.tween_interval(0.12)
	sequence.tween_callback(_start_run)
	sequence.tween_property(ghost, "position:x", RUN_END_X, 0.82).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	sequence.parallel().tween_property(ghost, "modulate:a", 1.0, 0.12)
	sequence.parallel().tween_property(portal, "scale", PORTAL_CLOSED_SCALE, 0.28).set_delay(0.39).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	sequence.parallel().tween_callback(portal.hide).set_delay(0.67)
	sequence.tween_callback(ghost.play.bind(&"leap"))
	sequence.tween_method(_leap_into_bear, 0.0, 1.0, 0.76).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	sequence.tween_callback(_possess_bear)
	sequence.tween_property(bear, "position:y", hop_y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sequence.parallel().tween_property(glow, "modulate:a", 0.0, 0.60)
	sequence.parallel().tween_property(bear, "modulate", Color.WHITE, 0.50)
	sequence.parallel().tween_property(bear, "position:y", rest_y, 0.26).from(hop_y).set_delay(0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	sequence.tween_interval(0.65)
	sequence.tween_property(fade, "color:a", 1.0, 0.75)
	sequence.parallel().tween_property(music, "volume_db", -45.0, 0.75)
	sequence.tween_callback(_enter_house)

func _open_portal() -> void:
	portal.show()
	portal_sound.play()

func _start_run() -> void:
	ghost.show()
	ghost.play(&"run")

func _leap_into_bear(progress: float) -> void:
	var takeoff := Vector2(RUN_END_X, bear.position.y)
	var destination := bear.position + Vector2(0, -20)
	ghost.position = takeoff.lerp(destination, progress)
	ghost.position.y -= sin(progress * PI) * 33.0
	ghost.scale = Vector2.ONE * lerpf(3.0, 0.9, smoothstep(0.66, 1.0, progress))
	ghost.modulate.a = 1.0 - smoothstep(0.80, 1.0, progress)

func _possess_bear() -> void:
	ghost.hide()
	ghost.stop()
	glow.modulate.a = 0.75
	burst.show()
	burst.play()
	impact_sound.play()
	bear.modulate = Color(1.45, 1.3, 1.1)

func _enter_house() -> void:
	if get_tree().change_scene_to_file(HOUSE_SCENE) != OK:
		fade.color.a = 0.0
		push_error("Possession finished, but the house scene could not load.")
