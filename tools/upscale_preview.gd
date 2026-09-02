extends SceneTree
## 일회성 도구 — 작은 도트 스프라이트를 컨펌용으로 확대(최근접 보간) 저장.
## 실행: godot4 --headless --script res://tools/upscale_preview.gd --path <project> -- <src> <dst> <scale>

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var src: String = args[0]
	var dst: String = args[1]
	var scale: int = int(args[2])

	var img := Image.load_from_file(ProjectSettings.globalize_path(src))
	img.resize(img.get_width() * scale, img.get_height() * scale, Image.INTERPOLATE_NEAREST)
	img.save_png(dst)
	print("[PREVIEW] 저장 완료: %s" % dst)
	quit(0)
