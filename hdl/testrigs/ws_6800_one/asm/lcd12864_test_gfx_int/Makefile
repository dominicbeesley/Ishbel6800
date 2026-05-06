SCRIPTS=../../../../../scripts
BUILD=build
INCLUDES=../includes

AS=vasm6800_std
ASFLAGS=-m6800 -I $(INCLUDES)
LD=vlink
LDFLAGS=-m -b srec19 -nowarn=22 -Cvbcc  -nostdlib 

TARGETS=lcd_test
TARGETS2=$(addsuffix .s19, $(addprefix $(BUILD)/, $(TARGETS)))
DEPS=$(wildcard $(INCLUDES)/*.inc)

.SECONDARY:

all:: $(TARGETS2)

MKDIR := $(shell mkdir -p $(BUILD))

$(TARGETS2:%.s19=%.o): $(DEPS)

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
