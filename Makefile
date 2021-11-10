# riscv64 toolchain programs.
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OC = riscv64-unknown-elf-objcopy
OS = riscv64-unknown-elf-size
READELF = riscv64-unknown-elf-readelf
OBJDUMP = riscv64-unknown-elf-objdump
MKDIR = mkdir -p

# DFU util for downloading firmware
DFU = dfu-util

# Assembler directives
ASFLAGS += -march=rv32imac
ASFLAGS += -mabi=ilp32
ASFLAGS += -g

# Linker directives.
LFLAGS += -nostdlib
LFLAGS += -march=rv32imac
LFLAGS += -mabi=ilp32
LFLAGS += -mcmodel=medlow
LFLAGS += -m elf32lriscv
LFLAGS += -TGD32VF103xB.ld

# Source files.
NAME = longan_nano
ASM = $(NAME).S
DISASM = $(NAME).asm
BIN = $(NAME).bin
ELF = $(NAME).elf
ELFHEADER = elf.header

SRCDIR = src
BUILDDIR = target

SOURCES := $(wildcard $(SRCDIR)/*.S)
OBJECTS := $(patsubst $(SRCDIR)/%.S,$(BUILDDIR)/%.o,$(SOURCES)) 

vpath %.S $(SRCDIR)

# Default rule to build the whole project.
.PHONY: all
all: $(BUILDDIR)/$(BIN) $(BUILDDIR)/$(ELFHEADER)

# Rule to create an object file from the assembly files.
$(BUILDDIR)/%.o: %.S | $(BUILDDIR)/
	$(AS) $(ASFLAGS) -o $@ $<

# Rule to link object files to elf file
$(BUILDDIR)/$(ELF): $(OBJECTS)
	$(LD) $(OBJECTS) $(LFLAGS) -o $@

#Rule to output the elf structure info into a file
$(BUILDDIR)/$(ELFHEADER): $(BUILDDIR)/$(ELF) 
	$(READELF) -a $< > $@

# Rule to create a raw binary file from an ELF file.
$(BUILDDIR)/$(BIN): $(BUILDDIR)/$(ELF) 
	$(OC) -S -O binary $< $@
	$(OS) $<

# Create output build directory before compile
$(BUILDDIR)/:
	@$(MKDIR) $@

# Flash bin to longan nano board
.PHONY: flash
flash:
	$(DFU) -a 0 -s 0x08000000:leave -D $(BUILDDIR)/$(BIN)

# disassembly elf to asm
.PHONY: disasm
disasm:
	$(OBJDUMP) --disassemble $(BUILDDIR)/$(ELF) > $(BUILDDIR)/$(DISASM)

# Rule to clear out generated build files.
.PHONY: clean
clean:
	rm -rf $(BUILDDIR)/
