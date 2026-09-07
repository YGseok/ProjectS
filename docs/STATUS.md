# STATUS.md — 현재 상태 / 인수인계 문서

이 문서는 매 루프 이터레이션이 끝날 때 **다음 세션(기억 없음)에게 남기는 인수인계서**다.
새 이터레이션은 작업 시작 전 이 문서를 가장 먼저 읽는다.
갱신할 때는 아래 세 섹션을 모두 최신 상태로 다시 쓴다 — 과거 기록은
"완료 기록"으로 옮기고, 지금 섹션은 항상 "현재"만 반영한다.

---

## 1. 지금 위치 (현재 상태 요약)

- **git**: `.git`이 사라졌던 사고 이후 재초기화 완료 (2026-09-02, 이전 이력은
  복구 안 됨). `origin/master`에 push까지 연결돼 있음. 정확한 최신 커밋은
  `git log --oneline -1`로 확인할 것 (이 문서에 특정 해시를 박아두면
  매번 바로 낡아서 더 이상 안 함).
- **메인 타일셋 팩 확보**(2026-09-04): `assets/tiles/main/` — RPG Maker
  MV/MZ 스타일 48px 타일 시트(A4=벽/지붕, A5=바닥, Inside_C/C_2/D/E=가구·
  집기, Outside=자연 오브젝트(불규칙 크기, 타일 격자 아님)). 호러 장르에
  맞는 소재(핏자국 바닥 타일 등) 포함. 자세한 파일별 크기/그리드는
  `assets/tiles/main/README.md` 참고. **A4(벽)/A5(바닥) 중 5개 타일은
  `main_tileset.tres`로 조립해 챕터 1 두 씬에 이미 반영함** (아래 "배경
  아트 통합" 참고). Outside(자연 오브젝트)에서는 나무/덤불 3종을 잘라
  `assets/props/nature/`로 만들어 두 씬 마당에 배치함. Inside_C/D/E(실내
  가구)는 아직 미사용 — 챕터 1이 실외(툇마루/마당/원두막) 범위라 지금은
  쓸 곳이 없음, 실내 씬이 생기면 사용.
  **라이선스 확인됨**(작가 AnisAous,
  `assets/THIRD_PARTY_LICENSES/main_tileset_pack/LICENSE.txt`): 개인 용도
  무료, **상업적 사용은 $4.50 이상 후원 필요**(아직 후원 여부 미확인 —
  상업 출시 전 확인할 것), 수정 가능, 팩 자체 재판매/재배포는 금지.
- **보너스 팩 확보**(2026-09-04): `assets/Bonus.rar`(RAR라 압축 해제용
  7-Zip을 winget으로 설치해서 풀었음)를 `assets/sprites/characters/
  bonus_pack/`(캐릭터 3종: Bonus.png 잡다한 스프라이트 모음, Cute_Yui.png,
  femaleIdle.png)와 `assets/props/bonus_pack/`(Door1.png 8프레임 문 열림
  애니메이션 — 호러 연출용, RejectedAssets1.png 괘종시계)로 정리. 각 폴더
  README 참고. **라이선스 확인됨**(2026-09-04, 메인 타일셋 팩과 같은
  출처 — AnisAous, 동일 라이선스 적용: 개인 용도 무료, 상업적 사용은
  $4.50 이상 후원 필요).
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
- `res://scenes/chapter1_real.tscn` / `chapter1_dream.tscn` — 배경은 이제
  실제 타일 아트 적용됨(아래 "배경 아트 통합" 참고, 더 이상 그레이박스
  아님). 낮잠→꿈 전환은 왕복 가능하지만 `chapter1_dream.tscn`의 각성
  트리거는 여전히 **임시** (Enter만 누르면 각성 — 진짜 메인 퍼즐로 교체 전,
  §7.1 재구성 대기 중).

## 2. 다음 할 일 큐 (우선순위 순, 위가 먼저)

> INBOX.md에 새 지시가 있으면 이 큐보다 항상 먼저 처리한다.

1. DESIGN.md §7.1(챕터 1 메인 퍼즐) 재구성 여부는 **사람이 Claude.ai에서
   결정 중** — 여기서 먼저 판단하지 말고 결정 결과(INBOX.md 또는
   docs/scenario/ 새 파일)를 기다릴 것.
2. 캐릭터 아트: `bonus_pack`의 캐릭터들은 최종 디자인(흰 원피스, 10살
   한국인 여아)과 안 맞음 — 맞는 에셋이 더 필요하거나 별도 제작 필요.
3. 각 신규 씬/상호작용 작업 후 `qa/run_qa.sh`(시각) + 해당하면 `tests/`
   자동 상호작용 테스트로 검증 → 사람 눈 확인은 여전히 최종 기준.

> 위 1, 2번이 둘 다 사람의 후속 조치(스토리 결정 / 에셋 확보) 대기
> 상태라, 다음 세션은 그 전까지 코드 품질/테스트 커버리지 보강을 계속
> 해도 좋다. `Outside.png`(자연 오브젝트)는 사용 시작함(나무/덤불 3종,
> `assets/props/nature/`). `Inside_C/D/E`(실내 가구)는 챕터 1이 실외
> 범위라 아직 쓸 곳이 없음 — 실내 씬이 새로 필요해지기 전까지는 미룰 것
> (임의로 새 실내 씬을 만들지 말 것, 그건 스토리/설계 결정 영역).

> **배경 아트 통합 완료**(2026-09-07): `assets/tiles/main/main_tileset.tres`
> 로 `chapter1_real.tscn`과 `chapter1_dream.tscn` 둘 다 그레이박스에서
> 실제 타일로 교체. 같은 5개 타일(벽/잔디/밭/툇마루나무/원두막나무)을
> 재사용하되, 꿈 씬은 `TileData.modulate`로 구역별 색 틴트를 다르게 줘서
> "같은 공간, 다른 분위기"(DESIGN.md §4)를 구현 — 특히 밭은 진한 빨강
> 틴트로 피마자밭 느낌을 강조. QA 캡처 둘 다 확인, `chapter1_real` 쪽은
> 자동 상호작용 테스트 11개도 재통과.

> 이동 사양 확정(2026-09-01): `play_area` 는 화면 전체이며, 벽/구역 경계
> 충돌 처리는 아직 요청되지 않았으므로 구현하지 않는다.

## 3. 완료 기록 (최신이 위)

- 회귀 스윕 3: `tests/run_all.sh`로 자동 테스트 6종 전부 재통과 + QA
  시각 캡처 5종 전부 exit 0 확인 (마당 나무/덤불 추가 이후 회귀 없음).
- `tests/run_all.sh` 추가 — `tests/`의 `test_*.gd` 전부를 순서대로
  실행하고 통과/실패 개수를 요약(하나라도 실패하면 exit 1). 매번 파일을
  하나씩 나열해서 돌리던 것을 대체. `qa/README.md`에 사용법 기록.
- `chapter1_dream.tscn`에도 같은 나무/덤불을 같은 위치에 배치하되
  `modulate`로 칙칙한 톤(나무는 회녹색, 덤불은 녹슨 듯한 붉은기)을 줘서
  "같은 공간, 다른 분위기" 유지. QA 캡처 확인.
- `chapter1_real.tscn` 마당에 나무 2그루 + 열매 덤불 배치 (`assets/props/
  nature/` 스프라이트, `Sprite2D` + `centered=false`/`offset`로 밑동
  기준 배치). QA 캡처로 배치 확인, 자동 테스트 회귀 없음 확인.
- `assets/props/nature/` 신설: `Outside.png`(불규칙 자연 오브젝트 시트,
  지금까지 미사용)에서 나무 2종(`tree_green`, `tree_small`)과 열매
  덤불(`bush_berry`)을 손으로 잘라 저장. `tools/crop_outside_props.gd`로
  좌표 지정, README에 좌표 기록. 다음: 실제 씬(마당)에 배치.
- 회귀 스윕 2: 자동 테스트 6종(대화, 낮잠/각성 왕복, 이동 경계, NPC 방향
  체크, 낮잠/각성 트리거 사정거리) 전부 재통과 + QA 시각 캡처 5종 전부
  exit 0. 큐에서 해결된 지붕 항목 정리.
- `tests/test_wake_trigger_range.gd` 추가: `test_nap_trigger_range.gd`와
  대칭으로 `chapter1_dream.tscn`의 각성 트리거도 사정거리 밖 미반응 +
  프롬프트 표시/숨김을 검증. 첫 시도에 바로 통과.
- `tools/README.md` 작성 — 늘어난 헤드리스 도구 스크립트들(용도, 상태,
  `--script` 모드 오토로드 함정)을 표로 정리. `gen_player_sprite.gd`는
  중단된 접근임을 명시.
- `chapter1_real.tscn`의 원두막 지붕에 `TileData.modulate` 밝은 톤 틴트
  적용 — 벽과 같은 타일 재사용하면서도 시각적으로 구분되게 함 (꿈 씬은
  이미 구역별 틴트가 있었으니 현실 씬만 보완). QA 캡처 확인.
- `tests/test_nap_trigger_range.gd` 추가: 낮잠 트리거가 사정거리
  (`interact_radius`) 밖에서는 반응 안 하고 프롬프트도 숨겨지는지, 복귀
  시 정상 작동하는지(대조군) 검증. 테스트 작성 중 실제로 발견한 함정:
  플레이어를 오른쪽으로 이동시켜 "범위 밖"을 만들려 하면 그 자리가
  그림자 NPC와 인접+마주보는 위치라 낮잠 대신 NPC 대화가 열려버려 이후
  이동이 막히는 간섭이 있었음 — 아래/위 방향으로 옮기도록 수정해 해결
  (제품 버그 아님, 테스트 시나리오 설계 문제였음).
- 회귀 스윕: `tests/`의 자동 테스트 4종(대화, 낮잠/각성 왕복, 이동 경계,
  NPC 방향 체크) 전부 재통과 + QA 시각 캡처 5종(dungeon, chapter1_real,
  chapter1_dream, pipeline_test, main_tileset_test) 전부 exit 0로 확인.
  최근 배경 아트 교체 이후 회귀 없음.
- `tests/test_npc_facing_check.gd` 추가: NPC가 "인접 + 그 방향을 바라볼
  때만" 반응한다는 로직의 부정 케이스(다른 방향 보면 반응 안 함)를
  대조군(다시 바라보면 반응함)과 함께 검증. 기존 대화 테스트는 긍정
  케이스만 다뤘던 공백을 메움.
- `tests/test_movement_bounds.gd` 추가: 플레이어가 `play_area` 경계
  밖으로 못 나가는지(위쪽 끝까지 이동 후 추가 이동 시도해도 그대로,
  반대 방향 이동은 정상 작동) 자동 검증.
- `tests/test_nap_wake_roundtrip.gd` 추가: `chapter1_real`↔`chapter1_dream`
  낮잠/각성 씬 전환 왕복을 `change_scene_to_file` + `current_scene.name`
  체크로 자동 검증 (배경 아트 교체 이후에도 정상 작동 확인). INBOX.md
  기존 완료 항목(대화 시스템/테스트 NPC/배경 디자인)을 [처리됨]으로 정리.
- 배경 아트 통합 3단계: `chapter1_dream.tscn`에도 같은 타일셋 적용,
  `TileData.modulate`로 구역별 색 틴트(밭=진한 빨강 등)를 줘서 꿈 분위기
  표현. QA 캡처 확인.
- 배경 아트 통합 2단계: `chapter1_real.tscn`의 그레이박스 ColorRect를
  실제 타일(`TileMapLayer` + `chapter1_real_background.gd`)로 교체.
  좌표/레이아웃은 그대로 유지. QA 캡처 확인 + 자동 상호작용 테스트
  11개 재통과 확인.
- 배경 아트 통합 1단계: `assets/tiles/main/main_tileset.tres` 조립(벽/잔디/
  흙/나무바닥 5종), 48px→32px 자동 축소 렌더링 확인, QA 캡처로 5종 타일
  이음매 검증 완료. (다음: 실제 챕터 1 씬 적용)
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
