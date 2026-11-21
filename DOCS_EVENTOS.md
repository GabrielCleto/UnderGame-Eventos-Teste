# 📖 Arquitetura e Documentação Técnica: Sistema de Eventos Megalomaníacos

Este documento detalha o funcionamento interno, ciclo de vida e especificações técnicas do sistema de eventos implementado no repositório **UnderGame-Eventos-Teste**.

---

## 1. Ciclo de Vida do Evento

Cada evento megalomaníaco é controlado de forma centralizada pelo `main.js`, interagindo com três subsistemas independentes:

```
[Disparo: UI / Tecla 1-6] 
         │
         ▼
[main.js: triggerMegalomaniacEvent(name)]
         │
         ├── 1. Shader / Filtro ─────► pixiRenderer.setEventShader(name)
         │                             └─► Aplica GLSL Filter ou ctx.filter
         │
         ├── 2. Sintetizador Áudio ──► audio.playEventMusic(name)
         │                             └─► Inicia nós WebAudio em tempo real
         │
         ├── 3. Mutação de Terreno ──► world.mutateMapForEvent(name)
         │                             └─► Spawna objetos temáticos no raio
         │
         └── 4. Interface (HUD) ─────► Exibe Banner Animado + Subtítulo
```

Ao cancelar ou transitar entre eventos (`clearMegalomaniacEvent()`):
1. **Filtros visuais:** O shader ativo é removido ou interpolado de volta para o padrão neutro.
2. **Sintetizador:** Todos os nós de áudio do evento executam fade-out suave (ADSR release) e são desconectados, retomando a trilha sonora habitual do jogo.
3. **Terreno:** As mutações e props temporários associados ao evento são removidos da lista de objetos do mundo.

---

## 2. Especificação dos Shaders GLSL (`pixiShaders.js`)

Os fragment shaders operam em cima da textura completa da cena via PixiJS `Filter`:

### A. Noite Eterna (`noir`)
- **Conceito:** Estética monocromática anos 40, alto contraste e vinheta escura progressiva.
- **GLSL Logic:**
  - Conversão de luminância: `float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));`
  - Aumento de contraste: `gray = (gray - 0.5) * 1.35 + 0.5;`
  - Vinheta circular centrada: `float vignette = smoothstep(0.8, 0.25, length(uv - 0.5));`
  - Saída: `gl_FragColor = vec4(vec3(gray) * vignette, color.a);`

### B. Lua de Sangue (`bloodmoon`)
- **Conceito:** Opressão carmesim e pulso rítmico de perigo.
- **GLSL Logic:**
  - Pulso temporal: `float pulse = sin(uTime * 2.5) * 0.15 + 0.85;`
  - Realce do canal vermelho e dessaturação seletiva de verde/azul:
    `color.r = pow(color.r, 0.7) * 1.3 * pulse;`
    `color.g *= 0.35; color.b *= 0.35;`

### C. Eclipse do Vazio (`void_eclipse`)
- **Conceito:** Aberração cromática com dispersão radial e inversão cósmica suave.
- **GLSL Logic:**
  - Deslocamento de coordenadas de textura (RGB Split):
    `float r = texture2D(uSampler, uv + vec2(distort, 0.0)).r;`
    `float g = texture2D(uSampler, uv).g;`
    `float b = texture2D(uSampler, uv - vec2(distort, 0.0)).b;`
  - Inversão suave com tom púrpura/violeta.

### D. Era Glacial (`glacial`)
- **Conceito:** Hipotermia visual, tonalização ciano-ártica e partículas de gelo.
- **GLSL Logic:**
  - Matriz de tonalização fria com corte de tons quentes:
    `color.rgb = mix(color.rgb, vec3(0.1, 0.8, 1.0) * dot(color.rgb, vec3(0.33)), 0.65);`
  - Brilho especular cristalino nos picos de claridade.

### E. Apocalipse Solar (`solar`)
- **Conceito:** Superaquecimento, tonalidade âmbar-dourada e saturação extrema.
- **GLSL Logic:**
  - Elevação de exposição com curva exponencial:
    `color.rgb *= vec3(1.4, 1.1, 0.7);`
    `color.rgb = pow(color.rgb, vec3(0.85));`

