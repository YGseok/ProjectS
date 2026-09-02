# STATUS.md — 현재 상태 / 인수인계 문서

이 문서는 매 루프 이터레이션이 끝날 때 **다음 세션(기억 없음)에게 남기는 인수인계서**다.
새 이터레이션은 작업 시작 전 이 문서를 가장 먼저 읽는다.
갱신할 때는 아래 세 섹션을 모두 최신 상태로 다시 쓴다 — 과거 기록은
"완료 기록"으로 옮기고, 지금 섹션은 항상 "현재"만 반영한다.

---

## 1. 지금 위치 (현재 상태 요약)

- `res://scenes/chapter1_real.tscn` / `chapter1_dream.tscn` — 챕터 1의
  현실·꿈 그레이박스 두 씬 모두 완성. 기와집 벽/툇마루/밭/원두막을 동일한
  좌표에 배치하되, 꿈 씬은 전체 톤을 어둡게, 밭을 초록(밭)→붉은색
  (피마자밭)으로 바꿔 "같은 공간, 다른 분위기"(DESIGN.md §3)를 표현.
  실제 픽셀아트는 아직 없음 (의도적 플레이스홀더).
- `res://scripts/player.gd` — 그리드 단위 4방향 이동 스크립트
  (DESIGN.md §4: 키보드 방향키 전용, 타일 단위 이동, 자유이동 아님).
  `add_to_group("player")` 로 상호작용 트리거가 플레이어를 찾을 수 있게 함.
- **낮잠→꿈 전환 구현 완료**:
  - `res://scenes/common/InteractTrigger.tscn` + `scripts/nap_trigger.gd` —
    플레이어가 근처(반경 24px)에서 상호작용키(Enter/Space, `ui_accept`)를
    누르면 페이드 후 다른 씬으로 전환하는 재사용 컴포넌트.
  - `res://scenes/common/FadeOverlay.tscn` + `scripts/fade_overlay.gd` —
    씬 시작 시 검은 화면에서 밝아지고, 전환 시 어두워진 뒤 다음 씬 로드.
  - `chapter1_real.tscn`의 툇마루에 `NapTrigger` 배치 (프롬프트 "Enter: 낮잠")
    → `chapter1_dream.tscn` 으로 전환.
  - `chapter1_dream.tscn`의 같은 위치에 `WakeTrigger` 배치 (프롬프트
    "Enter: 깨어나기 (임시)") → `chapter1_real.tscn` 으로 되돌아옴.
    **주의**: 이건 왕복 테스트용 임시 트리거다. DESIGN.md §3(5)/§6.1에 따르면
    진짜 각성은 "메인 퍼즐(단서 5종 수집) 해결"로 트리거돼야 하며, 단서
    수집 시스템이 구현되면 이 임시 WakeTrigger는 제거/교체해야 한다.
- `project.godot`의 `run/main_scene` 을 `dungeon.tscn`(QA 데모용
  플레이스홀더, 그대로 보존)에서 `chapter1_real.tscn` 으로 변경함.
- 아직 없음: 메인 퍼즐 단서 수집 시스템(DESIGN.md §6.1, 다음 작업),
  실제 픽셀아트 에셋, 사운드.
- QA 캡처 확인 완료: `GAME_START=chapter1_real` / `chapter1_dream` 둘 다
  `./qa/run_qa.sh` → exit 0, 두 PNG 모두 육안 확인함 (이 세션에서).
  낮잠/각성 트리거(Enter 키 → 페이드 → 씬 전환, 왕복)도 사람이 직접
  플레이해서 정상 동작 확인함(2026-09-01).
- **주인공 캐릭터 디자인 진행 중**: `tools/gen_player_sprite.gd` (헤드리스
  Godot 스크립트로 도트 스프라이트를 절차적으로 그려 PNG 저장, 확정 전
  반복 검토용)로 `assets/sprites/player_draft_v1~v7.png` 초안 제작.
  v7까지 진행했고 아직 최종 컨펌 전 (2026-09-02 기준 진행 중, 등신비/
  얼굴·드레스 형태 피드백 반영 중). **최종 컨펌 전까지 이 초안들을 실제
  게임 스프라이트로 연결하지 말 것.**
