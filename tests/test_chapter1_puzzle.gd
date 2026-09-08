extends SceneTree
## 자동 상호작용 테스트 — 챕터 1 메인 퍼즐 "닫힌 일기장"(DESIGN.md §8.1,
## 2026-09-07 확정)의 4단계 순환 진행을 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_chapter1_puzzle.gd --path <project>
##
## Chapter1Progress는 오토로드라 change_scene_to_file()로 씬을 다시 불러도
## 값이 유지된다 — 여기서는 실제 낮잠/각성 씬 전환 대신
## Chapter1Progress.advance_cycle()을 직접 호출해 순환을 시뮬레이션한다
## (씬 전환 자체는 test_nap_wake_roundtrip.gd가 이미 검증함).

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
	_assert(_progress != null, "Chapter1Progress 오토로드 노드를 /root 에서 찾음")
	if _player == null or _progress == null:
		_finish()
		return

	_assert(_progress.stage == 1, "초기 진행 단계는 1, 실제: %d" % _progress.stage)

	var floorboard: Node2D = current_scene.get_node("Floorboard")
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	var jar: Node2D = current_scene.get_node("JarStamp")
	var key_slot: Control = current_scene.get_node("InventoryUI/KeySlot")
	var stamp_slot: Control = current_scene.get_node("InventoryUI/StampSlot")

	# 새로 추가된 오브젝트들의 _process()가 한 번 이상 돌 시간을 준다
	# (씬 로드 직후 2프레임만으로는 부족할 때가 있었음 — visible 갱신은
	# _process에서 일어나므로).
	for i in range(10):
		await process_frame
	_assert(not hopscotch.visible, "1단계에서는 사방치기(열쇠) 안 보임")
	_assert(not jar.visible, "1단계에서는 장독(나무패) 안 보임")
	_assert(not key_slot.visible and not stamp_slot.visible,
		"아이템 획득 전에는 인벤토리 UI 슬롯이 둘 다 숨겨져 있음")

	# 판자로 이동해서 조사 — 아직 잠겨있다는 대사만 뜨고 상태 변화 없음.
	await _move_to(floorboard.position)
	# 상호작용 프롬프트("Enter: 살펴보기")가 실제로 보이는지도 확인한다 —
	# InteractableBase._player 조회가 씬 트리 노드 순서에 우연히 의존하게
	# 되면(예: 이 오브젝트가 Player보다 먼저 _ready()되는 순서로 바뀌면)
	# 상호작용 자체는 되더라도 프롬프트 라벨만 영원히 안 뜨는 회귀가 생긴
	# 적이 있다(chapter1_real.tscn z-order 수정 중 발견, STATUS.md 참고).
	var floorboard_prompt: Label = floorboard.get_node("PromptLabel")
	_assert(floorboard_prompt.visible, "판자 옆에 있으면 상호작용 프롬프트가 보임")
	await _interact()
	_assert(not _progress.has_key and not _progress.has_stamp,
		"1단계에서 판자 조사해도 열쇠/나무패 상태 변화 없음")

	# 순환 1회(각성 시뮬레이션) -> 2단계, 사방치기 등장.
	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 2, "순환 1회 후 2단계, 실제: %d" % _progress.stage)
	_assert(hopscotch.visible, "2단계부터 사방치기 보임")
	_assert(not jar.visible, "2단계에서는 아직 장독 안 보임")

	await _move_to(hopscotch.position)
	await _interact_expect_item("열쇠")
	_assert(_progress.has_key, "2단계 사방치기 조사 후 열쇠 획득")
	await process_frame
	_assert(key_slot.visible and not stamp_slot.visible,
		"열쇠 획득 후 인벤토리에 열쇠 슬롯만 보임")

	# 이미 파낸 뒤 다시 조사해도 크래시 없이 "이미 비어있다" 분기만 타고
	# 상태는 그대로 유지되는지 확인 (hopscotch_key.gd의 has_key 분기).
	await _interact()
	_assert(_progress.has_key, "사방치기를 다시 조사해도 열쇠 상태는 그대로 유지")

	await _move_to(floorboard.position)
	await _interact()
	_assert(not _progress.diary_opened, "열쇠만 있고 나무패 없으면 아직 안 열림")

	# 순환 2회 -> 3단계, 장독 등장.
	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 3, "순환 2회 후 3단계, 실제: %d" % _progress.stage)
	_assert(jar.visible, "3단계부터 장독 보임")

	await _move_to(jar.position)
	await _interact_expect_item("나무패")
	_assert(_progress.has_stamp, "3단계 장독 조사 후 나무패 획득")
	await process_frame
	_assert(key_slot.visible and stamp_slot.visible,
		"나무패까지 획득하면 인벤토리에 두 슬롯 다 보임")

	# 장독도 마찬가지로 재조사 시 안전한지 확인 (jar_stamp.gd의
	# has_stamp 분기).
	await _interact()
	_assert(_progress.has_stamp, "장독을 다시 조사해도 나무패 상태는 그대로 유지")

	await _move_to(floorboard.position)
	await _interact()
	_assert(not _progress.diary_opened,
		"열쇠+나무패 모두 있어도 4단계 전에는 아직 안 열림 (실제: stage=%d)" % _progress.stage)

	# 순환 3회 -> 4단계, 이제 열림.
	_progress.advance_cycle()
	await process_frame
	_assert(_progress.stage == 4, "순환 3회 후 4단계, 실제: %d" % _progress.stage)

	# MAX_STAGE(4)를 넘어서까지 순환을 더 시도해도 5, 6...으로 안 올라가고
	# 4에서 멈추는지 확인 (chapter1_progress.gd의 상한 체크).
	_progress.advance_cycle()
	_progress.advance_cycle()
	_assert(_progress.stage == 4, "MAX_STAGE를 넘겨 호출해도 4에서 멈춤, 실제: %d" % _progress.stage)

	var wall_mark: Node2D = current_scene.get_node("WallMarkFlash")
	_assert(not wall_mark.visible, "일기 개봉 전에는 벽 낙서가 숨겨져 있음")

	await _move_to(floorboard.position)
	# 첫 입력만 따로 보낸다 — floorboard._open_diary()가 대화를 시작하며
	# wall_mark_flash.gd의 flash()를 동기적으로 호출해 visible=true를
	# 세팅한 직후(진짜 사라지는 건 flash_seconds 뒤라 타이밍에 안전하게
	# 검증 가능한 시점) 상태를 확인한 다음, 나머지 대화는 _interact()로
	# 마저 닫는다.
	await _send_action("ui_accept")
	_assert(wall_mark.visible, "일기 개봉 시퀀스 시작과 동시에 벽 낙서가 flash()됨")
	await _interact()
	_assert(_progress.diary_opened, "4단계 + 열쇠 + 나무패 모두 갖춘 뒤 판자 조사하면 일기 개봉됨")
	await process_frame
	_assert(not key_slot.visible and not stamp_slot.visible,
		"일기 개봉(아이템 소진) 후 인벤토리 슬롯이 둘 다 사라짐")

	# 일기 개봉(대화 종료) 자체가 각성(챕터 종료)을 유발해야 한다
	# (DESIGN.md §8.1 "트리거" 항목) — WakeTrigger를 따로 안 걸어가도
	# 자동으로 Chapter1End로 전환되는지 확인.
	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"일기 개봉 후 자동으로 챕터 종료 화면(Chapter1End)으로 전환됨, 실제: %s" %
			[current_scene.name if current_scene else "null"])

	# diary_opened == true 상태에서 챕터 1을 다시 열어 판자를 재조사해도
	# (Chapter1Progress는 오토로드라 값이 그대로 유지됨) 재오픈 로직이
	# 다시 실행되거나 크래시하지 않고 "다시 읽기" 대사만 뜨는지 확인.
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	for i in range(10):
		await process_frame
	_player = get_first_node_in_group("player")
	var floorboard_again: Node2D = current_scene.get_node("Floorboard")
	await _move_to(floorboard_again.position)
	await _interact()
	_assert(_progress.diary_opened, "일기 개봉 후 다시 조사해도 상태 유지, 크래시 없음")

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


