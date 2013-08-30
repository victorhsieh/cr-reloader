author:
  name: ['Victor Hsieh']
  email: 'victor@csie.org'
name: 'cr-reloader-backend'
description: 'Cr Reloader Backend'
version: '0.6.1'
repository:
  type: 'git'
  url: 'git://github.com/victorhsieh/cr-reloader.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
    ./node_modules/.bin/lsc -cbo lib src
  """
  publish: """
    rm ../cr-reloader-backend.zip
    zip -r ../cr-reloader-backend.zip . -x 'node_modules*' 'src*' npm-debug.log '.*.swp'
  """
main: 'lib/app.js'
engines:
  node: '0.8.x'
  npm: '1.1.x'
dependencies: {}
devDependencies:
  LiveScript: '1.1.x'
optionalDependencies: {}
