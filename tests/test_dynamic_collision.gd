extends SceneTree
## 자동 상호작용 테스트 — NPC/InteractableBase 하위 오브젝트에 새로
## 추가된 동적 콜리전("blocks_movement" 그룹, 2026-09-09 사람 피드백
## "NPC 및 대화 가능한 오브젝트에도 벽처럼 충돌 판정을 추가한다")이
## 실제로 벽처럼 막는지, 그리고 아직 등장하지 않은 단계(visible=false)의
## 오브젝트는 막지 않다가 등장한 뒤부터 막는지 검증한다. 정적
## blocked_rects(벽/나무 밑둥)는 test_collision_map.gd가 이미 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_dynamic_collision.gd --path <project>

var _player: Node2D
var _progress: Node
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_progress = root.get_node_or_null("Chapter1Progress")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_progress != null, "Chapter1Progress 오토로드 노드를 찾음")
	if _player == null or _progress == null:
		_finish()
		return

	# --- NPC 콜리전: 스폰(608,160)에서 오른쪽으로 2칸(672,160)까지는
	# 정상 이동, 그 다음 한 칸(704,160, ShadowNPC 위치)은 막혀야 한다.
	for i in range(2):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"NPC 옆(672,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(672, 160)),
		"NPC 자리(704,160)로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# --- Floorboard(480,160) 콜리전: y=160행은 이제 곧장 왼쪽으로 못
	# 지나가므로, 콜리전 없는 y=192행으로 우회해서 옆 칸(512,160)까지 간다.
	await _move_one_tile("ui_down")
	for i in range(5):
		await _move_one_tile("ui_left")
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(512, 160)),
		"Floorboard 옆(512,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(512, 160)),
		"Floorboard(480,160) 자리로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# --- GonggiStones(416,160) 콜리전: 같은 방식으로 우회해서 옆 칸
	# (448,160)까지 간다.
	await _move_one_tile("ui_down")
	for i in range(2):
		await _move_one_tile("ui_left")
	await _move_one_tile("ui_up")
	_assert(_player.position.is_equal_approx(Vector2(448, 160)),
		"GonggiStones 옆(448,160)까지 정상 이동, 실제: %s" % [_player.position])
	await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(448, 160)),
		"GonggiStones(416,160) 자리로는 이동 못 하고 그대로임, 실제: %s" % [_player.position])

	# --- 단계 게이팅 오브젝트(HopscotchKey)는 "숨겨진 동안은 막지 않다가,
	# 등장하면 그때부터 막는다"가 핵심 — 1단계에서는 안 보이므로 그 자리를
	# 그냥 통과해서 지나갈 수 있어야 한다.
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	_assert(not hopscotch.visible, "1단계에서는 사방치기가 아직 안 보임")
	for i in range(10):
		await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(448, 480)),
		"안 보이는 사방치기 자리는 그냥 통과해서 지나갈 수 있음, 실제: %s" % [_player.position])

	# 한 칸 물러난 뒤 2단계로 진행시켜 사방치기를 등장시킨다.
	await _move_one_tile("ui_up")
	_progress.advance_cycle()
	for i in range(5):
		await process_frame
	_assert(hopscotch.visible, "2단계부터 사방치기가 보임")

	await _move_one_tile("ui_down")
	_assert(_player.position.is_equal_approx(Vector2(448, 448)),
		"등장한 뒤에는 사방치기 자리로 이동 못 하고 그대로임, 실제: %s" % [_player.position])

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