func _move_to(target: Vector2) -> void:
	while not _player.position.is_equal_approx(target):
		var dir := Vector2.ZERO
		var diff := target - _player.position
		if absf(diff.x) > 0.01:
			dir = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
		elif absf(diff.y) > 0.01:
			dir = Vector2.DOWN if diff.y > 0 else Vector2.UP
		else:
			break
		var action := "ui_right"
		if dir == Vector2.LEFT:
			action = "ui_left"
		elif dir == Vector2.DOWN:
			action = "ui_down"
		elif dir == Vector2.UP:
			action = "ui_up"
		await _move_one_tile(action)


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


func _interact() -> void:
	await _send_action("ui_accept")
	# 대화가 열렸다면 한 줄씩 넘겨서 닫는다 (다음 상호작용을 막지 않도록).
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var guard := 0
	while dialogue and dialogue.is_active() and guard < 20:
		await _send_action("ui_accept")
		guard += 1
	# 대화가 끝나며 아이템 획득 팝업이 떴다면(hopscotch_key.gd/jar_stamp.gd
	# 참고) 그것도 닫아야 다음 이동/상호작용이 막히지 않는다.
	var popup: Node = root.get_node_or_null("ItemPopup")
	if popup and popup.is_active():
		await _send_action("ui_accept")


## _interact()와 같지만, 대화가 끝난 뒤 뜨는 아이템 팝업의 내용(이름)까지
## 확인하고 닫는다. 첫 발견 시에만 팝업이 뜨므로 재조사 검증에는 안 쓴다.
func _interact_expect_item(expected_name: String) -> void:
	await _send_action("ui_accept")
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var guard := 0
	while dialogue and dialogue.is_active() and guard < 20:
		await _send_action("ui_accept")
		guard += 1
	var popup: Node = root.get_node_or_null("ItemPopup")
	_assert(popup != null and popup.is_active(),
		"'%s' 획득 시 아이템 팝업이 뜸" % expected_name)
	if popup and popup.is_active():
		var label: Label = popup.get_node("Panel/Label")
		_assert(label.text == expected_name,
			"팝업에 표시된 이름이 '%s', 실제: '%s'" % [expected_name, label.text])
		await _send_action("ui_accept")
		_assert(not popup.is_active(), "Enter 입력으로 팝업이 닫힘")


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
