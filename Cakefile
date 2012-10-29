fs            = require('fs')
path          = require('path')
{print}       = require('sys')
{spawn, exec} = require('child_process')


run = (command, options, next) ->
  if options? and options.length > 0
    command += ' ' + options.join(' ')
  exec(command, (error, stdout, stderr) ->
    if stderr.length > 0
      console.log("Stderr exec'ing command '#{command}'...\n" + stderr)
    if error?
      console.log('exec error: ' + error)
    if next?
      next(stdout)
    else
      if stdout.length > 0
        console.log("Stdout exec'ing command '#{command}'...\n" + stdout)
  )

compile = (watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = false
  options = ['-c', '-o', 'js', '.']
  options.unshift '-w' if watch
  run('coffee', options)

task('compile', 'Compile CoffeeScript source files to JavaScript and place in ./js', () ->
    compile()
)

task('watch', 'Recompile CoffeeScript source files when modified and place in ./js *\n' +
              '                          * Actually, it is best to just run `jitter . js` from the command line', () ->
    compile(true)
)

task('install', 'Install globally but from this source using npm', () ->
  process.chdir(__dirname)
  run('npm install -g .')
)

task('publish', 'Publish to npm', () ->
  process.chdir(__dirname)
  run('npm publish .')
)

task('test', 'Run the CoffeeScript test suite with nodeunit', () ->
  {reporters} = require('nodeunit')
  process.chdir(__dirname)
  reporters.default.run(['test'])
)
