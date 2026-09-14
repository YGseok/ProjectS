extends SceneTree
## 자동 상호작용 테스트 — 챕터 1 현실 맵 확장(2026-09-14, DESIGN.md §8.3
## "레벨 디자인 및 내부 구조는 임의로 일임한다")으로 새로 생긴 기와집
## 내부(안방+건넌방)가 실제로 걸어서 도달 가능한지, 벽이 제대로 막고
## 있는지, 안방-건넌방 사이 문(칸 하나만 뚫려 있음)이 정확한 자리에만
## 있는지 검증한다.
##
## 좌표 참고(chapter1_real_background.gd): 안방 출입문 col14-15(x448-511),
## 내부 바닥 col9-29/row-9~-1, 안방-건넌방 사이 벽 col19(x608-639) —
## row-5,-4(y-160,-128)만 뚫려 있음.
##
## 실행: godot4 --headless --script res://tests/test_house_interior.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	# 스폰(608,160)에서 왼쪽 5칸 -> 출입문 자리(448,160).
	for i in range(5):
		await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(448, 160)),
		"출입문 앞(448,160)까지 정상 이동, 실제: %s" % [_player.position])

	# 문을 통해 안방 안쪽까지(row-5, y=-160) 위로 10칸.
	for i in range(10):
		await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(448, -160)),
		"출입문을 통해 안방 안쪽까지 정상 이동, 실제: %s" % [_player.position])

	# 안방-건넌방 사이 문(row-5)을 통해 건넌방까지 오른쪽 7칸 -> (672,-160).
	for i in range(7):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(672, -160)),
		"안방-건넌방 사이 문을 통해 건넌방까지 정상 이동, 실제: %s" % [_player.position])

	# --- 벽이 실제로 막는지 확인 ---
	# 안방으로 돌아가 북쪽 벽(row-9, y=-288)까지 간 뒤 한 칸 더 위로
	# 가려 하면 막혀야 한다.
	for i in range(7):
		await _move_one_tile("ui_left")
	for i in range(4):
		await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(448, -288)),
		"안방 북쪽 벽 앞(448,-288)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(448, -288)),
		"북쪽 벽으로는 더 못 들어가고 그대로임, 실제: %s" % [_player.position])

	# 안방-건넌방 사이 벽은 문(row-5,-4) 말고 다른 자리(row-8)에서는 막혀야
	# 한다 — (576,-256)까지 이동한 뒤 오른쪽(608,-256 벽)으로 못 가는지 확인.
	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(448, -256)),
		"row-8 줄로 한 칸 내려옴, 실제: %s" % [_player.position])
	for i in range(4):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(576, -256)),
		"벽 바로 앞(576,-256)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(576, -256)),
		"문이 없는 자리(row-8)에서는 안방-건넌방 사이 벽에 막혀 그대로임, 실제: %s" % [_player.position])

	_finish()


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
