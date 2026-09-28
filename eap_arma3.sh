#!/bin/bash

# ==============================================================================
# INSTALADOR AUTOMÁTICO DE ATALHO E ÍCONE MILITAR (Executa apenas se necessário)
# ==============================================================================
setup_desktop_integration() {
    local ICON_DIR="$HOME/.local/share/icons"
    local APPS_DIR="$HOME/.local/share/applications"
    local DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
    local ICON_FILE="$ICON_DIR/arma3-eap.svg"
    local DESKTOP_FILE="$APPS_DIR/arma3-eap.desktop"
    local CURRENT_SCRIPT="$(readlink -f "$0")"

    mkdir -p "$ICON_DIR" "$APPS_DIR"

    # 1. Cria o ícone militar SVG caso não exista
    if [ ! -f "$ICON_FILE" ]; then
        cat << 'EOF' > "$ICON_FILE"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="100%" height="100%">
  <defs>
    <radialGradient id="bgGrad" cx="50%" cy="50%" r="65%">
      <stop offset="0%" stop-color="#242c22"/>
      <stop offset="70%" stop-color="#141a12"/>
      <stop offset="100%" stop-color="#0b0e0a"/>
    </radialGradient>
    <linearGradient id="goldBorder" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#e5b342"/>
      <stop offset="50%" stop-color="#8a6b22"/>
      <stop offset="100%" stop-color="#d49b29"/>
    </linearGradient>
    <filter id="dropShadow" x="-10%" y="-10%" width="120%" height="130%">
      <feDropShadow dx="0" dy="8" stdDeviation="10" flood-color="#000000" flood-opacity="0.85"/>
    </filter>
  </defs>
  <polygon points="256,22 466,88 436,378 256,488 76,378 46,88" fill="url(#bgGrad)" stroke="url(#goldBorder)" stroke-width="12" stroke-linejoin="round" filter="url(#dropShadow)" />
  <polygon points="256,42 444,102 418,360 256,460 94,360 68,102" fill="none" stroke="#4d5c47" stroke-width="3" stroke-dasharray="14,8" stroke-linejoin="round" />
  <g stroke="#e5b342" opacity="0.85" stroke-linecap="square">
    <circle cx="256" cy="225" r="95" fill="none" stroke="#e5b342" stroke-width="3.5"/>
    <circle cx="256" cy="225" r="50" fill="none" stroke="#e5b342" stroke-width="2" stroke-dasharray="6,6"/>
    <circle cx="256" cy="225" r="4" fill="#e5b342"/>
    <line x1="256" y1="95" x2="256" y2="175" stroke-width="3.5"/>
    <line x1="256" y1="275" x2="256" y2="355" stroke-width="3.5"/>
    <line x1="126" y1="225" x2="206" y2="225" stroke-width="3.5"/>
    <line x1="306" y1="225" x2="386" y2="225" stroke-width="3.5"/>
    <line x1="244" y1="300" x2="268" y2="300" stroke-width="2.5"/>
    <line x1="248" y1="325" x2="264" y2="325" stroke-width="2.5"/>
  </g>
  <path d="M 190,135 L 256,105 L 322,135" fill="none" stroke="#d49b29" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M 205,155 L 256,132 L 307,155" fill="none" stroke="#8a6b22" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="256" y="240" font-family="'Impact', 'Arial Black', sans-serif" font-size="44" font-weight="900" letter-spacing="5" fill="#f5f7f2" text-anchor="middle" stroke="#10140e" stroke-width="2">EAP</text>
  <rect x="156" y="380" width="200" height="32" rx="4" fill="#1b2219" stroke="#e5b342" stroke-width="2"/>
  <text x="256" y="403" font-family="'Courier New', monospace" font-size="20" font-weight="bold" letter-spacing="4" fill="#e5b342" text-anchor="middle">MIL-SIM</text>
</svg>
EOF
    fi

    # 2. Detecta automaticamente o emulador de terminal disponível no sistema
    local TERM_CMD=""
    if command -v x-terminal-emulator >/dev/null 2>&1; then
        TERM_CMD="x-terminal-emulator -e"
    elif command -v io.elementary.terminal >/dev/null 2>&1; then
        TERM_CMD="io.elementary.terminal -e"
    elif command -v cosmic-term >/dev/null 2>&1; then
        TERM_CMD="cosmic-term -e"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        TERM_CMD="gnome-terminal --"
    elif command -v konsole >/dev/null 2>&1; then
        TERM_CMD="konsole -e"
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        TERM_CMD="xfce4-terminal -e"
    fi

    # 3. Monta a linha Exec com suporte a caminhos com espaços
    local EXEC_LINE=""
    local IS_TERMINAL="false"
    if [ -n "$TERM_CMD" ]; then
        EXEC_LINE="$TERM_CMD bash -c '\"$CURRENT_SCRIPT\"; exec bash'"
    else
        EXEC_LINE="bash -c '\"$CURRENT_SCRIPT\"'"
        IS_TERMINAL="true"
    fi

    # 4. Gera o arquivo .desktop
    cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=Arma 3 - EAP Launcher
Comment=Gerenciador de Mods e Launcher Arma 3
Exec=$EXEC_LINE
Icon=$ICON_FILE
Terminal=$IS_TERMINAL
Categories=Game;
StartupNotify=true
EOF
    chmod +x "$DESKTOP_FILE"

    # Atualiza a Área de Trabalho (Desktop)
    if [ -d "$DESKTOP_DIR" ]; then
        cp "$DESKTOP_FILE" "$DESKTOP_DIR/" 2>/dev/null
        chmod +x "$DESKTOP_DIR/arma3-eap.desktop" 2>/dev/null
        gio set "$DESKTOP_DIR/arma3-eap.desktop" metadata::trusted true 2>/dev/null
    fi
}

