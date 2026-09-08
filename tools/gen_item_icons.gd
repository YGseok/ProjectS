extends SceneTree
## 일회성 도구 — 챕터 1 아이템 획득 팝업/인벤토리 UI용 자리표시 아이콘을
## 절차적으로 그려서 저장한다 (실제 아이콘 아트를 구하기 전까지의 임시
## 조치, 캐릭터 아트와 같은 정책). 32x32 단색 사각형 + 테두리 정도로만
## 구분한다 — 이후 실제 아이콘으로 교체 시 이 스크립트는 지워도 된다.

const OUT_DIR := "res://assets/props/ui_icons/"

# name -> [fill_color, border_color]
var _icons := {
	"key_icon": [Color(0.85, 0.75, 0.25), Color(0.4, 0.32, 0.05)],
	"stamp_icon": [Color(0.45, 0.3, 0.2), Color(0.2, 0.12, 0.06)],
}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for key in _icons.keys():
		var colors: Array = _icons[key]
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(colors[0])
		for x in range(32):
			for y in range(32):
				if x < 2 or x > 29 or y < 2 or y > 29:
					img.set_pixel(x, y, colors[1])
		img.save_png(OUT_DIR + key + ".png")
		print("saved %s%s.png" % [OUT_DIR, key])
	quit(0)
