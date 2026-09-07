extends SceneTree
## 자동 유닛 테스트 — DialogueSystem 자체의 공개 API를 NPC/플레이어 없이
## 직접 검증한다. 지금까지의 대화 테스트(test_dialogue_interaction.gd,
## test_npc_facing_check.gd)는 전부 "줄이 1개뿐인" NPC로만 시험해서,
## 여러 줄을 순서대로 진행하는 로직과 몇 가지 가드는 한 번도 실행된 적이
## 없었다. 이 테스트가 그 공백을 메운다.
##
## 실행: godot4 --headless --script res://tests/test_dialogue_system_unit.gd --path <project>

var _dialogue: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_dialogue = root.get_node_or_null("DialogueSystem")
	_assert(_dialogue != null, "DialogueSystem 오토로드를 찾음")
	if _dialogue == null:
		_finish()
		return

	# 1) 빈 배열로 시작하면 활성화되지 않아야 함
	var empty_lines: Array[String] = []
	_dialogue.start_dialogue(empty_lines)
	_assert(not _dialogue.is_active(), "빈 배열로는 대화가 시작되지 않음")

	# 2) 여러 줄 대화가 순서대로 진행되는지
	var lines: Array[String] = ["첫 줄", "둘째 줄", "셋째 줄"]
	_dialogue.start_dialogue(lines)
	_assert(_dialogue.is_active(), "여러 줄 대화 시작 시 활성화됨")
	_assert(_get_label_text() == "첫 줄", "첫 줄이 표시됨, 실제: '%s'" % _get_label_text())

	# 시작 프레임에는 같은 프레임 가드 때문에 advance가 무시되므로 한 프레임 넘긴다
	await process_frame
	await process_frame

	await _send_accept()
	_assert(_get_label_text() == "둘째 줄", "둘째 줄로 진행됨, 실제: '%s'" % _get_label_text())
	_assert(_dialogue.is_active(), "아직 대화 중")

	await _send_accept()
	_assert(_get_label_text() == "셋째 줄", "셋째 줄로 진행됨, 실제: '%s'" % _get_label_text())
	_assert(_dialogue.is_active(), "아직 대화 중")

	# 3) 마지막 줄에서 한 번 더 진행하면 종료
	await _send_accept()
	_assert(not _dialogue.is_active(), "마지막 줄 이후 대화 종료됨")

	# 4) 대화 중에 start_dialogue()를 다시 호출해도 무시되어야 함(진행 중 교체 방지)
	var lines_a: Array[String] = ["A1", "A2"]
	var lines_b: Array[String] = ["B1"]
	_dialogue.start_dialogue(lines_a)
	await process_frame
	await process_frame
	_dialogue.start_dialogue(lines_b)
	_assert(_get_label_text() == "A1", "대화 중 재호출은 무시되고 기존 대화 유지, 실제: '%s'" % _get_label_text())

	# 정리: 남은 대화 닫기
	await _send_accept()
	await _send_accept()

	_finish()


func _get_label_text() -> String:
	var label: Label = _dialogue.get_node("Panel/Label")
	return label.text


func _send_accept() -> void:
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	var release := InputEventAction.new()
	release.action = "ui_accept"
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	await process_frame


func _assert(condition: bool, description: String) -> void:
	if condition:
		print("[TEST] PASS - %s" % description)
	else:
		printerr("[TEST] FAIL - %s" % description)
		_all_passed = false


func _finish() -> void:
	if _all_passed:
		print("[TEST] ALL PASSED")
		quit(0)
	else:
		printerr("[TEST] SOME FAILED")
		quit(1)
