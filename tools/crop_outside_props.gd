extends SceneTree
## 일회성 도구 — Outside.png(불규칙 크기 자연 오브젝트 시트)에서 개별
## 스프라이트를 손으로 지정한 사각형으로 잘라 assets/props/nature/ 에 저장.
## 좌표는 눈대중 추정 후 결과를 보고 조정하는 방식으로 확정한다.

const SRC := "res://assets/tiles/main/Outside.png"
const OUT_DIR := "res://assets/props/nature/"

# name -> Rect2i(x, y, w, h)
var _crops := {
	"tree_green": Rect2i(5, 5, 140, 215),
	"bush_berry": Rect2i(5, 250, 140, 170),
	"tree_small": Rect2i(170, 255, 150, 165),
}

func _initialize() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for key in _crops.keys():
		var rect: Rect2i = _crops[key]
		var cropped := img.get_region(rect)
		cropped.save_png(OUT_DIR + key + ".png")
		print("saved %s%s.png (%dx%d)" % [OUT_DIR, key, cropped.get_width(), cropped.get_height()])
	quit(0)
