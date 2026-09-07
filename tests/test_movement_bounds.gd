extends SceneTree
## 자동 상호작용 테스트 — 플레이어가 play_area 경계 밖으로 나가지 못하는지
## 검증한다 (player.gd의 next_position/play_area.has_point 체크).
## 실행: godot4 --headless --script res://tests/test_movement_bounds.gd --path <project>

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

	# 시작 위치 (608,160) 에서 위로 5칸(160/32) 이동하면 y=0 (경계)에 도달
	for i in range(5):
		await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(608, 0)),
		"위로 5칸 이동 후 (608,0), 실제: %s" % [_player.position])

	# 경계에서 한 번 더 위로 누르면 화면 밖(y=-32)으로 못 나가고 그대로여야 함
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(608, 0)),
		"경계에서 추가로 위로 눌러도 그대로 (608,0), 실제: %s" % [_player.position])

	# 아래로 다시 이동은 정상 작동해야 함 (경계 로직이 이동 자체를 막은 게 아님을 확인)
	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(608, 32)),
		"경계 이후 아래로 이동은 정상, 실제: %s" % [_player.position])

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
