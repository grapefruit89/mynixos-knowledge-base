---
title: eslint-failing-rules (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/eslint-failing-rules]
---

[![Build Status](https://travis-ci.org/mightyiam/eslint-failing-rules.svg?branch=master)](https://travis-ci.org/mightyiam/eslint-failing-rules) [![codecov](https://codecov.io/gh/mightyiam/eslint-failing-rules/branch/master/graph/badge.svg)](https://codecov.io/gh/mightyiam/eslint-failing-rules)
[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# eslint-failing-rules

Gets failing ESLint rules.

## Why?

You may like to use that somehow, somewhere.

## How?

```js
const eslint = require('eslint')
const getFailing = require('eslint-failing-rules')

getFailing(eslint, ['**/*.js']) // ['semi', 'no-unused-vars']
```

### API

#### `getFailing(eslint, files)`

- `eslint`
  What `eslint@^3` exports
- `files`
  Input for ESLint’s [`executeOnFiles()`](http://eslint.org/docs/developer-guide/nodejs-api#executeonfiles).
  E.g. `['**/*.js', '**/*.jsx']`

Returns an array set of failed ESLint rules.

The purpose is to find the same failing rules that would be encountered
when running ESLint the way it is usually run in a context.

For this purpose, [`CLIEngine`](http://eslint.org/docs/developer-guide/nodejs-api#cliengine)
is called without any options,
so that any [configuration files](http://eslint.org/docs/user-guide/configuring#using-configuration-files)
that are usually be used, would be used.
