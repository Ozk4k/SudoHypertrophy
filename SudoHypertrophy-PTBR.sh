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
#░▒▓███████▓▒░   ░▒▓█▓▒░           ░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ & ChatGPT, ClaudeAI :p (Helped so much)

# Array para guardar PIDs dos processos de música
MUSIC_PIDS=()

# Função para tocar música em loop
play_looping_music() {
    # Um link para música do YouTube
    local youtube_url="https://www.youtube.com/watch?v=JocAXINz-YE"  # Substitua pelo seu link preferido

    # Verificar e instalar MPV que pode tocar diretamente do YouTube
    if ! command -v mpv &> /dev/null; then
        echo "📦 Instalando MPV para reproduzir música..."
        sudo apt update && sudo apt install -y mpv
    fi

    # Método 1: Usando MPV com loop
    if command -v mpv &> /dev/null; then
        echo "🎵 Iniciando música de fundo em loop..."
        mpv --no-video --volume=70 --loop-file=inf --really-quiet "$youtube_url" &
        MUSIC_PIDS+=($!)
        return 0
    fi

    # Método 2: Instalando mpg123 e youtube-dl como fallback
    echo "⚠️ MPV não disponível. Tentando método alternativo..."

    # Instalar youtube-dl
    if ! command -v youtube-dl &> /dev/null; then
        echo "📦 Instalando youtube-dl..."
        sudo apt update && sudo apt install -y youtube-dl
    fi

    # Instalar mpg123
    if ! command -v mpg123 &> /dev/null; then
        echo "📦 Instalando mpg123..."
        sudo apt install -y mpg123
    fi

    # Local para salvar o arquivo temporário
    local music_file="/tmp/trebolona_music.mp3"

    # Baixar a música
    echo "🎵 Baixando música do YouTube..."
    youtube-dl -x --audio-format mp3 -o "$music_file" "$youtube_url"

    # Verificar se o download foi bem-sucedido
    if [ -f "$music_file" ]; then
        # Iniciar o loop de música em background
        echo "Iniciando música Pra Ajudar no treino do Tux..."
        while true; do
            mpg123 -q "$music_file"
            # Se o script for interrompido, este loop também será
            sleep 1
        done &
        MUSIC_PIDS+=($!)
    else
        echo "⚠️ Não foi possível baixar a música. Continuando sem música..."
        return 1
    fi
}

# Função para verificar se a música está tocando e reiniciar se necessário
monitor_music() {
    # Verifica a cada 10 segundos se a música ainda está tocando
    while true; do
        sleep 10

        # Verifica se algum dos processos de música ainda está em execução
        local music_running=0
        for pid in "${MUSIC_PIDS[@]}"; do
            if ps -p $pid > /dev/null; then
                music_running=1
                break
            fi
        done

        # Se nenhum processo de música estiver em execução, reinicia a música
        if [ $music_running -eq 0 ]; then
            echo "🎵 Reiniciando música de fundo..."
            play_looping_music
        fi
    done
}

# Função para parar todos os processos de música
stop_all_music() {
    echo "🎵 Parando toda música de fundo..."

    # Mata todos os processos de música salvos
    for pid in "${MUSIC_PIDS[@]}"; do
        kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null
    done

    # Garante que nenhum processo mpv ou mpg123 fique rodando
    killall mpv 2>/dev/null || true
    killall mpg123 2>/dev/null || true

    # Limpa o array de PIDs
    MUSIC_PIDS=()
}

# Garante que a música pare quando o script terminar
trap stop_all_music EXIT

# ========= Bem-vindo =========
echo -e "\e[1;32m"
echo "========================================================="
echo "             Vai sai da jaula o Monstro"
echo "    Software é como sexo: é melhor quando é de graça."
echo "                   -Linus Torvalds"
echo "========================================================="
echo -e "\e[0m"

# Iniciar a música de fundo
play_looping_music

# Iniciar o monitor de música em background para garantir que continue tocando
monitor_music &
MUSIC_PIDS+=($!)

read -p "Aperte Y para Injetar ou qualquer outra tecla para cancelar: " choice

if [[ $choice != [Yy] ]]; then
    echo "❌ Peidou?, Vaza!."
    exit 1
fi

echo "✅ Preparando a Agulha, Segura o monstro!"
sleep 1

# ========= Atualização =========
echo "=== Atualizando o sistema ==="
sudo apt update && sudo apt upgrade -y

# ========= Flatpak e Integração =========
echo "=== Instalando e configurando o Flatpak ==="

# Instala o Flatpak
sudo apt install -y flatpak

# Adiciona o repositório oficial Flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ========= Driver NVIDIA =========
echo "=== Instalando driver NVIDIA 570 ==="
sudo apt install -y nvidia-driver-570

# ========= Kernel Liquorix =========
echo "=== Adicionando Repo Liquorix ==="
echo "deb http://liquorix.net/debian liquorix main" | sudo tee /etc/apt/sources.list.d/liquorix.list
curl -s https://liquorix.net/liquorix.asc | sudo tee /etc/apt/trusted.gpg.d/liquorix.asc
sudo apt update
sudo apt install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

# ========= Flatpak Apps =========
echo "=== Instalando apps via Flatpak ==="
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

# ========= Otimizações =========
echo "=== Aplicando otimizações de sistema ==="

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

# DNS rápido
echo "nameserver 1.1.1.3" | sudo tee /etc/resolv.conf
echo "nameserver 1.0.0.2" | sudo tee -a /etc/resolv.conf

# Ativar ZRAM
sudo apt install -y zram-tools
sudo tee /etc/default/zramswap > /dev/null <<EOF
ALGO=lz4
PERCENT=50
EOF
sudo systemctl enable --now zramswap

# Desativar serviços desnecessários
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

echo "✅ Trebolona Injetada Com Sucesso!"
echo "🔁 Reinicie o linux para a Trebolona dar Efeito."

# Parar toda a música antes de sair
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
