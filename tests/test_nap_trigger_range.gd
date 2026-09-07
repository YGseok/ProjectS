extends SceneTree
## 자동 상호작용 테스트 — 낮잠 트리거(scripts/nap_trigger.gd)가 사정거리
## (interact_radius) 밖에서는 반응하지 않고, 프롬프트 라벨도 그때만
## 보이는지 검증한다. 지금까지의 왕복 테스트(test_nap_wake_roundtrip.gd)는
## 플레이어가 이미 트리거 위치에 있는 긍정 케이스만 다뤘다.
##
## 실행: godot4 --headless --script res://tests/test_nap_trigger_range.gd --path <project>

var _player: Node2D
var _nap_trigger: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_nap_trigger = current_scene.get_node_or_null("NapTrigger")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_nap_trigger != null, "NapTrigger 노드를 찾음")
	if _player == null or _nap_trigger == null:
		_finish()
		return

	var prompt_label: Label = _nap_trigger.get_node("PromptLabel")

	# 시작 위치(608,160)는 트리거 바로 위 -> 사정거리 안
	await process_frame
	_assert(prompt_label.visible, "트리거 위치에 있을 때 프롬프트 라벨이 보임")

	# 아래로 2칸(608,224) 이동 -> 거리 64 > interact_radius(24), 사정거리 밖.
	# (오른쪽으로 가면 툇마루의 그림자 NPC와 인접+마주보게 돼서 낮잠 대신
	# NPC 대화가 열려버리는 간섭이 생기므로 반드시 아래/위로 움직일 것.)
	await _move_one_tile("ui_down")
	await _move_one_tile("ui_down")
	await process_frame
	_assert(not prompt_label.visible, "사정거리 밖에서는 프롬프트 라벨이 숨겨짐")

	await _send_action("ui_accept")
	_assert(current_scene.name == "Chapter1Real",
		"사정거리 밖에서 Enter를 눌러도 씬이 전환되지 않음, 실제: %s" % [current_scene.name])

	# 다시 위로 2칸 이동해 트리거 위치로 복귀 -> 대조군: 정상적으로 전환돼야 함
	await _move_one_tile("ui_up")
	await _move_one_tile("ui_up")
	await process_frame
	_assert(prompt_label.visible, "복귀 후 다시 프롬프트 라벨이 보임")

	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Dream", 3.0)
	_assert(current_scene.name == "Chapter1Dream",
		"사정거리 안에서는 정상적으로 낮잠 전환됨(대조군), 실제: %s" % [current_scene.name])

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


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