setup_desktop_integration

# --- Cores e Estilo ---
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
NC='\033[0m'
B_VERDE='\033[1;32m'
CYAN='\033[0;36m'

# --- Carregamento do Arquivo de Ambiente (.env) ---
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

# Se o .env não existir, cria a partir do .env.example
if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        echo -e "${VERDE}[!] Arquivo .env criado a partir de .env.example.${NC}"
    else
        echo -e "${VERMELHO}[X] Erro: Arquivo .env não encontrado em $SCRIPT_DIR${NC}"
        exit 1
    fi
fi

# Carrega e avalia as variáveis do .env garantindo expansão de variáveis ($HOME)
set -a
# shellcheck disable=SC1090
source <(envsubst < "$ENV_FILE" 2>/dev/null || cat "$ENV_FILE")
set +a

# --- Validação de Diretórios ---
if [ ! -d "$ARMA_DIR" ]; then
    echo -e "${AZUL}====================================================================${NC}"
    echo -e "${VERMELHO}DIRETÓRIO DO ARMA 3 NÃO ENCONTRADO:${CYAN}"
    echo -e "  $ARMA_DIR"
    echo -e "\n${NC}Edite o arquivo de configuração e corrija os caminhos:"
    echo -e "  • ${VERDE}ARMA_DIR${NC}  -> Pasta onde o jogo está instalado pela Steam"
    echo -e "  • ${VERDE}LOCAL_DIR${NC} -> Onde você deseja armazenar os mods baixados"
    echo -e "${AZUL}====================================================================${NC}"
    read -p "Pressione Enter para sair..."
    exit 1
fi

mkdir -p "$LOCAL_DIR"

# --- Função de Verificação e Download ---
sync_mods() {
    echo -e "\n${AZUL}🔍 Verificando atualizações no repositório remoto...${NC}"

    UPDATES=$(rclone copy :http: "$LOCAL_DIR" \
        --http-url "$REMOTE_URL" \
        --size-only \
        --exclude "*enoch*" \
        --dry-run \
        -v 2>&1 \
        | grep -E "NOTICE: .*: (Copied|Updated)" \
        | sed -E 's/.*NOTICE: (.*): (Copied|Updated).*/\1/' \
        | grep -v -E "ERROR|NOTICE|hash|rclone")

    if [ -z "$UPDATES" ]; then
        echo -e "${B_VERDE}✔ Todos os mods já estão sincronizados e na versão mais recente!${NC}"
    else
        echo -e "${AMARELO}📦 Atualizações / novos arquivos detectados:${NC}"
        
        MODS_AFETADOS=$(echo "$UPDATES" | grep -o '^@[^/]*' | sort -u)
        if [ -n "$MODS_AFETADOS" ]; then
            echo -e "${CYAN}Mods afetados:${NC}"
            while IFS= read -r mod; do
                [ -n "$mod" ] && echo -e "  ➜ ${VERDE}$mod${NC}"
            done <<< "$MODS_AFETADOS"
        fi

        echo -e "\n${AZUL}Arquivos a sincronizar:${NC}"
        echo "$UPDATES" | head -n 15 | while IFS= read -r file; do
            [ -n "$file" ] && echo -e "  • $file"
        done
        
        TOTAL_FILES=$(echo "$UPDATES" | grep -c .)
        if [ "$TOTAL_FILES" -gt 15 ]; then
            echo -e "  ${AMARELO}...e mais $(($TOTAL_FILES - 15)) arquivo(s).${NC}"
        fi

        echo -e "\n${AZUL}📡 Baixando atualizações...${NC}"
        rclone copy :http: "$LOCAL_DIR" \
            --http-url "$REMOTE_URL" \
            --size-only \
            --exclude "*enoch*" \
            --checkers 16 \
            --transfers 4 \
            --stats 5s \
            --progress

        # Garante que nenhum ficheiro específico do Enoch permaneça ativo após download
        find "$LOCAL_DIR" -iname "*enoch*.pbo" -exec mv {} {}.disabled \; 2>/dev/null

        echo -e "\n${B_VERDE}✨ Sincronização concluída com sucesso!${NC}"
    fi
}

