extends TileMapLayer
## 챕터 1 현실 배경 — assets/tiles/main/main_tileset.tres 타일로 채운다.
## 좌표는 기존 그레이박스 ColorRect들과 동일한 위치를 32px 그리드로 옮긴 것
## (scenes/chapter1_real.tscn 참고). source 0 = A4(벽), source 1 = A5(바닥/지면).
##
## 주의: 여기서는 TileData.modulate를 절대 건드리지 않는다. 벽/지붕이
## 같은 atlas 타일(WALL)을 공유하는데, TileData는 (source_id, atlas_coords)
## 별로 하나만 존재해서 modulate를 바꾸면 그 타일을 쓰는 셀 전부(같은 씬
## 안에서도, 심지어 main_tileset.tres를 공유하는 다른 씬에서도)에 영향을
## 준다 — 실제로 이 때문에 지붕/벽 색 구분이 전혀 작동 안 했고, 꿈 씬에서
## 돌아왔을 때 배경이 안 돌아오는 버그가 있었다(2026-09-07, 사람이 플레이
## 하다 발견). 구역별 색은 대신 chapter1_real.tscn에 있는 반투명
## ColorRect 오버레이로 표현한다.

const GRASS := Vector2i(0, 8)
const DIRT := Vector2i(1, 8)
const WOOD_LIGHT := Vector2i(0, 5)
const WOOD_MED := Vector2i(1, 5)
const WALL := Vector2i(2, 10)

func _ready() -> void:
	# 마당(잔디) 전체
	_fill_rect(0, 40, 0, 23, 1, GRASS)

	# 기와집 벽 (x160-1120, y0-128 -> col5-34, row0-3)
	_fill_rect(5, 35, 0, 4, 0, WALL)

	# 툇마루 (x160-1120, y128-192 -> col5-34, row4-5)
	_fill_rect(5, 35, 4, 6, 1, WOOD_LIGHT)

	# 밭 (x192-576, y288-608 -> col6-17, row9-18)
	_fill_rect(6, 18, 9, 19, 1, DIRT)

	# 원두막 지붕 (x832-1120, y352-416 -> col26-34, row11-12) — 벽과 같은
	# 타일. 밝은 톤 구분은 chapter1_real.tscn의 RoofTint 오버레이가 담당.
	_fill_rect(26, 35, 11, 13, 0, WALL)

	# 원두막 바닥 (x864-1088, y384-576 -> col27-33, row12-17)
	_fill_rect(27, 34, 12, 18, 1, WOOD_MED)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, source_id: int, atlas: Vector2i) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			set_cell(Vector2i(c, r), source_id, atlas)
