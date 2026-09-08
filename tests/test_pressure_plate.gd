extends SceneTree
## 자동 유닛 테스트 — scripts/pressure_plate.gd(범용 발판/풋 스위치
## 컴포넌트, 아직 챕터 1 어디에도 실제로 배치는 안 함)의 눌림/해제/
## one_shot 동작을 검증한다. 아직 어느 .tscn에도 없는 컴포넌트라 이
## 테스트가 프로그램적으로 인스턴스화해서 씬에 붙인다.
##
## 실행: godot4 --headless --script res://tests/test_pressure_plate.gd --path <project>

const PLATE_SCRIPT := preload("res://scripts/pressure_plate.gd")

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

	# --- 기본(one_shot=false) 발판: 밟으면 눌리고, 벗어나면 풀림 ---
	var plate := Node2D.new()
	plate.set_script(PLATE_SCRIPT)
	plate.position = Vector2(608, 224)  # 스폰(608,160)에서 아래로 두 칸
	var visual := ColorRect.new()
	visual.name = "Visual"
	visual.size = Vector2(24, 24)
	visual.position = Vector2(-12, -12)
	plate.add_child(visual)
	current_scene.add_child(plate)

	# GDScript 람다는 지역 int 변수를 값으로 캡처해서(참조 공유 아님)
	# 람다 안에서 증가시켜도 바깥 변수엔 반영이 안 된다 — 배열(참조
	# 타입)에 담아서 우회한다.
	var pressed_count := [0]
	var released_count := [0]
	plate.pressed.connect(func(): pressed_count[0] += 1)
	plate.released.connect(func(): released_count[0] += 1)

	for i in range(10):
		await process_frame
	_assert(not plate.is_pressed(), "플레이어가 멀리 있을 때는 안 눌려있음")

	# 발판 위치(608,224)로 이동: 아래로 2칸.
	await _move_one_tile("ui_down")
	await _move_one_tile("ui_down")
	for i in range(5):
		await process_frame
	_assert(plate.is_pressed(), "발판 위로 이동하면 눌림")
	_assert(pressed_count[0] == 1, "pressed 시그널이 정확히 1번 발생, 실제: %d" % pressed_count[0])

	# 계속 밟고 있는 동안 다시 눌리지 않아야 함(중복 발생 방지)
	for i in range(5):
		await process_frame
	_assert(pressed_count[0] == 1, "계속 밟고 있어도 pressed가 중복 발생하지 않음")

	# 벗어나면 released.
	await _move_one_tile("ui_up")
	await _move_one_tile("ui_up")
	for i in range(5):
		await process_frame
	_assert(not plate.is_pressed(), "발판에서 벗어나면 눌림 해제")
	_assert(released_count[0] == 1, "released 시그널이 정확히 1번 발생, 실제: %d" % released_count[0])

	plate.queue_free()

	# --- one_shot=true 발판: 한 번 눌리면 벗어나도 계속 눌린 채 유지, 재진입해도 재발생 없음 ---
	var plate_once := Node2D.new()
	plate_once.set_script(PLATE_SCRIPT)
	plate_once.one_shot = true
	plate_once.position = Vector2(608, 224)
	current_scene.add_child(plate_once)

	var once_pressed_count := [0]
	plate_once.pressed.connect(func(): once_pressed_count[0] += 1)

	await _move_one_tile("ui_down")
	await _move_one_tile("ui_down")
	for i in range(5):
		await process_frame
	_assert(plate_once.is_pressed(), "one_shot 발판도 처음 밟으면 눌림")
	_assert(once_pressed_count[0] == 1, "one_shot 발판의 pressed도 1번 발생")

	await _move_one_tile("ui_up")
	await _move_one_tile("ui_up")
	for i in range(5):
		await process_frame
	_assert(plate_once.is_pressed(), "one_shot 발판은 벗어나도 눌린 상태 유지(영구 스위치)")

	await _move_one_tile("ui_down")
	await _move_one_tile("ui_down")
	for i in range(5):
		await process_frame
	_assert(once_pressed_count[0] == 1, "one_shot 발판은 다시 밟아도 pressed가 재발생하지 않음")

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
