extends SceneTree
## 자동 상호작용 테스트 — 방향키/Enter를 실제 입력처럼 시뮬레이션해서
## (Input.parse_input_event, 폴링/이벤트 콜백 둘 다 실제 키 입력과 동일하게
## 트리거됨) "플레이어가 NPC 쪽으로 걸어가 마주보고 Enter를 누르면 대화가
## 뜨고, 다시 누르면 닫힌다"는 흐름을 사람 없이 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_dialogue_interaction.gd --path <project>
## 성공: 마지막 줄에 [TEST] ALL PASSED 출력 + exit 0
## 실패: 실패한 assert 내용 출력 + exit 1

var _player: Node2D
var _dialogue: Node
var _all_passed := true

func _initialize() -> void:
	# 오토로드(DialogueSystem)는 --script 모드에서 전역 식별자로 노출되지
	# 않아서(컴파일 오류) /root 에서 직접 노드를 찾는다.
	_dialogue = root.get_node_or_null("DialogueSystem")
	_assert(_dialogue != null, "DialogueSystem 오토로드 노드를 /root 에서 찾음")
	if _dialogue == null:
		_finish()
		return

	var packed := load("res://scenes/chapter1_real.tscn") as PackedScene
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	_assert(not _dialogue.is_active(), "시작 시 대화 비활성 상태")

	# 플레이어를 오른쪽으로 2칸 이동 (608,160) -> (672,160), ShadowNPC(704,160)와 인접
	await _move_one_tile("ui_right")
	await _move_one_tile("ui_right")

	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"이동 후 위치가 (672,160) 근처, 실제: %s" % [_player.position])
	_assert(_player.facing == Vector2.RIGHT, "이동 후 facing == RIGHT, 실제: %s" % [_player.facing])

	# NPC 방향을 보고 있는 상태에서 상호작용
	await _send_action("ui_accept")

	_assert(_dialogue.is_active(), "Enter 입력 후 대화 활성화됨")
	var label: Label = _dialogue.get_node("Panel/Label")
	_assert(label.text == "[...]", "대화 텍스트가 '[...]', 실제: '%s'" % label.text)

	# 대화가 활성화된 동안 플레이어가 움직이지 않아야 함 (player.gd의 대화 중 이동 차단 확인)
	var pos_before_move_attempt := _player.position
	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(pos_before_move_attempt),
		"대화 중에는 이동 입력이 무시됨, 실제: %s" % [_player.position])

	# 대화 진행 (줄이 1개뿐이므로 다음 Enter로 종료돼야 함)
	await _send_action("ui_accept")
	_assert(not _dialogue.is_active(), "두 번째 Enter 후 대화 종료됨")

	# 회귀 테스트: 플레이어가 NPC 옆에 그대로 서있는 상태에서 대화를 닫으면,
	# 같은 입력으로 NPC가 같은 프레임에 즉시 재시작해서는 안 된다. 몇 프레임
	# 더 지켜봐서 계속 닫힌 채로 있는지 확인한다.
	for _i in range(5):
		await process_frame
	_assert(not _dialogue.is_active(), "대화 종료 몇 프레임 뒤에도 재시작되지 않고 닫힌 채로 유지됨")

	# 그 다음 새로 Enter를 누르면 다시 정상적으로 대화가 시작되어야 한다
	# (닫힌 뒤 영영 반응 안 하는 것도 버그이므로 함께 확인)
	await _send_action("ui_accept")
	_assert(_dialogue.is_active(), "닫힌 뒤 다시 Enter를 누르면 정상적으로 재시작됨")

	_finish()


func _move_one_tile(action: String) -> void:
	_send_action_press(action)
	var start_guard := 0
	while not _player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	_send_action_release(action)
	var move_guard := 0
	while _player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


func _send_action(action: String) -> void:
	_send_action_press(action)
	await process_frame
	await process_frame
	_send_action_release(action)
	await process_frame
	await process_frame


func _send_action_press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _send_action_release(action: String) -> void:
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
