author:
  name: ['Victor Hsieh']
  email: 'victor@csie.org'
name: 'crx-reloader-backend'
description: 'Crx Reloader Backend'
version: '0.5.0'
repository:
  type: 'git'
  url: 'git://github.com/victorhsieh/crx-reloader.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
    ./node_modules/.bin/lsc -cbo lib src
  """
main: 'lib/app.js'
engines:
  node: '0.8.x'
  npm: '1.1.x'
dependencies: {}
devDependencies:
  LiveScript: '1.1.x'
optionalDependencies: {}
