extends Node2D
class_name ChapterEndScreen
## 챕터 2 이후 공용 종료 화면 — Enter를 누르면 `next_scene`으로 넘어간다
## (챕터 1의 `chapter1_end.gd`와 같은 역할을 범용화, DESIGN.md §11).
## 마지막 챕터는 `next_scene`을 임시 엔딩 화면으로 지정해서 일상으로
## 안 돌아가게 한다. 자유 이동이 없는 정적 화면이라 미니맵은 끈다.
##
## **버그 수정(2026-09-14, 통합 테스트로 발견)**: 이 씬은 대개 직전
## 화면(꿈)에서 챕터 타이틀 카드를 스킵하려고 누른 Enter 직후에
## 로드된다 — 그 입력이 이 씬이 뜬 바로 그 프레임에도 "새로 눌림"으로
## 보여서, 화면이 뜨자마자 곧바로 다음 씬으로 넘어가 버리는(사람이
## "Enter: 계속"을 실제로 본 적도 없이 스킵되는) 문제가 있었다 — 여러
## 인터랙션 오브젝트에서 이미 겪은 것과 같은 "닫는 입력이 같은 프레임에
## 다른 걸 재트리거" 버그 클래스. `_ready_frame`으로 이 씬이 뜬 바로 그
## 프레임의 입력은 무시한다.

@export var next_scene: String = "res://scenes/chapter1_real.tscn"

var _continued := false
var _ready_frame := -1

func _ready() -> void:
	Minimap.hide_map()
	_ready_frame = Engine.get_process_frames()

func _process(_delta: float) -> void:
	if _continued:
		return
	if Engine.get_process_frames() == _ready_frame:
		return
	if Input.is_action_just_pressed("ui_accept"):
		_continue()

func _continue() -> void:
	_continued = true
	var fade := get_tree().get_first_node_in_group("fade_overlay")
	if fade:
		fade.fade_to_scene(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)
