#!/bin/bash
set -e

# Kill any leftover processes on port 4747
lsof -ti:4747 | xargs kill -9 2>/dev/null || true
sleep 1

echo "Starting Agentation MCP server..."
npx -y agentation-mcp server &
MCP_PID=$!
sleep 2

echo "Starting tunnel..."
TUNNEL_LOG=$(mktemp)
ssh -o StrictHostKeyChecking=no -T \
    -R 80:localhost:4747 nokey@localhost.run \
    > "$TUNNEL_LOG" 2>&1 &
SSH_PID=$!

# Wait for URL
for i in $(seq 1 20); do
  URL=$(grep -o 'https://[a-z0-9]*\.lhr\.life' "$TUNNEL_LOG" 2>/dev/null | head -1)
  [ -n "$URL" ] && break
  sleep 1
done

if [ -z "$URL" ]; then
  echo "Failed to get tunnel URL."
  kill $MCP_PID $SSH_PID 2>/dev/null
  rm -f "$TUNNEL_LOG"
  exit 1
fi

ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$URL', safe=''))")
SHARE_URL="https://yunustuncel.github.io/metrics-prototype/?endpoint=$ENCODED"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Share this URL with colleagues:"
echo ""
echo "  $SHARE_URL"
echo ""
echo "  Annotations sync to you in real time."
echo "  Tell Claude: 'read the annotations and implement changes'"
echo "  Press Ctrl+C to stop."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

trap "kill $MCP_PID $SSH_PID 2>/dev/null; rm -f $TUNNEL_LOG; echo ''; echo 'Session ended.'" EXIT
wait
