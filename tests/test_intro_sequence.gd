extends SceneTree
## 자동 상호작용 테스트 — 챕터 1 프롤로그(intro_sequence.gd)의 자동 재생,
## Enter로 한 줄 스킵, Esc로 전체 스킵, 그리고 끝까지 재생 시
## chapter1_real로 정상 전환되는지 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_intro_sequence.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_intro.tscn")
	await process_frame
	await process_frame

	var label: Label = current_scene.get_node("Label")
	var first_line := label.text
	_assert(first_line != "", "첫 줄이 바로 표시됨")

	# Enter로 한 줄 스킵 -> 3초를 기다리지 않고 즉시 다음 줄로 넘어감.
	await _send_action("ui_accept")
	_assert(label.text != first_line,
		"Enter를 누르면 즉시 다음 줄로 넘어감, 실제: '%s'" % label.text)
	var second_line := label.text

	# 자동 재생: 아무 입력 없이 AUTO_ADVANCE_SECONDS(3초)만 지나도 다음 줄로.
	await create_timer(3.2).timeout
	_assert(label.text != second_line,
		"입력 없이도 3초 뒤 자동으로 다음 줄로 넘어감, 실제: '%s'" % label.text)

	# Esc로 전체 스킵 -> 남은 줄과 상관없이 바로 chapter1_real로 전환.
	await _send_action("ui_cancel")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"Esc로 건너뛰면 바로 챕터 1 현실로 전환됨, 실제: %s" %
			[current_scene.name if current_scene else "null"])

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


func _send_action(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	var release := InputEventAction.new()
	release.action = action
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
