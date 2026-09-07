extends SceneTree
## 자동 상호작용 테스트 — NPC는 "인접 + 그 방향을 바라볼 때"만 반응해야
## 한다 (scripts/npc.gd). 지금까지의 대화 테스트(test_dialogue_interaction.gd)
## 는 "바라보고 있을 때 반응한다"는 긍정 케이스만 확인했었다. 이 테스트는
## "인접하지만 다른 방향을 보고 있으면 반응하지 않는다"는 부정 케이스와,
## 그 직후 다시 바라보면 정상적으로 반응하는지(설정 자체가 깨진 게 아님을
## 확인하는 대조군)를 함께 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_npc_facing_check.gd --path <project>

var _player: Node2D
var _dialogue: Node
var _all_passed := true

func _initialize() -> void:
	_dialogue = null
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_dialogue = root.get_node_or_null("DialogueSystem")
	_player = get_first_node_in_group("player")
	_assert(_dialogue != null, "DialogueSystem 오토로드를 찾음")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _dialogue == null or _player == null:
		_finish()
		return

	# (608,160) -> (672,160), NPC(704,160)와 인접, facing RIGHT
	await _move_one_tile("ui_right")
	await _move_one_tile("ui_right")
	_assert(_player.facing == Vector2.RIGHT, "이동 후 facing RIGHT, 실제: %s" % [_player.facing])

	# 위로 갔다가 아래로 내려와서 같은 자리(672,160)로 돌아오되 facing은 DOWN으로
	await _move_one_tile("ui_up")
	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"제자리로 복귀, 실제: %s" % [_player.position])
	_assert(_player.facing == Vector2.DOWN, "복귀 후 facing DOWN, 실제: %s" % [_player.facing])

	# 부정 케이스: 인접하지만 NPC 방향(RIGHT)이 아닌 DOWN을 보고 있으므로
	# Enter를 눌러도 대화가 시작되면 안 된다.
	await _send_action("ui_accept")
	_assert(not _dialogue.is_active(),
		"다른 방향을 보고 있으면 인접해도 대화가 시작되지 않음")

	# 대조군: 다시 오른쪽을 보게 만들고(왼쪽 갔다가 오른쪽으로 복귀) 같은 Enter로
	# 이번엔 정상적으로 시작되는지 확인 (테스트 자체가 항상 실패하는 게 아님을 확인)
	await _move_one_tile("ui_left")
	await _move_one_tile("ui_right")
	_assert(_player.facing == Vector2.RIGHT, "다시 RIGHT를 보는 상태로 복귀, 실제: %s" % [_player.facing])

	await _send_action("ui_accept")
	_assert(_dialogue.is_active(), "NPC를 바라본 상태에서는 정상적으로 대화 시작됨(대조군)")

	_finish()


func _move_one_tile(action: String) -> void:
	_press(action)
	var start_guard := 0
	while not _player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	_release(action)
	var move_guard := 0
	while _player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


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
