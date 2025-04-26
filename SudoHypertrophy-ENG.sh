#!/bin/bash

#$$$$$$$$\                  $$\                 $$\                                     $$$$$$$\                            $$$$$$$$\
#\__$$  __|                 $$ |                $$ |                                    $$  __$$\                           \__$$  __|
#   $$ | $$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\  $$ | $$$$$$\  $$$$$$$\   $$$$$$\        $$ |  $$ | $$$$$$\   $$$$$$\           $$ |$$\   $$\ $$\   $$\
#   $$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$ |$$  __$$\ $$  __$$\  \____$$\       $$$$$$$  |$$  __$$\ $$  __$$\          $$ |$$ |  $$ |\$$\ $$  |
#   $$ |$$ |  \__|$$$$$$$$ |$$ |  $$ |$$ /  $$ |$$ |$$ /  $$ |$$ |  $$ | $$$$$$$ |      $$  ____/ $$ |  \__|$$ /  $$ |         $$ |$$ |  $$ | \$$$$  /
#   $$ |$$ |      $$   ____|$$ |  $$ |$$ |  $$ |$$ |$$ |  $$ |$$ |  $$ |$$  __$$ |      $$ |      $$ |      $$ |  $$ |         $$ |$$ |  $$ | $$  $$<
#   $$ |$$ |      \$$$$$$$\ $$$$$$$  |\$$$$$$  |$$ |\$$$$$$  |$$ |  $$ |\$$$$$$$ |      $$ |      $$ |      \$$$$$$  |         $$ |\$$$$$$  |$$  /\$$\
#   \__|\__|       \_______|\_______/  \______/ \__| \______/ \__|  \__| \_______|      \__|      \__|       \______/          \__| \______/ \__/  \__|
#
#
#░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░
#░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
#░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░    ░▒▓██▓▒░░▒▓█▓▒░░▒▓█▓▒░
#░▒▓███████▓▒░ ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓██▓▒░  ░▒▓███████▓▒░
#░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██▓▒░    ░▒▓█▓▒░░▒▓█▓▒░
#░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░
#░▒▓███████▓▒░   ░▒▓█▓▒░           ░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░


# Array to store PIDs of music processes
MUSIC_PIDS=()

# Function to play looping music
play_looping_music() {
    # A link to a YouTube music video
    local youtube_url="https://www.youtube.com/watch?v=JocAXINz-YE"  # Replace with your favorite link

    # Check and install MPV which can play directly from YouTube
    if ! command -v mpv &> /dev/null; then
        echo "📦 Installing MPV to play music..."
        sudo apt update && sudo apt install -y mpv
    fi

    # Method 1: Using MPV with loop
    if command -v mpv &> /dev/null; then
        echo "🎵 Starting background music in loop..."
        mpv --no-video --volume=70 --loop-file=inf --really-quiet "$youtube_url" &
        MUSIC_PIDS+=($!)
        return 0
    fi

    # Method 2: Installing mpg123 and youtube-dl as fallback
    echo "⚠️ MPV not available. Trying alternative method..."

    # Install youtube-dl
    if ! command -v youtube-dl &> /dev/null; then
        echo "📦 Installing youtube-dl..."
        sudo apt update && sudo apt install -y youtube-dl
    fi

    # Install mpg123
    if ! command -v mpg123 &> /dev/null; then
        echo "📦 Installing mpg123..."
        sudo apt install -y mpg123
    fi

    # Location to save temporary file
    local music_file="/tmp/trebolona_music.mp3"

    # Download the music
    echo "🎵 Downloading music from YouTube..."
    youtube-dl -x --audio-format mp3 -o "$music_file" "$youtube_url"

    # Check if the download was successful
    if [ -f "$music_file" ]; then
        # Start the music loop in the background
        echo "Starting music to help Tux's workout..."
        while true; do
            mpg123 -q "$music_file"
            # If the script is interrupted, this loop will stop as well
            sleep 1
        done &
        MUSIC_PIDS+=($!)
    else
        echo "⚠️ Unable to download the music. Continuing without music..."
        return 1
    fi
}

# Function to check if music is still playing and restart if necessary
monitor_music() {
    # Check every 10 seconds if the music is still playing
    while true; do
        sleep 10

        # Check if any of the music processes are still running
        local music_running=0
        for pid in "${MUSIC_PIDS[@]}"; do
            if ps -p $pid > /dev/null; then
                music_running=1
                break
            fi
        done

        # If no music process is running, restart the music
        if [ $music_running -eq 0 ]; then
            echo "🎵 Restarting background music..."
            play_looping_music
        fi
    done
}

