AS=vasm6800_std
ASFLAGS=-m6800 
LD=vlink
LDFLAGS=-m -b rawbin1 -nowarn=22 -Cvbcc -T./vlink.cmd -nostdlib 

SCRIPTS=../../../../../scripts
BUILD=build
TARGETS=mon6800
mon6800_OBJS=mon6800.o

mon6800_OBJS_B=$(addprefix $(BUILD)/, $(mon6800_OBJS))

TARGETS2=$(addsuffix .hex, $(addprefix $(BUILD)/, $(TARGETS)))

X := $(shell mkdir $(BUILD))

all:: $(TARGETS2)

$(BUILD)/%.o: %.asm
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<


$(BUILD)/mon6800.rom: $(mon6800_OBJS_B)
	$(LD) $(LDFLAGS) -M$(basename $@).map -o $@ -symfile $(basename $@).sym -symfmt "DEF %s 0x%08llx" $(filter %.o, $^) 

$(BUILD)/%.mif: $(BUILD)/%.rom
	$(SCRIPTS)/perl/bin2mif.pl $< >$@

$(BUILD)/%.hex: $(BUILD)/%.rom
	srec_cat $< -Binary -Output >$@ -Intel

clean::
	-rm $(mon6800_OBJS_B)
	-rm $(patsubst %.o, %.lst, $(mon6800_OBJS_B))
	-rm $(TARGETS2) 
	-rm $(patsubst %.hex, %.rom, $(TARGETS2))
	-rm $(patsubst %.hex, %.map, $(TARGETS2))
	-rm $(patsubst %.hex, %.sym, $(TARGETS2))
