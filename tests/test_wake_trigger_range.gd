extends SceneTree
## 자동 상호작용 테스트 — chapter1_dream.tscn의 각성 트리거(WakeTrigger,
## nap_trigger.gd 재사용)도 사정거리 밖에서는 반응하지 않는지 검증한다.
## test_nap_trigger_range.gd와 대칭이지만, 꿈 씬에는 그림자 NPC가 없어
## 그 간섭 문제는 없다 (참고: 그 테스트를 만들며 발견한 함정).
##
## 또한 이 WakeTrigger 인스턴스는 `advances_chapter1_cycle = true`로
## 설정돼 있어야 하므로(DESIGN.md §8.1, chapter1_dream.tscn 참고), 실제
## 각성 성공 시 `Chapter1Progress.stage`가 1 올라가는지도 함께 검증한다
## — `Chapter1Progress.advance_cycle()`을 직접 호출하는 방식(예:
## test_chapter1_puzzle.gd)만으로는 .tscn의 익스포트 값이 실제로 true로
## 저장/전달되고 있는지는 못 잡아낸다.
##
## 실행: godot4 --headless --script res://tests/test_wake_trigger_range.gd --path <project>

var _player: Node2D
var _wake_trigger: Node
var _progress: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_wake_trigger = current_scene.get_node_or_null("WakeTrigger")
	_progress = root.get_node_or_null("Chapter1Progress")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_wake_trigger != null, "WakeTrigger 노드를 찾음")
	_assert(_progress != null, "Chapter1Progress 오토로드 노드를 /root 에서 찾음")
	_assert(_wake_trigger != null and _wake_trigger.advances_chapter1_cycle,
		"WakeTrigger의 advances_chapter1_cycle이 true로 설정됨")
	if _player == null or _wake_trigger == null or _progress == null:
		_finish()
		return

	var stage_before: int = _progress.stage

	var prompt_label: Label = _wake_trigger.get_node("PromptLabel")

	await process_frame
	_assert(prompt_label.visible, "트리거 위치에 있을 때 프롬프트 라벨이 보임")

	# 아래로 2칸 이동 -> 사정거리 밖
	await _move_one_tile("ui_down")
	await _move_one_tile("ui_down")
	await process_frame
	_assert(not prompt_label.visible, "사정거리 밖에서는 프롬프트 라벨이 숨겨짐")

	await _send_action("ui_accept")
	_assert(current_scene.name == "Chapter1Dream",
		"사정거리 밖에서 Enter를 눌러도 씬이 전환되지 않음, 실제: %s" % [current_scene.name])
	_assert(_progress.stage == stage_before,
		"사정거리 밖에서는 진행 단계도 그대로, 실제: %d" % _progress.stage)

	# 복귀 -> 대조군
	await _move_one_tile("ui_up")
	await _move_one_tile("ui_up")
	await process_frame
	_assert(prompt_label.visible, "복귀 후 다시 프롬프트 라벨이 보임")

	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene.name == "Chapter1Real",
		"사정거리 안에서는 정상적으로 각성됨(대조군), 실제: %s" % [current_scene.name])
	_assert(_progress.stage == stage_before + 1,
		"실제 각성 성공 시 진행 단계가 1 올라감, 실제: %d (이전: %d)" % [_progress.stage, stage_before])

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
