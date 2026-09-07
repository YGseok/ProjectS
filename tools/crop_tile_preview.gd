extends SceneTree
## 일회성 도구 — A4/A5 시트를 2배 확대하고 48px(원본 기준) 격자선을 그려서
## 특정 타일의 (col,row) 좌표를 눈으로 셀 수 있게 만든다.

const CELL := 48
const SCALE := 2

func _initialize() -> void:
	_make_grid("res://assets/tiles/main/A4.png", "res://tools/tile_preview_A4_grid.png")
	_make_grid("res://assets/tiles/main/A5.png", "res://tools/tile_preview_A5_grid.png")
	quit(0)


func _make_grid(src_path: String, out_path: String) -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(src_path))
	img.resize(img.get_width() * SCALE, img.get_height() * SCALE, Image.INTERPOLATE_NEAREST)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var line := Color(1, 0, 1, 0.9)
	var step := CELL * SCALE
	var x := 0
	while x < w:
		for y in range(h):
			img.set_pixel(x, y, line)
		x += step
	var y2 := 0
	while y2 < h:
		for x2 in range(w):
			img.set_pixel(x2, y2, line)
		y2 += step
	img.save_png(out_path)
	print("saved: %s (%dx%d)" % [out_path, w, h])
