---
sidebar_position: 12
---

# Garbage collection

Garbage collection is an automatic process that manages memory usage by detecting and removing unreferenced or dead objects and freeing up allocated heap memory.

Motoko’s default garbage collection method uses a copying approach that depends on the amount of heap memory currently in use. An alternative garbage collector uses a marking approach, which instead considers the amount of free heap memory. These garbage collectors are triggered when enough changes have been made to heap memory since the last collection cycle.

Both garbage collectors are limited by the ICP instruction limit per message, preventing them from collecting the entire heap memory pool in a single execution. As a result, [canisters](https://internetcomputer.org/docs/building-apps/essentials/canisters) cannot fully utilize the entire 4GiB memory pool, as some free space must be reserved for the garbage collector to operate.

A incremental garbage collection process is available, which distributes the workload across multiple messages as needed. This approach allows canisters to allocate up to three times more heap space after collection while consuming fewer cycles on average. With incremental garbage collection, canisters can take advantage of the entire 4 GiB heap memory pool.

The incremental garbage collector can be enabled by specifying the `--incremental-gc` compiler flag in the project's `dfx.json` file.


```json
{
  "canisters": {
    "my_dapp": {
       "main": "src/my-dapp.mo",
       "type": "motoko",
       "args" : "--incremental-gc"
    }
  }
}
```

Garbage collection can be forced to run after every message using the `--force-gc` flag in the project's `dfx.json` file. This should be used for debugging purposes outside of production.

```json
"defaults": {
  "build": {
    "packtool": "",
    "args": "--force-gc"
  }
}
```


