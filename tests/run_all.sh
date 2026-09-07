#!/usr/bin/env bash
# tests/run_all.sh — tests/ 안의 모든 자동 상호작용 테스트(test_*.gd)를
# 순서대로 실행하고 통과/실패를 요약한다.
#
# 사용법:
#   ./tests/run_all.sh
#   GODOT_BIN=/c/Path/To/Godot.exe ./tests/run_all.sh
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

pass_count=0
fail_count=0
failed_names=()

for test_file in "$TESTS_DIR"/test_*.gd; do
  [[ -e "$test_file" ]] || continue
  name="$(basename "$test_file" .gd)"
  echo "=== $name ==="
  output="$("$GODOT_BIN" --headless --script "res://tests/$(basename "$test_file")" --path "$PROJECT_DIR" 2>&1)"
  echo "$output"
  if grep -q "\[TEST\] ALL PASSED" <<< "$output"; then
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
