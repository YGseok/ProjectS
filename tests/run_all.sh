#!/usr/bin/env bash
# tests/run_all.sh — tests/ 안의 모든 자동 상호작용 테스트(test_*.gd)를
# 순서대로 실행하고 통과/실패를 요약한다.
#
# 사용법:
#   ./tests/run_all.sh
#   GODOT_BIN=/c/Path/To/Godot.exe ./tests/run_all.sh
#
# 환경변수:
#   TEST_TIMEOUT  테스트 1개당 최대 실행 초 (기본 180 — 가장 느린 test_full_story_progression이 약 65초). 넘으면 강제 종료하고 실패 처리 —
#                 스크립트 오류로 Godot가 안 끝나고 멈추는 경우를 막는다.
#
# 종료 코드: 하나라도 실패하면 1, 전부 통과하면 0.

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="$PROJECT_DIR/tests"
GODOT_BIN="${GODOT_BIN:-godot4}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "[TESTS] 오류: '$GODOT_BIN' 실행 파일을 찾을 수 없습니다. GODOT_BIN 환경변수로 경로를 지정하세요." >&2
  exit 1
fi

TEST_TIMEOUT="${TEST_TIMEOUT:-180}"

# timeout은 Windows에서 콘솔 래퍼만 죽이고 실제 Godot 프로세스는 남기는 경우가 있어서,
# 이 테스트 파일을 실행 중인 프로세스만 명령줄로 찾아 정리한다(다른 세션의 Godot는 안 건드림).
kill_leftover() {
  command -v wmic >/dev/null 2>&1 || return 0
  wmic process where "name like 'Godot%' and commandline like '%$1%'" get ProcessId 2>/dev/null \
    | grep -E '^[0-9]+' | while read -r pid; do taskkill //PID "$pid" //F //T >/dev/null 2>&1; done
}

pass_count=0
fail_count=0
failed_names=()

for test_file in "$TESTS_DIR"/test_*.gd; do
  [[ -e "$test_file" ]] || continue
  name="$(basename "$test_file" .gd)"
  echo "=== $name ==="
  output="$(timeout "$TEST_TIMEOUT" "$GODOT_BIN" --headless --script "res://tests/$(basename "$test_file")" --path "$PROJECT_DIR" 2>&1)"
  status=$?
  echo "$output"
  if [[ $status -eq 124 ]]; then
    echo "[TESTS] 타임아웃: $name (${TEST_TIMEOUT}초 초과)"
    kill_leftover "$name.gd"
  fi
  if [[ $status -ne 124 ]] && grep -q "\[TEST\] ALL PASSED" <<< "$output"; then
    pass_count=$((pass_count + 1))
  else
    fail_count=$((fail_count + 1))
    failed_names+=("$name")
  fi
  echo
done

echo "===================================="
echo "[TESTS] 통과: $pass_count, 실패: $fail_count"
if [[ $fail_count -gt 0 ]]; then
  echo "[TESTS] 실패한 테스트: ${failed_names[*]}"
  exit 1
fi
exit 0