# Function to stop all music processes
stop_all_music() {
    echo "🎵 Stopping all background music..."

    # Kill all music processes saved
    for pid in "${MUSIC_PIDS[@]}"; do
        kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done

    # Ensure no mpv or mpg123 process is running
    killall mpv 2>/dev/null || true
    killall mpg123 2>/dev/null || true

    # Clear the PID array
    MUSIC_PIDS=()
}

# Ensure music stops when the script exits
trap stop_all_music EXIT

# ========= Welcome =========
echo -e "\e[1;32m"
echo "========================================================="
echo "             The Beast Is Unleashed!"
echo "    Software is like sex: it's better when it's free."
echo "                   -Linus Torvalds"
echo "========================================================="
echo -e "\e[0m"

# Start the background music
play_looping_music

# Start the music monitor in the background to ensure it keeps playing
monitor_music &
MUSIC_PIDS+=($!)

read -p "Press Y to Inject or any other key to cancel: " choice

if [[ $choice != [Yy] ]]; then
    echo "❌ Chicken out? Get outta here!"
    exit 1
fi

echo "✅ Preparing the Needle, Hold on tight!"
sleep 1

# ========= System Update =========
echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

# ========= Flatpak and Integration =========
echo "=== Installing and configuring Flatpak ==="

# Install Flatpak
sudo apt install -y flatpak

# Add official Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ========= NVIDIA Driver =========
echo "=== Installing NVIDIA driver 570 ==="
sudo apt install -y nvidia-driver-570

# ========= Liquorix Kernel =========
echo "=== Adding Liquorix Repo ==="
echo "deb http://liquorix.net/debian liquorix main" | sudo tee /etc/apt/sources.list.d/liquorix.list
curl -s https://liquorix.net/liquorix.asc | sudo tee /etc/apt/trusted.gpg.d/liquorix.asc
sudo apt update
sudo apt install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

# ========= Flatpak Apps =========
echo "=== Installing apps via Flatpak ==="
flatpak install flathub -y \
    com.discordapp.Discord \
    com.github.nukeop.nuclear \
    com.kassent.cubiomes-viewer \
    io.github.woxel.woxel \
    io.github.jnbt.editor \
    net.davidotek.pupgui2 \
    org.prismlauncher.PrismLauncher \
    com.mojang.Minecraft \
    org.mozilla.firefox \
    org.kde.kdenlive \
    com.obsproject.Studio \
    org.gimp.GIMP \
    com.github.tchx84.Flatseal \
    com.github.oguzhaninan.stacer \
    com.usebottles.bottles \
    org.libretro.RetroArch \
    app.drey.Warp \
    io.github.ilya_zlobintsev.LACT \
    org.qbittorrent.qBittorrent \
    com.github.Matoking.protontricks \
    md.obsidian.Obsidian \
    org.gnome.Boxes \
    org.winehq.Wine \
    net.nokyan.Resources \
    com.warlordsoftwares.youtube-downloader-4ktube \
    org.jdownloader.JDownloader \
    io.github.jeffshee.Hidamari \
    com.github.KRTirtho.Spotube \
    com.modrinth.ModrinthApp \
    com.sublimetext.three

# ========= Optimizations =========
echo "=== Applying system optimizations ==="

# sysctl tweaks
sudo tee /etc/sysctl.d/99-gaming-tweaks.conf > /dev/null <<EOF
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
vm.swappiness = 10
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
EOF
sudo sysctl --system

# Fast DNS
echo "nameserver 1.1.1.3" | sudo tee /etc/resolv.conf
echo "nameserver 1.0.0.2" | sudo tee -a /etc/resolv.conf

# Enable ZRAM
sudo apt install -y zram-tools
sudo tee /etc/default/zramswap > /dev/null <<EOF
ALGO=lz4
PERCENT=50
EOF
sudo systemctl enable --now zramswap

# Disable unnecessary services
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

echo "✅ Trebolona successfully injected!"
echo "🔁 Restart Linux for the Trebolona to take effect."

# Stop all music before exiting
stop_all_music


