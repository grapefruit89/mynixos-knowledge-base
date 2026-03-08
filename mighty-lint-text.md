---
title: lint-text (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/lint-text]
---

[![Build Status](https://travis-ci.org/mightyiam/lint-text?branch=master)](https://travis-ci.org/mightyiam/lint-text)
[![Standard - JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# lint-text

Convenience wrapper for ESLint’s `CLIEngine.prototype.executeOnText()`

Instead of

```js
const { CLIEngine } = require('eslint')
const cli = new CLIEngine({ some: 'options' })
cli.executeOnText('"some" && "code"')
```

Do

```js
const lintText = require('lint-text')
lintText({ some: 'options' }, ['"some" && "code"'])
```

## Features

- one line less
- no `new`
- tested better than patience

## API

### `lintText(options, text)`

- `options`:  
  will be passed to the `CLIEngine` constructor ([ESLint docs](http://eslint.org/docs/developer-guide/nodejs-api#cliengine))
- `text`:  
  will be passed as first argument to `executeOnText` ([ESLint docs](http://eslint.org/docs/developer-guide/nodejs-api#executeontext))

Returns what `executeOnText` returns.
