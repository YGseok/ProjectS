# assets/sprites/characters/bonus_pack/

`assets/Bonus.rar`(원래 `Bonus/Characters/`)에서 2026-09-04에 압축 해제해
정리함. 관련 오브젝트(문, 시계)는 [assets/props/bonus_pack/](../../props/bonus_pack/)
에 있음.

| 파일 | 크기(px) | 내용 |
|---|---|---|
| `Bonus.png` | 400×208 | 잡다한 보너스 스프라이트 모음(균일한 격자 아님) — 문 3종(빨강/보라+창/초록), 여자아이 캐릭터 3종(양갈래머리 소녀 2, 멜빵바지 소녀 1), 몬스터/크리처 2종(거미형, 작고 둥근 것) |
| `Cute_Yui.png` | 98×266 | 이름 붙은 캐릭터 하나("Yui") — 동물 귀 달린 후드를 쓴 아이, 3열×4행(대략 33×67px 칸) 걷기 프레임 시트(행: 아래/왼쪽/오른쪽/위 추정). 각 행 가운데(정지) 프레임만 잘라서 `assets/sprites/characters/player_placeholder/`로 옮겨 실제 Player에 적용함(2026-09-15) — 오른쪽은 왼쪽 프레임을 그대로 `flip_h`해서 만들었으므로 시트 3번째 행은 실제로는 쓰지 않음 |
| `femaleIdle.png` | 192×64 | 분홍/빨강 곱슬머리 여자아이, 3프레임(64×64씩) 대기(idle) 애니메이션 |

## 라이선스

`assets/tiles/main/`(AnisAous 팩)과 같은 출처에서 받은 보너스 자료로 확인됨
(사람 확인, 2026-09-04) — 동일한 라이선스 적용:
[assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt](../../THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt)
(개인 용도 무료, 상업적 사용은 $4.50 이상 후원 필요, 수정 가능, 팩 자체
재판매/재배포 금지).

## 주의

- `Cute_Yui.png`는 2026-09-15부터 파생물(`player_placeholder/`)을 통해
  실제 Player에 연결됨 — 단, 캐릭터 디자인은 DESIGN.md의 최종 주인공
  디자인(흰 원피스, 10살 전후 한국인 여아)과 다르므로 어디까지나
  "기능부터 만들고 내용은 나중에" 방침에 따른 placeholder다(사람 확인,
  2026-09-15). 최종 디자인이 정해지면
  [player_placeholder/README.md](../player_placeholder/README.md)의
  3개 파일만 교체하면 된다. `Bonus.png`/`femaleIdle.png`는 여전히
  미사용 — 필요해지면 검토.
