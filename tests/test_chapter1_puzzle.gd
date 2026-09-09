extends SceneTree
## 자동 상호작용 테스트 — 챕터 1 메인 퍼즐 "닫힌 일기장"(DESIGN.md §8.1,
## 2026-09-07 확정; 구조 2026-09-09 갱신)의 진행을 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_chapter1_puzzle.gd --path <project>
##
## 2026-09-09부터 퍼즐이 "순환(낮잠↔각성)마다 하나씩"이 아니라 "꿈 방문
## 한 번 안에서 전부"로 바뀌면서, 오브젝트들도 chapter1_real에서
## chapter1_dream으로 옮겨갔고 더 이상 단계별로 등장/사라지지 않는다 —
## 그래서 이 테스트도 chapter1_dream.tscn을 직접 로드하고, advance_cycle()
## 시뮬레이션 없이 열쇠/나무패를 자유 순서로 모으는 흐름을 검증한다.

var _player: Node2D
var _progress: Node
var _all_passed := true

func _initialize() -> void:
	# 이 테스트는 퍼즐 자체를 검증하는 게 목적이라, 첫 방문 때 자동으로
	# 뜨는 "1장 시작" 타이틀 카드(chapter_title_card.gd, 2026-09-09)가
	# 이동을 막아 방해하지 않도록 미리 "이미 봤다"로 처리해둔다 — 타이틀
	# 카드 자체는 tests/test_chapter_title_card.gd가 따로 검증한다.
	root.get_node("Chapter1Progress").chapter_started = true

	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_progress = root.get_node_or_null("Chapter1Progress")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_progress != null, "Chapter1Progress 오토로드 노드를 /root 에서 찾음")
	if _player == null or _progress == null:
		_finish()
		return

	var floorboard: Node2D = current_scene.get_node("Floorboard")
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	var jar: Node2D = current_scene.get_node("JarStamp")
	var key_slot: Control = current_scene.get_node("InventoryUI/KeySlot")
	var stamp_slot: Control = current_scene.get_node("InventoryUI/StampSlot")
	var hint_label: Label = current_scene.get_node("ObjectiveHint/Label")

	# 오브젝트들의 _process()가 한 번 이상 돌 시간을 준다(씬 로드 직후
	# 2프레임만으로는 부족할 때가 있었음 — visible 갱신은 _process에서 일어남).
	for i in range(10):
		await process_frame
	_assert(hopscotch.visible, "사방치기(열쇠)는 꿈 방문 즉시부터 보임(더 이상 단계 게이팅 없음)")
	_assert(jar.visible, "장독(나무패)도 꿈 방문 즉시부터 보임(더 이상 단계 게이팅 없음)")
	_assert(not key_slot.visible and not stamp_slot.visible,
		"아이템 획득 전에는 인벤토리 UI 슬롯이 둘 다 숨겨져 있음")
	_assert(hint_label.text != "", "초기 목표 힌트가 비어있지 않음, 실제: '%s'" % hint_label.text)

	# 판자로 이동해서 조사 — 아직 잠겨있다는 대사만 뜨고 상태 변화 없음.
	await _move_to(floorboard.position)
	# 상호작용 프롬프트("Enter: 살펴보기")가 실제로 보이는지도 확인한다 —
	# InteractableBase._player 조회가 씬 트리 노드 순서에 우연히 의존하게
	# 되면(예: 이 오브젝트가 Player보다 먼저 _ready()되는 순서로 바뀌면)
	# 상호작용 자체는 되더라도 프롬프트 라벨만 영원히 안 뜨는 회귀가 생긴
	# 적이 있다(chapter1_real.tscn z-order 수정 중 발견, STATUS.md 참고).
	var floorboard_prompt: Label = floorboard.get_node("PromptLabel")
	_assert(floorboard_prompt.visible, "판자 옆에 있으면 상호작용 프롬프트가 보임")
	# 대화가 열려 있는 동안은 목표 힌트를 숨겨야 한다 — 대화창(화면 하단)과
	# 힌트 라벨(마찬가지로 화면 하단) 위치가 겹쳐서, 숨기지 않으면 대화창
	# 밑으로 힌트 텍스트 한 조각이 삐져나와 보이는 시각 버그가 있었다
	# (실제 창 캡처로 발견, 2026-09-08).
	await _send_action("ui_accept")
	_assert(not hint_label.visible, "대화가 열려 있는 동안은 목표 힌트가 숨겨짐")
	await _interact()
	_assert(hint_label.visible, "대화가 닫히면 목표 힌트가 다시 보임")
	_assert(not _progress.has_key and not _progress.has_stamp,
		"아직 아무것도 못 모은 상태에서 판자 조사해도 열쇠/나무패 상태 변화 없음")

	var hint_before_key := hint_label.text
	await _move_to(hopscotch.position)
	await _interact_expect_item("열쇠")
	_assert(_progress.has_key, "사방치기 조사 후 열쇠 획득")
	await process_frame
	_assert(key_slot.visible and not stamp_slot.visible,
		"열쇠 획득 후 인벤토리에 열쇠 슬롯만 보임")
	_assert(hint_label.text != hint_before_key,
		"열쇠 획득 후 목표 힌트가 바뀜, 실제: '%s'" % hint_label.text)

	# 이미 파낸 뒤 다시 조사해도 크래시 없이 "이미 비어있다" 분기만 타고
	# 상태는 그대로 유지되는지 확인 (hopscotch_key.gd의 has_key 분기).
	await _interact()
	_assert(_progress.has_key, "사방치기를 다시 조사해도 열쇠 상태는 그대로 유지")

	await _move_to(floorboard.position)
	await _interact()
	_assert(not _progress.diary_opened, "열쇠만 있고 나무패 없으면 아직 안 열림")

	await _move_to(jar.position)
	await _interact_expect_item("나무패")
	_assert(_progress.has_stamp, "장독 조사 후 나무패 획득")
	await process_frame
	_assert(key_slot.visible and stamp_slot.visible,
		"나무패까지 획득하면 인벤토리에 두 슬롯 다 보임")

	# 장독도 마찬가지로 재조사 시 안전한지 확인 (jar_stamp.gd의
	# has_stamp 분기).
	await _interact()
	_assert(_progress.has_stamp, "장독을 다시 조사해도 나무패 상태는 그대로 유지")

	var wall_mark: Node2D = current_scene.get_node("WallMarkFlash")
	_assert(not wall_mark.visible, "일기 개봉 전에는 벽 낙서가 숨겨져 있음")

	await _move_to(floorboard.position)
	# 첫 입력만 따로 보낸다 — floorboard._open_diary()가 대화를 시작하며
	# wall_mark_flash.gd의 flash()를 동기적으로 호출해 visible=true를
	# 세팅한 직후(진짜 사라지는 건 flash_seconds 뒤라 타이밍에 안전하게
	# 검증 가능한 시점) 상태를 확인한 다음, 나머지 대화는 _interact()로
	# 마저 닫는다. 2026-09-09부터는 열쇠+나무패만 있으면(더 이상 순환
	# 단계를 기다릴 필요 없이) 곧바로 열린다.
	await _send_action("ui_accept")
	_assert(wall_mark.visible, "열쇠+나무패를 모두 갖춘 뒤 판자를 조사하면 곧바로 일기 개봉 시퀀스가 시작되며 벽 낙서가 flash()됨")

	# flash_seconds(기본 0.2초)가 지나면 다시 숨어야 한다 — "딱 한 번만
	# 스치듯" 요구사항의 나머지 절반(사라지는 쪽)은 지금까지 타이밍
	# 문제로 테스트한 적이 없었다. 팝업/힌트 애니메이션 테스트에서 쓴 것과
	# 같은 방식(create_timer로 충분히 기다린 뒤 확인)으로 안전하게 검증.
	await create_timer(0.35).timeout
	_assert(not wall_mark.visible, "flash_seconds가 지나면 벽 낙서가 다시 숨겨짐")

	await _interact()
	_assert(_progress.diary_opened, "열쇠 + 나무패 모두 갖춘 뒤 판자 조사하면 일기 개봉됨")
	await process_frame
	_assert(not key_slot.visible and not stamp_slot.visible,
		"일기 개봉(아이템 소진) 후 인벤토리 슬롯이 둘 다 사라짐")
	_assert(hint_label.text == "", "일기 개봉 후 목표 힌트가 비워짐(더 할 일 없음)")

	# 일기 개봉(대화 종료) 자체가 각성(챕터 종료 = 탈출)을 유발해야 한다
	# (DESIGN.md §8.1 "트리거" 항목) — 2026-09-09부터 이 꿈에는 별도의
	# "깨어나기" 트리거가 아예 없으므로, 일기 개봉이 유일한 탈출 경로다.
	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"일기 개봉 후 자동으로 챕터 종료 화면(Chapter1End)으로 전환됨, 실제: %s" %
			[current_scene.name if current_scene else "null"])

	# diary_opened == true 상태에서 꿈을 다시 열어 판자를 재조사해도
	# (Chapter1Progress는 오토로드라 값이 그대로 유지됨) 재오픈 로직이
	# 다시 실행되거나 크래시하지 않고 "다시 읽기" 대사만 뜨는지 확인.
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
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


