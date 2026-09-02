extends Node2D
## 파이프라인 테스트용 — elf_girl_test 8방향 에셋 중 4방향(상하좌우)만 골라
## player.gd와 같은 그리드 이동 로직에 연결, 방향키 입력에 따라 스프라이트
## 텍스처를 교체한다. 실제 주인공 스크립트가 아니라 통합 검증용.

const TILE_SIZE := 160.0
const TILE_MOVE_SECONDS := 0.18
const MOVE_SPEED := TILE_SIZE / TILE_MOVE_SECONDS
const DIR := "res://assets/sprites/characters/elf_girl_test/"

@export var play_area: Rect2 = Rect2(160.0, 160.0, 480.0, 320.0)

var _tex_down: Texture2D = preload("res://assets/sprites/characters/elf_girl_test/elf girl current animations1.png")
var _tex_right: Texture2D = preload("res://assets/sprites/characters/elf_girl_test/elf girl current animations2.png")
var _tex_up: Texture2D = preload("res://assets/sprites/characters/elf_girl_test/elf girl current animations3.png")
var _tex_left: Texture2D = preload("res://assets/sprites/characters/elf_girl_test/elf girl current animations6.png")

var _target_position: Vector2
var _moving := false

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_target_position = position
	_sprite.texture = _tex_down
	_sprite.offset = Vector2(0, -_sprite.texture.get_height() / 2.0 + TILE_SIZE / 2.0)

func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_target_position, MOVE_SPEED * delta)
		if position.is_equal_approx(_target_position):
			position = _target_position
			_moving = false
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir = Vector2.RIGHT
		_sprite.texture = _tex_right
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2.LEFT
		_sprite.texture = _tex_left
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2.DOWN
		_sprite.texture = _tex_down
	elif Input.is_action_pressed("ui_up"):
		dir = Vector2.UP
		_sprite.texture = _tex_up

	if dir == Vector2.ZERO:
		return

	var next_position := position + dir * TILE_SIZE
	if not play_area.has_point(next_position):
		return

	_target_position = next_position
	_moving = true
