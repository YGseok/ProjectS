extends Node2D
class_name PressurePlate
## 재사용 가능한 발판/풋 스위치 컴포넌트 — 상호작용 키 없이, 플레이어가
## 범위 안에 들어오면 자동으로 눌리고 벗어나면 원래대로 돌아온다. 사람
## 피드백(2026-09-08 "인터렉션 오브젝트나 풋 스위치 등, 무언가가 더
## 필요하다")에 대응한 범용 부품이다. **2026-09-14 사람 확인으로 배치
## 결정을 위임받음** — `pressure_plate_flavor.gd`(이 클래스 상속)가
## `chapter1_dream.tscn`의 원두막 마루에 실제로 배치돼 순수 분위기 대사
## 한 줄을 트리거한다(아래 완료 기록/DESIGN.md §5 참고). 이 기본
## 클래스 자체는 여전히 범용 부품 — 다른 효과(문이 열림 등)가 필요해지면
## 새 하위 클래스를 또 만들면 된다.
##
## one_shot=false(기본): 밟고 있는 동안만 눌린 상태 유지, 벗어나면
## released 시그널(딛고 서 있어야 하는 발판 — 놓으면 문이 닫히는 식).
## one_shot=true: 한 번 눌리면 그걸로 끝, 이후 다시 밟아도 반응 없음
## (영구 스위치).

signal pressed
signal released

@export var trigger_radius: float = 20.0
@export var one_shot: bool = false

@onready var _visual: ColorRect = get_node_or_null("Visual")

var _player: Node2D
var _is_pressed := false
var _consumed := false

func is_pressed() -> bool:
	return _is_pressed

func _process(_delta: float) -> void:
	if _consumed:
		return
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return

	var in_range := global_position.distance_to(_player.global_position) <= trigger_radius
	if in_range and not _is_pressed:
		_is_pressed = true
		if _visual:
			_visual.color = Color(0.3, 0.75, 0.35, 0.9)
		pressed.emit()
		if one_shot:
			_consumed = true
	elif not in_range and _is_pressed and not one_shot:
		_is_pressed = false
		if _visual:
			_visual.color = Color(0.5, 0.5, 0.5, 0.9)
		released.emit()
