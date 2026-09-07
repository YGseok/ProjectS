# assets/props/main_tileset_props/ — 실내 가구 시트에서 뽑은 소품

`assets/tiles/main/Inside_C_2.png`(가구/장식 시트, 48px 격자)에서 손으로
잘라낸 개별 스프라이트. `tools/crop_props_from_inside_c2.gd`로 생성했고,
좌표를 더 다듬거나 다른 오브젝트를 추가하려면 그 스크립트의 `_crops`
딕셔너리에 `이름: Rect2i(x, y, w, h)`를 추가하고 재실행.

챕터 1 메인 퍼즐 "닫힌 일기장"(DESIGN.md §7.1)의 오브젝트 아트를
`ColorRect` 그레이박스에서 교체하려고 만들었다 — `scripts/jar_stamp.gd`,
`scripts/gonggi_stones.gd` 참고.

## 라이선스

`assets/tiles/main/`(AnisAous 팩)의 일부이므로 동일 라이선스 적용:
[assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt](../../THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt)
(개인 용도 무료, 상업적 사용은 $4.50 이상 후원 필요).

## 파일

| 파일 | 원본 좌표 (Inside_C_2.png 기준) | 크기(px) | 설명 | 용도 |
|---|---|---|---|---|
| `jar.png` | `Rect2i(576, 384, 48, 48)` | 48×48 | 어두운 적갈색 둥근 항아리 | 장독대 (`jar_stamp.gd`) |
| `gonggi_stone.png` | `Rect2i(0, 432, 48, 48)` | 48×48 | 회갈색 조약돌 | 공기돌 (`gonggi_stones.gd`) — 실제로는 다섯 알이지만 이 시트엔 한 개짜리 조약돌만 있어서 이 한 장으로 "공기돌 더미"를 대표시킴 |

## 못 찾은 것

- **마루 판자(floorboard)**: 이 시트/`main_tileset.tres` 어디에도 한국식
  마루 밑 들뜬 판자에 맞는 소재가 없어서 `ColorRect` 그레이박스 유지.
- **사방치기(hopscotch)**: 흙바닥에 그린 사방치기 칸은 RPG Maker 실내
  가구 팩에 있을 리가 없는 소재라 애초에 찾지 않음 — `ColorRect`로 칸
  윤곽만 표현.

실제 스프라이트가 필요해지면 별도 제작이나 다른 팩을 구해야 한다.
