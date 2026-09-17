# assets/sprites/characters/concept_art/

주인공 캐릭터 확정 디자인 원본 자료(2026-09-17, 사람 제공 — DESIGN.md
목표인 "흰 원피스를 입은 10살 전후 한국인 여아"에 맞는 첫 컨셉아트).

| 파일 | 내용 |
|---|---|
| `pc001_original.webp` | 사람이 제공한 원본 파일(1024×1024). 캐릭터 주변이 투명이 아니라 회색/흰색 체크무늬 배경이 실제 픽셀로 박혀 있는 상태였다(진짜 알파 투명이 아님 — 코너 픽셀 alpha=1.0 확인됨). |
| `pc001_down_full.png` | 위 원본에서 배경을 제거하고(코너 4곳에서 flood-fill로 체크무늬/흰 배경 영역만 투명 처리 — 절대값 임계치만으로는 배경 톤이 균일하지 않아 실패했고, 연결성 기반 flood-fill이 필요했음) 캐릭터 영역만 잘라낸 원본 해상도(362×773) 버전. 나중에 다른 방향(옆/뒤) 그림을 만들 때도 참고할 수 있도록 원본 해상도로 보관. |

`player_placeholder/player_down.png`는 이 `pc001_down_full.png`를 게임
캐릭터 크기(33×70, 기존 placeholder 스케일에 맞춤)로 축소한 것이다
(`Image.resize(..., INTERPOLATE_LANCZOS)`).

## 라이선스

사람이 직접 제공한 자체 제작(또는 확보) 자료 — 제3자 에셋 팩이 아니므로
`assets/THIRD_PARTY_LICENSES/`의 기존 라이선스와 무관하다. 출처/저작권
확인이 필요하면 사람에게 문의할 것.

## 주의

- 지금은 정면(아래) 방향 그림만 있다. 왼쪽/오른쪽/위(뒤) 방향은 아직
  없어서 `player_placeholder/`에서 정면 그림을 임시로 재사용 중이다 —
  `player_placeholder/README.md` 참고.
