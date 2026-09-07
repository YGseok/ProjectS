extends SceneTree
## 자동 상호작용 테스트 — 벽/나무 밑둥처럼 CollisionMap에 등록된 영역은
## 실제로 걸어 들어갈 수 없고, 그 옆(칸 하나 차이)은 정상적으로 지나갈
## 수 있는지 검증한다 (사람 피드백, 2026-09-07: "지붕이나 나무 밑둥 등,
## 이동하지 못하는 곳은 블록되어 있어야 함").
##
## 실행: godot4 --headless --script res://tests/test_collision_map.gd --path <project>

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

	# --- 벽 콜리전: 툇마루(y=160)에서 위로 한 칸(y=128)은 괜찮지만,
	# 그 다음 한 칸 더(y=96)는 벽(블록 영역 y:[0,128))이라 막혀야 한다.
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(608, 128)),
		"툇마루에서 위로 한 칸은 정상 이동, 실제: %s" % [_player.position])

	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(608, 128)),
		"벽 안으로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# 원위치로 복귀
	await _move_one_tile("ui_down")

	# --- 나무 밑둥 콜리전: TreeGreen 밑둥은 (672,448)-(704,480) 칸.
	# (672,416)까지 이동한 뒤 아래로 가면 밑둥이라 막히고, 오른쪽으로
	# 돌아서 내려가면(704,448) 정상적으로 지나갈 수 있어야 한다.
	for i in range(2):
		await _move_one_tile("ui_right")
	for i in range(8):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(672, 416)),
		"나무 옆(672,416)까지 정상 이동, 실제: %s" % [_player.position])

	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(672, 416)),
		"나무 밑둥으로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(704, 416)),
		"나무를 피해 오른쪽으로는 정상 이동, 실제: %s" % [_player.position])

	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(704, 448)),
		"나무 밑둥 바로 옆 칸으로는 정상 이동(밑둥 자체만 막힘), 실제: %s" % [_player.position])

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
