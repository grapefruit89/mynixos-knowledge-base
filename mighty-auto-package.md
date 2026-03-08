---
title: auto-package (mightyiam Nugget)
category: architecture/mightyiam-discovery
capabilities: [extracted-readme, traceability-secured]
sources: [https://github.com/mightyiam/auto-package]
---

auto-package
============
Dynamically generate `package.json` files for automated releases.

### How does this even work?
* Install it `npm install -g auto-package`
* Add `package.json` to `.gitignore`
* Write a `package.js` file like this:

```js
var Package = require('auto-package');

Package.name('some-module');
Package.author('John Manero', 'john.manero@gmail.com');
Package.description('Dynamically generate package.json files for NodeJS modules');
Package.versionFile(); // Read version from ./VERSION

Package.githubRepo('jmanero/node-some-module');

Package.keyword('some');
Package.keyword('module');

Package.license('MIT');
```

* Run `node package.js`
* Run `npm publish`

### Why?
Because JSON is static, and continuous integration isn't. In an automated build environment, often times merging to `master` results in a release. With tools like `thor-scmversion`, automated release versioning is easy, but getting that version into your `package.json` file isn't. This utility provides a simple framework to represent package metadata as code instead of JSON.

### API
* _#content_ Is the object that eventually becomes `package.json`. You may do with it what you will.
* _#name(value), #version(value), #description(value), #license(value), #repo(value), #homepage(value)_ Do exactly what you think...
* _#author(name, email)_ does too.
* _#versionFile(path)_ Is more interesting. It will try to read a version string from a file at `path` (relative to CWD)
* _#keyword(word)_ Adds a keyword
* _#depends(name, version)_ Adds a dependency
* _#githubRepo('owner/repo')_ Adds `repo`, `homepage`, and `bugs` fields to GitHub resources

### CI setup tip
Build your `package.json` before the CI tries to find it.

Also, if you `require` any dependencies in `package.js`, install them as well.

For example, in Travis CI:

```yml
language: node_js
node_js: stable
before_install: 'npm i auto-package@^0.1.1 some-dependency@^1.1.5 && node package.js'
```

## License
The MIT License (MIT)
=====================
_Copyright (C) 2015 John Manero <john.manero@gmail.com>_

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
