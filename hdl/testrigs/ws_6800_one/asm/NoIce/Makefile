
SCRIPTS=../../../../../scripts
BUILD=build
INCLUDES=../includes

AS=vasm6800_std
ASFLAGS=-m6800 -I $(INCLUDES)
LD=vlink
LDFLAGS=-m -b rawbin1 -nowarn=22 -Cvbcc -nostdlib 

TARGETS=mon6800
TARGETS2=$(addsuffix .hex, $(addprefix $(BUILD)/, $(TARGETS)))
DEPS=$(wildcard $(INCLUDES)/*.inc)

.SECONDARY:

all:: $(TARGETS2)

MKDIR := $(shell mkdir -p $(BUILD))

$(TARGETS2:%.hex=%.o): $(DEPS)

$(BUILD)/%.o: %.asm
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<


$(BUILD)/%.rom: $(BUILD)/%.o
	$(LD) $(LDFLAGS) -M$(basename $@).map -o $@ -T./$(notdir $(basename $@)).lk -symfile $(basename $@).sym -symfmt "DEF %s 0x%08llx" $(filter %.o, $^) 

$(BUILD)/%.mif: $(BUILD)/%.rom
	$(SCRIPTS)/perl/bin2mif.pl $< >$@

$(BUILD)/%.hex: $(BUILD)/%.rom
	srec_cat $< -Binary -Output >$@ -Intel

clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.hex=%.lst) 
	-rm $(TARGETS2:%.hex=%.sym) 
	-rm $(TARGETS2:%.hex=%.map) 
	-rm $(TARGETS2:%.hex=%.mif) 
	-rm $(TARGETS2:%.hex=%.rom) 
	-rm $(TARGETS2:%.hex=%.o) 
