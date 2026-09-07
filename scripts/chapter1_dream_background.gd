extends TileMapLayer
## 챕터 1 꿈 배경 — chapter1_real_background.gd와 동일한 타일을 재사용하되,
## 구역별로 modulate(색 틴트)를 다르게 줘서 "같은 공간, 다른 분위기"
## (DESIGN.md §4)를 표현한다. 특히 밭은 빨갛게 틴트해서 피마자밭 느낌을 낸다.

const GRASS := Vector2i(0, 8)
const DIRT := Vector2i(1, 8)
const WOOD_LIGHT := Vector2i(0, 5)
const WOOD_MED := Vector2i(1, 5)
const WALL := Vector2i(2, 10)

const TINT_GROUND := Color(0.5, 0.45, 0.55, 1)
const TINT_WALL := Color(0.6, 0.5, 0.5, 1)
const TINT_PORCH := Color(0.75, 0.65, 0.6, 1)
const TINT_FIELD := Color(1.4, 0.3, 0.35, 1)
const TINT_ROOF := Color(0.7, 0.45, 0.4, 1)
const TINT_GAZEBO_FLOOR := Color(0.8, 0.75, 0.7, 1)

func _ready() -> void:
	# 마당(잔디) 전체
	_fill_rect(0, 40, 0, 23, 1, GRASS, TINT_GROUND)

	# 기와집 벽
	_fill_rect(5, 35, 0, 4, 0, WALL, TINT_WALL)

	# 툇마루
	_fill_rect(5, 35, 4, 6, 1, WOOD_LIGHT, TINT_PORCH)

	# 밭 (피마자밭 — 강하게 붉은 틴트)
	_fill_rect(6, 18, 9, 19, 1, DIRT, TINT_FIELD)

	# 원두막 지붕
	_fill_rect(26, 35, 11, 13, 0, WALL, TINT_ROOF)

	# 원두막 바닥
	_fill_rect(27, 34, 12, 18, 1, WOOD_MED, TINT_GAZEBO_FLOOR)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, source_id: int, atlas: Vector2i, tint: Color) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			var coords := Vector2i(c, r)
			set_cell(coords, source_id, atlas)
			var data := get_cell_tile_data(coords)
			if data:
				data.modulate = tint
