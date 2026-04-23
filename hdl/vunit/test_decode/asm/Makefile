
AS=vasm6800_std
ASFLAGS=-m6800 

BUILD=build
HOSTFS=~/hostfs/test6800
TARGETS=test test-bcd-dave test-bcd-dave2
TARGETS2=$(addsuffix .rom, $(addprefix $(BUILD)/, $(TARGETS)))

all:: $(TARGETS2)

MKDIR := $(shell mkdir -p $(BUILD))

$(BUILD)/%.rom: %.asm
	$(AS) $(ASFLAGS) -Fbin -o $@ -L $(basename $@).lst $<

clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.rom=%.lst) 
