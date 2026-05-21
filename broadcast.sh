#!/bin/bash
MESSAGE="$1"
VOICE="$2"
EXTENSIONS="${@:3}"
TIMESTAMP=$(date +%s)
AUDIO_FILE="/var/lib/asterisk/sounds/broadcast_${TIMESTAMP}.wav"
VOICE_MODEL="/usr/local/share/piper/voices/${VOICE}.onnx"

if [ ! -f "$VOICE_MODEL" ]; then
  VOICE_MODEL="/usr/local/share/piper/voices/en_US-lessac-medium.onnx"
fi

echo "$MESSAGE" | piper \
  --model "$VOICE_MODEL" \
  --output_file "$AUDIO_FILE"

sox "$AUDIO_FILE" -r 8000 -c 1 -e signed-integer -b 16 "${AUDIO_FILE%.*}_converted.wav"
sox "${AUDIO_FILE%.*}_converted.wav" "$AUDIO_FILE" pad 1 0
rm "${AUDIO_FILE%.*}_converted.wav"

chown asterisk:asterisk "$AUDIO_FILE"

for EXT in $EXTENSIONS; do
  case $EXT in
    201|202) ALERT_INFO="Auto Answer" ;;
    *) ALERT_INFO="info=alert-autoanswer" ;;
  esac

  CALL_FILE="/var/spool/asterisk/outgoing/broadcast_${EXT}_${TIMESTAMP}.call"
  printf "Channel: PJSIP/%s\nCallerID: Broadcast <0000>\nMaxRetries: 0\nRetryTime: 10\nWaitTime: 20\nSetvar: ALERT_INFO=%s\nSetvar: AUDIO_FILE=%s\nContext: broadcast-announce\nExtension: s\nPriority: 1\n" "$EXT" "$ALERT_INFO" "${AUDIO_FILE%.*}" > "$CALL_FILE"
  chown asterisk:asterisk "$CALL_FILE"
done
