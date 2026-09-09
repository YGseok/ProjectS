extends SceneTree
## 자동 상호작용 테스트 — 플레이어가 play_area 경계 밖으로 나가지 못하는지
## 검증한다 (player.gd의 next_position/play_area.has_point 체크).
##
## 왼쪽(화면 x=0)으로 경계를 확인한다 — 위쪽은 이제 기와집 벽 콜리전이
## y=128 자리에 있어서 화면 경계(y=0)보다 먼저 막히므로, "월드 경계"와
## "오브젝트 콜리전"을 섞지 않기 위해 콜리전이 없는 왼쪽 방향을 쓴다.
## 콜리전 자체는 test_collision_map.gd에서 따로 검증한다.
##
## y=160행(툇마루)은 2026-09-09부터 GonggiStones(416,160)/Floorboard
## (480,160)/ShadowNPC(704,160)에 콜리전이 생겨서 더 이상 "콜리전 없는
## 가로줄"이 아니다 — 아래로 한 칸(y=192) 내려간 뒤 그 줄에서 왼쪽 이동을
## 검증한다(그 줄은 여전히 아무 오브젝트도 없음).
##
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

	# 카메라 limit_*가 play_area(현재는 화면 전체, 0,0,1280,720)와 정확히
	# 같아야 한다 — 뷰포트 크기와 limit 크기가 같으면 카메라가 움직일
	# 여지가 없어서(항상 중앙에 고정) 지금은 시각적으로 아무 변화가
	# 없지만, 나중에 맵이 화면보다 커지면(사람 피드백, 2026-09-08 —
	# "맵이 과하게 넓으면 스크롤링") 이 limit이 실제 맵 경계 역할을 하게
	# 된다. 값이 실수로 어긋나면 이 테스트가 잡아낸다.
	var camera: Camera2D = _player.get_node("Camera2D")
	_assert(camera != null, "플레이어에 Camera2D가 있음")
	if camera:
		_assert(camera.limit_left == 0 and camera.limit_top == 0 and
				camera.limit_right == 1280 and camera.limit_bottom == 720,
			"카메라 limit이 play_area(0,0,1280,720)와 일치, 실제: (%d,%d,%d,%d)" %
				[camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom])

	# 콜리전 없는 줄(y=192)로 한 칸 내려간 뒤, 왼쪽으로 19칸(608/32)
	# 이동하면 x=0 (경계)에 도달.
	await _move_one_tile("ui_down")
	for i in range(19):
		await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(0, 192)),
		"왼쪽으로 19칸 이동 후 (0,192), 실제: %s" % [_player.position])

	# 경계에서 한 번 더 왼쪽으로 누르면 화면 밖(x=-32)으로 못 나가고 그대로여야 함
	await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(0, 192)),
		"경계에서 추가로 왼쪽으로 눌러도 그대로 (0,192), 실제: %s" % [_player.position])

	# 오른쪽으로 다시 이동은 정상 작동해야 함 (경계 로직이 이동 자체를 막은 게 아님을 확인)
	await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(32, 192)),
		"경계 이후 오른쪽으로 이동은 정상, 실제: %s" % [_player.position])

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
