extends Node2D
## 챕터 1 종료 화면 — Enter를 누르면 "일상" 파트로 이어지는 현실
## (chapter1_real.tscn)로 넘어간다(사람 피드백, 2026-09-09 "챕터 종료한
## 뒤 일상이 시작된다"). 지금은 그 현실 씬을 그대로 재사용한다 — NPC
## 대화/장식물 조사 등 기존 상호작용은 이미 있지만, 이 시점 전용의 새
## 대사·단서 콘텐츠는 아직 없다(사람 확인 후 채울 것, INBOX.md "탈출한
## 후... 일상 플레이" 항목 참고 — 새 콘텐츠가 필요해서 이번엔 순수 구조
## 연결만 함).

const NEXT_SCENE := "res://scenes/chapter1_real.tscn"

var _continued := false

func _process(_delta: float) -> void:
	if _continued:
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