# --- Função de Lançamento ---
launch_game() {
    echo -e "\n${VERDE}🚀 Preparando symlinks e executando Arma 3...${NC}"
    
    if [ ! -d "$ARMA_DIR" ]; then
        echo -e "${VERMELHO}❌ Diretório do Arma 3 não encontrado em: $ARMA_DIR${NC}"
        return 1
    fi
    
    cd "$ARMA_DIR" || exit 1
    
    # Remove apenas links simbólicos anteriores de mods (@*)
    find . -maxdepth 1 -type l -name "@*" -delete
    
    # Monta os symlinks dos mods locais
    MODS=""
    for d in "$LOCAL_DIR"/@*; do
        if [ -d "$d" ]; then
            M_NAME=$(basename "$d")
            ln -sfn "$d" "$M_NAME"
            MODS+="$M_NAME;"
        fi
    done
    
    FINAL_MODS="${MODS%;}"

    echo -e "${AZUL}Mods carregados:${NC} $FINAL_MODS"

    # Usa -applaunch para evitar truncamento de argumentos longos
    nohup steam -applaunch "$APP_ID" -nosplash -skipIntro -nolauncher -mod="$FINAL_MODS" > /dev/null 2>&1 &
    
    echo -e "${B_VERDE}✅ Jogo iniciado via Steam!${NC}"
    sleep 2
}

# --- Menu Principal ---
while true; do
    clear
    echo -e "${AZUL}=========================================================${NC}"
    echo -e "      ${AMARELO}🚁 EAP - CENTRAL DE COMANDO ARMA 3${NC}"
    echo -e "${AZUL}=========================================================${NC}"
    echo -e "${VERDE}1)${NC} JOGAR (Verificar Updates + Start)"
    echo -e "${VERDE}2)${NC} APENAS SINCRONIZAR (Verificar + Baixar)"
    echo -e "${VERDE}3)${NC} INFO DE SISTEMA / ESTATÍSTICAS"
    echo -e "${VERDE}4)${NC} SAIR"
    echo -e "${AZUL}=========================================================${NC}"
    read -p "🎯 Escolha uma opção: " OPT
    
    case $OPT in
        1)
            killall -9 arma3_x64.exe rclone 2>/dev/null
            sync_mods
            launch_game
            exit 0
            ;;
            
        2)
            sync_mods
            echo -e "\n1) Iniciar o Jogo agora | 2) Voltar ao Menu"
            read -p "> " NEXT_STEP
            if [[ "$NEXT_STEP" == "1" ]]; then
                launch_game
                exit 0
            fi
            ;;
            
        3)
            echo -e "\n${AMARELO}--- 📊 Estatísticas do Repositório ---${NC}"
            TAMANHO_TOTAL=$(du -sh "$LOCAL_DIR" 2>/dev/null | cut -f1)
            QNTD_PASTAS=$(find "$LOCAL_DIR" -maxdepth 1 -type d -name "@*" 2>/dev/null | wc -l)
            QNTD_ARQUIVOS=$(find "$LOCAL_DIR" -type f 2>/dev/null | wc -l)
            QNTD_LINKS=$(find "$ARMA_DIR" -maxdepth 1 -type l -name "@*" 2>/dev/null | wc -l)

            echo -e "📂 ${AZUL}Mods Instalados:${NC} $QNTD_PASTAS pastas principais (@)"
            echo -e "📄 ${AZUL}Total de Ficheiros:${NC} $QNTD_ARQUIVOS itens no disco"
            echo -e "🔗 ${AZUL}Links Ativos:${NC} $QNTD_LINKS atalhos na pasta do Arma 3"
            echo -e "💾 ${AZUL}Espaço Ocupado:${NC} ${TAMANHO_TOTAL:-0}"
            
            echo -e "\n${AMARELO}--- Partição do Sistema ---${NC}"
            df -h "$LOCAL_DIR" | grep -E "Filesystem|/"
            
            echo -e "${AZUL}------------------------------${NC}"
            echo -e "1) Abrir pasta dos Mods"
            echo -e "2) Voltar"
            read -p "> " SUBOPT
            [[ "$SUBOPT" == "1" ]] && xdg-open "$LOCAL_DIR" >/dev/null 2>&1 &
            ;;
            
        4)
            echo -e "\n${AMARELO}👋 Saindo...${NC}"
            exit 0
            ;;
            
        *)
            echo -e "\n${VERMELHO}Opção inválida!${NC}"
            sleep 1
            ;;
    esac
done