### F. Febre Surreal (`psychedelic`)
- **Conceito:** Rotação contínua da roda de cores (Hue Shift) a 60 FPS.
- **GLSL Logic:**
  - Conversão RGB -> HSV -> Rotação de Matiz via `uTime` -> HSV -> RGB.
  - Cria ondas psicodélicas que reagem à passagem do tempo.

---

## 3. Síntese WebAudio Procedural (`audio.js`)

Os sintetizadores são instanciados sob demanda e utilizam nós nativos de Web Audio API:

```
[Master Gain (0.4)] ◄─── [Event Master Gain] ◄─── [Biquad Filter] ◄─── [Oscillators / Noise]
                                                                        ▲
                                                                  [LFO / Modulation]
```

### Arquitetura dos Patches de Sintetizador:
1. **Noir Jazz Noir:**
   - Oscilador 1: Onda Triangular a 55Hz (A1) para contrabaixo acústico.
   - Oscilador 2: Onda Senoidal com arpejos lentos pentatônicos menores.
   - Filtro: Lowpass em 450Hz, corte quente.
2. **Bloodmoon Drone:**
   - Osciladores Sawtooth duplos desafinados em 7 centésimos (detune: +/- 7).
   - Sub-bass a 40Hz com ganho comprimido.
   - LFO senoidal de 0.8Hz modulando a frequência do corte de filtro (sweep aterrorizante).
3. **Void Eclipse Cosmic:**
   - Acorde diminuto dissonante em ondas dente-de-serra.
   - Delay recursivo estéreo simulado por nós `DelayNode` e `GainNode` de realimentação.
4. **Glacial Blizzard:**
   - Buffer de ruído branco gerado dinamicamente (`createBuffer(1, length, sampleRate)`).
   - Filtro Bandpass ressonante oscilando entre 600Hz e 2400Hz simulando vento cortante.
5. **Solar Supernova:**
   - Síntese FM: Um oscilador modulador senoidal a 110Hz modula a frequência de uma portadora a 220Hz.
   - Filtro High-Shelf dando brilho aos harmônicos agudos.
6. **Psychedelic Arpeggiator:**
   - Sequenciador de 8 passos executando escalas místicas rápidas (160 BPM).
   - Transição constante de oitavas e decay curto percussivo.

---

## 4. Mutação Dinâmica de Mapa (`world.js`)

Ao acionar um evento, a função `world.mutateMapForEvent(eventName, playerX, playerY)` executa:
1. Varredura do anel de tiles ao redor das coordenadas do jogador (distância entre 150px e 550px).
2. Verificação de tiles navegáveis (evitando spawn dentro de água ou rochas sólidas).
3. Instanciação de entidades físicas destrutíveis ou props temáticos:
   - `worldObjects.push({ x, y, type: propType, hp: 50, maxHp: 50, eventOwner: eventName })`.
4. Os objetos recebem colisores circulares e interagem com projéteis do jogador e monstros.
5. No cancelamento do evento, `world.clearEventMutations()` remove todos os objetos com etiqueta `eventOwner`.

---

## 5. Roteiro de Futuras Expansões (Roadmap)

- [ ] **Mecânicas Específicas de Gameplay por Evento:**
  - *Noite Eterna:* Reduzir campo de visão do jogador e aumentar dano crítico furtivo.
  - *Lua de Sangue:* Aumentar velocidade dos inimigos em 40% e dobrar taxa de drop de gemas de sangue.
  - *Era Glacial:* Aplicar efeito de desaceleração (slow) gradual caso o jogador fique parado.
  - *Apocalipse Solar:* Criar zonas de sombra estratégicas sob árvores para evitar dano contínuo de calor.
- [ ] **Chefes Especiais Vinculados a Eventos:**
  - Boss exclusivo para cada cataclismo (Ex: Aparição do Vazio, Titã de Gelo).
- [ ] **Integração na Linha Principal (`-UnderGame`):**
  - Mesclar o módulo testado como ondas especiais periódicas (ex: a cada 5 minutos de sobrevivência).
