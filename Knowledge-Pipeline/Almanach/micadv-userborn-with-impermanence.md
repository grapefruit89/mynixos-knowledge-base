---
title: userborn-with-impermanence (Mic92 Advanced Pattern)
category: architecture/mic92-virtuoso
capabilities: [testing-vms, server-config, mesh-vpn, impermanence-users]
sources: [https://github.com/Mic92/userborn-with-impermanence]
---

Me trying to make impermance work with userborn.
Can be tested like this:

```
$ nix run github:Mic92/userborn-with-impermanence#nixosConfigurations.myhost.config.system.build.vmWithDisko
```

## Current issues

- [x] ~~`environment.persistence.<mountpoint>.users.<user>.directories` have the wrong user/group.~~, see https://github.com/nix-community/impermanence/pull/223

