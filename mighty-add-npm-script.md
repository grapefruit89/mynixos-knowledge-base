---
title: add-npm-script (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/add-npm-script]
---

[![Build Status](https://travis-ci.org/mightyiam/add-npm-script.svg?branch=master)](https://travis-ci.org/mightyiam/add-npm-script)
[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# add-npm-script

Adds a provided script to `package.json`.

## Why?

- [Reads and writes closest `package.json`](https://www.npmjs.com/package/modify-pkg-up)
- Appropriate for set up of development tools
  like linters and test runners.

## How?

### Example

```js
const addNpmScript = require('add-npm-script')
addNpmScript('wow', 'echo such nice. much like.')
  .then(() => console.log('done'))
```

```console
$ npm run wow
such nice. much like.
```

### API

#### `addNpmScript(name, script)`

- `name`:
  name of the script
- `script`:
  script itself

Returns an empty promise.
