#
#	Makefile for FreeRTOS demo on Raspberry Pi
#
BASE=$(shell pwd)/
BUILD_DIR=$(shell pwd)/build/

MODULE_NAME="RaspberryPi BSP"

TARGETS=kernel.img kernel.list kernel.syms kernel.elf
LINKER_SCRIPT=raspberrypi.ld

-include .dbuild/dbuild.mk


all: kernel.list kernel.img kernel.syms
	@$(SIZE) kernel.elf

kernel.img: kernel.elf
	$(Q)$(PRETTY) IMAGE $(MODULE_NAME) $@
	$(Q)$(OBJCOPY) kernel.elf -O binary $@

kernel.list: kernel.elf
	$(Q)$(PRETTY) LIST $(MODULE_NAME) $@
	$(Q)$(OBJDUMP) -D -S  kernel.elf > $@

kernel.syms: kernel.elf
	$(Q)$(PRETTY) SYMS $(MODULE_NAME) $@
	$(Q)$(OBJDUMP) -t kernel.elf > $@

#kernel.elf: LDFLAGS += -L "/opt/Xilinx/14.2/ISE_DS/EDK/gnu/arm/lin64/lib/gcc/arm-xilinx-eabi/4.6.1/" -lgcc
#kernel.elf: LDFLAGS += -L "/opt/Xilinx/14.2/ISE_DS/EDK/gnu/arm/lin64/arm-xilinx-eabi/lib/" -lc
kernel.elf: LDFLAGS += -L "/usr/lib/gcc/aarch64-linux-gnu/10.2.0" -lgcc
kernel.elf: LDFLAGS += -L "/usr/aarch64-linux-gnu/lib" -lc
kernel.elf: $(OBJECTS)
	$(Q)$(LD) $(OBJECTS) -Map kernel.map -o $@ -T $(LINKER_SCRIPT) $(LDFLAGS)


QEMUOPTS = -M raspi3 -m 1G -serial null -serial mon:stdio -nographic -kernel kernel.elf

qemu:
	$(Q)qemu-system-aarch64 $(QEMUOPTS)

qemu-gdb:
	$(Q)qemu-system-aarch64 -gdb tcp::1234 -S $(QEMUOPTS)

gdb:
	$(Q)aarch64-none-elf-gdb -n -x .gdbinit -tui
