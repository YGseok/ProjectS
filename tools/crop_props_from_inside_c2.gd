extends SceneTree
## 일회성 도구 — Inside_C_2.png(가구/장식 시트, 48px 격자)에서 챕터 1
## 메인 퍼즐 오브젝트(장독/공기돌)용 스프라이트를 잘라
## assets/props/main_tileset_props/ 에 저장. 좌표는 눈대중 추정 후 결과를
## 보고 조정하는 방식으로 확정했다 (crop_outside_props.gd와 같은 패턴).
##
## 판자(floorboard)/사방치기(hopscotch)는 이 시트에 어울리는 것이 없어서
## (RPG Maker 실내 가구 팩이라 한국식 마루 판자·흙바닥 사방치기 칸과 안
## 맞음) ColorRect 그레이박스로 남겨뒀다 — STATUS.md 참고.

const SRC := "res://assets/tiles/main/Inside_C_2.png"
const OUT_DIR := "res://assets/props/main_tileset_props/"

# name -> Rect2i(x, y, w, h), 48px 격자 기준
var _crops := {
	"jar": Rect2i(576, 384, 48, 48),
	"gonggi_stone": Rect2i(0, 432, 48, 48),
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
