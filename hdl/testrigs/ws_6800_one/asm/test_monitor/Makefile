
AS=vasm6800_std
ASFLAGS=-m6800 

SCRIPTS=../../../../../scripts
BUILD=build
TARGETS=test_monitor
TARGETS2=$(addsuffix .mif, $(addprefix $(BUILD)/, $(TARGETS)))

all:: $(TARGETS2)

MKDIR := $(shell mkdir -p $(BUILD))

$(BUILD)/%.bin: %.asm
	$(AS) $(ASFLAGS) -Fbin -o $@ -L $(basename $@).lst $<

$(BUILD)/%.mif: $(BUILD)/%.bin
	$(SCRIPTS)/perl/bin2mif.pl $< >$@

clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.mif=%.lst) 
	-rm $(TARGETS2:%.mif=%.bin) 
