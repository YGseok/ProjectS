extends SceneTree
## 통합 테스트 — 프롤로그(chapter1_intro)에서 시작해서 챕터 1 현실 →
## 낮잠/각성 순환으로 퍼즐 4단계를 전부 풀고 → 챕터 종료 화면까지
## 한 번에 이어지는지 검증한다. 지금까지의 테스트는 각 씬/시스템을
## 따로따로 검증했지, 프롤로그부터 끝까지 이어지는 전체 경로를 한 번에
## 확인한 적은 없었다.
##
## 실행: godot4 --headless --script res://tests/test_full_playthrough.gd --path <project>

var _player: Node2D
var _progress: Node
var _all_passed := true

func _initialize() -> void:
	# 1) 프롤로그 -> Esc로 건너뛰고 챕터 1 현실 도착 확인.
	change_scene_to_file("res://scenes/chapter1_intro.tscn")
	await process_frame
	await process_frame
	await _send_action("ui_cancel")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"프롤로그를 건너뛰면 챕터 1 현실에 도착함, 실제: %s" %
			[current_scene.name if current_scene else "null"])
	if current_scene == null or current_scene.name != "Chapter1Real":
		_finish()
		return

	_player = get_first_node_in_group("player")
	_progress = root.get_node_or_null("Chapter1Progress")
	_assert(_player != null and _progress != null, "player/Chapter1Progress를 찾음")
	if _player == null or _progress == null:
		_finish()
		return

	# 2) 1단계: 판자 확인(잠김) -> 순환 -> 2단계: 사방치기에서 열쇠.
	var floorboard: Node2D = current_scene.get_node("Floorboard")
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	var jar: Node2D = current_scene.get_node("JarStamp")

	await _move_to(floorboard.position)
	await _interact_close()

	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 2, "순환 1회 후 2단계")

	await _move_to(hopscotch.position)
	await _interact_close()
	_assert(_progress.has_key, "사방치기에서 열쇠 획득")

	# 3) 순환 -> 3단계: 장독에서 나무패.
	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 3, "순환 2회 후 3단계")

	await _move_to(jar.position)
	await _interact_close()
	_assert(_progress.has_stamp, "장독에서 나무패 획득")

	# 4) 순환 -> 4단계: 판자에서 일기 개봉 -> 자동으로 챕터 종료 화면.
	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 4, "순환 3회 후 4단계")

	await _move_to(floorboard.position)
	await _interact_close()
	_assert(_progress.diary_opened, "4단계에서 판자를 열면 일기 개봉됨")

	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"프롤로그부터 시작한 전체 플레이가 챕터 종료 화면까지 정상 도달, 실제: %s" %
			[current_scene.name if current_scene else "null"])

	_finish()


## 대화/팝업이 뜨면 전부 닫고 나올 때까지 Enter를 반복 전송한다
## (대화 여러 줄 + 뒤이은 아이템 팝업까지 한 번에 처리).
func _interact_close() -> void:
	await _send_action("ui_accept")
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var popup: Node = root.get_node_or_null("ItemPopup")
	var guard := 0
	while guard < 20 and ((dialogue and dialogue.is_active()) or (popup and popup.is_active())):
		await _send_action("ui_accept")
		guard += 1


func _move_to(target: Vector2) -> void:
	while not _player.position.is_equal_approx(target):
		var diff := target - _player.position
		var action := "ui_right"
		if absf(diff.x) > 0.01:
			action = "ui_right" if diff.x > 0 else "ui_left"
		elif absf(diff.y) > 0.01:
			action = "ui_down" if diff.y > 0 else "ui_up"
		else:
			break
		await _move_one_tile(action)


func _move_one_tile(action: String) -> void:
	_press(action)
	var g := 0
	while not _player._moving and g < 10:
		await process_frame
		g += 1
	_release(action)
	var g2 := 0
	while _player._moving and g2 < 60:
		await process_frame
		g2 += 1


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


func _send_action(action: String) -> void:
	_press(action)
	await process_frame
	await process_frame
	_release(action)
	await process_frame
	await process_frame


func _press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _release(action: String) -> void:
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
