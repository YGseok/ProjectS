extends Node
## QA 시각 확인 도구 (부트스트랩 스크립트).
##
## 사용법: qa/run_qa.sh 를 통해 실행하는 것을 전제로 하지만,
## 직접 실행하려면 아래처럼 호출한다.
##
##   GAME_START=dungeon godot4 --path . res://qa/QACapture.tscn
##
## 동작:
##   1) GAME_START 환경변수로 지정된 씬을 res://scenes/<key>.tscn 규칙으로 로드
##      (QA_SCENE_PATH 가 지정되면 그것을 그대로 사용, 규칙 무시)
##   2) QA_FRAME(기본 30) 프레임만큼 실제로 process_frame을 기다림
##      (애니메이션/레이아웃/조명이 안정화될 시간을 준다)
##   3) 뷰포트를 텍스처로 읽어 PNG로 저장 (QA_OUTPUT 경로, 기본 qa/output/<key>.png)
##   4) 성공 시 exit 0, 실패 시 exit 1 로 즉시 종료
##
## 반드시 실제 창을 띄운 상태(헤드리스 아님, 필요하면 Xvfb 가상 디스플레이)로
## 실행해야 뷰포트가 실제로 렌더링된 결과를 캡처한다. 자세한 내용은
## qa/README.md 참고.

func _ready() -> void:
	var exit_code := await _run()
	get_tree().quit(exit_code)


func _run() -> int:
	var start_key := OS.get_environment("GAME_START")
	if start_key.is_empty():
		push_error("[QA] GAME_START 환경변수가 지정되지 않았습니다. 예: GAME_START=dungeon")
		return 1

	var target_frame := 30
	var frame_str := OS.get_environment("QA_FRAME")
	if not frame_str.is_empty():
		if not frame_str.is_valid_int():
			push_error("[QA] QA_FRAME 값이 정수가 아닙니다: %s" % frame_str)
			return 1
		target_frame = frame_str.to_int()
		if target_frame < 0:
			push_error("[QA] QA_FRAME 은 0 이상이어야 합니다: %d" % target_frame)
			return 1

	var scene_path := OS.get_environment("QA_SCENE_PATH")
	if scene_path.is_empty():
		scene_path = "res://scenes/%s.tscn" % start_key

	if not ResourceLoader.exists(scene_path):
		push_error("[QA] 씬을 찾을 수 없습니다: %s (GAME_START=%s)" % [scene_path, start_key])
		return 1

	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("[QA] 씬 로드 실패: %s" % scene_path)
		return 1

	var instance := packed.instantiate()
	if instance == null:
		push_error("[QA] 씬 인스턴스화 실패: %s" % scene_path)
		return 1

	get_tree().root.add_child.call_deferred(instance)
	await get_tree().process_frame
	print("[QA] 씬 '%s' 로드 완료 (%s). %d 프레임 대기 후 캡처합니다." % [start_key, scene_path, target_frame])

	for i in range(target_frame):
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	if img == null:
		push_error("[QA] 뷰포트 이미지를 가져오지 못했습니다.")
		return 1

	var output_path := OS.get_environment("QA_OUTPUT")
	if output_path.is_empty():
		var out_dir := "res://qa/output"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
		output_path = "%s/%s.png" % [out_dir, start_key]

	var save_path := output_path
	if save_path.begins_with("res://") or save_path.begins_with("user://"):
		var dir_only := save_path.get_base_dir()
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_only))
	else:
		var abs_dir := save_path.get_base_dir()
		if not abs_dir.is_empty():
			DirAccess.make_dir_recursive_absolute(abs_dir)

	var err := img.save_png(save_path)
	if err != OK:
		push_error("[QA] PNG 저장 실패 (%d): %s" % [err, save_path])
		return 1

	print("[QA] 스크린샷 저장 완료: %s" % save_path)
	return 0
