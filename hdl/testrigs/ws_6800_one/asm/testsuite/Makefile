
AS=vasm6800_std
ASFLAGS=-m6800 -I ../includes -pad=0x3E
LD=vlink
LDFLAGS=-m -b srec19 -nowarn=22 -Cvbcc  -nostdlib

SCRIPTS=../../../../../scripts
BUILD=build
TARGETS=testsuite
TARGETS2=$(addsuffix .s19, $(addprefix $(BUILD)/, $(TARGETS)))

.SECONDARY:

all:: $(TARGETS2)

testsuite: $(wildcard **.f16)

MKDIR := $(shell mkdir -p $(BUILD))
$(BUILD)/%.o: %.asm
	$(AS) $(ASFLAGS) -Fvobj -o $@ -L $(basename $@).lst $<

$(BUILD)/%.s19: $(BUILD)/%.o 
	$(LD) $(LDFLAGS) -M$(basename $@).map -o $@ -T./$(notdir $(basename $@)).lk -symfile $(basename $@).sym -symfmt "DEF %s 0x%08llx" $(filter %.o, $^) 


clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.s19=%.lst) 
	-rm $(TARGETS2:%.s19=%.sym) 
	-rm $(TARGETS2:%.s19=%.map) 
	-rm $(TARGETS2:%.s19=%.o) 
