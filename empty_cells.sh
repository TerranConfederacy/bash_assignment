#!/usr/bin/env bash
# empty_cells    - 
# empty_cells <file> [sep]   (sep ; on default)
set -euo pipefail

file=${1:-}
sep=${2:-';'}

[[ -z "$file" || ! -f "$file" ]] && { echo "Usage: $0 <file> [sep]" >&2; exit 1; }

# ------- TAB sep -------
IFS= read -r header < "$file"
col_string=$(printf '%s' "$header" | tr "$sep" '\t')   # e.g "ID\tName\tYear..."

# ------- awk-------
awk -v FS="$sep" -v COLS="$col_string" '
BEGIN {
    n = split(COLS, names, "\t")
}
NR > 1 {
    for (i = 1; i <= n; i++) {
        if (i > NF || $i == "" || $i ~ /^[[:space:]]+$/) cnt[i]++
    }
}
END {
    for (i = 1; i <= n; i++)
        printf "%s: %d\n", names[i], (cnt[i] + 0)   # 没出现时 cnt 为 0
}
' "$file"
