extends SceneTree
## 자동 테스트 — NPC/InteractableBase 하위 오브젝트에 추가된 동적
## 콜리전("blocks_movement" 그룹, 2026-09-09 사람 피드백 "NPC 및 대화
## 가능한 오브젝트에도 벽처럼 충돌 판정을 추가한다")이 실제로 벽처럼
## 막는지 검증한다. 정적 blocked_rects(벽/나무 밑둥)는
## test_collision_map.gd가 이미 검증한다.
##
## 2026-09-09 퍼즐 구조 변경(꿈 방문 한 번 안에서 전부 진행)으로 판자/
## 공기돌/사방치기/장독이 chapter1_real에서 chapter1_dream으로 옮겨갔고,
## 더 이상 단계별로 나타났다 사라지지 않고 처음부터 항상 보인다 — 그래서
## NPC 콜리전은 현실 씬에서, 나머지 오브젝트 콜리전은 꿈 씬에서 확인한다.
##
## 실행: godot4 --headless --script res://tests/test_dynamic_collision.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	await _check_npc_collision_in_reality()
	await _check_puzzle_object_collision_in_dream()
	_finish()


func _check_npc_collision_in_reality() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_assert(_player != null, "(현실) player 그룹 노드를 찾음")
	if _player == null:
		return

	# --- NPC 콜리전: 스폰(608,160)에서 오른쪽으로 2칸(672,160)까지는
	# 정상 이동, 그 다음 한 칸(704,160, ShadowNPC 위치)은 막혀야 한다.
	for i in range(2):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"(현실) NPC 옆(672,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"(현실) NPC 자리(704,160)로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])


func _check_puzzle_object_collision_in_dream() -> void:
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	var progress: Node = root.get_node_or_null("Chapter1Progress")
	_assert(_player != null, "(꿈) player 그룹 노드를 찾음")
	_assert(progress != null, "Chapter1Progress 오토로드를 찾음")
	if _player == null or progress == null:
		return

	# --- Floorboard(480,160) 콜리전: y=160행은 곧장 왼쪽으로 못
	# 지나가므로, 콜리전 없는 y=192행으로 우회해서 옆 칸(512,160)까지 간다.
	# 스폰(608,160)에서 3칸 왼쪽 = 512.
	await _move_one_tile("ui_down")
	for i in range(3):
		await _move_one_tile("ui_left")
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(512, 160)),
		"(꿈) Floorboard 옆(512,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(512, 160)),
		"(꿈) Floorboard(480,160) 자리로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# --- GonggiStones(416,160) 콜리전: 같은 방식으로 우회해서 옆 칸
	# (448,160)까지 간다.
	await _move_one_tile("ui_down")
	for i in range(2):
		await _move_one_tile("ui_left")
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(448, 160)),
		"(꿈) GonggiStones 옆(448,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(448, 160)),
		"(꿈) GonggiStones(416,160) 자리로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# --- HopscotchKey(448,480) 콜리전: 2026-09-09부터는 단계 게이팅 없이
	# 씬 로드 직후부터 바로 보이고 바로 막혀야 한다(예전엔 2단계부터).
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	_assert(hopscotch.visible, "(꿈) HopscotchKey는 씬 로드 즉시부터 보임(더 이상 단계 게이팅 없음)")
	for i in range(10):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(448, 448)),
		"(꿈) HopscotchKey 옆(448,448)까지만 이동, 자리(448,480)는 처음부터 막혀 있음, 실제: %s" %
			[_player.position])


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
