#!/usr/bin/env bash
set -e

# 👇 How many parallel miners to run
MINER_COUNT=15

# 👇 Your mining public key
PUBKEY="2jcgp9Av69R6ndKZqFKLGyY4HFtaWjyzMsXJb6M5LYNYjVUUxMH3PoZcrB2wbLVxQY5h5BGbYzebmghxvrkzjJpp45LXpetwV6KpDK4qkCi8ANQzPPbZDQt2UMtbQRyYd6Q9"

# 👇 Base compiled repo to clone from
BASE_DIR="$HOME/nockchain"

# 👇 Starting port number (increments by 2 for each miner)
START_PORT=3006

for i in $(seq 1 $MINER_COUNT); do
  DIR="$HOME/nockchain_worker_$i"
  SESSION="nock-miner-$i"
  SOCKET="nockchain_$i.sock"
  PORT=$((START_PORT + (i - 1) * 2))

  echo "🧱 Setting up miner $i in $DIR using UDP port $PORT"

  # Only clone if folder doesn't exist
  if [ ! -d "$DIR" ]; then
    cp -r "$BASE_DIR" "$DIR"
  fi

  cd "$DIR"

  # Clean up any previous session
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  rm -f "$SOCKET"

  # Start miner in tmux with unique bind + socket
  tmux new-session -d -s "$SESSION" bash -c "
    cd $DIR && \
    RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
      --npc-socket $SOCKET \
      --mining-pubkey $PUBKEY \
      --bind /ip4/0.0.0.0/udp/${PORT}/quic-v1 \
      --mine
  "

  echo "✅ Launched miner $i in tmux session: $SESSION"
done

echo "🚀 All $MINER_COUNT miners are running with unique ports."
echo "👉 Use: tmux ls   to view them"
