# assets/sprites/characters/player_placeholder/

`bonus_pack/Cute_Yui.png`(98×266, 3열×4행 걷기 프레임 시트)에서 각 방향의
가운데(정지) 프레임만 잘라낸 것. 실제 주인공 디자인(흰 원피스, 10살 전후
한국인 여아, DESIGN.md)과 다른 캐릭터다 — 2026-09-15 사람 확인("기능부터
만들고 내용은 나중에 붙인다")에 따라, 실제 스프라이트가 정해지기 전까지
`player.gd`의 방향별 텍스처 교체 **기능**을 실제 게임에서 검증하기 위한
placeholder로 붙였다. 최종 아트가 정해지면 이 폴더의 3개 파일만 교체하면
된다(코드 변경 불필요 — `player.gd`가 파일명을 고정 참조).

| 파일 | 크기(px) | 용도 |
|---|---|---|
| `player_down.png` | 33×67 | 아래(정면)를 볼 때 |
| `player_side.png` | 33×67 | 왼쪽을 볼 때. 오른쪽은 이 텍스처를 `flip_h`로 좌우 반전해서 재사용(시트 3행이 진짜 반전쌍인지 불확실해서, 직접 반전을 써서 좌우가 항상 대칭이 되도록 함) |
| `player_up.png` | 33×67 | 위(뒤)를 볼 때 |

## 라이선스

원본 `Cute_Yui.png`와 동일 —
[assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt](../../THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt)
(개인 용도 무료, 상업적 사용은 $4.50 이상 후원 필요, 수정 가능, 팩 자체
재판매/재배포 금지). 이 폴더의 파일들은 원본에서 잘라낸 파생물이다.
