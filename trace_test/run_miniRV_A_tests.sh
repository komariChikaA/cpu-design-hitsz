#!/usr/bin/env bash

# Run all miniRV group-A Basic Trace tests and generate a Markdown report.
#
# Usage:
#   ./run_miniRV_A_tests.sh [cdp-tests-directory] [report-file]
#
# Examples:
#   ./run_miniRV_A_tests.sh
#   ./run_miniRV_A_tests.sh ~/cdp-tests
#   ./run_miniRV_A_tests.sh ~/cdp-tests ~/miniRV_A_report.md

set -u
set -o pipefail

invocation_dir="$PWD"
run_user="${USER:-$(id -un)}"

tests=(
    add sub auipc xor xori
    sll srl srli sra srai
    lb lbu lh lhu
    sw sb sh jalr
)

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ge 1 ]]; then
    test_root="$1"
elif [[ -f "$PWD/Makefile" ]]; then
    test_root="$PWD"
elif [[ -f "$script_dir/../Makefile" ]]; then
    test_root="$(cd -- "$script_dir/.." && pwd)"
else
    printf 'Error: cannot find the cdp-tests Makefile.\n' >&2
    printf 'Usage: %s [cdp-tests-directory] [report-file]\n' "$0" >&2
    exit 2
fi

if [[ ! -d "$test_root" || ! -f "$test_root/Makefile" ]]; then
    printf 'Error: %s is not a cdp-tests directory.\n' "$test_root" >&2
    exit 2
fi

test_root="$(cd -- "$test_root" && pwd)"
report_file="${2:-$test_root/trace test/miniRV_A_report.md}"
if [[ "$report_file" != /* ]]; then
    report_file="$invocation_dir/$report_file"
fi
report_dir="$(dirname -- "$report_file")"
report_name="$(basename -- "$report_file")"
logs_dir="$report_dir/${report_name%.md}_logs"
tmp_report="$report_file.tmp.$$"

mkdir -p -- "$report_dir" "$logs_dir"
trap 'rm -f -- "$tmp_report"' EXIT

declare -a results
declare -a return_codes
pass_count=0
fail_count=0
started_at="$(date '+%Y-%m-%d %H:%M:%S %z')"
build_log="$logs_dir/build.log"

cd -- "$test_root"

printf '[BUILD] Compiling cdp-tests...\n'
if make >"$build_log" 2>&1; then
    build_result="PASS"
    build_rc=0
    printf '[BUILD] PASS\n'
else
    build_rc=$?
    build_result="FAIL"
    printf '[BUILD] FAIL (exit code %d)\n' "$build_rc"

    {
        printf '# miniRV A 组 Basic Trace 测试报告\n\n'
        printf -- '- 生成时间：`%s`\n' "$started_at"
        printf -- '- 测试目录：`%s`\n' "$test_root"
        printf -- '- 编译结果：**FAIL** (exit code `%d`)\n\n' "$build_rc"
        printf '## 编译日志\n\n'
        printf '%s\n' '```text'
        printf '%s\n' "$run_user@$(hostname):$test_root$ make"
        cat -- "$build_log"
        printf '%s\n' '```'
    } >"$tmp_report"

    mv -- "$tmp_report" "$report_file"
    trap - EXIT
    printf 'Report: %s\n' "$report_file"
    exit "$build_rc"
fi

for index in "${!tests[@]}"; do
    test_name="${tests[$index]}"
    log_file="$logs_dir/$test_name.log"

    printf '[%02d/%02d] TEST=%-5s ... ' \
        "$((index + 1))" "${#tests[@]}" "$test_name"

    if make run TEST="$test_name" >"$log_file" 2>&1; then
        rc=0
    else
        rc=$?
    fi

    if [[ "$rc" -eq 0 ]] && grep -Fq 'Test Point Pass!' "$log_file"; then
        results[$index]="PASS"
        pass_count=$((pass_count + 1))
        printf 'PASS\n'
    else
        results[$index]="FAIL"
        fail_count=$((fail_count + 1))
        printf 'FAIL (exit code %d)\n' "$rc"
    fi
    return_codes[$index]="$rc"
done

finished_at="$(date '+%Y-%m-%d %H:%M:%S %z')"

{
    printf '# miniRV A 组 Basic Trace 测试报告\n\n'
    printf -- '- 开始时间：`%s`\n' "$started_at"
    printf -- '- 结束时间：`%s`\n' "$finished_at"
    printf -- '- 测试目录：`%s`\n' "$test_root"
    printf -- '- 编译结果：**%s**\n' "$build_result"
    printf -- '- 指令结果：**%d/%d 通过，%d 失败**\n\n' \
        "$pass_count" "${#tests[@]}" "$fail_count"

    printf '## 结果汇总\n\n'
    printf '| 指令 | 结果 | make 退出码 | 日志 |\n'
    printf '|---|---:|---:|---|\n'
    for index in "${!tests[@]}"; do
        test_name="${tests[$index]}"
        printf '| `%s` | **%s** | `%s` | [`%s.log`](./%s/%s.log) |\n' \
            "$test_name" "${results[$index]}" "${return_codes[$index]}" \
            "$test_name" "${report_name%.md}_logs" "$test_name"
    done

    printf '\n## 编译日志\n\n'
    printf '%s\n' '```text'
    printf '%s\n' "$run_user@$(hostname):$test_root$ make"
    cat -- "$build_log"
    printf '%s\n' '```'

    for index in "${!tests[@]}"; do
        test_name="${tests[$index]}"
        printf '\n## TEST = %s\n\n' "$test_name"
        printf -- '- 结果：**%s**\n' "${results[$index]}"
        printf -- '- 退出码：`%s`\n\n' "${return_codes[$index]}"
        printf '%s\n' '```text'
        printf '%s\n' "$run_user@$(hostname):$test_root$ make run TEST=$test_name"
        cat -- "$logs_dir/$test_name.log"
        printf '%s\n' '```'
    done
} >"$tmp_report"

mv -- "$tmp_report" "$report_file"
trap - EXIT

printf '\nSummary: %d/%d passed, %d failed.\n' \
    "$pass_count" "${#tests[@]}" "$fail_count"
printf 'Report: %s\n' "$report_file"
printf 'Logs:   %s\n' "$logs_dir"

if (( fail_count > 0 )); then
    exit 1
fi

exit 0
