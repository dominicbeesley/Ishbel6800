
AS=vasm6800_std
ASFLAGS=-m6800 -I ../includes -pad=0x3E -uspc=0x3E
#LD=vlink
#LDFLAGS=-m -b srec19 -nowarn=22 -Cvbcc  -nostdlib

SCRIPTS=../../../../../scripts
BUILD=build
TARGETS=testsuite testsuite.cmp
TARGETS2=$(addsuffix .s19, $(addprefix $(BUILD)/, $(TARGETS)))

.SECONDARY:

all:: $(TARGETS2)


MKDIR := $(shell mkdir -p $(BUILD))
$(BUILD)/testsuite.cmp.s19: testsuite.asm 
	$(AS) $(ASFLAGS) -DBUILD_COMPARE=1 -Fsrec -s19 -o $@ -L $(basename $@).lst $<

$(BUILD)/testsuite.s19: testsuite.asm 
	$(AS) $(ASFLAGS) -DBUILD_WSONE=1 -Fsrec -s19 -o $@ -L $(basename $@).lst $<

clean::
	-rm $(TARGETS2) 
	-rm $(TARGETS2:%.s19=%.lst) 
	-rm $(TARGETS2:%.s19=%.sym) 
	-rm $(TARGETS2:%.s19=%.map) 
	-rm $(TARGETS2:%.s19=%.o) 
