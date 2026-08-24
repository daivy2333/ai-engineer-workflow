# QEMU Image Layout and Mutation

Use this reference when a QEMU failure depends on a disk image, pflash, a fixed byte region, a backing chain, or media changed by the guest or firmware.

## Container and backing state

- Identify raw, qcow2, or another container from its metadata, not its filename suffix.
- Distinguish virtual size from allocated size. Sparse allocation does not change guest-visible capacity.
- Resolve qcow2 backing files and overlays before attributing unexpected bytes to the active image.
- Treat pflash, firmware variables, filesystems, and reusable block media as mutable QEMU inputs. Repeated runs may start from different state unless they use a fresh copy or overlay.

`file` and `qemu-img info` help identify the container. Partition tools describe content inside the guest-visible address space; they do not identify the outer container.

## Partitions and offsets

- Read the partition-table type and logical sector size from the image or tool output; do not assume 512-byte sectors.
- Convert a partition start to bytes with `start_sector * logical_sector_size`.
- State whether an offset is image-relative, partition-relative, or relative to a nested container.
- Account for firmware, bootloader, metadata, or fixed regions that may live outside the partition table.
- Check that `offset + payload_size` remains within its intended region and does not overlap another payload.

For raw writes, `dd` semantics depend on `bs`, `seek`, `skip`, `count`, and truncation behavior. A numerically correct offset with the wrong unit or base can produce a bootable but incorrect image.

## Mutation and verification

- Converting, resizing, rebasing, repartitioning, repairing a filesystem, mounting read-write, or running a writable guest can change container or guest-visible state.
- Firmware and pflash may update variables before Linux starts. A later boot can therefore differ without any source change.
- Flush pending writes before inspecting the final layout or byte ranges.
- Check material writes with independent readback. A successful command exit does not prove placement, bounds, or filesystem contents.
- A QEMU boot does not prove byte-for-byte packaging correctness because firmware, filesystems, and the guest may tolerate or mutate an incorrect layout.

When a boot failure follows image work, compare the container type, backing chain, partition boundaries, sector size, fixed regions, and guest-visible contents before changing kernel or driver code.
