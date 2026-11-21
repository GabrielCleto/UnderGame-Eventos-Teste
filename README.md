# 🎮 UnderGame: Eventos Megalomaníacos (Standalone Testbed)

> **Ambiente experimental independente** para desenvolvimento, prototipação e teste de eventos cataclísmicos em tempo real no **UnderGame** (Survivor / Action Roguelite).

---

## ⚡ Como Executar

O projeto suporta **dois modos de execução**, garantindo máxima compatibilidade:

### 1. Modo WebGL Completo (Recomendado)
- Dê dois cliques em **`INICIAR_TESTE_EVENTOS.bat`**.
- Um servidor local HTTP leve será iniciado automaticamente na porta `8888` e abrirá seu navegador padrão com **PixiJS WebGL 2.0**, shaders customizados GLSL e 180+ FPS.

### 2. Modo Direto (Zero-Config / Offline)
- Dê dois cliques diretamente no arquivo **`index.html`** (`file://`).
- O motor detecta automaticamente o protocolo de arquivo local e ativa o **Fallback Híbrido Canvas 2D** com filtros nativos (`ctx.filter`), permitindo jogar e testar todos os eventos sem necessidade de servidor HTTP.

---

## 🕹️ Controles e Atalhos

A barra de controle de eventos fica posicionada no **rodapé da tela** para visualização limpa e desobstruída dos banners de onda.

| Tecla | Evento Megalomaníaco | Descrição & Clima |
|:---:|:---|:---|
| **`1`** | **Noite Eterna (Noir)** | Grayscale profundo, vinheta estilo cinema mudo, névoa espessa, postes de iluminação retrô e sintetizador jazz sombrio. |
| **`2`** | **Lua de Sangue** | Atmosfera carmesim agressiva, pulsação de contraste, obeliscos de sangue sacrifical, hordas frenéticas e drone sub-grave aterrorizante. |
| **`3`** | **Eclipse do Vazio** | Aberração cromática, inversão cósmica, fendas do vazio interdimensionais, distorção espectral e arpejos dissonantes. |
| **`4`** | **Era Glacial** | Congelamento global em ciano, nevasca de partículas cortantes, espículas de gelo destrutíveis e ruído branco de tempestade. |
| **`5`** | **Apocalipse Solar** | Supernova âmbar ultra-brilhante, calor abrasador, monólitos solares de plasma e sintetizador FM radiante. |
| **`6`** | **Febre Surreal** | Rotação psicodélica contínua de matriz de matiz (Rainbow Hue Shift), cogumelos mágicos no mapa e arpejos cósmicos rápidos. |
| **`K`** | **Encerrar Evento** | Desativa qualquer evento ativo, restaura a paleta natural do bioma, limpa mutações temporárias e retorna à trilha original. |

> *Dica: Você também pode clicar diretamente nos botões temáticos na barra inferior do jogo.*

---

## 🌟 Sistema de Eventos Megalomaníacos

Cada evento transforma 4 pilares do jogo simultaneamente:

```
               ┌───────────────────────────────┐
               │    DISPARO DO EVENTO (1-6)    │
               └───────────────┬───────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         ▼                     ▼                     ▼
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  SHADERS / 2D   │   │  TRILHA PROCED. │   │   MUTAÇÃO MAPA  │
│  FILTERS (GLSL) │   │ (WebAudio Synth)│   │ (Objetos & Props│
└─────────────────┘   └─────────────────┘   └─────────────────┘
```

### 1. Shaders Customizados (PixiJS + Canvas 2D)
- **WebGL**: Filtros customizados fragment shader GLSL (`pixiShaders.js`) que operam por pixel: matrizes de cor, aberração cromática com dispersão RGB, pulso senoidal e saturação dinâmica.
- **Canvas 2D Fallback**: Filtros nativos de contexto (`ctx.filter = 'grayscale(...) contrast(...) drop-shadow(...)'`) e sobreposição atmosférica direta para segurança em `file://`.

### 2. Trilha Sonora Procedural (WebAudio API)
- Não depende de arquivos MP3 gigantes externos para os eventos.
- Cada evento possui seu próprio **sintetizador generativo em tempo real** em `src/core/audio.js`:
  - Osciladores Sawtooth / Sine / Triangle desafinados (Detune).
  - Filtros Low-Pass biquad ressonantes modulados por LFO.
  - Geração de ruído de nevasca com buffer randômico de partículas sonoras.
  - Arpejos procedurais polifônicos com envelopes ADSR.

