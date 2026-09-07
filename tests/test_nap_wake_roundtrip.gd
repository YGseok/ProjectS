extends SceneTree
## 자동 상호작용 테스트 — 툇마루에서 Enter로 낮잠(chapter1_real ->
## chapter1_dream), 다시 Enter로 각성(chapter1_dream -> chapter1_real)이
## 실제로 씬을 전환하는지 검증한다. 사람이 매번 직접 플레이해서 확인하지
## 않아도 되게 하기 위함 (qa/README.md "상호작용 자동 테스트" 참고).
##
## 실행: godot4 --headless --script res://tests/test_nap_wake_roundtrip.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"초기 씬이 Chapter1Real, 실제: %s" % [current_scene.name if current_scene else "null"])

	# 플레이어는 툇마루의 낮잠 트리거 위치(608,160)에서 시작하므로 바로 상호작용
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Dream", 3.0)

	_assert(current_scene != null and current_scene.name == "Chapter1Dream",
		"낮잠 후 씬이 Chapter1Dream, 실제: %s" % [current_scene.name if current_scene else "null"])

	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)

	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"각성 후 씬이 다시 Chapter1Real, 실제: %s" % [current_scene.name if current_scene else "null"])

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
