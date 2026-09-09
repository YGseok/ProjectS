extends SceneTree
## 자동 테스트 — 개발자용 챕터 이동 치트(scripts/debug_warp.gd, 2026-09-09
## 사람 피드백 "개발자용 챕터 이동 치트를 만든다")가 F9로 열리고, 숫자
## 키로 고른 체크포인트로 실제로 이동하면서 Chapter1Progress를 그 지점에
## 맞는 값으로 정확히 덮어쓰는지 검증한다. 대화창이 열려 있는 등 다른
## 상황에서도 항상 반응해야 한다("모든 상황에서 접근 가능")는 요구사항도
## 함께 확인한다.
##
## 실행: godot4 --headless --script res://tests/test_debug_warp.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	var warp: Node = root.get_node_or_null("DebugWarp")
	var progress: Node = root.get_node_or_null("Chapter1Progress")
	_assert(warp != null, "DebugWarp 오토로드를 찾음")
	_assert(progress != null, "Chapter1Progress 오토로드를 찾음")
	if warp == null or progress == null:
		_finish()
		return

	_assert(not warp.is_menu_open(), "시작 시 치트 메뉴는 닫혀 있음")

	# 일부러 대화창을 열어둔 채로도 F9가 반응하는지 확인 — "모든 상황에서
	# 접근 가능"해야 하므로, 다른 인터랙션들과 달리 DialogueSystem.is_active()
	# 체크를 하지 않는 게 의도된 설계다.
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var test_line: Array[String] = ["테스트 대사"]
	dialogue.start_dialogue(test_line)
	await process_frame
	_assert(dialogue.is_active(), "테스트용으로 대화를 열어둠")

	await _press_key(KEY_F9)
	_assert(warp.is_menu_open(), "대화창이 열려 있어도 F9로 치트 메뉴가 열림")

	# 진행 상태를 일부러 어질러 놓은 뒤, "1장 진행 중(꿈)" 체크포인트
	# (인덱스 1 -> 키 '2')로 이동하면 아이템 없음으로 정확히 초기화되는지
	# 확인한다.
	progress.has_key = true
	progress.has_stamp = true
	progress.diary_opened = true

	await _press_key(KEY_2)
	await process_frame
	await process_frame
	_assert(not warp.is_menu_open(), "체크포인트 선택 후 메뉴가 자동으로 닫힘")
	await _wait_scene_change("Chapter1Dream", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Dream",
		"'1장 진행 중' 선택 시 chapter1_dream으로 이동함, 실제: %s" %
			[current_scene.name if current_scene else "null"])
	_assert(not progress.has_key and not progress.has_stamp and not progress.diary_opened,
		"'1장 진행 중' 이동 시 진행 상태가 시작 지점 값으로 초기화됨(key=%s, stamp=%s, diary=%s)" %
			[progress.has_key, progress.has_stamp, progress.diary_opened])

	# "1장 종료" 체크포인트(인덱스 2 -> 키 '3')로 이동하면 완료 상태로 감.
	await _press_key(KEY_F9)
	_assert(warp.is_menu_open(), "다시 F9로 메뉴를 염")
	await _press_key(KEY_3)
	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"'1장 종료' 선택 시 chapter1_end로 이동함, 실제: %s" %
			[current_scene.name if current_scene else "null"])
	_assert(progress.has_key and progress.has_stamp and progress.diary_opened,
		"'1장 종료' 이동 시 진행 상태가 완료 값으로 설정됨(key=%s, stamp=%s, diary=%s)" %
			[progress.has_key, progress.has_stamp, progress.diary_opened])

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


func _press_key(keycode: Key) -> void:
	var press := InputEventKey.new()
	press.keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	var release := InputEventKey.new()
	release.keycode = keycode
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
