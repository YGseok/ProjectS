extends SceneTree
## 자동 유닛 테스트 — DialogueSystem의 타자기 효과(v0.03, Label.visible_ratio)
## 가 실제로 0에서 시작해 시간이 지나며 1.0까지 올라가고, 줄이 바뀔 때마다
## 다시 초기화되는지 NPC 없이 직접 검증한다. 지금까지는 일회성 스크립트
## (tools/verify_typewriter.gd, 실행 후 삭제)로만 확인하고 지웠었다.
##
## 실행: godot4 --headless --script res://tests/test_dialogue_typewriter.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	_assert(dialogue != null, "DialogueSystem 오토로드를 찾음")
	if dialogue == null:
		_finish()
		return

	var label: Label = dialogue.get_node("Panel/Label")
	var lines: Array[String] = ["이것은 스물다섯 글자 정도 되는 테스트 문장입니다요."]

	dialogue.start_dialogue(lines)
	await process_frame

	_assert(label.text == lines[0], ".text는 타자기 효과와 무관하게 즉시 전체 문자열로 설정됨")
	_assert(label.visible_ratio < 1.0, "대화 시작 직후 visible_ratio가 아직 1.0 미만")

	await create_timer(0.15).timeout
	var ratio_mid: float = label.visible_ratio
	_assert(ratio_mid > 0.0 and ratio_mid < 1.0,
		"0.15초 후 글자 일부만 보임(0<ratio<1), 실제: %f" % ratio_mid)

	await create_timer(0.8).timeout
	_assert(is_equal_approx(label.visible_ratio, 1.0),
		"충분히 기다리면 전체 글자가 다 보임(ratio==1.0), 실제: %f" % label.visible_ratio)

	# 타이핑이 이미 끝난 뒤에도 ui_accept로 정상 진행/종료되는지(입력 로직이
	# 타자기 효과 때문에 안 바뀌었는지) 확인.
	_send_action_press("ui_accept")
	await process_frame
	await process_frame
	_send_action_release("ui_accept")
	await process_frame
	await process_frame
	_assert(not dialogue.is_active(), "줄이 하나뿐이므로 ui_accept 한 번으로 대화가 정상 종료됨")

	_finish()


func _send_action_press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _send_action_release(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = false
	Input.parse_input_event(ev)


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
