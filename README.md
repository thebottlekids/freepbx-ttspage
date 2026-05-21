A FreePBX module that lets you broadcast text-to-speech messages to any extension on your system using Piper TTS. Type a message, pick a voice, select your extensions, and hit broadcast — that's it.

## Features
- Text-to-speech broadcasting using Piper TTS
- Multiple US English voices to choose from
- Dynamically pulls extensions from FreePBX — no hardcoding needed
- Select All button for quick system-wide broadcasting
- Built directly into the FreePBX Admin menu
- Audio automatically converted to Asterisk-compatible format

## Requirements
- FreePBX 17
- Debian 12
- Piper TTS
- Sox
- PHP 8.2
- PJSIP extensions

## Installation

### 1. Install Piper TTS
```bash
cd /tmp
wget https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz
tar -xzf piper_linux_x86_64.tar.gz
sudo rm -rf /usr/local/bin/piper
sudo mv /tmp/piper/piper /usr/local/bin/
sudo mv /tmp/piper/lib* /usr/local/lib/
sudo ldconfig
sudo apt-get install espeak-ng -y
sudo mv /tmp/piper/espeak-ng-data /usr/share/espeak-ng-data
```

### 2. Download Voice Models
```bash
mkdir -p /usr/local/share/piper/voices
cd /usr/local/share/piper/voices
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx.json
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx.json
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kathleen/low/en_US-kathleen-low.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kathleen/low/en_US-kathleen-low.onnx.json
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/joe/medium/en_US-joe-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/joe/medium/en_US-joe-medium.onnx.json
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kusal/medium/en_US-kusal-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/kusal/medium/en_US-kusal-medium.onnx.json
```

### 3. Install Sox
```bash
apt-get install sox -y
```

### 4. Install the Broadcast Script
```bash
cp broadcast.sh /usr/local/bin/broadcast.sh
chmod +x /usr/local/bin/broadcast.sh
usermod -aG asterisk www-data
systemctl restart apache2
```

### 5. Install the FreePBX Module
```bash
cp -r ttspage /var/www/html/admin/modules/
fwconsole ma install ttspage
fwconsole reload
```

### 6. Add Dialplan Context
Add the following to `/etc/asterisk/extensions_custom.conf`:s,1,NoOp(Starting broadcast)
exten => s,n,Set(PJSIP_HEADER(Alert-Info)=http://www.notused.com;info=alert-autoanswer;delay=0)
exten => s,n,Set(PJSIP_HEADER(Call-Info)=http://www.notused.com;answer-after=0)
exten => s,n,Wait(2)
exten => s,n,Playback(${AUDIO_FILE})
exten => s,n,Hangup()
Then reload:
```bash
asterisk -rx "dialplan reload"
```

## Usage
1. Log into FreePBX
2. Go to **Admin > TTS Page**
3. Type your message in the text box
4. Select a voice from the dropdown
5. Check the extensions you want to broadcast to
6. Click **📣 Broadcast**

The system will generate the audio using Piper TTS, convert it to the correct format, and call each selected extension playing the message.

## Author
Michael Knudsen
https://github.com/thebottlekids
EOF