## target까지 이동한다. target 자체가 오브젝트 콜리전으로 막혀 있을 수
## 있으므로(2026-09-09, NPC/대화 오브젝트 충돌 추가), 정확히 그 칸에
## 못 들어가면(진행 없음) 인접 칸에서 멈춘다 — interact_radius가 그 거리를
## 커버하도록 이미 늘어나 있음. x축이 막혀 있으면 y축으로 우회를 시도해서
## (그리고 그 반대도) 다른 오브젝트 하나 때문에 목표 근처에 못 가는 경우를
## 피한다.
func _move_to(target: Vector2) -> void:
	var guard := 0
	while not _player.position.is_equal_approx(target) and guard < 100:
		guard += 1
		var diff := target - _player.position
		var x_action := ""
		var y_action := ""
		if absf(diff.x) > 0.01:
			x_action = "ui_right" if diff.x > 0 else "ui_left"
		if absf(diff.y) > 0.01:
			y_action = "ui_down" if diff.y > 0 else "ui_up"
		if x_action == "" and y_action == "":
			break
		var before := _player.position
		if x_action != "":
			await _move_one_tile(x_action)
		if _player.position.is_equal_approx(before) and y_action != "":
			await _move_one_tile(y_action)
		if _player.position.is_equal_approx(before):
			break


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
