#!/usr/bin/env bash
# qa/run_all.sh — 알려진 모든 씬에 대해 run_qa.sh 시각 캡처를 순서대로
# 실행하고 통과/실패를 요약한다 (tests/run_all.sh 의 시각 QA 버전).
#
# 사용법:
#   ./qa/run_all.sh
#   GODOT_BIN=/c/Path/To/Godot.exe ./qa/run_all.sh
#
# 주의: 이 스크립트는 exit code/PNG 생성 여부만 확인한다 — 캡처된 이미지가
# "제대로 된 화면"인지는 사람이 (또는 이미지 읽기 도구로) 직접 봐야 한다.
# `docs/DESIGN.md` §7.3 참고.
#
# 종료 코드: 하나라도 실패하면 1, 전부 성공하면 0.

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# "GAME_START 키|QA_SCENE_PATH(비어있으면 기본 규칙 사용)" 형식.
# 새 씬을 추가하면 여기에 한 줄만 추가하면 된다.
SCENES=(
  "dungeon|"
  "chapter1_intro|"
  "chapter1_real|"
  "chapter1_dream|"
  "chapter1_end|"
  "pipeline_test|res://scenes/test/pipeline_test.tscn"
  "main_tileset_test|res://scenes/test/main_tileset_test.tscn"
)

pass_count=0
fail_count=0
failed_names=()

for entry in "${SCENES[@]}"; do
  key="${entry%%|*}"
  scene_path="${entry#*|}"
  echo "=== $key ==="
  if [[ -n "$scene_path" ]]; then
    GAME_START="$key" QA_SCENE_PATH="$scene_path" "$PROJECT_DIR/qa/run_qa.sh"
  else
    GAME_START="$key" "$PROJECT_DIR/qa/run_qa.sh"
  fi
  if [[ $? -eq 0 ]]; then
    pass_count=$((pass_count + 1))
  else
    fail_count=$((fail_count + 1))
    failed_names+=("$key")
  fi
  echo
done

echo "===================================="
echo "[QA] 성공: $pass_count, 실패: $fail_count"
if [[ $fail_count -gt 0 ]]; then
  echo "[QA] 실패한 씬: ${failed_names[*]}"
  exit 1
fi
echo "[QA] 캡처된 PNG는 qa/output/ 에서 직접 눈으로 확인할 것 (exit 0가 화면이 맞다는 뜻은 아님)"
exit 0
