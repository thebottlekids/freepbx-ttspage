#!/bin/bash

echo "=== TTS Page Installer ==="

# Install dependencies
echo "[1/6] Installing dependencies..."
apt-get install -y sox espeak-ng

# Install Piper
echo "[2/6] Installing Piper TTS..."
cd /tmp
wget -q https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz
tar -xzf piper_linux_x86_64.tar.gz
rm -rf /usr/local/bin/piper
mv /tmp/piper/piper /usr/local/bin/
mv /tmp/piper/lib* /usr/local/lib/
mv /tmp/piper/espeak-ng-data /usr/share/espeak-ng-data
ldconfig

# Download voice models
echo "[3/6] Downloading voice models..."
mkdir -p /usr/local/share/piper/voices
cd /usr/local/share/piper/voices
BASE="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US"
wget -q $BASE/lessac/medium/en_US-lessac-medium.onnx
wget -q $BASE/lessac/medium/en_US-lessac-medium.onnx.json
wget -q $BASE/amy/medium/en_US-amy-medium.onnx
wget -q $BASE/amy/medium/en_US-amy-medium.onnx.json
wget -q $BASE/ryan/high/en_US-ryan-high.onnx
wget -q $BASE/ryan/high/en_US-ryan-high.onnx.json
wget -q $BASE/kathleen/low/en_US-kathleen-low.onnx
wget -q $BASE/kathleen/low/en_US-kathleen-low.onnx.json
wget -q $BASE/joe/medium/en_US-joe-medium.onnx
wget -q $BASE/joe/medium/en_US-joe-medium.onnx.json
wget -q $BASE/kusal/medium/en_US-kusal-medium.onnx
wget -q $BASE/kusal/medium/en_US-kusal-medium.onnx.json

# Install broadcast script
echo "[4/6] Installing broadcast script..."
mkdir -p /var/www/html/admin/modules/ttspage
cd /var/www/html/admin/modules/ttspage
wget -q https://raw.githubusercontent.com/thebottlekids/freepbx-ttspage/main/broadcast.sh
wget -q https://raw.githubusercontent.com/thebottlekids/freepbx-ttspage/main/module.xml
wget -q https://raw.githubusercontent.com/thebottlekids/freepbx-ttspage/main/page.ttspage.php
cp broadcast.sh /usr/local/bin/broadcast.sh
chmod +x /usr/local/bin/broadcast.sh
usermod -aG asterisk www-data

# Set up dialplan
echo "[5/6] Setting up Asterisk dialplan..."
cat >> /etc/asterisk/extensions_custom.conf << 'DIALPLAN'

[broadcast-announce]
exten => s,1,NoOp(Starting broadcast)
exten => s,n,Set(PJSIP_HEADER(Alert-Info)=<http://www.notused.com>;info=alert-autoanswer;delay=0)
exten => s,n,Set(PJSIP_HEADER(Call-Info)=<http://www.notused.com>;answer-after=0)
exten => s,n,Wait(2)
exten => s,n,Playback(${AUDIO_FILE})
exten => s,n,Hangup()
DIALPLAN

asterisk -rx "dialplan reload"

# Install FreePBX module
echo "[6/6] Installing FreePBX module..."
fwconsole ma install ttspage
fwconsole reload
systemctl restart apache2

echo ""
echo "=== Installation Complete! ==="
echo "Go to FreePBX Admin > TTS Page to use the module."
