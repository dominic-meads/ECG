set(DDR mig_0)
set(mig_0 "0x80000000;0x10000000")
set(lmb_bram_0 "0x50;0x7fb0")
set(TOTAL_MEM_CONTROLLERS "mig_0;lmb_bram_0")
set(MEMORY_SECTION "MEMORY
{
	mig_0 : ORIGIN = 0x80000000, LENGTH = 0x10000000
	lmb_bram_0 : ORIGIN = 0x50, LENGTH = 0x7fb0
}")
set(STACK_SIZE 0x400)
set(HEAP_SIZE 0x800)