- **테스트용 외부 에셋 팩 반입**(2026-09-02): `STEP/Elf_Girl_Character_and_
  Interior_Pack_DEMO.zip` (라이선스: 상업적 사용/수정 가능, 재판매·재배포만
  금지 — `assets/THIRD_PARTY_LICENSES/elf_girl_pack/LICENSE.txt` 참고)을
  정리해서 반영함:
  - `assets/sprites/characters/elf_girl_test/` — 8방향 캐릭터 스프라이트시트
  - `assets/tiles/interior_test/{walls,floors,dual_grid}/` — 벽/바닥 타일
    (듀얼그리드 포함, Godot 4.3+ TileSet 듀얼그리드 기능과 호환)
  - `assets/props/interior_test/{Architecture,Clutter,Furniture,WallDecor}/`
    — 가구/소품
  용도는 어디까지나 **파이프라인 테스트**(TileSet 구성, 8방향 스프라이트
  애니메이션 연결 방법 검증)이며, 최종 아트(§6.1 주인공 디자인 등)와는
  무관. 아직 실제 씬에 연결/통합하지는 않음.
- **주의**: `.git` 디렉터리가 사라져 있음을 발견함(2026-09-02, 이전 세션의
  커밋 이력 포함). 이 세션이 지운 적 없음 — 원인 불명, 사람 확인 필요.

## 2. 다음 할 일 큐 (우선순위 순, 위가 먼저)

> INBOX.md에 새 지시가 있으면 이 큐보다 항상 먼저 처리한다.

1. DESIGN.md §6.1 메인 퍼즐("둘이었다" 흔적 모으기)용 단서 아이템 5종
   배치 및 수집 시스템 구현 — §6.2 노출 페이싱 제약(언니 이름/죽음/기억
   구조 반전 암시 금지) 반드시 준수. 완료되면 `chapter1_dream.tscn`의
   임시 `WakeTrigger`를 "5종 단서 모두 수집 시 각성"으로 교체.
2. 그레이박스 색상 블록을 실제 픽셀아트 타일/스프라이트로 교체
3. 각 신규 씬 작업 후 반드시 `qa/run_qa.sh` 로 캡처 → 눈으로 확인 →
   문제 있으면 즉시 수정 (같은 이터레이션 내에서)

> DESIGN.md 전면 개정(2026-09-01): 옴니버스 → 단일 서사(기억 층위 구조)로
> 변경, §2에 게임 전체 진상(스포일러) 추가, 챕터 1 메인 퍼즐과 노출 페이싱
> 제약 확정. 구현 시 텍스트/연출에 §6.2 제약을 넘는 내용이 들어가지 않도록
> 주의할 것.

> 이동 사양 확정(사람 확인 완료, 2026-09-01): `play_area` 는 화면 전체
> (Ground 영역)이며, 기와집 벽/밭/원두막 등 개별 구역은 현재 **충돌 처리
> 없는 순수 시각적 표시**라 플레이어가 그냥 통과해서 지나다닐 수 있다.
> 벽/구역 경계로 이동을 막는 충돌 처리는 **아직 요청되지 않았으므로
> 구현하지 않는다** — 나중에 필요해지면 INBOX.md로 지시할 것.

## 3. 완료 기록 (최신이 위)

- 낮잠→꿈 전환 구현: `InteractTrigger`/`FadeOverlay` 재사용 컴포넌트 작성,
  `chapter1_real.tscn`(툇마루에 낮잠 트리거) ↔ `chapter1_dream.tscn`
  (같은 위치에 임시 각성 트리거, 밭→피마자밭 색 전환) 왕복 구조 완성.
  두 씬 다 QA 캡처로 렌더링 확인.
- `chapter1_real.tscn` 그레이박스(기와집/툇마루/밭/원두막) + 그리드 이동
  플레이어 스크립트 작성, QA 캡처로 렌더링 확인. `run_qa.sh`의
  `add_child()` 타이밍 버그(부모 노드가 자식 설정 중일 때 즉시 add_child
  호출해 실패 → 빈 화면 캡처됨) 수정, `call_deferred` 로 교체해 해결.

---

### 이터레이션 종료 시 체크리스트 (기록 전에 확인)

- [ ] `qa/run_qa.sh` 실행 결과가 성공(exit 0)이고 PNG가 실제로 갱신되었는가?
- [ ] 생성된 PNG를 직접 확인했는가? (파일 존재만으로 완료 판단 금지)
- [ ] `docs/feedback/INBOX.md`의 지시를 모두 반영했는가, 반영 못했다면 이유를 남겼는가?
- [ ] 위 "완료 기록"에 이번 이터레이션에서 한 일을 한두 줄로 추가했는가?
- [ ] "다음 할 일 큐"를 다음 세션 기준으로 다시 정리했는가?
