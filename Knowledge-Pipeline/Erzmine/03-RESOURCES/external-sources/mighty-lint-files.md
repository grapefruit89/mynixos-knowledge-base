---
title: lint-files (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/lint-files]
---

[![Build Status](https://travis-ci.org/mightyiam/lint-files.svg?branch=master)](https://travis-ci.org/mightyiam/lint-files)
[![Standard - JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# lint-files

Convenience wrapper for ESLint’s `CLIEngine.prototype.executeOnFiles()`

Instead of

```js
const { CLIEngine } = require('eslint')
const cli = new CLIEngine({ some: 'options' })
cli.executeOnFiles(['some', 'files'])
```

Do

```js
const lintFiles = require('lint-files')
lintFiles({ some: 'options' }, ['some', 'files'])
```

## Features

- one line less
- no `new`
- tested better than patience

## API

### `lintFiles(options, files)`

- `options`:  
  will be passed to the `CLIEngine` constructor ([ESLint docs](http://eslint.org/docs/developer-guide/nodejs-api#cliengine))
- `files`:  
  will be passed to `executeOnFiles` ([ESLint docs](http://eslint.org/docs/developer-guide/nodejs-api#executeonfiles))

Returns what `executeOnFiles` returns.
