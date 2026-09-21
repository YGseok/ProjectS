extends TileMapLayer
## 챕터 3 꿈 배경 — 호수 배경(placeholder, DESIGN.md §11.3). 집이 아니라
## 야외 호숫가라 다른 챕터들과 달리 잔디 위에 물 타일(WATER)만 채운다.

const GRASS := Vector2i(0, 0)
const WATER := Vector2i(2, 0)

func _ready() -> void:
	_fill_rect(0, 40, 0, 23, GRASS)
	# 호수 (x256-1024, y224-544 -> col8-31, row7-16)
	_fill_rect(8, 32, 7, 17, WATER)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, atlas: Vector2i) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			set_cell(Vector2i(c, r), 0, atlas)
