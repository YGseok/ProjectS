extends SceneTree
## 자동 상호작용 테스트 — chapter1_real.tscn(일상 파트)에 새로 추가한
## NPC 3개(NpcA/B/C, scripts/npc.gd 재사용)가 실제로 도달 가능한 위치에
## 있고, 각자 지정한 placeholder 대사가 뜨는지 검증한다(사람 피드백,
## 2026-09-14 "일상 파트에서는 NPC 3개 정도 만들고, 임의의 대화를 하도록
## 만든다", DESIGN.md §11.4). 대사 내용은 전부 placeholder — 이 테스트가
## 확인하는 건 "NPC가 배치돼 있고 상호작용이 되는가"이지 대사 내용이
## 아니다.
##
## 실행: godot4 --headless --script res://tests/test_daily_life_npcs.gd --path <project>

var _player: Node2D
var _dialogue: Node
var _last_seen_text := ""
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

	var ysort: Node = current_scene.get_node("YSortObjects")
	_assert(ysort.get_node_or_null("NpcA") != null, "NpcA 노드를 찾음")
	_assert(ysort.get_node_or_null("NpcB") != null, "NpcB 노드를 찾음")
	_assert(ysort.get_node_or_null("NpcC") != null, "NpcC 노드를 찾음")

	# 1) 대문(x448~512)을 지나 안방(NpcA, 384,-160)까지 이동.
	for i in range(4):
		await _move_one_tile("ui_left")
	for i in range(10):
		await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(480, -160)),
		"대문을 지나 안방 진입, 실제: %s" % [_player.position])

	# NpcA(384,-160)는 그 자체가 blocks_movement라서 왼쪽으로 계속
	# 이동하면 한 칸 앞(416,-160)에서 자동으로 막히고, 그 순간 facing도
	# LEFT로 갱신된다(player.gd: 막혀도 facing은 갱신됨) — 굳이 정확한
	# 정지 위치를 미리 계산해서 우회할 필요 없이 자연스럽게 인접+정면
	# 상태가 된다.
	for i in range(3):
		await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(416, -160)),
		"NpcA 앞(막혀서 정지)까지 이동, 실제: %s" % [_player.position])
	_assert(_player.facing == Vector2.LEFT, "NpcA 방향(LEFT)을 보고 있음, 실제: %s" % [_player.facing])

	await _interact_close()
	_assert(_last_seen_text == "오늘도 덥네.", "NpcA 대사가 지정한 placeholder와 일치, 실제: '%s'" % _last_seen_text)

	# 2) 안방 <-> 건넌방 경계(x608~640)는 y=-160 행에서는 열려 있다(문
	# 틈, DESIGN.md §11.1 참고) — 그대로 오른쪽으로 계속 가면 NpcB
	# (800,-160) 앞(768,-160)에서 막혀 멈춘다.
	for i in range(12):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(768, -160)),
		"건넌방을 지나 NpcB 앞(막혀서 정지)까지 이동, 실제: %s" % [_player.position])
	_assert(_player.facing == Vector2.RIGHT, "NpcB 방향(RIGHT)을 보고 있음, 실제: %s" % [_player.facing])

	await _interact_close()
	_assert(_last_seen_text == "또 왔구나.", "NpcB 대사가 지정한 placeholder와 일치, 실제: '%s'" % _last_seen_text)

	# 3) 다시 대문(x480)으로 돌아나가 마당의 NpcC(960,544)까지 이동.
	# 원두막 지붕(x832~1120,y352~416) 아래를 지나는 y=480 행으로
	# 우회한다(v0.22 발판 테스트에서 쓴 것과 동일한 우회 패턴).
	for i in range(9):
		await _move_one_tile("ui_left")
	for i in range(10):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(480, 160)),
		"대문을 통해 마당으로 복귀, 실제: %s" % [_player.position])

	for i in range(10):
		await _move_one_tile("ui_down")
	for i in range(15):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(960, 480)),
		"원두막 지붕 아래(y=480)를 지나 NpcC 위쪽까지 이동, 실제: %s" % [_player.position])

	# NpcC(960,544) 바로 위(960,512)까지 내려간 뒤, 한 번 더 내려가려다
	# NpcC에 막혀 자동으로 정지 + facing DOWN.
	for i in range(2):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(960, 512)),
		"NpcC 앞(막혀서 정지)까지 이동, 실제: %s" % [_player.position])
	_assert(_player.facing == Vector2.DOWN, "NpcC 방향(DOWN)을 보고 있음, 실제: %s" % [_player.facing])

	await _interact_close()
	_assert(_last_seen_text == "...", "NpcC 대사가 지정한 placeholder와 일치, 실제: '%s'" % _last_seen_text)

	_finish()


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
