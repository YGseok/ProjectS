extends SceneTree
## 자동 상호작용 테스트 — chapter1_dream.tscn에도 반영한 기와집 내부
## (안방+건넌방, 2026-09-14 맵 확장, DESIGN.md §8.3)가 실제로 걸어서
## 도달 가능한지, 벽이 제대로 막고 있는지 검증한다.
## `tests/test_house_interior.gd`(현실)와 같은 구조/좌표를 검증하지만,
## 출입문 위치만 다르다 — 꿈 씬은 Floorboard(480,160)/GonggiStones
## (416,160)가 이미 그 자리에 있어서 문을 col10-11(x320-383, 안방 서쪽
## 구석)로 옮겨야 했다(현실은 col14-15).
##
## 실행: godot4 --headless --script res://tests/test_house_interior_dream.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	# "1장 시작" 타이틀 카드가 이동을 막아 방해하지 않도록 미리 처리.
	root.get_node("Chapter1Progress").chapter_started = true

	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	# 스폰(608,160)에서 왼쪽 9칸 -> 출입문 자리(320,160). Floorboard(480)/
	# GonggiStones(416)를 지나가야 하는데, 둘 다 동적 콜리전으로 막혀
	# 있으므로(2026-09-09) y=192행으로 우회해서 지나간다.
	await _move_to(Vector2(320, 192))
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(320, 160)),
		"출입문 앞(320,160)까지 정상 이동, 실제: %s" % [_player.position])

	# 문을 통해 안방 안쪽까지(row-5, y=-160) 위로 10칸.
	for i in range(10):
		await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(320, -160)),
		"출입문을 통해 안방 안쪽까지 정상 이동, 실제: %s" % [_player.position])

	# 안방-건넌방 사이 문(row-5, col19=x608)을 통해 건넌방까지.
	await _move_to(Vector2(672, -160))
	_assert(_player.position.is_equal_approx(Vector2(672, -160)),
		"안방-건넌방 사이 문을 통해 건넌방까지 정상 이동, 실제: %s" % [_player.position])

	# 북쪽 벽(row-9, y=-288) 확인 — 안방으로 돌아가 북쪽 벽 앞까지 간 뒤
	# 한 칸 더 위로 가려 하면 막혀야 한다.
	await _move_to(Vector2(320, -288))
	_assert(_player.position.is_equal_approx(Vector2(320, -288)),
		"안방 북쪽 벽 앞(320,-288)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(320, -288)),
		"북쪽 벽으로는 더 못 들어가고 그대로임, 실제: %s" % [_player.position])

	_finish()


## x축 우선 이동, 막히면 y축으로 우회(다른 테스트들과 동일한 패턴) —
## Floorboard/GonggiStones 동적 콜리전을 자연스럽게 피해서 이동한다.
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
