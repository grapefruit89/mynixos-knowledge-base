---
title: not-os (Mic92 Fork Nugget)
category: architecture/infrastructure
capabilities: [image-building, micro-vms, minimal-os, fleet-config]
sources: [https://github.com/Mic92/not-os]
---

not-os is a small experimental OS I wrote for embeded situations, it is based heavily on NixOS, but compiles down to a kernel, initrd, and a 48mb squashfs

there are also example iPXE config files, that will check the cryptographic signature over all images, to ensure only authorized files can run on the given hardware

and I have [Hydra](https://hydra.angeldsis.com/jobset/not-os/notos-unstable#tabs-jobs) setup and doing automatic builds of not-os against nixos-unstable, including testing that it can boot under qemu
