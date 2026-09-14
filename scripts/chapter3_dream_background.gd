extends TileMapLayer
## 챕터 3 꿈 배경 — 호수 배경(placeholder, DESIGN.md §11.3). 집이 아니라
## 야외 호숫가라 다른 챕터들과 달리 잔디만 깔고 끝난다. 호수 자체는
## `chapter3_dream.tscn`의 `LakeWater`(파란 ColorRect) 오버레이로
## 표현한다 — 현재 타일 자산(assets/tiles/main/)에는 물 타일이 없어서
## (A5.png 확인 완료) 그레이박스 정책에 맞춘 임시 표현.

const GRASS := Vector2i(0, 8)

func _ready() -> void:
	_fill_rect(0, 40, 0, 23, 1, GRASS)


func _fill_rect(c0: int, c1: int, r0: int, r1: int, source_id: int, atlas: Vector2i) -> void:
	for c in range(c0, c1):
		for r in range(r0, r1):
			set_cell(Vector2i(c, r), source_id, atlas)
