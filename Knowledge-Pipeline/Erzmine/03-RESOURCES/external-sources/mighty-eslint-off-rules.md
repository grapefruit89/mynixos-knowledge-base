---
title: eslint-off-rules (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/eslint-off-rules]
---

[![Build Status](https://travis-ci.org/mightyiam/eslint-off-rules.svg?branch=master)](https://travis-ci.org/mightyiam/eslint-off-rules)
[![JavaScript Style Guide](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)

# eslint-off-rules

Returns an ESLint rules config object of all provided `ruleId`s set to "off".

## Why?

Because you may like to ignore some rules.

## How?

### Example

`.eslintrc.js`:
```js
const off = require('eslint-off-rules')

const config = {
  rules: {
    'no-console': 'error',
    'no-debugger': 'error'
  }
}

const offRules = off(['semi', 'quotes']) // { semi: 'off', quotes: 'off' }
Object.assign(config.rules, offRules)

module.exports = config
```

### API

#### fn(ruleIds)

- `rules`
  array of [`ruleId`s](http://eslint.org/docs/rules/)

Returns an object which has
properties named after each of the provided `ruleId`s
and in which all of the values are `'off'`.