# [-----Alright_K.Dot-------]
# Alls my life, I has to fight, Nigga!
# Alls my life, I—hard times like, "Yah!"
# Bad trips like, "Yah!"
# Nazareth
# Nigga, you did it right?

# And we hate po-po, wanna kill us dead in the street fo sho'
# Nigga, I'm at the preacher's door
# My knees gettin' weak, and my gun might blow
# But we gon' be alright
# We gon' be alright
# We gon' be alright
# We gon' be alright
# Do you hear me, do you feel me? We gon' be alright
# We gon' be alright
# We gon' be alright
# We gon' be alright
# Do you hear me, do you feel me? We gon' be alright

# Uh, I keep my head up high
# I cross my heart and hope to die
# Lovin' me is not an option
# So, I keep tryin', tryin', tryin'
# And I never, ever stop, no
# No matter what they tryin' to say about me,
# I’m just me, real as they come
# Knowin' that I’m gon' rise above it all

# And we hate po-po, wanna kill us dead in the street fo sho'
# Nigga, I'm at the preacher's door
# My knees gettin' weak, and my gun might blow
# But we gon' be alright
# We gon' be alright
# We gon' be alright
# We gon' be alright
# Do you hear me, do you feel me? We gon' be alright
# We gon' be alright
# We gon' be alright
# We gon' be alright
# Do you hear me, do you feel me? We gon' be alright

# I know we been hurtin', but we gon' be alright
# I know we been tryin', but we gon' be alright
# I know we been cryin', but we gon' be alright
# We gon' be alright (Yeah)
# We gon' be alright (Uh)
# We gon' be alright
# We gon' be alright
# We gon' be alright



#                                                                 #####
#                                                                #######
#                   #                                            ##O#O##
#  ######          ###                                           #VVVVV#
#    ##             #                                          ##  VVV  ##
#    ##         ###    ### ####   ###    ###  ##### #####     #          ##
#    ##        #  ##    ###    ##  ##     ##    ##   ##      #            ##
#    ##       #   ##    ##     ##  ##     ##      ###        #            ###
#    ##          ###    ##     ##  ##     ##      ###       QQ#           ##Q
#    ##       # ###     ##     ##  ##     ##     ## ##    QQQQQQ#       #QQQQQQ
#    ##      ## ### #   ##     ##  ###   ###    ##   ##   QQQQQQQ#     #QQQQQQQ
#  ############  ###   ####   ####   #### ### ##### #####   QQQQQ#######QQQQQ


# 1. Software is like sex: it's better when it's free.
# 2. Microsoft is not evil. They just make really bad operating systems.
# 3. My name is Linus, and I am your God.
# 4. Look, you don't just have to be a good programmer to create something like Linux. You also have to be a damn bastard.
# 5. The philosophy of Linux is 'Laugh in the face of danger.' Oops. Wrong. 'Do it yourself.' Yeah, that's it.
# 6. Some people have told me they don’t think a chubby penguin really embodies the grace of Linux. Which tells me they've never seen an angry penguin chasing them at 100 miles per hour.
# 7. Intelligence is the ability to avoid doing work, yet still get the work done.
# 8. Seriously, I don’t aim to destroy Microsoft. This will be a completely involuntary side effect.
# 9. Now, many of you will probably get totally bored during the Christmas holiday, and here’s the perfect distraction. Test the new Kernel. All the stores will be closed, and there’s really nothing better to do between meals.
# 10. If Microsoft makes applications for Linux, that means I’ve won.
# 11. In my opinion, Microsoft is much better at making money than operating systems.
# 12. They never called me a nice guy. I’m somewhere between geeks and normal.
# 13. Talking is easy, show me the code.

# Linus Torvalds, the creator of Linux, is the kind of guy who isn’t afraid to speak his mind, and these quotes are a perfect example of that.
# He has a unique, often irreverent perspective on the world of technology, especially when it comes to free software and Linux.
# His words, although sometimes a bit harsh, reflect the spirit of the open-source movement and the freedom of choice in the world of computing.
# These quotes represent the bold attitude that helped make Linux what it is today, and how it became one of the cornerstones of the digital revolution.
#
# A big thank you to the Diolinux and DiolinuxLabs channels for their invaluable help in guiding us through the process of migrating to Linux.
# Their tutorials and explanations have made it easier to understand Linux, its benefits, and how to make the switch seamlessly. Without their content, many would have struggled to dive into the world of Linux.
# Thanks, Ozk
