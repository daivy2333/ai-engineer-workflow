# Address Reconciliation

Use one ledger for every address mentioned during debugging.

## Address ledger

| Field | Meaning | Evidence |
|---|---|---|
| Source location | File, function, and line | Debug information |
| Symbol address | Value recorded for a symbol | Symbol table |
| VMA | Address expected during execution | Section and program headers |
| LMA | Address used to load or store a segment | Linker script, map, loader |
| File offset | Byte position in ELF or image | Program headers |
| Runtime VA | Virtual address used by the CPU | PC, mappings, page tables |
| Runtime PA | Physical address after translation | Page-table walk or monitor |
| Relocation slide | Runtime displacement from linked layout | Loader and runtime mappings |
| MMIO address | Device register address | Platform description and bus map |
| Debugger address | Address space interpreted by the debug stub | Stub and target configuration |

Never write an unlabeled address in the evidence report.

## Conversions

Use these relations only after their assumptions are proven:

```text
runtime address = linked VMA + relocation slide
symbol offset = runtime PC - runtime symbol start
file offset = segment file offset + (VMA - segment VMA)
physical address = page_table_translate(runtime virtual address)
MMIO register = device base + register offset
```

LMA may differ from VMA. Flat binaries may remove ELF metadata. PIE, KASLR, bootloader relocation, overlays, and per-process address spaces can add distinct slides.

## Static artifact checks

Use the target-prefixed variants when host tools cannot decode the target:

```text
file <elf>
readelf -h <elf>
readelf -l <elf>
readelf -S <elf>
readelf -s <elf>
readelf -r <elf>
nm -n <elf>
objdump -dr <elf>
addr2line -e <elf> -f -C <address>
```

Also inspect:

- Linker script.
- Linker map.
- Loader configuration.
- Raw image conversion command.
- Build ID or artifact hash.
- Separate or split debug information.

Do not run `addr2line` on a runtime address until relocation has been removed or the tool has been given the runtime layout.

## Byte reconciliation

For an observed PC:

1. Identify its runtime address space.
2. Translate it to linked VMA.
3. Locate the containing segment and file offset.
4. Read bytes from the artifact.
5. Read the same number of bytes from runtime memory.
6. Decode both with the same architecture and instruction mode.
7. Record the first differing byte.

If bytes differ, test these causes before trusting symbols:

- Wrong or stale image.
- Wrong debug symbols.
- Incorrect load address.
- Missing relocation slide.
- Incorrect virtual-to-physical conversion.
- Debug stub reading another address space.
- Code overwrite or patching.
- Missing instruction-cache maintenance.
- Wrong endianness or instruction mode.

## MMIO addresses

For a faulting load or store, record:

- Faulting instruction and operands.
- Register values used by address calculation.
- Computed effective address.
- Access width and alignment.
- Virtual and physical addresses.
- Page or region attributes.
- Device base and register offset.
- Clock, reset, privilege, and bus state when relevant.

Do not infer access width from register stride.
