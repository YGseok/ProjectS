# assets/props/nature/ — 자연 오브젝트 (마당 장식용)

`assets/tiles/main/Outside.png`(불규칙 크기 시트, 타일 격자 아님)에서
손으로 잘라낸 개별 스프라이트. `tools/crop_outside_props.gd`로 생성했고,
좌표를 더 다듬거나 다른 오브젝트를 추가하려면 그 스크립트의 `_crops`
딕셔너리에 `이름: Rect2i(x, y, w, h)`를 추가하고 재실행.

## 라이선스

`assets/tiles/main/`(AnisAous 팩)의 일부이므로 동일 라이선스 적용:
[assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt](../../THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt)
(개인 용도 무료, 상업적 사용은 $4.50 이상 후원 필요).

## 파일

| 파일 | 원본 좌표 (Outside.png 기준) | 크기(px) | 설명 |
|---|---|---|---|
| `tree_green.png` | `Rect2i(5, 5, 140, 215)` | 140×215 | 둥근 초록 수관의 큰 나무 |
| `bush_berry.png` | `Rect2i(5, 250, 140, 170)` | 140×170 | 붉은 열매가 달린 낮은 나무/덤불 |
| `tree_small.png` | `Rect2i(170, 255, 150, 165)` | 150×165 | 조금 더 작은 나무 |

## 배치 시 주의

- 게임 그리드는 32px지만 이 오브젝트들은 훨씬 크다 — 타일이 아니라
  일반 `Sprite2D`로 배치하고, 시각적으로 자연스러운 위치(마당 안, 다른
  요소와 안 겹치는 곳)에 좌표를 잡을 것.
- 현재 이동에는 충돌 처리가 없다(STATUS.md "이동 사양 확정" 참고) —
  나무를 심어도 플레이어가 그냥 통과해서 지나갈 수 있다. 나무를
  막히게 하고 싶으면 별도로 충돌 관련 지시가 필요하다.
