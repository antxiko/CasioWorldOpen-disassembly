; ==========================================================================
; CASIO WORLD OPEN - Casio - MSX1 - cartucho de 32 KB en las paginas 1 y 2
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; DATOS cabecera_ab: Cabecera AB: firma, INIT=0x4010, STATEMENT/DEVICE/TEXT=0,
;   seis bytes de relleno
;   0x4000..0x4010  (16 bytes)
DATA_cabecera_ab:
	defb 041h,042h,010h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 4000  AB.@............

; ======================================================================
; CODIGO 0x4010..0x40f6  (230 bytes)
; ======================================================================


init:		; Punto de entrada que llama la BIOS tras la cabecera AB
	di			;4010
	ld sp,0f370h		;4011   ; la pila justo debajo de las variables de la BIOS
	call 00138h		;4014   ; BIOS RSLREG - Reads the primary slot register | lee el registro de slots primarios
	ld b,a			;4017
	and 00ch		;4018   ; los bits 2 y 3 son el slot de la pagina 1
	rlca			;401a   ; subidos a los bits 4 y 5
	rlca			;401b
	ld c,a			;401c
	ld a,b			;401d
	and 0cfh		;401e   ; para dejarlos tambien como slot de la pagina 2
	or c			;4020
	call 0013bh		;4021   ; BIOS WSLREG - Writes value to the primary slot register | y con eso el cartucho de 32 KB se ve entero, en las dos paginas
	ld a,0c9h		;4024   ; 0xC9 es un RET: el gancho H.TIMI queda desactivado
	ld (0fd9fh),a		;4026
	ld (0e0a5h),a		;4029   ; y lo mismo en 0xE0A5, que es codigo que vive en RAM
	ld a,0d0h		;402c   ; 0xD0 en la fila del sprite 0 apaga TODOS los sprites de golpe
	ld hl,01b00h		;402e
	call 0004dh		;4031   ; BIOS WRTVRM - Writes data in VRAM
	ld a,0c2h		;4034   ; 0xC2 es un jp nz: parchea la rutina de RAM de 0xE10E
	ld (0e10eh),a		;4036
	call esconde_al_golfista		;4039   ; monta las columnas del campo
	call monta_la_pantalla_de_titulo		;403c   ; la pantalla de titulo, con su logotipo
	ld a,(0e000h)		;403f   ; y la marca de la opcion elegida, que 0x419B deja en 0xC0
	call pinta_la_marca_de_jugadores		;4042
arranca_la_partida:		; Monta la pantalla de juego, limpia los indicadores de sonido y entrada y engancha el manejador temporal
	call monta_la_pantalla_de_juego		;4045   ; Monta la pantalla de juego, limpia flags de sonido/entrada y engancha el manejador temporal 0x415B
	ld a,080h		;4048   ; el bit 7 de (0xE001) pide el arranque
	ld (0e001h),a		;404a   ; Pone (0xE001) a 0x80 (bit de arranque) y limpia flags de entrada/sonido
	xor a			;404d   ; y el resto de indicadores arrancan a cero
	ld (0e002h),a		;404e
	ld (0e007h),a		;4051
	ld (0e06ch),a		;4054
	ld (0e077h),a		;4057
	ld (0e005h),a		;405a
	ld hl,0415bh		;405d   ; el manejador TEMPORAL de interrupcion, el que remata la inicializacion
	ld (0fda0h),hl		;4060
espera_el_arranque:		; No sigue hasta que el bit 7 de (0xE005) dice que la inicializacion termino
	ld hl,0e005h		;4063   ; Espera a que termine el arranque (bit 7 de 0xE005)
	bit 7,(hl)		;4066   ; hasta que el bit 7 de (0xE005) no se levante, no se sigue
	jr z,espera_el_arranque		;4068
	push hl			;406a
	ld hl,04b8ah		;406b   ; Engancha el manejador de interrupcion definitivo y monta la pantalla de titulo (DISSCR/INIT32)
	ld (0fda0h),hl		;406e
	call para_el_canal		;4071   ; calla el canal de sonido
	call 00041h		;4074   ; BIOS DISSCR - Inhibits the screen display
	call 0006fh		;4077   ; BIOS INIT32 - Switches to SCREEN 1 (text screen with 32*24 characters)
	ld a,0f1h		;407a   ; el color de la pantalla de resultado, 0xF1: blanco sobre negro
	ld hl,02000h		;407c
	ld c,020h		;407f
	call rellena_vram		;4081
	call limpia_los_nombres		;4084   ; y la tabla de nombres a espacios
	pop hl			;4087
	push hl			;4088
	bit 6,(hl)		;4089   ; el bit 6 dice si la ronda se ha acabado del todo
	ld hl,040f6h		;408b   ; Dibuja el texto inicial segun el bit 6 del byte leido de la pila
	ld de,018c8h		;408e
	ld b,00fh		;4091
	jr z,prepara_el_hud		;4093
	ld hl,04105h		;4095   ; y 0x4105 es "GAME  OVER"
	ld b,00ah		;4098
	ld de,01a0bh		;409a
	call copia_a_vram		;409d
	ld hl,040fah		;40a0   ; con 0x40FA, "TOTAL SCORE", debajo
	ld de,018cah		;40a3
	ld b,00bh		;40a6
prepara_el_hud:		; Deja listos los datos del jugador 1 para el marcador
	call copia_a_vram		;40a8   ; Prepara los datos del jugador 1 (0x411A) para el HUD
	ld bc,(0e09ah)		;40ab   ; la puntuacion acumulada del jugador 1
	ld hl,05031h		;40af   ; el patron de la cifra
	ld de,0194ah		;40b2   ; en VRAM 0x194A
	call prepara_el_texto_del_hud		;40b5
	ld a,(0e000h)		;40b8
	rlca			;40bb   ; el bit 7 de (0xE000) esta puesto con UN jugador: no hay segunda cifra que escribir
	jr c,enciende_la_pantalla		;40bc
	ld bc,(0e09ch)		;40be   ; Si el modo es a dos jugadores (bit 6 de 0xE000), prepara tambien los del jugador 2
	ld hl,05032h		;40c2   ; y con dos, la del jugador 2
	ld de,0198ah		;40c5   ; en VRAM 0x198A
	call prepara_el_texto_del_hud		;40c8
enciende_la_pantalla:		; Muestra lo ya montado y registra los bloques de sonido
	call muestra_la_pantalla		;40cb
	call registra_los_sonidos		;40ce   ; apunta los bloques de sonido en sus canales
espera_el_canal_libre:		; Da vueltas hasta que (0xF403) suelta el canal de sonido
	ld a,(0f403h)		;40d1   ; Espera a que el canal de sonido (0xF403) quede libre antes de continuar
	or a			;40d4   ; mientras (0xF403) no sea cero, el sonido sigue sonando
	jr nz,espera_el_canal_libre		;40d5
	pop hl			;40d7
	bit 6,(hl)		;40d8   ; con el bit 6 bajado, vuelve a jugar sin pasar por el titulo
	jp z,arranca_la_partida		;40da
	ld b,000h		;40dd
	ld de,0bb93h		;40df   ; Registra dos bloques de sonido iniciales en los canales 0 y 1
	call registra_un_bloque		;40e2
	ld b,001h		;40e5
	ld de,0bbafh		;40e7
	call registra_un_bloque		;40ea
espera_el_canal_otra_vez:		; La misma espera, en el otro punto del arranque
	ld a,(0f403h)		;40ed
	or a			;40f0
	jr nz,espera_el_canal_otra_vez		;40f1
	jp init		;40f3   ; y al acabar, arranque en frio

; ----------------------------------------------------------------------
; DATOS texto_hud_00: Texto corto del HUD, 15 bytes; 0x4145 lo lee entero o
;   solo los ultimos 11 (desde 0x40FA) segun el bit 6 de (0xE005)
;   0x40f6..0x410f  (25 bytes)
DATA_texto_hud_00:
	defb 04fh,055h,054h,020h,054h,04fh,054h,041h,04ch,020h,053h,043h,04fh,052h,045h,047h	; 40f6  OUT TOTAL SCOREG
	defb 041h,04dh,045h,020h,020h,04fh,056h,045h,052h	; 4106  AME  OVER

; ======================================================================
; CODIGO 0x410f..0x42f9  (490 bytes)
; ======================================================================


limpia_los_nombres:		; Rellena de espacios las 768 celdas de la tabla de nombres
	ld a,020h		;410f
	ld hl,01800h		;4111   ; las 768 celdas de la tabla de nombres
	ld bc,00300h		;4114   ; rellenas de espacios
	jp 00056h		;4117   ; BIOS FILVRM - Fills VRAM with value
prepara_el_texto_del_hud:		; Guarda el puntero de origen y elige longitud 0x24 o 0x48 segun el bit 6 de (0xE005)
	ld (0e053h),hl		;411a   ; Guarda HL como puntero fuente en (0xE053); longitud base 0x24 o 0x48 segun el bit 6 de (0xE005)
	ld a,(0e005h)		;411d
	bit 6,a		;4120   ; el bit 6 de (0xE005)
	ld a,024h		;4122   ; elige 36 bytes
	jr z,suma_la_longitud		;4124
	add a,a			;4126   ; o el doble, 72
suma_la_longitud:		; Junta la base con el desplazamiento para saber cuanto copiar
	add a,b			;4127   ; mas lo que traiga B
	ld c,a			;4128
	push de			;4129
	call prepara_las_cifras		;412a   ; Copia el bloque calculado (0x4797) y espeja en alto los 7 bytes de (0xE057)
	ld hl,0e057h		;412d
	ld b,007h		;4130   ; los siete bytes que quedan
espeja_en_alto:		; Pone el bit 7 a los siete bytes que quedan y deja el puntero final
	ld a,(hl)			;4132   ; Espeja en alto los 7 bytes restantes y prepara el puntero final de copia
	add a,080h		;4133   ; con el bit 7 puesto: en esta fuente, eso los pasa a la version en alto
	ld (hl),a			;4135
	inc hl			;4136
	djnz espeja_en_alto		;4137
	ld hl,02020h		;4139   ; dos espacios de relleno al final
	ld (0e055h),hl		;413c
	pop de			;413f
	ld hl,0e053h		;4140
	ld b,00bh		;4143   ; y once bytes de copia
copia_a_vram:		; Copia B bytes de HL a la VRAM: el ayudante que usa casi toda la pantalla de titulo y el marcador
	push de			;4145   ; Copia B bytes de HL a VRAM DE (LDIRVM); helper de texto/patrones usado por casi toda la pantalla de titulo y el HUD
	push hl			;4146
	push bc			;4147
	ld c,b			;4148   ; la BIOS quiere la cuenta en BC
	ld b,000h		;4149
	call 0005ch		;414b   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop bc			;414e
	ld e,b			;414f
	ld d,000h		;4150
	pop hl			;4152
	add hl,de			;4153   ; al volver, HL queda apuntando detras de lo copiado
	pop de			;4154
	ret			;4155
rellena_vram:		; Rellena la VRAM con un valor, por la BIOS
	ld b,000h		;4156   ; la cuenta cabe en C: nunca se rellena mas de 255
	jp 00056h		;4158   ; BIOS FILVRM - Fills VRAM with value
interrupcion_de_arranque:		; El manejador TEMPORAL: llama al definitivo y, la primera vez, remata la inicializacion
	call avanza_los_contadores		;415b   ; Manejador de interrupcion TEMPORAL de arranque: llama primero al definitivo (0x4B8A)
	ld hl,0e002h		;415e   ; Bit 7 de (0xE002): si ya esta activo no repite la inicializacion de abajo
	ld a,(hl)			;4161
	rlca			;4162   ; con el bit 7 de (0xE002) puesto ya se hizo
	ret c			;4163
	ld (hl),0ffh		;4164   ; y se marca para no repetirlo
	ld hl,0e072h		;4166
	inc (hl)			;4169   ; un cuadro mas en el contador de (0xE072)
	call prepara_los_indicadores		;416a   ; Cadena de inicializacion de arranque: sonido, entrada, datos por hoyo, HUD y demas subsistemas
	call multiplicador_base		;416d
	call despacha_por_bits		;4170
	call despacha_la_animacion		;4173
	call elige_el_indicador		;4176
	call mira_el_disparo		;4179
	call despacha_las_fases		;417c
	ld a,(0e072h)		;417f
	and 003h		;4182   ; uno de cada cuatro cuadros
	call z,refresca_el_marcador		;4184   ; Si (0xE072) esta a multiplo de 4, refresca el mensaje de la parte inferior de pantalla
	ld a,(0e000h)		;4187
	rlca			;418a   ; con un solo jugador, siempre
	jr c,marca_el_relleno		;418b
	and 018h		;418d   ; y con dos, solo si hay animacion pendiente
	jr z,baja_la_bandera_de_arranque		;418f
marca_el_relleno:		; Deja 0xC2 en (0xE116)
	ld a,0c2h		;4191
	ld (0e116h),a		;4193   ; 0xC2 otra vez, sobre la otra rutina de RAM
baja_la_bandera_de_arranque:		; Pone (0xE002) a cero para no repetir
	xor a			;4196
	ld (0e002h),a		;4197
	ret			;419a
monta_la_pantalla_de_titulo:		; Apaga el video, entra en SCREEN 1 y coloca el logotipo, los textos y el color
	call 00041h		;419b   ; BIOS DISSCR - Inhibits the screen display | Apaga pantalla, fija el color y entra en SCREEN 1 para montar la pantalla de titulo
	ld a,001h		;419e   ; la pagina de la VRAM
	ld (0f3ebh),a		;41a0
	call 00062h		;41a3   ; BIOS CHGCLR - Changes the screen colors | el color de la pantalla de titulo
	call 0006fh		;41a6   ; BIOS INIT32 - Switches to SCREEN 1 (text screen with 32*24 characters) | SCREEN 1: 32 columnas
	ld hl,042f9h		;41a9   ; el tile 0x40, que en esta pantalla es el simbolo (C) del copyright
	ld de,00200h		;41ac
	ld b,008h		;41af   ; ocho bytes: un solo caracter
	call copia_a_vram		;41b1
	ld hl,04301h		;41b4   ; Copia el logotipo (304 bytes, patrones tal cual) a VRAM
	ld de,00408h		;41b7
	ld bc,00130h		;41ba   ; 304 bytes, 38 tiles: el logotipo de CASIO WORLD OPEN
	call 0005ch		;41bd   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld a,0f1h		;41c0   ; Rellena de color los dos tercios superiores de la pantalla (0x4156)
	ld hl,02000h		;41c2
	ld c,010h		;41c5
	call rellena_vram		;41c7
	ld a,021h		;41ca   ; y 0x21 en el tercero, que es donde va el logotipo
	ld hl,02010h		;41cc
	ld c,010h		;41cf
	call rellena_vram		;41d1
	call limpia_los_nombres		;41d4
	ld bc,00303h		;41d7   ; tres filas de tres celdas
	ld de,0186eh		;41da
	ld hl,04431h		;41dd   ; Bloques de patrones del logotipo (3x3 y 16x4) via 0x44E5
	call copia_un_bloque		;41e0
	ld bc,01004h		;41e3   ; y dieciseis filas de cuatro
	ld de,018c8h		;41e6
	ld hl,0443ah		;41e9
	call copia_un_bloque		;41ec
	ld hl,0447ah		;41ef   ; Textos de la pantalla de titulo (autor, copyright, menu de jugadores)
	ld de,01969h		;41f2
	ld b,00dh		;41f5
	call copia_a_vram		;41f7
	ld hl,04487h		;41fa   ; "PLAYER SELECT"
	ld de,019c9h		;41fd
	ld b,00dh		;4200
	call copia_a_vram		;4202
	ld hl,04494h		;4205   ; "PLAY PUSH TRIGGER1", que se escribe DOS veces
	push hl			;4208
	ld de,01a08h		;4209
	ld b,012h		;420c
	call copia_a_vram		;420e
	pop hl			;4211
	ld de,01a48h		;4212   ; en la fila de abajo, la del 2PLAY
	ld b,012h		;4215
	call copia_a_vram		;4217
	ld hl,044a6h		;421a   ; "TO START GAME"
	ld de,01a89h		;421d
	ld b,00dh		;4220
	call copia_a_vram		;4222
	ld hl,044b3h		;4225   ; "COPYRIGHT 1985 (C) CASIO"
	ld de,01ae5h		;4228
	ld b,016h		;422b
	call copia_a_vram		;422d
	ld hl,044c9h		;4230   ; y el "1" y el "2" de las dos filas, una celda por fila
	ld de,01a07h		;4233
	ld bc,00103h		;4236
	call copia_un_bloque		;4239
	call muestra_la_pantalla		;423c   ; Enciende la pantalla ya montada
	ld hl,00101h		;423f   ; Hoyo inicial = 1, contador de golpes a cero
	ld (0e0b4h),hl		;4242
	ld hl,00000h		;4245
	ld (0e09ah),hl		;4248   ; las dos puntuaciones acumuladas, a cero
	ld (0e09ch),hl		;424b
	ld hl,04b8ah		;424e   ; Engancha el manejador de interrupcion DEFINITIVO (0x4B8A) en H.TIMI
	ld (0fda0h),hl		;4251
	ld a,0c3h		;4254   ; 0xC3 es un salto: asi queda enganchado el gancho H.TIMI
	ld (0fd9fh),a		;4256
	xor a			;4259
	ld (0e09eh),a		;425a   ; sin animacion pendiente
	call registra_los_sonidos		;425d   ; Otra fase de inicializacion (0x42E9) antes de esperar la entrada del jugador
	ld a,0c0h		;4260
	ld (0e000h),a		;4262   ; la opcion de partida arranca en 0xC0
espera_la_eleccion:		; Con el canal de sonido libre, prepara los valores del disparo y lee la eleccion de jugadores
	push af			;4265   ; Si el canal de sonido esta libre, prepara los valores del disparo (0x5EEC)
	ld a,(0f403h)		;4266   ; en cuanto el sonido de la pantalla de titulo acaba, se juega
	or a			;4269
	jr z,pasa_al_juego		;426a
	call multiplicador_base		;426c   ; lee el mando
	pop af			;426f
	ld hl,0e0a8h		;4270   ; (0xE0A8) trae el estado de la entrada
	bit 4,(hl)		;4273   ; el bit 4 es el disparo: confirma la eleccion
	jr nz,marca_dos_jugadores		;4275
	bit 0,(hl)		;4277   ; Segun los bits de (0xE0A8), decide la rama de disparo (normal, especial o par)
	jr nz,marca_un_jugador		;4279
	bit 1,(hl)		;427b   ; y el bit 1 a la otra
	jr z,repinta_la_eleccion		;427d
	ld a,040h		;427f   ; 0x40 dibuja la marca en la fila de arriba; ese es el codigo de DOS jugadores, comprobado en openMSX
	jr repinta_la_eleccion		;4281
marca_un_jugador:		; Deja el codigo de un jugador
	ld a,0c0h		;4283   ; y 0xC0 la dibuja en la de abajo; ese es el codigo de UN jugador, y es con el que arranca
repinta_la_eleccion:		; Redibuja la marca y vuelve a esperar
	call pinta_la_marca_de_jugadores		;4285
	jr espera_la_eleccion		;4288
marca_dos_jugadores:		; Baja el bit 4 de (0xE0BA) y repinta
	ld hl,0e0bah		;428a
	res 4,(hl)		;428d   ; apaga el parpadeo: la marca deja de alternar
	call pinta_la_marca_de_jugadores		;428f
	ld (0e000h),a		;4292   ; y la eleccion queda guardada en (0xE000)
	ret			;4295
pinta_la_marca_de_jugadores:		; Elige tres bytes de tabla_atributo_titulo segun los indicadores y el acarreo
	push af			;4296
	rlca			;4297   ; el bit 7 elige entre las dos marcas
	ld hl,044d0h		;4298   ; con el puesto, el bloque que deja la marca en la fila de abajo
	jr c,elige_la_ventana		;429b
	ld hl,044cfh		;429d   ; y con el bajado, el que la deja en la de arriba
elige_la_ventana:		; El bit 4 de (0xE0BA) decide cual de las dos filas se marca
	ld a,(0e0bah)		;42a0
	bit 4,a		;42a3   ; y mientras el bit 4 de (0xE0BA) este puesto, se dibujan las dos: eso es el parpadeo
	jr z,escribe_la_marca		;42a5
	ld hl,044cch		;42a7
escribe_la_marca:		; Deja el bloque de 1x3 en la fila que toque
	ld de,01a05h		;42aa   ; columna 5 de la fila 16
	ld bc,00103h		;42ad   ; tres filas de un byte: la A arriba, nada en medio y la B abajo
	call copia_un_bloque		;42b0
	pop af			;42b3
	ret			;42b4
pasa_al_juego:		; Engancha el manejador de 0x44D3 y monta la pantalla de juego
	ld hl,044d3h		;42b5   ; Engancha el manejador temporal 0x44D3 en H.TIMI y monta la pantalla de juego (0x44F3)
	ld (0fda0h),hl		;42b8   ; un manejador temporal mas
	call monta_la_pantalla_de_juego		;42bb
	xor a			;42be
	ld (0e004h),a		;42bf   ; y a jugar
	ld hl,0e0b4h		;42c2
cierra_el_hoyo:		; Espera, refresca el marcador y avanza de hoyo mientras no se pase de 18
	push hl			;42c5   ; Espera entrada, ejecuta 0x593B/0x4754, avanza el hoyo si es menor que 0x12 o reinicia si no
	call monta_el_marcador		;42c6
	call refresca_el_marcador		;42c9   ; Refresca el marcador de golpes (0x4754) antes de comprobar el limite de hoyos
	pop hl			;42cc
	ld a,(hl)			;42cd
	cp 012h		;42ce
	jp nc,init		;42d0
	inc a			;42d3
	ld (hl),a			;42d4
	xor a			;42d5
	ld (0e0bah),a		;42d6
espera_o_reinicia:		; Con el disparo pulsado reinicia el cartucho; si no, espera a que (0xE0BA) llegue a 0x60
	ld a,(0e004h)		;42d9   ; Si se pulsa el boton de disparo (0xE004 bit 6) reinicia el cartucho; si no, espera a que (0xE0BA) llegue a 0x60
	rlca			;42dc
	jp c,init		;42dd
	ld a,(0e0bah)		;42e0
	cp 060h		;42e3
	jr c,espera_o_reinicia		;42e5
	jr cierra_el_hoyo		;42e7
registra_los_sonidos:		; Da de alta los dos bloques fijos de sonido, canales 0 y 1
	ld b,000h		;42e9   ; Registra dos bloques de sonido fijos (canales 0 y 1) via 0xBD03
	ld de,0bc29h		;42eb
	call registra_un_bloque		;42ee
	ld b,001h		;42f1
	ld de,0bc78h		;42f3
	jp registra_un_bloque		;42f6

; ----------------------------------------------------------------------
; DATOS texto_titulo_00: Texto corto de la pantalla de titulo, 8 bytes
;   (0x41A9, 0x4145)
;   0x42f9..0x4301  (8 bytes)
DATA_texto_titulo_00:
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch	; 42f9  <B....B<

; ----------------------------------------------------------------------
; DATOS logotipo_titulo: Bloque de 304 bytes copiado tal cual a VRAM (LDIRVM),
;   patrones del logotipo de la pantalla de titulo
;   0x4301..0x4431  (304 bytes)
DATA_logotipo_titulo:
	defb 000h,003h,03fh,077h,063h,0e0h,0e0h,0e0h,0e0h,0e3h,0e3h,0e3h,0e3h,07fh,03eh,000h	; 4301  ..?wc.........>.
	defb 000h,01ch,01ch,02ch,02eh,02eh,02eh,06eh,07eh,07eh,06eh,06fh,06fh,000h,000h,000h	; 4311  ...,...n~~noo...
	defb 03ch,066h,062h,062h,070h,038h,01ch,00eh,00eh,04eh,04eh,07ch,071h,000h,000h,000h	; 4321  <fbbp8...NN|q...
	defb 000h,07ch,038h,038h,038h,038h,038h,070h,070h,070h,070h,070h,0f8h,000h,000h,000h	; 4331  .|88888ppppp....
	defb 000h,000h,000h,018h,03ch,072h,0e2h,0e2h,0e2h,0e2h,0e2h,0e2h,0e6h,06ch,030h,000h	; 4341  ....<r.......l0.
	defb 000h,000h,080h,0c0h,0e0h,0e4h,0c6h,0c3h,0d3h,0d2h,0d2h,0f2h,0fah,0eeh,08eh,004h	; 4351  ................
	defb 03ch,072h,072h,072h,072h,072h,072h,03ch,0e8h,066h,063h,063h,063h,07eh,074h,077h	; 4361  <rrrrrr<.fccc~tw
	defb 0f3h,031h,00ch,000h,000h,000h,000h,000h,000h,0fch,070h,070h,073h,033h,033h,07eh	; 4371  .1........pps33~
	defb 080h,0c0h,0e0h,071h,03fh,01ch,000h,000h,000h,0f8h,07eh,072h,073h,073h,077h,0feh	; 4381  ...q?.....~rssw.
	defb 000h,020h,040h,080h,000h,000h,000h,000h,070h,0cch,0c6h,0e2h,0e2h,0e2h,076h,03ch	; 4391  . @.....p.....v<
	defb 000h,000h,000h,000h,000h,01ch,03fh,063h,0e3h,0e7h,07eh,070h,070h,078h,0f0h,0c0h	; 43a1  ......?c..~ppx..
	defb 00eh,01ah,032h,070h,0f2h,074h,078h,070h,072h,072h,074h,078h,0e0h,0c0h,000h,000h	; 43b1  ..2p.txprrtx....
	defb 001h,006h,006h,012h,032h,072h,0fah,07ah,0aah,076h,077h,076h,074h,070h,0e0h,080h	; 43c1  ....2r.z.vwvtp..
	defb 000h,001h,000h,006h,01fh,03fh,033h,040h,007h,00fh,01fh,038h,030h,060h,040h,080h	; 43d1  .....?3@...80`@.
	defb 0c0h,0e0h,071h,033h,01eh,08ch,0efh,07eh,03ch,0dfh,0f3h,031h,031h,071h,073h,0e3h	; 43e1  ..q3...~<..11qs.
	defb 000h,0e0h,0f0h,090h,000h,0e0h,0f0h,030h,010h,000h,080h,0c0h,0c0h,0c0h,080h,000h	; 43f1  .......0........
	defb 000h,000h,001h,001h,003h,003h,007h,007h,00fh,00fh,01fh,01eh,03eh,03ch,07ch,0f8h	; 4401  ............><|.
	defb 0ech,0e8h,0c0h,0c0h,0c0h,080h,080h,000h,0fbh,0fbh,0f1h,0f1h,0e1h,0c1h,0c1h,081h	; 4411  ................
	defb 000h,001h,003h,007h,00fh,01fh,03fh,07fh,0ffh,03fh,00eh,006h,000h,000h,000h,000h	; 4421  ......?..?......

; ----------------------------------------------------------------------
; DATOS bloque_titulo_00: Bloque de patrones 3x3 via 0x44E5 (0x41DD)
;   0x4431..0x443a  (9 bytes)
DATA_bloque_titulo_00:
	defb 09bh,09dh,09fh,09ch,09eh,0a0h,0a1h,0a3h,020h	; 4431  ........ 

; ----------------------------------------------------------------------
; DATOS bloque_titulo_01: Bloque de patrones 16x4 via 0x44E5 (0x41E9)
;   0x443a..0x447a  (64 bytes)
DATA_bloque_titulo_01:
	defb 081h,083h,085h,087h,089h,020h,0a2h,020h,020h,020h,020h,020h,020h,020h,020h,099h	; 443a  ..... .        .
	defb 082h,084h,086h,088h,08ah,0a5h,0a4h,08bh,020h,020h,020h,020h,020h,095h,097h,09ah	; 444a  ........     ...
	defb 020h,020h,020h,020h,020h,0a6h,020h,08ch,08dh,08eh,090h,092h,094h,096h,098h,020h	; 445a       . ........ 
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,08fh,091h,093h,020h,020h,020h,020h	; 446a           ...    

; ----------------------------------------------------------------------
; DATOS texto_titulo_01: Texto corto de la pantalla de titulo, 13 bytes
;   (0x41EF)
;   0x447a..0x4487  (13 bytes)
DATA_texto_titulo_01:
	defb 04dh,053h,058h,020h,047h,04fh,04ch,046h,020h,047h,041h,04dh,045h	; 447a  MSX GOLF GAME

; ----------------------------------------------------------------------
; DATOS texto_titulo_02: Texto corto de la pantalla de titulo, 13 bytes
;   (0x41FA)
;   0x4487..0x4494  (13 bytes)
DATA_texto_titulo_02:
	defb 050h,04ch,041h,059h,045h,052h,020h,053h,045h,04ch,045h,043h,054h	; 4487  PLAYER SELECT

; ----------------------------------------------------------------------
; DATOS texto_titulo_03: Texto corto, 18 bytes, leido DOS veces a dos destinos
;   VRAM distintos (0x4205 y 0x4212)
;   0x4494..0x44a6  (18 bytes)
DATA_texto_titulo_03:
	defb 050h,04ch,041h,059h,020h,050h,055h,053h,048h,020h,054h,052h,049h,047h,047h,045h	; 4494  PLAY PUSH TRIGGE
	defb 052h,031h	; 44a4

; ----------------------------------------------------------------------
; DATOS texto_titulo_04: Texto corto de la pantalla de titulo, 13 bytes
;   (0x421A)
;   0x44a6..0x44b3  (13 bytes)
DATA_texto_titulo_04:
	defb 054h,04fh,020h,053h,054h,041h,052h,054h,020h,047h,041h,04dh,045h	; 44a6  TO START GAME

; ----------------------------------------------------------------------
; DATOS texto_titulo_05: Texto corto de la pantalla de titulo, 22 bytes
;   (0x4225)
;   0x44b3..0x44c9  (22 bytes)
DATA_texto_titulo_05:
	defb 043h,04fh,050h,059h,052h,049h,047h,048h,054h,020h,031h,039h,038h,035h,020h,040h	; 44b3  COPYRIGHT 1985 @
	defb 020h,043h,041h,053h,049h,04fh	; 44c3

; ----------------------------------------------------------------------
; DATOS bloque_titulo_02: Bloque de patrones 1x3 via 0x44E5 (0x4230)
;   0x44c9..0x44cc  (3 bytes)
DATA_bloque_titulo_02:
	defb 031h,020h,032h	; 44c9

; ----------------------------------------------------------------------
; DATOS tabla_atributo_titulo: 7 bytes; 0x4296 (0x4296) elige una ventana de 3
;   dentro (offset 0, 3 o 4) segun flags de (0xE0BA) y el acarreo de A
;   0x44cc..0x44d3  (7 bytes)
DATA_tabla_atributo_titulo:
	defb 041h,020h,042h,041h,020h,020h,042h	; 44cc

; ======================================================================
; CODIGO 0x44d3..0x45a8  (213 bytes)
; ======================================================================


interrupcion_de_juego:		; El manejador definitivo mas la comprobacion del bit 4 de (0xE0A8)
	call avanza_los_contadores		;44d3   ; Manejador de interrupcion definitivo mas comprobacion de (0xE0A8) bit 4: si esta activo, fuerza (0xE004)
	call multiplicador_base		;44d6
	ld a,(0e0a8h)		;44d9
	bit 4,a		;44dc
	ret z			;44de
	ld a,0ffh		;44df
	ld (0e004h),a		;44e1   ; que levanta (0xE004) para que 0x42D9 salga del bucle
	ret			;44e4
copia_un_bloque:		; C filas de B bytes, avanzando una fila de VRAM en cada vuelta
	call copia_a_vram		;44e5   ; Copia C filas de B bytes cada una (0x4145), avanzando el destino una fila de VRAM (32 bytes) por iteracion
	push hl			;44e8
	ld hl,00020h		;44e9   ; y 32 mas alla, la fila siguiente
	add hl,de			;44ec
	ex de,hl			;44ed
	pop hl			;44ee
	dec c			;44ef   ; C filas en total
	jr nz,copia_un_bloque		;44f0
	ret			;44f2
monta_la_pantalla_de_juego:		; Pasa por SCREEN 1 para quedarse con su juego de caracteres y lo lleva a SCREEN 2 como patrones del campo
	call 00041h		;44f3   ; BIOS DISSCR - Inhibits the screen display
	call 0006fh		;44f6   ; BIOS INIT32 - Switches to SCREEN 1 (text screen with 32*24 characters) | pasa por SCREEN 1 solo para quedarse con su juego de caracteres
	ld hl,00100h		;44f9
	ld de,0e800h		;44fc
	ld bc,00200h		;44ff   ; 512 bytes: los 64 caracteres del 0x20 al 0x5F, leidos de la VRAM a la RAM
	call 00059h		;4502   ; BIOS LDIRMV - Block transfers to memory from VRAM
	call 00072h		;4505   ; BIOS INIGRP - Switches to SCREEN 2 (high resolution screen with 256*192 pixels) | y vuelve a SCREEN 2
	ld hl,0e800h		;4508
	ld de,01500h		;450b
	ld bc,00200h		;450e
	call 0005ch		;4511   ; BIOS LDIRVM - Block transfers to VRAM from memory | esos mismos caracteres van a VRAM 0x1500, el tercer tercio de patrones: con ellos se pinta el campo
	ld a,0f1h		;4514   ; color 0xF1 en los 6144 bytes de la tabla de color
	ld hl,02000h		;4516
	ld bc,01800h		;4519
	call 00056h		;451c   ; BIOS FILVRM - Fills VRAM with value
	call carga_los_sprites		;451f   ; y los diez sprites de 16x16
	ld hl,0e0c2h		;4522
	ld b,05ch		;4525   ; 0x5C bytes de la tabla que empieza en 0xE0C2
rellena_una_fila:		; Deja la fila de patron a 0xC2
	ld (hl),0c2h		;4527   ; Rellena una fila de patron con 0xC2 (blanco/relleno)
	inc hl			;4529
	djnz rellena_una_fila		;452a
	ld a,097h		;452c
	ld bc,00302h		;452e
	ld hl,0e0c2h		;4531
calla_los_canales:		; Silencia los registros de sonido avanzando de cuatro en cuatro
	ld (hl),a			;4534   ; Rellena los registros de sonido con silencio, avanzando de 4 en 4
	inc hl			;4535
	inc hl			;4536
	inc hl			;4537
	ld (hl),000h		;4538
	inc hl			;453a
	djnz calla_los_canales		;453b
	add a,010h		;453d   ; Avanza el patron en pasos de 0x10 para el siguiente registro
	ld b,004h		;453f
	dec c			;4541
	jr nz,calla_los_canales		;4542
	ld hl,05097h		;4544   ; Fija los limites de camara por defecto (0xE0C2-0xE0C8)
	ld (0e0c2h),hl		;4547
	ld h,060h		;454a
	ld (0e0c6h),hl		;454c
	ld hl,00014h		;454f
	ld (0e0c4h),hl		;4552
	ld (0e0c8h),hl		;4555
	ld a,0a0h		;4558
	ld hl,01a60h		;455a   ; la franja de color de VRAM 0x1A60, 160 celdas
	ld c,0a0h		;455d
	call rellena_vram		;455f
muestra_la_pantalla:		; Enciende el video y deja el registro 1 del VDP en 0xE2
	call 00044h		;4562   ; BIOS ENASCR - Displays the screen | y ya se puede encender la pantalla
	ld bc,0e201h		;4565   ; registro 1 del VDP a 0xE2: pantalla encendida, interrupcion y sprites de 16x16
	jp 00047h		;4568   ; BIOS WRTVDP - Writes data in the VDP-register
limpia_el_terreno:		; Diecinueve pasadas sobre el buffer de terreno de 0xE800
	ld b,013h		;456b
	ld hl,0e800h		;456d   ; el buffer del terreno, en 0xE800
limpia_una_franja:		; Treinta y dos celdas por pasada
	push bc			;4570
	ld b,020h		;4571   ; treinta y dos celdas por franja
limpia_una_celda:		; Escribe el indice bajo en cada casilla
	ld (hl),l			;4573   ; y cada casilla se queda con su propio indice bajo
	inc hl			;4574
	djnz limpia_una_celda		;4575
	pop bc			;4577
	djnz limpia_una_franja		;4578
	ld hl,0e800h		;457a
	ld de,01800h		;457d
	ld bc,00260h		;4580   ; las 608 celdas se vuelcan a la tabla de nombres
	jp 0005ch		;4583   ; BIOS LDIRVM - Block transfers to VRAM from memory
lee_la_ficha_del_hoyo:		; Toma las cinco de datos_por_hoyo: el tipo de terreno a (0xE0A0) y (0xE09F), y cuatro parametros mas
	ld de,(0e0b4h)		;4586   ; Lee la entrada de datos_por_hoyo del hoyo actual (0xE0B4): tipo de terreno a (0xE0A0)/(0xE09F), y 4 parametros a (0xE0A1)-(0xE0A4)
	ld d,000h		;458a   ; el numero de hoyo cabe en un byte
	dec de			;458c   ; menos uno: el hoyo 1 es la entrada 0
	ld hl,045a8h		;458d
	add hl,de			;4590   ; cinco veces: cada ficha son cinco bytes
	add hl,de			;4591
	add hl,de			;4592
	add hl,de			;4593
	add hl,de			;4594
	ld a,(hl)			;4595
	ld (0e0a0h),a		;4596   ; el primer byte es el tipo de terreno
	and 00fh		;4599   ; y su nibble bajo va aparte, a (0xE09F)
	ld (0e09fh),a		;459b
	inc hl			;459e
	ld de,0e0a1h		;459f   ; Copia los 4 parametros restantes de la entrada a (0xE0A1)-(0xE0A4)
	ld bc,00004h		;45a2   ; seguidos, a 0xE0A1
	ldir		;45a5
	ret			;45a7

; ----------------------------------------------------------------------
; DATOS datos_por_hoyo: 18 entradas de 5 bytes (una por hoyo), indexadas por
;   (0xE0B4)-1 desde 0x4586 (0x458D)
;   0x45a8..0x4602  (90 bytes)
DATA_datos_por_hoyo:
	defb 004h,064h,020h,02ch,02ch	; 45a8
	defb 0e3h,03ch,020h,01ch,023h	; 45ad
	defb 004h,054h,028h,01ch,02ch	; 45b2
	defb 0c4h,06ch,018h,02ch,023h	; 45b7
	defb 0c4h,06ch,028h,02ch,023h	; 45bc
	defb 0c4h,05ch,010h,02ch,023h	; 45c1
	defb 005h,06ch,028h,02ch,02ch	; 45c6
	defb 0c4h,044h,010h,01ch,023h	; 45cb
	defb 004h,05ch,018h,01ch,02ch	; 45d0
	defb 045h,06ch,010h,02ch,02ch	; 45d5
	defb 004h,06ch,018h,02ch,02ch	; 45da
	defb 0c4h,054h,028h,01ch,023h	; 45df
	defb 0c4h,05ch,018h,01ch,023h	; 45e4
	defb 063h,03ch,020h,01ch,02ch	; 45e9
	defb 004h,044h,010h,02ch,02ch	; 45ee
	defb 004h,05ch,010h,02ch,02ch	; 45f3
	defb 084h,06ch,010h,02ch,023h	; 45f8
	defb 004h,05ch,028h,02ch,02ch	; 45fd

; ======================================================================
; CODIGO 0x4602..0x485a  (600 bytes)
; ======================================================================


despacha_por_bits:		; Va rotando (0xE001) y atiende cada bit puesto: es la lista de tareas del cuadro
	ld hl,0e001h		;4602   ; Despacho por bits de (0xE001): cada bit activo pide una accion distinta (rlca sucesivos van mirando el acarreo)
	ld a,(hl)			;4605   ; (0xE001) es la lista de tareas del cuadro: un bit por cosa que hacer
	rlca			;4606   ; bit 7: empieza un hoyo
	jr c,empieza_el_hoyo		;4607
	rlca			;4609   ; bit 6: cambia el turno
	jp c,cambia_de_turno		;460a
	rlca			;460d   ; bit 5: hay animacion de golpe
	jp c,mira_si_hay_animacion		;460e
	rlca			;4611   ; bit 4: hay animacion de camara
	jp c,mira_si_hay_animacion_de_camara		;4612
	rlca			;4615   ; bit 3: toca actualizar el contador del jugador
	jp c,elige_el_contador_del_jugador		;4616
	rlca			;4619   ; y si no queda ninguno, se acaba
	ret nc			;461a
	ld a,(0e0bah)		;461b   ; Ningun bit activo: si (0xE0BA)>=0xC0 no hace nada, si no copia (0xE006) a (0xE005)
	cp 0c0h		;461e   ; con (0xE0BA) por debajo de 0xC0 no hay nada mas
	ret c			;4620
	ld a,(0e006h)		;4621   ; y si no, (0xE006) pasa a (0xE005)
	ld (0e005h),a		;4624
	ret			;4627
empieza_el_hoyo:		; Registra el sonido y trae la lista de objetos del hoyo que toca
	rrc (hl)		;4628   ; Registra sonido y lee la lista de objetos del hoyo (0x6289)
	ld a,001h		;462a
	ld (0e0b5h),a		;462c   ; marca que el hoyo esta recien empezado
	call lee_la_ficha_del_hoyo		;462f   ; la ficha de cinco bytes del hoyo
	call lista_del_hoyo		;4632   ; y la lista de objetos que lleva dentro
	dec hl			;4635
	ld b,(hl)			;4636   ; Guarda las dos primeras posiciones como referencia de camara (0xE00E/0xE014)
	dec hl			;4637
	ld c,(hl)			;4638
	ld l,000h		;4639
	ld h,b			;463b
	ld (0e00eh),hl		;463c   ; son la referencia de camara en columna
	ld h,c			;463f
	ld (0e014h),hl		;4640   ; y en fila
	ld hl,0e000h		;4643   ; Ajusta el bit 6 de (0xE000) segun coincidan o no los punteros de datos de los jugadores
	ld a,(hl)			;4646
	and 0c0h		;4647   ; se queda solo con los dos bits altos: el modo y el turno
	ld (hl),a			;4649
	set 6,(hl)		;464a   ; y arranca el hoyo con el turno del jugador 1
	bit 7,(hl)		;464c   ; con un solo jugador no hay nada que decidir
	jr nz,mezcla_posicion_y_cuadro		;464e
	ld a,(0e09ah)		;4650   ; y con dos, empieza el que vaya peor de golpes
	ld bc,(0e09ch)		;4653
	cp c			;4657   ; empatados, el jugador 1
	jr z,mezcla_posicion_y_cuadro		;4658
	set 6,(hl)		;465a   ; el jugador 1 va por delante
	jr c,mezcla_posicion_y_cuadro		;465c
	res 6,(hl)		;465e   ; y si no, le toca al 2
mezcla_posicion_y_cuadro:		; Junta (0xE0BA) con el numero de cuadro, y marca el bit alto si el terreno lo pide
	ld hl,(0e0bah)		;4660   ; Combina la posicion (0xE0BA) con el fotograma (0xE072); si (0xE0A0) bit 5 esta activo marca el bit alto
	ld a,(0e072h)		;4663   ; el numero de cuadro va en la parte alta
	ld h,a			;4666
	ld a,(0e0a0h)		;4667
	bit 5,a		;466a   ; el bit 5 del terreno
	jr z,reinicia_el_turno		;466c
	set 7,h		;466e   ; pone el bit 7 de esa pareja
reinicia_el_turno:		; Deja a cero todas las variables de turno y de sonido
	ld (0e093h),hl		;4670   ; Reinicia todas las variables de turno y sonido al empezar partida
	xor a			;4673
	ld (0e069h),a		;4674   ; sin golpe en curso
	ld (0e076h),a		;4677
	ld (0e06ch),a		;467a
	ld (0e007h),a		;467d   ; ni turno pendiente
	ld (0e09ah),a		;4680   ; las dos puntuaciones a cero
	ld (0e09ch),a		;4683
	ld (0e076h),a		;4686
	ld (0e077h),a		;4689
	ld hl,05090h		;468c   ; Fija los limites de camara y puntero de puntuacion por defecto
	ld (0e112h),hl		;468f
	ld (0e11ah),hl		;4692
	ld hl,00f00h		;4695   ; y los limites de camara
	ld (0e0e8h),hl		;4698
	ld l,00ch		;469b
	ld (0e114h),hl		;469d
	ld h,001h		;46a0
	ld (0e11ch),hl		;46a2
	ld a,0c2h		;46a5   ; 0xC2 otra vez sobre las dos rutinas de RAM
	ld (0e0e6h),a		;46a7
	ld (0e116h),a		;46aa
	call estructura_del_jugador_uno		;46ad   ; Monta las posiciones iniciales de ambos jugadores
	jp estructura_del_jugador_dos		;46b0   ; y la del 2
columna_desde_la_fila:		; 0x7E menos la fila; el signo del terreno elige la paleta
	ld a,07eh		;46b3   ; Calcula 0x7E menos la fila como nueva columna; el signo de (0xE0A0) elige la paleta
	sub (hl)			;46b5   ; 0x7E menos la fila: el campo se dibuja de abajo arriba
	ld l,a			;46b6
	ld a,(0e0a0h)		;46b7
	rlca			;46ba   ; el bit 7 del terreno elige entre las dos paletas
	ld a,(de)			;46bb
	ld h,0b7h		;46bc
	jr nc,descarta_si_se_sale		;46be
	neg		;46c0   ; con el signo cambiado
	ld h,0f7h		;46c2   ; y la paleta de 0xF7
descarta_si_se_sale:		; Por debajo de la fila 0xB0 no dibuja nada
	add a,h			;46c4   ; Si la fila resultante se sale de pantalla (>=0xB0) no dibuja; si no, usa el patron 0xC2
	ld h,a			;46c5
	cp 0b0h		;46c6   ; a partir de la fila 0xB0 ya no se ve
	ret nc			;46c8
	ld l,0c2h		;46c9   ; y si se ve, el patron de relleno 0xC2
	ret			;46cb
cambia_de_turno:		; Enciende o apaga el bit 6 de (0xE000) segun toque
	rrc (hl)		;46cc   ; Segun los bits de (0xE000), activa o desactiva el bit 6 (turno/modo)
	ld hl,0e000h		;46ce
	ld a,(hl)			;46d1
	rlca			;46d2   ; con el bit 7 puesto, un solo jugador: la camara no cambia de dueno
	jr c,coloca_la_camara		;46d3
	and 078h		;46d5   ; los bits 3 a 6 dicen si hay algo en marcha
	jr z,junta_las_dos_posiciones		;46d7
	set 6,(hl)		;46d9   ; Si ninguna condicion especial se cumple, deja el bit 6 activo
	and 028h		;46db   ; y con los bits 3 o 5 puestos, se queda asi
	jr nz,coloca_la_camara		;46dd
	res 6,(hl)		;46df   ; si no, pasa al jugador 2
	jr coloca_la_camara		;46e1
junta_las_dos_posiciones:		; Prepara las posiciones de los dos jugadores para medir quien esta mas lejos
	ld bc,(0e037h)		;46e3   ; Combina las posiciones de los dos jugadores para el calculo de distancia (0x4740)
	ld a,(0e03ah)		;46e7   ; la posicion del jugador 1
	ld c,a			;46ea
	ld de,(0e046h)		;46eb   ; y la del 2
	ld a,(0e049h)		;46ef
	ld e,a			;46f2
	ld hl,(0e0a1h)		;46f3   ; con los parametros del hoyo
	call quien_esta_mas_lejos		;46f6   ; gana el turno el que este mas lejos de la bandera
coloca_la_camara:		; Prepara la vista y guarda la posicion de los dos jugadores como referencia
	call elige_las_dos_tablas		;46f9   ; Prepara la camara y guarda la posicion de ambos jugadores como referencia (0xE02E/0xE030/0xE032)
	call monta_el_marcador		;46fc   ; redibuja el marcador
	call valores_por_defecto		;46ff   ; y deja los valores de camara por defecto
	call camara_del_activo		;4702   ; centrada en el jugador que juega
	ld hl,(0e00eh)		;4705
	ld (0e02eh),hl		;4708   ; la columna de referencia
	ld hl,(0e014h)		;470b
	ld (0e030h),hl		;470e   ; la fila
	ld hl,(0e112h)		;4711
	ld (0e032h),hl		;4714   ; y el puntero de puntuacion
	ld a,(0e0b5h)		;4717   ; Calcula el rango de dificultad (0xE114) segun el puntero de datos de puntuacion (0xE112)
	ld (0e0b6h),a		;471a   ; el hoyo recien empezado se apunta tambien en (0xE0B6)
	ld a,(0e112h)		;471d
	cp 07fh		;4720   ; por encima de 0x7F, el rango mas ancho
	ld l,00ch		;4722
	jr nc,reinicia_el_hoyo		;4724
	cp 066h		;4726   ; de 0x66 a 0x7E, el de en medio
	ld l,008h		;4728
	jr nc,reinicia_el_hoyo		;472a
	ld l,004h		;472c   ; y por debajo, el mas estrecho
reinicia_el_hoyo:		; Hoyo, terreno y angulo de partida (0x80) a sus valores iniciales
	ld h,00fh		;472e   ; Reinicia hoyo, terreno y angulo inicial (0x80) al empezar partida
	ld (0e114h),hl		;4730   ; con 0x0F en la parte alta
	xor a			;4733
	ld (0e0bdh),a		;4734   ; sin golpe dado
	ld (0e073h),a		;4737
	ld a,080h		;473a
	ld (0e06ch),a		;473c   ; y el angulo de tiro arranca en 0x80, que es el centro
	ret			;473f
quien_esta_mas_lejos:		; Compara los dos valores absolutos y decide de quien es el turno
	call distancia_sin_signo		;4740   ; Compara dos valores absolutos con signo (0x5F8F) para decidir el turno
	push bc			;4743
	pop de			;4744
	ld b,a			;4745
	call distancia_sin_signo		;4746   ; y la del 2
	ld hl,0e000h		;4749
	cp b			;474c
	ret z			;474d   ; empatados, no se cambia el turno
	set 6,(hl)		;474e   ; Segun cual sea mayor, activa o desactiva el bit 6 de (0xE000)
	ret nc			;4750
	res 6,(hl)		;4751   ; y si el 2 esta mas lejos, le toca a el
	ret			;4753
refresca_el_marcador:		; Mira (0xE09E) y decide si hay que repintar
	ld hl,0e09eh		;4754
	ld a,(hl)			;4757   ; el bit 7 de (0xE09E) dice si solo hay que refrescar
	rlca			;4758
	jp c,mira_si_repinta		;4759
pinta_el_texto_del_marcador:		; Escribe el rotulo y rellena el color en dos franjas
	ld hl,0487eh		;475c   ; Dibuja el texto del marcador (0x4145) y rellena color en dos franjas
	ld de,01a78h		;475f   ; el rotulo va a VRAM 0x1A78
	ld b,007h		;4762   ; siete celdas
	call copia_a_vram		;4764
	ld a,0a0h		;4767   ; Rellena de color otra franja del marcador (bunker/agua)
	ld hl,01a98h		;4769   ; la de 0x1A98
	ld c,007h		;476c
	push bc			;476e
	call rellena_vram		;476f
	ld a,0a0h		;4772
	ld hl,01ad8h		;4774   ; y la de 0x1AD8
	pop bc			;4777
	call rellena_vram		;4778
	ld hl,0d0b1h		;477b   ; Monta las posiciones iniciales de ambos jugadores (0x4797)
	ld de,01ab6h		;477e   ; su casilla, VRAM 0x1AB6
	ld bc,(0e09ah)		;4781   ; y su puntuacion acumulada
	call prepara_las_cifras		;4785
	ld a,(0e000h)		;4788
	rlca			;478b   ; con el bit 7 de (0xE000) puesto no hay segundo jugador
	ret c			;478c
	ld hl,0d0b2h		;478d   ; y si lo hay, su patron
	ld de,01af6h		;4790   ; en VRAM 0x1AF6
	ld bc,(0e09ch)		;4793
prepara_las_cifras:		; Guarda el origen y elige el patron 0xAB o 0xAD segun el signo
	ld (0e055h),hl		;4797   ; Guarda HL como puntero fuente en (0xE055); elige patron 0xAB o 0xAD segun el signo de B
	ld a,b			;479a
	bit 7,a		;479b   ; el bit 7 de B es el signo de la puntuacion
	ld b,0abh		;479d   ; 0xAB es el mas
	jr z,prepara_el_golpe_en_el_hud		;479f
	neg		;47a1   ; y con el negativo, se le da la vuelta
	ld b,0adh		;47a3   ; y 0xAD es el menos
prepara_el_golpe_en_el_hud:		; Deja los cinco parametros de dibujo del marcador de golpe
	ld hl,0e057h		;47a5   ; Prepara los parametros de dibujo del marcador de golpe (0xE057-0xE05B)
	ld (hl),b			;47a8   ; el signo, primero
	call arranca_las_decenas		;47a9   ; luego las decenas y unidades
	ld (0e058h),hl		;47ac
	ld hl,0a0a0h		;47af   ; dos espacios de relleno
	ld (0e05ah),hl		;47b2
	ld hl,0e05bh		;47b5
	ld b,0b1h		;47b8   ; 0xB1 es el uno: las centenas se cuentan desde ahi
	ld a,c			;47ba
cuenta_las_centenas:		; Resta cien mientras quepa: las centenas de la cifra
	cp 064h		;47bb   ; Normaliza restando 100 repetidamente, contando las centenas en B
	jr c,cierra_la_cifra		;47bd
	sub 064h		;47bf
	ld (hl),b			;47c1   ; se escribe la cifra de centenas
	inc b			;47c2
	jr cuenta_las_centenas		;47c3
cierra_la_cifra:		; Guarda el resultado y vuelve al origen
	call arranca_las_decenas		;47c5
	ld (0e05ch),hl		;47c8
	ld hl,0e055h		;47cb
	ld b,009h		;47ce   ; nueve bytes en total por marcador
	jp copia_a_vram		;47d0
arranca_las_decenas:		; Entra con el codigo del cero ya puesto en L
	ld l,0b0h		;47d3   ; 0xB0 es el cero
cuenta_las_decenas:		; Resta diez mientras quepa, contando en L
	sub 00ah		;47d5   ; restando de diez en diez
	jr c,deja_las_unidades		;47d7
	inc l			;47d9   ; sube la cifra de las decenas
	jr cuenta_las_decenas		;47da
deja_las_unidades:		; Lo que sobra son las unidades, ya en codigo de caracter
	add a,0bah		;47dc   ; y lo que sobra son las unidades, ya como caracter
	ld h,a			;47de
	ret			;47df
mira_si_repinta:		; Segun el bit leido, decide si el marcador de golpe se redibuja
	rlca			;47e0   ; Segun el bit leido, decide si redibuja el marcador de golpe segun (0xE0C0)
	jr nc,prepara_el_repintado		;47e1   ; el bit 6 decide si se repinta entero
	ld a,(0e0c0h)		;47e3   ; y si no, solo cuando (0xE0C0) pasa de 0xA0
	cp 0a0h		;47e6
	ret c			;47e8
	xor a			;47e9
	ld (hl),a			;47ea   ; que se borra antes de repintar
	jp pinta_el_texto_del_marcador		;47eb
prepara_el_repintado:		; Limpia (0xE0C0) y monta el bucle de cincuenta pasos sobre (0xE12A)
	xor a			;47ee   ; Limpia (0xE0C0), marca el bit 6 del byte y prepara un bucle de 50 pasos sobre (0xE12A)
	ld (0e0c0h),a		;47ef   ; (0xE0C0) a cero: la cuenta de espera vuelve a empezar
	set 6,(hl)		;47f2   ; marca que ya se ha repintado
	ld a,(hl)			;47f4
	and 01fh		;47f5   ; los cinco bits bajos son el codigo de mensaje
	ld b,032h		;47f7   ; cincuenta celdas de la fila
	ld hl,0e12ah		;47f9
rellena_de_espacios:		; Deja la fila en blanco; el color depende de que jugador sea
	ld (hl),0a0h		;47fc   ; Rellena una fila con espacios; el color del marcador depende del jugador (0, 1 o resto)
	inc hl			;47fe
	djnz rellena_de_espacios		;47ff
	or a			;4801   ; codigo 0: sin mensaje
	jr z,elige_la_fila_del_marcador		;4802
	cp 002h		;4804   ; codigo 1: un color
	ld hl,0c2cfh		;4806
	jr c,pinta_la_segunda_fila		;4809
	ld hl,0c8d7h		;480b   ; Jugador 2: usa un color distinto y sigue en 0x484B
	jr z,pinta_la_segunda_fila		;480e
	sub 002h		;4810
	ld hl,0485ah		;4812   ; y del 3 en adelante, uno de los cinco textos de 0x485A
lee_la_cuenta:		; Toma la longitud del texto siguiente
	ld b,(hl)			;4815   ; el primer byte de cada texto es su longitud
	inc hl			;4816
	dec a			;4817
	jr z,prepara_la_copia		;4818   ; hasta llegar al que toca
salta_el_texto:		; Se salta el texto que no toca
	inc hl			;481a
	djnz salta_el_texto		;481b   ; saltandose los que no
	jr lee_la_cuenta		;481d
prepara_la_copia:		; Deja la longitud en BC y el destino en 0xE12B
	ld c,b			;481f
	ld b,000h		;4820
	ld de,0e12bh		;4822   ; el texto se monta en 0xE12B
	ldir		;4825
elige_la_fila_del_marcador:		; El bit 6 de (0xE000) dice en cual de las dos filas va
	ld a,(0e000h)		;4827
	ld de,01ab8h		;482a   ; la fila del jugador 1
	bit 6,a		;482d   ; o la del 2, segun el bit 6 de (0xE000)
	jr nz,pinta_los_golpes		;482f
	ld de,01af8h		;4831
pinta_los_golpes:		; Escribe los siete bytes del contador y los seis del texto de al lado
	push de			;4834   ; Dibuja el marcador de golpes actual (7 bytes) y el texto siguiente (6 bytes)
	ld hl,0e12ah		;4835
	ld b,007h		;4838   ; siete bytes de contador
	call copia_a_vram		;483a
	pop hl			;483d   ; Recupera el puntero y salta al segundo texto del marcador
	ld de,0ffe1h		;483e   ; menos 0x1F: la casilla del texto que va al lado
	add hl,de			;4841
	ex de,hl			;4842
	ld hl,0e131h		;4843
	ld b,006h		;4846   ; y seis bytes de texto
	jp copia_a_vram		;4848
pinta_la_segunda_fila:		; La misma pareja, en la fila del otro jugador
	ld (0e141h),hl		;484b
	ld hl,0e12ah		;484e
	ld de,01a76h		;4851   ; y en la fila del otro jugador, un bloque de cinco filas por diez
	ld bc,00a05h		;4854
	jp copia_un_bloque		;4857

; ----------------------------------------------------------------------
; DATOS textos_puntuacion: Cinco textos de puntuacion de golf con longitud en
;   el primer byte (EAGLE, BIRDIE, PAR, BOGEY, " BOGEYDOUBLE"), leidos por
;   0x4754/0x4145
;   0x485a..0x487e  (36 bytes)
DATA_textos_puntuacion:
	defb 005h,0c5h,0c1h,0c7h,0cch,0c5h,006h,0c2h,0c9h,0d2h,0c4h,0c9h,0c5h,003h,0d0h,0c1h	; 485a  ................
	defb 0d2h,005h,0c2h,0cfh,0c7h,0c5h,0d9h,00ch,0a0h,0c2h,0cfh,0c7h,0c5h,0d9h,0c4h,0cfh	; 486a  ................
	defb 0d5h,0c2h,0cch,0c5h	; 487a

; ----------------------------------------------------------------------
; DATOS texto_titulo_06: Texto corto, 7 bytes (0x475C)
;   0x487e..0x4885  (7 bytes)
DATA_texto_titulo_06:
	defb 090h,091h,092h,0a0h,0a0h,093h,094h	; 487e

; ======================================================================
; CODIGO 0x4885..0x4a72  (493 bytes)
; ======================================================================


mira_si_hay_animacion:		; Con un golpe en curso no toca nada
	ld a,(0e007h)		;4885   ; Si hay una animacion de golpe en curso (0xE06C/0xE076), no hace nada
	ld hl,0e06ch		;4888   ; (0xE06C) es la animacion de golpe
	or (hl)			;488b
	ld hl,0e076h		;488c   ; y (0xE076) la de camara
	or (hl)			;488f
	ret nz			;4890   ; con cualquiera de las tres en marcha, no se toca nada
	call elige_el_contador		;4891   ; el contador del jugador que juega
	call para_el_canal		;4894   ; y calla el canal de sonido
	ld hl,0e069h		;4897   ; Comprueba el estado del turno actual antes de decidir la accion
	ld a,(hl)			;489a   ; Segun el estado del turno (0xE069), decide la siguiente accion (sonido, sprite o cambio de fase)
	and 00fh		;489b   ; los cuatro bits bajos del estado
	jr nz,marca_el_marcador_sucio		;489d   ; con alguno puesto, solo hay que refrescar el marcador
	ld a,(hl)			;489f
	bit 4,a		;48a0   ; el bit 4 pide descontar el contador
	jr nz,descuenta_el_contador		;48a2
	rlca			;48a4   ; y el bit 7, sortear el golpe del ordenador
	jp c,sortea_con_el_cuadro		;48a5
	call posicion_del_tile		;48a8   ; mira el tile que hay bajo la bola
	jp z,sonido_de_arranque		;48ab   ; sin tile, el sonido de arranque
	cp 00fh		;48ae   ; terreno 0x0F
	jr z,registra_el_sonido_del_terreno		;48b0
	cp 004h		;48b2   ; o terreno 0x04
registra_el_sonido_del_terreno:		; Si el terreno no es el especial, da de alta el bloque del canal 2
	jp z,registra_el_tercer_sonido		;48b4   ; Si el terreno no es el especial (0x0C), registra un bloque de sonido en el canal 2
	ld a,(0e073h)		;48b7
	cp 00ch		;48ba   ; y con el terreno 0x0C no suena nada
	jr z,pide_el_repintado		;48bc
	ld b,002h		;48be
	ld de,0bbfch		;48c0   ; 0xBBFC es el bloque de sonido del canal 2
	call registra_un_bloque		;48c3
pide_el_repintado:		; Deja (0xE001) a 0x40, que es lo que pide redibujar
	call elige_la_estructura_del_turno		;48c6
	ld a,040h		;48c9   ; el bit 6 de la lista de tareas: repintar
	ld (0e001h),a		;48cb
	ret			;48ce
marca_el_marcador_sucio:		; Deja (0xE09E) a 0x81
	ld a,081h		;48cf   ; 0x81 en (0xE09E): el marcador se redibuja entero
	ld (0e09eh),a		;48d1
pasa_al_otro_jugador:		; Copia posicion y datos del otro a las variables del turno activo
	ld a,(0e0b6h)		;48d4   ; Copia posicion y datos del otro jugador a las variables activas del turno
	ld (0e0b5h),a		;48d7   ; el otro jugador pasa a ser el activo
	ld hl,(0e02eh)		;48da
	ld (0e00eh),hl		;48dd   ; su columna
	ld hl,(0e030h)		;48e0
	ld (0e014h),hl		;48e3   ; su fila
	ld hl,(0e032h)		;48e6
	ld (0e11ah),hl		;48e9   ; y su puntero de puntuacion, por partida doble
	ld (0e112h),hl		;48ec
encadena_el_refresco:		; Registra el sonido y encadena terreno, marcador y viento
	ld b,002h		;48ef   ; Registra el primer bloque de sonido (canal 2) y encadena el refresco de terreno, HUD y viento
	ld de,0bb86h		;48f1   ; 0xBB86, el bloque del canal 2
	call registra_un_bloque		;48f4
	call refresca_el_marcador		;48f7   ; repinta el marcador
	call camara_del_activo		;48fa   ; centra la camara en el que juega
	call valores_a_cero		;48fd   ; y pone a cero los valores de trabajo
	call elige_el_contador		;4900
	jr pide_el_repintado		;4903
descuenta_el_contador:		; Baja el contador y reparte segun con que valor se queda
	call elige_el_contador		;4905   ; Decrementa el contador leido de 0x554B y ramifica segun su valor final
	ld a,(hl)			;4908
	dec a			;4909   ; Si el contador llega a 1, redibuja el marcador especial (0xE09F=5)
	ld (hl),a			;490a
	dec a			;490b
	jr z,escala_por_cuatro		;490c   ; al llegar a uno, se escala y sigue
	dec a			;490e
	jr nz,mira_los_dos_bits_bajos		;490f   ; y al llegar a dos, se mira el terreno
	ld a,(0e09fh)		;4911
	sub 005h		;4914   ; el terreno 5 tambien escala
	jr z,escala_por_cuatro		;4916
mira_los_dos_bits_bajos:		; Los dos bits bajos de (0xE0BA) deciden el camino
	ld a,(0e0bah)		;4918
	and 003h		;491b   ; los dos bits bajos de (0xE0BA)
	jr nz,escala_por_cuatro		;491d
	ld a,008h		;491f   ; el bit 3 de la lista de tareas
	ld (0e001h),a		;4921
sonido_del_canal_dos:		; Da de alta el bloque de 0xBBEC en el canal 2
	ld b,002h		;4924
	ld de,0bbech		;4926   ; 0xBBEC, otro bloque del canal 2
	jp registra_un_bloque		;4929
sortea_con_el_cuadro:		; Mezcla (0xE0B9) con el numero de cuadro: el azar del cartucho
	ld b,002h		;492c   ; Registra sonido en el canal 2 y calcula un valor pseudoaleatorio con (0xE0B9) xor (0xE072)
	ld de,0bbd2h		;492e   ; 0xBBD2, el bloque del canal 2
	call registra_un_bloque		;4931
	ld hl,(0e0b9h)		;4934
	ld a,(0e072h)		;4937   ; el numero de cuadro
	xor h			;493a   ; mezclado con (0xE0B9): asi sale el azar del cartucho
	ld l,a			;493b
	ld (0e095h),hl		;493c
	ld hl,(0e0a1h)		;493f   ; los parametros del hoyo
	ld de,(0e00eh)		;4942   ; y la posicion actual
	ld a,(0e015h)		;4946
	ld e,a			;4949
	call distancia_sin_signo		;494a   ; Compara la distancia horizontal con 0x5F8F para decidir si el golpe entra
	or a			;494d
	jr z,descuenta_el_contador		;494e   ; con distancia cero, se descuenta el contador
escala_por_cuatro:		; Dobla dos veces el valor antes de usarlo como indice
	add a,a			;4950   ; por cuatro
	add a,a			;4951
	cp 014h		;4952   ; y con tope en veinte
	jr c,calcula_el_viento		;4954
	ld a,014h		;4956
calcula_el_viento:		; Saca la fuerza y el rumbo del viento del cuadro
	push af			;4958   ; Calcula el viento actual (0x5FB2/0x601B)
	call rumbo_y_distancia		;4959   ; la fuerza y el rumbo del viento de este cuadro
	pop hl			;495c
	ld l,000h		;495d
	call angulo_a_coordenadas		;495f   ; pasados a componentes de columna y fila
	ld hl,(0e0a2h)		;4962   ; Calcula la posicion de salida sumando el desplazamiento del terreno
	ld l,000h		;4965
	add hl,bc			;4967   ; sumado a la componente
	ld (0e082h),hl		;4968   ; esa es la salida en columna
	ex de,hl			;496b   ; Ajusta el signo de la posicion Y segun (0xE0A0)
	ld a,(0e0a0h)		;496c
	rlca			;496f   ; el bit 7 del terreno
	call c,niega_de		;4970   ; le da la vuelta al signo de la fila
	ld de,(0e0a3h)		;4973   ; y el desplazamiento de fila
	ld e,000h		;4977
	add hl,de			;4979
	ld (0e079h),hl		;497a   ; esa es la salida en fila
	xor a			;497d
	ld (0e078h),a		;497e   ; sin altura acumulada
	ld (0e081h),a		;4981
	call elige_la_estructura_del_turno		;4984   ; Monta la lista de objetos del hoyo (0x4A11) y decide el siguiente estado segun (0xE000)
	ld hl,0e000h		;4987
	ld a,(hl)			;498a
	rlca			;498b   ; con un solo jugador, avisos directos
	jr c,enciende_los_avisos		;498c
	and 060h		;498e   ; y con dos, tambien si hay algo pendiente
	jr nz,enciende_los_avisos		;4990
	bit 6,(hl)		;4992   ; turno del jugador 1
	jr nz,marca_el_viento_sucio		;4994
	set 4,(hl)		;4996   ; bit 4: animacion de camara
	jp pide_el_repintado		;4998
marca_el_viento_sucio:		; Levanta el bit 5 y pide repintado
	set 5,(hl)		;499b   ; y bit 5: animacion de golpe
	jp pide_el_repintado		;499d
enciende_los_avisos:		; Levanta las dos senales de sonido y fuerza el color del indicador
	set 4,(hl)		;49a0   ; Activa dos senales de sonido y fuerza el color del indicador
	set 5,(hl)		;49a2
	ld a,010h		;49a4   ; el bit 4 de la lista de tareas
	ld (0e001h),a		;49a6
	ld a,0c2h		;49a9   ; 0xC2 sobre las dos rutinas de RAM otra vez
	ld (0e0e6h),a		;49ab
	ld (0e116h),a		;49ae
	ld a,080h		;49b1
	ld (0e077h),a		;49b3   ; el bit 7 de (0xE077): el aviso queda encendido
	jp prepara_los_indicadores		;49b6
registra_el_tercer_sonido:		; Da de alta el tercer bloque y ajusta el contador segun el signo de (0xE075)
	ld a,082h		;49b9   ; Registra un tercer bloque de sonido y ajusta un contador segun el signo de (0xE075)
	ld (0e09eh),a		;49bb   ; 0x82 en (0xE09E)
	ld b,001h		;49be
	ld de,0bc13h		;49c0   ; 0xBC13, en el canal 1
	call registra_un_bloque		;49c3
	ld a,(0e075h)		;49c6
	rlca			;49c9   ; el signo de (0xE075)
	ld b,0feh		;49ca   ; -2 si es positivo
	jr nc,arranca_la_busqueda_de_objeto		;49cc
	ld b,002h		;49ce   ; y +2 si es negativo: la busqueda va en un sentido o en el otro
arranca_la_busqueda_de_objeto:		; Prepara los punteros para recorrer los objetos del hoyo
	ld hl,(0e00eh)		;49d0   ; la posicion desde la que se busca
	ld a,(0e015h)		;49d3
	ld l,a			;49d6
busca_el_objeto_activo:		; Recorre los objetos hasta dar con uno marcado, o hasta pasar del limite 0x80
	ld a,l			;49d7   ; Recorre los objetos del hoyo hasta encontrar uno con el atributo activo, o hasta superar el limite (0x80)
	add a,b			;49d8   ; un paso en el sentido elegido
	cp 080h		;49d9   ; pasado el limite 0x80, se acaba y le toca al otro
	jp nc,pasa_al_otro_jugador		;49db
	ld l,a			;49de
	push hl			;49df
	push bc			;49e0
	call monta_los_objetos		;49e1   ; monta el objeto que hay en esa casilla
	pop bc			;49e4
	ld c,a			;49e5
	ld a,(ix+000h)		;49e6   ; Si no encuentra ninguno valido, sigue con el siguiente objeto
	and 02fh		;49e9   ; los bits 0 a 5 de su atributo
	jr z,guarda_la_salida		;49eb   ; con alguno puesto, ese objeto vale
	pop hl			;49ed
	jr busca_el_objeto_activo		;49ee   ; y si no, el siguiente
guarda_la_salida:		; Deja la posicion de partida del jugador y encadena sonido y marcador
	ld a,c			;49f0   ; Guarda la posicion inicial del jugador y sigue en 0x48EF (sonido/HUD)
	ld (0e0b5h),a		;49f1   ; el objeto encontrado pasa a ser la posicion del jugador
	ld (0e11ah),hl		;49f4   ; y su puntero de puntuacion
	ld (0e112h),hl		;49f7
	pop hl			;49fa
	ld a,h			;49fb
	ld (0e00fh),a		;49fc   ; la columna
	ld a,l			;49ff
	ld (0e015h),a		;4a00   ; y la fila
	jp encadena_el_refresco		;4a03
sonido_de_arranque:		; Da de alta el bloque de 0xBC09
	ld b,002h		;4a06
	ld de,0bc09h		;4a08   ; 0xBC09, en el canal 2
	call registra_un_bloque		;4a0b
	jp pide_el_repintado		;4a0e
elige_la_estructura_del_turno:		; El bit 6 de (0xE000) dice de que jugador son las variables
	push hl			;4a11
	ld hl,0e000h		;4a12
	bit 6,(hl)		;4a15   ; el bit 6 de (0xE000) dice quien juega
	pop hl			;4a17
	jr nz,estructura_del_jugador_uno		;4a18
estructura_del_jugador_dos:		; Apunta IY a la tabla del segundo
	ld iy,04a8ah		;4a1a   ; IY a la ficha del jugador 2
	jr estructura_comun		;4a1e
estructura_del_jugador_uno:		; Apunta IY a la del primero
	ld iy,04a7eh		;4a20   ; o a la del jugador 1
estructura_comun:		; Y IX a la tabla comun
	ld ix,04a72h		;4a24   ; y IX siempre a la ficha comun
	jr copia_los_parametros		;4a28
elige_las_dos_tablas:		; Reparte entre 0x4A7E y 0x4A8A segun el turno
	push hl			;4a2a   ; Elige entre dos tablas (0x4A7E/0x4A8A) segun el bit 6 de (0xE000)
	ld hl,0e000h		;4a2b
	bit 6,(hl)		;4a2e   ; aqui se reparte al reves
	pop hl			;4a30
	ld ix,04a7eh		;4a31   ; IX a la ficha del jugador 1
	jr nz,tabla_comun_por_defecto		;4a35
	ld ix,04a8ah		;4a37   ; o a la del 2
tabla_comun_por_defecto:		; El caso en el que IY tambien es la comun
	ld iy,04a72h		;4a3b   ; y IY a la comun
copia_los_parametros:		; Pasa los dos bloques comunes a la estructura de los dos jugadores
	push af			;4a3f   ; Copia dos bloques de datos comunes (parametros 2 y 3) a la estructura de ambos jugadores
	push bc			;4a40
	push de			;4a41
	push hl			;4a42
	ld bc,00002h		;4a43   ; el segundo bloque
	call copia_tres_bloques		;4a46   ; Cada bloque lo copia 0x4A54 (IX/IY en paralelo)
	ld bc,00003h		;4a49   ; y el tercero
	call copia_tres_bloques		;4a4c
	pop hl			;4a4f
	pop de			;4a50
	pop bc			;4a51
	pop af			;4a52
	ret			;4a53
copia_tres_bloques:		; Tres parejas de bytes por vuelta
	ld a,003h		;4a54   ; tres parejas por bloque
copia_un_par:		; Copia una pareja de la estructura IX a la IY
	ld l,(ix+000h)		;4a56   ; Copia A bloques de 2 bytes de la estructura IX a la IY
	ld h,(ix+001h)		;4a59   ; el par de la ficha de origen dice de donde se copia
	ld e,(iy+000h)		;4a5c
	ld d,(iy+001h)		;4a5f   ; y el de la de destino, adonde
	push bc			;4a62
	ldir		;4a63   ; la copia de verdad
	pop bc			;4a65
	inc ix		;4a66   ; Avanza ambos punteros (IX, IY) tras cada bloque
	inc ix		;4a68
	inc iy		;4a6a   ; y otros dos en la de destino
	inc iy		;4a6c
	dec a			;4a6e
	jr nz,copia_un_par		;4a6f
	ret			;4a71

; ----------------------------------------------------------------------
; DATOS tabla_variables_ram: 18 direcciones de RAM de 16 bits (rango
;   0xE00E-0xE112), indexadas por IX/IY desde tres puntos de arranque
;   distintos (0x4a1a, 0x4a20, 0x4a24); proposito exacto no determinado
;   0x4a72..0x4a96  (36 bytes)
DATA_tabla_variables_ram:
	defw 0e0b4h,0e00eh,0e014h,0e078h,0e081h,0e112h	; 4a72
	defw 0e035h,0e037h,0e039h,0e03bh,0e03eh,0e041h	; 4a7e
	defw 0e044h,0e046h,0e048h,0e04ah,0e04dh,0e050h	; 4a8a

; ======================================================================
; CODIGO 0x4a96..0x4b04  (110 bytes)
; ======================================================================


mira_si_hay_animacion_de_camara:		; Con (0xE077) ocupado no toca nada
	ld a,(0e077h)		;4a96
	or a			;4a99   ; con la camara moviendose, no se toca el contador
	ret nz			;4a9a
elige_el_contador_del_jugador:		; Con el bit 6 bajo, el puntero es el de la segunda mitad
	ld a,(0e000h)		;4a9b   ; Si el bit 6 de (0xE000) no esta activo, usa el puntero de la segunda mitad (0xE09C)
	ld hl,0e09ah		;4a9e
	bit 6,a		;4aa1   ; el bit 6 dice de quien es el contador
	jr nz,diferencia_con_el_terreno		;4aa3
	inc hl			;4aa5   ; dos bytes mas alla, el del jugador 2
	inc hl			;4aa6
diferencia_con_el_terreno:		; Diferencia con signo entre el terreno y el contador, saturada de 0 a 99
	ld a,(0e09fh)		;4aa7   ; Calcula la diferencia con signo entre el terreno y (hl), saturada aproximadamente entre 0 y 99
	sub (hl)			;4aaa   ; el terreno menos el contador
	neg		;4aab   ; con el signo cambiado
	ld b,a			;4aad
	inc hl			;4aae   ; Ajusta el resultado sumando el siguiente byte de la tabla
	add a,(hl)			;4aaf   ; mas el byte siguiente de la ficha
	cp 064h		;4ab0   ; por debajo de 100 vale
	jr c,guarda_y_comprueba		;4ab2
	cp 0dch		;4ab4   ; y por encima de 0xDC tambien, que es un numero negativo
	jr nc,guarda_y_comprueba		;4ab6
	ld a,063h		;4ab8   ; lo demas se recorta a 99
guarda_y_comprueba:		; Guarda el valor y mira si B mas 0x85 desborda
	ld (hl),a			;4aba   ; Guarda A y comprueba si B+0x85 desborda
	ld a,b			;4abb   ; el valor de antes de ajustarlo
	add a,085h		;4abc   ; mas 0x85: si desborda, el golpe ha sido fuerte
	jr nc,recorta_el_desborde		;4abe
	push af			;4ac0
	ld b,000h		;4ac1
	ld de,0bcd3h		;4ac3   ; Si desborda, registra dos bloques de sonido extra (impacto fuerte)
	call registra_un_bloque		;4ac6
	ld b,001h		;4ac9
	ld de,0bce6h		;4acb   ; y 0xBCE6 en el canal 1: el sonido del golpe fuerte
	call registra_un_bloque		;4ace
	pop af			;4ad1
recorta_el_desborde:		; Por encima de 0x88 se queda a cero
	cp 088h		;4ad2   ; por encima de 0x88, sin sonido
	jr c,guarda_el_sonido_y_repinta		;4ad4
	xor a			;4ad6
guarda_el_sonido_y_repinta:		; Deja el parametro de sonido y redibuja el marcador
	ld (0e09eh),a		;4ad7   ; Guarda el parametro de sonido y redibuja el marcador (0x4754)
	call refresca_el_marcador		;4ada   ; y el marcador se repinta
	ld hl,0e000h		;4add
	ld a,(hl)			;4ae0
	rlca			;4ae1   ; con el bit 7 puesto, un solo jugador
	jr c,$+39		;4ae2
	and 018h		;4ae4   ; los bits 3 y 4 dicen si hay algo pendiente
	jr nz,$+35		;4ae6
	bit 6,(hl)		;4ae8   ; Segun los bits de (0xE000), activa flags de sonido o pasa al siguiente estado
	jr z,marca_dos_senales		;4aea   ; con el turno en el jugador 2, se marcan otras dos senales
	set 5,(hl)		;4aec   ; bits 5 y 3: golpe y contador
	set 3,(hl)		;4aee
	bit 4,(hl)		;4af0   ; y el bit 4 decide adonde se sigue
	jp z,pide_el_repintado		;4af2
	jp enciende_los_avisos		;4af5
marca_dos_senales:		; Levanta los bits 2 y 4 y mira el 5
	set 2,(hl)		;4af8   ; bits 2 y 4 para el otro camino
	set 4,(hl)		;4afa
	bit 5,(hl)		;4afc
	jp z,pide_el_repintado		;4afe
	jp enciende_los_avisos		;4b01

; ----------------------------------------------------------------------
; DATOS codigo_huerfano: Codigo valido pero inalcanzable: `ld a,080h / ld
;   (0e077h),a`, la misma pareja que remata marca_la_fase (0x5520), sin un
;   solo salto que llegue hasta aqui
;   0x4b04..0x4b09  (5 bytes)
DATA_codigo_huerfano:
	defb 03eh,080h,032h,077h,0e0h	; 4b04

; ======================================================================
; CODIGO 0x4b09..0x4d2f  (550 bytes)
; ======================================================================


avanza_de_hoyo:		; Sube (0xE0B4): en el 19 se acaba la ronda, y en el 10 se cambia de recorrido
	ld hl,0e0b4h		;4b09   ; Avanza el hoyo (0xE0B4); si llega a 19 termina la ronda, si llega a 10 cambia de recorrido
	ld a,(hl)			;4b0c
	cp 012h		;4b0d   ; el hoyo 0x12 es el dieciocho: la ronda se acaba
	jr z,cierra_la_ronda		;4b0f
	inc a			;4b11
	ld (hl),a			;4b12   ; uno mas
	cp 00ah		;4b13   ; y en el diez se pasa de la ida a la vuelta
	jr z,cambia_de_recorrido		;4b15
	ld a,080h		;4b17   ; el bit 7 de la lista de tareas: empieza hoyo
pide_la_tarea:		; Deja la tarea pedida en (0xE001)
	ld (0e001h),a		;4b19
esconde_al_golfista:		; Pone Y=0xC2 -fuera de pantalla- a los NUEVE sprites del golfista, escribiendo de cuatro en cuatro desde 0xE0EA porque cada atributo son cuatro bytes
	ld a,0c2h		;4b1c
	ld hl,0e0eah		;4b1e   ; el buffer de atributos del golfista, 0xE0EA
	ld b,009h		;4b21   ; los nueve sprites que lo componen
rellena_la_columna:		; El bucle: un sprite cada cuatro bytes
	ld (hl),a			;4b23   ; Escribe A en la Y de cada uno de los nueve atributos, saltando de cuatro en cuatro
	inc hl			;4b24   ; cuatro bytes por atributo: Y, X, patron y color
	inc hl			;4b25
	inc hl			;4b26
	inc hl			;4b27
	djnz rellena_la_columna		;4b28
	ret			;4b2a
cierra_la_ronda:		; El codigo 0xC0 marca el final de las dieciocho
	ld a,0c0h		;4b2b   ; 0xC0 es el codigo de ronda terminada
guarda_el_cierre:		; Deja el codigo y pone a cero la posicion
	ld (0e006h),a		;4b2d
	xor a			;4b30
	ld (0e0bah),a		;4b31   ; y la posicion vuelve a cero
	ld a,004h		;4b34   ; el bit 2 de la lista de tareas
	jr pide_la_tarea		;4b36
cambia_de_recorrido:		; El codigo 0x80 marca el paso de la ida a la vuelta
	ld a,080h		;4b38   ; y 0x80 es el codigo de cambio de recorrido, de OUT a IN
	jr guarda_el_cierre		;4b3a
posicion_del_tile:		; Saca la direccion de VRAM del siguiente tile desde el puntero de puntuacion
	ld hl,(0e112h)		;4b3c   ; Calcula la posicion de VRAM del proximo tile a partir del puntero de puntuacion (0xE112)
	push hl			;4b3f   ; guarda la posicion, que hace falta luego
	ld a,h			;4b40
	and 0f8h		;4b41   ; la fila entera de casillas
	ld d,000h		;4b43
	ld e,a			;4b45
	ld a,l			;4b46
	and 0f8h		;4b47   ; y la columna
	rrca			;4b49   ; entre ocho
	rrca			;4b4a
	rrca			;4b4b
	ld h,a			;4b4c
	ld a,l			;4b4d
	and 007h		;4b4e   ; los tres bits bajos son la fila dentro de la casilla
	ld l,a			;4b50
	add hl,de			;4b51   ; y eso da la direccion del patron en la VRAM
	call 0004ah		;4b52   ; BIOS RDVRM - Reads the content of VRAM | Lee dos bytes de VRAM (patron actual y su vecino)
	ld d,a			;4b55
	set 5,h		;4b56   ; el bit 13 sube a la tabla de color, 0x2000 mas alla
	call 0004ah		;4b58   ; BIOS RDVRM - Reads the content of VRAM
	ld e,a			;4b5b
	pop hl			;4b5c
	ld a,h			;4b5d
	and 007h		;4b5e   ; los tres bits bajos de la columna
baja_el_contador:		; Descuenta hasta cero
	or a			;4b60
	jr z,normaliza_el_signo		;4b61   ; hasta gastarlos
	dec a			;4b63
	rlc d		;4b64   ; rotando el patron para dejar el pixel que toca en el bit alto
	jr baja_el_contador		;4b66
normaliza_el_signo:		; Rota D a la izquierda si el par D,E desborda
	ld a,e			;4b68   ; Normaliza el signo de D,E rotando D a la izquierda si desborda
	rlc d		;4b69   ; con el bit alto puesto
	jr nc,comprueba_el_nibble		;4b6b
	rlca			;4b6d   ; el color se cambia por su nibble alto
	rlca			;4b6e
	rlca			;4b6f
	rlca			;4b70
comprueba_el_nibble:		; Sale si el nibble bajo vale 0x0B
	and 00fh		;4b71   ; los cuatro bits del color
	cp 00bh		;4b73   ; el 0x0B es un color
	ret z			;4b75
	cp 006h		;4b76   ; y el 0x06 el otro
	ret			;4b78
prepara_los_indicadores:		; Deja 0xD0 en (0xE11E) y limpia la tira de 0xE0C2
	ld a,0d0h		;4b79
	ld (0e11eh),a		;4b7b   ; 0xD0 esconde el resto de sprites
	ld hl,0e0c2h		;4b7e
	ld de,01b00h		;4b81
	ld bc,0005dh		;4b84   ; los 93 bytes de atributos de sprite se vuelcan de golpe
	jp 0005ch		;4b87   ; BIOS LDIRVM - Block transfers to VRAM from memory
avanza_los_contadores:		; El manejador de interrupcion: sube los siete contadores de 0xE0BA
	ld hl,0e0bah		;4b8a
	ld b,007h		;4b8d   ; siete contadores seguidos desde 0xE0BA
sube_un_contador:		; Cada uno de esos siete incrementos
	inc (hl)			;4b8f   ; uno mas cada cuadro
	inc hl			;4b90
	djnz sube_un_contador		;4b91
	jp arranca_el_reproductor		;4b93   ; y de paso avanza la musica
despacha_la_animacion:		; Rota (0xE06C) y llama a la fase de animacion del golpe que toque
	ld hl,0e06ch		;4b96   ; Dispatcher por bits de (0xE06C): cada bit activo llama a la fase de animacion del golpe correspondiente
	ld a,(hl)			;4b99   ; (0xE06C) es la lista de fases de la animacion del golpe
	rlca			;4b9a   ; bit 7: mira los intentos
	jr c,mira_los_intentos		;4b9b
	rlca			;4b9d   ; bit 6: reinicia si toca
	jp c,reinicia_si_toca		;4b9e
	rlca			;4ba1   ; bit 5: invierte el angulo
	jp c,invierte_el_angulo		;4ba2
	rlca			;4ba5   ; bit 4: mira el angulo alto
	jp c,mira_el_angulo_alto		;4ba6
	rlca			;4ba9   ; bit 3: sube el angulo
	jp c,sube_el_angulo		;4baa
	rlca			;4bad   ; Si tampoco el bit del septimo intento esta activo, comprueba (0xE077)
	jp c,reinicia_los_intentos		;4bae
	rlca			;4bb1   ; y bit 1: el contador seis
	jp c,mira_el_contador_seis		;4bb2
	ld a,(0e077h)		;4bb5   ; Si ningun bit esta activo y (0xE077) es cero, usa el color de indicador por defecto
	or a			;4bb8   ; sin nada pendiente ni camara en marcha
	ret nz			;4bb9
	ld a,0c2h		;4bba   ; el color de indicador por defecto
	ld (0e0e2h),a		;4bbc
	ret			;4bbf
mira_los_intentos:		; Por encima de 0x60 intentos, recoloca la camara
	ld a,(0e0bdh)		;4bc0   ; Si los intentos (0xE0BD) superan 0x60, calcula una nueva posicion de camara
	cp 060h		;4bc3   ; por debajo de 0x60 intentos no hay nada que hacer
	ret c			;4bc5
	rrc (hl)		;4bc6   ; y si los hay, se atiende y se baja el bit
	ld de,(0e0a1h)		;4bc8
	ld hl,(0e00eh)		;4bcc
	ld a,(0e015h)		;4bcf
	cp 0d0h		;4bd2   ; por encima de 0xD0, la fila se pone a cero
	jr c,recalcula_el_viento		;4bd4
	xor a			;4bd6
recalcula_el_viento:		; Vuelve a sacar fuerza y rumbo para el nuevo cuadro
	ld l,a			;4bd7   ; Calcula el viento actual (0xE070/0xE06F) con 0x5FB2
	push hl			;4bd8
	call rumbo_y_distancia		;4bd9   ; el rumbo y la distancia del viento
	ld (0e070h),a		;4bdc   ; que queda en (0xE070)
	ld (0e06fh),a		;4bdf   ; y en (0xE06F)
	pop hl			;4be2
	call monta_los_objetos		;4be3   ; Monta la lista de objetos del hoyo (0x610B) y el sprite correspondiente (0x4B3C)
	ld hl,(0e112h)		;4be6
	ld (0e098h),hl		;4be9   ; y el puntero de puntuacion se copia a (0xE098)
	call posicion_del_tile		;4bec   ; el tile que hay bajo el puntero
	ld hl,0e06dh		;4bef
	ld (hl),000h		;4bf2   ; la fase de animacion, a cero
	jr nz,elige_el_sprite_fijo		;4bf4
	set 1,(hl)		;4bf6   ; y con el color que toca, el bit 1
elige_el_sprite_fijo:		; Reparte entre tres sprites segun (0xE114)
	ld a,(0e114h)		;4bf8   ; Elige uno de tres sprites fijos (dispatch de 3 vias) segun (0xE114)
	cp 008h		;4bfb   ; por debajo de 8
	ld a,006h		;4bfd
	ld hl,0b9f0h		;4bff   ; el sprite de 0xB9F0
	jr c,dibuja_el_sprite_fijo		;4c02
	ld a,008h		;4c04   ; justo 8
	ld hl,0b777h		;4c06   ; el de 0xB777
	jr z,dibuja_el_sprite_fijo		;4c09
	ld a,009h		;4c0b   ; y por encima
	ld hl,0b4aeh		;4c0d   ; el de 0xB4AE
dibuja_el_sprite_fijo:		; Guarda el sonido, pinta el sprite elegido y fija los parametros de animacion
	ld (0e097h),a		;4c10   ; Guarda el parametro de sonido, dibuja el sprite fijo elegido (0x5293) y fija los parametros de animacion
	call descomprime_a_la_ram		;4c13   ; se descomprime a la RAM
	ld a,001h		;4c16
	call guarda_el_estado_y_repinta		;4c18   ; y se repinta
	ld hl,00f24h		;4c1b   ; Fija los limites de camara por defecto (0xE0E4/0xE0DE/0xE0E0)
	ld (0e0e4h),hl		;4c1e   ; los limites de camara
	ld hl,06898h		;4c21
	ld (0e0deh),hl		;4c24
	ld hl,00710h		;4c27
	ld (0e0e0h),hl		;4c2a
	ret			;4c2d
reinicia_si_toca:		; Con el bit 4 de (0xE0A7) puesto, angulo y potencia vuelven a cero y el terreno se repinta
	ld a,(0e0a7h)		;4c2e   ; Si (0xE0A7) bit 4 esta activo, reinicia angulo y potencia y redibuja el terreno
	bit 4,a		;4c31   ; el bit 4 de (0xE0A7)
	jr z,mira_si_hay_angulo		;4c33
	rrc (hl)		;4c35
	xor a			;4c37
	ld (0e092h),a		;4c38   ; angulo a cero
	ld (0e071h),a		;4c3b   ; y potencia a cero
	call camara_del_activo		;4c3e   ; la camara vuelve al jugador
	jp mira_si_es_el_especial		;4c41
mira_si_hay_angulo:		; Sin angulo (0xE0A8) o con la camara ocupada, no hace nada
	ld hl,0e077h		;4c44   ; Si (0xE077) bit 6 esta activo o no hay angulo (0xE0A8=0), no hace nada
	bit 6,(hl)		;4c47   ; el bit 6 de (0xE077): la camara esta ocupada
	jr nz,repinta_el_terreno		;4c49
	ld a,(0e0a8h)		;4c4b
	and 003h		;4c4e   ; sin direccion pulsada, tampoco
	jr z,repinta_el_terreno		;4c50
	ld b,00bh		;4c52   ; Elige entre dos parametros segun los bits de (0xE06D)/(0xE069)
	ld l,06dh		;4c54
	bit 1,(hl)		;4c56   ; el bit 1 de (0xE06D)
	jr nz,acerca_el_terreno		;4c58
	ld l,069h		;4c5a
	bit 6,(hl)		;4c5c   ; o el bit 6 de (0xE069)
	jr z,acerca_el_terreno		;4c5e
	ld b,00ch		;4c60   ; suben el tope a 12
acerca_el_terreno:		; Sube o baja el tipo de terreno hacia B, saturando en 0xFF
	rrca			;4c62   ; Compara el terreno con B; si lo iguala o supera, satura a 0xFF
	ld l,073h		;4c63
	ld a,(hl)			;4c65
	jr c,terreno_baja		;4c66   ; hacia abajo
	cp b			;4c68
	jr c,terreno_sube		;4c69   ; y hacia arriba mientras no llegue al tope
	ld a,0ffh		;4c6b   ; si lo alcanza, da la vuelta
terreno_sube:		; Un paso hacia arriba
	inc a			;4c6d
	jr guarda_el_terreno		;4c6e
terreno_baja:		; Un paso hacia abajo, sin pasarse de B
	dec a			;4c70
	jp p,guarda_el_terreno		;4c71
	ld a,b			;4c74
guarda_el_terreno:		; Lo deja puesto y mira si es el especial
	ld (hl),a			;4c75
	cp 00ch		;4c76   ; el terreno 0x0C es el especial
	jr nz,repinta_el_terreno		;4c78
	ld a,(0e070h)		;4c7a
	ld (0e06fh),a		;4c7d   ; y ahi el viento se congela en su valor base
repinta_el_terreno:		; Con la camara ocupada, redibuja y fuerza el tipo especial
	ld a,(0e077h)		;4c80   ; Si (0xE077) esta activo, redibuja el terreno y fuerza el tipo especial (0x0C)
	or a			;4c83   ; sin camara ocupada, se dibuja normal
	jr z,dibuja_el_terreno		;4c84
	call posicion_de_camara		;4c86
	ld a,00ch		;4c89   ; y con ella, el terreno se fuerza al especial
	ld (0e073h),a		;4c8b
	or a			;4c8e
	jr dibuja_y_remata		;4c8f
dibuja_el_terreno:		; Manda a dibujar y mira el signo del parametro
	call camara_del_activo		;4c91
	ld a,(0e0a0h)		;4c94   ; el bit 7 del terreno elige por que lado entra
	rlca			;4c97
dibuja_y_remata:		; Dibuja y encadena el remate
	call elige_el_lado		;4c98
	call limites_por_defecto		;4c9b
mira_si_es_el_especial:		; Marca en A si el terreno actual es el tipo 0x0C
	ld a,(0e073h)		;4c9e   ; Marca en A si el terreno actual es el especial (tipo 0x0C)
	ld l,a			;4ca1
	cp 00ch		;4ca2   ; el 0x0C otra vez
	ld a,001h		;4ca4
	jr z,dibuja_por_tabla		;4ca6
	xor a			;4ca8
dibuja_por_tabla:		; Guarda la fase y saca de tabla_terreno_b el parametro con el que dibujar
	ld (0e0c5h),a		;4ca9   ; Guarda el flag de fase y lee el parametro de terreno (tabla_terreno_b) para dibujarlo
	ld (0e0c9h),a		;4cac
	ld h,000h		;4caf
	push hl			;4cb1
	ld de,04d49h		;4cb2   ; tabla_terreno_b, un byte por tipo de terreno
	add hl,de			;4cb5
	ld a,(hl)			;4cb6
	ld (0e074h),a		;4cb7
	ld hl,017a8h		;4cba   ; ocho celdas de VRAM 0x17A8
	ld c,008h		;4cbd
	call rellena_vram		;4cbf
	pop hl			;4cc2
	add hl,hl			;4cc3   ; Copia 2 bytes de tabla_terreno_a a VRAM
	ld de,04d2fh		;4cc4
	add hl,de			;4cc7
	ld de,01a93h		;4cc8   ; que van a VRAM 0x1A93
	ld bc,00002h		;4ccb
	call 0005ch		;4cce   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld a,001h		;4cd1
	jp guarda_el_estado_y_repinta		;4cd3
elige_el_lado:		; El acarreo decide por que lado entra
	push af			;4cd6
	ld a,001h		;4cd7   ; sin acarreo, un paso a la derecha
	jr nc,mira_los_bits_de_estado		;4cd9
	ld a,0ffh		;4cdb   ; y con el, uno a la izquierda
mira_los_bits_de_estado:		; Los bits 2 y 3 de (0xE0A7) reparten el camino
	ld hl,0e0a7h		;4cdd
	bit 3,(hl)		;4ce0   ; el bit 3 de (0xE0A7)
	jr z,mira_el_bit_dos		;4ce2
	neg		;4ce4   ; le da la vuelta al paso
	jr desplaza_la_camara		;4ce6
mira_el_bit_dos:		; El otro reparto
	bit 2,(hl)		;4ce8   ; y el bit 2 decide si se aplica
	jr z,guarda_el_viento_base		;4cea
desplaza_la_camara:		; Calcula el desplazamiento y elige parametro segun el terreno
	ld l,06fh		;4cec   ; Calcula un desplazamiento y elige parametro segun si el terreno es el especial
	add a,(hl)			;4cee   ; el viento actual mas el paso
	ld b,a			;4cef
	ld a,(0e073h)		;4cf0
	cp 00ch		;4cf3   ; con el terreno especial
	ld de,03060h		;4cf5   ; los limites son 0x30 y 0x60
	jr nz,recorta_contra_el_limite		;4cf8
	ld de,01020h		;4cfa   ; y con los demas, 0x10 y 0x20
recorta_contra_el_limite:		; Si la posicion normalizada no llega al limite, la guarda
	ld a,(0e070h)		;4cfd   ; Compara la posicion normalizada contra el limite E; si es menor, la guarda
	sub b			;4d00   ; la posicion menos el paso
	add a,d			;4d01
	cp e			;4d02
	jr nc,guarda_el_viento_base		;4d03
	ld (hl),b			;4d05   ; y si cabe, se guarda
guarda_el_viento_base:		; Deja el viento actual como base y convierte la posicion de camara
	ld a,(0e06fh)		;4d06   ; Guarda el viento actual como base y convierte la posicion de camara (0x601B)
	ld (0e075h),a		;4d09   ; el viento actual queda de base en (0xE075)
	ld hl,01800h		;4d0c
	call angulo_a_coordenadas		;4d0f   ; pasado a coordenadas
	ld hl,(0e0e6h)		;4d12   ; Calcula la diferencia con signo entre la coordenada de camara y B
	ld a,l			;4d15
	sub b			;4d16   ; menos la componente
	ld l,a			;4d17
	pop af			;4d18
	ld a,d			;4d19
	jr nc,calcula_la_fila		;4d1a
	neg		;4d1c   ; con el signo cambiado
calcula_la_fila:		; Saca la fila de VRAM; sin el bit 4 de (0xE0BA) usa el patron de relleno
	add a,h			;4d1e   ; Calcula una fila de VRAM; si (0xE0BA) bit 4 no esta activo, usa el patron 0xC2
	ld h,a			;4d1f   ; esa es la fila
	ld (0e0e2h),hl		;4d20
	ld a,(0e0bah)		;4d23
	and 010h		;4d26   ; el bit 4 de (0xE0BA)
	ret nz			;4d28
	ld a,0c2h		;4d29   ; y sin el, el patron de relleno
	ld (0e0e2h),a		;4d2b
	ret			;4d2e

; ----------------------------------------------------------------------
; DATOS tabla_terreno_a: 13 entradas de 2 bytes indexadas por (0xE073) desde
;   0x4CC4 (LDIRVM, 2 bytes por entrada)
;   0x4d2f..0x4d49  (26 bytes)
DATA_tabla_terreno_a:
	defb 0b1h,0d7h	; 4d2f
	defb 0b3h,0d7h	; 4d31
	defb 0b5h,0d7h	; 4d33
	defb 0b1h,0c9h	; 4d35
	defb 0b3h,0c9h	; 4d37
	defb 0b5h,0c9h	; 4d39
	defb 0b6h,0c9h	; 4d3b
	defb 0b7h,0c9h	; 4d3d
	defb 0b8h,0c9h	; 4d3f
	defb 0b9h,0c9h	; 4d41
	defb 0d0h,0d7h	; 4d43
	defb 0d3h,0d7h	; 4d45
	defb 0d0h,0d4h	; 4d47

; ----------------------------------------------------------------------
; DATOS tabla_terreno_b: 13 entradas de 1 byte indexadas por (0xE073) desde
;   0x4CB2
;   0x4d49..0x4d56  (13 bytes)
DATA_tabla_terreno_b:
	defb 018h,018h,03ch,018h,03ch,03ch,07eh,07eh,0ffh,0ffh,0ffh,0ffh,000h	; 4d49  ..<.<<~~.....

; ======================================================================
; CODIGO 0x4d56..0x4ecd  (375 bytes)
; ======================================================================


invierte_el_angulo:		; Con el bit 4 de (0xE0A8) puesto, el angulo de tiro cambia de signo
	ld a,(0e0a8h)		;4d56   ; Si (0xE0A8) bit 4 esta activo, invierte el angulo de tiro (0xE092)
	bit 4,a		;4d59   ; el bit 4 de (0xE0A8) es el disparo
	jr z,avanza_el_angulo		;4d5b
	ld hl,0e092h		;4d5d
	ld a,(hl)			;4d60
	add a,a			;4d61   ; el bit 7 del angulo
	jr nc,fija_el_angulo		;4d62
	cpl			;4d64   ; con el puesto, el angulo se complementa
fija_el_angulo:		; Guarda el angulo, pone los intentos a cero y salta al paso 0x10
	ld (hl),a			;4d65   ; Guarda el angulo, reinicia (0xE0BD) y fuerza el paso de animacion (0xE06C)=0x10
	xor a			;4d66
	ld (0e0bdh),a		;4d67   ; los intentos vuelven a cero
	ld a,002h		;4d6a
	call guarda_el_estado_y_repinta		;4d6c   ; y se repinta
	ld a,010h		;4d6f
	ld (0e06ch),a		;4d71   ; la fase 0x10 de la animacion
	ret			;4d74
avanza_el_angulo:		; Sube el angulo de cinco en cinco, dandole la vuelta al llegar al tope
	ld hl,0e092h		;4d75   ; Avanza el angulo (0xE092) en 5 unidades, invirtiendolo si se pasa de rango
	ld a,(hl)			;4d78
	add a,005h		;4d79   ; cinco unidades de angulo por paso
	ld (hl),a			;4d7b
	add a,a			;4d7c   ; el bit 7 del resultado
	jr nc,posicion_del_angulo		;4d7d
	cpl			;4d7f   ; con el puesto, el angulo va de vuelta: asi oscila
posicion_del_angulo:		; Saca de la tabla trigonometrica la posicion que le toca
	ld h,a			;4d80   ; Calcula la posicion trigonometrica aproximada del angulo (0x5F3B)
	ld l,01eh		;4d81   ; por 0x1E
	call multiplica		;4d83
	ld a,h			;4d86
	add a,003h		;4d87   ; mas tres
	ld b,004h		;4d89   ; cuatro bytes de barra
	ld hl,0e058h		;4d8b
prepara_la_trigonometrica:		; Ocho vueltas sobre el byte de la tabla
	push bc			;4d8e
	ld (hl),000h		;4d8f   ; el byte arranca a cero
	ld b,008h		;4d91   ; ocho bits por byte
rota_la_trigonometrica:		; Rota a la derecha tantas veces como diga A
	rrc (hl)		;4d93   ; rotando a la derecha
	dec a			;4d95
	jp m,cierra_la_trigonometrica		;4d96   ; hasta gastar la cuenta
	set 7,(hl)		;4d99   ; y el bit 7 puesto: asi se rellena la barra de potencia bit a bit
cierra_la_trigonometrica:		; Remata el bucle y devuelve el valor
	djnz rota_la_trigonometrica		;4d9b   ; Bucle interno de la tabla trigonometrica
	dec hl			;4d9d
	pop bc			;4d9e
	djnz prepara_la_trigonometrica		;4d9f
	ld b,004h		;4da1
	ld de,0e055h		;4da3   ; los cuatro bytes recien montados
	ld hl,01780h		;4da6   ; a VRAM 0x1780
rellena_ocho_filas:		; Ocho filas de VRAM con el valor que apunte DE
	push bc			;4da9   ; Rellena 8 filas de VRAM con el valor de (DE), avanzando la fila cada vez (FILVRM)
	ld a,(de)			;4daa
	ld bc,00008h		;4dab   ; ocho celdas por fila
	push bc			;4dae
	push hl			;4daf
	call 00056h		;4db0   ; BIOS FILVRM - Fills VRAM with value
	pop hl			;4db3
	pop bc			;4db4
	add hl,bc			;4db5   ; Avanza el destino a la siguiente fila y el origen al siguiente valor
	inc de			;4db6
	pop bc			;4db7
	djnz rellena_ocho_filas		;4db8
	ret			;4dba
mira_el_angulo_alto:		; Con terreno normal, angulo alto y ocho intentos, pide redibujar
	ld a,(0e073h)		;4dbb   ; Si el terreno no es el especial, el angulo es alto y los intentos llegan a 8, redibuja (a=3)
	cp 00ch		;4dbe   ; con el terreno especial, otro camino
	jr nc,espera_ocho_intentos		;4dc0
	ld a,(0e092h)		;4dc2
	cp 040h		;4dc5   ; por debajo de 0x40 de angulo
	jr c,pasa_al_paso_ocho		;4dc7
	ld a,(0e0bdh)		;4dc9
	cp 008h		;4dcc   ; Si los intentos no llegan a 8 no hace nada mas
	ret c			;4dce
	ld a,003h		;4dcf   ; estado 3
	call guarda_el_estado_y_repinta		;4dd1
pasa_al_paso_ocho:		; Deja el paso de animacion en 8
	ld a,008h		;4dd4
	ld (0e06ch),a		;4dd6   ; la fase 8 de la animacion
	ret			;4dd9
espera_ocho_intentos:		; Sin llegar a ocho intentos no sigue
	ld a,(0e0bdh)		;4dda   ; Si los intentos (0xE0BD) no llegan a 8, no hace nada
	cp 008h		;4ddd   ; los ocho intentos
	ret c			;4ddf
	ld a,001h		;4de0   ; estado 1
	call guarda_el_estado_y_repinta		;4de2
	ld hl,(0e092h)		;4de5   ; Calcula el limite de camara escalando el angulo de tiro (0xE092)
	ld h,03ah		;4de8   ; el angulo por 0x3A
	call multiplica		;4dea
	ld a,h			;4ded
	add a,002h		;4dee   ; mas dos
	ld (0e0a6h),a		;4df0   ; ese es el limite de camara
	ld a,080h		;4df3
	ld (0e076h),a		;4df5   ; el bit 7 de (0xE076): arranca la animacion de camara
	xor a			;4df8
	ld (0e06ch),a		;4df9   ; y la del golpe se apaga
	ret			;4dfc
sube_el_angulo:		; Sin el bit 4 de (0xE0A8), el angulo sube cinco
	ld a,(0e0a8h)		;4dfd   ; Si (0xE0A8) bit 4 no esta activo, incrementa el angulo en 5 unidades
	and 010h		;4e00   ; el bit 4 de (0xE0A8)
	jr nz,calcula_la_trayectoria		;4e02
	ld l,071h		;4e04
	ld a,(hl)			;4e06
	add a,005h		;4e07   ; cinco unidades mas de potencia
	ld (hl),a			;4e09
	add a,a			;4e0a   ; el bit 7 del resultado
	jr nc,complemento_a_cien		;4e0b
	cpl			;4e0d   ; le da la vuelta: la barra tambien oscila
complemento_a_cien:		; Guarda cien menos el resultado en (0xE0DF)
	ld h,a			;4e0e   ; Calcula el complemento a 100 del resultado y lo guarda en (0xE0DF)
	ld l,019h		;4e0f   ; por 0x19
	call multiplica		;4e11
	ld a,064h		;4e14
	sub h			;4e16   ; y cien menos eso es lo que se ensena
	ld (0e0dfh),a		;4e17
	ret			;4e1a
calcula_la_trayectoria:		; Lee tabla_terreno_c del terreno y multiplica sus parametros por el angulo
	ld de,(0e073h)		;4e1b   ; Lee tabla_terreno_c del terreno actual (0xE073) y multiplica sus parametros por (0xE092) con 0x5F3B
	ld d,000h		;4e1f   ; el terreno cabe en un byte
	ld hl,04ecdh		;4e21
	add hl,de			;4e24   ; tres veces: cada entrada de tabla_terreno_c son tres bytes
	add hl,de			;4e25
	add hl,de			;4e26
	ld d,(hl)			;4e27   ; el primer parametro, la altura
	inc hl			;4e28
	ld b,(hl)			;4e29   ; el segundo
	inc hl			;4e2a
	ld c,(hl)			;4e2b   ; y el tercero
	ld a,(0e092h)		;4e2c   ; Multiplica el parametro de altura por (0xE092) para el segundo termino
	ld h,d			;4e2f   ; la altura por el angulo
	ld l,a			;4e30
	call multiplica		;4e31
	ld l,h			;4e34   ; se queda con la parte alta
	ld h,000h		;4e35
	ld de,003a0h		;4e37   ; mas 0x3A0
	add hl,de			;4e3a
	ld (0e01ch),hl		;4e3b   ; Guarda el resultado como limite/distancia en (0xE01C)
	ld h,b			;4e3e   ; el segundo parametro
	ld l,a			;4e3f
	call multiplica		;4e40   ; por el mismo angulo
	ld l,h			;4e43
	ld h,000h		;4e44
	ld b,000h		;4e46   ; Combina ambos terminos calculados
	add hl,bc			;4e48   ; mas el tercero: ese es el alcance
	push hl			;4e49
	ld hl,0e06dh		;4e4a
	bit 1,(hl)		;4e4d   ; el bit 1 de (0xE06D)
	jr z,aplica_el_viento		;4e4f
	pop hl			;4e51
	srl h		;4e52   ; parte el alcance por dos
	rr l		;4e54
	push hl			;4e56
	ld hl,(0e0bah)		;4e57   ; Compara la altura acumulada (0xE0BA) contra el limite del terreno; marca el bit 0 de (0xE06D) si se supera
	ld h,006h		;4e5a   ; el contador por seis
	call multiplica		;4e5c
	ld a,(0e073h)		;4e5f
	cp h			;4e62   ; comparado con el terreno
	ld hl,0e06dh		;4e63
	ld (hl),000h		;4e66   ; la bandera se limpia
	jr nc,aplica_el_viento		;4e68
	set 0,(hl)		;4e6a   ; y se levanta si el terreno se queda corto
aplica_el_viento:		; Corrige la trayectoria con el viento del cuadro
	pop hl			;4e6c   ; Calcula la trayectoria con el viento actual (0x601B)
	push hl			;4e6d
	ld a,(0e06fh)		;4e6e   ; el rumbo del viento
	call angulo_a_coordenadas		;4e71   ; pasado a componentes
	ld (0e010h),de		;4e74   ; la de columna
	ld (0e016h),bc		;4e78   ; y la de fila
	ld hl,(0e093h)		;4e7c
	ld h,010h		;4e7f   ; la potencia por 0x10
	call multiplica		;4e81   ; Escala la potencia del golpe segun el angulo (0x5F3B/0x600F)
	ld a,(0e094h)		;4e84
	call componentes_negadas		;4e87   ; con las componentes ya negadas
	ld e,b			;4e8a
	pop hl			;4e8b
	push de			;4e8c
	ld a,(0e071h)		;4e8d
	add a,a			;4e90   ; el bit 7 de la potencia
	jr nc,elige_el_signo		;4e91
	cpl			;4e93   ; con el puesto, se complementa
elige_el_signo:		; Reparte segun el bit alto
	ld b,0c0h		;4e94   ; media vuelta de brujula
	add a,a			;4e96
	jr nc,invierte_y_escala		;4e97
	ld b,040h		;4e99   ; o un cuarto
	cpl			;4e9b
invierte_y_escala:		; Cambia de signo y vuelve a multiplicar
	neg		;4e9c   ; Invierte y escala el valor con el viento actual (0x5F3B)
	ld h,a			;4e9e
	call multiplica		;4e9f   ; y se escala
	ld a,(0e06fh)		;4ea2
	add a,b			;4ea5   ; sumado al rumbo del viento
	call angulo_a_coordenadas		;4ea6   ; Convierte el resultado en coordenada de pantalla (0x601B)
	pop hl			;4ea9
	ld a,h			;4eaa
	add a,d			;4eab   ; la componente de columna del efecto
	ld d,a			;4eac
	ld a,(0e0a0h)		;4ead
	rlca			;4eb0   ; el bit 7 del terreno
	ld a,d			;4eb1
	jr nc,guarda_la_caida		;4eb2
	neg		;4eb4   ; le da la vuelta a la fila
guarda_la_caida:		; Deja la nueva posicion, reinicia los intentos y pasa al paso 4
	ld (0e012h),a		;4eb6   ; Guarda la nueva posicion, reinicia los intentos, redibuja (a=2) y fija el paso de animacion a 4
	ld a,b			;4eb9   ; y la componente de fila
	add a,l			;4eba
	ld (0e018h),a		;4ebb
	xor a			;4ebe
	ld (0e0bdh),a		;4ebf   ; los intentos vuelven a cero
	ld a,002h		;4ec2   ; estado 2
	call guarda_el_estado_y_repinta		;4ec4
	ld a,004h		;4ec7   ; Fija el paso de animacion a 4 tras el nuevo golpe
	ld (0e06ch),a		;4ec9
	ret			;4ecc

; ----------------------------------------------------------------------
; DATOS tabla_terreno_c: 12 entradas de 3 bytes indexadas por (0xE073) desde
;   0x4E1B
;   0x4ecd..0x4ef1  (36 bytes)
DATA_tabla_terreno_c:
	defb 050h,01dh,025h	; 4ecd
	defb 050h,019h,020h	; 4ed0
	defb 050h,019h,01eh	; 4ed3
	defb 030h,01ch,020h	; 4ed6
	defb 040h,01ah,01ch	; 4ed9
	defb 050h,018h,019h	; 4edc
	defb 068h,018h,014h	; 4edf
	defb 080h,015h,012h	; 4ee2
	defb 080h,014h,00dh	; 4ee5
	defb 088h,013h,009h	; 4ee8
	defb 090h,012h,006h	; 4eeb
	defb 090h,012h,006h	; 4eee

; ======================================================================
; CODIGO 0x4ef1..0x4fc9  (216 bytes)
; ======================================================================


reinicia_los_intentos:		; A los ocho intentos, los pone a cero y pide redibujar
	ld hl,0e0bdh		;4ef1   ; Si los intentos llegan a 8, los reinicia y redibuja (a=4)
	ld a,(hl)			;4ef4
	cp 008h		;4ef5   ; los ocho intentos
	ret c			;4ef7
	ld (hl),000h		;4ef8   ; que se reinician
	ld a,004h		;4efa   ; estado 4
	call guarda_el_estado_y_repinta		;4efc
	ld a,(0e06dh)		;4eff   ; Segun el bit de (0xE06D), ajusta (0xE007) al valor por defecto
	rrca			;4f02   ; el bit 0 de (0xE06D)
	jr c,pasa_al_paso_dos		;4f03
	ld a,080h		;4f05   ; el bit 7 de (0xE007)
	ld (0e007h),a		;4f07
pasa_al_paso_dos:		; Deja el paso de animacion en 2
	ld a,002h		;4f0a
	ld (0e06ch),a		;4f0c   ; y la fase 2
	ret			;4f0f
mira_el_contador_seis:		; A los ocho intentos, compara (0xE06E) contra seis
	ld hl,0e0bdh		;4f10   ; Si los intentos (0xE0BD) llegan a 8, los reinicia y compara (0xE06E) contra 6
	ld a,(hl)			;4f13
	cp 008h		;4f14   ; los ocho intentos otra vez
	ret c			;4f16
	ld (hl),000h		;4f17   ; reiniciados
	ld a,(0e06eh)		;4f19
	cp 006h		;4f1c   ; el estado seis es el tope
	jr nc,invierte_el_bit_bajo		;4f1e
	inc a			;4f20   ; y si no, uno mas
	jr guarda_el_estado_y_repinta		;4f21
invierte_el_bit_bajo:		; Complementa el bit 0 de (0xE06D): el interruptor que alterna entre los dos estados
	ld a,(0e06dh)		;4f23
	cpl			;4f26   ; el bit 0 complementado: el interruptor entre los dos estados
	and 001h		;4f27
	ld (0e06ch),a		;4f29
	ret			;4f2c
guarda_el_estado_y_repinta:		; Deja el nuevo estado en (0xE06E) y decide si redibuja el marcador o el texto
	ld (0e06eh),a		;4f2d   ; Guarda el nuevo estado (0xE06E) y decide si redibuja el marcador o el texto
	dec a			;4f30   ; el estado 1
	push af			;4f31
	call z,valores_a_cero		;4f32   ; pone los valores a cero
	call nz,valores_por_defecto		;4f35   ; y cualquier otro, a sus valores por defecto
	call esconde_al_golfista		;4f38   ; y rellena la columna del indicador
	ld a,(0e097h)		;4f3b
	cp 008h		;4f3e   ; Elige el bloque de datos de puntuacion segun (0xE097)
	ld bc,00808h		;4f40
	ld hl,0502fh		;4f43   ; el bloque de 0x502F
	ld de,05113h		;4f46
	jr c,copia_al_intermedio		;4f49
	ld bc,01c1dh		;4f4b   ; justo 8
	ld hl,04fffh		;4f4e   ; el bloque de 0x4FFF
	ld de,050bch		;4f51
	jr z,copia_al_intermedio		;4f54
	ld bc,02223h		;4f56   ; y por encima
	ld hl,04fc9h		;4f59   ; el bloque de 0x4FC9
	ld de,05053h		;4f5c
copia_al_intermedio:		; Cincuenta y cuatro bytes fijos al buffer de trabajo de 0xEE80
	push af			;4f5f   ; Copia siempre 54 bytes fijos al buffer de staging (0xEE80)
	push de			;4f60
	push bc			;4f61
	ld bc,00036h		;4f62   ; cincuenta y cuatro bytes fijos
	ld de,0ee80h		;4f65   ; al buffer de trabajo de 0xEE80
	ldir		;4f68
	pop bc			;4f6a
	ld a,(0e073h)		;4f6b
	cp 003h		;4f6e   ; por debajo del terreno 3, no se toca nada mas
	jr c,recupera_la_segunda		;4f70
	cp 00ch		;4f72   ; Si el terreno es el especial (0x0C), ajusta el parametro extra
	jr nz,guarda_el_contador		;4f74
	ld b,c			;4f76   ; cambia el parametro por el otro
guarda_el_contador:		; Deja B en 0xEE87
	ld a,b			;4f77
	ld (0ee87h),a		;4f78   ; que queda en 0xEE87
recupera_la_segunda:		; Trae la otra direccion y calcula su tabla
	ld de,0ee80h		;4f7b   ; Recupera la segunda direccion (DE original de 0x4F40) y calcula su tabla con 0x5F3B
	pop hl			;4f7e
	pop af			;4f7f
	ex (sp),hl			;4f80
	ld l,a			;4f81
	call multiplica		;4f82   ; el indice se escala
	add hl,de			;4f85   ; y se suma a la segunda direccion
	ld de,0e0eah		;4f86   ; el destino es la tira de atributos de 0xE0EA
	ld b,a			;4f89
posicion_relativa_a_la_camara:		; Recorre la lista de objetos restando la posicion de camara
	ld a,(hl)			;4f8a   ; Recorre la lista de objetos calculando su posicion relativa a la camara (dos restas)
	inc hl			;4f8b
	ex (sp),hl			;4f8c
	dec a			;4f8d   ; menos uno; negativo cierra la lista
	jp m,fin_de_la_lista		;4f8e
	push bc			;4f91
	push hl			;4f92
	ld c,a			;4f93
	ld b,000h		;4f94
	add hl,bc			;4f96   ; por tres: cada objeto son tres bytes
	add hl,bc			;4f97
	add hl,bc			;4f98
	ld a,(0e098h)		;4f99   ; Resta la posicion de camara X e Y para obtener la coordenada relativa
	sub (hl)			;4f9c   ; la columna del objeto menos la de la camara
	ld (de),a			;4f9d
	inc hl			;4f9e
	inc de			;4f9f
	ld a,(0e099h)		;4fa0   ; y la fila
	sub (hl)			;4fa3
	ld (de),a			;4fa4
	inc hl			;4fa5
	inc de			;4fa6
	inc de			;4fa7
	ld a,(hl)			;4fa8   ; Guarda el tipo de objeto ya ajustado
	push hl			;4fa9
	ld hl,0e000h		;4faa   ; Si esta en el estado especial y el tipo es 8, lo cambia a 7
	bit 6,(hl)		;4fad   ; con el turno en el jugador 2
	jr nz,guarda_y_avanza		;4faf
	cp 008h		;4fb1   ; el tipo 8
	jr nz,guarda_y_avanza		;4fb3
	ld a,007h		;4fb5   ; se dibuja como el 7
guarda_y_avanza:		; Deja el resultado y calcula donde va el siguiente
	pop hl			;4fb7   ; Guarda el resultado en el buffer y calcula la posicion de VRAM de la siguiente entrada (c*4+0x60)
	ld (de),a			;4fb8
	dec de			;4fb9
	ld a,c			;4fba
	add a,a			;4fbb   ; el indice por cuatro
	add a,a			;4fbc
	add a,060h		;4fbd   ; mas 0x60: ese es el patron del sprite
	ld (de),a			;4fbf
	inc de			;4fc0   ; Avanza el puntero de destino dos posiciones
	inc de			;4fc1
	pop hl			;4fc2
	pop bc			;4fc3
	ex (sp),hl			;4fc4
	djnz posicion_relativa_a_la_camara		;4fc5
fin_de_la_lista:		; Recupera el puntero y sale
	pop hl			;4fc7
	ret			;4fc8

; ----------------------------------------------------------------------
; DATOS listas_golfista_palos_9_y_mas: Las SEIS listas de piezas del swing,
;   nueve por fotograma. Cada byte es el numero de pieza; 0x4F8D lo decrementa
;   y un cero cierra la lista antes de tiempo
;   0x4fc9..0x4fff  (54 bytes)
DATA_listas_golfista_palos_9_y_mas:
	defb 001h,002h,003h,004h,005h,006h,007h,008h,000h,001h,002h,009h,00ah,00bh,006h,007h	; 4fc9  ................
	defb 00ch,000h,00dh,002h,011h,010h,00eh,012h,014h,013h,00fh,001h,002h,003h,004h,005h	; 4fd9  ................
	defb 015h,016h,008h,017h,001h,002h,018h,01bh,019h,015h,016h,01ah,017h,01eh,01fh,020h	; 4fe9  ............... 
	defb 021h,01dh,015h,016h,01ch,017h	; 4ff9

; ----------------------------------------------------------------------
; DATOS listas_golfista_palo_8: Las seis listas del swing del palo 8, ocho
;   piezas por fotograma
;   0x4fff..0x502f  (48 bytes)
DATA_listas_golfista_palo_8:
	defb 001h,002h,003h,004h,005h,006h,007h,008h	; 4fff  ........
	defb 009h,00ah,00bh,00ch,00dh,00eh,00fh,000h	; 5007  ........
	defb 010h,011h,012h,00eh,00fh,000h,000h,000h	; 500f  ........
	defb 001h,002h,003h,004h,005h,013h,014h,008h	; 5017  ........
	defb 001h,002h,015h,016h,017h,013h,014h,000h	; 501f  ........
	defb 018h,019h,01ah,01bh,013h,014h,000h,000h	; 5027  ........

; ----------------------------------------------------------------------
; DATOS listas_golfista_palos_1_a_7: Las seis listas del swing de los palos 1
;   a 7, seis piezas por fotograma
;   0x502f..0x5053  (36 bytes)
DATA_listas_golfista_palos_1_a_7:
	defb 001h,002h,003h,004h,005h,006h	; 502f
	defb 001h,008h,009h,004h,005h,007h	; 5035
	defb 00ah,00ch,00dh,00eh,00bh,000h	; 503b
	defb 001h,002h,003h,00fh,010h,006h	; 5041
	defb 012h,013h,00fh,010h,011h,000h	; 5047
	defb 014h,015h,00fh,010h,016h,000h	; 504d

; ----------------------------------------------------------------------
; DATOS datos_del_golfista: Las 35 piezas del golfista de palos 9 y mas, TRES
;   bytes cada una: cuanto se sube, cuanto se corre a la izquierda y el color.
;   0x4F9C y 0x4FA3 los RESTAN de la posicion del golfista; medido contra el
;   emulador, (0xE099)-primero y (0xE098)-segundo salen constantes -144 y 80-
;   en las ocho piezas del cuadro de reposo. El patron del sprite no esta
;   aqui: sale de la cuenta de 0x4FBA, indice*4+0x60
;   0x5053..0x50bc  (105 bytes)
DATA_datos_del_golfista:
	defb 031h,015h,001h	; 5053
	defb 02ch,010h,00ah	; 5056
	defb 028h,00dh,00fh	; 5059
	defb 021h,01dh,00fh	; 505c
	defb 018h,011h,00ah	; 505f
	defb 011h,01dh,008h	; 5062
	defb 001h,01bh,00fh	; 5065
	defb 00ch,007h,001h	; 5068
	defb 025h,00dh,00fh	; 506b
	defb 021h,01dh,00fh	; 506e
	defb 01ch,01ch,00ah	; 5071
	defb 016h,02bh,001h	; 5074
	defb 030h,015h,001h	; 5077
	defb 02ch,01ch,00ah	; 507a
	defb 02ch,019h,00fh	; 507d
	defb 01ch,01dh,00fh	; 5080
	defb 01ch,00dh,00fh	; 5083
	defb 010h,01dh,008h	; 5086
	defb 00ch,00dh,008h	; 5089
	defb 002h,01bh,00fh	; 508c
	defb 011h,01dh,008h	; 508f
	defb 005h,019h,00fh	; 5092
	defb 001h,018h,008h	; 5095
	defb 027h,00dh,00fh	; 5098
	defb 01dh,00dh,00ah	; 509b
	defb 015h,008h,001h	; 509e
	defb 021h,01dh,00fh	; 50a1
	defb 031h,021h,00fh	; 50a4
	defb 031h,01dh,00ah	; 50a7
	defb 02dh,014h,001h	; 50aa
	defb 021h,00dh,00ah	; 50ad
	defb 01dh,00dh,00fh	; 50b0
	defb 021h,01dh,00fh	; 50b3
	defb 00ch,007h,001h	; 50b6
	defb 00ch,007h,001h	; 50b9

; ----------------------------------------------------------------------
; DATOS datos_del_golfista_palo_8: Las 29 piezas del golfista del palo 8, tres
;   bytes cada una
;   0x50bc..0x5113  (87 bytes)
DATA_datos_del_golfista_palo_8:
	defb 027h,00ch,001h	; 50bc
	defb 027h,00ch,00fh	; 50bf
	defb 027h,00ch,00ah	; 50c2
	defb 017h,013h,00fh	; 50c5
	defb 017h,008h,00ah	; 50c8
	defb 010h,016h,008h	; 50cb
	defb 000h,015h,00fh	; 50ce
	defb 007h,003h,001h	; 50d1
	defb 028h,009h,001h	; 50d4
	defb 025h,010h,00ah	; 50d7
	defb 01bh,013h,00fh	; 50da
	defb 015h,012h,00ah	; 50dd
	defb 012h,01eh,001h	; 50e0
	defb 00bh,013h,008h	; 50e3
	defb 001h,015h,00fh	; 50e6
	defb 028h,00ch,001h	; 50e9
	defb 023h,011h,00ah	; 50ec
	defb 01bh,013h,00fh	; 50ef
	defb 00bh,015h,008h	; 50f2
	defb 003h,015h,00fh	; 50f5
	defb 01eh,00ch,00ah	; 50f8
	defb 018h,013h,00fh	; 50fb
	defb 013h,001h,001h	; 50fe
	defb 028h,014h,00ah	; 5101
	defb 025h,00ch,001h	; 5104
	defb 018h,002h,00ah	; 5107
	defb 01bh,013h,00fh	; 510a
	defb 007h,003h,001h	; 510d
	defb 007h,003h,001h	; 5110

; ----------------------------------------------------------------------
; DATOS datos_del_golfista_palos_1_a_7: Las 22 piezas del golfista de los
;   palos 1 a 7, tres bytes cada una
;   0x5113..0x5155  (66 bytes)
DATA_datos_del_golfista_palos_1_a_7:
	defb 020h,00eh,001h	; 5113
	defb 014h,00eh,00ah	; 5116
	defb 004h,00eh,001h	; 5119
	defb 007h,00eh,008h	; 511c
	defb 000h,00eh,00fh	; 511f
	defb 017h,00eh,00fh	; 5122
	defb 017h,00eh,00fh	; 5125
	defb 018h,00eh,00ah	; 5128
	defb 010h,01eh,001h	; 512b
	defb 019h,00eh,001h	; 512e
	defb 017h,00eh,00fh	; 5131
	defb 017h,00eh,00ah	; 5134
	defb 007h,00eh,008h	; 5137
	defb 007h,00eh,00fh	; 513a
	defb 007h,00eh,008h	; 513d
	defb 001h,00eh,00fh	; 5140
	defb 017h,00eh,00fh	; 5143
	defb 017h,00eh,001h	; 5146
	defb 017h,00eh,00ah	; 5149
	defb 01fh,00eh,001h	; 514c
	defb 017h,00eh,00fh	; 514f
	defb 017h,00eh,00ah	; 5152

; ======================================================================
; CODIGO 0x5155..0x5184  (47 bytes)
; ======================================================================


copia_y_espeja:		; Copia cuarenta bytes y detras los cincuenta y seis siguientes leidos hacia atras: la version espejada
	push de			;5155   ; Copia los primeros 40 bytes a 0xEF00 y lee los 56 siguientes hacia atras (version espejada)
	push af			;5156
	ld de,0ef00h		;5157   ; el destino en RAM
	ld hl,05184h		;515a
	ld bc,00028h		;515d   ; cuarenta bytes tal cual
	ldir		;5160
	ld hl,051a3h		;5162   ; y los cincuenta y seis siguientes se leen HACIA ATRAS
	ld de,0ef28h		;5165
	ld b,038h		;5168   ; cincuenta y seis
espeja_el_resto:		; Los siete que quedan, con el bit alto puesto y el origen retrocediendo
	ld a,(hl)			;516a   ; Espeja en alto los 7 bytes restantes, avanzando hacia atras en el origen
	ld (de),a			;516b   ; cada byte a su sitio
	dec hl			;516c   ; el origen retrocede
	inc de			;516d   ; y el destino avanza: por eso sale espejado
	djnz espeja_el_resto		;516e
	pop af			;5170
	add a,008h		;5171   ; Calcula la direccion del texto en 0xEF00 segun el byte leido
	and 0e0h		;5173   ; y solo los tres bits altos
	rrca			;5175   ; entre cuatro: ocho bytes por entrada
	rrca			;5176
	ld l,a			;5177
	ld h,000h		;5178
	ld de,0ef00h		;517a
	add hl,de			;517d   ; sobre el buffer de 0xEF00
	pop de			;517e
	ld b,008h		;517f   ; ocho celdas de texto
	jp copia_a_vram		;5181

; ----------------------------------------------------------------------
; DATOS datos_5184: 40 bytes copiados por LDIRZ a RAM 0xEF00 desde 0x515A;
;   leidos tambien al reves desde 0x51A3 (56 bytes) para una version espejada,
;   solapando con esta tabla y con codigo ya explicado
;   0x5184..0x51ac  (40 bytes)
DATA_datos_5184:
	defb 000h,000h,008h,00ch,0ffh,00ch,008h,000h	; 5184  ........
	defb 000h,0c0h,060h,030h,01ah,00eh,00eh,01eh	; 518c  ..`0....
	defb 010h,010h,010h,010h,010h,07ch,038h,010h	; 5194  .....|8.
	defb 000h,006h,00ch,018h,0b0h,0e0h,0e0h,0f0h	; 519c  ........
	defb 000h,000h,020h,060h,0ffh,060h,020h,000h	; 51a4  .. `.` .

; ======================================================================
; CODIGO 0x51ac..0x5a58  (2220 bytes)
; ======================================================================


mira_el_disparo:		; Los dos bits bajos de (0xE076) deciden si el golpe se reprocesa
	ld hl,0e076h		;51ac   ; Segun los bits 0/1 de (0xE076), decide si reprocesa el disparo o continua
	ld a,(hl)			;51af
	rlca			;51b0   ; el bit 7 de (0xE076): arranca el vuelo
	jr c,arranca_la_trayectoria		;51b1
	rlca			;51b3   ; y el bit 6: sigue el que ya esta en marcha
	jr c,compara_los_intentos		;51b4
	ret			;51b6
compara_los_intentos:		; Enfrenta (0xE0BE) con (0xE0A6)
	ld a,(0e0beh)		;51b7
	ld hl,0e0a6h		;51ba
	cp (hl)			;51bd   ; los intentos contra el tope de (0xE0A6)
	jr c,acumula_la_velocidad		;51be
limpia_el_disparo:		; Deja (0xE076) a cero
	xor a			;51c0
	ld (0e076h),a		;51c1   ; pasado el tope, el vuelo se acaba
	ret			;51c4
acumula_la_velocidad:		; Suma la velocidad en las cuatro posiciones de los dos jugadores
	ld ix,0e00eh		;51c5   ; Acumula la velocidad en las cuatro posiciones de los dos jugadores (0x58FF)
	call suma_a_la_estructura		;51c9   ; la primera posicion
	ld ix,0e014h		;51cc
	call suma_a_la_estructura		;51d0   ; la segunda
	ld ix,0e01eh		;51d3
	call suma_a_la_estructura		;51d7   ; la tercera
	ld ix,0e022h		;51da
	call suma_a_la_estructura		;51de   ; y la cuarta
	call camara_del_activo		;51e1   ; Calcula la camara (0x5831) y el nuevo puntero de datos de puntuacion (0xE112)
	ld hl,(0e01eh)		;51e4
	ld a,(0e023h)		;51e7
	ld l,a			;51ea
	ld (0e112h),hl		;51eb   ; el puntero de puntuacion nuevo
	call posicion_del_tile		;51ee   ; y si el tile de ahi es el de llegada, se acaba
	jr z,limpia_el_disparo		;51f1
	ret			;51f3
arranca_la_trayectoria:		; Registra el sonido y calcula el primer tramo del vuelo
	rrc (hl)		;51f4   ; Registra un bloque de sonido y calcula la trayectoria inicial (0x52EE, 0x601B)
	call para_el_canal		;51f6   ; calla el canal
	ld b,000h		;51f9
	ld de,0bbe2h		;51fb   ; 0xBBE2, el sonido del golpe
	call registra_un_bloque		;51fe
	call valores_por_defecto		;5201
	ld a,(0e06fh)		;5204   ; el rumbo del viento
	ld hl,00022h		;5207   ; con modulo 0x22
	call angulo_a_coordenadas		;520a   ; pasado a componentes
	ld (0e010h),de		;520d   ; Guarda la velocidad calculada como incremento de posicion (0xE010/0xE016)
	ld (0e016h),bc		;5211   ; y el de fila
	ld a,(0e0a6h)		;5215   ; la potencia del golpe dice cuantos pasos
	ld ix,(0e00eh)		;5218
	ld hl,(0e014h)		;521c
	ld de,(0e010h)		;521f
	ld bc,(0e016h)		;5223
acumula_el_avance:		; Aplica el incremento tantas veces como diga la potencia del golpe
	add ix,de		;5227   ; Acumula el incremento de posicion tantas veces como indique A (potencia del golpe)
	add hl,bc			;5229   ; y fila
	dec a			;522a   ; un paso menos
	jr nz,acumula_el_avance		;522b
	push hl			;522d
	pop de			;522e
	push ix		;522f
	pop hl			;5231
	ld l,d			;5232
	call monta_los_objetos		;5233   ; Monta la lista de objetos del hoyo en la posicion final y marca si cambio de jugador
	push hl			;5236
	ld hl,0e0b5h		;5237
	cp (hl)			;523a   ; si es otro jugador, se marca
	jr z,fija_el_limite_de_camara		;523b
	ld hl,0e000h		;523d
	set 0,(hl)		;5240   ; con el bit 0 de (0xE000)
fija_el_limite_de_camara:		; Deja el puntero de puntuacion como nuevo tope
	ld hl,(0e112h)		;5242   ; Guarda el puntero de datos de puntuacion como nuevo limite de camara (0xE022/0xE01E)
	ld d,l			;5245   ; el byte alto del puntero
	ld e,000h		;5246
	ld (0e022h),de		;5248   ; es el limite de camara en columna
	ld l,000h		;524c
	ld (0e01eh),hl		;524e   ; y en fila
	pop hl			;5251
	push hl			;5252
	ld h,l			;5253
	ld l,000h		;5254
	xor a			;5256
	sbc hl,de		;5257   ; Compara la posicion actual contra ese limite, invirtiendo el signo si hace falta
	jr nc,coordenada_de_camara_y		;5259
	inc a			;525b   ; con el signo cambiado si hace falta
	call niega_de		;525c
coordenada_de_camara_y:		; Saca la Y de la camara a partir de (0xE0A6)
	ld de,(0e0a6h)		;525f   ; Calcula la coordenada de camara Y a partir de (0xE0A6)
	ld d,000h		;5263
	call divide_diecisiete		;5265   ; entre diecisiete
	rrca			;5268
	call c,niega_de		;5269
	ld (0e024h),hl		;526c   ; y esa es la Y de la camara
	pop hl			;526f
	ld l,000h		;5270
	ld bc,(0e01eh)		;5272
	xor a			;5276
	ld (0e0beh),a		;5277   ; los intentos a cero
	sbc hl,bc		;527a   ; la distancia contra el limite
	jr nc,coordenada_de_pantalla		;527c   ; Compara la distancia horizontal contra el limite de camara
	inc a			;527e
	call niega_de		;527f
coordenada_de_pantalla:		; Y la posicion de pantalla que le corresponde
	ld de,(0e0a6h)		;5282   ; Calcula una posicion de pantalla a partir de (0xE0A6) y la guarda en (0xE020)
	ld d,000h		;5286
	call divide_diecisiete		;5288   ; entre diecisiete otra vez
	rrca			;528b
	call c,niega_de		;528c
	ld (0e020h),hl		;528f   ; y esa es la posicion en pantalla
	ret			;5292
descomprime_a_la_ram:		; Descomprime en 0xE800 el bloque que traiga HL
	ld de,0e800h		;5293   ; el bloque se descomprime en 0xE800
	push de			;5296
	call descomprime		;5297
	pop hl			;529a
	ld de,03b00h		;529b   ; 0x460 bytes a VRAM 0x3B00
	ld bc,00460h		;529e
	jp 0005ch		;52a1   ; BIOS LDIRVM - Block transfers to VRAM from memory
despacha_las_fases:		; Rota (0xE077) y llama a la fase que toque: terreno, trayectoria, viento o reinicio
	ld hl,0e077h		;52a4   ; Dispatcher por bits de (0xE077): cada bit activo llama a otra fase (terreno, trayectoria, viento, reinicio)
	ld a,(hl)			;52a7   ; (0xE077) es la lista de fases de la vista
	rlca			;52a8   ; bit 7: monta el terreno
	jr c,monta_el_terreno		;52a9
	rlca			;52ab   ; bit 6: cuadro par
	jp c,mira_el_cuadro_par		;52ac
	rlca			;52af   ; bit 5: el signo del angulo
	jp c,mira_el_signo_del_angulo		;52b0
	rlca			;52b3   ; bit 4: reinicia los intentos
	jr c,reinicia_los_intentos_de_fase		;52b4
	rlca			;52b6   ; bit 3: espera a los ocho
	jr c,espera_los_ocho		;52b7
	rlca			;52b9   ; bit 2: los dos vectores
	jp c,dos_vectores		;52ba
	rlca			;52bd   ; Si ningun bit de (0xE077) esta activo, no hace nada mas
	ret nc			;52be
	ld a,(0e0bfh)		;52bf   ; Si ningun bit esta activo, comprueba los intentos y ajusta el color del indicador
	cp 080h		;52c2   ; por debajo de 0x80 intentos, nada
	ret c			;52c4
	ld (hl),000h		;52c5   ; y si no, se limpia la lista
	ld a,0c2h		;52c7   ; y se repone el color del indicador
	ld (0e10eh),a		;52c9
	ret			;52cc
reinicia_los_intentos_de_fase:		; A los ocho, los pone a cero y marca la fase
	ld hl,0e0bfh		;52cd   ; Si los intentos (0xE0BF) llegan a 8, los reinicia y marca (0xE077)
	ld a,(hl)			;52d0
	cp 008h		;52d1   ; los ocho intentos
	ret c			;52d3
	ld (hl),000h		;52d4
	ld a,002h		;52d6   ; estado 2
	call guarda_el_estado_y_repinta		;52d8
	ld a,008h		;52db
	ld (0e077h),a		;52dd   ; y la fase 3
	ret			;52e0
espera_los_ocho:		; Por debajo de ocho intentos no hace nada
	ld a,(0e0bfh)		;52e1   ; Si el numero de intentos (0xE0BF) es menor que 8, no hace nada; si no, redibuja algo (0x4F2D)
	cp 008h		;52e4   ; sin ocho intentos, nada
	ret c			;52e6
	rrc (hl)		;52e7
	ld a,001h		;52e9   ; estado 1
	call guarda_el_estado_y_repinta		;52eb
valores_por_defecto:		; Entra con la pareja 0x01,0x0F
	ld bc,0010fh		;52ee   ; la pareja por defecto: 1 y 15
guarda_la_pareja:		; Deja los dos bytes en 0xE11D y 0xE11E
	ld a,b			;52f1
	ld (0e11dh),a		;52f2   ; el primero, en (0xE11D)
	ld a,c			;52f5
	ld (0e115h),a		;52f6   ; y el segundo, en (0xE115)
	ret			;52f9
valores_a_cero:		; La misma entrada con la pareja a cero
	ld bc,00000h		;52fa   ; y la variante que los deja a cero
	jr guarda_la_pareja		;52fd
monta_el_terreno:		; Limpia el buffer, dibuja el terreno del hoyo y rellena el color de la franja de arriba
	rrc (hl)		;52ff   ; Monta el terreno del hoyo (0x456B/0x5D84) y rellena de color la franja superior
	call limpia_el_terreno		;5301   ; limpia el buffer del terreno
	call monta_el_plano_del_hoyo		;5304   ; dibuja el plano del hoyo
	ld hl,01780h		;5307
	ld c,020h		;530a   ; treinta y dos celdas
	xor a			;530c
	call rellena_vram		;530d   ; de la franja de arriba
	ld hl,0e000h		;5310   ; Segun los bits de (0xE000), decide el siguiente estado del turno
	ld a,(hl)			;5313
	rlca			;5314   ; con el bit 7 puesto, un solo jugador
	jr c,monta_el_hoyo		;5315
	and 018h		;5317   ; los bits 3 y 4
	jr z,junta_las_posiciones		;5319
	set 6,(hl)		;531b   ; turno del jugador 1
	and 008h		;531d   ; y el bit 3 lo deja asi
	jr nz,monta_el_hoyo		;531f
	res 6,(hl)		;5321   ; si no, pasa al 2
	jr monta_el_hoyo		;5323
junta_las_posiciones:		; La otra variante de la comparacion de distancias
	ld bc,(0e03ch)		;5325   ; Combina las posiciones de los dos jugadores (variante) para 0x4740
	ld a,(0e040h)		;5329   ; la otra pareja de posiciones
	ld c,a			;532c
	ld de,(0e04bh)		;532d
	ld a,(0e04fh)		;5331
	ld e,a			;5334
	ld hl,(0e0a3h)		;5335
	call quien_esta_mas_lejos		;5338   ; y quien este mas lejos juega
monta_el_hoyo:		; Escribe numero de hoyo y par, sortea el viento con el registro R y coloca la bola en su salida
	call elige_las_dos_tablas		;533b   ; Monta un nuevo hoyo: numero de hoyo y par en pantalla, y la posicion inicial de la bola
	ld a,(0e096h)		;533e   ; el numero de hoyo
	ld de,017c0h		;5341   ; a VRAM 0x17C0
	call copia_y_espeja		;5344
	ld a,0f8h		;5347   ; 0xF8 es la letra del recorrido
	ld hl,01a19h		;5349
	call 0004dh		;534c   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,(0e095h)		;534f
	ld h,005h		;5352
	call multiplica		;5354   ; el par por cinco
	ld a,h			;5357
	add a,0b0h		;5358   ; mas 0xB0, que es el cero
	ld hl,01a1ah		;535a   ; en VRAM 0x1A1A
	call 0004dh		;535d   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,(0e079h)		;5360
	ld (0e08eh),hl		;5363   ; la fila de salida de la bola
	ld hl,(0e082h)		;5366
	ld (0e090h),hl		;5369   ; y su columna
	ld de,(0e0a3h)		;536c   ; Copia la posicion de salida de la bola a las variables de trabajo (0xE08E/0xE090)
	ld hl,(0e079h)		;5370
	ld a,(0e083h)		;5373
	ld l,a			;5376
	call rumbo_y_distancia		;5377   ; el rumbo y la distancia hasta la bandera
	ld (0e070h),a		;537a   ; que queda de viento base
	ld b,a			;537d
	ld a,r		;537e   ; Nueva racha de viento: usa el registro R de refresco como fuente pseudoaleatoria
	and 00fh		;5380   ; sus cuatro bits bajos
	sub 007h		;5382   ; menos siete: una racha de -7 a +8
	add a,b			;5384
	ld (0e06fh),a		;5385   ; sumada al viento base
	call posicion_de_camara		;5388   ; Prepara el terreno/vista del nuevo hoyo (0x5578)
	ld hl,00f24h		;538b
	ld (0e0e4h),hl		;538e   ; y los limites de camara
	ld hl,05088h		;5391   ; Fija el puntero de datos de puntuacion (0xE112) a 0x5088 y el sprite del golfista inicial
	ld (0e112h),hl		;5394   ; el puntero de puntuacion arranca en 0x5088
	ld h,056h		;5397
	ld (0e098h),hl		;5399
	ld a,00ch		;539c
	ld (0e114h),a		;539e   ; el rango de dificultad
	ld a,009h		;53a1
	ld (0e097h),a		;53a3   ; y el sprite del golfista de salida
	ld hl,0b4aeh		;53a6   ; Dibuja el sprite fijo de salida (plano_hoyo_15) con 0x5293
	call descomprime_a_la_ram		;53a9   ; que se descomprime a la RAM
	ld a,001h		;53ac
	call guarda_el_estado_y_repinta		;53ae   ; estado 1
	ld hl,(0e095h)		;53b1   ; Calcula la posicion de camara/vista a partir de la posicion de la bola (0x5F3B, 0x600F)
	ld a,h			;53b4
	ld h,050h		;53b5   ; por 0x50
	call multiplica		;53b7
	ld l,h			;53ba
	srl l		;53bb   ; entre dos
	ld h,000h		;53bd
	call componentes_negadas		;53bf   ; pasado a componentes negadas
	ld (0e07eh),de		;53c2   ; la de columna
	ld (0e087h),bc		;53c6   ; y la de fila
	ld hl,0e07fh		;53ca
	call normaliza_el_signo_del_par		;53cd   ; el signo de la primera
	ld hl,0e088h		;53d0
	call normaliza_el_signo_del_par		;53d3   ; y el de la segunda
	ld hl,0e07eh		;53d6
	call cuatro_rotaciones		;53d9   ; cuatro rotaciones a cada vector
	ld hl,0e087h		;53dc
cuatro_rotaciones:		; Cuatro pasadas de la rotacion de tres bytes
	ld a,004h		;53df   ; cuatro pasadas
rota_tres_bytes:		; Cada una de esas pasadas
	push hl			;53e1   ; Repite la rotacion de 3 bytes (0x5480) tantas veces como indique A
	call rota_el_vector		;53e2   ; cada una rota los tres bytes
	pop hl			;53e5
	dec a			;53e6
	jr nz,rota_tres_bytes		;53e7
	ret			;53e9
normaliza_el_signo_del_par:		; Deja el byte de al lado a cero o a uno segun el bit 7
	xor a			;53ea
	bit 7,(hl)		;53eb   ; el bit 7 del byte
	jr z,guarda_el_signo		;53ed
	dec a			;53ef   ; y con el puesto, 0xFF de extension de signo
guarda_el_signo:		; Escribe ese cero o uno
	inc hl			;53f0   ; el byte de al lado
	ld (hl),a			;53f1
	ret			;53f2
mira_el_cuadro_par:		; En los cuadros impares no toca nada
	ld a,(0e072h)		;53f3   ; Si (0xE072) es par, no hace nada
	rrca			;53f6   ; el bit 0 del contador de cuadros
	ret c			;53f7   ; en los impares no se toca nada
	call reinicia_si_toca		;53f8
	ld bc,(0e0a3h)		;53fb   ; los parametros del hoyo
	ld d,c			;53ff
	ld c,000h		;5400
	ld e,000h		;5402
	call distancia_a_la_salida		;5404   ; Calcula la diferencia de posicion (0x55A8) y guarda dos limites de camara (0xE10E/0xE110)
	dec h			;5407   ; dos filas menos
	dec h			;5408
	ld (0e10eh),hl		;5409   ; ese es el primer limite
	ld a,l			;540c
	call recorta_a_cincuenta		;540d   ; recortado a cincuenta
	ld h,001h		;5410
	ld (0e110h),hl		;5412   ; y ese el segundo
	ret			;5415
recorta_a_cincuenta:		; Por encima de 0x50 se queda en el tope
	ld l,018h		;5416   ; el tope bajo, 0x18
	cp 050h		;5418   ; por encima de 0x50
	ret c			;541a
	ld l,01ch		;541b   ; el tope alto, 0x1C
	ret			;541d
mira_el_signo_del_angulo:		; El bit 4 de (0xE0A8) reparte el camino
	ld a,(0e0a8h)		;541e
	bit 4,a		;5421   ; el bit 4 de (0xE0A8) es el disparo
	jr nz,sonido_segun_el_angulo		;5423
	call avanza_el_angulo		;5425   ; sin el, el angulo sigue oscilando
	call posicion_de_camara		;5428   ; y la camara se recoloca
limites_por_defecto:		; Fija los limites de pantalla y ajusta el color del borde si toca
	ld hl,00f00h		;542b   ; Fija los limites de pantalla por defecto; si (0xE0BA) bit 4 esta activo, ajusta el color de borde
	ld (0e0e8h),hl		;542e   ; los limites de pantalla
	ld (0e118h),hl		;5431
	ld a,(0e0bah)		;5434
	and 010h		;5437   ; el bit 4 de (0xE0BA)
	ret z			;5439
	ld a,0c2h		;543a
	ld (0e0e6h),a		;543c   ; y con el, se repone el color del borde
	ret			;543f
sonido_segun_el_angulo:		; Registra el bloque que corresponde al signo del angulo
	rrc (hl)		;5440   ; Registra otro bloque de sonido segun el signo del angulo de tiro actual
	call para_el_canal		;5442   ; calla el canal
	ld b,000h		;5445
	ld de,0bbe2h		;5447   ; 0xBBE2, el sonido del golpe
	call registra_un_bloque		;544a
	ld a,(0e092h)		;544d
	add a,a			;5450   ; el bit 7 del angulo
	jr nc,camara_con_viento		;5451
	cpl			;5453   ; con el puesto, se complementa
camara_con_viento:		; Recalcula la posicion de camara con el viento del cuadro
	srl a		;5454   ; Calcula la posicion de camara con el viento actual (0x601B)
	ld h,a			;5456
	ld l,000h		;5457
	ld a,(0e06fh)		;5459   ; con el rumbo del viento
	call angulo_a_coordenadas		;545c
	ld (0e07bh),de		;545f   ; la componente de columna
	ld (0e084h),bc		;5463   ; y la de fila
	ld hl,0e07ch		;5467
	call normaliza_el_signo_del_par		;546a   ; Normaliza las dos posiciones calculadas (0x53EA) y reinicia el contador de intentos
	ld hl,0e085h		;546d
	call normaliza_el_signo_del_par		;5470   ; y el de la segunda
	xor a			;5473
	ld (0e0bfh),a		;5474   ; los intentos, a cero
	ld hl,0e07bh		;5477
	call rota_el_vector		;547a   ; las dos se rotan una vez
	ld hl,0e084h		;547d
rota_el_vector:		; Tres bytes rotados a la izquierda: multiplicar por dos en 24 bits
	ld b,003h		;5480   ; tres bytes
	or a			;5482
rota_un_byte:		; Cada uno de esos tres desplazamientos
	rl (hl)		;5483   ; rotados a la izquierda: eso es multiplicar por dos en 24 bits
	inc hl			;5485
	djnz rota_un_byte		;5486
	ret			;5488
dos_vectores:		; Prepara los dos vectores de 0xE078
	ld b,002h		;5489   ; dos vectores
	ld hl,0e078h		;548b   ; desde 0xE078
seis_pasos:		; Seis vueltas por vector
	ld c,006h		;548e   ; seis bytes cada uno
	or a			;5490
suma_el_vector:		; Suma con acarreo el vector de tres bytes: posicion mas velocidad de la bola en vuelo
	ld a,(hl)			;5491   ; Suma con acarreo un vector de 3 bytes (posicion + velocidad de la bola en vuelo)
	push hl			;5492
	inc hl			;5493
	inc hl			;5494
	inc hl			;5495
	adc a,(hl)			;5496   ; mas el del vector de al lado, con acarreo
	pop hl			;5497
	ld (hl),a			;5498
	inc hl			;5499
	dec c			;549a
	jr nz,suma_el_vector		;549b
	inc hl			;549d   ; y el siguiente vector, tres bytes mas alla
	inc hl			;549e
	inc hl			;549f
	djnz seis_pasos		;54a0
	call posicion_de_camara		;54a2   ; Redibuja el terreno tras mover la bola
	ld a,(0e07dh)		;54a5   ; Calcula la nueva coordenada de pantalla de la bola (0x5559) y la guarda
	ld hl,(0e07bh)		;54a8
	call invierte_si_negativo		;54ab   ; el signo de la columna
	ld (0e07bh),hl		;54ae   ; y se guarda ya escalada
	ld a,(0e086h)		;54b1
	ld hl,(0e084h)		;54b4
	call invierte_si_negativo		;54b7   ; lo mismo con la fila
	ld (0e084h),hl		;54ba
	ld a,(0e07ch)		;54bd   ; Si la posicion entera cambio respecto al fotograma anterior, sigue redibujando la bola
	ld hl,0e08ch		;54c0
	cp (hl)			;54c3   ; la parte entera de la columna contra la del cuadro anterior
	ld (hl),a			;54c4
	jr nz,distancia_al_hoyo		;54c5   ; si ha cambiado, hay que redibujar
	ld a,(0e085h)		;54c7
	ld hl,0e08dh		;54ca
	cp (hl)			;54cd   ; y lo mismo con la fila
	ld (hl),a			;54ce
	jr z,marca_la_fase		;54cf
distancia_al_hoyo:		; Mide lo que falta hasta el hoyo y actualiza el limite de camara
	ld bc,(0e079h)		;54d1   ; Calcula la distancia hasta el hoyo (0x55A8) y guarda el nuevo limite de camara
	ld de,(0e082h)		;54d5
	call distancia_a_la_salida		;54d9   ; contra la del hoyo
	jr nc,marca_la_fase		;54dc   ; sin acarreo, la bola ya ha llegado
	ld (0e112h),hl		;54de   ; ese es el nuevo puntero de puntuacion
	ld a,l			;54e1
	call recorta_a_cincuenta		;54e2   ; Calcula el nuevo rango de dificultad a partir de la distancia
	ld a,l			;54e5
	sub 014h		;54e6   ; menos 0x14
	ld (0e114h),a		;54e8   ; y ese el rango de dificultad
	ld de,(0e0a3h)		;54eb
	ld hl,(0e079h)		;54ef   ; Comprueba la distancia horizontal restante hasta el hoyo
	ld a,(0e083h)		;54f2
	ld l,a			;54f5
	call distancia_sin_signo		;54f6   ; Si la bola cayo muy cerca (0-1), calcula el rebote con el viento actual (0x5FB2/0x601B)
	cp 018h		;54f9   ; a mas de 0x18 no ha llegado
	jr nc,marca_la_fase		;54fb
	or a			;54fd
	jr z,mira_el_borde		;54fe   ; a cero, se mira el borde
	dec a			;5500
	ret nz			;5501   ; y a mas de uno, nada
	call rumbo_y_distancia		;5502   ; el rumbo del viento
	ld hl,00400h		;5505   ; con modulo 0x400
	call angulo_a_coordenadas		;5508
	ld a,b			;550b
	ld hl,(0e085h)		;550c
	call suma_el_offset		;550f   ; sumada a la fila
	ld (0e085h),hl		;5512
	ld a,d			;5515
	ld hl,(0e07ch)		;5516
	call suma_el_offset		;5519   ; y a la columna: el rebote de la bola al caer cerca
	ld (0e07ch),hl		;551c
	ret			;551f
marca_la_fase:		; Deja 0x80 en la fase que toque
	call elige_la_estructura_del_turno		;5520
	ld a,080h		;5523   ; 0x80 en la fase
	jr guarda_la_fase		;5525
mira_el_borde:		; Si algun jugador se pasa del borde 0x4C, no hace nada
	ld a,(0e07ch)		;5527   ; Si la posicion de cualquier jugador supera el borde de pantalla (0x4C), no hace nada
	add a,026h		;552a   ; mas 0x26
	cp 04ch		;552c   ; y el borde esta en 0x4C
	ret nc			;552e
	ld a,(0e085h)		;552f
	add a,026h		;5532   ; lo mismo con el otro eje
	cp 04ch		;5534
	ret nc			;5536
	xor a			;5537
	ld (0e0bfh),a		;5538   ; los intentos a cero
	call valores_a_cero		;553b   ; Si no, reinicia los intentos y redibuja (marcador y terreno)
	call sonido_del_canal_dos		;553e   ; y el sonido del canal 2
	ld a,0c2h		;5541   ; el color del indicador
	ld (0e0e6h),a		;5543
	ld a,002h		;5546   ; la fase 2
guarda_la_fase:		; Escribe el valor en (0xE077)
	ld (0e077h),a		;5548
elige_el_contador:		; Puntero a (0xE09A) o (0xE09C) segun el bit 6 de (0xE000)
	ld a,(0e000h)		;554b   ; Elige el puntero (0xE09A) o (0xE09C) segun el bit 6 de (0xE000)
	bit 6,a		;554e   ; el bit 6 dice de quien es el contador
	ld hl,0e09ah		;5550
	jr nz,sube_el_contador		;5553
	inc hl			;5555   ; dos bytes mas alla, el del jugador 2
	inc hl			;5556
sube_el_contador:		; Y lo incrementa
	inc (hl)			;5557   ; uno mas
	ret			;5558
invierte_si_negativo:		; Con el signo puesto, cambia el valor antes de escalarlo
	rlca			;5559   ; Segun el signo, invierte el valor (0x6056) antes de escalarlo (0x5915)
	ld a,0f6h		;555a   ; 0xF6 es la marca que se recupera despues
	push af			;555c
	call c,niega_de		;555d   ; con el signo puesto, se niega antes
	call escala_los_dos_bytes		;5560   ; y se escala
	pop af			;5563
	ret nc			;5564
	ld a,h			;5565   ; Si el resultado escalado es cero, lo deja en -1
	or l			;5566   ; si el resultado da cero
	jp nz,niega_de		;5567
	dec hl			;556a   ; se deja en -1: asi nunca se queda parada
	ret			;556b
suma_el_offset:		; Suma A al puntero, en 16 bits
	push bc			;556c
	ld b,000h		;556d
	bit 7,a		;556f   ; el bit 7 de A: el signo
	jr z,suma_y_devuelve		;5571
	dec b			;5573   ; que se extiende a B
suma_y_devuelve:		; Remate de esa suma
	ld c,a			;5574
	add hl,bc			;5575   ; y se suma en dieciseis bits
	pop bc			;5576
	ret			;5577
posicion_de_camara:		; Coordenada Y de la camara, del jugador que toque segun el bit 6 de (0xE000)
	ld hl,(0e083h)		;5578   ; Calcula la coordenada de camara Y eligiendo entre las posiciones del jugador 1 o 2 (bit 6 de 0xE000)
	ld a,(0e07ah)		;557b   ; la coordenada vertical
	call a_fila_y_columna		;557e   ; pasada a fila y columna
	ld (0e0e6h),hl		;5581
	ld a,(0e000h)		;5584
	bit 6,a		;5587   ; el bit 6 elige el jugador
	ld hl,(0e04fh)		;5589   ; la horizontal del jugador 2
	ld a,(0e04ch)		;558c   ; Lee la coordenada horizontal correspondiente al jugador elegido
	jr nz,guarda_la_horizontal		;558f
	ld hl,(0e040h)		;5591   ; o la del 1
	ld a,(0e03dh)		;5594
guarda_la_horizontal:		; Deja la coordenada horizontal en (0xE116)
	call a_fila_y_columna		;5597   ; tambien pasada a fila y columna
	ld (0e116h),hl		;559a
	ret			;559d
a_fila_y_columna:		; Convierte una coordenada de pantalla en fila y columna de caracter
	add a,0b0h		;559e   ; Convierte una coordenada de pantalla en fila/columna de caracter (limites 0xB0/0x50)
	ld h,a			;55a0
	ld a,l			;55a1
	sub 050h		;55a2   ; y 0x50 menos la columna
	neg		;55a4   ; con el signo cambiado
	ld l,a			;55a6
	ret			;55a7
distancia_a_la_salida:		; Posicion relativa al tee, con el signo invertido si hace falta
	ld hl,(0e08eh)		;55a8   ; Calcula la posicion relativa al punto de salida, invirtiendo el signo si es negativa
	or a			;55ab
	sbc hl,bc		;55ac   ; la posicion menos el punto de salida
	push af			;55ae
	call c,niega_de		;55af   ; en positivo
	add hl,hl			;55b2   ; Multiplica por 4 (add hl,hl x2) y descarta el byte bajo
	add hl,hl			;55b3
	ld l,000h		;55b4   ; y se tira el byte bajo
	pop af			;55b6
	jr c,distancia_a_la_llegada		;55b7
	ld a,h			;55b9   ; y si era negativa, los dos bytes se cambian
	ld h,l			;55ba
	ld l,a			;55bb
distancia_a_la_llegada:		; Lo mismo respecto al green
	push hl			;55bc   ; Calcula la posicion relativa al punto de llegada, invirtiendo el signo si es negativa
	ld hl,(0e090h)		;55bd
	or a			;55c0
	sbc hl,de		;55c1   ; lo mismo contra el punto de llegada
	push af			;55c3
	call c,niega_de		;55c4
	add hl,hl			;55c7   ; Multiplica por 4 y descarta el byte bajo
	add hl,hl			;55c8
	ld l,000h		;55c9
	pop af			;55cb
	jr c,modulo_de_la_distancia		;55cc
	ld a,h			;55ce
	ld h,l			;55cf
	ld l,a			;55d0
modulo_de_la_distancia:		; El valor absoluto de las dos; por encima de 0x90 no hace nada
	pop bc			;55d1   ; Calcula el valor absoluto de la distancia (0x5F8F); si supera 0x90 no hace nada
	ld e,h			;55d2
	ld d,b			;55d3
	ld h,c			;55d4
	call distancia_sin_signo		;55d5   ; el modulo de las dos: la distancia de verdad
	cp 090h		;55d8   ; por encima de 0x90 no se dibuja
	ret nc			;55da
	push af			;55db
	call rumbo_y_distancia		;55dc   ; Calcula la posicion de VRAM del sprite con el signo de la distancia (0x5FB2)
	ld b,a			;55df
	pop af			;55e0
	add a,060h		;55e1   ; mas 0x60: ahi empiezan los patrones de sprite
	ld e,a			;55e3
	ld d,000h		;55e4
	ld hl,01e00h		;55e6
	call divide_diecisiete		;55e9   ; Convierte la posicion en fila/columna de pantalla (0x5F4C)
	ld a,050h		;55ec
	sub l			;55ee   ; 0x50 menos la columna
	ld c,a			;55ef
	ld a,088h		;55f0
	sub c			;55f2   ; y 0x88 menos eso
	ld l,a			;55f3
	push hl			;55f4
	ld a,(0e06fh)		;55f5
	sub b			;55f8   ; menos el rumbo del viento
	push af			;55f9
	jp p,escala_la_distancia		;55fa
	neg		;55fd   ; en positivo
escala_la_distancia:		; Por debajo de 0x40 la multiplica por ocho, guardando el signo
	cp 040h		;55ff   ; Si A es menor que 0x40, lo multiplica por 8 (0x5F3B) preservando el signo
	jr nc,distancia_cero		;5601
	ld h,c			;5603
	ld l,a			;5604
	call multiplica		;5605   ; por el factor
	add hl,hl			;5608   ; y por ocho
	add hl,hl			;5609
	add hl,hl			;560a
	pop af			;560b
	ld a,h			;560c
	jp p,centra_en_pantalla		;560d   ; Satura el resultado a positivo si se paso de rango
	neg		;5610   ; y si no, se le da la vuelta antes
centra_en_pantalla:		; Suma 0x50, que es el centro
	add a,050h		;5612   ; 0x50 es el centro de la pantalla
	pop hl			;5614
	ld h,a			;5615
	scf			;5616   ; sale con acarreo: hay algo que dibujar
	ret			;5617
distancia_cero:		; El caso en el que no hay nada que escalar
	pop hl			;5618
	xor a			;5619   ; el caso a cero
	jr centra_en_pantalla		;561a
elige_el_indicador:		; Los bits de (0xE007) eligen el patron del indicador de (0xE11A)
	ld a,(0e007h)		;561c   ; Segun los bits de (0xE007), elige el patron del indicador (0xE11A)
	rlca			;561f   ; el bit 7 de (0xE007): la bola vuela
	jr c,prepara_el_vuelo		;5620
	rlca			;5622   ; y el bit 6: la camara la sigue
	jp c,cuenta_los_pasos		;5623
	ld a,0c2h		;5626   ; sin ninguno, el patron de relleno
	ld (0e11ah),a		;5628
	ret			;562b
prepara_el_vuelo:		; Registra sonido, limpia distancias e indicadores y copia los dieciseis bytes de posicion inicial
	ld b,000h		;562c   ; Registra sonido, limpia distancias y flags, y copia el bloque de posicion inicial (16 bytes)
	ld de,0bcf9h		;562e   ; 0xBCF9, el sonido del vuelo
	call registra_un_bloque		;5631
	ld hl,00000h		;5634
	ld (0e01ah),hl		;5637   ; la distancia recorrida, a cero
	xor a			;563a
	ld (0e013h),a		;563b   ; y los tres acumuladores de altura tambien
	ld (0e019h),a		;563e
	ld (0e008h),a		;5641
	ld hl,0e00eh		;5644   ; los dieciseis bytes de posicion
	ld de,0e055h		;5647   ; se copian a 0xE055, que es la copia de seguridad
	ld bc,00010h		;564a
	ldir		;564d
	xor a			;564f
	ld (0e0adh),a		;5650   ; Reinicia el contador de hoyos jugados
	ld hl,00000h		;5653
vuela_la_bola:		; Acumula velocidad y posicion hasta que la bola toca el suelo
	call acumula_los_dos_ejes		;5656   ; Acumula velocidad y posicion (0x587B) hasta que la bola aterriza
	inc hl			;5659   ; uno mas en la cuenta
	jr nc,vuela_la_bola		;565a   ; y hasta que no toque el suelo, otra vuelta
	ld (0e00ah),hl		;565c   ; los cuadros que ha durado el vuelo
	ld a,(0e00fh)		;565f   ; Calcula la posicion final de aterrizaje y monta la lista de objetos del hoyo alli
	ld h,a			;5662   ; la columna donde ha caido
	ld a,(0e015h)		;5663
	ld l,a			;5666   ; y su fila
	call monta_los_objetos		;5667   ; mira que hay en esa casilla
	ld (0e0b5h),a		;566a   ; el objeto que sea
	ld (0e00ch),hl		;566d   ; y la posicion final
	ld d,h			;5670
	ld e,000h		;5671
	ld hl,(0e112h)		;5673   ; Fija los limites de camara segun el puntero de datos de puntuacion (0xE112)
	ld b,l			;5676
	ld c,000h		;5677
	ld (0e022h),bc		;5679   ; el limite de camara en columna
	ld l,000h		;567d
	ld (0e01eh),hl		;567f   ; y en fila
	ex de,hl			;5682
	xor a			;5683
	sbc hl,de		;5684   ; la posicion menos el limite
	jr nc,posicion_tras_el_bote		;5686
	inc a			;5688
	call niega_de		;5689   ; en positivo
posicion_tras_el_bote:		; Recalcula la coordenada tras el aterrizaje
	ld de,(0e00ah)		;568c
	call divide_diecisiete		;5690   ; entre diecisiete
	or a			;5693
	jr z,guarda_la_camara		;5694
	call niega_de		;5696   ; y con el signo que tocaba
guarda_la_camara:		; Deja la posicion de camara y vuelve a copiar el bloque de posicion
	ld (0e020h),hl		;5699   ; Guarda la posicion de camara (0xE020) y copia el bloque de posicion inicial (16 bytes)
	ld de,0e00eh		;569c
	ld hl,0e055h		;569f   ; la copia de seguridad vuelve a su sitio
	ld bc,00010h		;56a2
	ldir		;56a5
	ld hl,00f00h		;56a7   ; Fija los limites por defecto y reinicia los contadores para el nuevo hoyo
	ld (0e0e8h),hl		;56aa   ; los limites por defecto
	ld l,00ch		;56ad
	ld (0e114h),hl		;56af   ; el rango de dificultad
	ld h,001h		;56b2
	ld (0e11ch),hl		;56b4
	ld hl,0eb8fh		;56b7   ; Fija la posicion inicial del indicador de terreno (0xEB8F)
	ld (0e0aeh),hl		;56ba   ; y el indicador de terreno arranca en 0xEB8F
	xor a			;56bd
	ld (0e0adh),a		;56be   ; los contadores del vuelo, a cero
	ld (0e013h),a		;56c1
	ld (0e019h),a		;56c4
	ld (0e008h),a		;56c7
	ld (0e072h),a		;56ca   ; el contador de cuadros tambien
	ld hl,00000h		;56cd
	ld (0e06ah),hl		;56d0   ; y los tres pares de camara
	ld (0e024h),hl		;56d3
	ld (0e026h),hl		;56d6
	ld (0e028h),hl		;56d9
	ld a,040h		;56dc   ; el bit 6 de (0xE007): ahora la camara persigue a la bola
	ld (0e007h),a		;56de
	ret			;56e1
cuenta_los_pasos:		; A los diecisiete pasos sube (0xE034) y mira su bit bajo
	ld a,(0e0adh)		;56e2   ; Si (0xE0AD) llega a 17, incrementa (0xE034) y comprueba su bit 0
	dec a			;56e5   ; uno menos
	cp 011h		;56e6   ; hasta el paso diecisiete
	jr c,prepara_el_seguimiento		;56e8
	ld hl,0e034h		;56ea
	inc (hl)			;56ed   ; uno mas en (0xE034)
	ld a,(hl)			;56ee
	rrca			;56ef   ; y solo se sigue en los pares
	ret c			;56f0
prepara_el_seguimiento:		; Deja IX en el bloque de seguimiento
	call acumula_a_los_dos		;56f1   ; acumula la posicion de los dos
	ld ix,0e026h		;56f4   ; y la del bloque de seguimiento
	call suma_a_la_estructura		;56f8
distancia_entre_limites:		; La distancia de camara es la resta de sus dos topes
	ld a,(0e023h)		;56fb   ; Calcula la distancia de camara restando ambos limites
	ld hl,0e01bh		;56fe
	sub (hl)			;5701   ; el primer limite
	ld hl,0e027h		;5702
	sub (hl)			;5705   ; menos el segundo: esa es la distancia
	cp 0a0h		;5706   ; por encima de 0xA0, la camara ya no se mueve
	jr nc,velocidad_de_camara		;5708
	cp 030h		;570a   ; por encima de 0x30 se acerca
	ld hl,0e0adh		;570c   ; Segun el rango, decide si vibra la camara (0x572D) o pasa al siguiente estado (0x5742)
	jr nc,acerca_la_camara		;570f
	ld a,(hl)			;5711
	cp 012h		;5712   ; y en el paso 0x12 se para
	jr z,velocidad_de_camara		;5714
	inc (hl)			;5716   ; uno mas
	call esconde_los_sprites_de_fuera		;5717   ; Actualiza los limites de camara en pasos de 8
	call nueve_columnas		;571a   ; y nueve mas
	ld hl,0e098h		;571d
	ld a,(hl)			;5720
	add a,008h		;5721   ; ocho de paso
	ld (hl),a			;5723
	ld hl,0e023h		;5724
	ld a,(hl)			;5727
	add a,008h		;5728   ; y ocho tambien en la coordenada
	ld (hl),a			;572a
	jr distancia_entre_limites		;572b
acerca_la_camara:		; Por encima de 0x39, y si queda margen, la camara se acerca un paso
	cp 039h		;572d   ; Si el valor supera 0x39 y queda margen, decrementa el contador y ajusta la camara (0x5CA8)
	jr c,velocidad_de_camara		;572f   ; por debajo de 0x39 no se acerca mas
	ld a,(hl)			;5731
	or a			;5732   ; ni si el contador esta a cero
	jr z,velocidad_de_camara		;5733
	dec (hl)			;5735   ; uno menos
	call monta_dos_franjas_mas		;5736   ; dos franjas mas de terreno
	ld hl,0e023h		;5739
	ld a,(hl)			;573c
	sub 008h		;573d   ; y ocho menos de coordenada
	ld (hl),a			;573f   ; Resta 8 a la coordenada de camara (0xE023) y continua en 0x56FB
	jr distancia_entre_limites		;5740
velocidad_de_camara:		; Sale del signo de (0xE01D) con un factor de un cuarto del cuadro
	ld a,(0e01dh)		;5742   ; Calcula la velocidad segun el signo de (0xE01D), con un factor de (0xE072)/4
	rlca			;5745   ; el signo de (0xE01D)
	ld hl,0e023h		;5746
	ld a,(hl)			;5749
	jr c,guarda_el_indicador		;574a
	ld bc,(0e072h)		;574c
	srl c		;5750   ; el cuadro entre cuatro
	srl c		;5752
	sub c			;5754   ; restado a la coordenada
guarda_el_indicador:		; Deja el indicador de rumbo y mide la diferencia si el hoyo es corto
	ld (0e11ah),a		;5755   ; Guarda el indicador de viento/direccion; calcula una diferencia de posiciones si el hoyo es corto
	ld a,(0e0adh)		;5758
	dec a			;575b   ; uno menos
	cp 011h		;575c   ; hasta el paso diecisiete
	ld a,(hl)			;575e   ; Si el hoyo es corto, usa el byte leido de (hl) directamente
	jr c,puntero_por_defecto		;575f
	ld hl,0e01bh		;5761
	sub (hl)			;5764   ; el primer limite
	ld hl,0e027h		;5765
	sub (hl)			;5768   ; y el segundo
	jr guarda_el_puntero_y_repinta		;5769
puntero_por_defecto:		; El valor 0x30 cuando no hay otro
	ld a,030h		;576b   ; 0x30 por defecto
guarda_el_puntero_y_repinta:		; Nuevo puntero de puntuacion y terreno redibujado
	ld (0e112h),a		;576d   ; Guarda el nuevo puntero de datos de puntuacion y redibuja el terreno (0x585D)
	call decide_si_repinta		;5770   ; y el terreno se redibuja
	ld a,(0e01dh)		;5773   ; Segun los bits de (0xE01D) y (0xE007), decide si registra el sonido de impacto
	rlca			;5776   ; el bit 7 de (0xE01D)
	jr nc,fuerza_el_refresco		;5777
	ld hl,0e007h		;5779
	ld a,(hl)			;577c
	rrca			;577d   ; el bit 0 de (0xE007)
	jr c,fuerza_el_refresco		;577e
	set 0,(hl)		;5780   ; que se levanta aqui
	ld a,(0e0adh)		;5782   ; Calcula el limite de camara horizontal a partir del hoyo actual (0xE0AD)
	add a,013h		;5785   ; mas 0x13
	add a,a			;5787   ; por ocho
	add a,a			;5788
	add a,a			;5789
	ld h,a			;578a
	ld l,000h		;578b
	ld de,(0e022h)		;578d
	ld (0e022h),hl		;5791   ; ese es el limite nuevo
	or a			;5794
	sbc hl,de		;5795   ; menos el viejo
	ld (0e026h),hl		;5797   ; y la diferencia se guarda
	ld a,(0e00ch)		;579a
	ld b,004h		;579d   ; por debajo de 0x58, cuatro
	cp 058h		;579f
	jr c,coordenada_desde_arriba		;57a1
	ld b,008h		;57a3   ; por debajo de 0x78, ocho
	cp 078h		;57a5
	jr c,coordenada_desde_arriba		;57a7
	ld b,00ch		;57a9   ; y por encima, doce
coordenada_desde_arriba:		; 0x98 menos el valor: la Y contada desde arriba, y de paso los parametros de sonido
	sub 098h		;57ab   ; Calcula la coordenada Y (0x98-A) y fija los parametros de sonido (0xE114/0xE11C)
	neg		;57ad   ; 0x98 menos el valor: la fila contada desde arriba
	ld h,a			;57af
	ld l,000h		;57b0
	ld a,b			;57b2
	ld (0e114h),a		;57b3   ; el rango de dificultad
	ld (0e11ch),a		;57b6   ; y el parametro de sonido
	push hl			;57b9
	ld hl,(0e00ah)		;57ba   ; Compara la distancia de fotogramas (0xE00A vs 0xE06A) para decidir el redondeo
	ld de,(0e06ah)		;57bd   ; los cuadros que llevaba el vuelo
	or a			;57c1
	sbc hl,de		;57c2   ; restados
	ex de,hl			;57c4
	ld a,d			;57c5
	or e			;57c6
	jr nz,dos_coordenadas_de_camara		;57c7
	inc de			;57c9   ; y si la diferencia es cero, se pone a uno para no dividir por cero
dos_coordenadas_de_camara:		; Calcula las dos y les da la vuelta si hace falta
	ld hl,(0e026h)		;57ca   ; Calcula dos coordenadas de camara con 0x5F4C y 0x6056
	call divide_diecisiete		;57cd   ; entre diecisiete
	call niega_de		;57d0   ; con el signo cambiado
	ld (0e028h),hl		;57d3
	pop hl			;57d6
	call divide_diecisiete		;57d7   ; y la otra igual
	call niega_de		;57da
	ld (0e024h),hl		;57dd
	ret			;57e0
fuerza_el_refresco:		; Por encima de 0xA4 en (0xE113), obliga a repintar
	ld a,(0e113h)		;57e1   ; Si (0xE113) supera 0xA4, fuerza un refresco (0x52FA)
	cp 0a4h		;57e4   ; por encima de 0xA4
	call nc,valores_a_cero		;57e6   ; se fuerza el refresco
	ld hl,(0e01ah)		;57e9
	ld a,h			;57ec   ; con distancia todavia pendiente
	or l			;57ed
	ret nz			;57ee
	ld a,(0e069h)		;57ef   ; Si la distancia (0xE01A) es distinta de cero, tambien refresca; si no, limpia el indicador
	and 00fh		;57f2   ; el nibble bajo del estado
	call nz,valores_a_cero		;57f4
	xor a			;57f7
	ld (0e007h),a		;57f8   ; y el vuelo se da por terminado
	ret			;57fb
nueve_columnas:		; Prepara las nueve columnas de 0xE0EA
	ld hl,0e0eah		;57fc
	ld b,009h		;57ff   ; nueve columnas
mira_el_relleno:		; Salta las columnas que ya llevan el patron de relleno
	ld a,(hl)			;5801
	cp 0c2h		;5802   ; las que ya llevan relleno se saltan
	jr z,salta_cuatro		;5804
	add a,008h		;5806   ; y a las demas, ocho mas
	ld (hl),a			;5808
salta_cuatro:		; Avanza el puntero cuatro posiciones
	inc hl			;5809   ; Avanza el puntero 4 posiciones y repite el bucle exterior
	inc hl			;580a
	inc hl			;580b
	inc hl			;580c
	djnz mira_el_relleno		;580d
	ret			;580f
acumula_a_los_dos:		; Suma la posicion de los dos jugadores, repinta y sube el contador de cuadros
	ld ix,0e01eh		;5810   ; Acumula la posicion de los dos jugadores (0x58FF), redibuja e incrementa el contador de fotogramas
	call suma_a_la_estructura		;5814   ; el primer par
	ld ix,0e022h		;5817
	call suma_a_la_estructura		;581b   ; el segundo
	call acumula_los_dos_ejes		;581e   ; Reordena las posiciones dibujadas tras acumular el movimiento (0x587B)
	ld hl,(0e06ah)		;5821
	inc hl			;5824   ; un cuadro mas de vuelo
	ld (0e06ah),hl		;5825
	ld a,(0e01fh)		;5828
	ld (0e11bh),a		;582b   ; el indicador de altura
	ld (0e113h),a		;582e   ; y su copia
camara_del_activo:		; Calcula la posicion de camara del jugador que juega
	push af			;5831   ; Calcula la posicion de camara con 0x46B3 para el jugador activo
	push hl			;5832
	push de			;5833
	ld hl,0e015h		;5834
	ld de,0e00fh		;5837
	call columna_desde_la_fila		;583a   ; la columna del jugador que juega
	ld (0e0e6h),hl		;583d   ; que va a (0xE0E6)
	ld a,(0e000h)		;5840
	bit 6,a		;5843   ; Segun el bit 6 de (0xE000), usa las variables del jugador 1 o 2
	ld hl,0e049h		;5845   ; las variables del jugador 2
	ld de,0e047h		;5848
	jr nz,guarda_la_camara_horizontal		;584b
	ld hl,0e03ah		;584d   ; o las del 1
	ld de,0e038h		;5850
guarda_la_camara_horizontal:		; Deja el resultado en (0xE116)
	call columna_desde_la_fila		;5853   ; Guarda el resultado de 0x46B3 en (0xE116) y restaura registros
	ld (0e116h),hl		;5856   ; y el resultado a (0xE116)
	pop de			;5859
	pop hl			;585a
	pop af			;585b
	ret			;585c
decide_si_repinta:		; Cruza limite de camara, cercania del hoyo y terreno antes de decidir
	ld a,(0e112h)		;585d   ; Comprueba varias condiciones (limite de camara, hoyo cercano, terreno) antes de decidir
	ld hl,0e11ah		;5860
	cp (hl)			;5863   ; el puntero contra el limite de camara
	jr nc,pon_el_relleno		;5864
	ld a,(hl)			;5866
	cp 098h		;5867   ; y contra 0x98
	jr nc,pon_el_relleno		;5869
	ld a,(0e0adh)		;586b
	cp 00ah		;586e   ; con el hoyo por debajo del diez
	jr nc,pon_el_relleno		;5870
	ld a,(0e069h)		;5872   ; Si ninguna se cumple y el nibble bajo es cero, no hace nada mas
	and 00fh		;5875   ; y el nibble bajo del estado a cero
	ret z			;5877
pon_el_relleno:		; Deja el patron 0xC2 en la casilla
	ld (hl),0c2h		;5878   ; en cualquiera de esos casos, patron de relleno
	ret			;587a
acumula_los_dos_ejes:		; Suma velocidad y posicion en los dos ejes
	push de			;587b   ; Acumula velocidad y posicion en ambos ejes (0x58FF/0x58EB)
	push hl			;587c
	ld ix,0e00eh		;587d
	call suma_a_la_estructura		;5881
	ld hl,0e012h		;5884
	ld de,(0e010h)		;5887   ; la velocidad en columna
	call suma_dos_bytes		;588b   ; sumada a la posicion
	ld (0e010h),hl		;588e
	ld ix,0e014h		;5891   ; Repite el calculo de velocidad/posicion para el segundo eje
	call suma_a_la_estructura		;5895   ; y la del otro eje
	ld hl,0e018h		;5898
	ld de,(0e016h)		;589b   ; su velocidad
	call suma_dos_bytes		;589f   ; tambien sumada
	ld (0e016h),hl		;58a2
	ld a,001h		;58a5   ; Detecta si la bola supero el limite de distancia (bit 7 de D)
	ld hl,(0e01ah)		;58a7
	ld de,(0e01ch)		;58aa
	add hl,de			;58ae   ; la distancia recorrida mas el paso
	ld (0e01ah),hl		;58af
	jr c,descuenta_la_distancia		;58b2
	bit 7,d		;58b4   ; el bit 7 del paso: la bola ya baja
	jr z,descuenta_la_distancia		;58b6
	ld a,(0e008h)		;58b8
descuenta_la_distancia:		; Resta ocho al contador; al llegar a cero lo reinicia y avisa con acarreo
	ld hl,(0e01ch)		;58bb   ; Resta 8 al contador de distancia; si llega a 0, lo reinicia y marca el acarreo
	ld de,00008h		;58be   ; ocho menos de contador
	or a			;58c1
	sbc hl,de		;58c2
	ld (0e01ch),hl		;58c4
	or a			;58c7   ; Si la resta no llega a cero, sigue contando en la siguiente pasada
	jr nz,mira_el_rango		;58c8   ; mientras no llegue a cero, sigue el vuelo
	ld hl,00000h		;58ca
	ld (0e01ah),hl		;58cd   ; la distancia vuelve a cero
	scf			;58d0   ; y avisa con acarreo: la bola ha aterrizado
	jr recupera_registros		;58d1
mira_el_rango:		; Enciende o apaga el bit 0 de (0xE008) segun caiga (0xE01B) en su rango
	ld a,(0e01bh)		;58d3   ; Comprueba si (0xE01B) esta dentro de un rango y activa/desactiva el bit 0 de (0xE008)
	sub 0d0h		;58d6   ; menos 0xD0
	cp 010h		;58d8   ; y si no cabe en dieciseis, fuera de rango
	jr nc,limpia_el_acarreo		;58da
	ld hl,0e008h		;58dc
	res 0,(hl)		;58df   ; dentro del rango bajo
	cp 008h		;58e1   ; y a partir de ocho
	jr c,limpia_el_acarreo		;58e3
	set 0,(hl)		;58e5   ; se levanta el bit 0
limpia_el_acarreo:		; Sale sin acarreo
	or a			;58e7
recupera_registros:		; Devuelve HL y DE
	pop hl			;58e8
	pop de			;58e9
	ret			;58ea
suma_dos_bytes:		; Suma la pareja de la tabla y guarda el resultado
	ld a,(hl)			;58eb   ; Suma dos bytes consecutivos de la tabla y guarda el resultado
	inc hl			;58ec
	add a,(hl)			;58ed   ; los dos bytes de la pareja
	ld (hl),a			;58ee
	dec hl			;58ef
	bit 7,(hl)		;58f0   ; el signo del primero
	ex de,hl			;58f2   ; Segun el signo del byte anterior, suma o resta DE al resultado
	ld de,00000h		;58f3
	jr z,suma_con_acarreo		;58f6
	ccf			;58f8   ; con el negativo, se resta
	sbc hl,de		;58f9
	ret			;58fb
suma_con_acarreo:		; El remate de 16 bits
	adc hl,de		;58fc   ; y con el positivo, se suma
	ret			;58fe
suma_a_la_estructura:		; Suma un vector de dos bytes a la estructura que apunta IX
	push de			;58ff   ; Suma un vector de 2 bytes a la estructura de posicion (IX)
	ld l,(ix+000h)		;5900   ; la posicion de la estructura
	ld h,(ix+001h)		;5903
	ld e,(ix+002h)		;5906   ; y su velocidad, dos bytes mas alla
	ld d,(ix+003h)		;5909
	add hl,de			;590c   ; sumadas
	ld (ix+000h),l		;590d   ; y guardadas en la misma estructura
	ld (ix+001h),h		;5910
	pop de			;5913
	ret			;5914
escala_los_dos_bytes:		; Multiplica H y L por A y junta el resultado
	push de			;5915   ; Escala H por A y L por A (dos llamadas a 0x5F3B) y combina el resultado en HL
	push hl			;5916
	ld h,a			;5917
	call multiplica		;5918   ; la parte alta por A
	ld e,h			;591b
	pop hl			;591c
	ld l,a			;591d
	call multiplica		;591e   ; y la baja
	ld d,000h		;5921   ; Suma las dos partes escaladas
	add hl,de			;5923   ; juntas: el escalado de 16 bits
	pop de			;5924
	ret			;5925
lista_de_objetos_aparte:		; La misma busqueda de tabla_objetos_hoyo, por su cuenta
	push af			;5926   ; Repite la logica de 0x6289 (tabla_objetos_hoyo) de forma independiente
	push de			;5927
	ld a,(0e0b4h)		;5928
	dec a			;592b   ; menos uno: el hoyo 1 es la entrada 0
	add a,a			;592c   ; doblado: la tabla es de punteros
	ld e,a			;592d
	ld d,000h		;592e
	ld hl,06299h		;5930   ; Indexa la tabla de objetos del hoyo con (0xE0B4)-1
	add hl,de			;5933   ; sobre la tabla de objetos por hoyo
	ld e,(hl)			;5934
	inc hl			;5935
	ld d,(hl)			;5936
	ex de,hl			;5937
	pop de			;5938
	pop af			;5939
	ret			;593a
monta_el_marcador:		; Escribe todo el HUD: hoyo, par, POWER, CLUB, WIND y los iconos
	call lee_la_ficha_del_hoyo		;593b   ; Monta el terreno del HUD (0x4586/0x456B) y los textos de hoyo/par
	call limpia_el_terreno		;593e   ; y el buffer del terreno limpio
	ld hl,05a58h		;5941
	ld de,01a81h		;5944   ; el rotulo de 18 celdas, a VRAM 0x1A81
	ld b,012h		;5947
	call copia_a_vram		;5949
	ld hl,05a6ah		;594c
	ld de,01ac7h		;594f   ; y el de 6, a 0x1AC7
	ld b,006h		;5952
	call copia_a_vram		;5954
	ld a,(0e094h)		;5957
	ld de,017b8h		;595a   ; la barra de POWER, espejada, a VRAM 0x17B8
	call copia_y_espeja		;595d
	ld hl,(0e093h)		;5960   ; Dibuja el numero de hoyos restantes
	ld h,00ah		;5963   ; la potencia por diez
	call multiplica		;5965
	ld a,h			;5968
	add a,0b0h		;5969   ; mas 0xB0, que es el cero
	ld hl,01aceh		;596b   ; en VRAM 0x1ACE
	call 0004dh		;596e   ; BIOS WRTVRM - Writes data in VRAM
	ld a,(0e0b4h)		;5971
	cp 00ah		;5974   ; por debajo del hoyo 10
	ld c,000h		;5976
	ld hl,05a70h		;5978   ; el texto OUT
	jr c,escribe_el_hoyo		;597b
	ld hl,05a78h		;597d   ; y a partir de ahi, el texto IN, restando nueve
	ld c,009h		;5980
escribe_el_hoyo:		; El texto del hoyo -OUT o IN- y cuantos quedan
	ld de,01ae1h		;5982   ; Texto HUD (hoyo simple/doble digito) y numero de hoyos restantes en pantalla
	ld b,008h		;5985   ; ocho celdas de texto
	push bc			;5987
	call copia_a_vram		;5988
	pop bc			;598b
	ld a,(0e0b4h)		;598c
	sub c			;598f   ; menos el desplazamiento del recorrido
	add a,0b0h		;5990   ; mas 0xB0: el numero del hoyo dentro de su vuelta
	ld hl,01ae9h		;5992
	call 0004dh		;5995   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,05ab6h		;5998   ; Texto "PAR" y su valor en pantalla
	ld de,01aeeh		;599b   ; "PAR" a VRAM 0x1AEE
	ld b,004h		;599e
	call copia_a_vram		;59a0
	ld a,(0e09fh)		;59a3
	add a,0b0h		;59a6   ; el par del hoyo, mas 0xB0
	ld hl,01af2h		;59a8   ; en VRAM 0x1AF2
	call 0004dh		;59ab   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,05abah		;59ae   ; Etiquetas fijas del HUD (POWER/CLUB/WIND/HOLE/OUT/IN)
	ld de,01480h		;59b1   ; las etiquetas fijas, 48 bytes a VRAM 0x1480
	ld b,030h		;59b4
	call copia_a_vram		;59b6
	ld hl,01780h		;59b9   ; Rellena de color las tres franjas de la pantalla de juego
	ld c,020h		;59bc   ; treinta y dos celdas de la franja de arriba
	xor a			;59be
	call rellena_vram		;59bf
	ld hl,03780h		;59c2
	ld c,020h		;59c5
	ld a,08eh		;59c7   ; color 0x8E en la de abajo
	call rellena_vram		;59c9
	ld hl,037a0h		;59cc
	ld c,018h		;59cf
	ld a,08bh		;59d1   ; y 0x8B en las 24 ultimas
	call rellena_vram		;59d3
	call monta_el_plano		;59d6   ; Monta el sprite fijo de terreno inicial (0x5DEC)
	ld b,007h		;59d9   ; siete iconos de viento
	ld hl,05aeah		;59db   ; Coloca ocho iconos de viento en pantalla, uno por direccion
	ld de,020a8h		;59de
lee_un_icono_de_viento:		; Toma tipo y valor de la lista de iconos
	push bc			;59e1   ; Lee tipo y valor de un icono de viento de la lista
	ld b,(hl)			;59e2   ; la cuenta
	inc hl			;59e3
	ld a,(hl)			;59e4   ; y el valor
	inc hl			;59e5
	push hl			;59e6
	ex de,hl			;59e7
coloca_los_iconos:		; Pone los ocho rumbos del viento en su sitio
	push bc			;59e8   ; Coloca los ocho iconos de viento en pantalla (0x4156)
	push af			;59e9
	ld c,008h		;59ea   ; ocho celdas por icono
	call rellena_vram		;59ec
	ld de,00100h		;59ef   ; y una fila entera de salto
	add hl,de			;59f2
	pop af			;59f3
	pop bc			;59f4
	djnz coloca_los_iconos		;59f5
	ex de,hl			;59f7
	pop hl			;59f8
	pop bc			;59f9
	djnz lee_un_icono_de_viento		;59fa
	ld a,088h		;59fc   ; Dibuja el marcador de golpe con su color
	ld hl,03700h		;59fe   ; color 0x88 en la barra de golpe
	ld c,008h		;5a01
	call rellena_vram		;5a03
	ld de,01a75h		;5a06
	ld bc,00105h		;5a09   ; un bloque de cinco celdas
	ld hl,05af8h		;5a0c   ; Dibuja las etiquetas del HUD segun el hoyo actual (par o no)
	call copia_un_bloque		;5a0f
	ld de,(0e0b4h)		;5a12
	ld d,000h		;5a16
	dec e			;5a18   ; menos uno: el hoyo 1 es la entrada 0
	ld hl,05a80h		;5a19
	add hl,de			;5a1c
	add hl,de			;5a1d   ; tres veces: tres bytes por hoyo
	add hl,de			;5a1e
	ld a,(0e0a0h)		;5a1f   ; Elige el texto segun el bit 6 de (0xE0A0) (par/no par)
	bit 6,a		;5a22   ; el bit 6 del terreno
	ld de,01a5bh		;5a24   ; con el bajado, VRAM 0x1A5B
	jr z,pinta_el_golpe		;5a27
	ld de,01a56h		;5a29   ; y con el puesto, 0x1A56
pinta_el_golpe:		; Escribe el marcador de golpe y su separador
	ld b,003h		;5a2c   ; Dibuja el marcador de golpe (0x4145) y un caracter de separacion
	push de			;5a2e
	call copia_a_vram		;5a2f
	pop hl			;5a32
	inc hl			;5a33
	inc hl			;5a34
	inc hl			;5a35
	ld a,095h		;5a36   ; 0x95 es el separador que va detras
	call 0004dh		;5a38   ; BIOS WRTVRM - Writes data in VRAM
	call monta_la_vista_del_campo		;5a3b   ; Monta el sprite inicial del golfista (0x5AFD) en la posicion de salida
	ld b,013h		;5a3e   ; veintiuna filas
	ld de,00000h		;5a40
	ld hl,0ea00h		;5a43   ; desde 0xEA00
recorre_veintiuna_filas:		; Avanza a la vez el puntero de datos y el destino de VRAM
	push bc			;5a46   ; Recorre 21 filas avanzando el puntero de datos y el destino de VRAM en paralelo (relleno del HUD)
	call lee_el_nombre_de_la_celda		;5a47
	ld bc,00015h		;5a4a   ; 0x15 de salto en el origen
	add hl,bc			;5a4d
	ex de,hl			;5a4e
	ld bc,00020h		;5a4f   ; Avanza tanto el origen de datos como el destino de VRAM una fila mas
	add hl,bc			;5a52
	ex de,hl			;5a53
	pop bc			;5a54
	djnz recorre_veintiuna_filas		;5a55
	ret			;5a57

; ----------------------------------------------------------------------
; DATOS texto_hud_01: Texto corto del HUD, 18 bytes (0x5941)
;   0x5a58..0x5a6a  (18 bytes)
DATA_texto_hud_01:
	defb 0d0h,0cfh,0d7h,0c5h,0d2h,0f0h,0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0a0h,0c3h,0cch,0d5h	; 5a58  ................
	defb 0c2h,0bah	; 5a68

; ----------------------------------------------------------------------
; DATOS texto_hud_02: Texto corto del HUD, 6 bytes (0x594C)
;   0x5a6a..0x5a70  (6 bytes)
DATA_texto_hud_02:
	defb 0d7h,0c9h,0ceh,0c4h,0a0h,0f7h	; 5a6a

; ----------------------------------------------------------------------
; DATOS texto_hud_03a: Texto corto del HUD, 8 bytes, alternativa si el hoyo es
;   menor que 10 (0x5978)
;   0x5a70..0x5a78  (8 bytes)
DATA_texto_hud_03a:
	defb 0c8h,0cfh,0cch,0c5h,0bah,0cfh,0d5h,0d4h	; 5a70  ........

; ----------------------------------------------------------------------
; DATOS texto_hud_03b: Texto corto del HUD, 8 bytes, alternativa si el hoyo es
;   10 o mayor (0x597D)
;   0x5a78..0x5a80  (8 bytes)
DATA_texto_hud_03b:
	defb 0c8h,0cfh,0cch,0c5h,0bah,0c9h,0ceh,0a0h	; 5a78  ........

; ----------------------------------------------------------------------
; DATOS datos_hud_por_hoyo: 18 entradas de 3 bytes (una por hoyo), indexadas
;   por (0xE0B4)-1 desde 0x5A19
;   0x5a80..0x5ab6  (54 bytes)
DATA_datos_hud_por_hoyo:
	defb 0b3h,0b1h,0b1h	; 5a80
	defb 0b2h,0b0h,0b5h	; 5a83
	defb 0b3h,0b0h,0b4h	; 5a86
	defb 0b3h,0b2h,0b2h	; 5a89
	defb 0b4h,0b0h,0b5h	; 5a8c
	defb 0b3h,0b9h,0b0h	; 5a8f
	defb 0b5h,0b3h,0b6h	; 5a92
	defb 0b2h,0b9h,0b0h	; 5a95
	defb 0b2h,0b8h,0b0h	; 5a98
	defb 0b5h,0b4h,0b2h	; 5a9b
	defb 0b3h,0b1h,0b5h	; 5a9e
	defb 0b3h,0b0h,0b0h	; 5aa1
	defb 0b2h,0b7h,0b8h	; 5aa4
	defb 0b2h,0b0h,0b0h	; 5aa7
	defb 0b2h,0b8h,0b0h	; 5aaa
	defb 0b4h,0b1h,0b0h	; 5aad
	defb 0b4h,0b2h,0b0h	; 5ab0
	defb 0b3h,0b2h,0b9h	; 5ab3

; ----------------------------------------------------------------------
; DATOS texto_hud_04: Texto corto del HUD, 4 bytes (0x5998)
;   0x5ab6..0x5aba  (4 bytes)
DATA_texto_hud_04:
	defb 0d0h,0c1h,0d2h,0bah	; 5ab6

; ----------------------------------------------------------------------
; DATOS texto_hud_05: Texto corto del HUD, 48 bytes (0x59AE)
;   0x5aba..0x5aea  (48 bytes)
DATA_texto_hud_05:
	defb 000h,063h,094h,084h,064h,014h,094h,063h,000h,019h,0a5h,025h,025h,025h,0a5h,019h	; 5aba  .c..d..c...%%%..
	defb 000h,0cfh,028h,028h,0cfh,028h,028h,02fh,000h,04ah,0aah,08ah,04eh,02ah,0aah,04ah	; 5aca  ..((.((/.J..N*.J
	defb 000h,04eh,0a4h,0a4h,0a4h,0a4h,0a4h,044h,000h,000h,0a4h,0dah,092h,092h,092h,000h	; 5ada  .N.....D........

; ----------------------------------------------------------------------
; DATOS datos_hud_06: 14 bytes leidos por 0x59D6 (cuenta+parametro, ocho
;   sub-elementos via 0x4156); formato no cerrado del todo
;   0x5aea..0x5af8  (14 bytes)
DATA_datos_hud_06:
	defb 004h,0ddh,001h,088h,004h,0ddh,001h,088h,004h,0ddh,001h,088h,004h,0ddh	; 5aea  ..............

; ----------------------------------------------------------------------
; DATOS bloque_hud_00: Bloque de patrones 1x5 via 0x44E5 (0x5A0C), termina
;   justo donde arranca 0x5AFD
;   0x5af8..0x5afd  (5 bytes)
DATA_bloque_hud_00:
	defb 0e0h,0e0h,0e0h,0e0h,0e0h	; 5af8

; ======================================================================
; CODIGO 0x5afd..0x5e54  (855 bytes)
; ======================================================================


monta_la_vista_del_campo:		; Monta la lista de codigos de tile y descomprime los DOS TROZOS de la vista en perspectiva: el cielo en 0xEA00 y el suelo del tramo en 0xEA69, seguidos
	ld hl,(0e0b4h)		;5afd   ; Indice de hoyo/terreno en (0xE0B4): 0xA875 monta el fondo del campo antes de animar al golfista
	ld b,l			;5b00   ; el hoyo, en B
	ld c,h			;5b01   ; y el byte alto, en C
	push bc			;5b02
	call limpia_para_el_fondo		;5b03   ; primero el fondo del campo
	pop bc			;5b06
	push bc			;5b07
	call primer_tramo_del_hoyo		;5b08   ; y el cuadro del golfista que toca
	ld b,000h		;5b0b
	ld hl,06a2bh		;5b0d   ; Tabla de sprites del golfista en 0x6A2B, indexada por el fotograma acumulado que calcula 0x5E40
	add hl,bc			;5b10   ; doblado: la tabla de 0x6A2B es de punteros
	add hl,bc			;5b11
	push hl			;5b12
	ld e,(hl)			;5b13   ; el puntero del primer cuadro
	inc hl			;5b14
	ld d,(hl)			;5b15
	ex de,hl			;5b16
	ld de,0ea00h		;5b17   ; que se descomprime en 0xEA00
	call descomprime		;5b1a   ; Descomprime el primer sprite del golfista (postura del fotograma) en RAM 0xEA00
	pop hl			;5b1d
	pop bc			;5b1e
	ld b,000h		;5b1f
	add hl,bc			;5b21   ; el segundo cuadro, un paso mas alla en la tabla
	add hl,bc			;5b22
	ld e,(hl)			;5b23
	inc hl			;5b24
	ld d,(hl)			;5b25
	ex de,hl			;5b26
	ld de,0ea69h		;5b27   ; Segundo sprite, un fotograma mas adelante en la tabla (byte alto de (0xE0B4) como desplazamiento extra), en RAM 0xEA69
	jp descomprime		;5b2a
lee_el_nombre_de_la_celda:		; Trae de la VRAM el patron que hay en esa posicion
	push de			;5b2d   ; Lee el caracter de VRAM en esa posicion (nombre de patron)
	push hl			;5b2e
	push af			;5b2f
	ld hl,01800h		;5b30   ; la tabla de nombres
	add hl,de			;5b33
	call 0004ah		;5b34   ; BIOS RDVRM - Reads the content of VRAM | se lee la celda que hay ahi
	ld e,a			;5b37
	pop af			;5b38
	pop hl			;5b39
	push bc			;5b3a
	call pinta_veintiuna_columnas		;5b3b   ; Lo transforma con 0x5B41
	pop bc			;5b3e
	pop de			;5b3f
	ret			;5b40
pinta_veintiuna_columnas:		; La fila de la vista en perspectiva; con el bit 7 de (0xE0A0) va espejada
	push hl			;5b41   ; Si (0xE0A0) bit 7 esta activo, desplaza el puntero 0x14 posiciones
	ld a,(0e0a0h)		;5b42
	bit 7,a		;5b45   ; el bit 7 del terreno
	jr z,veintiuna		;5b47
	ld bc,00014h		;5b49   ; con el puesto, el puntero se corre veinte celdas: la vista sale espejada
	add hl,bc			;5b4c
veintiuna:		; El ancho de la vista
	ld b,015h		;5b4d   ; veintiuna columnas de ancho
pinta_una_celda_de_la_vista:		; Dibuja la celda y avanza o retrocede el puntero segun el espejo
	push bc			;5b4f
	call tile_por_indice		;5b50   ; Dibuja la celda; el puntero avanza o retrocede segun el espejo, que es lo que deja A cargado desde 0x5B42
	bit 7,a		;5b53   ; el bit 7 de (0xE0A0) OTRA VEZ, no el del byte leido: tile_por_indice conserva A, asi que este es el mismo espejo de 0x5B45
	jr z,avanza_el_puntero		;5b55
	dec hl			;5b57   ; con el puesto, el origen retrocede
	jr siguiente_columna		;5b58
avanza_el_puntero:		; El caso normal
	inc hl			;5b5a   ; y si no, avanza
siguiente_columna:		; Avanza el destino y sigue
	inc de			;5b5b   ; el destino siempre avanza
	pop bc			;5b5c
	djnz pinta_una_celda_de_la_vista		;5b5d
	pop hl			;5b5f
	ret			;5b60
tile_por_indice:		; El corazon del dibujado: el byte del mapa indexa la lista acumulada de 0xE800 -dos `add hl,bc`, o sea 16 bits- y saca el codigo de tile
	push af			;5b61   ; Lee el tile del buffer de terreno y obtiene su patron (0x5E66)
	push bc			;5b62
	push hl			;5b63
	ld c,(hl)			;5b64   ; el byte del mapa
	ld b,000h		;5b65
	ld hl,0e800h		;5b67
	add hl,bc			;5b6a   ; por dos: la lista de 0xE800 es de codigos de 16 bits
	add hl,bc			;5b6b
	ld c,(hl)			;5b6c   ; el codigo de tile, de dos bytes
	inc hl			;5b6d
	ld b,(hl)			;5b6e
	push bc			;5b6f
	pop hl			;5b70
	call pinta_un_patron		;5b71   ; con el que se pinta el patron
	call siguiente_de_la_cadena		;5b74   ; Decide si sigue la cadena de sprites de terreno (0x5EA5)
	pop hl			;5b77
	pop bc			;5b78
	pop af			;5b79
	ret			;5b7a
esconde_los_sprites_de_fuera:		; Recorre los NUEVE sprites del golfista en el buffer de atributos de 0xE0EA -cuatro bytes cada uno- y al que se sale de pantalla le pone Y=0xC2 para esconderlo
	ld bc,00900h		;5b7b   ; nueve columnas
	ld hl,0e0eah		;5b7e
mira_si_cabe:		; Si la Y del sprite mas ocho pasa de 0x98, ya no cabe: cuenta uno en C y la cambia por 0xC2, que es la Y de fuera de pantalla
	ld a,(hl)			;5b81   ; Si la fila se sale de pantalla, marca C y usa el patron de relleno 0xC2
	add a,008h		;5b82   ; ocho mas de altura
	cp 098h		;5b84   ; pasado 0x98 ya no cabe en pantalla
	jr c,guarda_la_altura		;5b86
	inc c			;5b88   ; se cuenta
	ld a,0c2h		;5b89   ; y se pone el patron de relleno
guarda_la_altura:		; Deja la Y en el atributo y salta al siguiente sprite, cuatro bytes mas alla
	ld (hl),a			;5b8b   ; Guarda el valor en la columna; si el hoyo es menor que 9, reinicia el paso de animacion
	inc hl			;5b8c   ; cuatro bytes por columna
	inc hl			;5b8d
	inc hl			;5b8e
	inc hl			;5b8f
	djnz mira_si_cabe		;5b90
	ld a,c			;5b92   ; Compara el hoyo actual contra 9 para decidir si toca reiniciar
	cp 009h		;5b93   ; con nueve columnas fuera
	jr c,monta_las_tres_franjas		;5b95
	xor a			;5b97
	ld (0e06ch),a		;5b98   ; la animacion del golpe se corta
monta_las_tres_franjas:		; Dibuja el terreno en las tres franjas de la pantalla
	ld de,0e800h		;5b9b   ; Monta el terreno en tres franjas de VRAM (0x5C45)
	ld hl,01800h		;5b9e   ; la primera franja, VRAM 0x1800
	call copia_la_franja		;5ba1
	ld hl,018e0h		;5ba4   ; la segunda, 0x18E0
	call copia_la_franja		;5ba7
	ld hl,019e0h		;5baa   ; y la tercera, 0x19E0
	call copia_la_franja		;5bad
	ld hl,0ec00h		;5bb0
	ld (0e0b0h),hl		;5bb3   ; el buffer de terreno de 0xEC00
	ld hl,01a40h		;5bb6
	call lee_de_la_vram		;5bb9   ; Calcula el limite de camara superior (0x5C9E)
	ld (0e0b2h),hl		;5bbc
	ld hl,01a20h		;5bbf
	call 0004ah		;5bc2   ; BIOS RDVRM - Reads the content of VRAM
	ld b,002h		;5bc5   ; dos pasos
	ld de,01a40h		;5bc7
franja_superior:		; Cada paso de la franja de arriba
	call fila_anterior		;5bca
	sub 020h		;5bcd   ; menos 0x20: una fila menos
	jr nc,pinta_varias_filas		;5bcf
	ld a,040h		;5bd1   ; y si se pasa, vuelve a 0x40
pinta_varias_filas:		; Varias filas de terreno seguidas
	push bc			;5bd3   ; Dibuja varias filas de terreno (0x5C6B)
	ld bc,00050h		;5bd4   ; ochenta celdas
	call pinta_la_franja		;5bd7
	pop bc			;5bda
	djnz franja_superior		;5bdb
	ld bc,00008h		;5bdd   ; y ocho mas para rematar
	call pinta_la_franja		;5be0
	call fila_anterior		;5be3   ; Calcula el siguiente limite de camara (0x5C9E)
	ld hl,0ea00h		;5be6
	ld (0e0b0h),hl		;5be9   ; el buffer de 0xEA00
	ld hl,019e0h		;5bec
	call lee_de_la_vram		;5bef
	ld (0e0b2h),hl		;5bf2
	ld hl,019c0h		;5bf5
	call 0004ah		;5bf8   ; BIOS RDVRM - Reads the content of VRAM
	ld b,007h		;5bfb   ; siete pasos
	ld de,019e0h		;5bfd
fila_repetida:		; Una fila repetida en todo el ancho
	call fila_anterior		;5c00   ; Dibuja una fila de terreno repetida en todo el ancho de pantalla
	sub 020h		;5c03
	push bc			;5c05
	ld bc,00018h		;5c06   ; veinticuatro columnas por fila
	call pinta_la_franja		;5c09
	pop bc			;5c0c
	djnz fila_repetida		;5c0d
	call fila_anterior		;5c0f
	sub 020h		;5c12
	ld hl,0e800h		;5c14
	ld (0e0b0h),hl		;5c17   ; y el buffer de 0xE800
	ld hl,018e0h		;5c1a
	call lee_de_la_vram		;5c1d   ; Calcula el siguiente limite de camara y prepara el dibujado de la franja central
	ld (0e0b2h),hl		;5c20
	ld b,007h		;5c23
	ld de,018e0h		;5c25
fila_de_veinticuatro:		; Una fila de veinticuatro columnas, repetida
	call fila_anterior		;5c28   ; Dibuja una fila de 24 columnas repetidamente para toda la pantalla
	sub 020h		;5c2b
	push bc			;5c2d
	ld bc,00018h		;5c2e
	call pinta_la_franja		;5c31
	pop bc			;5c34
	djnz fila_de_veinticuatro		;5c35
	call fila_anterior		;5c37
	ld hl,(0e0aeh)		;5c3a   ; Ajusta la posicion de scroll vertical (-21) al terminar
	ld de,0ffebh		;5c3d   ; 0xFFEB es -21: el scroll retrocede una fila de la vista
	add hl,de			;5c40
	ld (0e0aeh),hl		;5c41
	ret			;5c44
copia_la_franja:		; Trae dos franjas de 0xA8 bytes de la VRAM a la RAM: el terreno que se ve
	push bc			;5c45   ; Copia dos franjas de 0xA8 bytes de VRAM a RAM (terreno visible)
	call lee_de_la_vram		;5c46   ; la posicion de origen
	ld bc,000a8h		;5c49   ; 0xA8 bytes, que son las celdas visibles
	push hl			;5c4c   ; Copia la primera franja de VRAM a RAM (terreno visible izquierdo)
	push de			;5c4d
	call 00059h		;5c4e   ; BIOS LDIRMV - Block transfers to memory from VRAM | traidas de la VRAM
	pop de			;5c51
	ld hl,00100h		;5c52   ; y una fila entera de salto
	add hl,de			;5c55
	ex de,hl			;5c56
	pop hl			;5c57
	ld bc,02000h		;5c58   ; La segunda franja esta desplazada 0x2000 en VRAM (el otro tercio de pantalla)
	add hl,bc			;5c5b
	push de			;5c5c
	ld bc,000a8h		;5c5d
	call 00059h		;5c60   ; BIOS LDIRMV - Block transfers to memory from VRAM
	pop de			;5c63
	ld hl,00100h		;5c64
	add hl,de			;5c67
	ex de,hl			;5c68
	pop bc			;5c69
	ret			;5c6a
pinta_la_franja:		; Escribe una franja entera con el patron que le toque
	push af			;5c6b
	push de			;5c6c
	push hl			;5c6d
	push bc			;5c6e
	ld hl,(0e0b0h)		;5c6f   ; Copia la fila de terreno (0xE0B0/0xE0B2) a las dos franjas de VRAM
	ld de,(0e0b2h)		;5c72   ; y el destino en VRAM
	push hl			;5c76
	push de			;5c77
	call 0005ch		;5c78   ; BIOS LDIRVM - Block transfers to VRAM from memory | la primera franja
	pop de			;5c7b
	ld hl,02000h		;5c7c   ; 0x2000 mas alla
	add hl,de			;5c7f
	ex de,hl			;5c80
	pop hl			;5c81
	ld bc,00100h		;5c82   ; y 0x100 en el origen
	add hl,bc			;5c85
	pop bc			;5c86
	push bc			;5c87
	call 0005ch		;5c88   ; BIOS LDIRVM - Block transfers to VRAM from memory | la segunda franja
	pop bc			;5c8b
	ld hl,(0e0b0h)		;5c8c   ; Avanza los punteros de origen para la siguiente fila
	add hl,bc			;5c8f   ; los dos punteros avanzan lo mismo
	ld (0e0b0h),hl		;5c90
	ld hl,(0e0b2h)		;5c93
	add hl,bc			;5c96
	ld (0e0b2h),hl		;5c97
	pop hl			;5c9a
	pop de			;5c9b
	pop af			;5c9c
	ret			;5c9d
lee_de_la_vram:		; Trae el byte que hay en esa posicion
	push af			;5c9e
	call 0004ah		;5c9f   ; BIOS RDVRM - Reads the content of VRAM | el byte que hay en esa posicion
	ld l,a			;5ca2
	add hl,hl			;5ca3   ; por ocho: cada fila son ocho bytes
	add hl,hl			;5ca4
	add hl,hl			;5ca5
	pop af			;5ca6
	ret			;5ca7
monta_dos_franjas_mas:		; Las dos franjas de terreno que faltan
	push hl			;5ca8   ; Monta dos franjas de terreno adicionales (0x5C45)
	ld de,0e800h		;5ca9   ; el buffer de terreno
	ld hl,01900h		;5cac
	call copia_la_franja		;5caf   ; la franja de 0x1900
	ld hl,01a00h		;5cb2   ; y la de 0x1A00
	call copia_la_franja		;5cb5
	ld hl,0e800h		;5cb8
	ld (0e0b0h),hl		;5cbb
	ld hl,01800h		;5cbe
	call lee_de_la_vram		;5cc1   ; Calcula el limite de camara correspondiente
	ld (0e0b2h),hl		;5cc4
	ld hl,01800h		;5cc7
	call 0004ah		;5cca   ; BIOS RDVRM - Reads the content of VRAM
	add a,020h		;5ccd   ; una fila mas
	ld b,007h		;5ccf   ; siete pasos
	ld de,01800h		;5cd1
fila_hacia_abajo:		; Otra fila repetida, recorriendo hacia abajo
	call fila_siguiente		;5cd4   ; Dibuja otra fila de terreno repetida
	add a,020h		;5cd7
	push bc			;5cd9
	ld bc,00018h		;5cda   ; veinticuatro columnas
	call pinta_la_franja		;5cdd
	pop bc			;5ce0
	djnz fila_hacia_abajo		;5ce1
	call fila_siguiente		;5ce3
	add a,020h		;5ce6
	ld hl,0ea00h		;5ce8
	ld (0e0b0h),hl		;5ceb
	ld hl,01900h		;5cee
	call lee_de_la_vram		;5cf1   ; Calcula el limite de camara para esta franja
	ld (0e0b2h),hl		;5cf4
	ld b,007h		;5cf7
	ld de,01900h		;5cf9
fila_de_veinticuatro_abajo:		; La variante de veinticuatro columnas
	call fila_siguiente		;5cfc   ; Dibuja una fila de 24 columnas de patron (0x5C6B)
	add a,020h		;5cff
	push bc			;5d01
	ld bc,00018h		;5d02   ; veinticuatro columnas otra vez
	call pinta_la_franja		;5d05
	pop bc			;5d08
	djnz fila_de_veinticuatro_abajo		;5d09
	call fila_siguiente		;5d0b   ; Repite el dibujado de la fila para el siguiente tercio de pantalla
	ld hl,01a00h		;5d0e
	call 0004ah		;5d11   ; BIOS RDVRM - Reads the content of VRAM
	ld b,002h		;5d14
	ld de,01a00h		;5d16
avanza_la_fila:		; Sube la fila en 0x20 y para en 0x60
	add a,020h		;5d19
	cp 060h		;5d1b   ; y al llegar a 0x60 se da la vuelta
	jr nz,pinta_y_avanza		;5d1d
	xor a			;5d1f
pinta_y_avanza:		; Pinta la fila y pasa a la siguiente
	call fila_siguiente		;5d20
	djnz avanza_la_fila		;5d23
	call monta_la_vista_del_campo		;5d25   ; con el terreno montado, el golfista encima
	ld hl,01a40h		;5d28
	call 0004ah		;5d2b   ; BIOS RDVRM - Reads the content of VRAM
	add a,020h		;5d2e
	cp 060h		;5d30   ; tambien al llegar a 0x60
	jr nz,lee_la_posicion_de_scroll		;5d32
	xor a			;5d34
lee_la_posicion_de_scroll:		; Trae el caracter que hay donde va el scroll
	ld e,a			;5d35   ; Lee el caracter de VRAM en la posicion de scroll actual
	ld d,002h		;5d36   ; el tercio 2 de la pantalla
	ld hl,(0e0aeh)		;5d38   ; la posicion de scroll
	push hl			;5d3b
	call pinta_veintiuna_columnas		;5d3c   ; y ahi se pinta la fila de la vista
	pop hl			;5d3f
	ld bc,00015h		;5d40   ; veintiuna celdas mas de scroll
	add hl,bc			;5d43
	ld (0e0aeh),hl		;5d44
	ld hl,01a40h		;5d47
	call 0004ah		;5d4a   ; BIOS RDVRM - Reads the content of VRAM
	add a,020h		;5d4d   ; Ajusta el color si el valor leido supera el umbral (0x60)
	cp 060h		;5d4f
	jr nz,fila_del_borde		;5d51
	xor a			;5d53
fila_del_borde:		; La fila de 0x1A40, la del borde del campo
	ld de,01a40h		;5d54
	call fila_siguiente		;5d57
	pop hl			;5d5a
	ret			;5d5b
fila_anterior:		; Retrocede una fila de VRAM
	push hl			;5d5c
	ld hl,0ffe0h		;5d5d
	jr prepara_el_relleno_incremental		;5d60
fila_siguiente:		; Avanza una fila de VRAM
	push hl			;5d62
	ld hl,00020h		;5d63
prepara_el_relleno_incremental:		; Veintiun valores consecutivos
	push af			;5d66   ; Prepara un bucle de relleno de 21 valores consecutivos
	push bc			;5d67
	push de			;5d68
	push hl			;5d69
	ld hl,0ef00h		;5d6a
	push hl			;5d6d
	ld b,015h		;5d6e
rellena_incremental:		; Escribe 0, 1, 2... hasta veinte: la fila identidad
	ld (hl),a			;5d70   ; Rellena una fila con valores incrementales (0-20)
	inc a			;5d71
	inc hl			;5d72
	djnz rellena_incremental		;5d73
	pop hl			;5d75
	ld bc,00015h		;5d76
	call 0005ch		;5d79   ; BIOS LDIRVM - Block transfers to VRAM from memory | Copia la fila completa a VRAM (21 bytes)
	pop hl			;5d7c
	pop de			;5d7d
	add hl,de			;5d7e
	ex de,hl			;5d7f
	pop bc			;5d80
	pop af			;5d81
	pop hl			;5d82
	ret			;5d83
monta_el_plano_del_hoyo:		; Descomprime la paleta de 0xB3E2 y el plano que toque, y lo pinta en la franja de la derecha
	ld hl,0b3e2h		;5d84   ; Descomprime el sprite fijo de terreno en 0xB3E2 (RAM 0xE800)
	ld de,0e800h		;5d87
	call paleta_acumulada		;5d8a
	ld hl,(0e0b4h)		;5d8d
	ld h,000h		;5d90
	dec l			;5d92
	ld de,0b417h		;5d93   ; Tabla de 18 punteros en 0xB417, indexada por (0xE0B4)-1: el otro sprite del par de fondo
	add hl,hl			;5d96
	add hl,de			;5d97
	ld e,(hl)			;5d98
	inc hl			;5d99
	ld d,(hl)			;5d9a
	ex de,hl			;5d9b
	ld de,0ea00h		;5d9c
	call descomprime		;5d9f   ; Descomprime el sprite elegido en RAM 0xEA00
	ld hl,0ea00h		;5da2
	ld b,00ah		;5da5
	call plano_desde_la_celda_22		;5da7
	ld b,009h		;5daa
	ld hl,02ab0h		;5dac
rellena_el_color_del_campo:		; Rellena de color las franjas de la vista
	push bc			;5daf   ; Rellena de color varias franjas de pantalla (0x4156)
	ld a,011h		;5db0
	ld c,050h		;5db2
	call rellena_vram		;5db4
	ld bc,00100h		;5db7
	add hl,bc			;5dba
	pop bc			;5dbb
	djnz rellena_el_color_del_campo		;5dbc
	ld b,005h		;5dbe
	ld hl,00016h		;5dc0
	ld de,00000h		;5dc3
	call veintiun_patrones		;5dc6   ; Dibuja tres textos en distintas posiciones (0x5DD6)
	ld b,004h		;5dc9
	ld hl,0003dh		;5dcb
	call veintiun_patrones		;5dce
	ld b,00ah		;5dd1
	ld hl,00003h		;5dd3
veintiun_patrones:		; Veintiuna columnas por fila de terreno
	push bc			;5dd6
	ld b,015h		;5dd7
pinta_y_encadena:		; Dibuja el patron y salta al siguiente bloque de la cadena
	call pinta_un_patron		;5dd9   ; Dibuja un patron de terreno (0x5E66) y descomprime el siguiente sprite de la cadena (0x5EA5)
	call siguiente_de_la_cadena		;5ddc
	inc de			;5ddf
	djnz pinta_y_encadena		;5de0
	ex de,hl			;5de2   ; Avanza el puntero de datos 0xB (11) posiciones tras cada patron dibujado
	ld bc,0000bh		;5de3
	add hl,bc			;5de6
	ex de,hl			;5de7
	pop bc			;5de8
	djnz veintiun_patrones		;5de9
	ret			;5deb
monta_el_plano:		; Paleta acumulada de 0xB349 en 0xE800, plano del hoyo de tabla_planos_de_hoyo en 0xEA14, y diecinueve filas por dibujar
	ld hl,0b349h		;5dec   ; Descomprime el sprite fijo de 0xB349 en 0xE800
	ld de,0e800h		;5def
	call paleta_acumulada		;5df2
	ld hl,(0e0b4h)		;5df5
	ld h,000h		;5df8
	dec l			;5dfa
	ld de,0acb7h		;5dfb   ; Descomprime el sprite de tabla_planos_de_hoyo correspondiente al hoyo en 0xEA14
	add hl,hl			;5dfe
	add hl,de			;5dff
	ld e,(hl)			;5e00
	inc hl			;5e01
	ld d,(hl)			;5e02
	ex de,hl			;5e03
	ld de,0ea14h		;5e04
	push de			;5e07
	call descomprime		;5e08
	pop hl			;5e0b
	ld b,013h		;5e0c
plano_desde_la_celda_22:		; El plano ocupa las columnas 22 a 31 de la pantalla
	ld de,00016h		;5e0e
plano_una_fila:		; Una fila del plano; con el espejo puesto, adelanta nueve y recorre hacia atras
	push bc			;5e11   ; Si (0xE0A0) bit 7 esta activo, desplaza el puntero 9 posiciones
	push de			;5e12
	push hl			;5e13
	ld a,(0e0a0h)		;5e14
	bit 7,a		;5e17
	jr z,diez_columnas		;5e19
	ld bc,00009h		;5e1b
	add hl,bc			;5e1e
diez_columnas:		; El ancho del plano
	ld b,00ah		;5e1f
plano_una_celda:		; Dibuja la celda y mueve el puntero en el sentido que toque
	push bc			;5e21   ; Dibuja la celda; el `bit 7,a` de 0x5E26 NO mira el byte leido sino (0xE0A0), que tile_por_indice conserva: con el espejo puesto el inc y los dos dec dejan un retroceso neto
	call tile_por_indice		;5e22
	inc hl			;5e25
	bit 7,a		;5e26
	jr z,plano_siguiente_fila		;5e28
	dec hl			;5e2a
	dec hl			;5e2b
plano_siguiente_fila:		; Avanza diez en los datos y treinta y dos en la pantalla
	inc de			;5e2c   ; Avanza los punteros de datos y VRAM para la siguiente columna del elemento
	pop bc			;5e2d
	djnz plano_una_celda		;5e2e
	pop hl			;5e30
	pop de			;5e31
	ld bc,0000ah		;5e32
	add hl,bc			;5e35
	ex de,hl			;5e36
	ld bc,00020h		;5e37   ; Y para la siguiente fila del elemento
	add hl,bc			;5e3a
	ex de,hl			;5e3b
	pop bc			;5e3c
	djnz plano_una_fila		;5e3d
	ret			;5e3f
primer_tramo_del_hoyo:		; Suma los tramos de los hoyos anteriores y devuelve en C la primera entrada de tabla_vistas_del_campo de este hoyo, y en B cuantas tiene
	push af			;5e40   ; Suma los B-1 primeros pasos de tabla_pasos_golfista y devuelve el acumulado en C (indice de fotograma) y el paso actual en B
	push hl			;5e41
	xor a			;5e42
	ld c,a			;5e43
	ld hl,05e54h		;5e44
suma_los_pasos:		; El bucle de esa suma
	dec b			;5e47   ; Bucle de suma de tabla_pasos_golfista: acumula en A mientras cuenta en C
	jr z,devuelve_el_cuadro		;5e48
	inc c			;5e4a
	add a,(hl)			;5e4b
	inc hl			;5e4c
	jr suma_los_pasos		;5e4d
devuelve_el_cuadro:		; Deja el acumulado en C y el paso actual en B
	ld c,a			;5e4f
	ld b,(hl)			;5e50
	pop hl			;5e51
	pop af			;5e52
	ret			;5e53

; ----------------------------------------------------------------------
; DATOS tabla_tramos_por_hoyo: Cuantas entradas de tabla_vistas_del_campo
;   tiene cada hoyo: una de cielo y las demas de suelo, o sea entre tres y
;   cinco TRAMOS jugables por hoyo (80 en total). 0x5E40 los suma para dar con
;   el grupo del hoyo
;   0x5e54..0x5e66  (18 bytes)
DATA_tabla_tramos_por_hoyo:
	defb 006h,004h,006h,006h,006h,005h,006h,005h,005h,006h,006h,006h,005h,004h,005h,005h	; 5e54  ................
	defb 006h,006h	; 5e64

; ======================================================================
; CODIGO 0x5e66..0x5f32  (204 bytes)
; ======================================================================


pinta_un_patron:		; Copia el patron de 8x8 de tabla_patrones_terreno a la VRAM, espejandolo si el bit 7 de (0xE0A0) esta puesto
	push af			;5e66
	push bc			;5e67
	push de			;5e68
	push hl			;5e69   ; Guarda una copia extra del parametro (codigo de tile) para el calculo final
	push hl			;5e6a
	ex de,hl			;5e6b
	add hl,hl			;5e6c
	add hl,hl			;5e6d
	add hl,hl			;5e6e
	ld de,00000h		;5e6f
	add hl,de			;5e72
	ex de,hl			;5e73
	pop hl			;5e74
	add hl,hl			;5e75
	add hl,hl			;5e76
	add hl,hl			;5e77
	ld bc,08b5eh		;5e78   ; Base de tabla_patrones_terreno (0x8B5E), indexada por el codigo de tile (*8)
	add hl,bc			;5e7b
	ld a,(0e0a0h)		;5e7c   ; Si (0xE0A0) bit 7 esta activo, espeja el patron bit a bit (rlc/rra) antes de copiarlo a VRAM
	rlca			;5e7f
	jr nc,copia_el_patron		;5e80
	push de			;5e82
	ld de,0e122h		;5e83
	push de			;5e86
	ld b,008h		;5e87
espejo_ocho_filas:		; Ocho filas por patron
	push bc			;5e89
	ld b,008h		;5e8a
	ld c,(hl)			;5e8c
espeja_un_byte:		; Le da la vuelta a los ocho bits con rlc y rra
	rlc c		;5e8d   ; Bucle de espejado bit a bit (rlc/rra), copia el resultado a VRAM
	rra			;5e8f
	djnz espeja_un_byte		;5e90
	ld (de),a			;5e92
	inc hl			;5e93
	inc de			;5e94
	pop bc			;5e95
	djnz espejo_ocho_filas		;5e96
	pop hl			;5e98
	pop de			;5e99
copia_el_patron:		; El caso normal, sin espejo
	ld bc,00008h		;5e9a
	call 0005ch		;5e9d   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;5ea0
	pop de			;5ea1
	pop bc			;5ea2
	pop af			;5ea3
	ret			;5ea4
siguiente_de_la_cadena:		; Calcula el indice del terreno y avanza por la cadena de bloques
	push af			;5ea5   ; Calcula el indice (a*16) para el terreno actual
	push bc			;5ea6
	push de			;5ea7
	push hl			;5ea8
	push de			;5ea9
	push hl			;5eaa
	add hl,hl			;5eab
	add hl,hl			;5eac
	add hl,hl			;5ead
	add hl,hl			;5eae
	ld a,h			;5eaf
	ld hl,0e0a5h		;5eb0
	cp (hl)			;5eb3   ; Si coincide con la ultima cache (0xE0A5), no repite la cadena de sprites
	jr z,direccion_del_marcador		;5eb4
	ld (hl),a			;5eb6
	ld hl,09d2eh		;5eb7
suma_las_cabeceras:		; Cada cabecera dice cuanto saltar hasta el bloque siguiente
	or a			;5eba   ; Bucle de suma de deltas de la cadena de sprites de terreno (avanza hl sumando cada cabecera)
	jr z,descomprime_el_bloque		;5ebb
	ld e,(hl)			;5ebd
	inc hl			;5ebe
	ld d,(hl)			;5ebf
	inc hl			;5ec0
	add hl,de			;5ec1
	dec a			;5ec2
	jr suma_las_cabeceras		;5ec3
descomprime_el_bloque:		; Y lo descomprime en 0xEE00
	ld de,0ee00h		;5ec5
	call descomprime		;5ec8
direccion_del_marcador:		; Dos multiplicaciones por ocho dan la posicion de VRAM
	pop hl			;5ecb   ; Calcula la direccion de VRAM del marcador (dos multiplicaciones por 8)
	add hl,hl			;5ecc
	add hl,hl			;5ecd
	add hl,hl			;5ece
	ld h,000h		;5ecf
	res 7,l		;5ed1
	ld bc,0ee00h		;5ed3
	add hl,bc			;5ed6
	ex de,hl			;5ed7
	pop hl			;5ed8
	add hl,hl			;5ed9
	add hl,hl			;5eda
	add hl,hl			;5edb
	ld bc,02000h		;5edc
	add hl,bc			;5edf
	ex de,hl			;5ee0
	ld bc,00008h		;5ee1   ; Copia 8 bytes del patron a esa posicion
	call 0005ch		;5ee4   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;5ee7
	pop de			;5ee8
	pop bc			;5ee9
	pop af			;5eea
	ret			;5eeb
multiplicador_base:		; Uno o dos, segun los bits de (0xE000)
	xor a			;5eec   ; Calcula un multiplicador base (1 o 2) segun los bits de (0xE000)
	ld h,a			;5eed
	call multiplica_y_junta		;5eee
	push af			;5ef1
	ld a,(0e000h)		;5ef2
	ld hl,00102h		;5ef5
	rlca			;5ef8
	jr c,multiplica_los_dos		;5ef9
	ld l,001h		;5efb   ; Ajusta el multiplicador si el segundo bit tambien esta activo
	rlca			;5efd
	jr c,multiplica_los_dos		;5efe
	add hl,hl			;5f00
multiplica_los_dos:		; Multiplica angulo por potencia con la rutina de abajo
	pop af			;5f01   ; Multiplica dos valores con 0x5F14 (angulo/potencia)
	call multiplica_y_junta		;5f02
	ld h,l			;5f05
	call multiplica_y_junta		;5f06
	ld b,a			;5f09
	ld hl,0e0a7h		;5f0a   ; Combina el resultado con el parametro de dificultad (0xE0A7)
	ld a,(hl)			;5f0d
	ld (hl),b			;5f0e
	cpl			;5f0f
	and b			;5f10
	inc hl			;5f11
	ld (hl),a			;5f12
	ret			;5f13
multiplica_y_junta:		; Multiplica y combina los dos resultados
	push hl			;5f14
	push af			;5f15
	ld a,h			;5f16
	push af			;5f17
	call 000d5h		;5f18   ; BIOS GTSTCK - Returns the joystick status
	ld c,a			;5f1b
	ld b,000h		;5f1c
	ld hl,05f32h		;5f1e
	add hl,bc			;5f21
	pop af			;5f22
	push hl			;5f23
	call 000d8h		;5f24   ; BIOS GTTRIG - Returns current trigger status
	pop hl			;5f27
	or a			;5f28
	jr z,junta_los_bits		;5f29
	ld a,010h		;5f2b
junta_los_bits:		; Mezcla el resultado con lo que ya habia
	or (hl)			;5f2d
	pop hl			;5f2e
	or h			;5f2f
	pop hl			;5f30
	ret			;5f31

; ----------------------------------------------------------------------
; DATOS tabla_direccion_stick: 9 bytes, tabla de conversion de la direccion
;   del joystick (0-8, GTSTCK) usada en 0x5F14
;   0x5f32..0x5f3b  (9 bytes)
DATA_tabla_direccion_stick:
	defb 000h,001h,009h,008h,00ah,002h,006h,004h,005h	; 5f32  .........

; ======================================================================
; CODIGO 0x5f3b..0x6062  (295 bytes)
; ======================================================================


multiplica:		; Multiplicacion de ocho por ocho bits: ocho pasos de sumar y desplazar
	push bc			;5f3b   ; Multiplicacion de 8x8 bits (H*L), suma y desplaza 8 veces
	push de			;5f3c
	ld d,000h		;5f3d
	ld e,l			;5f3f
	ld l,d			;5f40
	ld b,008h		;5f41
multiplica_paso:		; El desplazamiento y la suma si el bit esta puesto
	add hl,hl			;5f43
	jr nc,multiplica_cierra		;5f44
	add hl,de			;5f46
multiplica_cierra:		; Devuelve el producto de dieciseis bits
	djnz multiplica_paso		;5f47
	pop de			;5f49
	pop bc			;5f4a
	ret			;5f4b
divide_diecisiete:		; Diecisiete pasos de desplazamiento sobre el vector de entrada
	push af			;5f4c   ; Prepara un bucle de 0x11 (17) iteraciones sobre el vector de entrada
	push bc			;5f4d
	push de			;5f4e
	ex de,hl			;5f4f
	ld b,011h		;5f50
	xor a			;5f52
divide_paso:		; Cada paso de esa division
	inc a			;5f53
	add hl,hl			;5f54
	jr c,divide_baja		;5f55
	djnz divide_paso		;5f57
divide_baja:		; Baja el par HL un bit
	rr h		;5f59
	rr l		;5f5b
	ex de,hl			;5f5d
	ld bc,00000h		;5f5e
divide_por_restas:		; Resta DE y cuenta el cociente en C
	inc c			;5f61   ; Divide por reste sucesiva (DE), cuenta el cociente en C
	or a			;5f62
	sbc hl,de		;5f63
	jr nc,divide_y_dobla		;5f65
	add hl,de			;5f67
	dec c			;5f68
divide_y_dobla:		; Baja DE y sube BC a la vez: division y multiplicacion en el mismo bucle
	dec a			;5f69   ; Division/multiplicacion por 2 simultanea, desplazando DE a la derecha y BC a la izquierda
	jr z,divide_devuelve		;5f6a
	srl d		;5f6c
	rr e		;5f6e
	sla c		;5f70
	rl b		;5f72
	jr divide_por_restas		;5f74
divide_devuelve:		; Deja el cociente y vuelve
	push bc			;5f76   ; Restaura registros y vuelve
	pop hl			;5f77
	pop de			;5f78
	pop bc			;5f79
	pop af			;5f7a
	ret			;5f7b
raiz_arranca:		; Prepara la busqueda con DE a cero
	push de			;5f7c
	ld de,00000h		;5f7d
	scf			;5f80
raiz_por_impares:		; Resta impares sucesivos: la raiz cuadrada entera del cartucho
	sbc hl,de		;5f81   ; Bucle de resta doble (division entera aproximada por 2*DE)
	jr c,raiz_devuelve		;5f83
	sbc hl,de		;5f85
	jr c,raiz_devuelve		;5f87
	inc de			;5f89
	jr raiz_por_impares		;5f8a
raiz_devuelve:		; Deja la raiz en HL
	ex de,hl			;5f8c
	pop de			;5f8d
	ret			;5f8e
distancia_sin_signo:		; Diferencia absoluta de los dos ejes
	push de			;5f8f   ; Valor absoluto de H-D (distancia sin signo)
	push hl			;5f90
	ld a,h			;5f91
	sub d			;5f92
	jr nc,distancia_segundo_eje		;5f93
	neg		;5f95
distancia_segundo_eje:		; El otro cateto
	ld d,a			;5f97
	ld a,l			;5f98
	sub e			;5f99
	jr nc,suma_de_cuadrados		;5f9a
	neg		;5f9c
suma_de_cuadrados:		; Eleva los dos al cuadrado y los suma
	ld h,a			;5f9e   ; Calcula A al cuadrado y D al cuadrado (0x5F3B), los suma
	ld l,a			;5f9f
	call multiplica		;5fa0
	push hl			;5fa3
	ld h,d			;5fa4
	ld l,d			;5fa5
	call multiplica		;5fa6
	pop de			;5fa9
	add hl,de			;5faa
	call raiz_arranca		;5fab   ; Toma la raiz cuadrada aproximada de la suma (0x5F7C): distancia diagonal
	ld a,l			;5fae
	pop hl			;5faf
	pop de			;5fb0
	ret			;5fb1
rumbo_y_distancia:		; Diferencia absoluta con el signo apuntado en el bit 6 de B
	push bc			;5fb2   ; Valor absoluto de D-H, marca el signo en el bit 6 de B
	push de			;5fb3
	push hl			;5fb4
	ld b,000h		;5fb5
	ld a,d			;5fb7
	sub h			;5fb8
	jr nc,rumbo_segundo_eje		;5fb9
	neg		;5fbb
	set 6,b		;5fbd
rumbo_segundo_eje:		; Y el otro, con el signo en el bit 7
	ld c,a			;5fbf   ; Valor absoluto de E-L, marca el signo en el bit 7 de B
	ld a,e			;5fc0
	sub l			;5fc1
	jr nc,distancia_diagonal		;5fc2
	neg		;5fc4
	set 7,b		;5fc6
distancia_diagonal:		; La hipotenusa: suma de cuadrados y raiz
	ld h,a			;5fc8   ; Calcula la distancia diagonal A^2+C^2 (0x5F3B/0x5F7C)
	ld l,a			;5fc9
	call multiplica		;5fca
	push hl			;5fcd
	ld h,c			;5fce
	ld l,c			;5fcf
	call multiplica		;5fd0
	pop de			;5fd3
	add hl,de			;5fd4
	call raiz_arranca		;5fd5
	ex de,hl			;5fd8
	ld h,a			;5fd9
	ld l,000h		;5fda
	call divide_diecisiete		;5fdc   ; Convierte la distancia en fila/columna de pantalla (0x5F4C)
	bit 0,h		;5fdf
	jr z,arranca_la_busqueda_de_rumbo		;5fe1
	dec hl			;5fe3
arranca_la_busqueda_de_rumbo:		; Prepara el recorrido de la tabla de rumbos
	ld a,l			;5fe4
	ld c,000h		;5fe5
	ld hl,06062h		;5fe7
busca_el_rumbo:		; Cuenta cuantas entradas de la tabla quedan por debajo: el arcotangente por tabla
	cp (hl)			;5fea   ; Busqueda lineal: cuenta en C cuantas entradas de la tabla son menores que A
	jr z,junta_los_signos		;5feb
	jr c,junta_los_signos		;5fed
	inc c			;5fef
	inc hl			;5ff0
	jr busca_el_rumbo		;5ff1
junta_los_signos:		; Convierte los dos bits de signo en un rumbo con signo
	ld a,b			;5ff3   ; Convierte el signo de B/C en un valor con signo unico (complemento o suma 0x80)
	rlca			;5ff4
	jr nc,rumbo_desplazado		;5ff5
	rlca			;5ff7
	ld a,c			;5ff8
	jr nc,rumbo_negativo		;5ff9
	add a,080h		;5ffb
	jr rumbo_devuelve		;5ffd
rumbo_negativo:		; El cuadrante que sale negado
	neg		;5fff
	jr rumbo_devuelve		;6001
rumbo_desplazado:		; El que va desplazado media vuelta
	rlca			;6003
	ld a,c			;6004
	jr nc,rumbo_devuelve		;6005
	neg		;6007
	add a,080h		;6009
rumbo_devuelve:		; Deja el rumbo listo
	pop hl			;600b
	pop de			;600c
	pop bc			;600d
	ret			;600e
componentes_negadas:		; Las mismas componentes, cambiadas de signo
	call angulo_a_coordenadas		;600f   ; Calcula la negacion de BC (0-BC) tras la conversion de 0x601B
	ld hl,00000h		;6012
	or a			;6015
	sbc hl,bc		;6016
	push hl			;6018
	pop bc			;6019
	ret			;601a
angulo_a_coordenadas:		; Convierte un rumbo en su pareja X,Y
	push hl			;601b   ; Convierte el angulo en coordenada X,Y encadenando 0x6032 y 0x6028
	push hl			;601c
	call coordenada_por_tabla		;601d
	ex (sp),hl			;6020
	call coordenada_invertida		;6021
	ex de,hl			;6024
	pop bc			;6025
	pop hl			;6026
	ret			;6027
coordenada_invertida:		; El cuadrante en el que hay que invertir antes de mirar la tabla
	push af			;6028   ; Invierte el valor (complemento a 2 + 0x40) antes de llamar a 0x6032
	neg		;6029
	add a,040h		;602b
	call coordenada_por_tabla		;602d
	pop af			;6030
	ret			;6031
coordenada_por_tabla:		; Con 0x40 o 0xC0 no hay nada que hacer; con el bit 6, invierte antes de mirar la tabla
	push bc			;6032   ; Si A es 0x40 o 0xC0 no hace nada; si el bit 6 esta activo invierte A
	push af			;6033
	cp 040h		;6034
	jr z,coordenada_devuelve		;6036
	cp 0c0h		;6038
	jr z,coordenada_devuelve		;603a
	push hl			;603c
	bit 6,a		;603d
	jr z,entra_en_la_tabla		;603f
	neg		;6041
entra_en_la_tabla:		; Los seis bits bajos indexan la tabla del swing
	and 03fh		;6043   ; Indexa tabla_umbral_swing con el resto (0-63) y sigue en 0x5915
	ld b,000h		;6045
	ld c,a			;6047
	ld hl,06062h		;6048
	add hl,bc			;604b
	ld a,(hl)			;604c
	pop hl			;604d
	call escala_los_dos_bytes		;604e
coordenada_devuelve:		; Recupera registros y sale
	pop af			;6051
	pop bc			;6052
	bit 7,a		;6053
	ret z			;6055
niega_de:		; Cero menos DE
	push af			;6056   ; Calcula la negacion de DE (0-DE)
	push de			;6057
	ex de,hl			;6058
	ld hl,00000h		;6059
	or a			;605c
	sbc hl,de		;605d
	pop de			;605f
	pop af			;6060
	ret			;6061

; ----------------------------------------------------------------------
; DATOS tabla_umbral_swing: 64 bytes, tabla de umbrales usada en 0x5FE4
;   (busqueda lineal) y 0x6003 (indexada directa, and 03fh)
;   0x6062..0x60a2  (64 bytes)
DATA_tabla_umbral_swing:
	defb 000h,006h,00ch,012h,019h,01fh,025h,02bh	; 6062  ......%+
	defb 031h,038h,03eh,044h,04ah,050h,056h,05ch	; 606a  18>DJPV\
	defb 061h,067h,06dh,073h,078h,07eh,083h,088h	; 6072  agmsx~..
	defb 08eh,093h,098h,09dh,0a2h,0a7h,0abh,0b0h	; 607a  ........
	defb 0b5h,0b9h,0bdh,0c1h,0c5h,0c9h,0cdh,0d1h	; 6082  ........
	defb 0d4h,0d8h,0dbh,0deh,0e1h,0e4h,0e7h,0eah	; 608a  ........
	defb 0ech,0eeh,0f1h,0f3h,0f4h,0f6h,0f8h,0f9h	; 6092  ........
	defb 0fbh,0fch,0fdh,0feh,0feh,0ffh,0ffh,0ffh	; 609a  ........

; ======================================================================
; CODIGO 0x60a2..0x60b6  (20 bytes)
; ======================================================================


carga_los_sprites:		; Descomprime los diez sprites de 16x16 y los copia a la tabla de patrones de sprite del VDP, en VRAM 0x3800
	ld hl,060b6h		;60a2
	ld de,0e800h		;60a5
	push de			;60a8
	call descomprime		;60a9
	pop hl			;60ac
	ld de,03800h		;60ad
	ld bc,00140h		;60b0
	jp 0005ch		;60b3   ; BIOS LDIRVM - Block transfers to VRAM from memory

; ----------------------------------------------------------------------
; DATOS patrones_de_sprite: LOS SPRITES DE VERDAD, los del VDP: 0x60A2 los
;   descomprime (66 bytes fuente -> 320 de salida) y copia esos 320 bytes a
;   VRAM 0x3800, que con el registro 6 a 0x07 es la tabla de patrones de
;   sprite. Son DIEZ sprites de 16x16: la bola a cinco tamanos, para la
;   perspectiva, mas los marcadores
;   0x60b6..0x60f8  (66 bytes)
DATA_patrones_de_sprite:
	defb 040h,000h,0c0h,0ffh,01fh,000h,0c0h,0c0h,0ffh,01eh,000h,060h,0f0h,0f0h,060h,0ffh	; 60b6  @..........`..`.
	defb 01ch,000h,030h,078h,0fch,0fch,078h,030h,0ffh,022h,000h,018h,018h,03ch,03ch,07eh	; 60c6  ..0x..x0."...<<~
	defb 07eh,0ffh,002h,0ffh,0ffh,010h,000h,0ffh,020h,0ffh,0ffh,003h,000h,018h,018h,0ffh	; 60d6  ~....... .......
	defb 01ch,000h,03ch,07fh,07fh,03ch,0ffh,01bh,000h,0ffh,020h,000h,0a0h,040h,0a0h,0ffh	; 60e6  ..<..<.... ..@..
	defb 01dh,000h	; 60f6

; ======================================================================
; CODIGO 0x60f8..0x6299  (417 bytes)
; ======================================================================


procesa_un_objeto:		; Calcula la casilla del objeto y copia sus tres bytes de atributo
	push bc			;60f8   ; Procesa un objeto del hoyo: calcula su direccion (0x6277) y copia 3 bytes de atributo
	ld a,(hl)			;60f9
	inc hl			;60fa
	ex de,hl			;60fb
	call casilla_del_objeto		;60fc
	ld (hl),c			;60ff
	inc hl			;6100
	ex de,hl			;6101
	ld bc,00003h		;6102
	ldir		;6105
	pop bc			;6107
	djnz procesa_un_objeto		;6108   ; Repite para cada objeto del sub-bloque (djnz)
	ret			;610a
monta_los_objetos:		; Limpia el buffer de 0xE800 y recorre la lista de objetos del hoyo, uno a uno
	ld ix,0e069h		;610b   ; Limpia el buffer de terreno (0xE800-0xE9FF) y procesa la lista de objetos del hoyo (0x6289) uno a uno con 0x60F8
	ld (ix+000h),000h		;610f
	push hl			;6113
	ld hl,0e800h		;6114
	ld bc,00200h		;6117
limpia_el_buffer:		; Los 512 bytes a cero antes de empezar
	ld (hl),000h		;611a   ; Limpia el buffer de terreno antes de procesar la lista de objetos del hoyo
	inc hl			;611c
	dec bc			;611d
	ld a,b			;611e
	or c			;611f
	jr nz,limpia_el_buffer		;6120
	call lista_del_hoyo		;6122
	ld c,001h		;6125
	ld b,(hl)			;6127
	inc hl			;6128
recorre_los_sub_bloques:		; Cada sub-bloque empieza por su cuenta de objetos
	push bc			;6129
	ld b,(hl)			;612a   ; Cuenta de bytes del objeto actual, leida de la lista de objetos del hoyo
	inc hl			;612b
	call procesa_un_objeto		;612c   ; Cada objeto lo procesa 0x60F8/0x6277 (coordenadas/atributo del elemento del hoyo)
	pop bc			;612f
	inc c			;6130
	djnz recorre_los_sub_bloques		;6131
	ld a,(0e076h)		;6133
	or a			;6136
	jr z,objetos_extra		;6137
	ld de,(0e0b4h)		;6139   ; Comprueba si el hoyo actual coincide con el ultimo fotograma de 0x5E40; si es asi, procesa dos objetos extra
	ld b,e			;613d
	push bc			;613e
	call primer_tramo_del_hoyo		;613f
	ld a,b			;6142
	pop bc			;6143
	dec a			;6144
	cp d			;6145
	jr nz,objetos_extra		;6146
	dec c			;6148
	ld b,002h		;6149
	call procesa_un_objeto		;614b
objetos_extra:		; Dos objetos mas cuando el hoyo coincide con el ultimo cuadro
	pop hl			;614e
	push hl			;614f
	ld a,h			;6150   ; Convierte la posicion guardada en fila/columna de pantalla (desplazamientos de 3 bits, rrca x3)
	and 0f8h		;6151
	rrca			;6153
	rrca			;6154
	rrca			;6155
	cp 008h		;6156
	jr c,mira_la_franja_central		;6158   ; Si la fila esta fuera del rango normal, marca el bit de arbol o agua segun el umbral
	cp 014h		;615a
	set 3,(ix+000h)		;615c
	ld a,007h		;6160
	jr c,mira_la_franja_central		;6162
	set 2,(ix+000h)		;6164
	xor a			;6168
mira_la_franja_central:		; Comprueba si la columna cae en la calle o en el agua y marca los bits del elemento
	ld b,a			;6169   ; Comprueba si la columna cae en la franja central/agua y activa los bits correspondientes del elemento
	ld a,l			;616a
	and 0f8h		;616b
	cp 079h		;616d
	jr c,dobla_y_junta		;616f
	cp 0c8h		;6171
	set 0,(ix+000h)		;6173
	ld a,078h		;6177
	jr c,dobla_y_junta		;6179
	set 1,(ix+000h)		;617b   ; Si cae en la franja derecha, activa el otro bit y limpia A
	xor a			;617f
dobla_y_junta:		; Dobla el valor y lo mezcla con la mascara
	add a,a			;6180
	or b			;6181
	ld bc,00004h		;6182
sube_diez:		; Suma 0x10 y vuelve al bucle
	push af			;6185
lee_la_casilla:		; Convierte el tile en direccion y, si no esta vacia, sigue leyendo
	push af			;6186   ; Convierte el tile en direccion (0x6277); si no esta vacio, sigue leyendo
	call casilla_del_objeto		;6187
	ld a,(hl)			;618a
	or a			;618b
	jr nz,mezcla_el_nibble		;618c
	pop af			;618e
	ld b,0ffh		;618f
escribe_el_atributo:		; Deja C en el atributo; con el bit 2 puesto, cambia de estado
	ld (ix+000h),c		;6191   ; Escribe C en el atributo del elemento; si el bit 2 esta activo, pasa a otro estado
	bit 2,c		;6194
	jr z,mira_el_bit_tres		;6196
	inc a			;6198
	bit 3,a		;6199
	jr z,lee_la_casilla		;619b
	res 2,c		;619d
	set 3,c		;619f
	jr escribe_el_atributo		;61a1
mira_el_bit_tres:		; Con el bit 3 todavia puesto, sigue leyendo
	dec a			;61a3   ; Si el bit 3 del valor sigue activo, continua leyendo (0x6186)
	bit 3,a		;61a4
	jr z,lee_la_casilla		;61a6
	pop af			;61a8
	res 3,c		;61a9
	set 2,c		;61ab
	bit 1,c		;61ad
	jr nz,sube_diez_mas		;61af
	set 0,c		;61b1
	sub 010h		;61b3   ; Si no, ajusta los bits del elemento segun si cae antes o despues del limite (0x10)
	jr nc,sube_diez		;61b5
	res 0,c		;61b7
	set 1,c		;61b9
sube_diez_mas:		; El otro camino que suma 0x10
	add a,010h		;61bb
	jr sube_diez		;61bd
mezcla_el_nibble:		; Con el bit 0 de B, mete el nibble bajo de C en el atributo
	bit 0,b		;61bf   ; Si el bit 0 de B esta activo, mezcla el nibble bajo de C en el atributo del elemento (ix+0)
	jr z,lee_el_siguiente		;61c1
	push af			;61c3
	ld a,c			;61c4
	and 00fh		;61c5
	or (ix+000h)		;61c7
	ld (ix+000h),a		;61ca
	pop af			;61cd
lee_el_siguiente:		; Trae el byte siguiente y marca bits segun su signo
	pop bc			;61ce   ; Lee el siguiente byte de la lista y marca bits del elemento segun su signo
	pop bc			;61cf
	ld b,a			;61d0
	inc hl			;61d1
	ld a,(hl)			;61d2
	bit 7,a		;61d3
	jr z,mira_el_bit_seis		;61d5
	set 5,(ix+000h)		;61d7
mira_el_bit_seis:		; Uno de los dos bits de tipo
	bit 6,a		;61db
	jr z,mira_el_bit_cinco		;61dd
	set 7,(ix+000h)		;61df
mira_el_bit_cinco:		; Y el otro
	bit 5,a		;61e3
	jr z,separa_los_campos		;61e5
	set 6,(ix+000h)		;61e7
separa_los_campos:		; Reparte el byte en nibble, E y C
	ld (0e053h),a		;61eb   ; Guarda A y separa los siguientes bytes en D (nibble), E y C
	and 00fh		;61ee
	ld d,a			;61f0
	inc hl			;61f1
	ld e,(hl)			;61f2
	inc hl			;61f3
	ld c,(hl)			;61f4
	pop hl			;61f5
	push bc			;61f6
	ld bc,(0e053h)		;61f7   ; Calcula la posicion de columna final combinando los bytes leidos
	ld a,l			;61fb
	and 007h		;61fc
	bit 4,c		;61fe
	jr nz,ajusta_la_coordenada		;6200
	sub 008h		;6202
	neg		;6204
ajusta_la_coordenada:		; El bit 4 de C corrige antes de multiplicar
	ld l,a			;6206   ; Ajusta la coordenada segun el bit 4 de C antes de las multiplicaciones
	ld a,h			;6207
	and 007h		;6208
	bit 4,c		;620a
	jr z,posicion_del_elemento		;620c
	sub 008h		;620e
	neg		;6210
posicion_del_elemento:		; De su codigo -tipo y coordenada- saca donde va en pantalla, con dos multiplicaciones
	ld h,a			;6212   ; Calcula la posicion en pantalla de un elemento del hoyo a partir de su codigo (tipo+coordenada, dos multiplicaciones con 0x5F3B)
	ex de,hl			;6213
	add hl,hl			;6214
	add hl,hl			;6215
	add hl,hl			;6216
	ld a,h			;6217   ; Multiplica por 8 tras saturar a multiplo de 8 (columna del elemento)
	add a,a			;6218
	add a,a			;6219
	add a,a			;621a
	ld h,a			;621b
	pop bc			;621c
	push bc			;621d
	ex de,hl			;621e
	ld a,c			;621f
	and 00fh		;6220   ; Extrae el nibble bajo de C como coordenada Y del elemento
	push hl			;6222
	ld l,a			;6223
	call multiplica		;6224
	ld b,l			;6227
	pop hl			;6228
	ld a,c			;6229   ; Extrae el nibble alto de C como coordenada X
	and 0f0h		;622a
	rrca			;622c
	rrca			;622d
	rrca			;622e
	rrca			;622f
	ld h,a			;6230
	call multiplica		;6231
	ld h,b			;6234
	pop bc			;6235
	ld a,h			;6236   ; Combina las dos coordenadas calculadas con el desplazamiento de camara (E,D)
	add a,e			;6237
	ld h,a			;6238
	ld a,d			;6239
	add a,l			;623a
	ld l,a			;623b
	ld a,(ix+000h)		;623c   ; Segun el nibble bajo de (ix+0): si es cero no dibuja nada; si el bit 3 esta activo usa una paleta distinta
	and 00fh		;623f
	jr z,recorta_la_fila		;6241
	bit 3,a		;6243
	ld h,0a8h		;6245
	jr nz,cuadro_de_golpe_especial		;6247
	ld h,000h		;6249
cuadro_de_golpe_especial:		; Con acarreo, calcula el cuadro especial usando (0xE0B3)
	rrca			;624b   ; Si hay acarreo, calcula un fotograma de golpe especial usando (0xE0B3)
	jr nc,refleja_la_fila		;624c
	push bc			;624e
	ld bc,(0e0b3h)		;624f
	call primer_tramo_del_hoyo		;6253
	dec b			;6256
	dec b			;6257
	pop af			;6258
	ld l,040h		;6259
refleja_la_fila:		; Con el bit 7 de (0xE0A0), la fila pasa a ser 0xA8 menos ella
	ld a,(0e0a0h)		;625b   ; Si (0xE0A0) bit 7 esta activo, refleja la fila (0xA8-H)
	rlca			;625e
	jr nc,devuelve_la_fila		;625f
	ld a,0a8h		;6261
	sub h			;6263
	ld h,a			;6264
devuelve_la_fila:		; Deja el resultado en A
	ld a,b			;6265
	ret			;6266
recorta_la_fila:		; La fila se queda dentro del rango 0x20-0xE0
	call refleja_la_fila		;6267   ; Recorta la fila resultante al rango de pantalla valido (0x20-0xE0)
	ld a,h			;626a
	cp 020h		;626b
	jr c,fila_al_tope		;626d
	cp 0e0h		;626f
	jr c,devuelve_la_fila		;6271
fila_al_tope:		; El tope de arriba
	ld h,020h		;6273
	jr devuelve_la_fila		;6275
casilla_del_objeto:		; Del codigo de tile saca su sitio en el buffer: nibble bajo la columna, nibble alto la fila, por cuatro
	push af			;6277   ; Convierte un codigo de tile (0-255) en su direccion dentro del buffer de terreno 0xE800 (tile>>4 * 4 + base)
	push de			;6278
	rrca			;6279
	rrca			;627a
	rrca			;627b
	rrca			;627c
	ld l,a			;627d
	ld h,000h		;627e   ; Divide por 16 (rrca x4) y multiplica por 4 (add hl,hl x2): direccion del grupo de tiles
	add hl,hl			;6280
	add hl,hl			;6281
	ld de,0e800h		;6282
	add hl,de			;6285
	pop de			;6286
	pop af			;6287
	ret			;6288
lista_del_hoyo:		; Los 18 punteros de 0x6299, indexados por el hoyo: arboles, bunkers y demas
	ld hl,(0e0b4h)		;6289   ; Tabla de 18 punteros en 0x6299, indexada por (0xE0B4)-1: lista de objetos del hoyo actual (arboles, bunkers...)
	ld h,000h		;628c
	dec hl			;628e
	add hl,hl			;628f
	ld de,06299h		;6290
	add hl,de			;6293   ; Suma el indice al puntero base de la tabla y lee el puntero final de 16 bits
	ld e,(hl)			;6294
	inc hl			;6295
	ld d,(hl)			;6296
	ex de,hl			;6297
	ret			;6298

; ----------------------------------------------------------------------
; DATOS tabla_objetos_hoyo: 18 punteros de 16 bits a listas de objetos por
;   hoyo, indexados por (0xE0B4)-1 desde 0x6289 (0x6290)
;   0x6299..0x62bf  (38 bytes)
DATA_tabla_objetos_hoyo:
	defw 062bfh,06764h,0637bh,06699h,06413h,06892h	; 6299
	defw 06413h,065dah,064efh,067d6h,06699h,0637bh	; 62a5
	defw 064efh,06764h,065dah,06892h,067d6h,06969h	; 62b1
	defw 018f8h	; 62bd

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_01: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x62bf..0x637b  (188 bytes)
DATA_objetos_hoyo_01:
	defb 005h,009h,002h,001h,0e4h,017h,003h,001h,0ebh,017h,012h,001h,0e4h,017h,013h,001h	; 62bf  ................
	defb 0ebh,017h,023h,001h,0e7h,017h,024h,001h,0eeh,017h,032h,001h,0c4h,013h,033h,001h	; 62cf  ..#...$...2...3.
	defb 0c7h,017h,034h,001h,0ceh,017h,00eh,042h,002h,004h,026h,043h,002h,00ah,025h,044h	; 62df  ..4....B..&C..%D
	defb 002h,010h,024h,052h,001h,0c4h,026h,053h,001h,0cah,027h,054h,001h,0f2h,012h,062h	; 62ef  ..$R..&S..'T...b
	defb 001h,084h,023h,063h,001h,088h,024h,064h,001h,08ch,024h,065h,001h,090h,025h,072h	; 62ff  ..#c..$d..$e..%r
	defb 001h,064h,013h,073h,001h,067h,014h,074h,001h,06bh,015h,075h,001h,070h,015h,00ch	; 630f  .d.s.g.t.k.u.p..
	defb 082h,002h,024h,012h,083h,002h,026h,015h,084h,002h,02bh,015h,085h,002h,020h,015h	; 631f  ..$...&...+... .
	defb 092h,001h,0e4h,022h,093h,001h,0e6h,025h,094h,002h,00bh,015h,095h,002h,010h,015h	; 632f  ..."...%........
	defb 0a2h,081h,084h,022h,0a3h,081h,086h,025h,0a4h,081h,08bh,025h,0a5h,081h,090h,025h	; 633f  ..."...%...%...%
	defb 006h,0b2h,021h,0c4h,052h,0b3h,021h,0c6h,055h,0b4h,021h,0cbh,055h,0b5h,021h,0d0h	; 634f  ..!.R.!.U.!.U.!.
	defb 055h,0c3h,041h,044h,047h,0c4h,041h,04bh,047h,002h,0d3h,031h,0ebh,047h,0d4h,031h	; 635f  U.ADG.AKG..1.G.1
	defb 0e4h,046h,0c3h,051h,0aah,015h,0c4h,051h,0a5h,016h,0fdh,01eh	; 636f  .F.Q...Q....

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_02: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x637b..0x6413  (152 bytes)
DATA_objetos_hoyo_02:
	defb 005h,006h,012h,001h,0e4h,013h,013h,001h,0e7h,017h,013h,001h,0eeh,017h,022h,001h	; 637b  ..............".
	defb 0c4h,013h,023h,001h,0c7h,017h,024h,001h,0ceh,017h,00bh,032h,002h,004h,028h,033h	; 638b  ..#...$....2..(3
	defb 002h,00ch,028h,042h,001h,0c4h,026h,043h,001h,0eah,018h,052h,001h,0a4h,015h,053h	; 639b  ..(B..&C...R...S
	defb 001h,0a9h,015h,054h,001h,0d0h,025h,061h,001h,064h,024h,062h,001h,068h,024h,063h	; 63ab  ...T..%a.d$b.h$c
	defb 081h,06bh,036h,064h,081h,071h,024h,006h,072h,001h,084h,024h,073h,081h,088h,028h	; 63bb  .k6d.q$.r..$s..(
	defb 074h,081h,090h,025h,082h,001h,064h,015h,083h,001h,069h,016h,084h,001h,06fh,016h	; 63cb  t..%..d...i...o.
	defb 008h,092h,021h,0cah,032h,093h,021h,0a6h,045h,094h,021h,08bh,036h,095h,021h,091h	; 63db  ..!.2.!.E.!.6.!.
	defb 034h,0a2h,021h,0cah,012h,0a3h,021h,0a6h,015h,0a4h,041h,02ah,037h,0a5h,041h,011h	; 63eb  4.!...!...A*7.A.
	defb 044h,003h,0b3h,032h,00fh,034h,0b4h,032h,008h,036h,0b5h,032h,004h,034h,0a4h,051h	; 63fb  D..2.4.2.6.2.4.Q
	defb 0c8h,016h,0a5h,051h,0c3h,016h,0f8h,018h	; 640b  ...Q....

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_03: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x6413..0x64ef  (220 bytes)
DATA_objetos_hoyo_03:
	defb 005h,00fh,003h,001h,0e4h,018h,004h,001h,0ech,018h,013h,001h,0eah,016h,014h,001h	; 6413  ................
	defb 0eah,016h,015h,001h,0f0h,015h,024h,001h,0c4h,016h,025h,001h,0cah,016h,026h,001h	; 6423  ......$...%...&.
	defb 0d0h,015h,034h,001h,0a4h,016h,035h,001h,0aah,016h,036h,001h,0b0h,015h,043h,001h	; 6433  ..4...5...6...C.
	defb 084h,013h,044h,001h,087h,014h,045h,001h,08bh,015h,046h,001h,090h,013h,00eh,053h	; 6443  ..D...E...F....S
	defb 001h,0a4h,033h,054h,001h,0a7h,048h,055h,001h,0afh,047h,062h,001h,085h,022h,063h	; 6453  ..3T..HU..Gb.."c
	defb 001h,087h,024h,064h,001h,08bh,025h,065h,001h,08fh,026h,071h,001h,086h,014h,072h	; 6463  ..$d..%e..&q...r
	defb 001h,08ah,015h,073h,001h,090h,014h,080h,001h,064h,014h,081h,001h,068h,014h,082h	; 6473  ...s.....d...h..
	defb 001h,06ch,013h,083h,001h,06fh,014h,007h,091h,001h,0e4h,031h,092h,001h,0e5h,037h	; 6483  .l...o.....1...7
	defb 093h,001h,0ech,038h,0a1h,001h,084h,021h,0a2h,001h,065h,044h,0a3h,001h,069h,033h	; 6493  ...8...!..eD..i3
	defb 0a4h,001h,06ch,028h,00dh,0b1h,001h,0e4h,033h,0b2h,001h,0e7h,034h,0b3h,001h,0ebh	; 64a3  ..l(....3...4...
	defb 034h,0b4h,001h,0efh,033h,0b5h,001h,0f2h,033h,0c3h,021h,064h,043h,0c4h,021h,067h	; 64b3  4...3...3.!dC.!g
	defb 045h,0c5h,021h,06ch,045h,0c6h,021h,071h,044h,0d3h,021h,064h,013h,0d4h,041h,006h	; 64c3  E.!lE.!qD.!d..A.
	defb 036h,0d5h,041h,00dh,035h,0d6h,021h,071h,014h,002h,0e4h,032h,00bh,027h,0e5h,032h	; 64d3  6.A.5.!q...2.'.2
	defb 004h,027h,0d4h,051h,0aah,035h,0d5h,051h,0a6h,035h,000h,010h	; 64e3  .'.Q.5.Q.5..

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_04: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x64ef..0x65da  (235 bytes)
DATA_objetos_hoyo_04:
	defb 004h,018h,011h,001h,0e4h,012h,012h,001h,0e6h,023h,013h,001h,0c9h,023h,014h,001h	; 64ef  .........#...#..
	defb 0cch,023h,015h,001h,0cfh,023h,021h,081h,0e4h,012h,022h,081h,0c5h,014h,023h,001h	; 64ff  .#...#!..."...#.
	defb 0a9h,013h,024h,001h,0ach,013h,025h,001h,0afh,012h,026h,001h,0b1h,014h,031h,081h	; 650f  ..$...%...&...1.
	defb 080h,035h,032h,081h,085h,024h,033h,081h,089h,013h,034h,001h,08ch,012h,035h,001h	; 651f  .52..$3...4...5.
	defb 08eh,013h,036h,001h,091h,013h,041h,081h,080h,023h,042h,081h,083h,023h,043h,081h	; 652f  ..6...A..#B..#C.
	defb 086h,023h,044h,081h,069h,023h,045h,001h,06ch,014h,046h,001h,070h,013h,047h,001h	; 653f  .#D.i#E.l.F.p.G.
	defb 073h,011h,014h,053h,082h,005h,021h,054h,082h,006h,012h,055h,082h,007h,027h,056h	; 654f  s..S..!T...U..'V
	defb 002h,00eh,023h,057h,082h,010h,023h,063h,081h,0e4h,022h,064h,081h,0e6h,023h,065h	; 655f  ..#W..#c.."d..#e
	defb 081h,0c9h,035h,066h,001h,0edh,048h,072h,001h,084h,012h,073h,081h,086h,024h,074h	; 656f  ..5f..Hr...s..$t
	defb 081h,0a8h,023h,075h,081h,0abh,024h,076h,001h,08fh,034h,082h,001h,024h,023h,083h	; 657f  ..#u..$v..4..$#.
	defb 001h,046h,023h,084h,081h,049h,033h,085h,081h,04bh,044h,086h,001h,04eh,036h,0a5h	; 658f  .F#..I3..KD..N6.
	defb 001h,04fh,013h,009h,092h,002h,004h,025h,093h,002h,009h,026h,094h,002h,00fh,026h	; 659f  .O.....%...&...&
	defb 0a2h,021h,0a4h,035h,0a3h,021h,0a9h,036h,0a4h,021h,090h,045h,0b2h,041h,045h,026h	; 65af  .!.5.!.6.!.E.AE&
	defb 0b3h,041h,02ch,036h,0b4h,021h,08fh,011h,002h,0c2h,032h,00ch,028h,0c3h,032h,004h	; 65bf  .A,6.!....2.(.2.
	defb 028h,0b2h,051h,08ah,044h,0b3h,051h,086h,045h,0f0h,018h	; 65cf  (.Q.D.Q.E..

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_05: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x65da..0x6699  (191 bytes)
DATA_objetos_hoyo_05:
	defb 004h,012h,002h,081h,0cbh,012h,003h,081h,0cdh,012h,004h,081h,0ceh,012h,011h,001h	; 65da  ................
	defb 0a7h,022h,012h,081h,0abh,021h,013h,081h,0cch,012h,014h,081h,0cdh,012h,015h,081h	; 65ea  ."...!..........
	defb 0aeh,024h,021h,081h,088h,013h,022h,081h,08bh,012h,023h,081h,08dh,021h,024h,081h	; 65fa  .$!..."...#..!$.
	defb 08eh,011h,025h,081h,08fh,011h,031h,081h,088h,013h,032h,001h,08ch,011h,033h,001h	; 660a  ..%...1...2...3.
	defb 08dh,011h,034h,001h,08dh,011h,035h,001h,08dh,011h,00dh,042h,082h,000h,027h,043h	; 661a  ..4...5....B..'C
	defb 082h,028h,013h,044h,002h,02bh,014h,045h,002h,02fh,014h,050h,081h,0e0h,024h,051h	; 662a  .(.D.+.E./.P..$Q
	defb 081h,0e4h,033h,052h,081h,0e7h,022h,053h,082h,009h,011h,054h,081h,0e9h,033h,055h	; 663a  ..3R.."S...T..3U
	defb 082h,00eh,036h,063h,001h,0cbh,023h,064h,001h,0aeh,023h,065h,001h,0b1h,024h,00bh	; 664a  ..6c..#d..#e..$.
	defb 061h,002h,004h,026h,062h,002h,00ah,023h,070h,021h,0c4h,011h,071h,021h,0c5h,025h	; 665a  a..&b..#p!..q!.%
	defb 072h,021h,0cah,022h,073h,021h,0ech,013h,074h,001h,0f0h,012h,080h,021h,084h,011h	; 666a  r!."s!..t....!..
	defb 081h,041h,044h,015h,082h,041h,049h,015h,083h,001h,0b0h,011h,002h,091h,031h,0cah	; 667a  .AD..AI.......1.
	defb 015h,092h,031h,0c4h,016h,081h,051h,08ah,023h,082h,051h,086h,024h,002h,00ah	; 668a  ..1...Q.#.Q.$..

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_06: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x6699..0x6764  (203 bytes)
DATA_objetos_hoyo_06:
	defb 004h,006h,010h,001h,0e4h,015h,011h,001h,0e9h,015h,012h,001h,0efh,016h,020h,001h	; 6699  .............. .
	defb 0c4h,026h,021h,001h,0c9h,026h,022h,001h,0cfh,026h,016h,031h,002h,024h,014h,032h	; 66a9  .&!..&"..&.1.$.2
	defb 002h,028h,014h,033h,002h,029h,013h,034h,002h,02ch,018h,041h,001h,0e4h,023h,042h	; 66b9  .(.3.).4.,.A..#B
	defb 001h,0e6h,023h,043h,001h,0e8h,023h,044h,001h,0ech,028h,051h,001h,0a4h,023h,052h	; 66c9  ..#C..#D..(Q..#R
	defb 001h,0a6h,023h,053h,001h,0a7h,033h,054h,001h,0abh,023h,055h,001h,0afh,036h,061h	; 66d9  ..#S..3T..#U..6a
	defb 001h,064h,033h,062h,001h,066h,033h,063h,001h,068h,034h,064h,001h,08bh,023h,065h	; 66e9  .d3b.f3c.h4d..#e
	defb 001h,08bh,037h,072h,081h,044h,023h,073h,001h,047h,024h,074h,001h,04bh,024h,075h	; 66f9  ..7r.D#s.G$t.K$u
	defb 001h,050h,024h,00dh,082h,082h,004h,022h,083h,082h,006h,025h,084h,002h,00bh,025h	; 6709  .P$...."...%...%
	defb 085h,002h,010h,025h,092h,081h,0c4h,033h,093h,081h,0c8h,025h,094h,001h,0cch,035h	; 6719  ...%...3...%...5
	defb 095h,001h,0d1h,024h,0a2h,081h,064h,033h,0a3h,081h,067h,044h,0a4h,081h,06dh,002h	; 6729  ...$..d3..gD..m.
	defb 0a5h,001h,070h,023h,0a6h,001h,072h,023h,008h,0b2h,081h,0e4h,044h,0b3h,081h,0e8h	; 6739  ..p#..r#....D...
	defb 046h,0b4h,001h,0efh,046h,0c2h,021h,0a4h,035h,0c3h,021h,0a9h,038h,0c4h,021h,0b2h	; 6749  F...F.!.5.!.8.!.
	defb 023h,0d2h,041h,024h,027h,0d3h,041h,02bh,026h,0f2h,020h	; 6759  #.A$'.A+&. 

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_07: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x6764..0x67d6  (114 bytes)
DATA_objetos_hoyo_07:
	defb 003h,004h,042h,081h,086h,023h,043h,081h,089h,023h,044h,081h,08ch,023h,045h,081h	; 6764  ..B..#C..#D..#E.
	defb 08fh,023h,013h,052h,002h,044h,013h,053h,002h,048h,015h,054h,002h,02dh,016h,062h	; 6774  .#.R.D.S.H.T.-.b
	defb 001h,0e4h,012h,063h,021h,0c6h,048h,064h,021h,0eeh,045h,065h,081h,0d4h,011h,072h	; 6784  ...c!.Hd!.Ee...r
	defb 021h,0a5h,011h,073h,041h,066h,017h,074h,041h,04dh,033h,075h,021h,0aeh,043h,092h	; 6794  !..sAf.tAM3u!.C.
	defb 080h,0e6h,002h,093h,080h,0e8h,002h,094h,080h,0eah,002h,095h,080h,0ech,002h,0a2h	; 67a4  ................
	defb 080h,0e6h,002h,0a3h,080h,0e8h,002h,0a4h,080h,0eah,002h,0a5h,080h,0ech,002h,002h	; 67b4  ................
	defb 083h,032h,008h,028h,084h,032h,004h,023h,073h,051h,0a7h,036h,074h,051h,0c4h,014h	; 67c4  .2.(.2.#sQ.6tQ..
	defb 0f8h,038h	; 67d4

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_08: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x67d6..0x6892  (188 bytes)
DATA_objetos_hoyo_08:
	defb 005h,002h,012h,001h,0c7h,028h,013h,001h,0adh,035h,010h,022h,002h,00ch,026h,031h	; 67d6  .....(...5."..&1
	defb 001h,0e4h,037h,032h,001h,0ebh,028h,041h,001h,0a5h,034h,042h,001h,0a9h,033h,043h	; 67e6  ..72..(A..4B..3C
	defb 001h,0ach,033h,051h,081h,064h,033h,052h,081h,085h,025h,053h,001h,089h,034h,054h	; 67f6  ..3Q.d3R..%S..4T
	defb 001h,0abh,023h,055h,001h,0aeh,022h,056h,001h,0b0h,021h,063h,081h,085h,014h,064h	; 6806  ..#U.."V..!c...d
	defb 001h,0a8h,024h,065h,001h,0ach,024h,066h,001h,0b1h,034h,00ch,075h,002h,007h,026h	; 6816  ..$e..$f..4.u..&
	defb 076h,002h,00eh,027h,084h,081h,0a4h,023h,085h,001h,0eah,025h,086h,001h,0f0h,025h	; 6826  v..'...#...%...%
	defb 094h,001h,086h,034h,095h,001h,08bh,034h,096h,001h,0b0h,025h,0a3h,001h,066h,024h	; 6836  ...4...4...%..f$
	defb 0a4h,001h,08bh,025h,0a5h,001h,070h,035h,0c4h,001h,050h,022h,00bh,0b1h,002h,004h	; 6846  ...%..p5..P"....
	defb 013h,0b2h,002h,007h,016h,0b3h,002h,00dh,013h,0c0h,021h,0a4h,014h,0c1h,021h,0a5h	; 6856  ..........!...!.
	defb 034h,0c2h,021h,0abh,035h,0c3h,001h,0b0h,033h,0d0h,021h,084h,011h,0d1h,041h,023h	; 6866  4.!.5...3.!...A#
	defb 023h,0d2h,041h,025h,028h,0d3h,021h,090h,011h,002h,0e1h,032h,00eh,023h,0e2h,032h	; 6876  #.A%(.!....2.#.2
	defb 007h,027h,0d1h,051h,0cfh,011h,0d2h,051h,0a9h,036h,0f8h,008h	; 6886  .'.Q...Q.6..

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_09: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x6892..0x6969  (215 bytes)
DATA_objetos_hoyo_09:
	defb 004h,011h,001h,001h,0e4h,013h,002h,001h,0e7h,017h,003h,001h,0eeh,017h,011h,001h	; 6892  ................
	defb 0e4h,013h,012h,001h,0e7h,015h,013h,001h,0ech,015h,014h,001h,0f1h,014h,021h,001h	; 68a2  ..............!.
	defb 0e4h,013h,022h,001h,0e7h,015h,023h,001h,0ech,015h,024h,001h,0f1h,014h,033h,001h	; 68b2  .."...#...$...3.
	defb 0c4h,013h,034h,001h,0c7h,017h,035h,001h,0ceh,017h,043h,001h,0aeh,013h,044h,001h	; 68c2  ..4...5...C...D.
	defb 0a7h,017h,045h,001h,0aeh,017h,010h,053h,002h,044h,013h,054h,002h,044h,013h,055h	; 68d2  ..E....S.D.T.D.U
	defb 002h,047h,017h,056h,002h,02eh,017h,063h,002h,004h,023h,064h,002h,007h,028h,065h	; 68e2  .G.V...c..#d..(e
	defb 002h,00fh,022h,066h,002h,011h,022h,073h,001h,0c4h,025h,074h,001h,0c9h,026h,075h	; 68f2  .."f.."s..%t..&u
	defb 001h,0cfh,022h,076h,001h,0d1h,022h,083h,001h,089h,011h,084h,001h,0a9h,013h,085h	; 6902  .."v..".........
	defb 001h,08fh,022h,086h,001h,091h,022h,00bh,093h,002h,024h,013h,094h,002h,029h,015h	; 6912  .."..."...$...).
	defb 095h,002h,02eh,016h,0a0h,021h,084h,051h,0a1h,021h,085h,053h,0a2h,021h,088h,057h	; 6922  .....!.Q.!.S.!.W
	defb 0a3h,021h,08fh,053h,0a4h,021h,092h,053h,0b1h,041h,023h,036h,0b2h,041h,029h,037h	; 6932  .!.S.!.S.A#6.A)7
	defb 0b3h,021h,070h,022h,006h,0c0h,031h,0f4h,014h,0c1h,032h,00bh,014h,0c2h,012h,005h	; 6942  .!p"..1...2.....
	defb 011h,0c3h,012h,004h,011h,0d2h,012h,027h,012h,0d3h,012h,024h,013h,0b1h,051h,0b0h	; 6952  .......'...$..Q.
	defb 012h,0b2h,051h,08ah,037h,000h,018h	; 6962

; ----------------------------------------------------------------------
; DATOS objetos_hoyo_10: Lista de objetos del hoyo, consumida por
;   0x60F8/0x6277 (0x610B); limite tomado de la tabla de punteros, formato
;   interno sin cerrar del todo
;   0x6969..0x6a2b  (194 bytes)
DATA_objetos_hoyo_10:
	defb 005h,009h,002h,002h,004h,027h,003h,002h,00bh,027h,012h,081h,0c5h,016h,013h,081h	; 6969  .....'...'......
	defb 0cbh,012h,014h,081h,0d0h,011h,022h,081h,0a5h,011h,023h,081h,0a6h,011h,024h,001h	; 6979  ......"...#...$.
	defb 0adh,011h,025h,001h,0aeh,012h,00eh,032h,002h,004h,012h,033h,002h,005h,023h,034h	; 6989  ..%....2...3..#4
	defb 002h,008h,023h,035h,002h,00bh,024h,041h,001h,0e4h,011h,042h,001h,0e5h,011h,043h	; 6999  ..#5..$A...B...C
	defb 001h,0e6h,012h,044h,001h,0e8h,013h,045h,081h,0ech,012h,051h,001h,0c4h,013h,052h	; 69a9  ...D...E...Q...R
	defb 001h,0c7h,013h,053h,081h,0cah,011h,054h,081h,0cbh,011h,055h,081h,0cch,013h,00bh	; 69b9  ...S...T...U....
	defb 061h,001h,0c4h,013h,062h,001h,0e5h,033h,063h,081h,0eah,013h,064h,082h,010h,022h	; 69c9  a...b..3c...d.."
	defb 072h,081h,084h,013h,073h,081h,087h,011h,074h,081h,088h,011h,082h,081h,064h,013h	; 69d9  r...s...t.....d.
	defb 083h,081h,087h,013h,084h,081h,0aah,024h,085h,001h,08eh,013h,009h,093h,081h,0e4h	; 69e9  .......$........
	defb 023h,094h,082h,005h,028h,095h,002h,00fh,012h,0a2h,081h,0a4h,011h,0a3h,021h,065h	; 69f9  #...(.........!e
	defb 022h,0a4h,021h,067h,024h,0a5h,021h,06bh,024h,0b4h,041h,027h,016h,0b5h,041h,02ch	; 6a09  ".!g$.!k$.A'..A,
	defb 015h,002h,0c4h,032h,04ch,013h,0c5h,032h,044h,013h,0b4h,052h,009h,015h,0b5h,052h	; 6a19  ...2L..2D..R...R
	defb 005h,015h	; 6a29

; ----------------------------------------------------------------------
; DATOS tabla_vistas_del_campo: 98 punteros de 16 bits a los MAPAS DE LA VISTA
;   en perspectiva, NO a cuadros de un golfista. Van en dieciocho grupos, uno
;   por hoyo, y tabla_tramos_por_hoyo (0x5E54) dice cuantos caen en cada
;   grupo: el primero del grupo son 105 bytes (21x5, el cielo) y los demas 294
;   (21x14, el suelo de cada tramo). 0x5B17 y 0x5B27 los descomprimen SEGUIDOS
;   en 0xEA00 y 0xEA69, que es 0xEA00+105, y juntos hacen 399 bytes = 19 filas
;   de 21 columnas
;   0x6a2b..0x6aef  (196 bytes)
DATA_tabla_vistas_del_campo:
	defw 06aefh,06b20h,06bc3h,06c6bh,06d12h,06d8ch	; 6a2b
	defw 07d8dh,07dcbh,07eb1h,07f69h,06e29h,06e64h	; 6a37
	defw 06f19h,06fc5h,07064h,070e9h,07b25h,07b53h	; 6a43
	defw 07bf6h,07c8bh,07d29h,07d8dh,0718ah,071bbh	; 6a4f
	defw 0727fh,07339h,073e8h,07471h,0839bh,083d0h	; 6a5b
	defw 08473h,0854bh,085c9h,0718ah,071bbh,0727fh	; 6a67
	defw 07339h,073e8h,07471h,077deh,0780dh,078e8h	; 6a73
	defw 079adh,07a56h,07500h,0753bh,075f8h,076a8h	; 6a7f
	defw 07734h,0801bh,0804eh,08116h,081dch,08271h	; 6a8b
	defw 08302h,07b25h,07b53h,07bf6h,07c8bh,07d29h	; 6a97
	defw 07d8dh,06e29h,06e64h,06f19h,06fc5h,07064h	; 6aa3
	defw 070e9h,07500h,0753bh,075f8h,076a8h,07734h	; 6aaf
	defw 07d8dh,07dcbh,07eb1h,07f69h,077deh,0780dh	; 6abb
	defw 078e8h,079adh,07a56h,0839bh,083d0h,08473h	; 6ac7
	defw 0854bh,085c9h,0801bh,0804eh,08116h,081dch	; 6ad3
	defw 08271h,08302h,0867ch,086b1h,0879fh,08899h	; 6adf
	defw 0898ah,08a63h	; 6aeb  -> DATA_vista_hoyo_18_tramo_4 DATA_vista_hoyo_18_tramo_5

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   1. Comprimido con 0xA8FB (49 bytes fuente, 105 de salida).
;   0x6aef..0x6b20  (49 bytes)
DATA_vista_hoyo_01_cielo:
	defb 02fh,000h,0ffh,024h,014h,008h,009h,00ah,00bh,00ch,0ffh,004h,014h,010h,011h,012h	; 6aef  /..$............
	defb 013h,0ffh,008h,014h,023h,024h,00dh,00eh,00fh,0ffh,016h,014h,015h,016h,017h,018h	; 6aff  ....#$..........
	defb 019h,01ah,01bh,01ch,019h,01ah,01dh,01eh,015h,016h,017h,01fh,020h,021h,022h,01dh	; 6b0f  ............ !".
	defb 01eh	; 6b1f

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 1.
;   Comprimido con 0xA8FB (163 bytes fuente, 294 de salida).
;   0x6b20..0x6bc3  (163 bytes)
DATA_vista_hoyo_01_tramo_1:
	defb 0a1h,000h,0ffh,008h,003h,034h,0ffh,004h,003h,034h,034h,0ffh,00dh,003h,034h,035h	; 6b20  .....4...44...45
	defb 086h,087h,083h,085h,035h,035h,036h,038h,0ffh,008h,003h,036h,038h,003h,035h,02eh	; 6b30  ....5568...68.5.
	defb 032h,092h,093h,02ch,02bh,003h,037h,039h,003h,03ah,03dh,040h,03ah,03dh,040h,003h	; 6b40  2..,+.79.:=@:=@.
	defb 037h,039h,02eh,02fh,08ch,08dh,048h,049h,08eh,08fh,026h,079h,003h,003h,03bh,03eh	; 6b50  79./..HI..&y..;>
	defb 041h,03bh,03eh,041h,003h,078h,033h,07bh,0ffh,004h,02ch,090h,091h,02ch,07ah,029h	; 6b60  A;>A.x3{..,..,z)
	defb 027h,079h,03ch,03fh,042h,03ch,03fh,042h,078h,033h,07bh,043h,044h,08ah,0ffh,007h	; 6b70  'y<?B<?Bx3{CD...
	defb 02ch,07ah,02ah,028h,082h,003h,003h,078h,033h,02fh,07bh,088h,047h,047h,08bh,0ffh	; 6b80  ,z*(...x3/{.GG..
	defb 00ah,02ch,084h,028h,02dh,031h,07bh,0ffh,00bh,02ch,0a1h,0a2h,067h,0a3h,0a4h,02ch	; 6b90  .,.(-1{..,..g..,
	defb 02ch,07bh,0ffh,00ch,02ch,088h,0ffh,004h,047h,0a5h,0ffh,043h,02ch,004h,003h,006h	; 6ba0  ,{..,...G..C,...
	defb 0ffh,00ch,003h,006h,003h,005h,02ch,000h,001h,003h,003h,007h,0ffh,00ch,003h,007h	; 6bb0  ......,.........
	defb 003h,003h,002h	; 6bc0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 1.
;   Comprimido con 0xA8FB (168 bytes fuente, 294 de salida).
;   0x6bc3..0x6c6b  (168 bytes)
DATA_vista_hoyo_01_tramo_2:
	defb 0a6h,000h,0ffh,007h,003h,034h,0ffh,008h,003h,034h,0ffh,008h,003h,036h,038h,003h	; 6bc3  .....4...4...68.
	defb 035h,078h,02eh,04eh,0bbh,0bbh,04ch,04ah,079h,035h,036h,038h,003h,003h,03ah,03dh	; 6bd3  5x.N..LJy568..:=
	defb 040h,003h,037h,039h,02eh,04eh,032h,07bh,0a9h,0aah,0a6h,0a7h,0a8h,029h,027h,037h	; 6be3  @.79.N2{.....)'7
	defb 039h,03ah,03dh,03bh,03eh,041h,003h,078h,030h,051h,053h,025h,054h,048h,0ffh,003h	; 6bf3  9:=;>A.x0QS%TH..
	defb 061h,049h,08eh,097h,02bh,079h,03bh,03eh,03ch,03fh,042h,02dh,032h,08ch,05ah,025h	; 6c03  aI..+y;><?B-2.Z%
	defb 056h,058h,0ffh,003h,09bh,05dh,0ffh,003h,025h,096h,02bh,03ch,03fh,078h,02eh,02fh	; 6c13  VX...]..%.+<?x./
	defb 07bh,0ffh,00ah,02ch,090h,09bh,09bh,099h,07ah,029h,027h,031h,07bh,02ch,043h,0a2h	; 6c23  {..,....z)'1{,C.
	defb 047h,047h,09ch,0ffh,00ch,02ch,07ah,02ch,02ch,062h,0ffh,004h,047h,089h,0ffh,00fh	; 6c33  GG...,z,,b..G...
	defb 02ch,063h,064h,047h,047h,046h,045h,0ffh,01fh,02ch,043h,04fh,044h,0ffh,010h,02ch	; 6c43  ,cdGGFE..,COD..,
	defb 065h,09dh,0ffh,003h,047h,0ffh,00fh,02ch,062h,0ffh,005h,047h,0ffh,00fh,02ch,063h	; 6c53  e...G..,b..G..,c
	defb 064h,047h,047h,046h,045h,0ffh,015h,02ch	; 6c63  dGGFE..,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 1.
;   Comprimido con 0xA8FB (167 bytes fuente, 294 de salida).
;   0x6c6b..0x6d12  (167 bytes)
DATA_vista_hoyo_01_tramo_3:
	defb 0a5h,000h,0ffh,003h,003h,03ah,03dh,040h,036h,038h,0ffh,008h,003h,036h,038h,0ffh	; 6c6b  .....:=@68...68.
	defb 006h,003h,03bh,03eh,041h,037h,039h,02eh,04eh,0ffh,003h,0bbh,04ch,04ah,079h,037h	; 6c7b  ..;>A79.N...LJy7
	defb 039h,003h,03ah,03dh,0ffh,003h,003h,03ch,03fh,042h,086h,030h,07bh,0ffh,005h,02ch	; 6c8b  9.:=...<?B.0{..,
	defb 07ah,02ah,085h,079h,003h,03bh,03eh,0ffh,003h,003h,078h,02dh,02fh,07bh,068h,069h	; 6c9b  z*.y.;>...x-/{hi
	defb 003h,06ch,06dh,003h,06ah,06bh,02ch,07ah,029h,085h,03ch,03fh,003h,078h,02eh,032h	; 6cab  .lm.jk,z).<?.x.2
	defb 07bh,02ch,02ch,06eh,076h,0ffh,004h,003h,06fh,070h,0ffh,003h,02ch,07ah,02ah,027h	; 6cbb  {,,nv...op..,z*'
	defb 02dh,02fh,07bh,02ch,050h,051h,050h,05fh,0ffh,00ch,02ch,07ah,02ch,050h,051h,053h	; 6ccb  -/{,PQP_..,z,PQS
	defb 0ffh,004h,081h,054h,098h,05fh,02ch,02ch,050h,051h,052h,053h,081h,054h,05eh,05fh	; 6cdb  ...T._,,PQRS.T^_
	defb 055h,0ffh,00dh,025h,0ffh,00eh,081h,0ffh,00eh,025h,05bh,05ch,05dh,025h,025h,056h	; 6ceb  U..%.....%[\]%%V
	defb 059h,0ffh,004h,09bh,057h,05ah,0ffh,008h,081h,0ffh,00dh,02ch,05bh,05ch,05dh,05ah	; 6cfb  Y...WZ.....,[\]Z
	defb 081h,081h,056h,059h,0ffh,03fh,02ch	; 6d0b

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 1.
;   Comprimido con 0xA8FB (122 bytes fuente, 294 de salida).
;   0x6d12..0x6d8c  (122 bytes)
DATA_vista_hoyo_01_tramo_4:
	defb 078h,000h,003h,03ah,03dh,040h,003h,036h,038h,0ffh,009h,003h,036h,038h,03ah,03dh	; 6d12  x..:=@.68...68:=
	defb 040h,003h,03bh,03eh,041h,003h,037h,039h,0ffh,009h,003h,037h,039h,03bh,03eh,041h	; 6d22  @.;>A.79...79;>A
	defb 003h,03ch,03fh,042h,02eh,04dh,04eh,066h,0a0h,0ffh,005h,0b9h,094h,083h,04ch,04ah	; 6d32  .<?B.MNf......LJ
	defb 03ch,03fh,042h,078h,02dh,04eh,032h,07bh,0ffh,00ch,02ch,07ah,02ah,027h,079h,02fh	; 6d42  <?Bx-N2{..,z*'y/
	defb 07bh,0ffh,011h,02ch,07ah,029h,0ffh,005h,02ch,0b3h,073h,069h,0ffh,006h,003h,06ah	; 6d52  {..,z)..,.si...j
	defb 071h,0b2h,0ffh,003h,02ch,07ah,0ffh,004h,02ch,068h,0ffh,005h,003h,0b6h,0b7h,0ffh	; 6d62  q...,z..,h......
	defb 005h,003h,06bh,0ffh,007h,02ch,06eh,0ffh,00ch,003h,070h,0ffh,008h,02ch,0b5h,075h	; 6d72  ..k..,n...p..,.u
	defb 077h,0ffh,006h,003h,06fh,072h,0b4h,0ffh,06dh,02ch	; 6d82  w...or..m,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_01_tramo_5: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 5 del hoyo 1.
;   Comprimido con 0xA8FB (157 bytes fuente, 294 de salida).
;   0x6d8c..0x6e29  (157 bytes)
DATA_vista_hoyo_01_tramo_5:
	defb 09bh,000h,03ah,03dh,040h,036h,038h,034h,003h,003h,078h,02eh,04eh,04ch,04ah,079h	; 6d8c  ..:=@684..x.NLJy
	defb 003h,003h,034h,036h,038h,003h,003h,03bh,03eh,041h,037h,039h,035h,02eh,04eh,02fh	; 6d9c  ..468..;>A795.N/
	defb 07bh,09eh,09fh,07ah,029h,04ch,04ah,035h,037h,039h,036h,038h,03ch,03fh,042h,02eh	; 6dac  {..z)LJ57968<?B.
	defb 087h,032h,07bh,0ffh,008h,02ch,07ah,029h,04ch,04ah,037h,039h,078h,02dh,032h,07bh	; 6dbc  .2{..,z)LJ79x-2{
	defb 050h,051h,052h,05fh,0ffh,006h,02ch,050h,051h,05fh,02ch,07ah,02ah,028h,02fh,07bh	; 6dcc  PQR_..,PQ_,z*(/{
	defb 060h,055h,0ffh,004h,025h,054h,048h,09ah,09ah,049h,055h,0ffh,003h,025h,054h,098h	; 6ddc  `U..%TH..IU..%T.
	defb 02ch,07ah,02ch,02ch,095h,05ah,056h,058h,0ffh,006h,059h,058h,05ah,025h,025h,056h	; 6dec  ,z,,.ZVX..YXZ%%V
	defb 059h,099h,0ffh,01bh,02ch,0b0h,073h,0abh,069h,0ffh,005h,003h,06ah,0ach,071h,0adh	; 6dfc  Y...,.s.i...j.q.
	defb 0ffh,008h,02ch,0b1h,0ffh,005h,003h,0bah,0ffh,005h,003h,0aeh,0ffh,008h,02ch,074h	; 6e0c  ..,...........,t
	defb 075h,077h,076h,0ffh,005h,003h,06fh,0b8h,072h,0afh,0ffh,058h,02ch	; 6e1c  uwv...o.r..X,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   3; lo comparten tambien los hoyo.tramo 12.0. Comprimido con 0xA8FB (59
;   bytes fuente, 105 de salida).
;   0x6e29..0x6e64  (59 bytes)
DATA_vista_hoyo_03_cielo:
	defb 039h,000h,0ffh,016h,014h,008h,009h,00ah,00ch,0ffh,008h,014h,008h,00bh,009h,00ah	; 6e29  9...............
	defb 00ch,0ffh,004h,014h,023h,024h,00eh,00fh,014h,010h,013h,0ffh,005h,014h,023h,024h	; 6e39  ....#$........#$
	defb 00dh,00eh,00fh,0ffh,018h,014h,021h,022h,01dh,01eh,016h,01fh,020h,022h,01ch,01ah	; 6e49  ......!".... "..
	defb 01bh,01ch,020h,01ah,01dh,016h,017h,022h,01dh,01eh,015h	; 6e59  .. ...."...

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 3; lo
;   comparten tambien los hoyo.tramo 12.1. Comprimido con 0xA8FB (181 bytes
;   fuente, 294 de salida).
;   0x6e64..0x6f19  (181 bytes)
DATA_vista_hoyo_03_tramo_1:
	defb 0b3h,000h,0ffh,00ah,003h,034h,0ffh,013h,003h,034h,035h,08ch,02fh,02ah,04ch,04ah	; 6e64  .....4...45./*LJ
	defb 003h,034h,0ffh,008h,003h,036h,038h,003h,003h,035h,02dh,032h,090h,08fh,089h,08ah	; 6e74  .4...68..5-2....
	defb 088h,035h,036h,038h,0ffh,004h,003h,036h,038h,037h,039h,003h,078h,030h,07bh,051h	; 6e84  .568...6879.x0{Q
	defb 052h,049h,048h,098h,087h,003h,037h,039h,003h,03ah,03dh,040h,037h,039h,003h,078h	; 6e94  RIH...79.:=@79.x
	defb 02eh,031h,07bh,02ch,096h,05ah,0ffh,003h,025h,093h,097h,03ah,03dh,040h,03bh,03eh	; 6ea4  .1{,.Z..%..:=@;>
	defb 041h,0ffh,003h,003h,030h,07bh,043h,044h,0ffh,004h,02ch,05bh,095h,079h,003h,03bh	; 6eb4  A...0{CD..,[.y.;
	defb 03eh,041h,03ch,03fh,042h,003h,078h,033h,043h,0bbh,047h,0d5h,0ffh,005h,02ch,07ah	; 6ec4  >A<?B.x3C.G...,z
	defb 08dh,003h,03ch,03fh,042h,0ffh,003h,003h,078h,030h,07bh,063h,064h,047h,0b6h,0ffh	; 6ed4  ..<?B...x0{cdG..
	defb 006h,02ch,08eh,079h,0ffh,004h,003h,078h,02eh,031h,07bh,0ffh,00bh,02ch,07ah,02ah	; 6ee4  .,.y...x.1{..,z*
	defb 028h,04ah,079h,02eh,02fh,07bh,0ffh,010h,02ch,07ah,082h,07bh,0ffh,02bh,02ch,004h	; 6ef4  (Jy./{..,z.{.+,.
	defb 003h,006h,0ffh,00ch,003h,006h,003h,005h,02ch,000h,001h,003h,003h,007h,0ffh,00ch	; 6f04  ........,.......
	defb 003h,007h,003h,003h,002h	; 6f14

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 3; lo
;   comparten tambien los hoyo.tramo 12.2. Comprimido con 0xA8FB (172 bytes
;   fuente, 294 de salida).
;   0x6f19..0x6fc5  (172 bytes)
DATA_vista_hoyo_03_tramo_2:
	defb 0aah,000h,0ffh,009h,003h,034h,0ffh,005h,003h,034h,034h,0ffh,00ah,003h,036h,038h	; 6f19  .....4...44...68
	defb 003h,035h,04dh,04eh,04ch,04ah,079h,035h,035h,04dh,04eh,066h,04ch,0ffh,004h,003h	; 6f29  .5MNLJy55MNfL...
	defb 036h,038h,037h,039h,0d3h,032h,07bh,02ch,02ch,07ah,08bh,066h,0a1h,0a8h,0a9h,0a6h	; 6f39  6879.2{,,z.f....
	defb 0a7h,003h,03ah,03dh,040h,037h,039h,003h,003h,083h,0ffh,003h,02ch,062h,0bch,064h	; 6f49  ..:=@79.....,b.d
	defb 09eh,0ffh,005h,02ch,003h,03bh,03eh,041h,003h,003h,078h,02dh,032h,07bh,02ch,02ch	; 6f59  ...,.;>A..x-2{,,
	defb 0bdh,0ffh,008h,02ch,003h,03ch,03fh,042h,078h,02dh,031h,07bh,0ffh,004h,02ch,060h	; 6f69  ...,.<?Bx-1{..,`
	defb 09ch,055h,0ffh,004h,025h,09bh,048h,003h,003h,078h,02dh,031h,07bh,0ffh,005h,02ch	; 6f79  .U..%.H..x-1{..,
	defb 0c5h,0ffh,009h,025h,02eh,04eh,02fh,07bh,0ffh,008h,02ch,05bh,05ch,05dh,0ffh,006h	; 6f89  ...%.N/{..,[\]..
	defb 025h,07bh,02ch,0a2h,0a3h,047h,067h,0beh,0ffh,008h,02ch,05bh,0c9h,095h,0c6h,0c7h	; 6f99  %{,..Gg...,[....
	defb 094h,02ch,062h,0ffh,004h,047h,0c0h,0ffh,00ah,02ch,07ah,029h,027h,079h,02ch,063h	; 6fa9  .,b..G...,z)'y,c
	defb 0ffh,003h,047h,0bfh,0ffh,00dh,02ch,07ah,029h,0ffh,03fh,02ch	; 6fb9  ..G...,z).?,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 3; lo
;   comparten tambien los hoyo.tramo 12.3. Comprimido con 0xA8FB (159 bytes
;   fuente, 294 de salida).
;   0x6fc5..0x7064  (159 bytes)
DATA_vista_hoyo_03_tramo_3:
	defb 09dh,000h,0ffh,005h,003h,036h,038h,0ffh,004h,003h,036h,038h,0ffh,00bh,003h,036h	; 6fc5  .....68...68...6
	defb 038h,037h,039h,078h,0ffh,003h,003h,037h,039h,078h,02eh,084h,0ffh,005h,066h,03ah	; 6fd5  879x...79x....f:
	defb 03dh,040h,037h,039h,02eh,04eh,0ffh,004h,066h,08bh,066h,032h,0cah,0cch,0cbh,06ch	; 6fe5  =@79.N..f.f2...l
	defb 06dh,003h,06ah,03bh,03eh,041h,003h,0d4h,07bh,02ch,02ch,043h,04fh,04fh,0bah,0a4h	; 6ff5  m.j;>A..{,,COO..
	defb 02ch,06eh,076h,0ffh,004h,003h,06fh,03ch,03fh,042h,078h,033h,02ch,0c1h,062h,047h	; 7005  ,nv...o<?Bx3,.bG
	defb 047h,0c3h,0c4h,0a5h,0ffh,008h,02ch,04dh,04dh,04eh,031h,07bh,02ch,0c2h,0bch,085h	; 7015  G.....,MMN1{,...
	defb 086h,0ffh,00bh,02ch,07bh,0ffh,01dh,02ch,0b4h,050h,051h,052h,053h,0ffh,005h,025h	; 7025  ...,{..,.PQRS..%
	defb 054h,055h,0ffh,008h,02ch,0c8h,0ffh,00ch,025h,0ffh,008h,02ch,096h,0ffh,00ch,025h	; 7035  TU..,...%..,...%
	defb 0ffh,009h,02ch,05bh,05ch,05dh,0ffh,009h,025h,0ffh,00ch,02ch,05bh,05ch,05dh,0ffh	; 7045  ..,[\]..%..,[\].
	defb 006h,025h,0ffh,010h,02ch,05bh,05ch,05dh,025h,025h,0ffh,013h,02ch,05bh,05ch	; 7055  .%..,[\]%%..,[\

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 3; lo
;   comparten tambien los hoyo.tramo 12.4. Comprimido con 0xA8FB (133 bytes
;   fuente, 294 de salida).
;   0x7064..0x70e9  (133 bytes)
DATA_vista_hoyo_03_tramo_4:
	defb 083h,000h,0ffh,00ah,003h,036h,038h,036h,038h,0ffh,008h,003h,078h,02eh,04eh,02fh	; 7064  .....6868...x.N/
	defb 0ffh,003h,066h,081h,027h,037h,039h,037h,039h,02eh,04eh,02fh,0ffh,003h,066h,081h	; 7074  ..f.'7979.N/..f.
	defb 02dh,02fh,07bh,0ffh,020h,02ch,0cdh,0ceh,0ffh,003h,003h,0abh,071h,0ffh,00ah,02ch	; 7084  -/{. ,......q..,
	defb 068h,069h,0ffh,004h,003h,0b5h,0ffh,004h,003h,02ch,02ch,043h,0ffh,003h,04fh,044h	; 7094  hi.......,,C..OD
	defb 0ffh,003h,02ch,06eh,0ffh,00ah,003h,043h,0bbh,0ffh,005h,047h,0b7h,0ffh,003h,02ch	; 70a4  ..,n...C...G...,
	defb 074h,075h,077h,0ffh,005h,003h,0b1h,072h,0ffh,005h,047h,0c3h,0bch,045h,0ffh,00dh	; 70b4  tuw....r..G..E..
	defb 02ch,047h,047h,0bch,085h,086h,0ffh,010h,02ch,046h,045h,0ffh,03ah,02ch,050h,051h	; 70c4  ,GG.....,FE.:,PQ
	defb 052h,0ffh,00ch,02ch,050h,051h,052h,061h,061h,053h,0ffh,003h,025h,0ffh,00ah,02ch	; 70d4  R..,PQRaaS..%..,
	defb 060h,055h,0ffh,009h,025h	; 70e4

; ----------------------------------------------------------------------
; DATOS vista_hoyo_03_tramo_5: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 5 del hoyo 3; lo
;   comparten tambien los hoyo.tramo 12.5. Comprimido con 0xA8FB (161 bytes
;   fuente, 294 de salida).
;   0x70e9..0x718a  (161 bytes)
DATA_vista_hoyo_03_tramo_5:
	defb 09fh,000h,0ffh,007h,003h,034h,078h,04dh,04eh,04ch,04ah,079h,003h,034h,0ffh,006h	; 70e9  .....4xMNLJy.4..
	defb 003h,036h,038h,003h,036h,038h,003h,035h,030h,07bh,09fh,0a0h,07ah,029h,027h,035h	; 70f9  .68.68.50{..z)'5
	defb 003h,036h,038h,03ah,03dh,003h,037h,039h,003h,037h,039h,078h,033h,07bh,0ffh,005h	; 7109  .68:=.79.79x3{..
	defb 02ch,07ah,029h,027h,037h,039h,03bh,03eh,091h,092h,025h,099h,09ah,02dh,02fh,07bh	; 7119  ,z)'79;>..%..-/{
	defb 0ffh,008h,02ch,07ah,029h,027h,03ch,03fh,0ffh,005h,025h,054h,0d2h,0b2h,0b3h,0ffh	; 7129  ..,z)'<?..%T....
	defb 009h,02ch,07ah,029h,027h,0ffh,007h,025h,07ch,07dh,0ffh,00ah,02ch,043h,044h,0c9h	; 7139  .,z)'..%|}..,CD.
	defb 09dh,057h,058h,059h,07dh,0ffh,009h,02ch,043h,04fh,04fh,0bbh,047h,047h,0ffh,00fh	; 7149  .WXY}..,COO.GG..
	defb 02ch,0b8h,0b9h,0c4h,0c4h,046h,045h,02ch,02ch,0afh,073h,0aah,069h,0ffh,005h,003h	; 7159  ,....FE,,.s.i...
	defb 06ah,0abh,071h,0ach,0ffh,008h,02ch,0b0h,0ffh,005h,003h,0d1h,0ffh,005h,003h,0adh	; 7169  j.q...,.........
	defb 0ffh,008h,02ch,074h,075h,077h,076h,0ffh,005h,003h,0cfh,0d0h,072h,0aeh,0ffh,045h	; 7179  ..,tuwv.....r..E
	defb 02ch	; 7189

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   5; lo comparten tambien los hoyo.tramo 7.0. Comprimido con 0xA8FB (49
;   bytes fuente, 105 de salida).
;   0x718a..0x71bb  (49 bytes)
DATA_vista_hoyo_05_cielo:
	defb 02fh,000h,0ffh,019h,014h,010h,013h,010h,014h,014h,008h,00ch,00bh,009h,00ah,00ch	; 718a  /...............
	defb 0ffh,00fh,014h,023h,00eh,00eh,024h,00dh,00eh,0ffh,01bh,014h,01fh,020h,022h,01ch	; 719a  ...#..$...... ".
	defb 01ah,01fh,020h,022h,01dh,01eh,016h,01fh,020h,01ah,01dh,01eh,016h,01bh,022h,01dh	; 71aa  .. ".... .....".
	defb 01eh	; 71ba

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 5; lo
;   comparten tambien los hoyo.tramo 7.1. Comprimido con 0xA8FB (196 bytes
;   fuente, 294 de salida).
;   0x71bb..0x727f  (196 bytes)
DATA_vista_hoyo_05_tramo_1:
	defb 0c2h,000h,003h,003h,034h,003h,003h,078h,0ffh,003h,0ceh,0ffh,004h,003h,034h,0ffh	; 71bb  ....4..x......4.
	defb 008h,003h,034h,035h,04dh,085h,032h,02ch,08eh,08fh,08dh,003h,034h,003h,035h,003h	; 71cb  ..45M.2,....4.5.
	defb 003h,036h,038h,0ffh,004h,003h,035h,030h,07bh,0adh,095h,096h,090h,04bh,003h,003h	; 71db  .68...50{....K..
	defb 035h,003h,036h,038h,003h,037h,039h,0ffh,005h,003h,088h,089h,063h,0cah,02ch,02ch	; 71eb  5.68.79.....c.,,
	defb 07ah,02ah,028h,04ah,079h,037h,039h,036h,038h,003h,03ah,03dh,040h,03ah,03dh,040h	; 71fb  z*(Jy7968.:=@:=@
	defb 0c6h,08ah,087h,0c7h,0ffh,004h,02ch,07ah,02ah,083h,079h,037h,039h,003h,03bh,03eh	; 720b  ......,z*.y79.;>
	defb 041h,03bh,03eh,041h,036h,038h,0c6h,091h,0ffh,005h,02ch,0bch,0beh,029h,028h,081h	; 721b  A;>A68....,..)(.
	defb 079h,03ch,03fh,042h,03ch,03fh,042h,037h,039h,033h,07bh,0ffh,005h,02ch,0d3h,047h	; 722b  y<?B<?B793{..,.G
	defb 07eh,044h,07ah,02bh,079h,0ffh,003h,003h,084h,04dh,04eh,02fh,07bh,0ffh,005h,02ch	; 723b  ~Dz+y....MN/{..,
	defb 0b4h,047h,047h,0b7h,0aeh,02ch,07ah,02bh,079h,003h,02ch,07bh,0ffh,010h,02ch,07ah	; 724b  .GG..,z+y.,{..,z
	defb 026h,079h,0ffh,013h,02ch,07ah,02bh,0ffh,014h,02ch,07ah,0ffh,017h,02ch,004h,003h	; 725b  &y..,z+..,z..,..
	defb 006h,0ffh,00ch,003h,006h,003h,005h,02ch,000h,001h,003h,003h,007h,0ffh,00ch,003h	; 726b  .......,........
	defb 007h,003h,003h,002h	; 727b

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 5; lo
;   comparten tambien los hoyo.tramo 7.2. Comprimido con 0xA8FB (186 bytes
;   fuente, 294 de salida).
;   0x727f..0x7339  (186 bytes)
DATA_vista_hoyo_05_tramo_2:
	defb 0b8h,000h,003h,034h,034h,0ffh,007h,003h,0ffh,004h,0ceh,079h,003h,034h,0ffh,004h	; 727f  ...44......y.4..
	defb 003h,034h,035h,035h,078h,04dh,04eh,0c0h,02fh,066h,09ah,0ffh,004h,0a8h,02ah,083h	; 728f  .455xMN./f....*.
	defb 035h,036h,038h,003h,003h,035h,02eh,04eh,02fh,07bh,0ffh,003h,02ch,0adh,02ch,09eh	; 729f  568..5.N/{..,.,.
	defb 09fh,09bh,09ch,09dh,07ah,02bh,037h,039h,03ah,03dh,0b9h,07bh,062h,0abh,0ach,0ffh	; 72af  ....z+79:=.{b...
	defb 003h,02ch,0c9h,0cah,0ffh,004h,0c5h,0d0h,0d1h,08ch,003h,003h,03bh,03eh,0c6h,0cfh	; 72bf  .,..........;>..
	defb 063h,064h,047h,0bdh,0beh,02ch,02ch,090h,04ah,0ffh,008h,003h,03ch,03fh,03dh,040h	; 72cf  cdG..,,.J...<?=@
	defb 088h,087h,0c8h,0afh,0b0h,0ffh,003h,02ch,07ah,093h,082h,0c0h,0c0h,04ch,04ah,079h	; 72df  .......,z....LJy
	defb 0ffh,003h,003h,03eh,041h,003h,0c6h,088h,087h,0ffh,00ah,02ch,07ah,029h,027h,079h	; 72ef  ...>A......,z)'y
	defb 003h,03fh,042h,003h,003h,078h,033h,0ffh,00ch,02ch,07ah,02ah,028h,003h,078h,02eh	; 72ff  .?B..x3..,z*(.x.
	defb 04eh,02fh,07bh,0ffh,00ah,02ch,043h,04fh,04fh,0beh,07ah,02dh,032h,07bh,0ffh,00dh	; 730f  N/{..,COO.z-2{..
	defb 02ch,0aah,0ffh,003h,047h,07eh,0ffh,011h,02ch,0cbh,0ffh,003h,047h,0ffh,012h,02ch	; 731f  ,...G~..,...G..,
	defb 0c8h,0cdh,047h,0ffh,014h,02ch,0aah,0ffh,015h,02ch	; 732f  ..G..,...,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 5; lo
;   comparten tambien los hoyo.tramo 7.3. Comprimido con 0xA8FB (175 bytes
;   fuente, 294 de salida).
;   0x7339..0x73e8  (175 bytes)
DATA_vista_hoyo_05_tramo_3:
	defb 0adh,000h,0ffh,00bh,003h,034h,034h,0ffh,010h,003h,036h,038h,003h,035h,035h,04dh	; 7339  .....44...68.55M
	defb 04eh,02fh,0ffh,003h,066h,093h,082h,03dh,040h,03ah,03dh,040h,003h,036h,038h,037h	; 7349  N/..f..=@:=@.687
	defb 039h,078h,02eh,031h,07bh,068h,069h,003h,06ch,06dh,0bah,0bbh,03eh,041h,03bh,03eh	; 7359  9x.1{hi.lm..>A;>
	defb 041h,003h,037h,039h,078h,02eh,031h,0bch,0beh,02ch,06eh,076h,0ffh,004h,003h,06fh	; 7369  A.79x.1..,nv...o
	defb 03fh,042h,03ch,03fh,042h,04dh,04eh,02fh,066h,07bh,02ch,0aah,047h,0bdh,0beh,0ffh	; 7379  ?B<?BMN/f{,.G...
	defb 006h,02ch,04dh,04eh,02fh,066h,09ah,07bh,0ffh,006h,02ch,0b1h,0b2h,0b7h,0d2h,0ffh	; 7389  .,MN/f.{..,.....
	defb 005h,02ch,07bh,0ffh,011h,02ch,0c5h,0d0h,0d1h,043h,0bfh,0cch,0cch,0b5h,0ffh,007h	; 7399  .,{..,...C......
	defb 02ch,0d0h,0d1h,0ffh,003h,08bh,08ch,0ffh,003h,003h,0ffh,004h,047h,0b6h,0ffh,007h	; 73a9  ,...........G...
	defb 02ch,026h,04bh,0ffh,007h,003h,0ffh,004h,047h,086h,0ffh,008h,02ch,07ah,0a8h,02ah	; 73b9  ,&K.....G...,z.*
	defb 0c0h,04ch,04ah,04bh,003h,0ffh,004h,047h,0bdh,0beh,0ffh,00dh,02ch,07ah,02ah,0ffh	; 73c9  .LJK...G....,z*.
	defb 006h,047h,097h,0ffh,00eh,02ch,0b1h,0b3h,0ffh,003h,0afh,0b0h,0ffh,024h,02ch	; 73d9  .G...,.......$,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 5; lo
;   comparten tambien los hoyo.tramo 7.4. Comprimido con 0xA8FB (137 bytes
;   fuente, 294 de salida).
;   0x73e8..0x7471  (137 bytes)
DATA_vista_hoyo_05_tramo_4:
	defb 087h,000h,003h,03ah,03dh,040h,036h,038h,0ffh,00bh,003h,036h,038h,03ah,03dh,003h	; 73e8  ...:=@68...68:=.
	defb 03bh,03eh,041h,037h,039h,078h,04dh,04eh,0ffh,004h,0c0h,04ch,04ah,04bh,079h,037h	; 73f8  ;>A79xMN...LJKy7
	defb 039h,03bh,03eh,003h,03ch,03fh,042h,02eh,04eh,02fh,07bh,0ffh,007h,02ch,07ah,029h	; 7408  9;>.<?B.N/{..,z)
	defb 04ch,027h,03ch,03fh,003h,078h,02eh,02fh,07bh,02ch,0a5h,073h,0a0h,069h,0ffh,006h	; 7418  L'<?.x./{,.s.i..
	defb 003h,0bah,0bbh,07ah,02ah,028h,02eh,02fh,07bh,0ffh,003h,02ch,0a6h,0ffh,005h,003h	; 7428  ...z*(./{..,....
	defb 0b8h,0ffh,004h,003h,0a3h,0ffh,003h,02ch,07bh,0ffh,005h,02ch,074h,075h,077h,076h	; 7438  .......,{..,tuwv
	defb 0ffh,004h,003h,06fh,0a7h,072h,0a4h,0ffh,004h,02ch,043h,0ffh,003h,04fh,0beh,0ffh	; 7448  ...o.r...,C..O..
	defb 010h,02ch,0aah,0ffh,004h,047h,0bdh,04fh,0beh,0ffh,00eh,02ch,0b1h,0b3h,0afh,0b2h	; 7458  .,...G.O...,....
	defb 0b7h,047h,047h,0cch,0cch,0d2h,0ffh,072h,02ch	; 7468  .GG....r,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_05_tramo_5: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 5 del hoyo 5; lo
;   comparten tambien los hoyo.tramo 7.5. Comprimido con 0xA8FB (143 bytes
;   fuente, 294 de salida).
;   0x7471..0x7500  (143 bytes)
DATA_vista_hoyo_05_tramo_5:
	defb 08dh,000h,0ffh,006h,003h,034h,003h,0ffh,003h,0ceh,04dh,04eh,0c0h,04ch,027h,079h	; 7471  .....4....MN.L'y
	defb 036h,038h,03ah,03dh,003h,003h,036h,038h,036h,038h,035h,094h,0ffh,005h,02ch,098h	; 7481  68:=..68685...,.
	defb 099h,0c5h,08dh,037h,039h,03bh,03eh,003h,003h,037h,039h,037h,039h,0c6h,092h,0ffh	; 7491  ...79;>..7979...
	defb 005h,02ch,090h,04ah,04bh,079h,003h,003h,03ch,03fh,04dh,04eh,0ffh,005h,0c0h,032h	; 74a1  .,.JKy..<?MN...2
	defb 0ffh,007h,02ch,07ah,02ah,04ch,027h,079h,079h,07bh,0ffh,011h,02ch,07ah,07ah,029h	; 74b1  ..,z*L'yy{..,zz)
	defb 0ffh,00ch,02ch,043h,0ffh,003h,04fh,0beh,0ffh,010h,02ch,0aah,0ffh,004h,047h,0c2h	; 74c1  ..,C..O...,...G.
	defb 0ffh,012h,02ch,0b1h,0c3h,0c4h,0ffh,007h,02ch,0a5h,073h,0a0h,069h,0ffh,005h,003h	; 74d1  ..,.....,.s.i...
	defb 06ah,0a1h,071h,0a2h,0ffh,008h,02ch,0a6h,0ffh,005h,003h,0b8h,0ffh,005h,003h,0a3h	; 74e1  j.q...,.........
	defb 0ffh,008h,02ch,0a9h,0c1h,0ffh,007h,003h,06fh,0a7h,072h,0a4h,0ffh,043h,02ch	; 74f1  ..,.....o.r..C,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_09_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   9; lo comparten tambien los hoyo.tramo 13.0. Comprimido con 0xA8FB (59
;   bytes fuente, 105 de salida).
;   0x7500..0x753b  (59 bytes)
DATA_vista_hoyo_09_cielo:
	defb 039h,000h,0ffh,017h,014h,008h,009h,00ah,00bh,00ch,0ffh,004h,014h,008h,00bh,00bh	; 7500  9...............
	defb 00ch,0ffh,008h,014h,023h,024h,00dh,00eh,00fh,0ffh,004h,014h,023h,00eh,00fh,00fh	; 7510  ....#$......#...
	defb 014h,010h,013h,0ffh,018h,014h,015h,016h,017h,01fh,020h,01ah,01ch,01ah,01bh,01ah	; 7520  .......... .....
	defb 01dh,016h,017h,01ah,01bh,01ch,01ah,01dh,01eh,01eh,014h	; 7530  ...........

; ----------------------------------------------------------------------
; DATOS vista_hoyo_09_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 9; lo
;   comparten tambien los hoyo.tramo 13.1. Comprimido con 0xA8FB (189 bytes
;   fuente, 294 de salida).
;   0x753b..0x75f8  (189 bytes)
DATA_vista_hoyo_09_tramo_1:
	defb 0bbh,000h,0ffh,005h,003h,034h,003h,078h,0c3h,0c3h,079h,0ffh,003h,003h,034h,034h	; 753b  .....4.x..y...44
	defb 0ffh,008h,003h,036h,038h,035h,02dh,032h,02ch,02ch,02ah,028h,04ah,04bh,035h,035h	; 754b  ...685-2,,*(JK55
	defb 003h,036h,038h,003h,003h,03ah,03dh,040h,037h,039h,086h,02ch,08ah,08bh,0ffh,004h	; 755b  .68..:=@79.,....
	defb 02ch,07ah,083h,028h,081h,037h,039h,03ah,03dh,03bh,03eh,041h,003h,003h,087h,088h	; 756b  ,z.(.79:=;>A....
	defb 02ch,08eh,08fh,0ffh,005h,02ch,07ah,083h,084h,079h,03bh,03eh,03ch,03fh,042h,003h	; 757b  ,....,z..y;><?B.
	defb 003h,078h,033h,0ffh,00ah,02ch,07ah,02bh,03ch,03fh,0ffh,004h,003h,02dh,031h,07bh	; 758b  .x3..,z+<?...-1{
	defb 050h,052h,053h,054h,092h,0ffh,006h,02ch,07ah,02bh,079h,0ffh,00bh,025h,07ch,0ffh	; 759b  PRST...,z+y..%|.
	defb 004h,02ch,043h,04fh,0bch,07ah,02bh,0ffh,009h,025h,056h,0a8h,0ffh,005h,02ch,0c7h	; 75ab  .,CO.z+..%V...,.
	defb 047h,047h,0b2h,07ah,0ffh,007h,025h,056h,0a8h,0ffh,006h,02ch,0afh,047h,047h,0b5h	; 75bb  GG.z..%V...,.GG.
	defb 0abh,02ch,0ffh,005h,025h,056h,0a8h,0ffh,00eh,02ch,025h,025h,058h,059h,0a8h,0ffh	; 75cb  .,..%V...,%%XY..
	defb 010h,02ch,07ch,07dh,0ffh,015h,02ch,004h,003h,006h,0ffh,00ch,003h,006h,003h,005h	; 75db  .,|}..,.........
	defb 02ch,000h,001h,003h,003h,007h,0ffh,00ch,003h,007h,003h,003h,002h	; 75eb  ,............

; ----------------------------------------------------------------------
; DATOS vista_hoyo_09_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 9; lo
;   comparten tambien los hoyo.tramo 13.2. Comprimido con 0xA8FB (176 bytes
;   fuente, 294 de salida).
;   0x75f8..0x76a8  (176 bytes)
DATA_vista_hoyo_09_tramo_2:
	defb 0aeh,000h,003h,003h,036h,038h,034h,0ffh,00ah,003h,034h,036h,038h,03ah,03dh,040h	; 75f8  ....684...468:=@
	defb 03dh,040h,037h,039h,035h,02eh,04eh,02fh,0ffh,003h,066h,082h,04ch,04ah,04bh,035h	; 7608  =@795.N/..f.LJK5
	defb 037h,039h,03bh,03eh,041h,03eh,041h,003h,003h,030h,07bh,09ah,09bh,097h,098h,099h	; 7618  79;>A>A..0{.....
	defb 02ch,0bah,0bch,07ah,029h,027h,079h,03ch,03fh,042h,03fh,042h,003h,003h,0c4h,0c0h	; 7628  ,..z)'y<?B?B....
	defb 0ffh,003h,02ch,043h,04fh,0b0h,047h,0b3h,02ch,02ch,07ah,029h,027h,079h,0ffh,005h	; 7638  ..,CO.G.,,z)'y..
	defb 003h,078h,08ch,0ffh,003h,02ch,0c1h,0adh,0adh,0aeh,0ffh,005h,02ch,07ah,02ah,028h	; 7648  .x...,......,z*(
	defb 003h,078h,02eh,04eh,02fh,07bh,0ffh,00eh,02ch,07ah,04eh,02fh,07bh,0ffh,01ah,02ch	; 7658  .x.N/{..,zN/{..,
	defb 050h,051h,052h,061h,052h,085h,0ffh,007h,02ch,050h,050h,051h,052h,061h,061h,093h	; 7668  PQRaR...,PPQRaa.
	defb 053h,0ffh,006h,025h,0c8h,0ffh,006h,02ch,0ffh,00dh,025h,0a7h,0ffh,007h,02ch,0ffh	; 7678  S..%...,..%...,.
	defb 00bh,025h,056h,0a8h,0ffh,008h,02ch,0ffh,009h,025h,07ch,07dh,0ffh,00ah,02ch,0ffh	; 7688  .%V...,..%|}..,.
	defb 007h,025h,07ch,07dh,0ffh,00ch,02ch,0ffh,004h,025h,056h,058h,0a8h,0ffh,00eh,02ch	; 7698  .%|}..,..%VX...,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_09_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 9; lo
;   comparten tambien los hoyo.tramo 13.3. Comprimido con 0xA8FB (140 bytes
;   fuente, 294 de salida).
;   0x76a8..0x7734  (140 bytes)
DATA_vista_hoyo_09_tramo_3:
	defb 08ah,000h,03ah,03dh,040h,003h,036h,038h,0ffh,00bh,003h,036h,038h,03ah,03dh,03bh	; 76a8  ..:=@.68...68:=;
	defb 03eh,041h,003h,037h,039h,04dh,04eh,02fh,0ffh,005h,066h,082h,04ch,027h,037h,039h	; 76b8  >A.79MN/..f.L'79
	defb 03bh,03eh,03ch,03fh,042h,02dh,02fh,066h,07bh,0ffh,009h,02ch,07ah,02ah,084h,03ch	; 76c8  ;><?B-/f{..,z*.<
	defb 03fh,078h,02eh,02fh,07bh,0ffh,00eh,02ch,07ah,029h,027h,02fh,07bh,0ffh,005h,02ch	; 76d8  ?x./{..,z)'/{..,
	defb 0b6h,0b7h,0ffh,006h,003h,09dh,071h,09eh,02ch,02ch,07ah,0ffh,005h,02ch,068h,069h	; 76e8  ......q.,,z..,hi
	defb 0ffh,004h,003h,0b8h,0ffh,005h,003h,09fh,0ffh,008h,02ch,06eh,076h,0ffh,008h,003h	; 76f8  ..........,nv...
	defb 0a6h,072h,0a0h,0ffh,013h,02ch,0bah,0bbh,04fh,0b9h,0bch,0ffh,00dh,02ch,065h,0b9h	; 7708  .r...,..O....,e.
	defb 094h,0ffh,005h,047h,0ffh,009h,02ch,062h,0ffh,003h,0c2h,0ffh,008h,047h,0ffh,009h	; 7718  ...G..,b.....G..
	defb 02ch,063h,064h,0ffh,007h,047h,0b4h,0b5h,0b1h,0ffh,03fh,02ch	; 7728  ,cd..G....?,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_09_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 9; lo
;   comparten tambien los hoyo.tramo 13.4. Comprimido con 0xA8FB (170 bytes
;   fuente, 294 de salida).
;   0x7734..0x77de  (170 bytes)
DATA_vista_hoyo_09_tramo_4:
	defb 0a8h,000h,003h,03ah,03dh,040h,036h,038h,003h,078h,04dh,04eh,0ffh,004h,0bdh,04ch	; 7734  ...:=@68.xMN...L
	defb 027h,079h,036h,038h,03ah,03dh,003h,03bh,03eh,041h,037h,039h,02eh,02fh,07bh,0ffh	; 7744  'y68:=.;>A79./{.
	defb 004h,02ch,095h,096h,07ah,02bh,037h,039h,03bh,03eh,003h,03ch,03fh,042h,02eh,02fh	; 7754  .,..z+79;>.<?B./
	defb 07bh,0ffh,007h,02ch,0c5h,0c6h,089h,003h,003h,03ch,03fh,003h,078h,02eh,02fh,07bh	; 7764  {..,.....<?.x./{
	defb 0ffh,007h,02ch,051h,053h,0ffh,005h,025h,091h,05eh,078h,030h,07bh,0ffh,009h,02ch	; 7774  ..,QS..%.^x0{..,
	defb 090h,0ffh,008h,025h,030h,07bh,02ch,02ch,062h,0c2h,0c2h,0ach,0ffh,006h,02ch,029h	; 7784  ...%0{,,b.....,)
	defb 027h,0c9h,0cah,0cbh,025h,025h,07bh,02ch,02ch,0a9h,0aah,0adh,0adh,0aeh,0ffh,007h	; 7794  '...%%{,,.......
	defb 02ch,07ah,08dh,082h,04ch,04ah,04bh,0ffh,004h,02ch,0a2h,073h,09ch,069h,0ffh,005h	; 77a4  ,z..LJK..,.s.i..
	defb 003h,06ah,09dh,071h,0a1h,0ffh,007h,02ch,068h,0ffh,006h,003h,0a4h,0a5h,0ffh,005h	; 77b4  .j.q...,h.......
	defb 003h,06bh,0ffh,006h,02ch,06eh,0ffh,00ch,003h,06fh,070h,0ffh,007h,02ch,0a3h,075h	; 77c4  .k..,n...op..,.u
	defb 077h,076h,0ffh,006h,003h,0beh,0bfh,0ffh,044h,02ch	; 77d4  wv......D,

; ----------------------------------------------------------------------
; DATOS vista_hoyo_08_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   8; lo comparten tambien los hoyo.tramo 15.0. Comprimido con 0xA8FB (47
;   bytes fuente, 105 de salida).
;   0x77de..0x780d  (47 bytes)
DATA_vista_hoyo_08_cielo:
	defb 02dh,000h,0ffh,020h,014h,008h,009h,00ah,00bh,00ch,0ffh,00ah,014h,010h,011h,013h	; 77de  -.. ............
	defb 0ffh,003h,014h,020h,00eh,00fh,00eh,00fh,0ffh,01ah,014h,022h,023h,019h,01ah,018h	; 77ee  ... ......."#...
	defb 019h,01ah,023h,019h,024h,025h,0ffh,004h,026h,027h,015h,01ch,01dh,016h,017h	; 77fe  ..#.$%..&'.....

; ----------------------------------------------------------------------
; DATOS vista_hoyo_08_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 8; lo
;   comparten tambien los hoyo.tramo 15.1. Comprimido con 0xA8FB (219 bytes
;   fuente, 294 de salida).
;   0x780d..0x78e8  (219 bytes)
DATA_vista_hoyo_08_tramo_1:
	defb 0d9h,000h,0ffh,004h,003h,08dh,08eh,08fh,0ffh,007h,003h,034h,003h,036h,038h,03ah	; 780d  ...........4.68:
	defb 03dh,040h,04eh,04fh,057h,059h,059h,058h,028h,05eh,0ffh,003h,090h,08eh,08fh,060h	; 781d  =@NOWYYX(^.....`
	defb 035h,003h,037h,039h,03bh,03eh,041h,028h,080h,030h,047h,048h,030h,05dh,062h,0ffh	; 782d  5.79;>A(.0GH0]b.
	defb 005h,059h,058h,091h,090h,05fh,003h,03ch,03fh,042h,028h,08ah,030h,0a4h,0a5h,0a6h	; 783d  .YX.._.<?B(.0...
	defb 0a7h,0ffh,007h,030h,05dh,062h,063h,05eh,05fh,060h,003h,028h,028h,055h,066h,065h	; 784d  ...0]bc^_`.((Ufe
	defb 0ffh,00ah,030h,0c1h,030h,0d4h,028h,028h,091h,05bh,0ffh,004h,028h,08ah,030h,030h	; 785d  ..0.0.((.[..(.00
	defb 051h,053h,054h,028h,028h,0cfh,0c3h,0c2h,030h,0d3h,0ffh,003h,028h,030h,05dh,062h	; 786d  QST((...0...(0]b
	defb 063h,0ffh,008h,028h,08bh,0ffh,003h,030h,0bch,0ffh,004h,028h,03dh,040h,0ceh,030h	; 787d  c..(...0...(=@.0
	defb 05dh,062h,063h,0ffh,005h,02ah,030h,030h,052h,054h,0ffh,005h,028h,03eh,042h,003h	; 788d  ]bc..*00RT..(>B.
	defb 0ceh,0ffh,004h,030h,05dh,062h,058h,029h,08ch,056h,0ffh,007h,029h,03fh,042h,003h	; 789d  ...0]bX).V..)?B.
	defb 09fh,0ffh,005h,030h,0ach,054h,0ffh,00ah,02ah,032h,049h,033h,0ffh,006h,030h,05dh	; 78ad  ...0.T..*2I3..0]
	defb 062h,05ah,05ah,058h,05ch,0ffh,003h,02ah,057h,059h,05ah,0ffh,00eh,030h,05dh,062h	; 78bd  bZZX\..*WYZ..0]b
	defb 05ah,082h,0ffh,005h,030h,004h,003h,006h,0ffh,00ch,003h,006h,003h,005h,030h,000h	; 78cd  Z...0.........0.
	defb 001h,003h,003h,007h,0ffh,00ch,003h,007h,003h,003h,002h	; 78dd  ...........

; ----------------------------------------------------------------------
; DATOS vista_hoyo_08_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 8; lo
;   comparten tambien los hoyo.tramo 15.2. Comprimido con 0xA8FB (197 bytes
;   fuente, 294 de salida).
;   0x78e8..0x79ad  (197 bytes)
DATA_vista_hoyo_08_tramo_2:
	defb 0c3h,000h,0ffh,00eh,003h,036h,038h,03ah,03dh,040h,0ffh,004h,003h,08dh,08eh,090h	; 78e8  .....68:=@......
	defb 04dh,04eh,091h,090h,08eh,08fh,060h,003h,003h,037h,039h,03bh,03eh,041h,003h,003h	; 78f8  MN....`..79;>A..
	defb 04eh,04fh,0ffh,00bh,028h,05eh,05fh,060h,03ch,03fh,042h,003h,003h,057h,059h,05ah	; 7908  NO..(^_`<?B..WYZ
	defb 061h,082h,0ffh,003h,030h,0d5h,05ch,0ffh,006h,028h,05eh,05fh,0ffh,003h,003h,030h	; 7918  a...0.\..(^_...0
	defb 06dh,06eh,003h,0b3h,0b4h,003h,06fh,070h,030h,0a2h,0ffh,003h,059h,058h,0ffh,003h	; 7928  mn....op0...YX..
	defb 028h,05eh,05fh,003h,030h,071h,07ah,0ffh,004h,003h,072h,073h,030h,043h,044h,0ffh	; 7938  (^_.0qz...rs0CD.
	defb 003h,030h,05dh,062h,058h,028h,028h,05eh,0ffh,003h,030h,0cah,089h,0ffh,004h,030h	; 7948  .0]bX((^..0....0
	defb 0c3h,045h,0c9h,0ffh,006h,030h,05bh,05ch,029h,08ah,030h,0c7h,045h,045h,084h,04bh	; 7958  .E...0[\).0.EE.K
	defb 04bh,044h,0ffh,008h,030h,043h,04bh,089h,0a2h,028h,08ah,030h,0c4h,0c6h,0ffh,003h	; 7968  KD..0CK..(.0....
	defb 085h,086h,0ffh,008h,030h,0beh,045h,045h,084h,028h,028h,055h,066h,069h,068h,0ffh	; 7978  ....0.EE.((Ufih.
	defb 00ch,030h,0c4h,0cdh,045h,0ffh,007h,028h,067h,066h,065h,0ffh,00ah,030h,0c5h,0ffh	; 7988  .0..E..(gfe..0..
	defb 00ah,029h,064h,0ffh,00ah,030h,0ffh,009h,02ah,057h,083h,0ffh,00ah,030h,0ffh,008h	; 7998  .)d..0..*W...0..
	defb 02ah,08bh,0ffh,00ch,030h	; 79a8

; ----------------------------------------------------------------------
; DATOS vista_hoyo_08_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 8; lo
;   comparten tambien los hoyo.tramo 15.3. Comprimido con 0xA8FB (169 bytes
;   fuente, 294 de salida).
;   0x79ad..0x7a56  (169 bytes)
DATA_vista_hoyo_08_tramo_3:
	defb 0a7h,000h,036h,038h,003h,034h,0ffh,00ch,003h,034h,003h,036h,038h,003h,037h,039h	; 79ad  ..68.4...4.68.79
	defb 003h,035h,003h,08dh,0ffh,007h,08eh,05fh,060h,003h,035h,003h,037h,039h,003h,08dh	; 79bd  .5....._`.5.79..
	defb 08eh,090h,050h,04fh,0ffh,00ah,028h,091h,0ffh,003h,090h,08eh,08eh,0ffh,003h,028h	; 79cd  ..PO..(........(
	defb 057h,0ffh,003h,059h,0ffh,007h,05ah,058h,05ch,0ffh,005h,028h,059h,05ah,0a3h,0b8h	; 79dd  W..Y..ZX\..(YZ..
	defb 0b7h,0b5h,06eh,0ffh,004h,003h,06fh,074h,075h,0b6h,030h,092h,062h,063h,05ch,028h	; 79ed  ..n...otu.0.bc\(
	defb 0ffh,003h,030h,079h,0ffh,005h,003h,088h,0ffh,004h,003h,076h,0ffh,005h,030h,05dh	; 79fd  ..0y.......v..0]
	defb 0ffh,003h,030h,0b9h,0bah,0bbh,07ah,0ffh,004h,003h,072h,07bh,078h,077h,030h,030h	; 7a0d  ..0...z...r{xw00
	defb 0cah,089h,0ffh,011h,030h,0afh,0b0h,045h,045h,0ffh,003h,030h,0aeh,0cch,0cch,0c8h	; 7a1d  ....0..EE..0....
	defb 0ffh,008h,030h,043h,087h,0ffh,003h,045h,0c9h,0ffh,003h,030h,0beh,0ffh,003h,045h	; 7a2d  ..0C...E...0...E
	defb 084h,0ffh,003h,04bh,044h,0ffh,003h,030h,0cbh,0ffh,003h,085h,086h,0ffh,005h,030h	; 7a3d  ...KD..0.......0
	defb 0c4h,0c6h,0ffh,005h,085h,086h,0ffh,04ah,030h	; 7a4d  .......J0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_08_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 8; lo
;   comparten tambien los hoyo.tramo 15.4. Comprimido con 0xA8FB (207 bytes
;   fuente, 294 de salida).
;   0x7a56..0x7b25  (207 bytes)
DATA_vista_hoyo_08_tramo_4:
	defb 0cdh,000h,003h,036h,038h,036h,038h,003h,034h,0ffh,003h,003h,049h,046h,09eh,003h	; 7a56  ...6868.4...IF..
	defb 034h,0ffh,007h,003h,037h,039h,037h,039h,003h,035h,04ch,04fh,064h,0bdh,0b1h,0b2h	; 7a66  4...7979.5LOd...
	defb 09dh,035h,003h,036h,038h,03ah,03dh,040h,08dh,08eh,090h,04dh,04eh,04fh,028h,057h	; 7a76  .5.68:=@...MNO(W
	defb 059h,059h,058h,067h,066h,069h,065h,02fh,037h,039h,03bh,03eh,041h,0ffh,003h,028h	; 7a86  YYXgfie/79;>A..(
	defb 057h,059h,05ah,0a3h,030h,030h,052h,054h,028h,028h,057h,0abh,07dh,02ch,02bh,03bh	; 7a96  WYZ.00RT((W.},+;
	defb 03fh,042h,057h,08bh,0ffh,007h,030h,092h,062h,0adh,063h,067h,066h,069h,065h,07dh	; 7aa6  ?BW...0.b.cgfie}
	defb 06ch,02dh,046h,0ffh,003h,030h,043h,04bh,04bh,044h,0ffh,006h,030h,092h,062h,059h	; 7ab6  l-F..0CKKD..0.bY
	defb 063h,028h,028h,067h,066h,030h,030h,0bfh,0c0h,085h,085h,086h,0ffh,00ah,030h,092h	; 7ac6  c((gf00.......0.
	defb 05bh,028h,028h,0ffh,005h,030h,06dh,06eh,003h,003h,0b3h,0b4h,003h,003h,06fh,070h	; 7ad6  [((..0mn......op
	defb 0ffh,004h,030h,092h,062h,0a0h,0ffh,004h,030h,071h,07ah,0ffh,006h,003h,072h,073h	; 7ae6  ..0.b...0qz...rs
	defb 0ffh,006h,030h,028h,0a0h,0a1h,068h,0ffh,011h,030h,0ffh,008h,028h,067h,066h,068h	; 7af6  ..0(..h..0..(gfh
	defb 051h,0ffh,006h,030h,051h,053h,054h,0d0h,0d1h,0d2h,0ffh,010h,028h,0a8h,0a9h,0ffh	; 7b06  Q..0QST.....(...
	defb 004h,003h,0d0h,0d1h,0d2h,0ffh,008h,028h,0a8h,0a8h,0a9h,0aah,0ffh,017h,003h	; 7b16  .......(.......

; ----------------------------------------------------------------------
; DATOS vista_hoyo_04_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   4; lo comparten tambien los hoyo.tramo 11.0. Comprimido con 0xA8FB (46
;   bytes fuente, 105 de salida).
;   0x7b25..0x7b53  (46 bytes)
DATA_vista_hoyo_04_cielo:
	defb 02ch,000h,0ffh,017h,014h,008h,009h,00ah,009h,00ah,00bh,00ch,0ffh,00eh,014h,020h	; 7b25  ,.............. 
	defb 00eh,00fh,021h,00dh,00eh,00fh,0ffh,004h,014h,010h,011h,012h,013h,0ffh,019h,014h	; 7b35  ..!.............
	defb 0ffh,00ah,026h,025h,027h,015h,01ch,01dh,01ah,018h,019h,01ah,018h,01bh	; 7b45  ..&%'.........

; ----------------------------------------------------------------------
; DATOS vista_hoyo_04_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 4; lo
;   comparten tambien los hoyo.tramo 11.1. Comprimido con 0xA8FB (163 bytes
;   fuente, 294 de salida).
;   0x7b53..0x7bf6  (163 bytes)
DATA_vista_hoyo_04_tramo_1:
	defb 0a1h,000h,0ffh,008h,028h,057h,083h,047h,048h,04ah,0c3h,034h,0ffh,006h,003h,0ffh	; 7b53  ....(W.GHJ.4....
	defb 008h,029h,055h,066h,065h,030h,030h,09fh,035h,036h,038h,0ffh,004h,003h,0ffh,007h	; 7b63  .)Ufe00.568.....
	defb 02ah,057h,061h,062h,063h,055h,0a2h,07dh,09ah,037h,039h,03ah,03dh,040h,003h,0ffh	; 7b73  *WabcU.}.79:=@..
	defb 007h,02ah,08ch,065h,030h,0c7h,02ah,02ah,0c4h,07dh,02fh,07ch,03bh,03eh,041h,03ah	; 7b83  .*.e0.**.}/|;>A:
	defb 0ffh,00bh,02ah,081h,082h,030h,030h,07dh,09ah,037h,03fh,042h,03bh,0ffh,007h,02ah	; 7b93  ..*..00}.7?B;..*
	defb 057h,059h,05ah,082h,0ffh,005h,030h,07dh,02fh,07ch,003h,03ch,0ffh,004h,02ah,081h	; 7ba3  WYZ...0}/|.<..*.
	defb 082h,0ffh,008h,030h,043h,04bh,044h,07dh,09ah,07ch,003h,02ah,02ah,081h,082h,0ffh	; 7bb3  ...0CKD}.|.**...
	defb 008h,030h,043h,087h,0ffh,003h,045h,030h,07dh,02dh,09bh,02ah,080h,0ffh,00ah,030h	; 7bc3  .0C...E0}-.*...0
	defb 0c2h,0ffh,003h,085h,086h,0ffh,003h,030h,07dh,082h,0ffh,040h,030h,004h,003h,006h	; 7bd3  .......0}..@0...
	defb 0ffh,00ch,003h,006h,003h,005h,030h,000h,001h,003h,003h,007h,0ffh,00ch,003h,007h	; 7be3  ......0.........
	defb 003h,003h,002h	; 7bf3

; ----------------------------------------------------------------------
; DATOS vista_hoyo_04_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 4; lo
;   comparten tambien los hoyo.tramo 11.2. Comprimido con 0xA8FB (149 bytes
;   fuente, 294 de salida).
;   0x7bf6..0x7c8b  (149 bytes)
DATA_vista_hoyo_04_tramo_2:
	defb 093h,000h,0ffh,006h,028h,057h,059h,05ah,06ch,04ah,02eh,02bh,07ch,003h,003h,036h	; 7bf6  ....(WYZlJ.+|..6
	defb 038h,03ah,03dh,040h,0ffh,005h,028h,08bh,0abh,0ach,0a8h,0a9h,0aah,030h,07dh,02ch	; 7c06  8:=@..(......0},
	defb 046h,02bh,037h,039h,03bh,03eh,041h,0ffh,005h,029h,08ah,051h,0ffh,008h,030h,07dh	; 7c16  F+79;>A..).Q..0}
	defb 02ch,02bh,03ch,03fh,042h,029h,029h,08bh,030h,092h,062h,059h,058h,029h,0a1h,0ffh	; 7c26  ,+<?B)).0.bYX)..
	defb 007h,030h,07dh,02bh,02bh,07ch,02ah,02ah,08ch,0c0h,052h,052h,053h,054h,057h,0a0h	; 7c36  .0}++|**..RRSTW.
	defb 0ffh,009h,030h,07dh,02fh,0ffh,004h,02ah,057h,059h,083h,0ffh,00eh,030h,02ah,02ah	; 7c46  ..0}/..*WY...0**
	defb 057h,083h,0ffh,011h,030h,02ah,08bh,0ffh,00eh,030h,043h,04bh,04bh,044h,09dh,08bh	; 7c56  W...0*...0CKKD..
	defb 0ffh,00dh,030h,0a3h,0a4h,0ffh,004h,045h,084h,0ffh,00bh,030h,043h,04bh,087h,0ffh	; 7c66  ..0....E...0CK..
	defb 007h,045h,0ffh,00bh,030h,0ffh,00ah,045h,0ffh,00bh,030h,06ah,0bdh,06bh,0ffh,006h	; 7c76  .E..0..E..0j.k..
	defb 045h,0beh,0ffh,02ah,030h	; 7c86

; ----------------------------------------------------------------------
; DATOS vista_hoyo_04_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 4; lo
;   comparten tambien los hoyo.tramo 11.3. Comprimido con 0xA8FB (158 bytes
;   fuente, 294 de salida).
;   0x7c8b..0x7d29  (158 bytes)
DATA_vista_hoyo_04_tramo_3:
	defb 09ch,000h,0ffh,004h,028h,057h,059h,059h,05ah,05ah,082h,0ffh,003h,030h,04ah,02eh	; 7c8b  ....(WYYZZ...0J.
	defb 02bh,07ch,003h,003h,036h,038h,028h,081h,082h,030h,030h,06dh,06eh,003h,0adh,0aeh	; 7c9b  +|..68(..00mn...
	defb 003h,06fh,070h,030h,030h,07dh,02ch,046h,02bh,037h,039h,028h,0ffh,004h,030h,071h	; 7cab  .op00},F+79(..0q
	defb 07ah,0ffh,004h,003h,072h,073h,0ffh,005h,030h,07dh,02ch,02bh,028h,08ch,065h,0ffh	; 7cbb  z...rs..0},+(.e.
	defb 011h,030h,07dh,0ffh,003h,029h,055h,066h,065h,0ffh,011h,030h,092h,062h,063h,0ffh	; 7ccb  .0}..)Ufe..0.bc.
	defb 003h,029h,067h,066h,069h,069h,068h,0ffh,00dh,030h,092h,062h,063h,0ffh,005h,02ah	; 7cdb  .)gfiih..0.bc..*
	defb 064h,0ffh,00fh,030h,0c6h,0ffh,004h,02ah,080h,0ffh,00fh,030h,0c5h,0ffh,003h,02ah	; 7ceb  d..0...*...0...*
	defb 080h,0ffh,00dh,030h,052h,053h,054h,0ffh,003h,028h,080h,0ffh,00bh,030h,052h,053h	; 7cfb  ...0RST..(...0RS
	defb 054h,0ffh,004h,029h,081h,082h,0ffh,00ah,030h,0ffh,008h,02ah,080h,0ffh,00ch,030h	; 7d0b  T..)....0..*...0
	defb 0ffh,007h,02ah,080h,0ffh,00dh,030h,0ffh,006h,02ah,080h,0ffh,00eh,030h	; 7d1b  ..*...0..*...0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_04_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 4; lo
;   comparten tambien los hoyo.tramo 11.4. Comprimido con 0xA8FB (100 bytes
;   fuente, 294 de salida).
;   0x7d29..0x7d8d  (100 bytes)
DATA_vista_hoyo_04_tramo_4:
	defb 062h,000h,0ffh,004h,028h,057h,059h,059h,05ah,05ah,082h,0ffh,00bh,030h,028h,081h	; 7d29  b...(WYYZZ...0(.
	defb 082h,0ffh,012h,030h,080h,0ffh,018h,030h,0b6h,0b1h,0afh,0ffh,007h,003h,074h,075h	; 7d39  ...0...0......tu
	defb 0b5h,0ffh,007h,030h,06dh,0ffh,006h,003h,0b9h,0bah,0ffh,005h,003h,070h,0ffh,006h	; 7d49  ...0m........p..
	defb 030h,071h,0ffh,00dh,003h,073h,0ffh,007h,030h,0b8h,0b4h,0bbh,0ffh,007h,003h,07bh	; 7d59  0q...s..0......{
	defb 078h,0b7h,0ffh,043h,030h,08ch,065h,0ffh,013h,030h,028h,028h,067h,066h,065h,0ffh	; 7d69  x..C0.e..0((gfe.
	defb 010h,030h,0ffh,006h,028h,067h,066h,065h,0ffh,00ch,030h,0ffh,00ah,028h,067h,066h	; 7d79  .0..(gfe..0..(gf
	defb 065h,0ffh,008h,030h	; 7d89

; ----------------------------------------------------------------------
; DATOS vista_hoyo_02_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   2; lo comparten tambien los hoyo.tramo 4.5, 11.5, 14.0. Comprimido con
;   0xA8FB (62 bytes fuente, 105 de salida).
;   0x7d8d..0x7dcb  (62 bytes)
DATA_vista_hoyo_02_cielo:
	defb 03ch,000h,0ffh,01ah,014h,008h,00bh,00bh,00ch,0ffh,009h,014h,010h,013h,014h,012h	; 7d8d  <...............
	defb 013h,010h,014h,014h,020h,00eh,00eh,00fh,0ffh,005h,014h,008h,009h,00ah,00bh,00ch	; 7d9d  .... ...........
	defb 0ffh,010h,014h,020h,021h,00dh,00eh,00fh,014h,014h,019h,01ah,01dh,01eh,022h,023h	; 7dad  ... !........."#
	defb 01ah,023h,024h,025h,0ffh,004h,026h,025h,027h,015h,01ch,023h,019h,01ah	; 7dbd  .#$%..&%'..#..

; ----------------------------------------------------------------------
; DATOS vista_hoyo_02_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 2; lo
;   comparten tambien los hoyo.tramo 14.1. Comprimido con 0xA8FB (230 bytes
;   fuente, 294 de salida).
;   0x7dcb..0x7eb1  (230 bytes)
DATA_vista_hoyo_02_tramo_1:
	defb 0e4h,000h,0ffh,005h,003h,034h,0ffh,003h,003h,0cah,050h,04fh,05eh,05fh,060h,003h	; 7dcb  .....4....PO^_`.
	defb 034h,0ffh,006h,003h,036h,038h,003h,035h,003h,0cah,050h,02ah,029h,02ah,028h,02ah	; 7ddb  4...68.5..P*)*(*
	defb 05eh,05fh,035h,003h,036h,038h,003h,03dh,040h,037h,039h,003h,0cah,050h,029h,02ah	; 7deb  ^_5.68.=@79..P)*
	defb 097h,0aah,093h,02ah,0ffh,003h,029h,02ch,02bh,037h,039h,003h,03eh,041h,003h,003h	; 7dfb  ...*..),+79.>A..
	defb 0d5h,02ah,029h,029h,080h,030h,047h,048h,09eh,0aah,0aah,09fh,030h,030h,02fh,003h	; 7e0b  .*)).0GH....00/.
	defb 003h,03fh,042h,003h,0d6h,02ah,02ah,081h,082h,0b9h,0bah,0ffh,004h,030h,0a9h,0a8h	; 7e1b  .?B..**......0..
	defb 0a8h,069h,069h,0a5h,003h,003h,0cah,050h,028h,02ah,096h,0ffh,007h,030h,0d2h,029h	; 7e2b  .ii....P(*...0.)
	defb 029h,0ffh,003h,02ah,028h,0d1h,0d5h,029h,029h,0ffh,003h,02ah,08ch,069h,0a8h,0a8h	; 7e3b  )..*(..))..*.i..
	defb 069h,0a8h,056h,0ffh,003h,02ah,028h,0ffh,004h,02ah,029h,0ffh,007h,02ah,028h,029h	; 7e4b  i.V..*(..*)..*()
	defb 029h,0ffh,006h,02ah,029h,02ah,02ah,029h,0ffh,005h,02ah,028h,0ffh,006h,02ah,029h	; 7e5b  )..*)**)..*(..*)
	defb 029h,0ffh,00eh,02ah,029h,028h,02ah,028h,0ffh,005h,02ah,028h,028h,0ffh,003h,02ah	; 7e6b  )..*)(*(..*((..*
	defb 0cfh,0d0h,02ah,0ffh,003h,029h,028h,0ffh,00bh,02ah,029h,028h,02ah,003h,003h,0ceh	; 7e7b  ..*..)(..*)(*...
	defb 0cfh,0d0h,0ffh,004h,02ah,029h,0ffh,005h,02ah,029h,029h,0a2h,0a2h,0a3h,0a4h,0ffh	; 7e8b  ....*)..*)).....
	defb 004h,003h,006h,0ffh,00ch,003h,006h,0ffh,003h,003h,000h,001h,003h,003h,007h,0ffh	; 7e9b  ................
	defb 00ch,003h,007h,003h,003h,002h	; 7eab

; ----------------------------------------------------------------------
; DATOS vista_hoyo_02_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 2; lo
;   comparten tambien los hoyo.tramo 14.2. Comprimido con 0xA8FB (184 bytes
;   fuente, 294 de salida).
;   0x7eb1..0x7f69  (184 bytes)
DATA_vista_hoyo_02_tramo_2:
	defb 0b6h,000h,03ah,03dh,040h,036h,038h,0ffh,00ch,003h,036h,038h,03ah,03dh,03bh,03eh	; 7eb1  ..:=@68...68:=;>
	defb 041h,037h,039h,08dh,08eh,0ffh,005h,090h,08eh,08fh,060h,003h,003h,037h,039h,03bh	; 7ec1  A79.......`..79;
	defb 03eh,03ch,03fh,042h,0cah,050h,02ah,02ah,029h,0ffh,003h,02ah,028h,029h,0ffh,003h	; 7ed1  ><?B.P**)..*()..
	defb 02ah,05eh,05fh,060h,03ch,03fh,04ch,04eh,04fh,02ah,029h,02ah,081h,082h,0ffh,004h	; 7ee1  *^_`<?LNO*)*....
	defb 030h,092h,062h,063h,02ah,029h,028h,02ah,05eh,05fh,02ah,029h,02ah,028h,081h,082h	; 7ef1  0.bc*)(*^_*)*(..
	defb 0ffh,009h,030h,0d3h,05ch,02ah,02ah,029h,0ffh,003h,02ah,081h,082h,0ffh,003h,030h	; 7f01  ..0.\**)..*....0
	defb 0c7h,0c8h,0ffh,004h,003h,06fh,074h,075h,0b3h,05dh,0aah,0aah,082h,057h,083h,0ffh	; 7f11  .....otu.]...W..
	defb 003h,030h,06dh,06eh,0ffh,006h,003h,088h,003h,003h,076h,0ffh,009h,030h,071h,07ah	; 7f21  .0mn......v..0qz
	defb 0ffh,006h,003h,072h,07bh,078h,077h,0ffh,01ah,030h,0adh,0aeh,0afh,0b0h,0b1h,0ffh	; 7f31  ...r{xw..0......
	defb 00eh,030h,0c5h,0c2h,0ffh,005h,045h,084h,0beh,0c9h,089h,0ffh,00ah,030h,0d3h,030h	; 7f41  .0....E......0.0
	defb 06ah,06bh,0ffh,007h,045h,084h,0beh,089h,0ffh,00bh,030h,0bfh,0c1h,0c0h,0bbh,06bh	; 7f51  jk..E.....0....k
	defb 0ffh,003h,045h,0c4h,0bch,0ffh,01dh,030h	; 7f61  ..E....0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_02_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 2; lo
;   comparten tambien los hoyo.tramo 14.3. Comprimido con 0xA8FB (178 bytes
;   fuente, 294 de salida).
;   0x7f69..0x801b  (178 bytes)
DATA_vista_hoyo_02_tramo_3:
	defb 0b0h,000h,03dh,040h,036h,038h,0ffh,006h,003h,032h,02bh,0a0h,0ffh,006h,003h,036h	; 7f69  ..=@68...2+....6
	defb 038h,03eh,041h,037h,039h,0ffh,005h,003h,09dh,0abh,0ach,030h,02fh,0ffh,005h,003h	; 7f79  8>A79......0/...
	defb 037h,039h,03fh,042h,003h,08eh,08eh,090h,04eh,0a1h,04fh,029h,02ah,02ah,028h,055h	; 7f89  79?B....N.O)**(U
	defb 090h,08fh,0ffh,005h,003h,04ch,04dh,04fh,0ffh,003h,02ah,029h,0ffh,003h,02ah,028h	; 7f99  .....LMO..*)..*(
	defb 02ah,02ah,029h,028h,02ah,05eh,05fh,060h,003h,003h,02ah,029h,02ah,029h,0ffh,003h	; 7fa9  **)(*^_`..*)*)..
	defb 02ah,081h,082h,0d4h,0ffh,003h,030h,092h,0c6h,062h,063h,029h,02ah,05eh,05fh,05bh	; 7fb9  *.....0..bc)*^_[
	defb 02ah,029h,028h,02ah,081h,082h,0ffh,005h,030h,043h,0ffh,003h,04bh,044h,098h,093h	; 7fc9  *)(*....0C..KD..
	defb 029h,02ah,0ffh,00ch,030h,06ah,0bbh,06bh,045h,045h,0bdh,030h,098h,093h,0ffh,00fh	; 7fd9  )*..0j.kEE.0....
	defb 030h,0bfh,0cdh,0c3h,0ffh,007h,030h,0b5h,0b4h,0b2h,06eh,0ffh,007h,003h,06fh,070h	; 7fe9  0.....0...n...op
	defb 0ffh,004h,030h,0a6h,0ffh,003h,030h,079h,003h,003h,088h,0ffh,008h,003h,073h,0ffh	; 7ff9  ..0...0y......s.
	defb 004h,030h,0a7h,0ffh,003h,030h,0b6h,0b7h,0b8h,07ah,0ffh,005h,003h,0cbh,0cch,0ffh	; 8009  .0...0...z......
	defb 045h,030h	; 8019

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   10; lo comparten tambien los hoyo.tramo 17.0. Comprimido con 0xA8FB (51
;   bytes fuente, 105 de salida).
;   0x801b..0x804e  (51 bytes)
DATA_vista_hoyo_10_cielo:
	defb 031h,000h,0ffh,016h,014h,008h,00bh,00ch,00bh,00ch,014h,014h,010h,013h,0ffh,00ch	; 801b  1...............
	defb 014h,020h,00eh,00fh,00eh,00fh,0ffh,008h,014h,010h,013h,0ffh,01ah,014h,026h,027h	; 802b  . ............&'
	defb 022h,01dh,018h,01ah,017h,018h,01ah,01dh,01eh,01fh,019h,01ah,018h,01bh,09ah,015h	; 803b  "...............
	defb 016h,017h,01dh	; 804b

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 10; lo
;   comparten tambien los hoyo.tramo 17.1. Comprimido con 0xA8FB (200 bytes
;   fuente, 294 de salida).
;   0x804e..0x8116  (200 bytes)
DATA_vista_hoyo_10_tramo_1:
	defb 0c6h,000h,029h,05eh,05fh,032h,049h,046h,02bh,003h,003h,0cdh,0abh,0a4h,0a5h,07ch	; 804e  ..)^_2IF+......|
	defb 034h,0ffh,006h,003h,029h,02ah,096h,030h,047h,048h,030h,09ch,0a0h,0ffh,004h,030h	; 805e  4...)*.0GH0....0
	defb 02fh,035h,034h,0ffh,005h,003h,02ah,029h,028h,067h,066h,065h,030h,0cch,0ffh,004h	; 806e  /54...*)(gfe0...
	defb 030h,0efh,0a7h,003h,035h,036h,038h,0ffh,003h,003h,02ah,02ah,028h,029h,02ah,028h	; 807e  0...568...**()*(
	defb 067h,0f2h,030h,0d3h,030h,0efh,0a7h,036h,038h,003h,037h,039h,0ffh,003h,003h,02ah	; 808e  g.0.0..68.79...*
	defb 029h,057h,0b1h,0b1h,082h,030h,030h,0d6h,0d4h,0f0h,0aah,0e9h,037h,039h,0ffh,003h	; 809e  )W...00.....79..
	defb 003h,03ah,03dh,040h,097h,082h,0ffh,008h,030h,02fh,07ch,0ffh,006h,003h,03bh,03eh	; 80ae  .:=@....0/|...;>
	defb 041h,030h,043h,04bh,089h,0ffh,006h,030h,07dh,02dh,09bh,0a4h,07ch,0ffh,003h,003h	; 80be  A0CK...0}-..|...
	defb 03ch,03fh,042h,0d9h,0ffh,003h,045h,084h,044h,0ffh,007h,030h,07dh,02ch,046h,0a4h	; 80ce  <?B...E.D..0},F.
	defb 0a5h,07ch,003h,003h,030h,0d7h,0ffh,003h,085h,086h,0ffh,00bh,030h,07dh,04ah,02eh	; 80de  .|..0.......0}J.
	defb 046h,08ah,0ffh,013h,030h,07dh,02ah,0afh,0ffh,013h,030h,029h,0f8h,0ffh,013h,030h	; 80ee  F...0}*...0)...0
	defb 02ah,0f9h,004h,003h,006h,0ffh,00ch,003h,006h,003h,005h,030h,000h,001h,003h,003h	; 80fe  *..........0....
	defb 007h,0ffh,00ch,003h,007h,003h,003h,002h	; 810e  ........

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 10; lo
;   comparten tambien los hoyo.tramo 17.2. Comprimido con 0xA8FB (198 bytes
;   fuente, 294 de salida).
;   0x8116..0x81dc  (198 bytes)
DATA_vista_hoyo_10_tramo_2:
	defb 0c4h,000h,0aeh,003h,034h,034h,0ffh,003h,003h,0cah,0edh,0edh,0ffh,003h,003h,0cah	; 8116  ....44..........
	defb 0cdh,0abh,0a4h,07ch,003h,036h,038h,05fh,003h,035h,035h,032h,049h,0e4h,033h,06ch	; 8126  ...|.68_.552I.3l
	defb 0b8h,04ah,02eh,033h,06ch,07eh,030h,07dh,02dh,09dh,037h,039h,02ah,05eh,05fh,09eh	; 8136  .J.3l~0}-.79*^_.
	defb 07eh,0c0h,0bdh,003h,0beh,0bfh,030h,030h,043h,044h,0ffh,004h,030h,0f4h,003h,003h	; 8146  ~.....00CD..0...
	defb 02ah,028h,02ah,08ch,065h,0ffh,005h,030h,0d2h,0dbh,0dch,0d4h,0ffh,004h,030h,0ach	; 8156  *(*.e..0......0.
	defb 07ch,003h,028h,02ah,0ffh,003h,029h,067h,066h,069h,069h,065h,0ffh,008h,030h,07dh	; 8166  |.(*..)gfiie..0}
	defb 02ch,02bh,02ah,029h,02ah,029h,029h,02ah,029h,02ah,029h,028h,064h,0ffh,006h,030h	; 8176  ,+*)*))*)*)(d..0
	defb 0e0h,0e1h,089h,07dh,02ah,028h,02ah,0ffh,003h,029h,02ah,02ah,029h,057h,0f6h,0ffh	; 8186  ...}*(*..)**)W..
	defb 006h,030h,0f1h,045h,045h,0dah,029h,028h,02ah,029h,028h,057h,059h,05ah,082h,0ffh	; 8196  .0.EE.)(*)(WYZ..
	defb 007h,030h,0d9h,045h,045h,0a3h,0a2h,02ah,029h,057h,05ah,082h,0ffh,010h,030h,081h	; 81a6  .0.EE..*)WZ...0.
	defb 082h,0ffh,017h,030h,0b9h,0bah,0bbh,0bch,089h,0ffh,00eh,030h,0eah,0ebh,0ffh,005h	; 81b6  ...0.......0....
	defb 045h,0cfh,0ffh,00ch,030h,0d9h,0ffh,008h,045h,0b3h,0ffh,00ch,030h,0d7h,0d8h,0ffh	; 81c6  E...0...E...0...
	defb 005h,085h,086h,0ffh,00bh,030h	; 81d6

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 10; lo
;   comparten tambien los hoyo.tramo 17.3. Comprimido con 0xA8FB (149 bytes
;   fuente, 294 de salida).
;   0x81dc..0x8271  (149 bytes)
DATA_vista_hoyo_10_tramo_3:
	defb 093h,000h,0ffh,005h,003h,0ffh,003h,0edh,0ffh,00ah,003h,0edh,0edh,003h,031h,049h	; 81dc  ..............1I
	defb 033h,06ch,0b8h,0ffh,003h,07fh,04ah,02eh,0ffh,003h,0e4h,046h,0a4h,0abh,049h,033h	; 81ec  3l....J....F..I3
	defb 06ch,0b8h,04ah,030h,030h,06dh,06eh,07ah,0ffh,004h,003h,06fh,070h,0ffh,00ch,030h	; 81fc  l.J00mnz...op..0
	defb 071h,07ah,0ffh,005h,003h,0deh,0dfh,030h,043h,04bh,089h,0ffh,00eh,030h,0e2h,0e1h	; 820c  qz.....0CK...0..
	defb 0e3h,0ebh,0ffh,003h,045h,0b3h,0ffh,005h,030h,08ah,0ffh,007h,030h,0e8h,0ffh,005h	; 821c  ....E...0...0...
	defb 085h,086h,0ffh,006h,030h,02ah,0f7h,065h,0ffh,012h,030h,02ah,02ah,029h,067h,0b0h	; 822c  ....0*.e..0**)g.
	defb 0ffh,010h,030h,028h,02ah,02ah,029h,02ah,0f2h,0ffh,00fh,030h,02ah,029h,028h,081h	; 823c  ..0(**)*...0*)(.
	defb 082h,0ffh,010h,030h,057h,059h,083h,0ffh,00eh,030h,0eah,0ebh,0ech,0ech,0ffh,010h	; 824c  ...0WY...0......
	defb 030h,0adh,0ffh,004h,045h,0ffh,00eh,030h,0b2h,0ffh,006h,045h,0ffh,00eh,030h,0ceh	; 825c  0...E..0...E..0.
	defb 0ffh,004h,045h,0dch,0d4h	; 826c

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 10; lo
;   comparten tambien los hoyo.tramo 17.4. Comprimido con 0xA8FB (145 bytes
;   fuente, 294 de salida).
;   0x8271..0x8302  (145 bytes)
DATA_vista_hoyo_10_tramo_4:
	defb 08fh,000h,0ffh,008h,003h,0edh,0edh,0ffh,00ch,003h,0cah,0cdh,0abh,049h,033h,06ch	; 8271  .............I3l
	defb 0b8h,07fh,07fh,04ah,02eh,046h,0a4h,0a5h,07ch,0ffh,003h,003h,0cah,0abh,032h,033h	; 8281  ...J.F..|.....23
	defb 07eh,0ffh,00bh,030h,07dh,04ah,02eh,0e4h,0e4h,09fh,07eh,0ffh,003h,030h,0c7h,0c3h	; 8291  ~..0}J....~..0..
	defb 0c1h,06eh,0ffh,005h,003h,06fh,074h,075h,0c6h,0ffh,007h,030h,06dh,003h,003h,088h	; 82a1  .n...otu...0m...
	defb 0ffh,00ah,003h,070h,0ffh,006h,030h,071h,0ffh,00ch,003h,072h,073h,0ffh,007h,030h	; 82b1  ...p..0q...rs..0
	defb 0c8h,0c5h,0c9h,07ah,0ffh,005h,003h,0e6h,0e7h,0ffh,019h,030h,0b4h,0e1h,0b5h,0ffh	; 82c1  ...z.......0....
	defb 00ch,030h,0e0h,0e3h,04bh,04bh,0ebh,0ffh,004h,045h,0ffh,00ch,030h,0ffh,009h,045h	; 82d1  .0..KK...E..0..E
	defb 0f7h,065h,0ffh,00ah,030h,0d7h,0d8h,0ffh,007h,085h,02ah,028h,064h,0ffh,012h,030h	; 82e1  .e..0.....*(d..0
	defb 029h,02ah,029h,0f7h,065h,0ffh,010h,030h,02ah,028h,02ah,02ah,029h,0afh,0ffh,00fh	; 82f1  )*).e..0*(**)...
	defb 030h	; 8301

; ----------------------------------------------------------------------
; DATOS vista_hoyo_10_tramo_5: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 5 del hoyo 10; lo
;   comparten tambien los hoyo.tramo 17.5. Comprimido con 0xA8FB (153 bytes
;   fuente, 294 de salida).
;   0x8302..0x839b  (153 bytes)
DATA_vista_hoyo_10_tramo_5:
	defb 097h,000h,003h,003h,034h,003h,0a0h,0b6h,0b7h,092h,062h,0ffh,004h,059h,063h,0ffh	; 8302  ....4.....b..Yc.
	defb 007h,028h,036h,038h,035h,003h,0a9h,0a9h,0a6h,0ffh,007h,030h,0f3h,0ffh,006h,028h	; 8312  .(685......0...(
	defb 037h,039h,0cah,032h,049h,0e4h,0a0h,0ffh,004h,030h,051h,052h,053h,056h,0ffh,006h	; 8322  79.2I....0QRSV..
	defb 028h,003h,031h,033h,07eh,0ffh,006h,030h,0ddh,0ffh,00ah,028h,003h,0f5h,0ffh,008h	; 8332  (.13~..0...(....
	defb 030h,05bh,05ch,0ffh,009h,028h,0cah,0a8h,0ffh,00ah,030h,098h,05ah,093h,0ffh,006h	; 8342  0[\..(....0.Z...
	defb 028h,0a1h,07eh,030h,030h,0eah,0ebh,0ech,0ech,0d5h,0ffh,006h,030h,098h,05ah,093h	; 8352  (.~00.......0.Z.
	defb 0ffh,003h,028h,0ffh,003h,030h,0d0h,0d1h,0ffh,003h,085h,086h,0ffh,009h,030h,098h	; 8362  ..(..0........0.
	defb 059h,058h,0ffh,006h,030h,0c4h,0c3h,0c1h,06eh,0ffh,003h,003h,06fh,074h,075h,0c2h	; 8372  YX..0...n...otu.
	defb 0ffh,00ah,030h,079h,0ffh,007h,003h,088h,003h,076h,0ffh,00ah,030h,0cbh,0e5h,0ffh	; 8382  ..0y.....v..0...
	defb 005h,003h,072h,07bh,078h,077h,0ffh,043h,030h	; 8392  ..r{xw.C0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_06_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   6; lo comparten tambien los hoyo.tramo 16.0. Comprimido con 0xA8FB (53
;   bytes fuente, 105 de salida).
;   0x839b..0x83d0  (53 bytes)
DATA_vista_hoyo_06_cielo:
	defb 033h,000h,0ffh,018h,014h,010h,011h,013h,0ffh,005h,014h,008h,009h,00ah,00bh,00bh	; 839b  3...............
	defb 00ch,014h,010h,013h,0ffh,00ch,014h,020h,021h,00dh,00eh,00eh,00fh,0ffh,019h,014h	; 83ab  ....... !.......
	defb 015h,016h,017h,018h,01ah,01dh,01eh,01fh,019h,01ah,017h,018h,01fh,01ah,018h,024h	; 83bb  ...............$
	defb 025h,025h,0ffh,003h,026h	; 83cb

; ----------------------------------------------------------------------
; DATOS vista_hoyo_06_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 6; lo
;   comparten tambien los hoyo.tramo 16.1. Comprimido con 0xA8FB (163 bytes
;   fuente, 294 de salida).
;   0x83d0..0x8473  (163 bytes)
DATA_vista_hoyo_06_tramo_1:
	defb 0a1h,000h,003h,003h,034h,003h,032h,049h,0a0h,0afh,0aeh,07fh,07fh,04ah,02eh,046h	; 83d0  ....4.2I.....J.F
	defb 0a4h,0a5h,0d9h,07ch,034h,003h,003h,036h,038h,035h,0cbh,0d2h,047h,048h,030h,0dbh	; 83e0  ...|4..685..GH0.
	defb 0cfh,0a8h,0d2h,0ffh,003h,030h,07dh,07fh,02fh,035h,036h,038h,037h,039h,003h,0d1h	; 83f0  .....0}./56879..
	defb 0a9h,0aah,0aah,0abh,036h,038h,003h,0c2h,0d2h,0ffh,004h,030h,07dh,09dh,037h,039h	; 8400  ....68.....0}.79
	defb 03ah,03dh,040h,0ffh,005h,003h,037h,039h,0c2h,0a1h,07eh,0ffh,005h,030h,07dh,02fh	; 8410  :=@...79..~..0}/
	defb 07ch,03bh,03eh,041h,0ffh,006h,003h,031h,09fh,043h,044h,0ffh,006h,030h,07dh,09dh	; 8420  |;>A...1.CD..0}.
	defb 03ch,03fh,042h,003h,003h,0c2h,0adh,049h,033h,0d5h,0d6h,045h,0ddh,0ffh,007h,030h	; 8430  <?B....I3..E...0
	defb 07dh,003h,003h,0c2h,031h,033h,06ch,07eh,030h,030h,06ah,06bh,045h,045h,0b0h,0ffh	; 8440  }...13l~00jkEE..
	defb 007h,030h,032h,049h,033h,07eh,0ffh,011h,030h,07eh,0ffh,055h,030h,004h,003h,006h	; 8450  .02I3~..0~.U0...
	defb 0ffh,00ch,003h,006h,003h,005h,030h,000h,001h,003h,003h,007h,0ffh,00ch,003h,007h	; 8460  ......0.........
	defb 003h,003h,002h	; 8470

; ----------------------------------------------------------------------
; DATOS vista_hoyo_06_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 6; lo
;   comparten tambien los hoyo.tramo 16.2. Comprimido con 0xA8FB (216 bytes
;   fuente, 294 de salida).
;   0x8473..0x854b  (216 bytes)
DATA_vista_hoyo_06_tramo_2:
	defb 0d6h,000h,003h,036h,038h,034h,003h,0c2h,0c3h,0adh,049h,0ceh,0ceh,046h,0a4h,07ch	; 8473  ...684....I..F.|
	defb 0ffh,004h,003h,036h,038h,003h,003h,037h,039h,035h,031h,033h,07eh,030h,030h,043h	; 8483  ...68..79513~00C
	defb 04bh,044h,07dh,04ah,02eh,046h,0a4h,0a5h,037h,039h,003h,003h,0c2h,031h,033h,07eh	; 8493  KD}J.F..79...13~
	defb 0ffh,003h,030h,0c5h,0c6h,085h,086h,0ffh,005h,030h,07dh,02ch,02bh,07ch,0c2h,09fh	; 84a3  ..0......0},+|..
	defb 07eh,030h,0bah,0b7h,003h,0b8h,0b9h,0ffh,00ah,030h,07dh,02ch,0d1h,0dah,0d2h,0ffh	; 84b3  ~0.......0},....
	defb 007h,030h,0d0h,0d0h,0d2h,0ffh,008h,030h,036h,038h,0a6h,0a7h,0a8h,0d0h,0d0h,0dbh	; 84c3  .0.....068......
	defb 0dch,0abh,036h,038h,0d8h,0ffh,008h,030h,037h,039h,0ffh,005h,003h,036h,038h,003h	; 84d3  ..68...079...68.
	defb 037h,039h,0a1h,07eh,0ffh,007h,030h,03ah,03dh,040h,0ffh,004h,003h,037h,039h,0c2h	; 84e3  79.~..0:=@...79.
	defb 032h,033h,07eh,0ffh,008h,030h,03bh,03eh,041h,0ffh,005h,003h,0c2h,09eh,07eh,0ffh	; 84f3  23~..0;>A.....~.
	defb 00ah,030h,03ch,03fh,042h,0ffh,004h,003h,0c2h,0a1h,07eh,0d5h,0d6h,0d7h,0c4h,0c8h	; 8503  .0<?B.....~.....
	defb 0ffh,006h,030h,0ffh,005h,003h,0c2h,031h,033h,043h,087h,0ffh,004h,045h,0c9h,0ffh	; 8513  ..0....13C...E..
	defb 006h,030h,0ffh,003h,003h,0c2h,032h,033h,07eh,030h,0ffh,006h,045h,0b0h,0ffh,006h	; 8523  .0....23~0..E...
	defb 030h,003h,0c2h,032h,033h,07eh,0ffh,003h,030h,06ah,06bh,045h,045h,0a3h,0a2h,0ffh	; 8533  0..23~..0jkEE...
	defb 007h,030h,033h,06ch,07eh,0ffh,012h,030h	; 8543  .03l~..0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_06_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 6; lo
;   comparten tambien los hoyo.tramo 16.3. Comprimido con 0xA8FB (126 bytes
;   fuente, 294 de salida).
;   0x854b..0x85c9  (126 bytes)
DATA_vista_hoyo_06_tramo_3:
	defb 07ch,000h,0ffh,005h,003h,0c2h,0c3h,0adh,049h,0ffh,004h,0ceh,046h,0a4h,0a5h,07ch	; 854b  |.......I...F..|
	defb 0ffh,006h,003h,0c2h,032h,049h,033h,07eh,0ffh,008h,030h,07dh,02ch,046h,0a4h,0a5h	; 855b  ....2I3~..0},F..
	defb 07ch,031h,049h,033h,07eh,0ffh,008h,030h,0b3h,0b4h,0b5h,0b6h,0cdh,089h,030h,07dh	; 856b  |1I3~..0......0}
	defb 02ch,07eh,0ffh,00ah,030h,0c5h,0c6h,0ffh,004h,085h,086h,0ffh,006h,030h,0beh,0bdh	; 857b  ,~..0........0..
	defb 0bbh,06eh,0ffh,004h,003h,06fh,074h,075h,0bch,0ffh,009h,030h,079h,003h,003h,088h	; 858b  .n...otu...0y...
	defb 0ffh,007h,003h,076h,0ffh,009h,030h,0bfh,0c0h,0c1h,07ah,0ffh,004h,003h,072h,07bh	; 859b  ...v..0...z...r{
	defb 078h,077h,0ffh,05ah,030h,0a7h,0a8h,0d2h,0ffh,012h,030h,003h,003h,0a9h,0a7h,0a8h	; 85ab  xw.Z0.....0.....
	defb 0d2h,0ffh,00fh,030h,0ffh,005h,003h,0a9h,0a7h,0a8h,0d2h,0ffh,00ch,030h	; 85bb  ...0.........0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_06_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 6; lo
;   comparten tambien los hoyo.tramo 16.4. Comprimido con 0xA8FB (179 bytes
;   fuente, 294 de salida).
;   0x85c9..0x867c  (179 bytes)
DATA_vista_hoyo_06_tramo_4:
	defb 0b1h,000h,003h,003h,036h,038h,003h,034h,0ffh,003h,003h,0c2h,0c3h,0adh,049h,0ceh	; 85c9  ....68.4......I.
	defb 0ceh,02bh,07ch,034h,003h,034h,003h,03dh,040h,037h,039h,003h,035h,032h,049h,033h	; 85d9  .+|4.4.=@79.52I3
	defb 06ch,07eh,030h,030h,0b1h,0b2h,030h,0ach,035h,003h,035h,003h,03eh,041h,003h,0c2h	; 85e9  l~00..0.5.5.>A..
	defb 031h,033h,07eh,0ffh,004h,030h,0dbh,0dbh,0dch,0aah,0abh,036h,038h,0ffh,003h,003h	; 85f9  13~..0.....68...
	defb 03fh,042h,032h,033h,07eh,0ffh,005h,030h,0d3h,0abh,0d4h,0ffh,003h,003h,037h,039h	; 8609  ?B23~..0......79
	defb 003h,03ah,03dh,031h,033h,07eh,0ffh,006h,030h,07dh,09dh,07ch,0ffh,007h,003h,03bh	; 8619  .:=13~..0}.|...;
	defb 03eh,07eh,0ffh,009h,030h,07dh,02dh,0ffh,004h,046h,0a4h,0a5h,07ch,03ch,03fh,0ffh	; 8629  >~..0}-..F..|<?.
	defb 011h,030h,07dh,02ch,046h,02bh,0ffh,007h,030h,0beh,0bdh,0bbh,06eh,0ffh,004h,003h	; 8639  .0},F+..0...n...
	defb 06fh,074h,075h,0bch,030h,07dh,0ffh,007h,030h,079h,0ffh,008h,003h,088h,003h,076h	; 8649  otu.0}..0y.....v
	defb 0ffh,009h,030h,0bfh,0c0h,0c1h,07ah,0ffh,004h,003h,072h,07bh,078h,077h,0ffh,005h	; 8659  ..0...z...r{xw..
	defb 030h,0cch,0ffh,004h,04bh,087h,0b0h,0ffh,00eh,030h,06ah,06bh,045h,045h,0cah,0c7h	; 8669  0...K....0jkEE..
	defb 0ffh,036h,030h	; 8679

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_cielo: Mapa de indices de la VISTA en perspectiva: las
;   CINCO filas de arriba (21x5=105 bytes), el cielo y el horizonte del hoyo
;   18. Comprimido con 0xA8FB (53 bytes fuente, 105 de salida).
;   0x867c..0x86b1  (53 bytes)
DATA_vista_hoyo_18_cielo:
	defb 033h,000h,0ffh,018h,014h,010h,011h,012h,013h,0ffh,004h,014h,008h,00bh,009h,00ah	; 867c  3...............
	defb 00bh,00ch,0ffh,00ah,014h,010h,013h,0ffh,003h,014h,020h,00eh,021h,00dh,00eh,00fh	; 868c  .......... .!...
	defb 0ffh,019h,014h,09bh,022h,023h,01bh,09bh,022h,017h,019h,01ah,018h,01fh,024h,0ffh	; 869c  ...."#..".....$.
	defb 003h,025h,0ffh,006h,026h	; 86ac

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_tramo_1: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 1 del hoyo 18.
;   Comprimido con 0xA8FB (238 bytes fuente, 294 de salida).
;   0x86b1..0x879f  (238 bytes)
DATA_vista_hoyo_18_tramo_1:
	defb 0ech,000h,0ffh,009h,003h,034h,0ffh,006h,003h,034h,0ffh,007h,003h,036h,038h,036h	; 86b1  .....4...4...686
	defb 038h,003h,034h,035h,003h,08dh,08eh,08fh,060h,003h,035h,0ffh,004h,003h,03ah,03dh	; 86c1  8.45....`.5...:=
	defb 040h,037h,039h,037h,039h,003h,035h,0c2h,050h,08bh,047h,048h,0c7h,0c3h,036h,038h	; 86d1  @7979.5.P.GH..68
	defb 03ah,03dh,040h,03bh,03eh,041h,003h,08dh,0ffh,003h,08eh,050h,029h,02ah,08ch,0aah	; 86e1  :=@;>A.....P)*..
	defb 056h,057h,0a9h,037h,039h,03bh,03eh,041h,03ch,03fh,042h,0cdh,02ah,029h,0ffh,003h	; 86f1  VW.79;>A<?B.*)..
	defb 02ah,029h,028h,02ah,096h,0ffh,003h,030h,02fh,003h,03ch,03fh,042h,003h,003h,0cch	; 8701  *)(*...0/.<?B...
	defb 028h,02ah,057h,05ah,0abh,063h,029h,02ah,028h,02ah,02ah,055h,0a1h,056h,0d2h,0d3h	; 8711  (*WZ.c)*(**U.V..
	defb 003h,003h,0c2h,050h,02ah,02ah,029h,08ah,0ffh,006h,030h,092h,062h,059h,059h,058h	; 8721  ...P**)...0.bYYX
	defb 029h,029h,0c3h,003h,02ah,028h,028h,029h,02ah,02ah,064h,0ffh,003h,030h,0a5h,04bh	; 8731  ))..*(()**d..0.K
	defb 0c1h,0ffh,005h,030h,0c6h,02ah,0c8h,0ffh,003h,02ah,029h,029h,02ah,02ah,0c8h,0ffh	; 8741  ...0.*...*))**..
	defb 004h,069h,065h,0ffh,003h,030h,094h,095h,02ah,029h,0ffh,003h,02ah,028h,02ah,02ah	; 8751  .ie..0..*)..*(**
	defb 029h,0ffh,007h,02ah,0c8h,069h,056h,02ah,029h,028h,0ffh,005h,02ah,028h,057h,0abh	; 8761  )..*.iV*)(..*(W.
	defb 0abh,05ah,082h,0ffh,006h,030h,092h,062h,063h,02ah,02ah,029h,05bh,0a6h,081h,082h	; 8771  .Z...0.bc**)[...
	defb 0ffh,00eh,030h,098h,093h,097h,030h,030h,004h,003h,006h,0ffh,00ch,003h,006h,003h	; 8781  ..0...00........
	defb 005h,030h,000h,001h,003h,003h,007h,0ffh,00ch,003h,007h,003h,003h,002h	; 8791  .0............

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_tramo_2: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 2 del hoyo 18.
;   Comprimido con 0xA8FB (250 bytes fuente, 294 de salida).
;   0x879f..0x8899  (250 bytes)
DATA_vista_hoyo_18_tramo_2:
	defb 0f8h,000h,0ffh,003h,003h,034h,0ffh,005h,003h,08dh,08eh,0ffh,003h,090h,08eh,08fh	; 879f  .....4..........
	defb 003h,003h,034h,0ffh,003h,003h,036h,038h,035h,0c2h,04dh,04dh,04eh,04fh,029h,097h	; 87af  ..4...685.MMNO).
	defb 0ffh,004h,0abh,059h,058h,0c3h,035h,036h,038h,003h,037h,039h,003h,0c9h,02ah,029h	; 87bf  ...YX.568.79..*)
	defb 02ah,029h,080h,030h,0b1h,0b2h,0aeh,0afh,0b0h,030h,0c6h,0c3h,037h,039h,0ffh,003h	; 87cf  *).0.....0..79..
	defb 003h,0c2h,050h,02ah,02ah,028h,096h,0ffh,004h,030h,051h,052h,053h,054h,0a7h,0a8h	; 87df  ..P**(...0QRST..
	defb 003h,003h,04ch,04dh,050h,02ah,029h,029h,02ah,02ah,028h,0ffh,004h,02ah,057h,05ah	; 87ef  ..LMP*))**(..*WZ
	defb 0a9h,0a8h,003h,03ah,03dh,040h,029h,02ah,029h,028h,0ffh,003h,02ah,028h,02ah,02ah	; 87ff  ...:=@)*)(..*(**
	defb 081h,082h,0ffh,004h,030h,02ch,02ch,03bh,03eh,041h,028h,0ffh,003h,02ah,028h,0ffh	; 880f  ....0,,;>A(..*(.
	defb 005h,02ah,0c8h,0bah,0bbh,0ffh,005h,030h,03ch,03fh,042h,0ffh,003h,02ah,057h,0ffh	; 881f  .*.....0<?B..*W.
	defb 003h,0abh,093h,02ah,029h,02ah,029h,028h,067h,0c0h,069h,065h,030h,09dh,02bh,003h	; 882f  ...*)*)(g.ie0.+.
	defb 029h,097h,082h,0ffh,005h,030h,092h,0ceh,029h,0ffh,005h,02ah,028h,067h,066h,065h	; 883f  )....0..)..*(gfe
	defb 02fh,0cbh,0ffh,009h,030h,092h,0ceh,02ah,02ah,028h,02ah,029h,028h,02ah,02ah,064h	; 884f  /...0..**(*)(**d
	defb 0ffh,00ch,030h,092h,062h,0abh,063h,02ah,029h,02ah,028h,02ah,0ffh,005h,030h,043h	; 885f  ..0.b.c*)*(*..0C
	defb 04bh,089h,0ffh,008h,030h,092h,0ceh,02ah,02ah,029h,08ah,0ffh,004h,030h,0bch,0ffh	; 886f  K...0..**)...0..
	defb 003h,045h,084h,0c1h,0ffh,007h,030h,098h,0ffh,003h,02ah,055h,066h,065h,030h,030h	; 887f  .E....0...*Ufe00
	defb 0bdh,0beh,085h,0a0h,0ffh,008h,030h,0c5h,029h,02ah	; 888f  ......0.)*

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_tramo_3: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 3 del hoyo 18.
;   Comprimido con 0xA8FB (241 bytes fuente, 294 de salida).
;   0x8899..0x898a  (241 bytes)
DATA_vista_hoyo_18_tramo_3:
	defb 0efh,000h,0ffh,003h,003h,034h,0ffh,005h,003h,0ffh,006h,08eh,08fh,060h,0ffh,003h	; 8899  .....4.......`..
	defb 003h,036h,003h,036h,038h,035h,04ch,04dh,04eh,04fh,028h,057h,0abh,0ffh,005h,05ah	; 88a9  .6.685LMNO(W...Z
	defb 093h,028h,05eh,05fh,037h,003h,037h,039h,003h,0c9h,02ah,029h,081h,082h,030h,06dh	; 88b9  .(^_7.79..*)..0m
	defb 06eh,003h,07ah,003h,06fh,070h,030h,098h,02ah,05eh,0ffh,003h,003h,0c2h,050h,02ah	; 88c9  n.z.op0.*^....P*
	defb 0cfh,0ffh,003h,030h,071h,07ah,0ffh,003h,003h,072h,073h,030h,0c5h,02ah,0a7h,08dh	; 88d9  ...0qz...rs0.*..
	defb 08eh,050h,0ffh,003h,02ah,028h,0c8h,069h,0bah,0bbh,0ffh,005h,030h,094h,095h,0a7h	; 88e9  .P..*(.i....0...
	defb 0a8h,003h,02ah,02ah,028h,02ah,029h,0ffh,004h,02ah,028h,0ffh,003h,02ah,029h,028h	; 88f9  ..**(*)..*(..*)(
	defb 0a6h,0a7h,0a8h,03ah,03dh,040h,02ah,02ah,029h,02ah,02ah,028h,0ffh,005h,02ah,057h	; 8909  ...:=@**)**(..*W
	defb 0abh,082h,0cbh,030h,02ch,02bh,03bh,03eh,041h,02ah,029h,02ah,028h,0ffh,003h,02ah	; 8919  ...0,+;>A*)*(..*
	defb 029h,02ah,02ah,08bh,0ffh,006h,030h,0d0h,03ch,03fh,042h,097h,061h,082h,030h,092h	; 8929  )**...0.<?B.a.0.
	defb 0bfh,093h,02ah,029h,02ah,08ah,0bbh,0ffh,006h,030h,09dh,003h,003h,0ffh,007h,030h	; 8939  ..*)*....0.....0
	defb 0c4h,029h,02ah,029h,029h,02ah,055h,0c0h,069h,0bah,0bbh,030h,02fh,003h,0ffh,008h	; 8949  .)*))*U.i..0/...
	defb 030h,098h,093h,02ah,02ah,029h,028h,0ffh,004h,02ah,0c8h,065h,09eh,0ffh,00ah,030h	; 8959  0..**)(..*.e...0
	defb 098h,093h,029h,02ah,028h,02ah,029h,029h,02ah,02ah,05eh,0ffh,00ch,030h,098h,093h	; 8969  ..)*(*))**^..0..
	defb 029h,02ah,029h,02ah,02ah,028h,02ah,0ffh,00eh,030h,092h,0bfh,093h,0ffh,003h,02ah	; 8979  )*)**(*..0.....*
	defb 029h	; 8989

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_tramo_4: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 4 del hoyo 18.
;   Comprimido con 0xA8FB (217 bytes fuente, 294 de salida).
;   0x898a..0x8a63  (217 bytes)
DATA_vista_hoyo_18_tramo_4:
	defb 0d7h,000h,0ffh,017h,003h,08dh,08eh,090h,04dh,04eh,04fh,02ah,029h,029h,02ah,02ah	; 898a  ........MNO*))**
	defb 05eh,0ffh,003h,08eh,05fh,060h,003h,003h,04ch,050h,02ah,029h,029h,097h,0abh,05ah	; 899a  ^..._`..LP*))..Z
	defb 061h,082h,0ffh,003h,030h,092h,0bfh,0abh,093h,02ah,02ah,05eh,05fh,02ah,028h,02ah	; 89aa  a...0....**^_*(*
	defb 097h,082h,030h,030h,0b6h,0b5h,0b3h,06eh,0ffh,003h,003h,074h,075h,0b4h,092h,062h	; 89ba  ..00...n...tu..b
	defb 093h,028h,02ah,028h,08bh,0ffh,004h,030h,079h,0ffh,004h,003h,088h,0ffh,003h,003h	; 89ca  .(*(...0y.......
	defb 076h,0ffh,003h,030h,0c6h,028h,08bh,0ffh,005h,030h,0b7h,0b8h,0b9h,07ah,0ffh,003h	; 89da  v..0.(...0...z..
	defb 003h,07bh,078h,077h,030h,030h,0c5h,02ah,02ah,08ah,0ffh,00fh,030h,094h,095h,02ah	; 89ea  .{xw00.**...0..*
	defb 029h,02ah,029h,055h,0aah,069h,068h,0ffh,006h,030h,051h,052h,052h,053h,056h,029h	; 89fa  )*)U.ih..0QRRSV)
	defb 02ah,029h,0ffh,004h,02ah,0ffh,003h,028h,055h,0aah,069h,052h,053h,056h,029h,028h	; 8a0a  *)..*..(U.iRSV)(
	defb 029h,02ah,029h,0ffh,003h,02ah,080h,028h,0ffh,00ah,02ah,029h,0ffh,003h,02ah,028h	; 8a1a  )*)..*.(..*)..*(
	defb 02ah,02ah,081h,082h,030h,0ffh,005h,02ah,029h,0ffh,004h,02ah,028h,02ah,029h,029h	; 8a2a  **..0..*)..*(*))
	defb 02ah,02ah,097h,082h,0ffh,003h,030h,02ah,02ah,028h,0ffh,004h,02ah,057h,0ffh,003h	; 8a3a  **....0**(..*W..
	defb 059h,0ffh,003h,05ah,082h,0ffh,006h,030h,02ah,029h,02ah,029h,057h,059h,083h,0ffh	; 8a4a  Y..Z...0*)*)WY..
	defb 00eh,030h,02ah,02ah,029h,080h,0ffh,011h,030h	; 8a5a  .0**)...0

; ----------------------------------------------------------------------
; DATOS vista_hoyo_18_tramo_5: Mapa de indices de la VISTA en perspectiva: las
;   CATORCE filas de suelo (21x14=294 bytes) del tramo 5 del hoyo 18.
;   Comprimido con 0xA8FB (251 bytes fuente, 294 de salida).
;   0x8a63..0x8b5e  (251 bytes)
DATA_vista_hoyo_18_tramo_5:
	defb 0f9h,000h,003h,003h,036h,038h,034h,0ffh,003h,003h,08dh,08fh,032h,02bh,08dh,08fh	; 8a63  ....684.....2+..
	defb 003h,003h,034h,036h,038h,003h,003h,03dh,040h,037h,039h,035h,0c2h,04dh,04fh,02ah	; 8a73  ..468..=@795.MO*
	defb 0cfh,0ach,0adh,0c6h,02ah,05eh,05fh,035h,037h,039h,03ah,03dh,03eh,041h,003h,0c2h	; 8a83  ....*^_579:=>A..
	defb 050h,028h,057h,059h,059h,058h,02ah,029h,02ah,029h,02ah,02ah,0c3h,003h,003h,03bh	; 8a93  P(WYYX*)*)**...;
	defb 03eh,03fh,042h,0d1h,02ah,02ah,096h,0ffh,004h,030h,092h,0bfh,0bfh,093h,02ah,028h	; 8aa3  >?B.**...0....*(
	defb 029h,05eh,05fh,03ch,03fh,003h,003h,031h,033h,062h,063h,0c8h,0ffh,004h,069h,065h	; 8ab3  )^_<?..13bc...ie
	defb 030h,030h,0c6h,029h,0ffh,003h,02ah,091h,090h,003h,09fh,0ffh,005h,030h,092h,0bfh	; 8ac3  00.)..*......0..
	defb 093h,029h,029h,067h,056h,029h,02ah,028h,02ah,029h,028h,02ah,003h,0a3h,0a2h,0ffh	; 8ad3  .))gV)*(*)(*....
	defb 007h,030h,098h,093h,028h,0ffh,006h,02ah,0a6h,0a7h,003h,003h,0a4h,030h,030h,051h	; 8ae3  .0..(..*.....00Q
	defb 052h,0ffh,003h,069h,0aah,056h,02ah,02ah,029h,02ah,028h,02ah,0cah,0ffh,004h,003h	; 8af3  R..i.V**)*(*....
	defb 0c2h,050h,029h,029h,0ffh,009h,02ah,028h,02ah,02ah,091h,090h,08eh,0c2h,050h,057h	; 8b03  .P))..*(**....PW
	defb 059h,05ah,082h,0ffh,007h,030h,092h,062h,063h,028h,0ffh,004h,02ah,081h,082h,030h	; 8b13  YZ...0.bc(..*..0
	defb 030h,0b6h,0b5h,0b3h,06eh,0ffh,003h,003h,06fh,074h,075h,0b4h,030h,05bh,05ch,029h	; 8b23  0...n...otu.0[\)
	defb 029h,02ah,0ffh,004h,030h,079h,0ffh,004h,003h,088h,0ffh,004h,003h,076h,0ffh,003h	; 8b33  )*..0y.......v..
	defb 030h,0c4h,02ah,028h,0ffh,004h,030h,0b7h,0b8h,0b9h,07ah,0ffh,003h,003h,072h,07bh	; 8b43  0.*(..0...z...r{
	defb 078h,077h,0ffh,004h,030h,0c4h,02ah,0ffh,014h,030h,0c4h	; 8b53  xw..0.*..0.

; ----------------------------------------------------------------------
; DATOS tabla_patrones_terreno: 570 patrones de 8x8 sin comprimir, indexados
;   por el codigo de tile del buffer 0xE800 desde 0x5E66 (0x5E78)
;   0x8b5e..0x9d2e  (4560 bytes)
DATA_tabla_patrones_terreno:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8b5e  ........
	defb 000h,001h,003h,007h,00fh,01fh,03fh,07fh	; 8b66  ......?.
	defb 000h,080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh	; 8b6e  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8b76  ........
	defb 001h,003h,007h,00fh,01fh,03fh,07fh,000h	; 8b7e  .....?..
	defb 080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh,000h	; 8b86  ........
	defb 000h,000h,000h,000h,0c3h,081h,000h,000h	; 8b8e  ........
	defb 000h,000h,081h,0c3h,000h,000h,000h,000h	; 8b96  ........
	defb 000h,000h,001h,001h,001h,003h,003h,003h	; 8b9e  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8ba6  ........
	defb 000h,000h,000h,0e1h,0c0h,080h,000h,000h	; 8bae  ........
	defb 0f8h,0e0h,0c0h,080h,000h,000h,000h,000h	; 8bb6  ........
	defb 01fh,007h,003h,001h,000h,000h,000h,000h	; 8bbe  ........
	defb 000h,000h,0c7h,083h,001h,000h,000h,000h	; 8bc6  ........
	defb 000h,000h,000h,000h,09fh,007h,001h,000h	; 8bce  ........
	defb 000h,000h,000h,000h,000h,000h,001h,007h	; 8bd6  ........
	defb 000h,000h,000h,001h,003h,087h,000h,000h	; 8bde  ........
	defb 000h,000h,001h,08fh,000h,000h,000h,000h	; 8be6  ........
	defb 000h,000h,0e1h,0c0h,000h,000h,082h,000h	; 8bee  ........
	defb 000h,0fch,0f0h,000h,000h,000h,000h,080h	; 8bf6  ........
	defb 087h,001h,000h,000h,000h,000h,018h,0fch	; 8bfe  ........
	defb 000h,0c3h,001h,000h,000h,001h,003h,00fh	; 8c06  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8c0e  ........
	defb 000h,000h,000h,000h,000h,000h,00fh,000h	; 8c16  ........
	defb 000h,000h,000h,000h,007h,03fh,000h,000h	; 8c1e  .....?..
	defb 000h,000h,007h,03fh,000h,000h,000h,000h	; 8c26  ...?....
	defb 001h,00fh,000h,000h,000h,000h,000h,000h	; 8c2e  ........
	defb 0f8h,000h,000h,000h,000h,000h,000h,000h	; 8c36  ........
	defb 000h,000h,0c0h,0f8h,000h,000h,000h,000h	; 8c3e  ........
	defb 000h,000h,000h,000h,0c3h,000h,000h,000h	; 8c46  ........
	defb 000h,003h,00fh,07fh,000h,000h,000h,000h	; 8c4e  ........
	defb 000h,000h,000h,000h,080h,0e0h,000h,000h	; 8c56  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8c5e  ........
	defb 001h,007h,01fh,000h,000h,000h,000h,000h	; 8c66  ........
	defb 0f8h,000h,000h,000h,000h,000h,000h,000h	; 8c6e  ........
	defb 000h,000h,0f8h,000h,000h,000h,000h,000h	; 8c76  ........
	defb 000h,000h,000h,0c0h,000h,000h,000h,000h	; 8c7e  ........
	defb 000h,080h,080h,0e0h,000h,000h,000h,000h	; 8c86  ........
	defb 000h,000h,000h,000h,0e0h,0f0h,0f8h,000h	; 8c8e  ........
	defb 01fh,01fh,01fh,01fh,03fh,03fh,03fh,03fh	; 8c96  ....????
	defb 03fh,03fh,03fh,03fh,03fh,07fh,07fh,07fh	; 8c9e  ?????...
	defb 07fh,07fh,07fh,07fh,07fh,000h,000h,000h	; 8ca6  ........
	defb 003h,00fh,01fh,03fh,000h,000h,000h,000h	; 8cae  ...?....
	defb 0c0h,0e0h,0f0h,0f8h,000h,000h,000h,000h	; 8cb6  ........
	defb 000h,000h,000h,000h,000h,080h,0feh,000h	; 8cbe  ........
	defb 000h,000h,000h,000h,000h,0dfh,0fbh,000h	; 8cc6  ........
	defb 000h,000h,000h,000h,000h,0dfh,0fbh,000h	; 8cce  ........
	defb 000h,000h,000h,000h,000h,001h,07fh,000h	; 8cd6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8cde  ........
	defb 000h,000h,0dfh,000h,000h,0ffh,000h,000h	; 8ce6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8cee  ........
	defb 03fh,0efh,01fh,05bh,08fh,023h,009h,022h	; 8cf6  ?..[.#."
	defb 0dfh,000h,057h,0bfh,055h,0afh,04ah,003h	; 8cfe  ..W.U.J.
	defb 000h,0d7h,0bdh,02fh,08ah,00dh,022h,000h	; 8d06  .../..".
	defb 000h,03fh,08bh,005h,040h,014h,001h,000h	; 8d0e  .?..@...
	defb 0bfh,0ddh,02bh,052h,005h,000h,000h,000h	; 8d16  ..+R....
	defb 000h,000h,0bfh,000h,06fh,0bfh,06fh,05bh	; 8d1e  ....o.o[
	defb 0dfh,0abh,015h,042h,011h,004h,000h,000h	; 8d26  ...B....
	defb 05bh,0a7h,009h,022h,000h,001h,000h,000h	; 8d2e  [.."....
	defb 07fh,05dh,0abh,017h,04bh,003h,015h,000h	; 8d36  .]..K...
	defb 000h,0dfh,0bbh,037h,08dh,013h,004h,001h	; 8d3e  ...7....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8d46  ........
	defb 000h,0fdh,000h,0ebh,07eh,0edh,0b2h,0c8h	; 8d4e  ....~...
	defb 000h,000h,000h,0fah,0d7h,0ech,0b2h,048h	; 8d56  .......H
	defb 0d7h,07ch,0b1h,0cah,020h,080h,000h,000h	; 8d5e  .|.. ...
	defb 0beh,0d8h,0a4h,0d0h,0a0h,040h,080h,040h	; 8d66  .....@.@
	defb 0f6h,0dch,072h,0c4h,010h,080h,000h,000h	; 8d6e  ..r.....
	defb 000h,000h,000h,000h,0edh,0fbh,0feh,0d8h	; 8d76  ........
	defb 0bah,0e4h,091h,044h,028h,000h,000h,000h	; 8d7e  ...D(...
	defb 0feh,0fah,0b4h,0fdh,0b8h,0f2h,0c8h,010h	; 8d86  ........
	defb 0fdh,0fbh,0bfh,0ech,0b2h,0c4h,010h,040h	; 8d8e  .......@
	defb 0e7h,0dbh,0a5h,003h,0a4h,001h,000h,081h	; 8d96  ........
	defb 0e7h,0e7h,0c3h,000h,000h,000h,000h,000h	; 8d9e  ........
	defb 0fch,0f8h,0f8h,0fch,0c2h,0c0h,0f1h,0cah	; 8da6  ........
	defb 084h,099h,044h,082h,0c0h,0fch,0fch,0f8h	; 8dae  ..D.....
	defb 000h,07fh,05fh,08fh,00fh,0dbh,021h,011h	; 8db6  .._...!.
	defb 01fh,021h,040h,041h,003h,07fh,07fh,03fh	; 8dbe  .!@A...?
	defb 000h,000h,000h,000h,000h,0fch,0f8h,0fch	; 8dc6  ........
	defb 0f2h,0e1h,0c0h,0ech,0d2h,0a1h,098h,0c4h	; 8dce  ........
	defb 082h,001h,080h,0c0h,0e0h,0f3h,000h,000h	; 8dd6  ........
	defb 0e7h,0c3h,0cfh,0e1h,001h,002h,004h,018h	; 8dde  ........
	defb 024h,042h,011h,000h,0e0h,010h,008h,018h	; 8de6  $B......
	defb 024h,002h,000h,000h,0c3h,0c3h,081h,000h	; 8dee  $.......
	defb 000h,000h,000h,000h,07fh,03fh,01fh,07fh	; 8df6  .....?..
	defb 03fh,01fh,00fh,07fh,08bh,081h,01ch,022h	; 8dfe  ?......"
	defb 021h,040h,049h,003h,027h,0cfh,000h,000h	; 8e06  !@I.'...
	defb 0d3h,081h,024h,001h,080h,012h,081h,0cbh	; 8e0e  ..$.....
	defb 0f3h,0e1h,0c0h,080h,080h,000h,000h,001h	; 8e16  ........
	defb 003h,003h,083h,083h,083h,0c3h,0c7h,0e7h	; 8e1e  ........
	defb 000h,000h,000h,0e3h,0c1h,080h,080h,080h	; 8e26  ........
	defb 0c0h,0e0h,0e1h,0e1h,0c3h,083h,087h,0cfh	; 8e2e  ........
	defb 000h,000h,003h,0f8h,0f0h,0e0h,0e0h,0c0h	; 8e36  ........
	defb 000h,000h,0e0h,007h,003h,0bfh,0efh,0fbh	; 8e3e  ........
	defb 000h,000h,000h,000h,003h,0f0h,0fbh,0dfh	; 8e46  ........
	defb 000h,000h,000h,000h,0f0h,007h,003h,001h	; 8e4e  ........
	defb 080h,080h,0efh,0fdh,080h,0c0h,0f1h,000h	; 8e56  ........
	defb 0fbh,0bfh,000h,0f7h,000h,000h,0f0h,0fch	; 8e5e  ........
	defb 0f7h,0dfh,001h,003h,003h,007h,00fh,01fh	; 8e66  ........
	defb 0fbh,0c0h,000h,000h,000h,000h,000h,000h	; 8e6e  ........
	defb 01fh,0c0h,000h,000h,000h,000h,000h,000h	; 8e76  ........
	defb 000h,080h,080h,0c0h,0c0h,0c0h,080h,000h	; 8e7e  ........
	defb 000h,000h,000h,080h,080h,080h,080h,000h	; 8e86  ........
	defb 000h,000h,000h,0feh,0feh,0feh,000h,000h	; 8e8e  ........
	defb 000h,000h,0feh,0feh,0fch,0fch,0feh,000h	; 8e96  ........
	defb 000h,000h,000h,0feh,0fch,0f8h,0f8h,0f0h	; 8e9e  ........
	defb 0f0h,0e0h,0e0h,0c0h,0c0h,080h,080h,000h	; 8ea6  ........
	defb 000h,000h,0c0h,000h,000h,000h,000h,000h	; 8eae  ........
	defb 000h,000h,000h,000h,03fh,01fh,00fh,007h	; 8eb6  ....?...
	defb 007h,003h,001h,000h,000h,000h,000h,000h	; 8ebe  ........
	defb 000h,000h,000h,07fh,03fh,01fh,00fh,007h	; 8ec6  ....?...
	defb 007h,007h,007h,007h,007h,007h,007h,007h	; 8ece  ........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,01fh,01fh	; 8ed6  ........
	defb 01fh,01fh,01fh,03fh,03fh,03fh,07fh,07fh	; 8ede  ...???..
	defb 0feh,0feh,0fch,0f8h,0f8h,0f8h,0f8h,0f8h	; 8ee6  ........
	defb 0f8h,0f8h,0f8h,0f8h,0fch,0fch,0feh,0feh	; 8eee  ........
	defb 000h,001h,001h,001h,003h,003h,001h,000h	; 8ef6  ........
	defb 003h,003h,007h,007h,007h,007h,00fh,00fh	; 8efe  ........
	defb 00fh,00fh,00fh,00fh,00fh,01fh,01fh,01fh	; 8f06  ........
	defb 01fh,01fh,01fh,01fh,01fh,000h,000h,000h	; 8f0e  ........
	defb 000h,000h,000h,003h,0f0h,0c0h,080h,012h	; 8f16  ........
	defb 000h,000h,000h,0c0h,007h,001h,000h,004h	; 8f1e  ........
	defb 001h,0f8h,0f0h,0e0h,0c0h,080h,081h,0c7h	; 8f26  ........
	defb 000h,000h,000h,003h,00fh,07fh,000h,000h	; 8f2e  ........
	defb 000h,007h,03fh,000h,000h,000h,000h,000h	; 8f36  ..?.....
	defb 003h,0f0h,0c0h,080h,011h,000h,004h,080h	; 8f3e  ........
	defb 0c0h,00fh,003h,001h,000h,004h,020h,000h	; 8f46  ...... .
	defb 000h,000h,000h,000h,000h,000h,07fh,03fh	; 8f4e  .......?
	defb 03fh,01fh,01fh,01fh,01fh,03fh,03fh,07fh	; 8f56  ?....??.
	defb 020h,001h,003h,00fh,03fh,000h,000h,000h	; 8f5e   ...?...
	defb 000h,000h,000h,000h,010h,003h,03fh,000h	; 8f66  ......?.
	defb 0c0h,0c0h,080h,010h,000h,000h,080h,0c3h	; 8f6e  ........
	defb 0c0h,0e0h,0f0h,0f0h,0f0h,0f0h,0e0h,0e0h	; 8f76  ........
	defb 000h,010h,000h,000h,040h,002h,000h,000h	; 8f7e  ....@...
	defb 003h,0f0h,0c0h,080h,0efh,0fdh,080h,0e1h	; 8f86  ........
	defb 0e0h,007h,0dfh,000h,0fbh,0bfh,000h,0f8h	; 8f8e  ........
	defb 000h,000h,03fh,01fh,0dfh,0fbh,0bfh,000h	; 8f96  ..?.....
	defb 000h,000h,0f0h,0f0h,0dfh,0fbh,0bfh,000h	; 8f9e  ........
	defb 038h,001h,0dfh,0f7h,0fdh,0bfh,0f7h,000h	; 8fa6  8.......
	defb 000h,000h,07fh,01fh,007h,007h,00fh,07fh	; 8fae  ........
	defb 080h,0e0h,0f0h,000h,000h,000h,000h,000h	; 8fb6  ........
	defb 000h,003h,00fh,000h,000h,000h,000h,000h	; 8fbe  ........
	defb 000h,000h,080h,0c0h,0c0h,0e0h,0f0h,000h	; 8fc6  ........
	defb 000h,001h,003h,007h,00fh,03fh,000h,000h	; 8fce  .....?..
	defb 000h,000h,000h,01fh,013h,013h,01fh,01fh	; 8fd6  ........
	defb 000h,000h,000h,0f8h,0c8h,0c8h,0f8h,0f8h	; 8fde  ........
	defb 0ffh,0ffh,0ffh,0ffh,0dbh,0afh,02ah,008h	; 8fe6  ......*.
	defb 000h,000h,000h,000h,07fh,0efh,0d7h,00dh	; 8fee  ........
	defb 0dfh,0fah,0e8h,0b4h,0e0h,0e8h,0f4h,070h	; 8ff6  .......p
	defb 0f5h,0fah,0f9h,0ech,0feh,0ebh,0fdh,000h	; 8ffe  ........
	defb 000h,000h,048h,020h,092h,0a4h,0d9h,0bch	; 9006  ..H ....
	defb 003h,001h,017h,00bh,043h,017h,04fh,03fh	; 900e  ....C.O?
	defb 0f8h,0a4h,0d0h,0c0h,0a8h,080h,040h,000h	; 9016  ......@.
	defb 010h,040h,085h,0a0h,0f4h,0bbh,0dfh,000h	; 901e  .@......
	defb 000h,0a0h,042h,008h,0c0h,0beh,0ebh,0bfh	; 9026  ..B.....
	defb 000h,000h,000h,092h,020h,042h,0f0h,0f7h	; 902e  .... B..
	defb 0a8h,0e1h,0dah,0bfh,0fah,000h,000h,000h	; 9036  ........
	defb 000h,002h,048h,0d7h,0adh,000h,000h,000h	; 903e  ..H.....
	defb 021h,04eh,06bh,0bfh,0d7h,000h,0bfh,000h	; 9046  !Nk.....
	defb 000h,0efh,0bdh,0d7h,08ah,054h,088h,000h	; 904e  .....T..
	defb 03fh,04dh,093h,005h,000h,009h,025h,05fh	; 9056  ?M....%_
	defb 000h,01fh,07fh,0feh,07fh,01fh,000h,000h	; 905e  ........
	defb 000h,0f8h,0feh,03fh,0feh,0f8h,000h,000h	; 9066  ...?....
	defb 013h,00fh,03fh,0dfh,0eeh,03bh,042h,008h	; 906e  ..?..;B.
	defb 000h,000h,000h,0fbh,0f5h,0dbh,0b4h,042h	; 9076  .......B
	defb 050h,0a0h,0d0h,0e8h,0e0h,0d0h,0a8h,040h	; 907e  P......@
	defb 000h,000h,05bh,0f5h,0d2h,020h,052h,000h	; 9086  ..[.. R.
	defb 0c0h,0b5h,072h,0feh,0fbh,0fdh,0feh,0f9h	; 908e  ..r.....
	defb 0f5h,04fh,02ah,044h,000h,000h,000h,000h	; 9096  .O*D....
	defb 0ech,0b0h,040h,080h,050h,000h,0a0h,0e8h	; 909e  ..@.P...
	defb 000h,0feh,000h,0fbh,0eeh,0d5h,0eah,0b8h	; 90a6  ........
	defb 000h,02bh,05fh,037h,08bh,01fh,02fh,01fh	; 90ae  .+_7../.
	defb 08fh,00bh,02fh,005h,017h,00bh,011h,004h	; 90b6  ../.....
	defb 03ch,0c3h,024h,000h,010h,080h,0c0h,0f0h	; 90be  <.$.....
	defb 000h,000h,0c0h,007h,000h,000h,001h,007h	; 90c6  ........
	defb 000h,000h,001h,0fch,0f8h,0f0h,0f8h,000h	; 90ce  ........
	defb 01eh,0e1h,012h,001h,003h,007h,01fh,000h	; 90d6  ........
	defb 000h,000h,000h,0fch,0f0h,0e0h,0c0h,0c7h	; 90de  ........
	defb 000h,000h,000h,000h,000h,020h,004h,000h	; 90e6  ..... ..
	defb 0feh,0fch,0fch,0f8h,0f8h,0f0h,0e0h,080h	; 90ee  ........
	defb 000h,000h,000h,003h,0f8h,0c0h,0f7h,0feh	; 90f6  ........
	defb 000h,000h,000h,001h,09ch,0bdh,0f7h,000h	; 90fe  ........
	defb 000h,000h,007h,0c0h,0dfh,0fdh,0f7h,000h	; 9106  ........
	defb 007h,0f8h,000h,0dfh,0fbh,0efh,0fdh,000h	; 910e  ........
	defb 001h,01fh,0c0h,000h,0edh,0bfh,0f7h,000h	; 9116  ........
	defb 000h,007h,0e0h,080h,0dfh,0f7h,000h,0fdh	; 911e  ........
	defb 000h,000h,000h,000h,000h,000h,03eh,000h	; 9126  ......>.
	defb 000h,000h,000h,000h,000h,01dh,000h,0f7h	; 912e  ........
	defb 000h,000h,000h,000h,007h,018h,0dfh,0fdh	; 9136  ........
	defb 003h,0f8h,0e0h,080h,0dfh,0fdh,0efh,000h	; 913e  ........
	defb 0c0h,00fh,0bfh,000h,0f7h,0dfh,000h,0f7h	; 9146  ........
	defb 001h,00fh,0c0h,000h,0ddh,0f7h,000h,000h	; 914e  ........
	defb 0b7h,003h,00fh,07fh,000h,000h,000h,000h	; 9156  ........
	defb 000h,0efh,000h,0fbh,0bfh,000h,018h,07fh	; 915e  ........
	defb 000h,0efh,0fbh,0bfh,003h,007h,03fh,000h	; 9166  ......?.
	defb 0f7h,001h,003h,00fh,0dfh,000h,000h,000h	; 916e  ........
	defb 000h,0efh,000h,0bbh,000h,003h,007h,03fh	; 9176  .......?
	defb 000h,0fdh,0bfh,0f7h,000h,090h,0fch,000h	; 917e  ........
	defb 000h,0dfh,0fdh,0f7h,000h,07bh,000h,000h	; 9186  .....{..
	defb 000h,0efh,0fdh,000h,03bh,000h,000h,000h	; 918e  ....;...
	defb 0d7h,003h,04fh,00fh,003h,001h,000h,000h	; 9196  ..O.....
	defb 0fdh,0dfh,080h,080h,0c0h,0e0h,0fch,000h	; 919e  ........
	defb 000h,0dfh,0fdh,000h,000h,0bbh,000h,0f0h	; 91a6  ........
	defb 0c0h,0e0h,0f9h,000h,000h,000h,000h,000h	; 91ae  ........
	defb 01fh,00fh,003h,000h,000h,003h,01fh,000h	; 91b6  ........
	defb 000h,000h,000h,03fh,01fh,00fh,007h,001h	; 91be  ...?....
	defb 000h,0ddh,000h,0f7h,000h,000h,00fh,03fh	; 91c6  .......?
	defb 000h,03fh,00fh,003h,001h,0dfh,0fdh,0f7h	; 91ce  .?......
	defb 000h,000h,000h,000h,000h,07fh,00fh,0dfh	; 91d6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,007h	; 91de  ........
	defb 0dfh,000h,003h,03fh,000h,000h,000h,000h	; 91e6  ...?....
	defb 0dfh,0fbh,0c0h,0f8h,0feh,000h,000h,000h	; 91ee  ........
	defb 0dfh,0fdh,000h,0f7h,000h,080h,0f8h,000h	; 91f6  ........
	defb 00fh,00fh,00fh,01fh,07fh,000h,000h,000h	; 91fe  ........
	defb 07fh,07fh,03fh,03fh,01fh,01fh,00fh,00fh	; 9206  ..??....
	defb 07fh,03fh,00fh,007h,003h,003h,001h,000h	; 920e  .?......
	defb 000h,000h,000h,000h,03fh,00fh,003h,001h	; 9216  ....?...
	defb 000h,000h,00fh,001h,0bfh,0fbh,0efh,000h	; 921e  ........
	defb 01fh,003h,0bfh,000h,0efh,0fdh,000h,000h	; 9226  ........
	defb 000h,000h,0f0h,01fh,000h,004h,040h,000h	; 922e  ......@.
	defb 000h,000h,000h,0f8h,00fh,010h,000h,00fh	; 9236  ........
	defb 000h,000h,000h,000h,0f0h,003h,007h,000h	; 923e  ........
	defb 0c3h,081h,020h,002h,080h,0c1h,083h,007h	; 9246  .. .....
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,000h,000h,000h	; 924e  ........
	defb 000h,000h,03fh,00fh,007h,001h,0bfh,0f7h	; 9256  ..?.....
	defb 0dfh,001h,003h,00fh,000h,000h,000h,000h	; 925e  ........
	defb 000h,000h,000h,000h,0dfh,0fdh,000h,0efh	; 9266  ........
	defb 000h,000h,000h,000h,000h,01fh,003h,001h	; 926e  ........
	defb 000h,000h,000h,0f8h,0e0h,0c0h,080h,0fbh	; 9276  ........
	defb 000h,0f7h,0bdh,000h,000h,000h,000h,000h	; 927e  ........
	defb 000h,000h,000h,000h,000h,0fbh,0dfh,000h	; 9286  ........
	defb 003h,0f0h,0c0h,080h,080h,010h,002h,000h	; 928e  ........
	defb 000h,020h,004h,080h,0c0h,0f0h,0fch,000h	; 9296  . ......
	defb 000h,042h,000h,000h,008h,000h,000h,0f0h	; 929e  .B......
	defb 000h,0c0h,01fh,00fh,00fh,01fh,03fh,07fh	; 92a6  ......?.
	defb 000h,000h,000h,000h,000h,000h,0fch,0e0h	; 92ae  ........
	defb 000h,001h,0feh,0fch,0f0h,0c0h,004h,001h	; 92b6  ........
	defb 00fh,01fh,03fh,07fh,000h,000h,000h,000h	; 92be  ..?.....
	defb 0f0h,0f8h,0fch,0feh,000h,000h,000h,000h	; 92c6  ........
	defb 0fdh,0eah,0b8h,0a2h,008h,040h,000h,000h	; 92ce  .....@..
	defb 0d4h,051h,080h,020h,082h,000h,000h,000h	; 92d6  .Q. ....
	defb 000h,000h,001h,003h,0f8h,0f0h,0e0h,080h	; 92de  ........
	defb 00fh,0f8h,0c0h,008h,000h,040h,002h,000h	; 92e6  .....@..
	defb 0fch,007h,003h,000h,000h,044h,000h,000h	; 92ee  .....D..
	defb 000h,000h,0c0h,0f8h,00fh,001h,004h,000h	; 92f6  ........
	defb 000h,000h,000h,000h,000h,080h,0e0h,007h	; 92fe  ........
	defb 003h,001h,020h,004h,001h,003h,007h,000h	; 9306  .. .....
	defb 000h,000h,000h,0c7h,000h,000h,000h,000h	; 930e  ........
	defb 0f0h,000h,000h,000h,000h,000h,000h,0f0h	; 9316  ........
	defb 000h,0c0h,0fch,0feh,0feh,0fch,0c0h,000h	; 931e  ........
	defb 000h,003h,03fh,07fh,07fh,03fh,003h,000h	; 9326  ..?..?..
	defb 00fh,000h,000h,000h,000h,000h,000h,00fh	; 932e  ........
	defb 000h,001h,007h,01fh,03fh,07fh,000h,000h	; 9336  ....?...
	defb 00fh,000h,000h,000h,000h,000h,000h,000h	; 933e  ........
	defb 0f0h,000h,000h,000h,000h,000h,000h,000h	; 9346  ........
	defb 000h,080h,0e0h,0f8h,0fch,0feh,000h,000h	; 934e  ........
	defb 000h,000h,000h,000h,000h,000h,000h,0f8h	; 9356  ........
	defb 000h,000h,000h,000h,000h,000h,000h,01fh	; 935e  ........
	defb 000h,000h,07fh,03fh,01fh,007h,001h,000h	; 9366  ...?....
	defb 000h,000h,000h,000h,000h,000h,000h,0f0h	; 936e  ........
	defb 000h,000h,0feh,0fch,0f8h,0e0h,080h,000h	; 9376  ........
	defb 000h,00fh,000h,000h,000h,000h,000h,000h	; 937e  ........
	defb 000h,0f0h,000h,000h,000h,000h,000h,000h	; 9386  ........
	defb 000h,000h,0c0h,0fch,000h,000h,000h,000h	; 938e  ........
	defb 000h,000h,000h,000h,000h,0c0h,0f0h,0f8h	; 9396  ........
	defb 0fch,0feh,000h,000h,000h,000h,0feh,0fch	; 939e  ........
	defb 0f8h,0f0h,0c0h,000h,000h,000h,000h,000h	; 93a6  ........
	defb 000h,000h,000h,000h,0fch,0c0h,000h,000h	; 93ae  ........
	defb 000h,000h,003h,03fh,000h,000h,000h,000h	; 93b6  ...?....
	defb 000h,000h,000h,000h,000h,003h,00fh,01fh	; 93be  ........
	defb 03fh,07fh,000h,000h,000h,000h,07fh,03fh	; 93c6  ?......?
	defb 01fh,00fh,003h,000h,000h,000h,000h,000h	; 93ce  ........
	defb 000h,000h,000h,000h,03fh,003h,000h,000h	; 93d6  ....?...
	defb 000h,000h,000h,000h,000h,0c0h,0f0h,0fch	; 93de  ........
	defb 000h,000h,000h,000h,000h,003h,00fh,03fh	; 93e6  .......?
	defb 0fch,0f0h,0c0h,000h,000h,000h,000h,000h	; 93ee  ........
	defb 03fh,00fh,003h,000h,000h,000h,000h,000h	; 93f6  ?.......
	defb 000h,000h,000h,000h,000h,0f8h,0f0h,0f8h	; 93fe  ........
	defb 000h,000h,000h,000h,000h,01fh,00fh,01fh	; 9406  ........
	defb 000h,000h,000h,000h,000h,000h,000h,01fh	; 940e  ........
	defb 000h,000h,000h,000h,000h,000h,00fh,000h	; 9416  ........
	defb 000h,000h,000h,000h,000h,000h,0f0h,000h	; 941e  ........
	defb 000h,000h,000h,000h,000h,0feh,0f5h,0fah	; 9426  ........
	defb 000h,000h,000h,000h,0bfh,07fh,0afh,05fh	; 942e  ......._
	defb 005h,00ah,001h,002h,000h,000h,000h,000h	; 9436  ........
	defb 0a0h,010h,080h,040h,000h,000h,000h,000h	; 943e  ...@....
	defb 055h,000h,022h,000h,000h,000h,000h,000h	; 9446  U.".....
	defb 055h,000h,022h,000h,000h,000h,000h,000h	; 944e  U.".....
	defb 000h,000h,01fh,003h,000h,000h,000h,000h	; 9456  ........
	defb 000h,080h,080h,0c0h,0c0h,0c0h,0e0h,0e0h	; 945e  ........
	defb 0e0h,0e0h,0e0h,0f0h,0f0h,0f0h,0f0h,0f0h	; 9466  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f8h,0f8h,0f8h,0f8h	; 946e  ........
	defb 0fch,0fch,0fch,0fch,0feh,0feh,0feh,0feh	; 9476  ........
	defb 0f0h,0f0h,0f8h,0f8h,0fch,0fch,0feh,0feh	; 947e  ........
	defb 0feh,0fch,0f8h,0f0h,0f0h,0e0h,0e0h,0c0h	; 9486  ........
	defb 0c0h,0c0h,080h,080h,080h,000h,000h,000h	; 948e  ........
	defb 0feh,0f8h,0f0h,0e0h,0c0h,080h,080h,000h	; 9496  ........
	defb 00fh,001h,000h,000h,000h,000h,000h,000h	; 949e  ........
	defb 000h,000h,07fh,03fh,01fh,00fh,00fh,007h	; 94a6  ...?....
	defb 007h,007h,003h,003h,001h,001h,000h,000h	; 94ae  ........
	defb 0e1h,0c0h,080h,080h,0c0h,0e0h,0f8h,000h	; 94b6  ........
	defb 000h,000h,07fh,01fh,00fh,01fh,03fh,000h	; 94be  ......?.
	defb 0f1h,0e0h,0e0h,0c0h,081h,003h,007h,000h	; 94c6  ........
	defb 000h,0feh,0fch,0f8h,0f0h,0c0h,080h,0ddh	; 94ce  ........
	defb 01ch,000h,0dfh,000h,0fdh,000h,0efh,000h	; 94d6  ........
	defb 001h,007h,00fh,00fh,01fh,03fh,03fh,07fh	; 94de  .....??.
	defb 000h,0dfh,0fbh,003h,007h,00fh,01fh,000h	; 94e6  ........
	defb 001h,007h,07fh,000h,000h,000h,000h,000h	; 94ee  ........
	defb 000h,001h,007h,01fh,07fh,000h,000h,000h	; 94f6  ........
	defb 000h,000h,000h,000h,000h,01fh,000h,0efh	; 94fe  ........
	defb 000h,000h,000h,000h,000h,000h,00fh,000h	; 9506  ........
	defb 000h,000h,000h,000h,000h,000h,000h,0f0h	; 950e  ........
	defb 000h,000h,0fbh,0feh,000h,0bdh,0fah,0f8h	; 9516  ........
	defb 000h,000h,07fh,03fh,00fh,000h,000h,000h	; 951e  ...?....
	defb 000h,000h,000h,000h,000h,03fh,01fh,007h	; 9526  .....?..
	defb 000h,000h,000h,000h,000h,000h,0c3h,0c3h	; 952e  ........
	defb 03fh,01fh,00fh,007h,003h,000h,000h,000h	; 9536  ?.......
	defb 000h,000h,000h,000h,000h,000h,03fh,007h	; 953e  ......?.
	defb 0c0h,0f0h,0f8h,0fch,0fch,0feh,000h,000h	; 9546  ........
	defb 000h,000h,000h,000h,000h,000h,080h,0f8h	; 954e  ........
	defb 002h,010h,080h,080h,0c0h,0e0h,0f0h,0fch	; 9556  ........
	defb 0f8h,00fh,000h,020h,002h,000h,008h,000h	; 955e  ... ....
	defb 000h,080h,0c0h,01fh,00fh,007h,003h,020h	; 9566  ....... 
	defb 01fh,003h,000h,020h,000h,004h,000h,000h	; 956e  ... ....
	defb 0feh,0f8h,0f0h,0f0h,0e0h,0e0h,0f0h,0f8h	; 9576  ........
	defb 000h,002h,020h,008h,000h,000h,0f0h,000h	; 957e  .. .....
	defb 000h,022h,000h,008h,000h,003h,00fh,03fh	; 9586  .".....?
	defb 000h,0f0h,080h,010h,002h,080h,0e0h,000h	; 958e  ........
	defb 0fch,000h,040h,000h,004h,000h,000h,007h	; 9596  ..@.....
	defb 000h,000h,000h,000h,03ch,081h,081h,024h	; 959e  ....<..$
	defb 000h,010h,001h,001h,003h,007h,01fh,000h	; 95a6  ........
	defb 07fh,01fh,007h,003h,001h,001h,020h,000h	; 95ae  ...... .
	defb 0c0h,0f0h,0f8h,0f8h,0fch,0fch,0feh,000h	; 95b6  ........
	defb 000h,010h,002h,000h,000h,000h,000h,000h	; 95be  ........
	defb 024h,001h,003h,00fh,000h,000h,000h,000h	; 95c6  $.......
	defb 0f0h,0c0h,080h,010h,002h,080h,0c0h,0f0h	; 95ce  ........
	defb 000h,000h,03fh,00fh,000h,000h,000h,000h	; 95d6  ..?.....
	defb 000h,000h,000h,000h,000h,03fh,000h,000h	; 95de  .....?..
	defb 000h,000h,000h,000h,000h,000h,00fh,000h	; 95e6  ........
	defb 008h,0c0h,0f8h,000h,000h,000h,000h,000h	; 95ee  ........
	defb 000h,022h,000h,000h,0e0h,0fch,000h,000h	; 95f6  ."......
	defb 020h,004h,000h,0f0h,000h,000h,000h,000h	; 95fe   .......
	defb 000h,000h,000h,01fh,003h,020h,000h,004h	; 9606  ..... ..
	defb 000h,0feh,0f8h,000h,044h,000h,000h,020h	; 960e  ....D.. 
	defb 0feh,0fch,0f8h,0f8h,0f8h,0f8h,0fch,0feh	; 9616  ........
	defb 000h,042h,000h,000h,010h,000h,00fh,000h	; 961e  .B......
	defb 0c0h,081h,0c0h,0c0h,0e0h,0f3h,000h,000h	; 9626  ........
	defb 001h,003h,087h,000h,000h,000h,000h,000h	; 962e  ........
	defb 000h,03fh,00fh,003h,001h,001h,020h,002h	; 9636  .?.... .
	defb 000h,020h,004h,001h,001h,003h,007h,01fh	; 963e  . ......
	defb 000h,040h,001h,007h,01fh,03fh,07fh,07fh	; 9646  .@...?..
	defb 000h,000h,000h,000h,000h,0feh,0fch,0f8h	; 964e  ........
	defb 0f0h,0e0h,0c0h,080h,080h,080h,080h,0c3h	; 9656  ........
	defb 000h,000h,020h,000h,004h,000h,000h,00fh	; 965e  .. .....
	defb 000h,020h,000h,000h,004h,000h,000h,000h	; 9666  . ......
	defb 0feh,0fch,0f8h,0f8h,0f8h,0f8h,0fch,0feh	; 966e  ........
	defb 0dfh,000h,0f0h,000h,000h,000h,000h,000h	; 9676  ........
	defb 0dfh,0fdh,000h,0f0h,000h,000h,000h,000h	; 967e  ........
	defb 0fch,0f0h,0e0h,0c0h,080h,080h,0f7h,000h	; 9686  ........
	defb 0efh,000h,0f0h,000h,000h,000h,000h,000h	; 968e  ........
	defb 000h,000h,000h,00fh,03fh,07fh,000h,000h	; 9696  ....?...
	defb 003h,00fh,03fh,000h,000h,000h,000h,000h	; 969e  ..?.....
	defb 090h,008h,000h,000h,0c3h,0c3h,081h,000h	; 96a6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 96ae  ........
	defb 000h,000h,000h,000h,000h,000h,001h,01fh	; 96b6  ........
	defb 001h,007h,00fh,01fh,03fh,07fh,000h,000h	; 96be  ....?...
	defb 000h,000h,000h,000h,000h,000h,0f8h,0e0h	; 96c6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 96ce  ........
	defb 000h,000h,000h,0c3h,0c3h,000h,000h,000h	; 96d6  ........
	defb 000h,000h,000h,0f0h,00fh,0dfh,000h,000h	; 96de  ........
	defb 001h,001h,003h,00fh,03fh,000h,000h,000h	; 96e6  ....?...
	defb 000h,07fh,03fh,01fh,01fh,01fh,03fh,07fh	; 96ee  ..?...?.
	defb 000h,000h,000h,003h,004h,01ch,03fh,04fh	; 96f6  ......?O
	defb 000h,000h,000h,000h,080h,0c0h,0e0h,0f0h	; 96fe  ........
	defb 0cfh,07fh,03fh,01fh,00fh,007h,003h,000h	; 9706  ..?.....
	defb 0f8h,0f8h,0f0h,0e0h,0c0h,080h,000h,000h	; 970e  ........
	defb 000h,000h,087h,003h,001h,003h,007h,000h	; 9716  ........
	defb 07fh,03fh,01fh,01fh,00fh,00fh,00fh,00fh	; 971e  .?......
	defb 01fh,01fh,01fh,01fh,00fh,00fh,00fh,00fh	; 9726  ........
	defb 007h,007h,007h,003h,003h,003h,001h,001h	; 972e  ........
	defb 000h,080h,080h,0c0h,0c0h,0e0h,0f0h,0fch	; 9736  ........
	defb 000h,000h,000h,000h,001h,001h,003h,00fh	; 973e  ........
	defb 000h,000h,000h,000h,000h,0f0h,0c0h,080h	; 9746  ........
	defb 000h,000h,000h,000h,000h,00fh,003h,001h	; 974e  ........
	defb 000h,07fh,03fh,007h,000h,000h,000h,000h	; 9756  ..?.....
	defb 000h,000h,000h,000h,01fh,007h,003h,001h	; 975e  ........
	defb 000h,000h,001h,001h,003h,007h,00fh,03fh	; 9766  .......?
	defb 000h,0feh,0ebh,0feh,0f4h,0feh,0ech,0f6h	; 976e  ........
	defb 0feh,0fah,0d4h,0f8h,0e8h,0fch,0d2h,0feh	; 9776  ........
	defb 000h,080h,0c0h,0c0h,0c0h,0c0h,080h,000h	; 977e  ........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; 9786  ........
	defb 00fh,00fh,00fh,00fh,007h,007h,007h,007h	; 978e  ........
	defb 007h,007h,007h,00fh,00fh,01fh,03fh,07fh	; 9796  ......?.
	defb 080h,0c0h,0f0h,000h,000h,000h,000h,000h	; 979e  ........
	defb 000h,000h,000h,000h,000h,0f8h,0c0h,080h	; 97a6  ........
	defb 000h,0feh,0fch,0f8h,0e0h,000h,000h,000h	; 97ae  ........
	defb 07fh,03fh,00fh,007h,003h,003h,001h,001h	; 97b6  .?......
	defb 001h,001h,001h,000h,000h,000h,000h,000h	; 97be  ........
	defb 0c0h,0f0h,0f8h,0fch,000h,000h,000h,000h	; 97c6  ........
	defb 000h,000h,000h,000h,000h,0f0h,0fch,0feh	; 97ce  ........
	defb 000h,000h,000h,000h,000h,0e0h,080h,000h	; 97d6  ........
	defb 000h,000h,000h,000h,000h,000h,000h,022h	; 97de  ......."
	defb 000h,000h,000h,000h,000h,0f8h,0e0h,080h	; 97e6  ........
	defb 000h,000h,000h,000h,0f0h,000h,020h,002h	; 97ee  ...... .
	defb 07fh,01fh,007h,003h,020h,000h,004h,000h	; 97f6  .... ...
	defb 000h,000h,000h,000h,000h,01fh,007h,001h	; 97fe  ........
	defb 0f8h,0e0h,080h,000h,022h,000h,008h,000h	; 9806  ...."...
	defb 000h,004h,020h,000h,008h,001h,001h,003h	; 980e  .. .....
	defb 000h,0ebh,0bfh,0ddh,055h,000h,012h,000h	; 9816  ....U...
	defb 000h,000h,07fh,03fh,01fh,00fh,007h,001h	; 981e  ...?....
	defb 000h,000h,000h,000h,0fch,0f0h,0e0h,080h	; 9826  ........
	defb 000h,000h,0feh,0fch,0f8h,0f0h,0e0h,080h	; 982e  ........
	defb 0f8h,0c0h,000h,000h,000h,000h,000h,000h	; 9836  ........
	defb 000h,000h,000h,040h,002h,008h,052h,0adh	; 983e  ...@..R.
	defb 000h,000h,000h,000h,008h,020h,044h,0b1h	; 9846  ..... D.
	defb 000h,000h,07fh,03fh,01fh,00fh,007h,007h	; 984e  ...?....
	defb 000h,024h,000h,080h,0c0h,0e0h,0f8h,0feh	; 9856  .$......
	defb 007h,007h,007h,007h,007h,00fh,01fh,03fh	; 985e  .......?
	defb 0aah,0ddh,0f7h,000h,000h,000h,000h,000h	; 9866  ........
	defb 000h,000h,000h,000h,000h,044h,011h,0aah	; 986e  .....D..
	defb 0f5h,0fah,0f5h,0dfh,000h,000h,000h,000h	; 9876  ........
	defb 000h,010h,000h,042h,010h,044h,0b0h,0eah	; 987e  ...B.D..
	defb 000h,000h,080h,0e0h,000h,000h,000h,000h	; 9886  ........
	defb 07fh,03fh,01fh,00fh,007h,003h,001h,000h	; 988e  .?......
	defb 000h,000h,000h,001h,001h,003h,003h,007h	; 9896  ........
	defb 007h,007h,00fh,00fh,01fh,01fh,03fh,07fh	; 989e  ......?.
	defb 00fh,007h,003h,003h,001h,001h,001h,000h	; 98a6  ........
	defb 000h,000h,0feh,0feh,0fch,0fch,0f8h,0e0h	; 98ae  ........
	defb 000h,080h,0c0h,0e0h,0f0h,0f8h,0feh,000h	; 98b6  ........
	defb 07fh,03fh,01fh,00fh,007h,003h,003h,087h	; 98be  .?......
	defb 08fh,007h,003h,001h,001h,080h,0c0h,0c0h	; 98c6  ........
	defb 0c0h,0c0h,080h,080h,001h,003h,007h,08fh	; 98ce  ........
	defb 0ffh,077h,0ddh,0bah,0d4h,0a9h,000h,000h	; 98d6  .w......
	defb 0d6h,000h,0abh,054h,0a8h,002h,000h,000h	; 98de  ...T....
	defb 05fh,0fdh,06fh,000h,0b7h,000h,000h,000h	; 98e6  _.o.....
	defb 001h,003h,006h,00eh,01fh,03fh,07fh,07fh	; 98ee  .....?..
	defb 080h,0c0h,060h,070h,0f8h,0fch,0e6h,0e6h	; 98f6  ..`p....
	defb 03fh,01fh,00fh,007h,003h,001h,000h,000h	; 98fe  ?.......
	defb 0fch,0f8h,0f0h,0e0h,0c0h,080h,000h,000h	; 9906  ........
	defb 01fh,0c0h,080h,080h,0c0h,0f0h,000h,000h	; 990e  ........
	defb 0c0h,00fh,003h,001h,000h,000h,0c0h,0f1h	; 9916  ........
	defb 000h,002h,080h,080h,0c0h,0f8h,0feh,0feh	; 991e  ........
	defb 000h,000h,000h,000h,0fch,0f0h,0c0h,000h	; 9926  ........
	defb 003h,0f0h,0c0h,000h,020h,002h,000h,000h	; 992e  .... ...
	defb 004h,020h,001h,001h,003h,003h,007h,007h	; 9936  . ......
	defb 00fh,00fh,01fh,01fh,03fh,03fh,07fh,07fh	; 993e  ....??..
	defb 03fh,01fh,00fh,00fh,007h,007h,007h,007h	; 9946  ?.......
	defb 007h,007h,00fh,00fh,01fh,01fh,03fh,07fh	; 994e  ......?.
	defb 000h,000h,000h,020h,000h,004h,000h,040h	; 9956  ... ...@
	defb 004h,040h,008h,000h,0c0h,0f0h,0fch,0feh	; 995e  .@......
	defb 000h,001h,003h,007h,007h,007h,00fh,00fh	; 9966  ........
	defb 00fh,00fh,007h,007h,003h,003h,001h,000h	; 996e  ........
	defb 000h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; 9976  ........
	defb 0f0h,0e0h,0e0h,0e0h,0f0h,0fch,000h,000h	; 997e  ........
	defb 00fh,007h,007h,007h,00fh,01fh,000h,000h	; 9986  ........
	defb 000h,000h,000h,0e0h,080h,000h,000h,083h	; 998e  ........
	defb 0e3h,081h,000h,000h,001h,003h,01fh,000h	; 9996  ........
	defb 000h,080h,0e0h,000h,000h,000h,000h,000h	; 999e  ........
	defb 000h,0a0h,0cah,0a0h,0f4h,0d8h,0f4h,0feh	; 99a6  ........
	defb 000h,003h,007h,000h,000h,000h,000h,000h	; 99ae  ........
	defb 000h,000h,0efh,000h,0bbh,000h,0d5h,0aah	; 99b6  ........
	defb 0cbh,081h,020h,081h,004h,020h,081h,0cbh	; 99be  .. .. ..
	defb 080h,0a0h,044h,0d0h,0a0h,0f4h,068h,0f6h	; 99c6  ..D...h.
	defb 000h,000h,000h,004h,020h,005h,010h,00ah	; 99ce  .... ...
	defb 000h,001h,090h,004h,052h,017h,0bdh,0efh	; 99d6  ....R...
	defb 0feh,0f8h,0f9h,0f6h,0e0h,0e0h,092h,08ch	; 99de  ........
	defb 000h,000h,0bbh,06fh,0bfh,017h,0bfh,00fh	; 99e6  ...o....
	defb 01fh,003h,001h,020h,004h,000h,001h,007h	; 99ee  ... ....
	defb 000h,080h,0c0h,0c0h,0c0h,0c0h,080h,000h	; 99f6  ........
	defb 07fh,03fh,00fh,00fh,047h,027h,01bh,000h	; 99fe  .?..G'..
	defb 000h,004h,020h,000h,000h,002h,010h,000h	; 9a06  .. .....
	defb 080h,048h,0b0h,000h,000h,0feh,0feh,0fch	; 9a0e  .H......
	defb 040h,027h,018h,000h,001h,03fh,03fh,01fh	; 9a16  @'...??.
	defb 000h,000h,0efh,000h,000h,0fbh,000h,000h	; 9a1e  ........
	defb 0e7h,0c1h,0c3h,025h,088h,043h,004h,081h	; 9a26  ...%.C..
	defb 0e7h,0e7h,0c3h,000h,0ddh,0f7h,0fdh,000h	; 9a2e  ........
	defb 000h,000h,000h,000h,0feh,000h,0f8h,0fch	; 9a36  ........
	defb 0d3h,001h,080h,04ch,012h,0c0h,021h,012h	; 9a3e  ...L..!.
	defb 000h,000h,000h,000h,07fh,09fh,01fh,00fh	; 9a46  ........
	defb 0f7h,0e0h,0e0h,0c0h,0eeh,0f1h,0e0h,080h	; 9a4e  ........
	defb 004h,080h,040h,020h,00dh,010h,020h,070h	; 9a56  ..@ .. p
	defb 000h,000h,020h,000h,002h,010h,000h,000h	; 9a5e  .. .....
	defb 0f6h,0fch,0eah,0f8h,0d4h,0f8h,0d2h,0f0h	; 9a66  ........
	defb 07fh,07fh,03fh,03fh,03fh,03fh,01fh,01fh	; 9a6e  ..????..
	defb 0e0h,0e0h,0e0h,0e0h,0c0h,0c0h,0c0h,0c0h	; 9a76  ........
	defb 000h,07fh,03fh,01fh,01fh,01fh,03fh,07fh	; 9a7e  ..?...?.
	defb 000h,0f0h,000h,000h,000h,000h,000h,000h	; 9a86  ........
	defb 000h,000h,000h,0e0h,0f8h,0feh,000h,000h	; 9a8e  ........
	defb 000h,0dfh,000h,0fbh,000h,000h,0c0h,0f8h	; 9a96  ........
	defb 000h,000h,07fh,07fh,03fh,01fh,007h,000h	; 9a9e  ....?...
	defb 003h,077h,08bh,007h,001h,083h,01fh,021h	; 9aa6  .w.....!
	defb 003h,00fh,01fh,03fh,07fh,07fh,000h,000h	; 9aae  ...?....
	defb 07fh,03fh,00fh,000h,0bfh,000h,0fdh,000h	; 9ab6  .?......
	defb 0f8h,0f8h,0f0h,0f0h,0e0h,0e0h,0c0h,080h	; 9abe  ........
	defb 080h,0c0h,0e0h,0e0h,0f0h,0f0h,0f8h,0f8h	; 9ac6  ........
	defb 000h,000h,000h,000h,000h,000h,0f0h,000h	; 9ace  ........
	defb 000h,000h,000h,000h,000h,000h,0dfh,0fdh	; 9ad6  ........
	defb 000h,000h,000h,000h,000h,000h,00fh,000h	; 9ade  ........
	defb 000h,000h,000h,000h,000h,0efh,000h,0ddh	; 9ae6  ........
	defb 000h,01fh,003h,0dfh,000h,0fbh,000h,0dfh	; 9aee  ........
	defb 07fh,01fh,007h,003h,000h,000h,000h,000h	; 9af6  ........
	defb 080h,0e0h,0f0h,0f8h,0fch,0feh,0feh,000h	; 9afe  ........
	defb 0feh,0feh,0fch,0fch,0f8h,0f0h,0e0h,080h	; 9b06  ........
	defb 0f8h,0fch,0fch,0feh,0feh,000h,000h,000h	; 9b0e  ........
	defb 080h,0e0h,0f0h,0f8h,0f8h,0fch,0feh,000h	; 9b16  ........
	defb 080h,0c0h,0e0h,0e0h,0e0h,0c0h,0c0h,080h	; 9b1e  ........
	defb 000h,0f0h,000h,000h,000h,000h,000h,000h	; 9b26  ........
	defb 00fh,00fh,01fh,03fh,03fh,07fh,07fh,000h	; 9b2e  ...??...
	defb 001h,001h,003h,003h,007h,007h,00fh,00fh	; 9b36  ........
	defb 000h,000h,080h,0c0h,0e0h,0e0h,0c0h,080h	; 9b3e  ........
	defb 0feh,0feh,0fch,0fch,0f8h,0f8h,0f0h,0f0h	; 9b46  ........
	defb 0feh,0fch,0fch,0f8h,0f8h,0f0h,0f0h,0f0h	; 9b4e  ........
	defb 0f0h,0f0h,0e0h,0e0h,0c0h,0c0h,080h,080h	; 9b56  ........
	defb 040h,000h,001h,003h,027h,000h,000h,000h	; 9b5e  @...'...
	defb 080h,080h,0c0h,0c0h,0e0h,0e0h,0f0h,0f0h	; 9b66  ........
	defb 0f0h,0f0h,0f0h,0f8h,0f8h,0f8h,0fch,0feh	; 9b6e  ........
	defb 000h,000h,005h,013h,005h,027h,003h,01eh	; 9b76  .....'..
	defb 000h,020h,080h,0a8h,040h,0e8h,0a0h,0f4h	; 9b7e  . ..@...
	defb 000h,0dfh,000h,0fdh,0e0h,0f9h,0fch,0feh	; 9b86  ........
	defb 000h,000h,000h,000h,000h,000h,003h,0e0h	; 9b8e  ........
	defb 000h,001h,001h,0fch,0f8h,0e0h,000h,0dfh	; 9b96  ........
	defb 001h,007h,01fh,03fh,07fh,07fh,03fh,00fh	; 9b9e  ...?..?.
	defb 000h,000h,0dfh,0fbh,007h,01fh,07fh,000h	; 9ba6  ........
	defb 000h,0f0h,0fch,0feh,000h,000h,000h,000h	; 9bae  ........
	defb 0bfh,001h,003h,007h,01fh,000h,000h,000h	; 9bb6  ........
	defb 000h,03fh,00fh,003h,000h,0dfh,000h,0fbh	; 9bbe  .?......
	defb 000h,080h,0c0h,0e0h,0f8h,0fch,0feh,000h	; 9bc6  ........
	defb 001h,007h,00fh,03fh,03fh,07fh,07fh,000h	; 9bce  ...??...
	defb 00fh,000h,000h,000h,000h,000h,000h,000h	; 9bd6  ........
	defb 001h,0e0h,080h,0fbh,0c0h,000h,000h,000h	; 9bde  ........
	defb 000h,0f7h,000h,000h,0ddh,000h,0f0h,0e0h	; 9be6  ........
	defb 000h,003h,0f0h,0e0h,0c0h,0c0h,080h,0f7h	; 9bee  ........
	defb 000h,0feh,0f8h,0f8h,0f0h,0e0h,0c0h,080h	; 9bf6  ........
	defb 000h,0dfh,0fdh,0e0h,0fch,0fch,0feh,000h	; 9bfe  ........
	defb 001h,003h,007h,007h,007h,003h,003h,001h	; 9c06  ........
	defb 00fh,00fh,00fh,007h,007h,003h,001h,0bfh	; 9c0e  ........
	defb 001h,001h,003h,007h,00fh,01fh,07fh,000h	; 9c16  ........
	defb 080h,080h,0c0h,0e0h,0f0h,0f8h,0fch,000h	; 9c1e  ........
	defb 000h,001h,003h,003h,003h,003h,001h,000h	; 9c26  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9c2e  ........
	defb 000h,0ffh,0ffh,0ffh,0ffh,0f7h,0ffh,000h	; 9c36  ........
	defb 000h,000h,000h,000h,001h,007h,00fh,00fh	; 9c3e  ........
	defb 000h,000h,000h,000h,000h,000h,0feh,0fch	; 9c46  ........
	defb 0f0h,0f0h,0e0h,0c0h,080h,000h,000h,000h	; 9c4e  ........
	defb 000h,000h,000h,000h,000h,000h,07fh,03fh	; 9c56  .......?
	defb 04fh,00bh,02fh,00dh,02fh,006h,013h,001h	; 9c5e  O././...
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h	; 9c66  ........
	defb 000h,0feh,0fch,0f8h,0f8h,0f8h,0fch,0feh	; 9c6e  ........
	defb 000h,003h,00fh,01fh,03fh,03fh,07fh,07fh	; 9c76  ....??..
	defb 000h,0c0h,0f0h,0f8h,0fch,0fch,0feh,0feh	; 9c7e  ........
	defb 07fh,03fh,01fh,00fh,007h,001h,001h,001h	; 9c86  .?......
	defb 000h,000h,000h,000h,003h,0f8h,0f0h,0f0h	; 9c8e  ........
	defb 0e0h,0e0h,0e0h,0e0h,0c0h,0c0h,080h,080h	; 9c96  ........
	defb 0feh,0fch,0fch,0f8h,0f8h,0f8h,0f8h,0f8h	; 9c9e  ........
	defb 0e0h,0e0h,0e0h,0c0h,0c0h,0c0h,080h,080h	; 9ca6  ........
	defb 0f0h,0f0h,0f0h,0f0h,0e0h,0e0h,0e0h,0e0h	; 9cae  ........
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,0f0h,0f0h,0f0h	; 9cb6  ........
	defb 0feh,0feh,0feh,0fch,0fch,0fch,0fch,0f8h	; 9cbe  ........
	defb 0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0feh	; 9cc6  ........
	defb 0e0h,0c0h,080h,000h,000h,000h,000h,000h	; 9cce  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0f0h,080h	; 9cd6  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0f0h,0c0h	; 9cde  ........
	defb 0ffh,0fch,0f0h,0c0h,000h,000h,000h,000h	; 9ce6  ........
	defb 07fh,00fh,007h,001h,000h,000h,000h,000h	; 9cee  ........
	defb 0ffh,0ffh,0ffh,0ffh,07fh,01fh,007h,001h	; 9cf6  ........
	defb 000h,000h,000h,000h,080h,080h,0c0h,0c0h	; 9cfe  ........
	defb 080h,0c0h,0e0h,0f0h,0fch,0ffh,0ffh,0ffh	; 9d06  ........
	defb 000h,000h,000h,000h,000h,000h,0e0h,0ffh	; 9d0e  ........
	defb 0ffh,0ffh,07fh,03fh,01fh,01fh,00fh,00fh	; 9d16  ...?....
	defb 00fh,007h,007h,003h,003h,003h,001h,001h	; 9d1e  ........
	defb 001h,001h,003h,007h,007h,00fh,00fh,00fh	; 9d26  ........

; ----------------------------------------------------------------------
; DATOS cadena_de_bloques_de_terreno: 36 sprites comprimidos con el formato de
;   0xA8FB encadenados sin tabla de punteros (cada cabecera salta a la
;   siguiente), verificados en Python (128 bytes de salida cada uno)
;   0x9d2e..0xa875  (2887 bytes)
DATA_cadena_de_bloques_de_terreno:
	defb 053h,000h,0ffh,009h,00ch,0ffh,007h,02ch,00ch,0ffh,007h,02ch,0ffh,008h,002h,0ffh	; 9d2e  S......,...,....
	defb 007h,023h,002h,0ffh,007h,023h,0ffh,005h,002h,02fh,02fh,0ffh,004h,00fh,02fh,02fh	; 9d3e  .#...#...//...//
	defb 0ffh,004h,002h,003h,003h,0ffh,006h,023h,0ffh,004h,002h,0ffh,004h,003h,0ffh,003h	; 9d4e  .......#........
	defb 005h,0ffh,003h,05fh,00fh,00fh,0ffh,004h,05fh,0ffh,004h,00fh,0ffh,004h,05fh,0ffh	; 9d5e  ..._...._....._.
	defb 004h,00fh,005h,005h,0ffh,003h,05fh,0ffh,003h,00fh,0ffh,004h,005h,0ffh,003h,05fh	; 9d6e  ......_........_
	defb 0ffh,007h,00fh,05fh,05fh,063h,000h,0ffh,003h,00fh,0ffh,003h,05fh,005h,005h,00fh	; 9d7e  ...__c......_...
	defb 00fh,05fh,05fh,0ffh,006h,005h,05fh,05fh,00fh,00fh,05fh,005h,005h,05fh,05fh,0ffh	; 9d8e  .__...__.._..__.
	defb 004h,00fh,0ffh,003h,05fh,0ffh,004h,00fh,05fh,05fh,005h,05fh,05fh,00fh,00fh,0ffh	; 9d9e  ...._...__.__...
	defb 003h,05fh,0ffh,00eh,005h,025h,002h,0ffh,004h,005h,025h,025h,002h,002h,005h,005h	; 9dae  ._...%....%%....
	defb 025h,025h,0ffh,004h,002h,025h,025h,0ffh,006h,002h,025h,0ffh,007h,002h,005h,005h	; 9dbe  %%...%%...%.....
	defb 025h,025h,0ffh,004h,002h,0ffh,004h,005h,025h,0ffh,003h,002h,005h,0ffh,003h,025h	; 9dce  %%......%......%
	defb 0ffh,004h,002h,0ffh,004h,005h,025h,025h,002h,002h,053h,000h,0ffh,007h,005h,002h	; 9dde  ......%%..S.....
	defb 0ffh,003h,025h,0ffh,005h,002h,025h,0ffh,007h,002h,005h,005h,025h,0ffh,005h,002h	; 9dee  ..%...%.....%...
	defb 0ffh,003h,005h,025h,0ffh,004h,002h,00fh,0ffh,003h,05fh,0ffh,004h,005h,0ffh,004h	; 9dfe  ...%......_.....
	defb 00fh,0ffh,003h,05fh,005h,0ffh,015h,023h,0ffh,003h,002h,0ffh,004h,025h,0ffh,004h	; 9e0e  ..._...#.....%..
	defb 002h,0ffh,004h,025h,0ffh,004h,002h,0ffh,005h,005h,024h,024h,002h,0ffh,005h,005h	; 9e1e  ...%......$$....
	defb 04fh,04fh,002h,0ffh,005h,005h,04fh,04fh,004h,0ffh,005h,005h,024h,024h,002h,048h	; 9e2e  OO....OO....$$.H
	defb 000h,0ffh,00ah,004h,04fh,004h,004h,04fh,0ffh,00ah,004h,0ffh,009h,023h,002h,0ffh	; 9e3e  ....O..O.....#..
	defb 006h,023h,002h,0ffh,006h,023h,003h,002h,0ffh,006h,023h,003h,0ffh,005h,023h,0ffh	; 9e4e  .#...#....#...#.
	defb 003h,003h,002h,002h,023h,002h,0ffh,00ah,023h,003h,003h,0ffh,004h,023h,003h,023h	; 9e5e  ....#...#....#.#
	defb 003h,003h,0ffh,007h,023h,003h,002h,0ffh,007h,023h,0ffh,008h,003h,002h,023h,002h	; 9e6e  ....#....#....#.
	defb 0ffh,005h,023h,0ffh,003h,002h,0ffh,005h,023h,037h,000h,0ffh,006h,023h,003h,003h	; 9e7e  ..#.....#7...#..
	defb 0ffh,00eh,023h,003h,003h,0ffh,004h,002h,0ffh,009h,023h,0ffh,003h,003h,0ffh,010h	; 9e8e  ..#.......#.....
	defb 023h,0ffh,005h,02ch,03ch,00ch,02ch,0ffh,003h,026h,0ffh,005h,002h,0ffh,00dh,02ch	; 9e9e  #..,<.,..&.....,
	defb 0ffh,003h,026h,002h,0ffh,00ch,02ch,0ffh,003h,026h,0ffh,005h,002h,0ffh,011h,02ch	; 9eae  ..&...,..&.....,
	defb 002h,002h,050h,000h,0ffh,00bh,02ch,00ch,0ffh,006h,02ch,00ch,00ch,0ffh,003h,026h	; 9ebe  ..P...,...,....&
	defb 006h,0ffh,004h,002h,0ffh,009h,02ch,03ch,0ffh,008h,02ch,002h,002h,0ffh,003h,02ch	; 9ece  ......,<..,....,
	defb 03ch,0ffh,004h,02ch,0ffh,005h,03bh,00bh,00bh,0ffh,009h,03bh,0ffh,003h,003h,0ffh	; 9ede  <..,..;....;....
	defb 00dh,03bh,003h,003h,013h,0ffh,005h,034h,003h,003h,013h,034h,034h,0ffh,003h,04fh	; 9eee  .;.....4...44..O
	defb 0ffh,004h,003h,013h,034h,04fh,04fh,0ffh,004h,003h,013h,0ffh,005h,034h,04fh,04fh	; 9efe  ....4OO......4OO
	defb 0ffh,003h,034h,003h,049h,000h,04fh,04fh,004h,04fh,004h,004h,034h,034h,04fh,04fh	; 9f0e  ..4.I.OO.O..44OO
	defb 0ffh,006h,034h,04fh,034h,0ffh,006h,003h,034h,023h,0ffh,007h,003h,0ffh,006h,023h	; 9f1e  ..4O4...4#.....#
	defb 0ffh,004h,003h,0ffh,004h,023h,003h,0ffh,003h,002h,0ffh,003h,023h,0ffh,004h,002h	; 9f2e  .....#......#...
	defb 0ffh,005h,023h,0ffh,004h,002h,0ffh,00ch,023h,003h,002h,002h,023h,0ffh,005h,003h	; 9f3e  ..#.....#...#...
	defb 0ffh,004h,002h,0ffh,007h,023h,0ffh,005h,003h,0ffh,003h,002h,0ffh,015h,023h,043h	; 9f4e  .....#........#C
	defb 000h,0ffh,018h,023h,003h,0ffh,006h,023h,003h,0ffh,015h,023h,0ffh,006h,003h,013h	; 9f5e  ...#...#...#....
	defb 0ffh,003h,03bh,06bh,0ffh,003h,003h,013h,03bh,03bh,00bh,06bh,013h,0ffh,007h,03bh	; 9f6e  ..;k....;;.k...;
	defb 0ffh,003h,00bh,0ffh,003h,03bh,003h,003h,00bh,03bh,03bh,0ffh,005h,003h,013h,0ffh	; 9f7e  .....;...;;.....
	defb 003h,03bh,06bh,00bh,06bh,03bh,013h,0ffh,003h,03bh,00bh,06bh,06bh,00bh,0ffh,006h	; 9f8e  .;k.k;...;.kk...
	defb 003h,0ffh,00ah,03bh,063h,000h,06bh,0ffh,004h,03bh,0ffh,003h,003h,0ffh,004h,00bh	; 9f9e  ...;c.k..;......
	defb 06bh,03bh,03bh,003h,0ffh,003h,03bh,06bh,00bh,00bh,0ffh,00ah,03bh,00bh,06bh,00bh	; 9fae  k;;...;k....;.k.
	defb 00bh,06bh,06bh,00bh,00bh,013h,0ffh,003h,034h,04fh,04fh,034h,034h,013h,034h,04fh	; 9fbe  .kk.....4OO44.4O
	defb 004h,04fh,04fh,004h,034h,003h,003h,034h,014h,0ffh,003h,04fh,004h,003h,003h,034h	; 9fce  .OO.4..4...O...4
	defb 014h,0ffh,003h,04fh,004h,013h,034h,0ffh,005h,04fh,004h,003h,003h,0ffh,009h,034h	; 9fde  ...O..4..O.....4
	defb 0ffh,005h,003h,004h,034h,034h,0ffh,007h,003h,0ffh,005h,023h,002h,003h,0ffh,005h	; 9fee  ....44.....#....
	defb 023h,002h,002h,0ffh,003h,003h,0ffh,005h,023h,03dh,000h,0ffh,003h,003h,0ffh,00dh	; 9ffe  #.......#=......
	defb 023h,0ffh,004h,002h,0ffh,013h,023h,002h,003h,003h,0ffh,015h,023h,003h,0ffh,007h	; a00e  #.....#.....#...
	defb 023h,002h,003h,0ffh,007h,023h,0ffh,003h,003h,0ffh,00ah,023h,0ffh,003h,002h,003h	; a01e  #....#.....#....
	defb 0ffh,004h,023h,0ffh,003h,002h,0ffh,005h,023h,002h,023h,002h,002h,0ffh,006h,023h	; a02e  ..#.....#.#....#
	defb 003h,0ffh,004h,023h,003h,0ffh,003h,023h,051h,000h,003h,0ffh,005h,023h,0ffh,003h	; a03e  ...#...#Q....#..
	defb 003h,0ffh,005h,023h,003h,003h,0ffh,008h,023h,0ffh,003h,002h,0ffh,00dh,023h,002h	; a04e  ...#....#.....#.
	defb 002h,0ffh,005h,023h,003h,0ffh,00ch,023h,0ffh,004h,003h,0ffh,005h,023h,003h,023h	; a05e  ...#...#.....#.#
	defb 023h,002h,023h,002h,0ffh,005h,023h,002h,0ffh,00fh,023h,013h,01bh,06bh,00bh,06bh	; a06e  #.#...#...#..k.k
	defb 0ffh,003h,03bh,003h,003h,013h,03bh,00bh,00bh,03bh,03bh,003h,003h,013h,0ffh,004h	; a07e  ..;...;..;;.....
	defb 03bh,003h,013h,01bh,06bh,0ffh,004h,03bh,0ffh,001h,003h,071h,000h,0ffh,003h,003h	; a08e  ;...k..;...q....
	defb 0ffh,005h,03bh,0ffh,003h,003h,001h,00bh,06bh,06bh,00bh,0ffh,008h,03bh,0ffh,003h	; a09e  ..;.....kk...;..
	defb 002h,012h,024h,024h,04fh,04fh,0ffh,003h,002h,012h,014h,04fh,04fh,004h,002h,002h	; a0ae  ..$$OO.....OO...
	defb 012h,014h,0ffh,003h,04fh,004h,012h,014h,004h,0ffh,004h,04fh,004h,012h,012h,014h	; a0be  ....O......O....
	defb 004h,0ffh,003h,04fh,004h,002h,012h,014h,014h,04fh,04fh,004h,04fh,0ffh,006h,003h	; a0ce  ...O.....OO.O...
	defb 013h,004h,0ffh,005h,003h,013h,004h,04fh,0ffh,004h,003h,013h,034h,04fh,04fh,013h	; a0de  .......O....4OO.
	defb 0ffh,003h,034h,0ffh,003h,04fh,004h,013h,034h,04fh,004h,04fh,04fh,004h,04fh,013h	; a0ee  ..4..O..4O.OO.O.
	defb 013h,034h,004h,04fh,04fh,004h,004h,04fh,0ffh,003h,024h,0ffh,004h,002h,075h,000h	; a0fe  .4.OO..O..$...u.
	defb 004h,04fh,004h,04fh,04fh,004h,024h,024h,004h,0ffh,003h,04fh,0ffh,003h,024h,002h	; a10e  .O.OO.$$...O..$.
	defb 04fh,0ffh,004h,024h,0ffh,003h,002h,004h,04fh,004h,04fh,004h,0ffh,003h,034h,004h	; a11e  O..$....O.O...4.
	defb 0ffh,003h,04fh,004h,034h,034h,003h,004h,0ffh,003h,04fh,004h,034h,003h,003h,004h	; a12e  ..O.44....O.4...
	defb 04fh,04fh,004h,034h,0ffh,003h,003h,04fh,024h,024h,0ffh,003h,023h,003h,003h,04fh	; a13e  OO.4...O$$..#..O
	defb 04fh,0ffh,005h,034h,003h,004h,04fh,04fh,004h,004h,04fh,004h,0ffh,004h,034h,0ffh	; a14e  O..4..OO..O...4.
	defb 005h,003h,0ffh,003h,024h,004h,004h,024h,024h,002h,0ffh,003h,003h,0ffh,005h,024h	; a15e  ....$..$$......$
	defb 004h,04fh,004h,04fh,004h,004h,034h,034h,002h,0ffh,004h,024h,0ffh,003h,04fh,0ffh	; a16e  .O.O..44...$..O.
	defb 005h,002h,024h,024h,04fh,065h,000h,0ffh,007h,002h,024h,04fh,004h,034h,034h,0ffh	; a17e  ..$$Oe....$O.44.
	defb 004h,003h,04fh,04fh,0ffh,003h,034h,0ffh,003h,003h,04fh,04fh,004h,04fh,004h,034h	; a18e  ..OO..4...OO.O.4
	defb 034h,003h,0ffh,005h,034h,0ffh,003h,003h,0ffh,00fh,034h,004h,0ffh,004h,003h,0ffh	; a19e  4...4.....4.....
	defb 004h,034h,003h,003h,034h,034h,0ffh,003h,04fh,004h,034h,034h,04fh,004h,04fh,04fh	; a1ae  .4..44..O.44O.OO
	defb 004h,004h,003h,003h,013h,01bh,00bh,06bh,06bh,00bh,0ffh,003h,003h,013h,01bh,06bh	; a1be  .......kk......k
	defb 00bh,03bh,0ffh,004h,003h,013h,03bh,03bh,003h,03bh,03bh,06bh,06bh,0ffh,004h,03bh	; a1ce  .;....;;.;;kk..;
	defb 0ffh,005h,023h,0ffh,005h,003h,0ffh,004h,034h,0ffh,002h,04fh,062h,000h,04fh,0ffh	; a1de  ..#.....4..Ob.O.
	defb 003h,034h,0ffh,007h,003h,004h,04fh,04fh,004h,04fh,0ffh,005h,003h,0ffh,003h,034h	; a1ee  .4....OO.O.....4
	defb 0ffh,003h,003h,0ffh,004h,034h,04fh,004h,04fh,04fh,004h,0ffh,008h,003h,004h,04fh	; a1fe  .....4O.OO.....O
	defb 04fh,004h,013h,0ffh,004h,03bh,06bh,06bh,00bh,00bh,06bh,06bh,0ffh,004h,03bh,003h	; a20e  O....;kk..kk..;.
	defb 00bh,06bh,00bh,00bh,06bh,00bh,00bh,03bh,003h,013h,0ffh,006h,03bh,0ffh,006h,003h	; a21e  .k..k..;....;...
	defb 03bh,03bh,003h,013h,0ffh,004h,03bh,06bh,06bh,0ffh,004h,023h,0ffh,004h,003h,0ffh	; a22e  ;;....;kk..#....
	defb 004h,023h,0ffh,004h,003h,0ffh,006h,023h,003h,003h,0ffh,005h,023h,0ffh,003h,003h	; a23e  .#.....#....#...
	defb 05eh,000h,003h,003h,013h,013h,0ffh,004h,03bh,013h,01bh,01bh,06bh,00bh,06bh,06bh	; a24e  ^.......;...k.kk
	defb 00bh,013h,01bh,01bh,00bh,00bh,06bh,00bh,00bh,003h,003h,013h,013h,01bh,01bh,06bh	; a25e  ......k........k
	defb 00bh,0ffh,005h,003h,013h,013h,0ffh,003h,03bh,06bh,06bh,0ffh,003h,03bh,003h,0ffh	; a26e  ........;kk..;..
	defb 003h,002h,023h,0ffh,004h,002h,023h,0ffh,006h,002h,023h,003h,0ffh,006h,023h,003h	; a27e  ..#...#...#...#.
	defb 003h,0ffh,006h,023h,003h,023h,0ffh,006h,002h,023h,003h,0ffh,005h,023h,002h,002h	; a28e  ...#.#...#...#..
	defb 023h,0ffh,007h,002h,023h,0ffh,007h,002h,003h,0ffh,005h,023h,0ffh,009h,002h,023h	; a29e  #...#......#...#
	defb 058h,000h,0ffh,007h,002h,023h,002h,002h,0ffh,005h,023h,003h,0ffh,007h,002h,023h	; a2ae  X....#....#....#
	defb 002h,002h,0ffh,005h,023h,003h,003h,023h,0ffh,006h,002h,003h,023h,0ffh,006h,002h	; a2be  ....#..#....#...
	defb 003h,003h,023h,023h,0ffh,004h,002h,0ffh,005h,003h,0ffh,005h,023h,0ffh,004h,002h	; a2ce  ..##........#...
	defb 0ffh,005h,023h,0ffh,005h,003h,0ffh,004h,002h,023h,023h,0ffh,004h,003h,023h,023h	; a2de  ..#......##...##
	defb 0ffh,004h,002h,0ffh,005h,003h,0ffh,005h,023h,0ffh,004h,002h,0ffh,005h,023h,0ffh	; a2ee  ........#.....#.
	defb 005h,003h,0ffh,004h,002h,023h,023h,0ffh,002h,003h,053h,000h,0ffh,005h,003h,0ffh	; a2fe  .....##...S.....
	defb 003h,023h,0ffh,005h,003h,0ffh,006h,023h,0ffh,005h,003h,0ffh,003h,023h,0ffh,005h	; a30e  .#.....#.....#..
	defb 003h,0ffh,005h,002h,0ffh,003h,023h,0ffh,005h,002h,0ffh,003h,023h,0ffh,007h,002h	; a31e  ......#.....#...
	defb 023h,0ffh,006h,002h,023h,003h,0ffh,006h,002h,023h,003h,0ffh,005h,002h,0ffh,003h	; a32e  #...#....#......
	defb 023h,0ffh,004h,002h,0ffh,008h,023h,0ffh,004h,003h,0ffh,004h,023h,0ffh,004h,003h	; a33e  #.....#.....#...
	defb 0ffh,009h,023h,003h,023h,0ffh,005h,003h,002h,002h,023h,023h,0ffh,004h,003h,032h	; a34e  ..#.#.....##...2
	defb 000h,003h,0ffh,034h,023h,0ffh,003h,003h,0ffh,007h,023h,003h,023h,023h,0ffh,006h	; a35e  ...4#.....#.##..
	defb 003h,002h,002h,0ffh,00ch,023h,003h,003h,0ffh,007h,03bh,0ffh,003h,003h,0ffh,005h	; a36e  .....#....;.....
	defb 03bh,003h,0ffh,007h,03bh,003h,003h,0ffh,006h,034h,04fh,034h,004h,04fh,004h,04fh	; a37e  ;...;....4O4.O.O
	defb 004h,04fh,004h,054h,000h,0ffh,008h,034h,004h,04fh,04fh,0ffh,004h,034h,003h,0ffh	; a38e  .O.T...4.OO..4..
	defb 003h,034h,0ffh,005h,003h,004h,0ffh,004h,034h,0ffh,008h,003h,034h,004h,04fh,0ffh	; a39e  .4......4...4.O.
	defb 006h,003h,034h,004h,0ffh,007h,003h,034h,002h,002h,023h,023h,002h,0ffh,003h,023h	; a3ae  ..4....4..##...#
	defb 002h,002h,0ffh,003h,023h,0ffh,003h,003h,0ffh,005h,002h,0ffh,003h,023h,0ffh,006h	; a3be  ....#........#..
	defb 002h,0ffh,007h,023h,0ffh,003h,003h,0ffh,006h,002h,0ffh,008h,023h,002h,002h,0ffh	; a3ce  ...#........#...
	defb 006h,003h,023h,023h,06bh,06bh,0ffh,006h,03bh,06dh,000h,013h,01bh,00bh,06bh,06bh	; a3de  ..##kk..;m....kk
	defb 00bh,06bh,00bh,003h,013h,013h,0ffh,004h,03bh,06bh,03bh,03bh,00bh,06bh,00bh,06bh	; a3ee  .k......;k;;.k.k
	defb 00bh,00bh,0ffh,008h,03bh,00bh,0ffh,003h,06bh,00bh,00bh,03bh,003h,00bh,06bh,00bh	; a3fe  ....;...k..;..k.
	defb 06bh,00bh,0ffh,003h,03bh,003h,03bh,03bh,06bh,06bh,03bh,03bh,003h,03bh,00bh,06bh	; a40e  k...;.;;kk;;.;.k
	defb 00bh,06bh,00bh,00bh,03bh,0ffh,004h,003h,013h,03bh,03bh,06bh,00bh,06bh,0ffh,005h	; a41e  .k..;....;;k.k..
	defb 03bh,003h,0ffh,006h,03bh,06bh,00bh,0ffh,007h,03bh,003h,00bh,06bh,06bh,00bh,0ffh	; a42e  ;...;k...;..kk..
	defb 004h,003h,06bh,0ffh,003h,03bh,0ffh,004h,003h,0ffh,003h,03bh,06bh,06bh,0ffh,003h	; a43e  ..k..;.....;kk..
	defb 03bh,003h,003h,03bh,03bh,0ffh,004h,00bh,059h,000h,0ffh,005h,003h,03bh,00bh,00bh	; a44e  ;..;;...Y....;..
	defb 0ffh,006h,003h,03bh,00bh,06bh,03bh,03bh,0ffh,005h,003h,00bh,06bh,00bh,00bh,03bh	; a45e  ...;.k;;....k..;
	defb 03bh,003h,003h,06bh,06bh,00bh,03bh,0ffh,007h,003h,03bh,03bh,06bh,00bh,06bh,003h	; a46e  ;..kk.;...;;k.k.
	defb 03bh,03bh,00bh,06bh,00bh,00bh,06bh,0ffh,008h,03bh,00bh,06bh,00bh,00bh,06bh,00bh	; a47e  ;;.k..k..;.k..k.
	defb 03bh,003h,0ffh,006h,03ch,003h,003h,0ffh,003h,03bh,0ffh,006h,003h,0ffh,005h,03bh	; a48e  ;...<....;.....;
	defb 06bh,06bh,00bh,06bh,06bh,0ffh,005h,03bh,00bh,06bh,0ffh,006h,03bh,0ffh,005h,003h	; a49e  kk.kk..;.k..;...
	defb 0ffh,00bh,03bh,05ch,000h,00bh,00bh,06bh,00bh,06bh,00bh,00bh,03bh,00bh,06bh,00bh	; a4ae  ..;\...k.k..;.k.
	defb 00bh,06bh,00bh,00bh,003h,0ffh,008h,034h,04fh,004h,024h,0ffh,005h,002h,04fh,04fh	; a4be  .k.....4O.$...OO
	defb 004h,024h,0ffh,004h,002h,0ffh,006h,034h,04fh,004h,04fh,004h,034h,0ffh,008h,003h	; a4ce  .$.....4O.O.4...
	defb 0ffh,003h,023h,002h,002h,0ffh,003h,023h,0ffh,005h,002h,03ch,03ch,00ch,00ch,0ffh	; a4de  ..#....#...<<...
	defb 003h,036h,006h,0ffh,003h,003h,0ffh,005h,002h,0ffh,006h,003h,0ffh,008h,023h,0ffh	; a4ee  .6............#.
	defb 008h,002h,023h,023h,0ffh,006h,002h,003h,003h,0ffh,003h,002h,023h,023h,0ffh,003h	; a4fe  ..##........##..
	defb 002h,045h,000h,0ffh,003h,003h,013h,014h,04fh,004h,004h,0ffh,005h,023h,001h,004h	; a50e  .E......O....#..
	defb 004h,002h,0ffh,007h,024h,0ffh,003h,003h,0ffh,005h,023h,0ffh,004h,003h,0ffh,012h	; a51e  ....$.....#.....
	defb 023h,0ffh,004h,003h,0ffh,005h,03bh,003h,0ffh,018h,023h,003h,0ffh,007h,023h,0ffh	; a52e  #.....;...#...#.
	defb 003h,003h,0ffh,005h,023h,0ffh,005h,002h,0ffh,003h,023h,0ffh,005h,002h,0ffh,003h	; a53e  ....#.....#.....
	defb 023h,002h,0ffh,003h,023h,0ffh,004h,003h,03fh,000h,0ffh,004h,002h,0ffh,004h,023h	; a54e  #...#...?......#
	defb 003h,003h,0ffh,006h,023h,002h,0ffh,00fh,023h,004h,0ffh,006h,034h,004h,0ffh,018h	; a55e  ....#...#...4...
	defb 034h,0ffh,003h,023h,0ffh,00ah,002h,0ffh,003h,023h,002h,0ffh,004h,023h,0ffh,003h	; a56e  4..#.....#...#..
	defb 003h,0ffh,00bh,023h,0ffh,005h,003h,0ffh,004h,023h,0ffh,004h,002h,0ffh,005h,003h	; a57e  ...#.....#......
	defb 0ffh,003h,023h,0ffh,005h,003h,03bh,03bh,00bh,05bh,000h,0ffh,005h,003h,00bh,00bh	; a58e  ..#...;;.[......
	defb 06bh,0ffh,005h,003h,0ffh,003h,03bh,0ffh,004h,003h,03bh,00bh,06bh,06bh,0ffh,004h	; a59e  k.....;...;.kk..
	defb 03bh,06bh,00bh,06bh,00bh,0ffh,005h,003h,0ffh,006h,03bh,00bh,06bh,00bh,06bh,00bh	; a5ae  ;k.k......;.k.k.
	defb 00bh,06bh,06bh,00bh,06bh,0ffh,003h,03bh,002h,0ffh,004h,023h,003h,023h,003h,002h	; a5be  .kk.k..;...#.#..
	defb 002h,0ffh,006h,023h,0ffh,004h,002h,0ffh,004h,024h,002h,002h,0ffh,008h,023h,0ffh	; a5ce  ...#.....$....#.
	defb 009h,003h,0ffh,005h,023h,0ffh,004h,003h,0ffh,004h,023h,003h,003h,0ffh,006h,03bh	; a5de  ....#.....#....;
	defb 00bh,06bh,00bh,0ffh,005h,03bh,03ch,000h,0ffh,008h,03bh,0ffh,003h,023h,0ffh,005h	; a5ee  .k...;<...;..#..
	defb 002h,0ffh,005h,003h,0ffh,007h,023h,0ffh,004h,002h,003h,023h,003h,0ffh,005h,023h	; a5fe  ......#....#...#
	defb 00bh,00bh,03bh,03bh,0ffh,004h,003h,0ffh,007h,023h,0ffh,004h,003h,0ffh,00dh,023h	; a60e  ..;;.....#.....#
	defb 0ffh,007h,03bh,00bh,002h,002h,0ffh,006h,023h,00bh,0ffh,006h,03bh,003h,0ffh,018h	; a61e  ..;.....#...;...
	defb 03bh,0ffh,008h,032h,046h,000h,0ffh,008h,032h,0ffh,003h,023h,002h,023h,0ffh,003h	; a62e  ;..2F...2..#.#..
	defb 002h,0ffh,016h,023h,003h,003h,0ffh,006h,023h,003h,003h,013h,0ffh,005h,03bh,003h	; a63e  ...#....#.....;.
	defb 003h,013h,0ffh,003h,03bh,00bh,00bh,03bh,03bh,00bh,06bh,0ffh,006h,03bh,0ffh,004h	; a64e  ....;..;;.k..;..
	defb 003h,0ffh,003h,03bh,00bh,013h,03bh,03bh,00bh,06bh,06bh,00bh,00bh,06bh,06bh,0ffh	; a65e  ...;..;;.kk..kk.
	defb 01eh,03bh,001h,00bh,00bh,06bh,00bh,06bh,00bh,0ffh,001h,06bh,04dh,000h,0ffh,003h	; a66e  .;...k.k...kM...
	defb 06bh,00bh,0ffh,004h,03bh,003h,0ffh,00eh,023h,003h,002h,0ffh,00dh,023h,002h,002h	; a67e  k...;...#....#..
	defb 0ffh,006h,023h,002h,002h,0ffh,003h,003h,03bh,03bh,00bh,00bh,0ffh,003h,03bh,00bh	; a68e  ..#.....;;....;.
	defb 00bh,0ffh,003h,03bh,003h,003h,023h,023h,0ffh,005h,002h,003h,0ffh,007h,023h,003h	; a69e  ...;..##......#.
	defb 023h,023h,0ffh,007h,002h,023h,002h,023h,002h,023h,023h,0ffh,008h,03ch,0ffh,008h	; a6ae  ##...#.#.##..<..
	defb 023h,0ffh,003h,003h,0ffh,005h,023h,003h,0ffh,007h,023h,051h,000h,0ffh,008h,03ch	; a6be  #.....#...#Q...<
	defb 002h,002h,0ffh,006h,023h,0ffh,003h,03bh,06bh,06bh,00bh,03bh,03bh,00bh,0ffh,006h	; a6ce  ....#..;kk.;;...
	defb 03bh,00bh,0ffh,007h,03ch,00ch,003h,023h,023h,003h,003h,023h,023h,003h,0ffh,003h	; a6de  ;...<..##..##...
	defb 03ch,00ch,00ch,0ffh,003h,036h,0ffh,003h,03ch,00ch,03ch,0ffh,003h,036h,003h,003h	; a6ee  <....6..<.<..6..
	defb 03ch,003h,003h,03ch,003h,003h,0ffh,008h,03ch,0ffh,003h,036h,003h,0ffh,003h,03ch	; a6fe  <..<....<..6...<
	defb 0ffh,005h,003h,03ch,003h,0ffh,00ah,03ch,0ffh,004h,003h,0ffh,014h,03ch,048h,000h	; a70e  ...<...<.....<H.
	defb 003h,003h,023h,003h,023h,023h,003h,003h,0ffh,018h,023h,003h,0ffh,007h,034h,004h	; a71e  ..#.##....#...4.
	defb 024h,0ffh,006h,002h,0ffh,003h,004h,0ffh,003h,024h,002h,002h,004h,04fh,004h,04fh	; a72e  $........$...O.O
	defb 004h,004h,024h,024h,003h,003h,0ffh,005h,034h,004h,0ffh,008h,03ch,0ffh,006h,034h	; a73e  ..$$....4...<..4
	defb 003h,003h,0ffh,003h,034h,004h,04fh,004h,04fh,004h,0ffh,010h,034h,0ffh,006h,002h	; a74e  ....4.O.O...4...
	defb 024h,004h,0ffh,005h,002h,004h,04fh,04fh,03fh,000h,0ffh,006h,002h,024h,004h,0ffh	; a75e  $.....OO?....$..
	defb 004h,002h,004h,04fh,004h,04fh,002h,024h,024h,04fh,004h,04fh,004h,04fh,0ffh,004h	; a76e  ...O.O.$$O.O.O..
	defb 024h,0ffh,004h,004h,0ffh,007h,034h,003h,0ffh,00dh,034h,0ffh,003h,003h,0ffh,007h	; a77e  $.....4...4.....
	defb 034h,003h,0ffh,008h,034h,004h,034h,0ffh,006h,003h,0ffh,007h,034h,003h,0ffh,008h	; a78e  4...4.4.....4...
	defb 034h,004h,004h,0ffh,00eh,034h,0ffh,010h,024h,055h,000h,03ch,00ch,0ffh,003h,03ch	; a79e  4....4..$U.<...<
	defb 0ffh,003h,003h,0ffh,010h,024h,003h,003h,0ffh,006h,023h,003h,0ffh,007h,023h,004h	; a7ae  .....$....#...#.
	defb 04fh,004h,04fh,0ffh,004h,034h,0ffh,006h,003h,013h,034h,003h,013h,013h,0ffh,003h	; a7be  O.O..4....4.....
	defb 034h,004h,04fh,0ffh,008h,034h,004h,004h,04fh,04fh,0ffh,003h,034h,003h,004h,0ffh	; a7ce  4.O..4..OO..4...
	defb 003h,034h,0ffh,004h,003h,04fh,0ffh,004h,034h,0ffh,004h,003h,0ffh,003h,034h,004h	; a7de  .4...O..4.....4.
	defb 04fh,004h,04fh,004h,0ffh,006h,024h,002h,0ffh,007h,024h,002h,034h,0ffh,007h,003h	; a7ee  O.O...$...$.4...
	defb 050h,000h,013h,034h,034h,04fh,034h,0ffh,003h,003h,004h,04fh,004h,004h,04fh,004h	; a7fe  P..44O4....O..O.
	defb 034h,034h,002h,012h,0ffh,005h,024h,04fh,002h,0ffh,007h,024h,004h,04fh,04fh,0ffh	; a80e  44....$O...$.OO.
	defb 004h,034h,003h,0ffh,00fh,034h,04fh,0ffh,007h,024h,002h,0ffh,007h,024h,002h,00bh	; a81e  .4...4O..$...$..
	defb 0ffh,006h,03bh,0ffh,006h,00bh,0ffh,003h,003h,002h,0ffh,006h,021h,002h,0ffh,004h	; a82e  ..;.........!...
	defb 003h,0ffh,004h,023h,0ffh,006h,002h,0ffh,007h,023h,0ffh,003h,003h,0ffh,006h,002h	; a83e  ...#.....#......
	defb 023h,023h,01bh,000h,0ffh,010h,023h,002h,0ffh,007h,024h,003h,0ffh,007h,023h,003h	; a84e  ##....#...$...#.
	defb 0ffh,00fh,023h,0ffh,004h,002h,0ffh,004h,024h,0ffh,010h,023h,0ffh,038h,034h,006h	; a85e  ..#.....$..#.84.
	defb 000h,0ffh,050h,024h,0ffh,030h,003h	; a86e

; ======================================================================
; CODIGO 0xa875..0xa926  (177 bytes)
; ======================================================================


limpia_para_el_fondo:		; Deja los 512 bytes del buffer a cero antes de elegir el fondo
	push bc			;a875   ; Limpia el buffer de terreno en RAM (0xE800-0xE9FF, 512 bytes)
	ld bc,00200h		;a876
	ld hl,0e800h		;a879
elige_el_fondo:		; Segun el tipo de terreno, una paleta de tiles u otra
	ld (hl),000h		;a87c   ; Limpia el buffer de terreno antes de elegir el sprite de fondo
	inc hl			;a87e
	dec bc			;a87f
	ld a,b			;a880
	or c			;a881
	jr nz,elige_el_fondo		;a882
	pop af			;a884
	push af			;a885
	ld de,0e902h		;a886   ; Segun el tipo de terreno en A (por la pila): 2,4,5,7,9,0xC,0xD usan un sprite de fondo, el resto otro
	ld hl,0a926h		;a889   ; El resto de valores de terreno usan el sprite de fondo por defecto (0xA926)
	cp 002h		;a88c
	jr z,fondo_alternativo		;a88e
	cp 004h		;a890
	jr c,descomprime_los_dos		;a892
	cp 005h		;a894
	jr z,descomprime_los_dos		;a896
	cp 007h		;a898
	jr z,descomprime_los_dos		;a89a
	cp 009h		;a89c
	jr z,descomprime_los_dos		;a89e
	cp 00ch		;a8a0
	jr z,descomprime_los_dos		;a8a2
	cp 00dh		;a8a4
	jr z,descomprime_los_dos		;a8a6
fondo_alternativo:		; La paleta de 0xA979
	ld de,0e934h		;a8a8
	ld hl,0a979h		;a8ab
descomprime_los_dos:		; El fondo en 0xE902 y la vista de terreno en 0xE800
	push de			;a8ae   ; Descomprime el sprite de fondo elegido en 0xE902, y ademas el sprite de terreno correspondiente en 0xE800
	ld de,0e800h		;a8af
	call paleta_acumulada		;a8b2
	pop de			;a8b5
	pop af			;a8b6
	dec a			;a8b7
	add a,a			;a8b8
	ld c,a			;a8b9
	ld b,000h		;a8ba
	ld ix,0a9ech		;a8bc   ; Indexa tabla_vistas_de_terreno con el terreno actual (-1)*2 y descomprime el sprite de terreno en 0xE800
	add ix,bc		;a8c0
	ld l,(ix+000h)		;a8c2
	ld h,(ix+001h)		;a8c5
	jp paleta_acumulada		;a8c8
paleta_acumulada:		; Descomprime y convierte los bytes en codigos de tile de 16 bits acumulados: los mapas de indices leen de aqui
	push hl			;a8cb   ; descomprime con 0xA8FB y despues separa cada byte con un cero, recorriendo el buffer HACIA ATRAS para no pisarse: la tira pasa a ser de valores de 16 bits
	push de			;a8cc
	call descomprime		;a8cd
	pop de			;a8d0
	pop hl			;a8d1
	push bc			;a8d2   ; guarda la longitud de salida, que es la cuenta del bucle de separacion
	push bc			;a8d3
	pop hl			;a8d4
	add hl,hl			;a8d5
	add hl,de			;a8d6
	ex de,hl			;a8d7
	add hl,bc			;a8d8
	dec de			;a8d9
	dec hl			;a8da
	xor a			;a8db
separa_con_ceros:		; Escribe cada byte seguido de un cero, hacia atras: los convierte en valores de 16 bits
	ld (de),a			;a8dc   ; un cero y el byte, hacia atras: cada byte de la fuente ocupa ya dos, byte bajo y cero
	dec de			;a8dd
	ldd		;a8de
	jp pe,separa_con_ceros		;a8e0
	inc de			;a8e3
	pop bc			;a8e4
	ld hl,00000h		;a8e5
acumula_los_codigos:		; La suma corrida que convierte las diferencias en codigos absolutos
	push bc			;a8e8   ; la suma corrida: cada valor es el anterior mas el byte, y por eso hacen falta 16 bits -tabla_patrones_terreno tiene 570 entradas-
	ld a,(de)			;a8e9
	ld c,a			;a8ea
	ld b,000h		;a8eb
	add hl,bc			;a8ed
	ld a,l			;a8ee   ; el acumulado se guarda en su sitio, byte bajo y byte alto
	ld (de),a			;a8ef
	inc de			;a8f0
	ld a,h			;a8f1
	ld (de),a			;a8f2
	inc de			;a8f3
	pop bc			;a8f4
	dec bc			;a8f5
	ld a,b			;a8f6
	or c			;a8f7
	jr nz,acumula_los_codigos		;a8f8
	ret			;a8fa
descomprime:		; El descompresor: la cabecera de dos bytes dice cuantos bytes de FUENTE quedan
	push de			;a8fb   ; Descompresor RLE propio del campo. Cabecera de 2 bytes: cuenta de bytes FUENTE que quedan por consumir
	ld c,(hl)			;a8fc
	inc hl			;a8fd
	ld b,(hl)			;a8fe
	inc hl			;a8ff
lee_un_byte:		; Copia literal, salvo que sea 0xFF
	ld a,(hl)			;a900   ; Byte normal: copia literal (ldi copia y descuenta bc, jp pe repite mientras bc!=0)
	cp 0ffh		;a901
	jr z,abre_la_racha		;a903
	ldi		;a905
	jp pe,lee_un_byte		;a907
	jr cuenta_lo_escrito		;a90a
abre_la_racha:		; El 0xFF abre racha: cuenta y valor en los dos bytes siguientes
	push bc			;a90c   ; Byte 0xFF: racha -los dos siguientes son [cuenta][valor]-, escribe 'valor' esa cuenta de veces
	inc hl			;a90d
	ld b,(hl)			;a90e
	inc hl			;a90f
	ld a,(hl)			;a910
	inc hl			;a911
escribe_la_racha:		; Escribe el valor esas veces
	ld (de),a			;a912   ; Bucle de copia hacia adelante de la racha (parte del descompresor 0xA8FB)
	inc de			;a913
	djnz escribe_la_racha		;a914
	pop bc			;a916
	dec bc			;a917
	dec bc			;a918
	dec bc			;a919
	ld a,b			;a91a
	or c			;a91b
	jr nz,lee_un_byte		;a91c
cuenta_lo_escrito:		; Devuelve en BC cuantos bytes han salido
	ex de,hl			;a91e   ; Resta DE de HL y guarda la diferencia en BC
	pop de			;a91f
	or a			;a920
	sbc hl,de		;a921
	push hl			;a923
	pop bc			;a924
	ret			;a925

; ----------------------------------------------------------------------
; DATOS paleta_de_tiles_a: Sprite de fondo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (83 bytes fuente, 129 de
;   salida)
;   0xa926..0xa979  (83 bytes)
DATA_paleta_de_tiles_a:
	defb 051h,000h,0ffh,001h,000h,0ffh,007h,001h,003h,0ffh,01ch,001h,00ah,003h,0ffh,004h	; a926  Q...............
	defb 001h,004h,002h,0ffh,005h,001h,002h,001h,002h,0ffh,00eh,001h,022h,001h,008h,001h	; a936  ............"...
	defb 003h,003h,001h,009h,001h,00ch,005h,002h,00ch,008h,0ffh,005h,001h,005h,0ffh,003h	; a946  ................
	defb 001h,003h,001h,008h,001h,005h,00ah,001h,002h,0ffh,003h,001h,002h,004h,004h,009h	; a956  ................
	defb 0ffh,008h,001h,003h,004h,001h,003h,001h,007h,001h,002h,0ffh,003h,001h,015h,001h	; a966  ................
	defb 010h,002h,0c6h	; a976

; ----------------------------------------------------------------------
; DATOS paleta_de_tiles_b: Sprite de fondo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (115 bytes fuente, 153 de
;   salida)
;   0xa979..0xa9ec  (115 bytes)
DATA_paleta_de_tiles_b:
	defb 071h,000h,0ffh,001h,000h,0ffh,007h,001h,003h,0ffh,00ch,001h,003h,0ffh,006h,001h	; a979  q...............
	defb 002h,0ffh,005h,001h,004h,0ffh,008h,001h,002h,002h,001h,0ffh,003h,002h,0ffh,003h	; a989  ................
	defb 001h,007h,0ffh,00eh,001h,022h,001h,00ch,01ah,002h,001h,004h,002h,00ah,002h,0ffh	; a999  ....."..........
	defb 003h,001h,002h,0ffh,006h,001h,005h,0ffh,003h,001h,002h,001h,001h,004h,0ffh,005h	; a9a9  ................
	defb 001h,003h,0ffh,003h,001h,009h,003h,002h,001h,006h,00dh,0ffh,003h,001h,003h,001h	; a9b9  ................
	defb 001h,002h,001h,002h,001h,001h,003h,009h,002h,002h,0ffh,003h,001h,013h,0ffh,003h	; a9c9  ................
	defb 001h,00fh,00ah,001h,009h,019h,025h,054h,002h,001h,003h,0ffh,004h,001h,007h,00ch	; a9d9  ......%T........
	defb 0ffh,005h,001h	; a9e9

; ----------------------------------------------------------------------
; DATOS tabla_vistas_de_terreno: 18 punteros de 16 bits a sprites del campo,
;   indexados por BC desde 0xA8CB (0xA8BC)
;   0xa9ec..0xaa10  (36 bytes)
DATA_tabla_vistas_de_terreno:
	defw 0aa10h,0ab9ah,0aa47h,0ab6fh,0aa90h,0ac38h	; a9ec
	defw 0aa90h,0ab30h,0aae4h,0abd8h,0ab6fh,0aa47h	; a9f8
	defw 0aae4h,0ab9ah,0ab30h,0ac38h,0abd8h,0ac7ch	; aa04

; ----------------------------------------------------------------------
; DATOS vista_terreno_01: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (55 bytes fuente)
;   0xaa10..0xaa47  (55 bytes)
DATA_vista_terreno_01:
	defb 035h,000h,031h,007h,001h,001h,002h,007h,003h,036h,0ffh,003h,001h,006h,001h,003h	; aa10  5.1......6......
	defb 0ffh,003h,001h,014h,001h,006h,021h,00eh,001h,008h,001h,001h,003h,005h,002h,001h	; aa20  ......!.........
	defb 001h,002h,001h,001h,002h,0ffh,007h,001h,00ah,001h,002h,001h,001h,003h,001h,003h	; aa30  ................
	defb 0ffh,005h,001h,003h,005h,052h,028h	; aa40

; ----------------------------------------------------------------------
; DATOS vista_terreno_02: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (73 bytes fuente)
;   0xaa47..0xaa90  (73 bytes)
DATA_vista_terreno_02:
	defb 047h,000h,039h,001h,009h,003h,034h,001h,022h,002h,001h,001h,006h,002h,001h,001h	; aa47  G.9...4.".......
	defb 002h,003h,005h,001h,00ah,002h,005h,001h,003h,001h,002h,001h,00ah,008h,003h,005h	; aa57  ................
	defb 003h,001h,002h,001h,001h,003h,0ffh,003h,001h,002h,001h,00ah,001h,002h,001h,001h	; aa67  ................
	defb 003h,001h,00bh,01ch,001h,001h,004h,00fh,001h,008h,001h,002h,001h,002h,002h,0ffh	; aa77  ................
	defb 00eh,001h,002h,0ffh,006h,001h,012h,001h,096h	; aa87  .........

; ----------------------------------------------------------------------
; DATOS vista_terreno_03: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (84 bytes fuente)
;   0xaa90..0xaae4  (84 bytes)
DATA_vista_terreno_03:
	defb 052h,000h,038h,001h,003h,007h,003h,038h,017h,003h,002h,0ffh,003h,001h,002h,0ffh	; aa90  R.8....8........
	defb 003h,001h,002h,002h,001h,001h,004h,001h,03ch,003h,001h,002h,007h,0ffh,004h,001h	; aaa0  ........<.......
	defb 00ah,001h,002h,001h,001h,003h,001h,00bh,005h,00bh,017h,001h,001h,007h,001h,003h	; aab0  ................
	defb 001h,005h,001h,001h,003h,004h,002h,004h,00eh,014h,00ah,001h,001h,004h,001h,001h	; aac0  ................
	defb 002h,001h,006h,001h,001h,002h,0ffh,003h,001h,006h,001h,00ch,007h,001h,00bh,002h	; aad0  ................
	defb 001h,001h,003h,001h	; aae0

; ----------------------------------------------------------------------
; DATOS vista_terreno_04: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (76 bytes fuente)
;   0xaae4..0xab30  (76 bytes)
DATA_vista_terreno_04:
	defb 04ah,000h,038h,001h,001h,002h,022h,035h,001h,001h,008h,003h,001h,003h,003h,007h	; aae4  J.8..."5........
	defb 001h,019h,011h,006h,002h,00ah,001h,001h,009h,0ffh,004h,001h,00ah,001h,002h,001h	; aaf4  ................
	defb 001h,007h,001h,002h,001h,001h,003h,018h,003h,010h,002h,004h,001h,002h,001h,001h	; ab04  ................
	defb 008h,002h,003h,001h,004h,001h,00ah,001h,003h,021h,001h,001h,002h,003h,003h,001h	; ab14  .........!......
	defb 009h,001h,01ah,00ch,002h,001h,001h,004h,011h,0ffh,003h,001h	; ab24  ............

; ----------------------------------------------------------------------
; DATOS vista_terreno_05: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (62 bytes fuente)
;   0xab30..0xab6e  (62 bytes)
DATA_vista_terreno_05:
	defb 03ch,000h,017h,001h,008h,013h,009h,009h,017h,001h,02eh,001h,020h,0ffh,003h,001h	; ab30  <........... ...
	defb 011h,001h,001h,01eh,003h,001h,002h,004h,0ffh,003h,001h,012h,001h,004h,003h,004h	; ab40  ................
	defb 001h,002h,001h,008h,017h,007h,00ah,004h,002h,003h,001h,005h,004h,001h,001h,003h	; ab50  ................
	defb 004h,001h,035h,014h,01ah,001h,009h,01bh,0ffh,003h,001h,005h,001h,007h	; ab60  ..5...........

; ----------------------------------------------------------------------
; DATOS relleno_ab6e: Un byte suelto entre dos sprites, sin explicar (posible
;   relleno de alineacion)
;   0xab6e..0xab6f  (1 bytes)
DATA_relleno_ab6e:
	defb 024h	; ab6e

; ----------------------------------------------------------------------
; DATOS vista_terreno_06: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (43 bytes fuente)
;   0xab6f..0xab9a  (43 bytes)
DATA_vista_terreno_06:
	defb 029h,000h,033h,002h,00dh,03ch,025h,008h,029h,001h,00ah,00bh,0ffh,003h,001h,002h	; ab6f  ).3..<%.).......
	defb 007h,0ffh,004h,001h,005h,001h,004h,003h,004h,001h,002h,0ffh,007h,001h,002h,002h	; ab7f  ................
	defb 02bh,01dh,004h,00bh,027h,00eh,02ch,013h,008h,001h,008h	; ab8f  +...'.,....

; ----------------------------------------------------------------------
; DATOS vista_terreno_07: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (62 bytes fuente)
;   0xab9a..0xabd8  (62 bytes)
DATA_vista_terreno_07:
	defb 03ch,000h,017h,001h,008h,021h,04ah,001h,006h,025h,009h,001h,001h,00ah,013h,001h	; ab9a  <....!J..%......
	defb 001h,002h,001h,008h,001h,003h,0ffh,004h,001h,010h,003h,004h,001h,002h,001h,008h	; abaa  ................
	defb 014h,001h,018h,005h,001h,005h,003h,001h,001h,003h,005h,005h,004h,001h,005h,001h	; abba  ................
	defb 024h,009h,001h,001h,004h,046h,001h,001h,00ch,002h,002h,018h,003h,001h	; abca  $....F........

; ----------------------------------------------------------------------
; DATOS vista_terreno_08: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (96 bytes fuente)
;   0xabd8..0xac38  (96 bytes)
DATA_vista_terreno_08:
	defb 05eh,000h,018h,01dh,005h,002h,005h,001h,002h,001h,035h,007h,010h,001h,003h,0ffh	; abd8  ^.........5.....
	defb 003h,001h,005h,006h,008h,007h,00dh,016h,00ah,005h,002h,003h,0ffh,004h,001h,002h	; abe8  ................
	defb 0ffh,004h,001h,003h,0ffh,003h,001h,00bh,003h,004h,001h,003h,001h,001h,002h,004h	; abf8  ................
	defb 002h,00fh,005h,00ah,008h,0ffh,003h,002h,001h,002h,001h,001h,004h,004h,002h,003h	; ac08  ................
	defb 004h,005h,001h,004h,024h,001h,005h,0ffh,003h,001h,005h,001h,002h,001h,00ah,00ch	; ac18  ....$...........
	defb 008h,001h,005h,00ch,002h,001h,001h,004h,011h,010h,00fh,001h,007h,001h,00ah,001h	; ac28  ................

; ----------------------------------------------------------------------
; DATOS vista_terreno_09: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (68 bytes fuente)
;   0xac38..0xac7c  (68 bytes)
DATA_vista_terreno_09:
	defb 042h,000h,017h,001h,008h,013h,00eh,001h,002h,001h,03bh,001h,010h,001h,006h,0ffh	; ac38  B.........;.....
	defb 005h,001h,002h,004h,00ah,003h,039h,003h,001h,003h,0ffh,003h,001h,003h,0ffh,003h	; ac48  ......9.........
	defb 001h,00bh,003h,004h,001h,002h,001h,008h,002h,01eh,009h,003h,002h,004h,012h,002h	; ac58  ................
	defb 004h,022h,00ch,001h,007h,005h,006h,001h,001h,00bh,002h,008h,001h,005h,00ah,002h	; ac68  ."..............
	defb 002h,001h,001h,04ah	; ac78

; ----------------------------------------------------------------------
; DATOS vista_terreno_10: Sprite del campo comprimido con el formato de
;   0xA8FB, decodificado y verificado en Python (59 bytes fuente)
;   0xac7c..0xacb7  (59 bytes)
DATA_vista_terreno_10:
	defb 039h,000h,017h,001h,008h,013h,005h,009h,03ah,00ch,00eh,003h,010h,004h,014h,001h	; ac7c  9.......:.......
	defb 001h,005h,01ah,003h,008h,001h,009h,0ffh,004h,001h,00ah,003h,004h,001h,002h,001h	; ac8c  ................
	defb 008h,01dh,001h,00ah,013h,002h,012h,00ah,007h,022h,05ah,001h,001h,003h,004h,010h	; ac9c  ........."Z.....
	defb 0ffh,003h,001h,003h,0ffh,003h,001h,007h,006h,010h,001h	; acac  ...........

; ----------------------------------------------------------------------
; DATOS tabla_planos_de_hoyo: 18 punteros de 16 bits a sprites, indexados por
;   (0xE0B4)-1 desde 0x5DEC (0x5DFB)
;   0xacb7..0xacdb  (36 bytes)
DATA_tabla_planos_de_hoyo:
	defw 0acdbh,0b0a5h,0ad7bh,0affah,0ae13h,0b1feh	; acb7
	defw 0ae13h,0af54h,0aeb6h,0b146h,0affah,0ad7bh	; acc3
	defw 0aeb6h,0b0a5h,0af54h,0b1feh,0b146h,0b2a3h	; accf

; ----------------------------------------------------------------------
; DATOS plano_hoyo_01: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (160 bytes fuente, 190 de salida)
;   0xacdb..0xad7b  (160 bytes)
DATA_plano_hoyo_01:
	defb 09eh,000h,0ffh,007h,001h,00dh,0ffh,004h,001h,00dh,0ffh,003h,001h,00dh,001h,00dh	; acdb  ................
	defb 001h,001h,00dh,001h,01fh,021h,05dh,022h,00dh,0ffh,004h,001h,00dh,020h,036h,037h	; aceb  .....!]"..... 67
	defb 023h,024h,00dh,001h,001h,00dh,028h,012h,013h,014h,015h,025h,0ffh,004h,001h,029h	; acfb  #$....(....%...)
	defb 016h,017h,009h,018h,026h,00dh,0ffh,003h,001h,00dh,01bh,00ch,019h,01ah,027h,0ffh	; ad0b  ....&.........'.
	defb 004h,001h,01eh,0ffh,003h,00ch,02ah,00dh,0ffh,004h,001h,01dh,00eh,00ch,00ch,004h	; ad1b  ......*.........
	defb 00dh,0ffh,003h,001h,00dh,01eh,00fh,00ch,00ch,02bh,0ffh,005h,001h,00dh,01bh,00ch	; ad2b  .........+......
	defb 010h,006h,0ffh,006h,001h,01ch,00ch,011h,008h,0ffh,006h,001h,01bh,00ch,004h,00dh	; ad3b  ................
	defb 0ffh,005h,001h,00dh,01ch,00ch,02bh,001h,00dh,0ffh,003h,001h,00dh,01eh,00ch,00ch	; ad4b  ......+.........
	defb 02ch,00dh,0ffh,005h,001h,00dh,01bh,00ch,006h,0ffh,006h,001h,01dh,034h,035h,007h	; ad5b  ,............45.
	defb 0ffh,005h,001h,00dh,01eh,02dh,056h,008h,0ffh,007h,001h,032h,033h,0ffh,005h,001h	; ad6b  .....-V....23...

; ----------------------------------------------------------------------
; DATOS plano_hoyo_02: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (152 bytes fuente, 190 de salida)
;   0xad7b..0xae13  (152 bytes)
DATA_plano_hoyo_02:
	defb 096h,000h,0ffh,006h,001h,00dh,0ffh,007h,001h,00dh,0ffh,006h,001h,00dh,0ffh,005h	; ad7b  ................
	defb 001h,00dh,0ffh,004h,001h,00dh,089h,08ah,001h,00dh,0ffh,004h,001h,00dh,065h,00ch	; ad8b  ..............e.
	defb 00ch,08bh,005h,08ch,00dh,0ffh,003h,001h,00ch,039h,038h,036h,037h,00ch,0ffh,004h	; ad9b  .........9867...
	defb 001h,05eh,0ffh,004h,00ch,08dh,0ffh,004h,001h,05fh,00ch,00ch,040h,07eh,04eh,00dh	; adab  .^......._..@~N.
	defb 001h,001h,00dh,05fh,00ch,078h,0ffh,003h,009h,07fh,001h,00dh,001h,05fh,00ch,04bh	; adbb  ..._.x......._.K
	defb 009h,047h,048h,00dh,001h,001h,00dh,05fh,00eh,00ch,084h,00dh,0ffh,005h,001h,05fh	; adcb  .GH...._......._
	defb 00fh,00ch,025h,001h,00dh,0ffh,003h,001h,00dh,060h,00ch,00ch,026h,0ffh,006h,001h	; addb  ..%......`..&...
	defb 061h,00ch,00ch,085h,00dh,00dh,0ffh,003h,001h,00dh,001h,00ch,00ch,086h,00dh,0ffh	; adeb  a...............
	defb 005h,001h,00dh,05eh,080h,081h,0ffh,007h,001h,062h,082h,083h,001h,00dh,0ffh,004h	; adfb  ...^.....b......
	defb 001h,00dh,001h,087h,088h,0ffh,00eh,001h	; ae0b  ........

; ----------------------------------------------------------------------
; DATOS plano_hoyo_03: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (163 bytes fuente, 190 de salida)
;   0xae13..0xaeb6  (163 bytes)
DATA_plano_hoyo_03:
	defb 0a1h,000h,0ffh,009h,001h,00dh,0ffh,003h,001h,00dh,065h,00ch,066h,067h,00dh,001h	; ae13  ..........e.fg..
	defb 001h,00dh,001h,0a8h,00ch,036h,037h,068h,0ffh,003h,001h,00dh,0a8h,00ch,069h,06ah	; ae23  .....67h......ij
	defb 00ch,00ch,0ffh,003h,001h,065h,0ffh,005h,00ch,08dh,00dh,001h,00dh,075h,09ah,00ch	; ae33  .....e.......u..
	defb 00ch,07ch,07dh,00dh,0ffh,003h,001h,00ch,09ch,09dh,0a6h,00dh,0ffh,005h,001h,05eh	; ae43  .|}............^
	defb 00ch,00ch,0a7h,001h,001h,00dh,0ffh,003h,001h,062h,0ffh,003h,00ch,097h,00dh,0ffh	; ae53  .........b......
	defb 004h,001h,00dh,072h,073h,00ch,00ch,097h,00dh,0ffh,005h,001h,00dh,05eh,00ch,09eh	; ae63  ...rs........^..
	defb 091h,0ffh,006h,001h,062h,00ch,09fh,00ch,0ffh,004h,001h,00dh,001h,001h,00ch,00ch	; ae73  ....b...........
	defb 098h,00dh,0ffh,004h,001h,00dh,0a8h,00ch,00ch,02ch,0ffh,005h,001h,063h,0ffh,003h	; ae83  .........,...c..
	defb 00ch,007h,0ffh,004h,001h,00dh,064h,00ch,00ch,098h,00dh,0ffh,003h,001h,00dh,028h	; ae93  ......d........(
	defb 0a0h,0a1h,00ch,099h,0ffh,005h,001h,029h,0a2h,0a3h,08dh,0ffh,007h,001h,032h,033h	; aea3  .......)......23
	defb 0ffh,005h,001h	; aeb3

; ----------------------------------------------------------------------
; DATOS plano_hoyo_04: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (158 bytes fuente, 190 de salida)
;   0xaeb6..0xaf54  (158 bytes)
DATA_plano_hoyo_04:
	defb 09ch,000h,0ffh,007h,001h,00dh,0ffh,004h,001h,00dh,001h,001h,00dh,0ffh,00ch,001h	; aeb6  ................
	defb 00dh,001h,001h,00dh,065h,00ch,066h,093h,00dh,0ffh,004h,001h,028h,00ch,036h,037h	; aec6  ....e.f.....(.67
	defb 00ch,091h,00dh,0ffh,003h,001h,029h,00ch,00ch,0a9h,0aah,00ch,084h,0ffh,003h,001h	; aed6  ......).........
	defb 00dh,003h,0ffh,004h,00ch,086h,00dh,0ffh,003h,001h,00dh,05eh,00ch,040h,015h,00ch	; aee6  ...........^.@..
	defb 091h,001h,001h,00dh,001h,062h,06ch,009h,009h,00ch,092h,001h,001h,0b8h,03bh,03eh	; aef6  .....bl.......;>
	defb 009h,009h,018h,00ch,00ch,001h,03eh,0ffh,005h,009h,08fh,00ch,00ch,001h,0ffh,005h	; af06  ......>.........
	defb 009h,06dh,00ch,010h,00ch,001h,0ffh,004h,009h,06dh,00ch,076h,02eh,098h,001h,046h	; af16  .m.......m.v...F
	defb 009h,049h,070h,00ch,00ch,077h,074h,099h,001h,001h,063h,0ffh,005h,00ch,002h,00dh	; af26  .Ip..wt...c.....
	defb 001h,001h,064h,0a0h,0a1h,00ch,00ch,002h,00dh,001h,001h,00dh,00ch,0a2h,0a3h,00ch	; af36  ..d.............
	defb 002h,001h,001h,00dh,001h,001h,087h,00ch,07ch,07dh,00dh,0ffh,00eh,001h	; af46  ........|}....

; ----------------------------------------------------------------------
; DATOS plano_hoyo_05: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (166 bytes fuente, 190 de salida)
;   0xaf54..0xaffa  (166 bytes)
DATA_plano_hoyo_05:
	defb 0a4h,000h,0ffh,005h,001h,00dh,0ffh,00bh,001h,00dh,001h,001h,00dh,001h,001h,00dh	; af54  ................
	defb 0ffh,007h,001h,00dh,0ffh,003h,001h,00dh,001h,001h,00dh,001h,00dh,0b8h,0b9h,0bah	; af64  ................
	defb 03ch,04dh,04eh,00dh,001h,001h,03dh,009h,049h,04ah,0ffh,003h,009h,0bbh,00dh,001h	; af74  <MN...=.IJ......
	defb 009h,0b4h,00ch,00ch,030h,050h,051h,009h,04dh,04eh,0b4h,00ch,036h,037h,06bh,00ch	; af84  ....0PQ.MN..67k.
	defb 00ch,0bch,009h,009h,0b5h,069h,06ah,0ffh,005h,00ch,0b7h,009h,009h,053h,0ffh,005h	; af94  .....ij......S..
	defb 00ch,09eh,0beh,0ffh,003h,009h,0b5h,05ah,058h,02fh,00ch,09fh,00ch,0ffh,005h,009h	; afa4  .......ZX/......
	defb 0b4h,0ffh,003h,00ch,0bdh,009h,050h,051h,009h,0b4h,0ffh,003h,00ch,0bdh,009h,009h	; afb4  ......PQ........
	defb 00ch,00ch,0bfh,0b3h,03fh,041h,042h,0ffh,003h,009h,0ffh,003h,00ch,0c0h,0ffh,005h	; afc4  ....?AB.........
	defb 009h,06eh,05eh,00ch,078h,0ffh,005h,009h,06dh,00ch,062h,00ch,04bh,04ch,0ffh,003h	; afd4  .n^.x...m.b.KL..
	defb 009h,06dh,0adh,00ch,00dh,087h,00ch,034h,035h,030h,031h,0ffh,003h,00ch,001h,001h	; afe4  .m.....4501.....
	defb 087h,02dh,056h,0ffh,005h,00ch	; aff4

; ----------------------------------------------------------------------
; DATOS plano_hoyo_06: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (171 bytes fuente, 190 de salida)
;   0xaffa..0xb0a5  (171 bytes)
DATA_plano_hoyo_06:
	defb 0a9h,000h,0ffh,005h,009h,047h,048h,001h,00dh,001h,0ffh,003h,009h,049h,045h,001h	; affa  .....GH......IE.
	defb 00dh,00dh,001h,001h,009h,009h,0b4h,036h,037h,00ch,066h,093h,00dh,001h,009h,009h	; b00a  .......67.f.....
	defb 0b3h,0ffh,005h,00ch,084h,001h,009h,049h,04ah,043h,057h,0ffh,003h,00ch,02ch,001h	; b01a  .......IJCW...,.
	defb 009h,0b3h,00ch,0c1h,0c4h,0b2h,00ch,00ch,007h,001h,009h,009h,0b5h,044h,0c3h,0ffh	; b02a  .............D..
	defb 003h,00ch,00dh,001h,0ffh,004h,009h,08fh,00ch,00ch,098h,001h,001h,009h,009h,049h	; b03a  ...............I
	defb 031h,0ffh,003h,00ch,02ch,001h,001h,009h,0c3h,0ffh,004h,00ch,010h,006h,00dh,001h	; b04a  1...,...........
	defb 009h,0c2h,0ffh,003h,00ch,076h,0a4h,007h,001h,001h,009h,0ffh,004h,00ch,077h,0a5h	; b05a  .....v........w.
	defb 008h,00dh,001h,0c3h,0ffh,005h,00ch,002h,00dh,001h,001h,08fh,0ffh,004h,00ch,002h	; b06a  ................
	defb 00dh,001h,001h,00dh,0ffh,004h,00ch,098h,001h,001h,00dh,001h,001h,00ch,0a0h,0a1h	; b07a  ................
	defb 00ch,099h,00dh,0ffh,004h,001h,087h,0a2h,0a3h,08dh,00dh,0ffh,006h,001h,032h,033h	; b08a  ..............23
	defb 0ffh,004h,001h,00dh,0ffh,004h,001h,00dh,0ffh,007h,001h	; b09a  ...........

; ----------------------------------------------------------------------
; DATOS plano_hoyo_07: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (161 bytes fuente, 190 de salida)
;   0xb0a5..0xb146  (161 bytes)
DATA_plano_hoyo_07:
	defb 09fh,000h,001h,00dh,0ffh,00fh,001h,00dh,0ffh,003h,001h,00dh,001h,00dh,0ffh,008h	; b0a5  ................
	defb 001h,00dh,0ffh,003h,001h,00dh,0ffh,005h,001h,094h,03eh,00bh,04dh,04eh,00dh,001h	; b0b5  ..........>.MN..
	defb 001h,00dh,0c5h,00bh,00ah,00bh,009h,00bh,0e7h,0ffh,003h,001h,0c6h,00bh,00bh,00ah	; b0c5  ................
	defb 00bh,00bh,0e8h,00dh,001h,00dh,00bh,009h,018h,04fh,0d3h,04ah,00bh,07fh,001h,0c5h	; b0d5  .........O.J....
	defb 00bh,00bh,0c2h,036h,037h,00ch,00ch,001h,001h,0c6h,00ah,00bh,069h,06ah,00ch,06ch	; b0e5  ...67.......ij.l
	defb 043h,0e7h,001h,0c7h,00bh,0d4h,00ch,0cah,0cbh,00bh,00bh,0e8h,001h,0c8h,0ffh,005h	; b0f5  C...............
	defb 00bh,009h,00ah,0e9h,001h,001h,00bh,00bh,009h,00ah,0ffh,003h,00bh,0d6h,001h,0c5h	; b105  ................
	defb 0ffh,005h,00bh,00ah,0e9h,001h,001h,0c8h,00bh,00bh,00ah,0ffh,003h,00bh,0e8h,0ffh	; b115  ................
	defb 003h,001h,0d7h,0ffh,004h,00bh,00ah,0d6h,0ffh,004h,001h,0e5h,0e6h,00ah,00bh,0d6h	; b125  ................
	defb 0ffh,006h,001h,028h,034h,035h,004h,0ffh,006h,001h,029h,02dh,056h,027h,0ffh,003h	; b135  ...(45....)-V'..
	defb 001h	; b145

; ----------------------------------------------------------------------
; DATOS plano_hoyo_08: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (184 bytes fuente, 190 de salida)
;   0xb146..0xb1fe  (184 bytes)
DATA_plano_hoyo_08:
	defb 0b6h,000h,001h,001h,00dh,0ffh,004h,001h,00dh,001h,001h,00dh,01fh,021h,093h,00dh	; b146  .............!..
	defb 001h,00dh,0ffh,004h,001h,020h,036h,037h,08bh,090h,00ch,00ch,091h,001h,04eh,0ffh	; b156  ..... 67......N.
	defb 003h,00ch,06bh,0ffh,003h,00ch,092h,001h,00bh,0b5h,054h,0ffh,005h,00ch,098h,001h	; b166  ..k.......T.....
	defb 00bh,009h,00bh,053h,0ffh,004h,00ch,099h,00dh,0ffh,003h,00bh,009h,053h,0ffh,003h	; b176  ...S.........S..
	defb 00ch,00dh,001h,00bh,00ah,00bh,00ah,00bh,052h,00ch,010h,084h,001h,0ffh,003h,00ah	; b186  ........R.......
	defb 00bh,00bh,08fh,00ch,011h,006h,001h,00bh,009h,00bh,00bh,06dh,0ffh,003h,00ch,007h	; b196  ...........m....
	defb 00dh,009h,00bh,06eh,06fh,0ffh,003h,00ch,088h,001h,001h,00bh,06dh,0ffh,003h,00ch	; b1a6  ...no.......m...
	defb 079h,07ah,00dh,001h,001h,00ah,00ch,00eh,00ch,0a6h,001h,00dh,0ffh,003h,001h,00bh	; b1b6  yz..............
	defb 052h,00fh,00ch,0a7h,00dh,001h,00dh,001h,001h,00bh,0d5h,0ffh,003h,00ch,05ch,005h	; b1c6  R.............\.
	defb 08ch,001h,001h,00bh,00bh,0b3h,0ffh,005h,00ch,091h,001h,009h,00ah,00bh,0b5h,054h	; b1d6  ...............T
	defb 00ch,00ch,080h,081h,084h,00ah,00bh,00ah,009h,00bh,053h,00ch,082h,083h,027h,0ffh	; b1e6  ..........S...'.
	defb 005h,00bh,00ah,04dh,04eh,0ffh,002h,001h	; b1f6  ...MN...

; ----------------------------------------------------------------------
; DATOS plano_hoyo_09: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (165 bytes fuente, 190 de salida)
;   0xb1fe..0xb2a3  (165 bytes)
DATA_plano_hoyo_09:
	defb 0a3h,000h,0ffh,006h,001h,00dh,0ffh,005h,001h,00dh,001h,001h,00dh,001h,00dh,0ffh	; b1fe  ................
	defb 003h,001h,00dh,095h,096h,00ch,00ch,066h,093h,001h,001h,00dh,065h,00ch,039h,038h	; b20e  .......f....e.98
	defb 0ffh,003h,00ch,084h,001h,001h,00ch,036h,037h,0ffh,004h,00ch,006h,001h,001h,087h	; b21e  .......67.......
	defb 0ffh,006h,00ch,007h,001h,00dh,001h,0abh,0ach,00dh,05bh,00ch,00ch,008h,0ffh,004h	; b22e  ..........[.....
	defb 001h,00dh,001h,09bh,00ch,00ch,007h,001h,00dh,0ffh,003h,001h,0dah,00eh,00ch,00ch	; b23e  ................
	defb 007h,0ffh,005h,001h,0d8h,00fh,00ch,00ch,008h,0ffh,004h,001h,00dh,020h,00ch,00ch	; b24e  ............. ..
	defb 004h,0ffh,004h,001h,00dh,0dah,0ffh,003h,00ch,02bh,001h,001h,00dh,001h,001h,020h	; b25e  .........+..... 
	defb 0ffh,003h,00ch,099h,0ffh,003h,001h,00dh,09bh,0ffh,004h,00ch,0ffh,004h,001h,0dah	; b26e  ................
	defb 0ffh,004h,00ch,08dh,00dh,0ffh,003h,001h,020h,0ffh,003h,00ch,07dh,00dh,0ffh,003h	; b27e  ........ ...}...
	defb 001h,028h,0a0h,0a1h,00ch,08dh,0ffh,005h,001h,029h,0a2h,0a3h,07dh,0ffh,007h,001h	; b28e  .(.......)..}...
	defb 0abh,0ach,0ffh,007h,001h	; b29e

; ----------------------------------------------------------------------
; DATOS plano_hoyo_10: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (166 bytes fuente, 190 de salida)
;   0xb2a3..0xb349  (166 bytes)
DATA_plano_hoyo_10:
	defb 0a4h,000h,001h,001h,00dh,0ffh,00bh,001h,00dh,0ffh,007h,001h,00dh,0ffh,003h,001h	; b2a3  ................
	defb 00dh,001h,00dh,0ffh,004h,001h,0d9h,03eh,0cdh,0c9h,0bbh,0ffh,004h,001h,00dh,0c6h	; b2b3  .......>........
	defb 0b4h,036h,037h,0c4h,0ffh,003h,001h,00dh,0d1h,00ah,0b5h,058h,044h,0d6h,00dh,001h	; b2c3  .67........XD...
	defb 001h,0c5h,00bh,00bh,00ah,0b4h,00ch,00dh,001h,00dh,001h,0c8h,00ah,00bh,00bh,0b3h	; b2d3  ................
	defb 08dh,001h,00dh,001h,00dh,0d2h,00bh,00bh,00ah,009h,009h,0bbh,00dh,001h,0d1h,00bh	; b2e3  ................
	defb 06dh,0ceh,0ffh,004h,00bh,0bbh,00dh,00bh,0c3h,00ch,00ch,04bh,04ch,009h,00ah,0d0h	; b2f3  m..........KL...
	defb 001h,00ah,0d5h,0ffh,004h,00ch,0bch,00ah,001h,001h,00bh,00bh,0cfh,054h,069h,06ah	; b303  .............Tij
	defb 00ch,0c0h,00dh,001h,00bh,00ah,009h,00bh,0cfh,054h,0bdh,00bh,001h,001h,00ah,00bh	; b313  .........T......
	defb 00bh,0cdh,0c9h,00bh,00bh,009h,00dh,001h,0c7h,009h,0c3h,034h,035h,0c0h,00ah,00ah	; b323  ...........45...
	defb 001h,00dh,0c8h,00bh,08eh,02dh,056h,00bh,00bh,0d6h,00dh,0ffh,004h,001h,0abh,07bh	; b333  .....-V........{
	defb 0d7h,0d6h,00dh,0ffh,00ch,001h	; b343

; ----------------------------------------------------------------------
; DATOS plano_hoyo_11: Sprite comprimido con el formato de 0xA8FB, llamado con
;   HL fijo desde 0x5DEC (0x5DEC), decodificado y verificado en Python (153
;   bytes fuente, 234 de salida)
;   0xb349..0xb3e2  (153 bytes)
DATA_plano_hoyo_11:
	defb 097h,000h,000h,003h,001h,001h,003h,001h,01eh,001h,001h,007h,001h,001h,00bh,019h	; b349  ................
	defb 0ffh,020h,001h,00eh,006h,0ffh,006h,001h,010h,001h,00ch,003h,003h,0ffh,003h,001h	; b359  . ..............
	defb 002h,0ffh,00ch,001h,004h,001h,005h,001h,002h,001h,001h,002h,001h,001h,005h,002h	; b369  ................
	defb 001h,002h,001h,003h,019h,010h,011h,0ffh,00fh,001h,002h,0ffh,003h,001h,002h,008h	; b379  ................
	defb 001h,00bh,00eh,007h,001h,006h,002h,001h,002h,001h,001h,005h,0ffh,005h,001h,002h	; b389  ................
	defb 0ffh,009h,001h,005h,001h,003h,001h,001h,00ch,0ffh,003h,001h,00bh,0ffh,008h,001h	; b399  ................
	defb 004h,0ffh,003h,001h,006h,003h,003h,001h,001h,003h,001h,001h,002h,002h,009h,003h	; b3a9  ................
	defb 008h,002h,002h,004h,002h,0ffh,005h,001h,002h,002h,0ffh,009h,001h,002h,001h,002h	; b3b9  ................
	defb 001h,003h,0ffh,005h,001h,002h,002h,004h,0ffh,006h,001h,009h,005h,002h,0ffh,004h	; b3c9  ................
	defb 001h,002h,0ffh,005h,001h,002h,0ffh,004h,001h	; b3d9  .........

; ----------------------------------------------------------------------
; DATOS plano_hoyo_12: Sprite comprimido con el formato de 0xA8FB, llamado con
;   HL fijo desde 0x5D84 (0x5D84), decodificado y verificado en Python (53
;   bytes fuente, 55 de salida)
;   0xb3e2..0xb417  (53 bytes)
DATA_plano_hoyo_12:
	defb 033h,000h,003h,005h,019h,006h,009h,00dh,006h,02dh,004h,001h,078h,003h,00bh,0ffh	; b3e2  3........-..x...
	defb 004h,001h,002h,001h,001h,004h,002h,001h,004h,001h,007h,001h,001h,008h,0ffh,003h	; b3f2  ................
	defb 001h,007h,03eh,007h,00ah,001h,001h,004h,002h,019h,037h,012h,028h,010h,0ffh,006h	; b402  ..>.......7.(...
	defb 001h,002h,001h,001h,002h	; b412

; ----------------------------------------------------------------------
; DATOS tabla_planos_de_hoyo2: 18 punteros de 16 bits (solo 2 direcciones
;   unicas), indexados por (0xE0B4)-1 desde 0x5D84 (0x5D93)
;   0xb417..0xb43b  (36 bytes)
DATA_tabla_planos_de_hoyo2:
	defw 0b43bh,0b472h,0b472h,0b43bh,0b43bh,0b43bh	; b417
	defw 0b43bh,0b472h,0b472h,0b43bh,0b43bh,0b472h	; b423
	defw 0b472h,0b472h,0b43bh,0b43bh,0b43bh,0b43bh	; b42f

; ----------------------------------------------------------------------
; DATOS plano_hoyo_13: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (55 bytes fuente, 100 de salida)
;   0xb43b..0xb472  (55 bytes)
DATA_plano_hoyo_13:
	defb 035h,000h,0ffh,016h,005h,00ch,00dh,00dh,000h,00eh,00fh,0ffh,003h,005h,001h,0ffh	; b43b  5...............
	defb 006h,000h,01ch,005h,005h,008h,0ffh,003h,000h,02ch,000h,000h,01dh,005h,005h,023h	; b44b  .........,.....#
	defb 0ffh,006h,000h,01eh,005h,005h,024h,0ffh,006h,000h,02fh,0ffh,003h,005h,011h,019h	; b45b  ......$.../.....
	defb 000h,019h,012h,013h,0ffh,016h,005h	; b46b

; ----------------------------------------------------------------------
; DATOS plano_hoyo_14: Sprite comprimido con el formato de 0xA8FB,
;   decodificado y verificado en Python (60 bytes fuente, 100 de salida)
;   0xb472..0xb4ae  (60 bytes)
DATA_plano_hoyo_14:
	defb 03ah,000h,0ffh,018h,005h,033h,000h,00eh,00fh,0ffh,006h,005h,0ffh,004h,000h,01ch	; b472  :....3..........
	defb 0ffh,004h,005h,027h,0ffh,004h,000h,01dh,005h,005h,033h,0ffh,006h,000h,01eh,005h	; b482  ...'......3.....
	defb 005h,0ffh,004h,000h,02ch,000h,000h,032h,005h,005h,035h,030h,0ffh,005h,000h,02fh	; b492  ....,..2..50.../
	defb 0ffh,003h,005h,017h,018h,01ah,01bh,016h,015h,0ffh,00ch,005h	; b4a2  ............

; ----------------------------------------------------------------------
; DATOS golfista_palos_9_y_mas: EL GOLFISTA para los palos por encima del 8:
;   35 piezas de sprite de 16x16 (1120 bytes), copiadas a VRAM 0x3B00 desde
;   0x4C13. Cada fotograma del swing lo componen hasta NUEVE de estas piezas
;   superpuestas, cada una con su color; las posiciones salen de
;   datos_del_golfista (0x5053) y el patron de indice*4+0x60
;   0xb4ae..0xb777  (713 bytes)
DATA_golfista_palos_9_y_mas:
	defb 0c7h,002h,0ffh,007h,000h,003h,007h,00fh,01fh,01fh,019h,018h,018h,00ch,0ffh,007h	; b4ae  ................
	defb 000h,0e0h,0f8h,0bch,08ch,09eh,02eh,007h,003h,016h,0ffh,005h,000h,008h,00eh,00ch	; b4be  ................
	defb 0dah,0ffh,001h,0ffh,0f9h,079h,07fh,03fh,01eh,008h,0ffh,00ah,000h,080h,000h,080h	; b4ce  .....y.?........
	defb 080h,0ffh,007h,000h,030h,020h,0ffh,003h,000h,080h,080h,0ffh,004h,0c0h,0ffh,011h	; b4de  ....0 ..........
	defb 000h,003h,007h,00fh,01dh,01dh,03eh,03eh,0ffh,004h,07fh,0ffh,004h,0ffh,0fch,0feh	; b4ee  ......>>........
	defb 0ffh,006h,0ffh,03fh,0ffh,004h,0c0h,0e0h,0f0h,0f0h,0fch,0feh,0feh,0ffh,001h,0ffh	; b4fe  ...?............
	defb 07fh,03fh,01fh,00fh,007h,007h,003h,001h,0ffh,00ah,000h,080h,0c0h,0e0h,0f0h,0f0h	; b50e  .?..............
	defb 0e0h,0ffh,004h,000h,0ffh,004h,0ffh,0ffh,003h,07fh,03fh,00fh,0ffh,003h,007h,00fh	; b51e  ..........?.....
	defb 0ffh,003h,01fh,0fch,0fch,0eeh,0eeh,0f7h,0f7h,0ffh,005h,0fbh,0ffh,005h,0f7h,07fh	; b52e  ................
	defb 0ffh,003h,0ffh,07fh,0ffh,00bh,000h,0dch,0feh,0ffh,001h,0ffh,0fch,0fch,0ffh,00bh	; b53e  ................
	defb 000h,080h,040h,020h,010h,008h,004h,002h,001h,0ffh,010h,000h,080h,040h,020h,010h	; b54e  ..@ .........@ .
	defb 01eh,01fh,01fh,00eh,000h,000h,030h,020h,0ffh,004h,000h,080h,0c0h,0e0h,0f0h,0f0h	; b55e  ......0 ........
	defb 070h,060h,040h,0ffh,011h,000h,001h,007h,00fh,018h,030h,020h,060h,040h,041h,007h	; b56e  p`@.......0 `@A.
	defb 087h,088h,010h,0f0h,0ffh,001h,0ffh,0fch,0fch,0f8h,0f9h,07fh,03fh,03fh,078h,0f0h	; b57e  ............??x.
	defb 0e0h,080h,000h,001h,00fh,07eh,0fch,00fh,01fh,03fh,03fh,07eh,07ch,0f0h,0f1h,0efh	; b58e  .....~...??~|...
	defb 05fh,01fh,0ffh,006h,000h,080h,080h,00eh,01fh,03fh,0ffh,001h,0ffh,0feh,0fch,0e0h	; b59e  _........?......
	defb 0ffh,006h,000h,001h,0ffh,003h,003h,001h,0ffh,00bh,000h,080h,080h,083h,09ch,0e0h	; b5ae  ................
	defb 0ffh,00eh,000h,001h,002h,004h,008h,013h,027h,04fh,09fh,01fh,019h,018h,018h,00ch	; b5be  ........'O......
	defb 000h,000h,0f0h,0f8h,078h,030h,000h,0e0h,0f8h,0bch,08ch,09eh,02eh,007h,003h,016h	; b5ce  ....x0..........
	defb 0ffh,005h,000h,018h,03ch,07eh,07fh,05fh,027h,07bh,0fbh,0f9h,0f1h,060h,0ffh,008h	; b5de  ....<~._'{...`..
	defb 000h,00dh,08fh,0cfh,0e7h,010h,018h,0e3h,0e1h,0ffh,00bh,000h,020h,020h,030h,070h	; b5ee  ............  0p
	defb 0f8h,0ffh,00ah,000h,003h,002h,080h,0c0h,0e0h,0f0h,01fh,01fh,0ffh,003h,03fh,0ffh	; b5fe  ..............?.
	defb 003h,07fh,0ffh,004h,0ffh,0ffh,004h,000h,0bfh,0bfh,0dfh,0efh,0ffh,004h,0ffh,0feh	; b60e  ................
	defb 0ffh,003h,0fch,0ffh,004h,000h,0c0h,0ffh,003h,0e0h,0c0h,0c0h,080h,0ffh,019h,000h	; b61e  ................
	defb 0ffh,003h,0ffh,0ffh,003h,07fh,03fh,01fh,00fh,0ffh,003h,007h,00fh,0ffh,003h,01fh	; b62e  ......?.........
	defb 0fch,0fch,0eeh,0eeh,0f7h,0f7h,0ffh,005h,0fbh,0ffh,005h,0f7h,000h,080h,0ffh,003h	; b63e  ................
	defb 0c0h,0ffh,003h,080h,0ffh,01ah,000h,07fh,0ffh,003h,0ffh,07fh,0ffh,00bh,000h,0deh	; b64e  ................
	defb 0efh,0f7h,0fch,0fch,0ffh,009h,000h,0ffh,004h,0ffh,07fh,03fh,01fh,007h,001h,000h	; b65e  ...........?....
	defb 001h,003h,000h,000h,003h,007h,0fch,0fch,0ffh,003h,0feh,0ffh,006h,0ffh,0feh,07eh	; b66e  ...............~
	defb 01ch,01ch,008h,078h,0feh,0ceh,08fh,09fh,073h,023h,011h,008h,0ffh,00ah,000h,0e0h	; b67e  ...x....s#......
	defb 0f0h,0f8h,0c0h,0e0h,0e0h,0ffh,007h,000h,0c0h,018h,038h,01ch,00eh,0ffh,01fh,000h	; b68e  ..........8.....
	defb 030h,020h,0ffh,004h,000h,080h,0e0h,0f0h,0e0h,0c0h,080h,0ffh,013h,000h,018h,03ch	; b69e  0 .............<
	defb 07ch,0fch,07ch,038h,0ffh,017h,000h,0e0h,018h,006h,001h,0ffh,00dh,000h,00ch,03eh	; b6ae  |.|8...........>
	defb 0fch,078h,030h,0ffh,00bh,000h,001h,003h,007h,00fh,00fh,01fh,03fh,03fh,0ffh,003h	; b6be  .x0.........??..
	defb 07fh,0ffh,004h,0ffh,0f8h,0fch,0feh,0ffh,003h,0ffh,0dfh,0efh,0f7h,0f9h,0ffh,003h	; b6ce  ................
	defb 0feh,0ffh,003h,0fch,0ffh,00fh,000h,001h,0ffh,00dh,000h,070h,0fch,0ffh,001h,0ffh	; b6de  ...........p....
	defb 0ffh,005h,000h,007h,00fh,00fh,01fh,03eh,078h,0fch,0feh,0f8h,070h,020h,0ffh,005h	; b6ee  .......>x...p ..
	defb 000h,010h,0b8h,0bch,0b8h,010h,010h,030h,030h,010h,0ffh,003h,000h,001h,08eh,001h	; b6fe  .......00.......
	defb 00fh,0ffh,005h,01fh,03fh,01fh,00fh,007h,003h,001h,018h,0fch,01eh,0ceh,0eeh,0f4h	; b70e  ....?...........
	defb 0f8h,0f8h,0fch,0fch,0f8h,0f8h,0e0h,0c0h,080h,000h,00ch,01ch,030h,0ffh,01dh,000h	; b71e  ............0...
	defb 080h,0c0h,0ffh,003h,0e0h,0c0h,080h,0ffh,019h,000h,03fh,01fh,00fh,01fh,01fh,0ffh	; b72e  ..........?.....
	defb 003h,03fh,0ffh,003h,07fh,0ffh,005h,0ffh,0f8h,0fch,0feh,0ffh,00ah,0ffh,0feh,0fch	; b73e  .?..............
	defb 0fch,080h,040h,040h,020h,020h,010h,010h,008h,008h,004h,004h,002h,002h,001h,0ffh	; b74e  ..@@  ..........
	defb 00eh,000h,030h,0f8h,0f0h,0c0h,080h,080h,0ffh,003h,040h,0ffh,003h,020h,0ffh,003h	; b75e  ..0.......@.. ..
	defb 010h,0ffh,003h,008h,01fh,01fh,0ffh,010h,000h	; b76e  .........

; ----------------------------------------------------------------------
; DATOS golfista_palo_8: EL GOLFISTA para el palo 8: 29 piezas de sprite de
;   16x16 (928 bytes). Ocho piezas por fotograma, posiciones en 0x50BC y
;   listas en 0x4FFF
;   0xb777..0xb9f0  (633 bytes)
DATA_golfista_palo_8:
	defb 077h,002h,0ffh,007h,000h,003h,007h,01eh,01eh,014h,010h,010h,008h,0ffh,008h,000h	; b777  w...............
	defb 0c0h,0f0h,0f0h,078h,0b8h,01ch,00ch,058h,0ffh,010h,000h,0f0h,0ffh,00dh,000h,0c0h	; b787  ...x...X........
	defb 080h,0ffh,00ah,000h,001h,001h,00bh,00fh,00fh,007h,00fh,0ffh,00ah,000h,080h,040h	; b797  ...............@
	defb 0e0h,030h,020h,0e0h,007h,00fh,01fh,01fh,03fh,03fh,0ffh,003h,07fh,0ffh,003h,0ffh	; b7a7  .0 .....??......
	defb 0ffh,004h,000h,0f8h,0fch,0fch,07eh,07eh,0bfh,0bfh,0ffh,003h,0e0h,0f0h,0f0h,0ffh	; b7b7  ......~~........
	defb 004h,000h,03ch,010h,0ffh,005h,000h,0f0h,0f0h,0f8h,078h,03ch,01ch,01eh,03eh,01ch	; b7c7  ..<.......x<..>.
	defb 0ffh,015h,000h,01fh,01fh,00fh,007h,003h,001h,000h,000h,001h,001h,003h,0ffh,005h	; b7d7  ................
	defb 000h,0feh,0f6h,0fah,0fbh,0ffh,003h,0fdh,0ffh,004h,0fah,007h,00fh,00fh,007h,0ffh	; b7e7  ................
	defb 00ch,000h,0feh,0ffh,001h,0ffh,0fch,0feh,0ffh,00ch,000h,040h,020h,010h,008h,004h	; b7f7  ...........@ ...
	defb 002h,001h,0ffh,010h,000h,080h,040h,038h,03ch,018h,0ffh,00ch,000h,01eh,03fh,0f7h	; b807  ......@8<.....?.
	defb 0f3h,0a5h,080h,080h,045h,0ffh,009h,000h,080h,080h,0c0h,0c0h,0e0h,0e0h,0c0h,0ffh	; b817  ....E...........
	defb 00fh,000h,031h,0ffh,007h,000h,010h,018h,0b4h,0feh,0e6h,064h,0feh,0fch,090h,0ffh	; b827  ..1........d....
	defb 003h,000h,003h,00fh,019h,010h,030h,020h,061h,043h,007h,08eh,088h,000h,0cfh,000h	; b837  ......0 aC......
	defb 003h,002h,0e0h,0e0h,0cch,0feh,07fh,0e7h,0c3h,083h,006h,01ch,070h,070h,0f0h,01eh	; b847  ............pp..
	defb 01fh,03eh,03ch,078h,071h,0e3h,0efh,08fh,060h,0ffh,008h,000h,030h,078h,0f8h,0f0h	; b857  .><xq...`...0x..
	defb 0c0h,0ffh,009h,000h,0ffh,003h,018h,00fh,0ffh,010h,000h,0f0h,007h,0ffh,00ah,000h	; b867  ................
	defb 0ffh,002h,0ffh,07fh,03fh,01fh,00fh,007h,007h,00fh,00fh,01fh,0ffh,005h,000h,0f0h	; b877  ....?...........
	defb 0b0h,0d8h,0d4h,0ffh,003h,0ech,0ffh,003h,0d8h,0c0h,0ffh,006h,000h,007h,00fh,00fh	; b887  ................
	defb 007h,0ffh,00bh,000h,006h,0f7h,0fbh,0fch,0feh,0ffh,00fh,000h,001h,007h,009h,010h	; b897  ................
	defb 023h,047h,09eh,01eh,014h,010h,010h,008h,0ffh,004h,000h,080h,0c0h,0c0h,000h,0c0h	; b8a7  #G..............
	defb 0f0h,0f0h,078h,0b8h,01ch,01ch,0b8h,0ffh,005h,000h,018h,038h,07ch,05eh,06fh,0f7h	; b8b7  ..x........8|^o.
	defb 0f7h,0c3h,003h,001h,001h,0ffh,005h,000h,008h,00ch,05ah,07fh,073h,0f2h,0ffh,001h	; b8c7  ..........Z.s...
	defb 0ffh,0deh,0c8h,0c0h,080h,0ffh,004h,000h,002h,00eh,01fh,01fh,03fh,03fh,07fh,07fh	; b8d7  ............??..
	defb 0ffh,004h,0ffh,000h,003h,002h,000h,008h,00ch,00eh,01fh,07fh,0bfh,0dfh,0feh,0f8h	; b8e7  ................
	defb 0ffh,003h,0f0h,03fh,03fh,01fh,00fh,003h,000h,000h,001h,000h,000h,003h,001h,0ffh	; b8f7  ...??...........
	defb 004h,000h,0fch,0fch,0feh,0feh,0ffh,003h,0ffh,0feh,03ch,018h,090h,0c0h,000h,0f0h	; b907  ..........<.....
	defb 078h,000h,003h,007h,004h,002h,003h,001h,0ffh,00ah,000h,0c0h,0e0h,064h,037h,0f9h	; b917  x............d7.
	defb 00eh,086h,0ffh,009h,000h,001h,001h,00bh,00fh,00fh,007h,00fh,003h,001h,0ffh,003h	; b927  ................
	defb 000h,001h,0ffh,004h,000h,080h,040h,0e0h,030h,020h,0e0h,0c0h,000h,060h,070h,0f0h	; b937  ......@.0 ...`p.
	defb 0e0h,0ffh,003h,000h,001h,007h,00fh,01fh,01fh,03fh,03fh,0ffh,003h,07fh,0ffh,003h	; b947  .........??.....
	defb 0ffh,0ffh,003h,000h,0e0h,0f8h,0fch,0ffh,002h,0ffh,0dfh,0e6h,0ffh,003h,0f8h,0ffh	; b957  ................
	defb 003h,0f0h,0ffh,005h,000h,0c0h,030h,00ch,003h,0ffh,00eh,000h,060h,0f0h,0e0h,040h	; b967  ......0.....`..@
	defb 0ffh,00eh,000h,006h,00fh,00fh,01fh,01ch,03ch,03eh,01eh,00ch,008h,0ffh,007h,000h	; b977  ........<>......
	defb 030h,078h,01ch,008h,008h,018h,018h,0ffh,005h,000h,00fh,0c0h,000h,001h,0ffh,004h	; b987  0x..............
	defb 007h,00fh,00fh,007h,003h,001h,000h,018h,0fch,00ch,000h,000h,0e0h,0f8h,0f8h,0fch	; b997  ................
	defb 0fch,0f8h,0f8h,0e0h,0c0h,0c0h,060h,0c0h,0ffh,01eh,000h,002h,007h,00fh,01fh,00fh	; b9a7  ......`.........
	defb 00fh,01fh,03fh,03fh,07fh,07fh,0ffh,005h,0ffh,000h,080h,0c0h,0f0h,0f8h,0fch,0feh	; b9b7  ..??............
	defb 0ffh,004h,0ffh,0feh,0fch,0f8h,0f0h,0f0h,040h,040h,020h,020h,010h,010h,008h,008h	; b9c7  ........@@  ....
	defb 004h,005h,003h,0ffh,00dh,000h,080h,0c0h,080h,0ffh,005h,000h,0ffh,003h,080h,0ffh	; b9d7  ................
	defb 003h,040h,0ffh,004h,020h,078h,0ffh,015h,000h	; b9e7  .@.. x...

; ----------------------------------------------------------------------
; DATOS golfista_palos_1_a_7: EL GOLFISTA para los palos del 1 al 7, el mas
;   lejano de la camara: 22 piezas de sprite de 16x16 (704 bytes). Seis piezas
;   por fotograma, posiciones en 0x5113 y listas en 0x502F
;   0xb9f0..0xbb86  (406 bytes)
DATA_golfista_palos_1_a_7:
	defb 094h,001h,0ffh,00ch,000h,001h,002h,002h,003h,0ffh,00bh,000h,0f0h,0d8h,098h,008h	; b9f0  ................
	defb 028h,000h,001h,001h,0ffh,007h,000h,001h,0ffh,005h,000h,020h,060h,0f0h,0d0h,0f0h	; ba00  (.......... `...
	defb 040h,0ffh,004h,000h,0c0h,0e0h,060h,030h,038h,030h,0ffh,010h,000h,010h,008h,008h	; ba10  @.....`080......
	defb 004h,007h,003h,0ffh,00ah,000h,0ffh,001h,0ffh,0fdh,07eh,03eh,00eh,01eh,03eh,03eh	; ba20  ..........~>..>>
	defb 0ffh,009h,000h,0ffh,006h,080h,0ffh,00ah,000h,03fh,03fh,0ffh,00dh,000h,0c0h,0e0h	; ba30  .........??.....
	defb 080h,0ffh,014h,000h,00fh,01fh,03fh,03bh,07dh,07dh,0feh,0ffh,002h,0ffh,0ffh,008h	; ba40  ......?;}}......
	defb 000h,080h,0ffh,004h,0c0h,0ffh,00ah,000h,00fh,017h,023h,042h,04ch,088h,030h,033h	; ba50  ..........#BL.03
	defb 0ffh,001h,0ffh,0ffh,008h,000h,080h,0c0h,0e0h,060h,040h,080h,0ffh,007h,000h,001h	; ba60  .........`@.....
	defb 001h,000h,000h,008h,01ch,03dh,033h,077h,0cfh,0cch,0ffh,004h,000h,020h,060h,0f0h	; ba70  .....=3w..... `.
	defb 0d0h,0f0h,040h,000h,000h,080h,080h,0ffh,016h,000h,030h,030h,01ch,003h,0ffh,00ah	; ba80  ..@.......00....
	defb 000h,001h,002h,004h,009h,002h,002h,003h,0ffh,007h,000h,070h,0b0h,000h,000h,0f0h	; ba90  ...........p....
	defb 0d8h,098h,008h,028h,0ffh,00eh,000h,001h,011h,03bh,07bh,07dh,07eh,0ffh,003h,0ffh	; baa0  ...(.....;{}~...
	defb 0ffh,008h,000h,080h,0c0h,0e0h,0e0h,0c0h,080h,0ffh,006h,000h,031h,079h,01ch,06eh	; bab0  ............1y.n
	defb 0eeh,0c4h,0ffh,009h,000h,020h,060h,0f0h,0d0h,0f0h,040h,0ffh,007h,000h,0ffh,001h	; bac0  ..... `...@.....
	defb 0ffh,0fdh,07eh,03eh,00eh,01eh,03eh,03eh,0ffh,009h,000h,080h,080h,0c0h,0c0h,080h	; bad0  ..~>..>>........
	defb 0ffh,012h,000h,03fh,03fh,0ffh,00ch,000h,080h,0c0h,000h,080h,0ffh,006h,000h,0feh	; bae0  ...??...........
	defb 0ffh,001h,0ffh,07fh,03fh,00fh,01fh,007h,01ah,002h,008h,0ffh,008h,000h,0ffh,003h	; baf0  ....?...........
	defb 080h,0ffh,00bh,000h,018h,025h,03dh,016h,0ffh,00eh,000h,080h,0ffh,014h,000h,00fh	; bb00  .....%=.........
	defb 01fh,03fh,07bh,07dh,0fch,0ffh,003h,0ffh,0ffh,008h,000h,080h,0c0h,0e0h,0c0h,080h	; bb10  .?{}............
	defb 0ffh,005h,000h,001h,003h,005h,004h,006h,0ffh,00bh,000h,0e0h,0b0h,030h,010h,050h	; bb20  .............0.P
	defb 0ffh,006h,000h,022h,01bh,007h,0ffh,004h,000h,002h,003h,001h,001h,0ffh,00bh,000h	; bb30  ..."............
	defb 040h,0c0h,0e0h,0a0h,0e0h,080h,000h,000h,060h,0e0h,0c0h,0ffh,00bh,000h,001h,008h	; bb40  @.......`.......
	defb 0ffh,004h,001h,0ffh,008h,000h,038h,0d8h,000h,0e0h,0f0h,0f8h,0f8h,0e0h,0e0h,0ffh	; bb50  ......8.........
	defb 005h,000h,008h,01eh,03fh,01fh,03fh,07fh,07fh,0ffh,003h,0ffh,0feh,0ffh,008h,000h	; bb60  ....?.?.........
	defb 0c0h,0e0h,0e0h,0c0h,080h,0ffh,004h,000h,006h,036h,070h,0e2h,0f2h,060h,0ffh,00fh	; bb70  .........6p..`..
	defb 000h,018h,010h,0ffh,008h,000h	; bb80

; ----------------------------------------------------------------------
; DATOS bloque_sonido_01: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbb86..0xbb93  (13 bytes)
DATA_bloque_sonido_01:
	defb 0fah,00ch,0ffh,013h,006h,008h,013h,006h,008h,013h,014h,014h,0ffh	; bb86  .............

; ----------------------------------------------------------------------
; DATOS bloque_sonido_02: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbb93..0xbbaf  (28 bytes)
DATA_bloque_sonido_02:
	defb 0f9h,011h,0ffh,028h,018h,018h,028h,018h,018h,029h,00ch,00ch,028h,018h,018h,029h	; bb93  ...(..(..)..(..)
	defb 00ch,00ch,028h,018h,018h,028h,018h,018h,028h,030h,030h,0ffh	; bba3  ..(..(..(00.

; ----------------------------------------------------------------------
; DATOS bloque_sonido_03: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbbaf..0xbbd2  (35 bytes)
DATA_bloque_sonido_03:
	defb 0f9h,011h,0ffh,02bh,018h,018h,02bh,018h,018h,02dh,00ch,00ch,02bh,018h,018h,02dh	; bbaf  ...+..+..-..+..-
	defb 00ch,00ch,030h,018h,018h,030h,018h,018h,030h,030h,030h,0ffh,0fah,00ch,0ffh,037h	; bbbf  ..0..0..000....7
	defb 002h,002h,0ffh	; bbcf

; ----------------------------------------------------------------------
; DATOS bloque_sonido_04: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbbd2..0xbbec  (26 bytes)
DATA_bloque_sonido_04:
	defb 0f9h,011h,0ffh,024h,006h,006h,028h,006h,006h,02bh,006h,006h,030h,006h,006h,0ffh	; bbd2  ...$..(..+..0...
	defb 0f9h,011h,0ffh,040h,003h,003h,040h,008h,008h,0ffh	; bbe2  ...@..@...

; ----------------------------------------------------------------------
; DATOS bloque_sonido_05: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbbec..0xbbfc  (16 bytes)
DATA_bloque_sonido_05:
	defb 0f9h,011h,0ffh,03ah,006h,004h,03ah,003h,002h,03ah,003h,002h,03ah,00ch,00ch,0ffh	; bbec  ...:..:..:..:...

; ----------------------------------------------------------------------
; DATOS bloque_sonido_06: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbbfc..0xbc09  (13 bytes)
DATA_bloque_sonido_06:
	defb 0f9h,011h,0ffh,020h,010h,003h,020h,00eh,003h,020h,00ah,003h,0ffh	; bbfc  ... .. .. ...

; ----------------------------------------------------------------------
; DATOS bloque_sonido_07: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbc09..0xbc13  (10 bytes)
DATA_bloque_sonido_07:
	defb 0fah,00ch,0ffh,0f3h,050h,0ffh,024h,003h,003h,0ffh	; bc09  ....P.$...

; ----------------------------------------------------------------------
; DATOS bloque_sonido_08: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbc13..0xbc29  (22 bytes)
DATA_bloque_sonido_08:
	defb 0f9h,011h,0ffh,0f6h,001h,0ffh,0f5h,0ffh,0ffh,00ah,004h,003h,0f5h,0ffh,0ffh,005h	; bc13  ................
	defb 020h,020h,0f6h,008h,0ffh,0ffh	; bc23

; ----------------------------------------------------------------------
; DATOS bloque_sonido_09: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbc29..0xbc78  (79 bytes)
DATA_bloque_sonido_09:
	defb 0f9h,011h,0ffh,02bh,00ch,00ch,028h,00ch,00ch,02bh,00ch,00ch,028h,00ch,00ch,02dh	; bc29  ...+..(..+..(..-
	defb 00ch,00ch,02fh,006h,006h,02bh,01eh,01eh,030h,00ch,00ch,02fh,00ch,00ch,02dh,00ch	; bc39  ../..+..0../..-.
	defb 00ch,02bh,00ch,00ch,029h,018h,018h,028h,018h,018h,02bh,00ch,00ch,028h,00ch,00ch	; bc49  .+..)..(..+..(..
	defb 02bh,00ch,00ch,028h,00ch,00ch,02dh,00ch,00ch,02fh,006h,006h,02bh,01eh,01eh,02dh	; bc59  +..(..-../..+..-
	defb 00ch,00ch,02fh,00ch,00ch,030h,00ch,00ch,032h,00ch,00ch,030h,018h,018h,0ffh	; bc69  ../..0..2..0...

; ----------------------------------------------------------------------
; DATOS bloque_sonido_10: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbc78..0xbcd3  (91 bytes)
DATA_bloque_sonido_10:
	defb 0f9h,011h,0ffh,018h,00ch,00ch,013h,00ch,00ch,018h,00ch,00ch,013h,00ch,00ch,01ah	; bc78  ................
	defb 00ch,00ch,015h,00ch,00ch,01ah,00ch,00ch,015h,00ch,00ch,01dh,00ch,00ch,018h,00ch	; bc88  ................
	defb 00ch,01ch,00ch,00ch,017h,00ch,00ch,01ah,00ch,00ch,015h,00ch,00ch,018h,00ch,00ch	; bc98  ................
	defb 013h,00ch,00ch,018h,00ch,00ch,013h,00ch,00ch,018h,00ch,00ch,013h,00ch,00ch,01ah	; bca8  ................
	defb 00ch,00ch,015h,00ch,00ch,01ah,00ch,00ch,015h,00ch,00ch,011h,00ch,00ch,011h,00ch	; bcb8  ................
	defb 00ch,013h,00ch,00ch,013h,00ch,00ch,018h,018h,018h,0ffh	; bcc8  ...........

; ----------------------------------------------------------------------
; DATOS bloque_sonido_11: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbcd3..0xbce6  (19 bytes)
DATA_bloque_sonido_11:
	defb 0f9h,011h,0ffh,030h,010h,010h,030h,008h,008h,030h,010h,010h,030h,008h,008h,030h	; bcd3  ...0..0..0..0..0
	defb 030h,030h,0ffh	; bce3

; ----------------------------------------------------------------------
; DATOS bloque_sonido_12: Bloque de datos de sonido/animacion, direccion
;   confirmada por codigo (0xBD03); formato bytecode no descifrado, limite
;   tomado de la siguiente direccion de la lista
;   0xbce6..0xbd03  (29 bytes)
DATA_bloque_sonido_12:
	defb 0f9h,011h,0ffh,03ch,010h,010h,03ch,008h,008h,03ch,010h,010h,03ch,008h,008h,03ch	; bce6  ...<..<..<..<..<
	defb 030h,030h,0ffh,0fah,00ch,0ffh,0f3h,0feh,0ffh,020h,0ffh,0ffh,0ffh	; bcf6  00....... ...

; ======================================================================
; CODIGO 0xbd03..0xbfa4  (673 bytes)
; ======================================================================


registra_un_bloque:		; Guarda el puntero del bloque en la estructura del canal y lo enciende
	call estructura_del_canal		;bd03   ; Guarda DE como puntero del bloque en la estructura del canal (IX) y lo activa
	ld (hl),e			;bd06   ; el puntero al bloque, byte bajo
	inc hl			;bd07
	ld (hl),d			;bd08   ; y byte alto
	inc hl			;bd09
	ld (hl),001h		;bd0a   ; y el canal queda encendido
	ret			;bd0c
estructura_del_canal:		; De su numero saca la direccion: el indice partido por ocho sobre la base 0xF401
	push bc			;bd0d   ; Calcula la direccion de la estructura del canal (b>>3, base 0xF401)
	push de			;bd0e
	ld hl,0f401h		;bd0f   ; la base de las estructuras de canal, en la RAM de la BIOS
	ld a,b			;bd12
	rrca			;bd13   ; el numero de canal entre ocho
	rrca			;bd14
	rrca			;bd15
	ld e,a			;bd16
	ld d,000h		;bd17
	add hl,de			;bd19   ; sumado a la base
	push hl			;bd1a
	inc hl			;bd1b   ; dos bytes mas alla arranca el bloque
	inc hl			;bd1c
	ex de,hl			;bd1d
	ld hl,0bfc2h		;bd1e   ; Copia 30 bytes desde tabla_bfc2 para inicializar el canal
	ld bc,0001eh		;bd21   ; Copia el bloque completo de 30 bytes de una sola vez (ldir)
	ldir		;bd24
	pop hl			;bd26
	pop de			;bd27
	pop bc			;bd28
	ret			;bd29
para_el_canal:		; Apaga el canal que le digan
	ld b,000h		;bd2a   ; el canal 0
	call estructura_del_canal		;bd2c
	inc b			;bd2f   ; el 1
	call estructura_del_canal		;bd30
	inc b			;bd33   ; y el 2
	call estructura_del_canal		;bd34
	ld a,007h		;bd37
	call 00096h		;bd39   ; BIOS RDPSG - Reads value from PSG-register | el registro 7 es el mezclador
	and 0c0h		;bd3c   ; se conservan los dos bits altos
	or 038h		;bd3e   ; y se apagan los tres tonos y los tres ruidos
	ld e,a			;bd40
	ld a,007h		;bd41
	call 00093h		;bd43   ; BIOS WRTPSG - Writes data to PSG-register
	xor a			;bd46
	ld (0f403h),a		;bd47   ; las tres banderas de canal ocupado, a cero
	ld (0f423h),a		;bd4a
	ld (0f443h),a		;bd4d
	ld b,002h		;bd50   ; dos canales
	ld ix,0f401h		;bd52   ; desde la base
recorre_dos:		; Dos canales seguidos, con paso de 0x20
	call calla_este_canal		;bd56
	ld de,00020h		;bd59   ; con paso de 0x20: eso mide una estructura de canal
	add ix,de		;bd5c
	djnz recorre_dos		;bd5e
calla_este_canal:		; Deja el canal en silencio
	xor a			;bd60
	ld (ix+012h),a		;bd61   ; vibrato
	ld (ix+013h),a		;bd64   ; y ruido, los dos a cero
escribe_el_registro:		; Manda el valor al registro del PSG que toque
	ld e,a			;bd67
	ld a,008h		;bd68   ; el registro 8 es el volumen del canal A
	add a,b			;bd6a   ; mas el numero de canal
	jp 00093h		;bd6b   ; BIOS WRTPSG - Writes data to PSG-register
cierra_el_canal:		; Lo apaga del todo
	pop hl			;bd6e
	xor a			;bd6f
	ld (ix+002h),a		;bd70   ; y el canal se marca como libre
	jr calla_este_canal		;bd73
arranca_el_reproductor:		; Prepara los canales desde la base 0xF401
	ld b,002h		;bd75
	ld ix,0f401h		;bd77   ; la base de la primera estructura
recorre_los_canales:		; Los dieciseis, uno por bit de (0xF400), con paso de 0x20
	call canal_un_paso		;bd7b   ; Recorre los 16 canales de sonido/animacion (paso de 0x20 en IX), uno por bit de (0xF400)
	ld de,00020h		;bd7e   ; otra vez el paso de 0x20
	add ix,de		;bd81
	ld a,(0f400h)		;bd83   ; (0xF400) lleva que canal toca
	ld b,a			;bd86
	djnz recorre_los_canales		;bd87
canal_un_paso:		; El paso del canal en este cuadro: lleva la duracion de la nota
	ld a,b			;bd89   ; Reproductor principal del canal: gestiona la duracion de la nota actual
	ld (0f400h),a		;bd8a
	ld a,(ix+002h)		;bd8d   ; el canal apagado no suena
	and a			;bd90
	ret z			;bd91
	dec (ix+00eh)		;bd92   ; un cuadro menos de la nota
	ret nz			;bd95   ; y hasta que no se agote, nada
	ld a,(ix+00dh)		;bd96
	ld (ix+00eh),a		;bd99   ; la duracion se recarga
	ld a,(ix+012h)		;bd9c   ; Aplica vibrato/portamento si estan activos (ix+0x12/0x13)
	and a			;bd9f
	call nz,lee_el_periodo		;bda0   ; con vibrato, se recalcula el periodo
	ld a,(ix+013h)		;bda3
	and a			;bda6
	call nz,lee_el_ruido		;bda7   ; y con ruido, el generador
	dec (ix+007h)		;bdaa   ; Decrementa el contador de repeticion; si llega a cero, va a leer el siguiente comando (0xBE74)
	jp z,lee_el_bytecode		;bdad   ; al llegar a cero toca leer la orden siguiente
	ld a,(ix+006h)		;bdb0
	and a			;bdb3
	ret z			;bdb4
	dec a			;bdb5
	ld (ix+006h),a		;bdb6   ; uno menos
	jr z,calla_este_canal		;bdb9   ; y al agotarse, el canal se calla
	jp mira_si_esta_callado		;bdbb
lee_el_periodo:		; Saca de la tabla el periodo de la nota
	ld a,b			;bdbe
	add a,a			;bdbf   ; el numero de canal por dos: los periodos van en pareja
	ld h,a			;bdc0
	call 00096h		;bdc1   ; BIOS RDPSG - Reads value from PSG-register | el byte bajo del periodo que hay puesto
	ld l,a			;bdc4
	ld a,h			;bdc5
	inc a			;bdc6
	call 00096h		;bdc7   ; BIOS RDPSG - Reads value from PSG-register | y el alto
	ld h,a			;bdca
	ld d,000h		;bdcb
	ld a,(ix+012h)		;bdcd
	and a			;bdd0   ; el signo del vibrato
	jp p,suma_el_indice		;bdd1
	neg		;bdd4   ; con el negativo, se resta
	ld e,a			;bdd6
	and a			;bdd7
	sbc hl,de		;bdd8
	jr devuelve_el_periodo		;bdda
suma_el_indice:		; Entra en la tabla con el desplazamiento calculado
	ld e,a			;bddc
	add hl,de			;bddd   ; y con el positivo, se suma
devuelve_el_periodo:		; Deja la pareja lista
	ret c			;bdde   ; si se desborda, se deja como estaba
	ex de,hl			;bddf
	ld a,b			;bde0
	add a,a			;bde1
dos_registros_seguidos:		; Escribe el registro y el siguiente: el tono va en pareja
	call 00093h		;bde2   ; BIOS WRTPSG - Writes data to PSG-register | el byte bajo del periodo
	inc a			;bde5   ; y el registro siguiente, el alto
	ld e,d			;bde6
	jp 00093h		;bde7   ; BIOS WRTPSG - Writes data to PSG-register
lee_el_ruido:		; Trae el registro 6, que es el generador de ruido
	ld a,006h		;bdea   ; el registro 6 es el periodo del ruido
	call 00096h		;bdec   ; BIOS RDPSG - Reads value from PSG-register
	and a			;bdef
	jr z,mantiene_el_ruido		;bdf0   ; a cero
	cp 01fh		;bdf2   ; o a su tope, 0x1F
	jr nz,sube_el_ruido		;bdf4
mantiene_el_ruido:		; Lo deja como estaba
	ld e,a			;bdf6
	ld a,(ix+013h)		;bdf7
	neg		;bdfa   ; el incremento cambia de signo: el ruido rebota entre los dos extremos
	ld (ix+013h),a		;bdfc
	ld a,e			;bdff
sube_el_ruido:		; Le suma su incremento sin pasar de 0x20
	add a,(ix+013h)		;be00   ; mas el incremento
	cp 020h		;be03   ; sin pasar de 0x20
	jr c,escribe_el_ruido		;be05
	ld a,01fh		;be07
escribe_el_ruido:		; Y lo devuelve al registro 6
	ld e,a			;be09
	ld a,006h		;be0a   ; y de vuelta al registro 6
	jp 00093h		;be0c   ; BIOS WRTPSG - Writes data to PSG-register
mira_si_esta_callado:		; Con el volumen a 0x10 el canal esta mudo y no hay nada que hacer
	ld a,(ix+00bh)		;be0f   ; Si el canal ya esta silenciado (ix+0xb=0x10) no hace nada
	cp 010h		;be12   ; 0x10 es el silencio
	ret z			;be14
	ld e,000h		;be15
	ld h,e			;be17
	ld l,(ix+006h)		;be18   ; el paso dentro del bloque
	add hl,hl			;be1b   ; Calcula la direccion base del bloque de sonido a partir de (ix+5)/(ix+6) (*16)
	add hl,hl			;be1c
	add hl,hl			;be1d
	add hl,hl			;be1e
	ld d,(ix+005h)		;be1f
	xor a			;be22
	ld b,008h		;be23   ; ocho bits
baja_un_bit:		; Desplazamiento con signo, guardando el resto
	push hl			;be25   ; Division/desplazamiento con signo, ajusta el resto en la pila
	srl d		;be26   ; el divisor se parte por dos
	rr e		;be28
	and a			;be2a
	sbc hl,de		;be2b   ; y se resta si cabe
	ccf			;be2d
	jr nc,recoge_el_bit		;be2e
	ex (sp),hl			;be30
recoge_el_bit:		; Toma un bit mas del flujo del canal
	rla			;be31   ; Recoge un bit mas del flujo de bytecode del canal
	pop hl			;be32
	djnz baja_un_bit		;be33
	ld c,a			;be35
	ld a,010h		;be36   ; 0x10 menos el cociente: el volumen va al reves
	sub c			;be38
guarda_el_volumen:		; Deja el volumen; si es silencio, para aqui
	ld (ix+00bh),a		;be39   ; Guarda el volumen del canal; si es silencio (0x10) no hace nada
	cp 010h		;be3c   ; el silencio se queda aqui
	ret z			;be3e
	srl a		;be3f   ; entre dos
	push af			;be41
	ld e,a			;be42
	ld d,000h		;be43
	ld l,(ix+009h)		;be45   ; Calcula la direccion de la forma de onda a partir del puntero del canal
	ld h,(ix+00ah)		;be48
	add hl,de			;be4b   ; mas el desplazamiento
	ld a,(0f400h)		;be4c
	ld b,a			;be4f
	pop af			;be50
	ld a,(hl)			;be51
	jr c,ocho_sub_elementos		;be52
	rrca			;be54
	rrca			;be55
	rrca			;be56
	rrca			;be57
ocho_sub_elementos:		; Prepara la lectura de los ocho campos del canal
	and 00fh		;be58   ; Prepara la lectura de 8 sub-elementos del canal (IX+8 en adelante)
	inc a			;be5a
	ld e,a			;be5b
	ld d,(ix+008h)		;be5c
	xor a			;be5f
	ld c,008h		;be60
monta_el_nibble:		; Va montando el nibble bit a bit
	add a,a			;be62
	rl e		;be63
	jr nc,cierra_el_nibble		;be65
	add a,d			;be67
cierra_el_nibble:		; Al agotar la cuenta, lo reordena y vuelve al reproductor
	dec c			;be68   ; Cuando el contador llega a cero, reordena el nibble y salta al reproductor principal
	jr nz,monta_el_nibble		;be69
	rrca			;be6b
	rrca			;be6c
	rrca			;be6d
	rrca			;be6e
	and 00fh		;be6f
	jp escribe_el_registro		;be71
lee_el_bytecode:		; Trae el byte actual del guion del canal
	call avanza_el_guion		;be74   ; Lee el byte actual del bytecode del canal (0xBF84)
	cp 0e0h		;be77
	jr c,compara_y_sigue		;be79
	cpl			;be7b
	add a,a			;be7c
	push de			;be7d
	ld e,a			;be7e
	ld d,000h		;be7f
	ld hl,0bfa4h		;be81
	add hl,de			;be84
	pop de			;be85
	push hl			;be86
	ld hl,lee_el_bytecode		;be87   ; Si es un comando (>=0xE0), salta a la rutina de la tabla de despacho (0xBFA4) -el JP (HL) real-
	ex (sp),hl			;be8a
	ld a,(hl)			;be8b
	inc hl			;be8c
	ld h,(hl)			;be8d
	ld l,a			;be8e
	jp (hl)			;be8f
intercambia_de:		; Cambia D y E con el juego de registros alterno
	ex af,af'			;be90   ; Intercambia D y E con el juego de registros alterno
	ld a,d			;be91
	ld d,e			;be92
	ld e,a			;be93
	ex af,af'			;be94
	ld (ix+007h),d		;be95   ; Guarda el resultado en la estructura del canal (IX+5/6/7)
	ld d,(ix+006h)		;be98
	ld (ix+005h),e		;be9b
	ld (ix+006h),e		;be9e
	inc e			;bea1
	dec e			;bea2
	ret			;bea3
compara_y_sigue:		; Si coinciden, vuelve al reproductor principal
	call intercambia_de		;bea4   ; Compara con 0xBE90; si son iguales, va al reproductor principal (0xBD60)
	jp z,calla_este_canal		;bea7
	push de			;beaa
	ld d,a			;beab
	ld a,(ix+014h)		;beac
	add a,d			;beaf
	ld c,000h		;beb0
recorta_a_doce:		; Nada por encima de doce
	cp 00ch		;beb2
	jr c,entra_en_la_tabla_de_ordenes		;beb4
	sub 00ch		;beb6
	inc c			;beb8
	jr recorta_a_doce		;beb9
entra_en_la_tabla_de_ordenes:		; Los doce punteros de 0xBFD5, indexados por el doble de A
	add a,a			;bebb   ; Indexa tabla_bfd5 (12 punteros) con el doble de A; si C no es cero, continua en otra rama
	ld e,a			;bebc
	ld d,000h		;bebd
	ld hl,0bfd5h		;bebf
	add hl,de			;bec2
	ld e,(hl)			;bec3
	inc hl			;bec4
	ld d,(hl)			;bec5
	ld a,c			;bec6   ; Si C es cero, usa el puntero calculado tal cual
	and a			;bec7
	jr z,dobla_el_indice		;bec8
baja_la_pareja:		; Desplaza DE un bit a la derecha
	srl d		;beca
	rr e		;becc
	dec a			;bece
	jr nz,baja_la_pareja		;becf
dobla_el_indice:		; Dobla B para entrar en la tabla
	ld a,b			;bed1
	add a,b			;bed2
	call dos_registros_seguidos		;bed3
	pop de			;bed6
mira_el_parametro:		; Con el parametro a 0x10, el canal esta mudo
	ld a,(ix+00ch)		;bed7
	cp 010h		;beda
	jr c,prepara_el_registro		;bedc
	xor a			;bede
	jp guarda_el_volumen		;bedf
prepara_el_registro:		; Deja el valor listo para el PSG
	ld c,a			;bee2
	inc d			;bee3
	dec d			;bee4
	ret nz			;bee5
	ld a,010h		;bee6
	call escribe_el_registro		;bee8
	ld e,c			;beeb
	ld a,00dh		;beec
	jp 00093h		;beee   ; BIOS WRTPSG - Writes data to PSG-register
siguiente_orden:		; Lee la orden siguiente del guion
	pop hl			;bef1
	call avanza_el_guion		;bef2
	call intercambia_de		;bef5
	jp z,calla_este_canal		;bef8
	ld e,a			;befb
	ld a,006h		;befc
	call 00093h		;befe   ; BIOS WRTPSG - Writes data to PSG-register
	jr mira_el_parametro		;bf01
sube_el_contador_del_canal:		; Incrementa el contador de repeticiones
	inc (ix+011h)		;bf03
	ld a,(ix+011h)		;bf06
	cp e			;bf09
	ret z			;bf0a
lee_el_puntero_guardado:		; Trae el puntero de vuelta del canal
	ld e,(ix+00fh)		;bf0b
	ld d,(ix+010h)		;bf0e
guarda_el_puntero:		; Y lo deja como puntero activo
	ld (ix+003h),e		;bf11
	ld (ix+004h),d		;bf14
sin_hacer_nada:		; La orden que no hace nada
	ret			;bf17
rebobina_el_canal:		; Devuelve el puntero de reproduccion a su valor de partida: el bucle de la pista
	ld (ix+011h),000h		;bf18   ; Reinicia el puntero de reproduccion del canal (IX+3/4) a su valor de partida (IX+0xF/0x10)
	ld e,(ix+003h)		;bf1c
	ld d,(ix+004h)		;bf1f
	ld (ix+00fh),e		;bf22
	ld (ix+010h),d		;bf25
	ret			;bf28
nibble_del_parametro:		; Se queda con los cuatro bits bajos
	ld a,e			;bf29
	and 00fh		;bf2a
	ld (ix+008h),a		;bf2c
	ret			;bf2f
calla_y_avanza:		; Pone el volumen a silencio y pasa a la orden siguiente
	ld a,010h		;bf30
	ld (ix+00bh),a		;bf32
	ld d,e			;bf35
	call escribe_el_registro		;bf36
	ld e,d			;bf39
	ld a,00dh		;bf3a
	call 00093h		;bf3c   ; BIOS WRTPSG - Writes data to PSG-register
	call avanza_el_guion		;bf3f
	ld a,00bh		;bf42
	jp dos_registros_seguidos		;bf44
guarda_el_parametro:		; Deja E como parametro del canal
	ld (ix+00ch),e		;bf47   ; Guarda E como parametro del canal de sonido
	bit 4,e		;bf4a
	jr z,calla_y_avanza		;bf4c
	ld a,e			;bf4e
	and 00fh		;bf4f
	add a,a			;bf51   ; Si el nibble bajo tiene un tono especial, calcula su direccion base (0xBFED+nibble*8)
	add a,a			;bf52
	add a,a			;bf53
	ld e,a			;bf54
	ld d,000h		;bf55
	ld hl,0bfedh		;bf57
	add hl,de			;bf5a
	ld (ix+009h),l		;bf5b
	ld (ix+00ah),h		;bf5e
	ret			;bf61
direccion_por_los_bits:		; Desplaza segun los bits de B para dar con la tabla
	ld a,e			;bf62   ; Calcula una direccion de tabla desplazando por los bits de B
	and 009h		;bf63
	ld l,a			;bf65
	ld h,009h		;bf66
	ld a,b			;bf68
	and a			;bf69
	jr z,lee_el_mezclador		;bf6a
desplaza_hasta:		; Cada uno de esos desplazamientos
	add hl,hl			;bf6c
	dec a			;bf6d
	jr nz,desplaza_hasta		;bf6e
lee_el_mezclador:		; Trae el registro 7, el del mezclador
	ld a,007h		;bf70
	call 00096h		;bf72   ; BIOS RDPSG - Reads value from PSG-register
	ld c,a			;bf75
	ld a,h			;bf76
	cpl			;bf77
	and c			;bf78
	or l			;bf79
	ld e,a			;bf7a
	ld a,007h		;bf7b
	jp 00093h		;bf7d   ; BIOS WRTPSG - Writes data to PSG-register
guarda_el_ultimo:		; Deja E en el ultimo campo del canal
	ld (ix+012h),e		;bf80
	ret			;bf83
avanza_el_guion:		; Lee el puntero del canal y lo adelanta tres posiciones
	ld l,(ix+000h)		;bf84   ; Lee el puntero de reproduccion del canal y lo avanza 3 posiciones
	ld h,(ix+001h)		;bf87
	ld e,(ix+003h)		;bf8a
	ld d,(ix+004h)		;bf8d
	add hl,de			;bf90
	inc de			;bf91
	inc de			;bf92
	inc de			;bf93
	ld (ix+003h),e		;bf94
	ld (ix+004h),d		;bf97
	ld a,(0f400h)		;bf9a   ; Lee el comando y su parametro de 2 bytes del flujo de bytecode
	ld b,a			;bf9d
	ld a,(hl)			;bf9e
	inc hl			;bf9f
	ld e,(hl)			;bfa0
	inc hl			;bfa1
	ld d,(hl)			;bfa2
	ret			;bfa3

; ----------------------------------------------------------------------
; DATOS tabla_despacho: 15 punteros de 16 bits para el jp (hl) de 0xBE8F,
;   indexados por (~A)*2 con A>=0xE0
;   0xbfa4..0xbfc2  (30 bytes)
DATA_tabla_despacho:
	defw 0bd6eh,0bd6eh,0bf17h,0bf18h,0bf03h	; bfa4
	defw 0bf29h,0bf47h,0bf62h,0bf62h,0bf62h	; bfae
	defw 0bef1h,0bf11h,0bf80h,0bef1h,0bf0bh	; bfb8

; ----------------------------------------------------------------------
; DATOS tabla_bfc2: 19 bytes, indexada por 1 byte desde 0xBD1E (cola de
;   tabla_despacho)
;   0xbfc2..0xbfd5  (19 bytes)
DATA_tabla_bfc2:
	defb 000h,000h,000h,001h,001h,001h,00fh,0edh,0bfh,010h,010h,001h,001h,000h,000h,001h	; bfc2  ................
	defb 000h,000h,000h	; bfd2

; ----------------------------------------------------------------------
; DATOS tabla_bfd5: 12 punteros de 16 bits, indexados desde 0xBEBF
;   0xbfd5..0xbfed  (24 bytes)
DATA_tabla_bfd5:
	defw 00d5ch,00c9dh,00be7h,00b3ch,00a9bh,00a02h	; bfd5
	defw 00973h,008ebh,0086bh,007f2h,00780h,00714h	; bfe1

; ----------------------------------------------------------------------
; DATOS tabla_bfed: 19 bytes al final del cartucho, base para un indexado de 8
;   en 8 desde 0xBF57; el ultimo tramo se trunca en el limite fisico de la ROM
;   0xbfed..0xc000  (19 bytes)
DATA_tabla_bfed:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0dch,0bah,098h,076h,054h,032h,010h	; bfed  ............vT2.
	defb 000h,000h,0ffh	; bffd
