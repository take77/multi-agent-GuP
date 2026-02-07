#!/bin/bash
# alert_platoon_leaders.sh - 全中隊長への一斉通知

MESSAGE="${1:-作戦指示があります}"

PLATOON_LEADERS=("kay" "katyusha" "darjeeling")

for leader in "${PLATOON_LEADERS[@]}"; do
    scripts/post.sh "$leader" "$MESSAGE"
done

echo "全中隊長への通知完了"
