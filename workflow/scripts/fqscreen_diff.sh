N=$#
ARGS=("$@")

TARGET="${!N}"
OUTPUT="${ARGS[$((N-2))]}"
FILES=("${ARGS[@]:0:$((N-2))}")

# Ensure output file is empty
> "$OUTPUT"

for INPUT in "${FILES[@]}"; do
    SAMPLE=$(basename "$INPUT")
    SAMPLE=${SAMPLE%_hits.txt}

    # Check if file is empty or all zero
    total_counts=$(awk '{sum+=$2} END{print sum}' "$INPUT")
    if [[ -z "$total_counts" || "$total_counts" -eq 0 ]]; then
        printf "%s\tNA\tNA\tNA\n" "$SAMPLE" >> "$OUTPUT"
        continue
    fi

    # Get top two hits (already sorted OR enforce sort)
    read top_hit top_count top_percent < <(
        sort -k2 -nr "$INPUT" | head -n1 | awk '{gsub("%","",$3); print $1, $2, $3}'
    )

    read second_hit second_count second_percent < <(
        sort -k2 -nr "$INPUT" | sed -n '2p' | awk '{gsub("%","",$3); print $1, $2, $3}'
    )

    # Calculate percent difference based on READ COUNTS
    if [[ "$top_count" -gt 0 ]]; then
        diff=$(awk -v a="$top_count" -v b="$second_count" 'BEGIN {printf "%.2f", ((a-b)/a)*100}')
    else
        diff="0.00"
    fi

    printf "%s\t%s\t%s\t%s%%\t%s\n" "$SAMPLE" "$top_hit" "$top_count" "$diff" >> "$OUTPUT"
done
