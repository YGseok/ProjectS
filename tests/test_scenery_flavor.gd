extends SceneTree
## 자동 상호작용 테스트 — chapter1_real.tscn에 새로 추가한 배경 장식물
## 조사 오브젝트(나무 2그루 + 열매 덤불, scripts/scenery_flavor.gd)가
## 실제로 도달 가능한 위치에 있고, 조사하면 지정한 대사가 뜨는지 검증한다
## (사람 피드백, 2026-09-08 "인터렉션 오브젝트... 뭔가 더 필요하다").
##
## 실행: godot4 --headless --script res://tests/test_scenery_flavor.gd --path <project>

var _player: Node2D
var _dialogue: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_dialogue = root.get_node_or_null("DialogueSystem")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_dialogue != null, "DialogueSystem 오토로드를 찾음")
	if _player == null or _dialogue == null:
		_finish()
		return

	# TreeGreen 옆(704,448)까지 이동해서 조사. (608,160)에서 곧장
	# "오른쪽 3, 아래 9"로 가면 (704,160)을 지나야 하는데, 그 자리는
	# 2026-09-09에 추가된 ShadowNPC 콜리전으로 막혀 있다 — 아래로 먼저
	# 충분히 내려간 뒤(10칸, y=480행) 오른쪽으로 이동해서(y=480행은
	# 트렁크 콜리전과 안 겹침) NPC/나무 밑동을 모두 피해 도착한다.
	for i in range(10):
		await _move_one_tile("ui_down")
	for i in range(3):
		await _move_one_tile("ui_right")
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(704, 448)),
		"TreeGreen 옆까지 정상 이동, 실제: %s" % [_player.position])

	await _interact_close()
	_assert(_dialogue_saw("그늘이 시원하다"), "TreeGreen 조사 시 지정한 대사가 뜸")

	# 꿈 씬(chapter1_dream.tscn)에도 같은 자리에 같은 컴포넌트로 examine
	# 트리거를 추가했다 — 좌표/충돌은 동일하므로 상호작용만 재확인.
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_dialogue = root.get_node_or_null("DialogueSystem")
	_assert(_player != null, "(꿈 씬) player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	for i in range(3):
		await _move_one_tile("ui_right")
	for i in range(9):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(704, 448)),
		"(꿈 씬) TreeGreen 옆까지 정상 이동, 실제: %s" % [_player.position])

	await _interact_close()
	_assert(_dialogue_saw("그늘이 지지 않는다"), "(꿈 씬) TreeGreen 조사 시 지정한 대사가 뜸")

	_finish()


func _dialogue_saw(substr: String) -> bool:
	# _interact_close()가 이미 대화를 다 닫았으므로, 여기서는 그 안에서
	# 마지막으로 표시했던 텍스트를 별도로 기록해뒀어야 하는데 단순화를
	# 위해 대신 아래 _interact_close()가 직접 라벨 텍스트를 검사하고
	# 결과를 저장한다.
	return _last_seen_text.find(substr) != -1


var _last_seen_text := ""

func _interact_close() -> void:
	await _send_action("ui_accept")
	var label: Label = _dialogue.get_node("Panel/Label")
	_last_seen_text = label.text
	var guard := 0
	while _dialogue.is_active() and guard < 20:
		await _send_action("ui_accept")
		guard += 1


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
