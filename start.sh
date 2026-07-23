#!/bin/bash
set -e

echo "Starting Agentation MCP server..."
npx -y agentation-mcp server &
MCP_PID=$!

echo "Starting tunnel..."
TUNNEL_OUT=$(mktemp)
npx localtunnel --port 4747 > "$TUNNEL_OUT" 2>&1 &
LT_PID=$!

# Wait for tunnel URL
for i in $(seq 1 20); do
  URL=$(grep -o 'https://[^ ]*\.loca\.lt' "$TUNNEL_OUT" 2>/dev/null | head -1)
  [ -n "$URL" ] && break
  sleep 1
done

if [ -z "$URL" ]; then
  echo "Failed to get tunnel URL. Check your connection."
  kill $MCP_PID $LT_PID 2>/dev/null
  exit 1
fi

SHARE_URL="https://yunustuncel.github.io/metrics-prototype/?endpoint=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$URL', safe=''))")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Share this URL with colleagues:"
echo ""
echo "  $SHARE_URL"
echo ""
echo "  Annotations sync to you in real time."
echo "  Press Ctrl+C to stop."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

trap "kill $MCP_PID $LT_PID 2>/dev/null; rm -f $TUNNEL_OUT" EXIT
wait