### 3. Mutação Dinâmica do Terreno & Objetos Destrutíveis
- Ao ativar um evento, o mapa sofre mutação em raio ao redor do jogador:
  - **Noite Eterna**: Gera postes de luz Noir (`noir_lamp.png`) com facho de iluminação.
  - **Lua de Sangue**: Ergue obeliscos sangrentos (`blood_obelisk.png`) destrutíveis.
  - **Eclipse do Vazio**: Abre fendas dimensionais instáveis (`void_rift.png`).
  - **Era Glacial**: Spawna agulhas pontiagudas de gelo (`ice_spire.png`).
  - **Apocalipse Solar**: Ergue monólitos solares incandescentes (`solar_monolith.png`).
  - **Febre Surreal**: Faz brotar cogumelos alucinógenos (`magic_mushroom.png`).
- Ao final do evento, as estruturas mutadas colapsam e o terreno volta ao equilíbrio.

---

## 📁 Estrutura do Repositório

```
UnderGame-Eventos-Teste/
├── assets/
│   ├── audio/              # Efeitos sonoros (SFX) e temas de personagens
│   ├── fonts/              # Tipografia medieval / arcade (MedievalSharp, etc.)
│   ├── icons/              # Ícones da interface e itens
│   └── sprites/
│       ├── characters/     # Heróis jogáveis e animações
│       ├── enemies/        # Bestiário e monstros
│       ├── vfx/            # Projéteis, magias e partículas
│       └── world/          # Tilesets, vegetação e props dos eventos
├── css/
│   └── style.css           # Estilização da HUD, barra de eventos e canvas
├── src/
│   ├── core/
│   │   ├── assets.js       # Carregamento e cache assíncrono de sprites/áudio
│   │   ├── audio.js        # Engine WebAudio procedural + Sintetizadores dos eventos
│   │   ├── config.js       # Constantes do jogo e flags de balanceamento
│   │   ├── input.js        # Mapeamento de teclado, mouse, gamepad e atalhos 1-6
│   │   └── spatialGrid.js  # Grid espacial para colisão e física a 60+ FPS
│   ├── data/
│   │   ├── characters.js   # Estatísticas e habilidades dos personagens
│   │   ├── items.js        # Armas, evoluções e upgrades
│   │   └── monsters.js     # Comportamento, vida e dano dos inimigos
│   ├── render/
│   │   ├── pixiRenderer.js # Pipeline híbrido PixiJS WebGL + Canvas 2D
│   │   ├── pixiShaders.js  # Shaders GLSL para cada evento cataclísmico
│   │   └── worldRenderer.js# Renderização de tiles, camadas e iluminação
│   ├── systems/
│   │   ├── ai.js           # IA de perseguição de hordas
│   │   ├── combat.js       # Cálculo de dano, hits críticos e projéteis
│   │   ├── state.js        # Gerenciamento de ciclo de vida da partida
│   │   └── update.js       # Loop principal de atualização lógica
│   ├── ui/
│   │   ├── hud.js          # Barra de vida, XP, minimapa e contadores
│   │   └── menus.js        # Telas de upgrade, seleção e pausa
│   ├── vendor/
│   │   └── pixi.min.js     # PixiJS v7 standalone local
│   ├── world/
│   │   └── world.js        # Geração procedural do mapa e mutações dos eventos
│   └── main.js             # Ponto de entrada, loop de jogo e orquestrador
├── INICIAR_TESTE_EVENTOS.bat # Launcher automático com servidor local
├── index.html              # HTML com barra de testes de eventos integrada
├── README.md               # Documentação principal
└── DOCS_EVENTOS.md         # Especificação técnica e arquitetura de eventos
```

---

## 🛠️ Tecnologias Utilizadas

- **JavaScript (ES6+) Modular Vanilla**: Sem frameworks pesados ou transpilações complexas.
- **PixiJS v7**: Aceleração gráfica WebGL 2.0 para renderização em lote (batch rendering).
- **GLSL Shaders**: Filtros de pós-processamento dinâmicos por evento.
- **Web Audio API**: Síntese analógica procedural e efeitos de áudio em tempo real.
- **Canvas 2D Context API**: Modo de contingência automático sem perda de jogabilidade.

---

## 👥 Autor & Licença

- **Desenvolvedor:** Gabriel Cleto
- **Projeto Base:** UnderGame
- **Licença:** MIT
