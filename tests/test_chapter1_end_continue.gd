extends SceneTree
## 자동 테스트 — 챕터 1 종료 화면(chapter1_end.gd)에서 Enter를 누르면
## "일상" 파트로 이어지는 현실(chapter1_real.tscn)로 넘어가는지 검증한다
## (사람 피드백, 2026-09-09 "챕터 종료한 뒤 일상이 시작된다"). 새 대사/
## 단서 콘텐츠는 아직 없고, 이번엔 순수 구조 연결(씬 전환)만 확인한다.
##
## 실행: godot4 --headless --script res://tests/test_chapter1_end_continue.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_end.tscn")
	await process_frame
	await process_frame

	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"챕터 1 종료 화면 로드 확인, 실제: %s" % [current_scene.name if current_scene else "null"])

	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"종료 화면에서 Enter를 누르면 현실(일상)로 넘어감, 실제: %s" %
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
