extends Node2D
## 챕터 1 종료 화면 — Enter를 누르면 "일상" 파트로 이어지는 현실
## (chapter1_real.tscn)로 넘어간다(사람 피드백, 2026-09-09 "챕터 종료한
## 뒤 일상이 시작된다"). 지금은 그 현실 씬을 그대로 재사용한다 — NPC
## 대화/장식물 조사 등 기존 상호작용은 이미 있지만, 이 시점 전용의 새
## 대사·단서 콘텐츠는 아직 없다(사람 확인 후 채울 것, INBOX.md "탈출한
## 후... 일상 플레이" 항목 참고 — 새 콘텐츠가 필요해서 이번엔 순수 구조
## 연결만 함).

## 자유 이동이 없는 정적 화면이라 미니맵을 끈다(사람 피드백, 2026-09-14
## "챕터 전환이나 나레이션 같이, 플레이 불가능한 시점에서는 표시되지
## 않는다") — 오토로드라 이전 씬에서 켜져 있었을 수 있어서 명시적으로
## 꺼야 한다.
##
## **버그 수정(2026-09-14, 챕터 2/3 통합 테스트로 발견)**: 이 씬은
## 직전 "1장 종료" 타이틀 카드를 스킵하려고 누른 Enter 직후에 로드되는데,
## 그 입력이 이 씬이 뜬 바로 그 프레임에도 "새로 눌림"으로 보여서 화면이
## 뜨자마자 곧바로 다음 씬으로 스킵돼버리는 문제가 있었다(같은 버그를
## `chapter_end.gd`에서도 발견해 같이 고침) — `_ready_frame`으로 이 씬이
## 뜬 바로 그 프레임의 입력은 무시한다.

const NEXT_SCENE := "res://scenes/chapter1_real.tscn"

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
		fade.fade_to_scene(NEXT_SCENE)
	else:
		get_tree().change_scene_to_file(NEXT_SCENE)
