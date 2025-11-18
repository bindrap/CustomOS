#!/bin/bash
# Emoji picker using wofi

EMOJI_LIST="😀 Grinning Face
😃 Grinning Face with Big Eyes
😄 Grinning Face with Smiling Eyes
😁 Beaming Face with Smiling Eyes
😆 Grinning Squinting Face
😅 Grinning Face with Sweat
🤣 Rolling on the Floor Laughing
😂 Face with Tears of Joy
🙂 Slightly Smiling Face
🙃 Upside-Down Face
😉 Winking Face
😊 Smiling Face with Smiling Eyes
😇 Smiling Face with Halo
🥰 Smiling Face with Hearts
😍 Smiling Face with Heart-Eyes
🤩 Star-Struck
😘 Face Blowing a Kiss
😗 Kissing Face
😚 Kissing Face with Closed Eyes
😙 Kissing Face with Smiling Eyes
😋 Face Savoring Food
😛 Face with Tongue
😜 Winking Face with Tongue
🤪 Zany Face
😝 Squinting Face with Tongue
🤑 Money-Mouth Face
🤗 Hugging Face
🤭 Face with Hand Over Mouth
🤫 Shushing Face
🤔 Thinking Face
🤐 Zipper-Mouth Face
🤨 Face with Raised Eyebrow
😐 Neutral Face
😑 Expressionless Face
😶 Face Without Mouth
😏 Smirking Face
😒 Unamused Face
🙄 Face with Rolling Eyes
😬 Grimacing Face
🤥 Lying Face
😌 Relieved Face
😔 Pensive Face
😪 Sleepy Face
🤤 Drooling Face
😴 Sleeping Face
😷 Face with Medical Mask
🤒 Face with Thermometer
🤕 Face with Head-Bandage
🤢 Nauseated Face
🤮 Face Vomiting
🤧 Sneezing Face
🥵 Hot Face
🥶 Cold Face
😎 Smiling Face with Sunglasses
🤓 Nerd Face
🧐 Face with Monocle
😕 Confused Face
😟 Worried Face
🙁 Slightly Frowning Face
😮 Face with Open Mouth
😯 Hushed Face
😲 Astonished Face
😳 Flushed Face
🥺 Pleading Face
😦 Frowning Face with Open Mouth
😧 Anguished Face
😨 Fearful Face
😰 Anxious Face with Sweat
😥 Sad but Relieved Face
😢 Crying Face
😭 Loudly Crying Face
😱 Face Screaming in Fear
😖 Confounded Face
😣 Persevering Face
😞 Disappointed Face
😓 Downcast Face with Sweat
😩 Weary Face
😫 Tired Face
🥱 Yawning Face
😤 Face with Steam From Nose
😡 Pouting Face
😠 Angry Face
🤬 Face with Symbols on Mouth
😈 Smiling Face with Horns
👿 Angry Face with Horns
💀 Skull
💩 Pile of Poo
🤡 Clown Face
👻 Ghost
👽 Alien
👾 Alien Monster
🤖 Robot
🎃 Jack-O-Lantern
😺 Grinning Cat
😸 Grinning Cat with Smiling Eyes
😹 Cat with Tears of Joy
😻 Smiling Cat with Heart-Eyes
😼 Cat with Wry Smile
😽 Kissing Cat
🙀 Weary Cat
😿 Crying Cat
😾 Pouting Cat
❤️ Red Heart
🧡 Orange Heart
💛 Yellow Heart
💚 Green Heart
💙 Blue Heart
💜 Purple Heart
🖤 Black Heart
🤍 White Heart
🤎 Brown Heart
💔 Broken Heart
❣️ Heart Exclamation
💕 Two Hearts
💞 Revolving Hearts
💓 Beating Heart
💗 Growing Heart
💖 Sparkling Heart
💘 Heart with Arrow
💝 Heart with Ribbon
💟 Heart Decoration
✨ Sparkles
💫 Dizzy
💥 Collision
💯 Hundred Points
🔥 Fire
⚡ High Voltage
💧 Droplet
🌟 Glowing Star
⭐ Star
✅ Check Mark Button
✔️ Check Mark
❌ Cross Mark
❎ Cross Mark Button
🚀 Rocket
💻 Laptop
⌨️ Keyboard
🖥️ Desktop Computer
🖱️ Computer Mouse
💾 Floppy Disk
💿 Optical Disk
📀 DVD
🎮 Video Game
🎯 Direct Hit
🎲 Game Die
♠️ Spade Suit
♥️ Heart Suit
♦️ Diamond Suit
♣️ Club Suit
🏆 Trophy
🥇 1st Place Medal
🥈 2nd Place Medal
🥉 3rd Place Medal
🏅 Sports Medal
🎖️ Military Medal
📌 Pushpin
📍 Round Pushpin
🚩 Triangular Flag
🏁 Chequered Flag
🎵 Musical Note
🎶 Musical Notes
🎤 Microphone
🎧 Headphone
📻 Radio
🎸 Guitar
🎹 Musical Keyboard
🎺 Trumpet
🎻 Violin
🥁 Drum
📱 Mobile Phone
☎️ Telephone
📞 Telephone Receiver
📟 Pager
📠 Fax Machine
🔋 Battery
🔌 Electric Plug
💡 Light Bulb
🔦 Flashlight
🕯️ Candle
🔔 Bell
🔕 Bell with Slash
📢 Loudspeaker
📣 Megaphone
⏰ Alarm Clock
⏱️ Stopwatch
⏲️ Timer Clock
🕐 One O'Clock
📅 Calendar
📆 Tear-Off Calendar
📝 Memo
📄 Page Facing Up
📃 Page with Curl
📋 Clipboard
📊 Bar Chart
📈 Chart Increasing
📉 Chart Decreasing
📌 Pushpin
📍 Round Pushpin
🔍 Magnifying Glass Tilted Left
🔎 Magnifying Glass Tilted Right
🔒 Locked
🔓 Unlocked
🔐 Locked with Key
🔑 Key
🗝️ Old Key
🔨 Hammer
⚒️ Hammer and Pick
🛠️ Hammer and Wrench
🔧 Wrench
🔩 Nut and Bolt
⚙️ Gear
🗜️ Clamp
⚖️ Balance Scale
🔗 Link
⛓️ Chains
🧰 Toolbox
🧲 Magnet
⚗️ Alembic
🧪 Test Tube
🧫 Petri Dish
🧬 DNA
🔬 Microscope
🔭 Telescope
📡 Satellite Antenna
💉 Syringe
💊 Pill
🩹 Adhesive Bandage
🩺 Stethoscope"

SELECTED=$(echo "$EMOJI_LIST" | wofi --dmenu --width 400 --height 600 --prompt "Select Emoji")

if [ -n "$SELECTED" ]; then
    EMOJI=$(echo "$SELECTED" | awk '{print $1}')
    echo -n "$EMOJI" | wl-copy
    notify-send "Emoji Copied" "$EMOJI" -t 1000
fi
