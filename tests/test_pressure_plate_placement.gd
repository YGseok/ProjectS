extends SceneTree
## 자동 상호작용 테스트 — chapter1_dream.tscn 원두막 마루에 배치한
## 분위기용 발판(CreakyBoardPlate, scripts/pressure_plate_flavor.gd)이
## 실제로 도달 가능한 위치에 있고, 밟으면 지정한 대사가 한 번만 뜨는지
## 검증한다(사람 피드백, 2026-09-08 "인터렉션 오브젝트... 무언가가 더
## 필요하다", 2026-09-14 "레벨 디자인 및 배치는 임의로 일임").
##
## 실행: godot4 --headless --script res://tests/test_pressure_plate_placement.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	root.get_node("Chapter1Progress").chapter_started = true

	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	var dialogue: Node = root.get_node("DialogueSystem")
	var plate: Node2D = current_scene.get_node("CreakyBoardPlate")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(plate != null, "CreakyBoardPlate 노드를 찾음")
	if _player == null or plate == null:
		_finish()
		return

	# 스폰(608,160)에서 발판(896,480)까지 이동 — 곧장 내려가면 원두막
	# 지붕 콜리전(x:832-1120, y:352-416)에 막히므로, 오른쪽으로 먼저
	# 충분히 이동해 지붕을 지나친 뒤 내려가는 우회 경로를 쓴다.
	await _move_to(Vector2(1152, 160))
	await _move_to(Vector2(1152, 480))
	await _move_to(Vector2(896, 480))
	_assert(_player.position.is_equal_approx(Vector2(896, 480)),
		"발판 자리까지 정상 이동, 실제: %s" % [_player.position])

	await process_frame
	await process_frame
	_assert(plate.is_pressed(), "발판 위에 서면 눌림")
	_assert(dialogue.is_active(), "발판을 밟으면 대사가 자동으로 뜸(상호작용 키 불필요)")
	var label: Label = dialogue.get_node("Panel/Label")
	_assert(label.text.find("삐걱") != -1, "대사 내용이 지정한 문구를 포함함, 실제: '%s'" % label.text)

	# 대사를 닫고 발판에서 벗어났다가 다시 밟아도 one_shot이라 재발동
	# 안 해야 한다.
	await _send_action("ui_accept")
	_assert(not dialogue.is_active(), "대사가 정상적으로 닫힘")

	await _move_one_tile("ui_up")
	await _move_one_tile("ui_down")
	await process_frame
	_assert(not dialogue.is_active(), "one_shot이라 다시 밟아도 대사가 재발동하지 않음")

	_finish()


## x축 우선 이동, 막히면 y축으로 우회 시도(다른 테스트들과 동일한 패턴).
func _move_to(target: Vector2) -> void:
	var guard := 0
	while not _player.position.is_equal_approx(target) and guard < 100:
		guard += 1
		var diff := target - _player.position
		var x_action := ""
		var y_action := ""
		if absf(diff.x) > 0.01:
			x_action = "ui_right" if diff.x > 0 else "ui_left"
		if absf(diff.y) > 0.01:
			y_action = "ui_down" if diff.y > 0 else "ui_up"
		if x_action == "" and y_action == "":
			break
		var before := _player.position
		if x_action != "":
			await _move_one_tile(x_action)
		if _player.position.is_equal_approx(before) and y_action != "":
			await _move_one_tile(y_action)
		if _player.position.is_equal_approx(before):
			break


func _move_one_tile(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var start_guard := 0
	while not _player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	var move_guard := 0
	while _player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


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
