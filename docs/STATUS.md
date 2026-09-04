# STATUS.md — 현재 상태 / 인수인계 문서

이 문서는 매 루프 이터레이션이 끝날 때 **다음 세션(기억 없음)에게 남기는 인수인계서**다.
새 이터레이션은 작업 시작 전 이 문서를 가장 먼저 읽는다.
갱신할 때는 아래 세 섹션을 모두 최신 상태로 다시 쓴다 — 과거 기록은
"완료 기록"으로 옮기고, 지금 섹션은 항상 "현재"만 반영한다.

---

## 1. 지금 위치 (현재 상태 요약)

- **git**: `.git`이 사라졌던 사고 이후 재초기화 완료 (2026-09-02, 이전 이력은
  복구 안 됨). `origin/master`에 push까지 연결돼 있음. 이 문서 기준 최신
  커밋은 `6e191b0`.
- **메인 타일셋 팩 확보**(2026-09-04): `assets/tiles/main/` — RPG Maker
  MV/MZ 스타일 48px 타일 시트(A4=벽/지붕, A5=바닥, Inside_C/C_2/D/E=가구·
  집기, Outside=자연 오브젝트(불규칙 크기, 타일 격자 아님)). 호러 장르에
  맞는 소재(핏자국 바닥 타일 등) 포함. 자세한 파일별 크기/그리드는
  `assets/tiles/main/README.md` 참고. **아직 Godot TileSet 리소스로
  조립하거나 실제 씬에 반영하지 않음** — 다음 배경 아트 작업 때 사용.
  **라이선스 확인됨**(작가 AnisAous,
  `assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt`): 개인 용도
  무료, **상업적 사용은 $4.50 이상 후원 필요**(아직 후원 여부 미확인 —
  상업 출시 전 확인할 것), 수정 가능, 팩 자체 재판매/재배포는 금지.
- **보너스 팩 확보**(2026-09-04): `assets/Bonus.rar`(RAR라 압축 해제용
  7-Zip을 winget으로 설치해서 풀었음)를 `assets/sprites/characters/
  bonus_pack/`(캐릭터 3종: Bonus.png 잡다한 스프라이트 모음, Cute_Yui.png,
  femaleIdle.png)와 `assets/props/bonus_pack/`(Door1.png 8프레임 문 열림
  애니메이션 — 호러 연출용, RejectedAssets1.png 괘종시계)로 정리. 각 폴더
  README 참고. **라이선스 정보 없음** — 메인 타일셋 팩과 같은 출처인지
  사람이 확인해야 하고, 확인 전까지 상업적 사용 금지.
- **스토리 진상 대개정**(2026-09-04): `docs/scenario/2026-09-04.md`를 받아
  `docs/DESIGN.md` §2를 다시 씀 — 리신 중독/목격 설정 등 기존 사망 원인은
  **폐기**, 계모와의 몸싸움 중 익사·빨간 연필 금기·필통·일기 중심의 새
  진상으로 교체(자세한 내용은 DESIGN.md §2 참고). §7(챕터 1)은 명백히 틀린
  전제("외갓집에 놀러옴" → 실제로는 본인 고향집)만 고치고, §7.1 메인 퍼즐은
  **재구성 여부가 미정 상태로 보류**돼 있음 — 사람이 "여기서는 구현/테스트만,
  스토리 결정은 Claude.ai에서 한다"고 확인함. **§7.1을 다시 짜기 전까지는
  손대지 말 것.**
- **캐릭터 아트 초안 작업은 중단됨**: `tools/gen_player_sprite.gd`로 절차적
  도트 스프라이트(`assets/sprites/player_draft_v1~v7.png`)를 v7까지
  반복했으나, 진짜 이미지 생성이 아니라 도형 조합이라 한계가 있다고 사람이
  판단(2026-09-04). **이 방식으로 캐릭터 아트를 더 다듬지 않는다.** 사람이
  무료 에셋 등 별도 리소스를 구해올 예정 — 받으면 파이프라인 테스트
  (`scenes/test/pipeline_test.tscn`)에서 검증한 방식(TileSet/스프라이트
  연결)으로 통합.
- **외부 에셋 파이프라인 검증 완료**: `STEP/`에서 받은 elf_girl 데모 팩을
  `assets/{sprites/characters,tiles,props}/..._test/`로 정리 (라이선스:
  상업적 사용/수정 가능, 재판매만 금지). `tools/build_interior_tileset.gd`로
  개별 PNG들을 `TileSet` 리소스로 코드 조립, `scenes/test/pipeline_test.tscn`
  에서 바닥/벽 타일 + 8방향 캐릭터 중 4방향을 그리드 이동에 연결해 QA
  캡처로 확인. **오른쪽 세로벽 좌우반전 문제(`wall_vertical.png`이 한쪽
  면만 그려져 있어 반대편은 FLIP_H 필요) 발견 후 수정 완료**
  (`TileSetAtlasSource.TRANSFORM_FLIP_H`로 `set_cell()` 시 반전).
- **대화 시스템 구현 완료**:
  - `scripts/dialogue_system.gd` + `scenes/common/DialogueSystem.tscn` —
    전역 오토로드(`project.godot` `[autoload]`), 하단 대화창, `ui_accept`
    (Enter/Space)로 한 줄씩 진행, 더 없으면 종료.
  - `scripts/npc.gd` + `scenes/common/ShadowNPC.tscn` — 재사용 가능한 NPC.
    플레이어가 인접 타일에서 그 방향을 "바라볼 때"만 반응 (거리 + facing
    내적 체크).
  - `scripts/player.gd`에 `facing` 변수 추가, 대화 중 이동 입력 무시하도록
    처리.
  - `chapter1_real.tscn` 툇마루에 테스트용 그림자 NPC 배치 (플레이어와 동일
    모양, 검은색, 대화 시 "[...]"만 출력).
  - **버그 발견 및 수정**: NPC 옆에 서서 마지막 줄을 닫는 Enter 입력이 같은
    프레임에 NPC를 다시 트리거해 대화가 즉시 재시작되는 버그가 있었음.
    `DialogueSystem._started_frame`/`_ended_frame` + `npc.gd`의
    `just_ended_this_frame()` 가드로 해결.
