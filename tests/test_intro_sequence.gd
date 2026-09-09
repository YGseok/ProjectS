extends SceneTree
## 자동 상호작용 테스트 — 챕터 1 프롤로그(intro_sequence.gd)가 입력 없이는
## 절대 진행되지 않고(2026-09-09 "자동 재생되지 않도록" 피드백으로 자동
## 진행 제거) Enter로만 한 줄씩 넘어가는지, Esc로 전체 스킵, 그리고 끝까지
## 다 넘겼을 때 chapter1_real로 정상 전환되는지 검증한다.
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

	# 타자기 효과(v0.03 추가) 회귀 확인: .text는 이미 전체 줄이지만
	# visible_ratio는 0에서 시작해 시간이 지나며 1.0까지 서서히 올라간다.
	# (첫 줄 "..."은 너무 짧아 순식간에 다 보이므로, 이 확인은 더 긴
	# 두 번째 줄로 넘어간 뒤에 한다.)
	_assert(label.visible_ratio < 1.0, "첫 줄 표시 직후 visible_ratio가 아직 1.0 미만(타자기 효과 시작)")

	# Enter로 한 줄 스킵 -> 3초를 기다리지 않고 즉시 다음 줄로 넘어감.
	await _send_action("ui_accept")
	_assert(label.text != first_line,
		"Enter를 누르면 즉시 다음 줄로 넘어감, 실제: '%s'" % label.text)
	_assert(label.visible_ratio < 1.0,
		"다음 줄로 넘어가면 visible_ratio도 다시 처음부터(타자기 효과 초기화), 실제: %f" % label.visible_ratio)
	var second_line := label.text

	await create_timer(0.15).timeout
	var ratio_mid: float = label.visible_ratio
	_assert(ratio_mid > 0.0 and ratio_mid < 1.0,
		"두 번째 줄에서 0.15초 후 글자 일부만 보임(0<ratio<1), 실제: %f" % ratio_mid)
	await create_timer(1.0).timeout
	_assert(is_equal_approx(label.visible_ratio, 1.0),
		"충분히 기다리면 전체 글자가 다 보임(ratio==1.0), 실제: %f" % label.visible_ratio)

	# 자동 재생 없음(2026-09-09 회귀 확인): 입력 없이 오래 기다려도
	# 절대 다음 줄로 안 넘어가야 한다 — 예전엔 3초면 자동으로 넘어갔었음.
	await create_timer(3.5).timeout
	_assert(label.text == second_line,
		"입력 없이 오래 기다려도 자동으로 넘어가지 않음(수동 진행), 실제: '%s'" % label.text)

	# Esc로 전체 스킵 -> 남은 줄과 상관없이 바로 chapter1_real로 전환.
	await _send_action("ui_cancel")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"Esc로 건너뛰면 바로 챕터 1 현실로 전환됨, 실제: %s" %
			[current_scene.name if current_scene else "null"])

	# Esc를 한 번도 안 쓰고, Enter만으로 모든 줄을 자연스럽게 다 넘겨도
	# (LINES 끝에 도달) 정상적으로 챕터 1로 전환되는지 확인 — 지금까지는
	# Esc로 건너뛰는 경로만 씬 전환을 검증했음.
	change_scene_to_file("res://scenes/chapter1_intro.tscn")
	await process_frame
	await process_frame
	var line_count: int = current_scene.LINES.size()
	for i in range(line_count):
		await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"Enter %d번으로 모든 줄을 자연스럽게 다 넘겨도 챕터 1로 전환됨, 실제: %s" %
			[line_count, current_scene.name if current_scene else "null"])

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
