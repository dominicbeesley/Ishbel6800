
AS=vasm6800_std
ASFLAGS=-m6800 
LD=vlink
LDFLAGS=-m -b rawbin1 -nowarn=22 -Cvbcc  -nostdlib 

SCRIPTS=../../../../../scripts
BUILD=build
TARGETS=V2_Ishbel
TARGETS2=$(addsuffix .mif, $(addprefix $(BUILD)/, $(TARGETS)))

.SECONDARY:

all:: $(TARGETS2)

MKDIR := $(shell mkdir -p $(BUILD))
$(BUILD)/%.o: %.asm
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<
	
$(BUILD)/%.bin: $(BUILD)/%.o
	$(LD) $(LDFLAGS) -M$(basename $@).map -o $@ -T./$(notdir $(basename $@)).lk -symfile $(basename $@).sym -symfmt "DEF %s 0x%08llx" $(filter %.o, $^) 

$(BUILD)/%.mif: $(BUILD)/%.bin
	$(SCRIPTS)/perl/bin2mif.pl $< >$@

clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.mif=%.lst) 
	-rm $(TARGETS2:%.mif=%.bin) 
	-rm $(TARGETS2:%.mif=%.sym) 
	-rm $(TARGETS2:%.mif=%.map) 
	-rm $(TARGETS2:%.mif=%.o) 