- **새 역량: 상호작용 자동 테스트** (`tests/`, 2026-09-04) — 정적 스크린샷
  QA로는 "키를 눌렀을 때 실제로 반응하는지" 검증이 안 됐는데, 이제
  `Input.parse_input_event()`로 실제 키 입력을 헤드리스 Godot 스크립트에서
  시뮬레이션해서 **사람 없이 자동으로 검증 가능**. 위 대화 시스템 버그도
  이 방식으로 잡아냈다. 사용법/함정은 `qa/README.md`의 "상호작용 자동
  테스트" 절 참고. 예시: `tests/test_dialogue_interaction.gd`.
- `res://scenes/chapter1_real.tscn` / `chapter1_dream.tscn` — 그레이박스
  상태 그대로 (실제 픽셀아트 없음, 의도적 플레이스홀더). 낮잠→꿈 전환은
  왕복 가능하지만 `chapter1_dream.tscn`의 각성 트리거는 여전히 **임시**
  (Enter만 누르면 각성 — 진짜 메인 퍼즐로 교체 전).

## 2. 다음 할 일 큐 (우선순위 순, 위가 먼저)

> INBOX.md에 새 지시가 있으면 이 큐보다 항상 먼저 처리한다.

1. DESIGN.md §7.1(챕터 1 메인 퍼즐) 재구성 여부는 **사람이 Claude.ai에서
   결정 중** — 여기서 먼저 판단하지 말고 결정 결과(INBOX.md 또는
   docs/scenario/ 새 파일)를 기다릴 것.
2. 캐릭터 아트: 사람이 외부 에셋을 구해오면, `pipeline_test`에서 검증한
   방식(TileSet/스프라이트 연결)으로 실제 플레이어에 통합.
3. 그레이박스 색상 블록을 실제 픽셀아트 타일로 교체 (배경 아트, INBOX
   4번 항목 — 사람이 "쪼개진 타일 형태로 저장"을 요청했었음, TileSet
   방식은 이미 pipeline_test로 검증됨).
4. 각 신규 씬/상호작용 작업 후 `qa/run_qa.sh`(시각) + 해당하면 `tests/`
   자동 상호작용 테스트로 검증 → 사람 눈 확인은 여전히 최종 기준.

> 이동 사양 확정(2026-09-01): `play_area` 는 화면 전체이며, 벽/구역 경계
> 충돌 처리는 아직 요청되지 않았으므로 구현하지 않는다.

## 3. 완료 기록 (최신이 위)

- DESIGN.md 절 번호 밀림에 따른 참조 오류 일괄 수정(§3 신설로 이후 절
  전부 한 칸씩 밀림), `assets/downloads/`에 받은 RPG Maker 스타일 메인
  타일셋 팩(7개 파일) `assets/tiles/main/`로 정리 + README 작성.
- 상호작용 자동 테스트 도구(`tests/`) 도입 + 대화 시스템의 "닫는 즉시
  재시작" 버그 발견/수정. 파이프라인 테스트 오른쪽 벽 좌우반전 버그 수정.
- 대화 시스템(`DialogueSystem` 오토로드 + NPC 컴포넌트) 구현, 챕터 1
  툇마루에 테스트용 그림자 NPC 배치.
- 외부 에셋 팩(elf_girl_test) 파이프라인 검증: TileSet 코드 조립,
  `pipeline_test.tscn`에서 타일+8방향 캐릭터 그리드 이동 확인.
- `.git` 재초기화(사람이 직접 삭제했다고 확인, 이전 이력 복구 안 됨),
  `docs/scenario/` 외부 시놉시스 인박스 워크플로 CLAUDE.md에 기록.
- 시놉시스 대개정 반영: DESIGN.md §2(진상) 전면 재작성 (리신 중독 사망
  원인 폐기 → 계모/익사/빨간 연필 금기 구조로 교체).
- 캐릭터 도트 스프라이트 절차적 생성 v1~v7 반복 (등신비/셰이프 피드백
  반영) 후 이 접근 자체를 중단하기로 결정.
- 낮잠→꿈 전환 구현: `InteractTrigger`/`FadeOverlay` 재사용 컴포넌트,
  `chapter1_real.tscn`↔`chapter1_dream.tscn` 왕복 구조.
- `chapter1_real.tscn` 그레이박스 + 그리드 이동 플레이어 스크립트, QA
  캡처 파이프라인의 `add_child()` 타이밍 버그 수정.

---

### 이터레이션 종료 시 체크리스트 (기록 전에 확인)

- [ ] `qa/run_qa.sh` 실행 결과가 성공(exit 0)이고 PNG가 실제로 갱신되었는가?
- [ ] 생성된 PNG를 직접 확인했는가? (파일 존재만으로 완료 판단 금지)
- [ ] 입력에 반응하는 상호작용을 새로 만들었다면 `tests/`에 자동 검증을
      추가했는가? (정적 스크린샷만으로는 키 입력 반응을 검증 못 함)
- [ ] `docs/feedback/INBOX.md`의 지시를 모두 반영했는가, 반영 못했다면 이유를 남겼는가?
- [ ] 위 "완료 기록"에 이번 이터레이션에서 한 일을 한두 줄로 추가했는가?
- [ ] "다음 할 일 큐"를 다음 세션 기준으로 다시 정리했는가?
