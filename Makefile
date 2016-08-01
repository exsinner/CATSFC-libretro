TARGET = CATSFC-libretro-vita

PSP_APP_NAME=CATSFC-libretro-vita
PSP_APP_VER=1.1.1

CORE_DIR := source
VITA_DIR := vita
LIBRETRO_DIR := libretro

SOURCES_C := \
	$(CORE_DIR)/apu.c $(CORE_DIR)/c4.c $(CORE_DIR)/c4emu.c $(CORE_DIR)/cheats2.c $(CORE_DIR)/cheats.c \
	$(CORE_DIR)/clip.c $(CORE_DIR)/cpu.c $(CORE_DIR)/cpuexec.c $(CORE_DIR)/cpuops.c $(CORE_DIR)/data.c\
	$(CORE_DIR)/dma.c $(CORE_DIR)/dsp1.c $(CORE_DIR)/fxdbg.c $(CORE_DIR)/fxemu.c $(CORE_DIR)/fxinst.c \
	$(CORE_DIR)/gfx.c $(CORE_DIR)/globals.c $(CORE_DIR)/memmap.c $(CORE_DIR)/obc1.c $(CORE_DIR)/ppu.c \
	$(CORE_DIR)/sa1.c $(CORE_DIR)/sa1cpu.c $(CORE_DIR)/sdd1.c $(CORE_DIR)/sdd1emu.c $(CORE_DIR)/seta010.c \
	$(CORE_DIR)/seta011.c $(CORE_DIR)/seta018.c $(CORE_DIR)/seta.c $(CORE_DIR)/soundux.c $(CORE_DIR)/spc700.c \
	$(CORE_DIR)/spc7110.c $(CORE_DIR)/srtc.c $(CORE_DIR)/tile.c $(CORE_DIR)/apu_blargg.c
SOURCES_C += $(LIBRETRO_DIR)/libretro.c
SOURCES_C += $(VITA_DIR)/utils.c $(VITA_DIR)/vita_input.c $(VITA_DIR)/vita_audio.c \
             $(VITA_DIR)/vita_video.c $(VITA_DIR)/vita_menu.c $(VITA_DIR)/main.c
    
OBJS := $(SOURCES_C:.c=.o)

LIBS = -lpsplib -lvita2d -lfreetype -lpng -lz -lm -lSceCommonDialog_stub -lSceSysmodule_stub -lSceDisplay_stub -lSceGxm_stub 	\
	-lSceCtrl_stub -lSceAudio_stub -lSceRtc_stub -lScePower_stub -lSceAppUtil_stub \
    -lSceCommonDialog_stub

PREFIX   = arm-vita-eabi
AS = $(PREFIX)-as
CC = $(PREFIX)-gcc
CXX		 = $(PREFIX)-g++
READELF  = $(PREFIX)-readelf
OBJDUMP  = $(PREFIX)-objdump

CFLAGS   = -Wl,-q -O3 -DVITA
CFLAGS  += -w -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -ftree-vectorize \
		   -mfloat-abi=hard -ffast-math -fsingle-precision-constant -ftree-vectorizer-verbose=2 -fopt-info-vec-optimized -funroll-loops \
           -mword-relocations -fno-rtti -Wno-deprecated -Wno-comment -Wno-sequence-point
CFLAGS  += -DHAVE_STRINGS_H -DHAVE_STDINT_H -DHAVE_INTTYPES_H -DRIGHTSHIFT_IS_SAR -DINLINE=inline -DFRONTEND_SUPPORTS_RGB565
CFLAGS  += -DSPC700_C -DEXECUTE_SUPERFX_PER_LINE -DSDD1_DECOMP \
           -DVAR_CYCLES -DCPU_SHUTDOWN -DSPC700_SHUTDOWN \
           -DNO_INLINE_SET_GET -DNOASM -DHAVE_MKSTEMP '-DACCEPT_SIZE_T=size_t' -DWANT_CHEATS \
           -DPSP_APP_NAME=\"$(PSP_APP_NAME)\" -DPSP_APP_VER=\"$(PSP_APP_VER)\"
CFLAGS  += -D__LIBRETRO__
ASFLAGS  = $(CFLAGS)


INCFLAGS := -I$(CORE_DIR) -I$(VITA_DIR) -I$(LIBRETRO_DIR)

all: eboot.bin

eboot.bin: $(TARGET).velf
	vita-make-fself $(TARGET).velf eboot.bin
	vita-mksfoex -s TITLE_ID=SKOG10001 "CATSFC Libretro Vita" param.sfo

$(TARGET).velf: $(TARGET).elf
		$(PREFIX)-strip -g $<
		vita-elf-create  $< $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(ASFLAGS) $(INCFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf $(TARGET).elf $(TARGET).velf $(OBJS) $(DATA)/*.h

copy: $(TARGET).velf
	@cp $(TARGET).velf ~/shared/vitasample.elf
	@echo "Copied!"
