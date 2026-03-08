---
title: equals-regalia (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/equals-regalia]
---

[![Build Status](https://travis-ci.org/mightyiam/equals-regalia.svg?branch=master)](https://travis-ci.org/mightyiam/equals-regalia) [![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# equals-regalia

Deep equality check for [regalia](https://www.npmjs.com/package/regalia) trees.

## Why?

Because perhaps we'd like to test our regalia trees.

## How?

1. [Reversal](https://www.npmjs.com/package/regalia-reverse)
1. [Deep equality](https://www.npmjs.com/package/lodash.isequal)

### Example

```js
const regalia = require('regalia')
const equalsRegalia = require('equals-regalia')

const regaliaTree = regalia(['foo', 'bar'])
equalsRegalia(regaliaTree, ['foo']) // false
equalsRegalia(regaliaTree, ['foo', 'bar']) // true
```

### API

#### `equalsRegalia(regaliaTree, definitionTree)`

- `regaliaTree`:
  a regalia tree
- `definitionTree`:
  a regalia definition tree (a regalia input)

Returns boolean result.
