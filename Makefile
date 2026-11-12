# Casio World Open (Casio, MSX1) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# La ROM no se distribuye. Hace falta en la raiz como casioworldopen.rom, y
# `make comprueba` verifica el sha256.

ROM      = casioworldopen.rom
SHA      = 7b03fd41c11975131db7c2303aa0757b369c4f6e1e54586da8f2b70d68b8d19d
SRC      = src
WORK     = work
ORG      = 0x4000
TITULO   = CASIO WORLD OPEN - Casio - MSX1 - cartucho de 32 KB en las paginas 1 y 2

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Casio World Open (Casio, 1985) para MSX, 32768 bytes exactos."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -ganchos de interrupcion, destinos de saltos
# indirectos- estan declarados en el .entries, cada uno con su justificacion.
$(WORK)/casioworldopen.trace.json: $(ROM) $(SRC)/casioworldopen.entries $(SRC)/casioworldopen.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/casioworldopen.entries \
	        $(WORK)/casioworldopen $(SRC)/casioworldopen.nocode

trace: $(WORK)/casioworldopen.trace.json

listado: $(WORK)/casioworldopen.trace.json $(SRC)/casioworldopen.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/casioworldopen.trace.json \
	        $(SRC)/casioworldopen.notes work/msx.sym $(SRC)/casioworldopen.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/casioworldopen.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/casioworldopen.asm $(ROM) $(ORG)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/casioworldopen.trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/casioworldopen.trace.json $(SRC)/casioworldopen.nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/casioworldopen.entries $(SRC)/casioworldopen.notes \
	        $(SRC)/casioworldopen.nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

densidad:
	@python3 tools/densidad.py $(SRC)/casioworldopen.asm

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# Dibuja los bloques de datos graficos declarados en el .notes, para MIRARLOS.
imagenes: $(ROM)
	@mkdir -p work/gfx
	python3 tools/dibuja.py $(ROM) $(ORG) $(SRC)/casioworldopen.notes work/gfx

# El swing JUGADO: grabar con
#   powershell -File tools/lanza_graba.ps1 -rom casioworldopen.rom -guion tools/guiones/swing.tcl -salida work/swing.bin -bp 0x4B8A -ram "0xE000 0x1000" -maquina C-BIOS_MSX1_JP
# y despues los GIF y su cotejo con la ROM.
gifs: $(ROM)
	python3 tools/swing_gif.py docs/imagenes
	python3 tools/swing_cotejo.py

web: $(ROM)
	python3 tools/graficos.py $(ROM) $(ORG) docs/imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	python3 tools/check_enlaces.py docs

clean:
	rm -rf $(WORK)/casioworldopen.trace.json $(WORK)/casioworldopen.blocks

.PHONY: all comprueba trace listado verify sanity test densidad imagenes gifs clean
