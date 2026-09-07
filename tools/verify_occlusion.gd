extends SceneTree
## 일회성 검증 스크립트 — 플레이어를 나무 캐노피 아래(밑둥 옆)로 이동시킨
## 뒤 화면을 캡처해서 오클루전 반투명 효과가 실제로 보이는지 확인한다.
## --headless로는 실제 렌더링 픽셀을 못 읽으므로 반드시 일반 모드로 실행.
##
## 실행: godot4 --path <project> --script res://tools/verify_occlusion.gd
## (주의: --script 플래그를 빼고 스크립트 경로만 위치 인자로 주면 조용히
## 아무 것도 안 하고 종료 코드 0으로 끝나버린다 — 반드시 --script 명시할 것)
##
## 참고: 창모드 실행 시 콘솔 stdout이 안정적으로 캡처되지 않는 경우가 있어서
## (윈도우 환경, 창이 포커스를 못 받을 때 등) res://qa/output/occlusion_log.txt
## 에도 동일 로그를 직접 남긴다.

var _log: FileAccess

func _log_line(msg: String) -> void:
	print(msg)
	if _log:
		_log.store_line(msg)
		_log.flush()

func _initialize() -> void:
	_log = FileAccess.open("res://qa/output/occlusion_log.txt", FileAccess.WRITE)
	_log_line(">>> verify_occlusion start")
	var tree := self
	tree.change_scene_to_file("res://scenes/chapter1_real.tscn")
	_log_line(">>> scene change requested")
	await tree.process_frame
	await tree.process_frame
	_log_line(">>> scene ready, current_scene=" + str(tree.current_scene))

	var player: Node2D = tree.get_first_node_in_group("player")
	_log_line(">>> player found: " + str(player))

	# (608,160) -> 오른쪽 3, 아래 7 -> (704,384): 나무 캐노피 한복판 부근
	for i in range(3):
		await _move_one_tile(player, "ui_right")
		_log_line("moved right %d pos=%s" % [i, player.position])
	for i in range(7):
		await _move_one_tile(player, "ui_down")
		_log_line("moved down %d pos=%s" % [i, player.position])

	for i in range(20):
		await tree.process_frame

	var img := tree.root.get_texture().get_image()
	var err := img.save_png("res://qa/output/occlusion_check.png")
	_log_line("save_png err=%s saved, player at %s" % [err, player.position])
	_log.close()
	tree.quit(0)


func _move_one_tile(player: Node2D, action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var start_guard := 0
	while not player._moving and start_guard < 10:
		await Engine.get_main_loop().process_frame
		start_guard += 1
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	var move_guard := 0
	while player._moving and move_guard < 60:
		await Engine.get_main_loop().process_frame
		move_guard += 1
