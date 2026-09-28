# 🚁 EAP - Central de Comando Arma 3 (Linux Launcher & Mod Sync)

[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20%7C%20Pop!__OS-orange.svg)](https://pop.system76.com/)
[![Compatibility: Proton](https://img.shields.io/badge/Compatibility-Valve%20Proton-blue.svg)](https://github.com/ValveSoftware/Proton)
[![Engine: Arma 3](https://img.shields.io/badge/Game-Arma%203-gold.svg)](https://arma3.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Script de automação para sincronização incremental de repositórios de mods e inicialização otimizada do **Arma 3** no Linux via **Steam / Proton**. Desenvolvido para esquadrões táticos, o script soluciona gargalos comuns de argumentos longos, inconsistências de dependências de DLC ausente no Linux, e integra-se diretamente à Área de Trabalho com identidade visual militar.

---

## 📌 Principais Recursos

- **Sincronização Rápida via Rclone:** Comparações baseadas em tamanho (`--size-only`), transferências paralelas (`--transfers 4 --checkers 16`) e dry-run antecipado para identificar apenas arquivos alterados.
- **Isolamento de Configuração via `.env`:** Variáveis de caminhos locais e repositório isoladas em arquivo `.env` (ignorado pelo Git), acompanhado do modelo `.env.example`.
- **Gerenciamento Inteligente de Symlinks:** Mantém a biblioteca de mods em qualquer diretório ou partição dedicada e cria links simbólicos dinâmicos na raiz do jogo sem duplicar arquivos.
- **Tratamento de Dependências Incompletas (DLC Contact/Enoch):** Sanitização automática de arquivos problemáticos para impedir falhas de `A3_Data_F_Enoch_Loadorder` e conflitos de classes em contas sem a DLC Contact.
- **Instalação Automática de Ícone e Atalho:** Gera dinamicamente um ícone tático vetorial (`.svg`) e registra o atalho `.desktop` no menu de aplicativos e na Área de Trabalho com suporte universal a emuladores de terminal (`x-terminal-emulator`, `cosmic-term`, `io.elementary.terminal`, `gnome-terminal`, etc.).
- **Diagnóstico e Estatísticas:** Monitoramento do volume de mods, integridade de links simbólicos e espaço disponível em disco.

---

## ⚙️ Pré-requisitos

Instale os pacotes básicos necessários no seu sistema (exemplo para distribuições baseadas em Debian / Ubuntu / Pop!_OS):

```bash
sudo apt update
sudo apt install -y rclone steam coreutils gettext-base
```

> **Nota:** O pacote `gettext-base` fornece o utilitário `envsubst`, utilizado para expandir variáveis de sistema (como `$HOME`) dentro do arquivo `.env`.

---

## 🚀 Instalação e Configuração

### 1. Clonar o Repositório
```bash
git clone https://github.com/cogoplay/eap-arma3-launcher.git
cd eap-arma3-launcher
chmod +x eap_arma3.sh
```

### 2. Configurar o Arquivo `.env`
Copie o modelo de variáveis de ambiente:
```bash
cp .env.example .env
```

Abra o arquivo `.env` no seu editor favorito e configure os caminhos conforme sua máquina:

```ini
# URL remota do repositório HTTP/WebDAV de mods
REMOTE_URL="http://104.194.9.235/REPOSITORIO/OFICIAL3"

# Diretório onde os mods baixados serão armazenados
LOCAL_DIR="$HOME/Games/Arma3/Mods-EAP"

# Diretório onde o Arma 3 está instalado pela Steam
ARMA_DIR="$HOME/Games/SteamLibrary/steamapps/common/Arma 3"

# Steam AppID do Arma 3
APP_ID="107410"
```

* `$LOCAL_DIR`: Onde os arquivos brutos dos mods serão salvos (certifique-se de ter espaço em disco suficiente, recomendado 60 GB+).
* `$ARMA_DIR`: Caminho raiz da pasta de instalação do Arma 3 na sua biblioteca Steam.

### 3. Primeira Execução e Instalação do Atalho
Execute o script uma vez pelo terminal:
```bash
./eap_arma3.sh
```

Na primeira inicialização:
1. O script gera o ícone militar vetorial em `~/.local/share/icons/arma3-eap.svg`.
2. Cria o arquivo `.desktop` no lançador do sistema e na Área de Trabalho.
3. Detecta automaticamente o emulador de terminal disponível para execuções futuras com duplo clique.

---

## 🎮 Central de Comando

Ao executar o launcher, você terá à disposição o menu interativo:

```text
=========================================================
      🚁 EAP - CENTRAL DE COMANDO ARMA 3
=========================================================
1)    JOGAR (Verificar Updates + Start)
2)    APENAS SINCRONIZAR (Verificar + Baixar)
3)    INFO DE SISTEMA / ESTATÍSTICAS
4)    SAIR
=========================================================
```

* **Opção 1 (Jogar):** Finaliza eventuais instâncias residuais (`arma3_x64.exe`), verifica se há novos mods no repositório, baixa atualizações se existirem, remonta os symlinks e dispara o executável do jogo via Proton sem passar por limitações de URI.
* **Opção 2 (Apenas Sincronizar):** Executa apenas a rotina de download e atualização incremental sem abrir o jogo.
* **Opção 3 (Info de Sistema):** Exibe contagem de pacotes `@`, total de arquivos, tamanho ocupado no disco e espaço livre na partição.

---

## 🛠️ Resolução de Alertas e Dúvidas Comuns

### 1. Mensagens de Addons (`A3_Data_F_Oldman` / `A3_Data_F_Enoch_Loadorder`)
Caso o utilizador **não possua a DLC Contact (Enoch)** na conta Steam:
* **Comportamento:** Ao abrir o jogo, pode surgir um pop-up de aviso informando que um addon depende de arquivos da expansão Enoch. **Isso é esperado e normal.**
* **Ação:** Basta clicar em **"OK"** para avançar; o motor prossegue normalmente para o menu principal.

#### Desativação Permanente de Conflitos (Para quem NÃO possui a DLC):
1. **Pela Steam:**
   * Clique com o botão direito no **Arma 3** > **Propriedades** > **DLC**.
   * Desmarque a opção **Arma 3 Contact** (ou *Contact Platform*).
2. **Pelo Terminal:**
   ```bash
   cd "$ARMA_DIR"
   mv Expansion/Addons/data_f_oldman.pbo Expansion/Addons/data_f_oldman.pbo.disabled 2>/dev/null
   mv Expansion/Addons/functions_f_oldman.pbo Expansion/Addons/functions_f_oldman.pbo.disabled 2>/dev/null
   [ -d "Enoch" ] && mv Enoch Enoch.disabled 2>/dev/null
   [ -d "Contact" ] && mv Contact Contact.disabled 2>/dev/null
   ```

#### Reativação (Para quem POSSUI a DLC comprada):
1. Marque a DLC na aba **Propriedades > DLC** da Steam e aguarde o download.
2. Restaure os nomes originais dos arquivos:
   ```bash
   cd "$ARMA_DIR"
   mv Expansion/Addons/data_f_oldman.pbo.disabled Expansion/Addons/data_f_oldman.pbo 2>/dev/null
   mv Expansion/Addons/functions_f_oldman.pbo.disabled Expansion/Addons/functions_f_oldman.pbo 2>/dev/null
   [ -d "Enoch.disabled" ] && mv Enoch.disabled Enoch 2>/dev/null
   [ -d "Contact.disabled" ] && mv Contact.disabled Contact 2>/dev/null
   ```

### 2. Alerta "App is not responding" (Wait vs Force Quit)
Durante o carregamento de muitos mods pesados, o gerenciador de janelas do Linux pode alertar que a aplicação não está a responder:
* **Nunca selecione "Force Quit".**
* Selecione sempre **"Wait" (Aguardar)**, pois o Proton e o motor do jogo estão apenas indexando arquivos PBO na memória RAM.

---

## 🧪 Ambiente de Homologação

- **Sistema Operacional:** Pop!_OS Linux (x86_64)
- **Camada de Execução:** Valve Proton Experimental / Proton GE
- **Plataforma:** Steam Linux Runtime

---

## 👨‍💻 Créditos e Autoria

Desenvolvido e mantido por **Alyton Cogo** ([cogoplay](https://github.com/cogoplay)) para a comunidade e esquadrão **ArmaPoint**.

Licenciado sob a [MIT License](LICENSE).