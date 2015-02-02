fs            = require('fs')
runsync       = require('runsync')  # polyfil for node.js 0.12 synchronous running functionality. Remove when upgrading to 0.12

runSync = (command, options, next) ->
  {stderr, stdout} = runSyncRaw(command, options)
  if stderr.length > 0
    console.error("Error running `#{command}`\n" + stderr)
    process.exit(1)
  if next?
    next(stdout)
  else
    if stdout.length > 0
      console.log("Stdout exec'ing command '#{command}'...\n" + stdout)

runSyncNoExit = (command, options) ->
  {stderr, stdout} = runSyncRaw(command, options)
  console.log("Output of running '#{command}'...\n#{stderr}\n#{stdout}\n")
  return {stderr, stdout}

runSyncRaw = (command, options) ->
  if options? and options.length > 0
    command += ' ' + options.join(' ')
  output = runsync.popen(command)
  stdout = output.stdout.toString()
  stderr = output.stderr.toString()
  return {stderr, stdout}

task('compile', 'Compile CoffeeScript source files to JavaScript', () ->
  process.chdir(__dirname)
  fs.readdir('./', (err, contents) ->
    files = ("#{file}" for file in contents when (file.indexOf('.coffee') > 0))
    runSync('coffee', ['-c'].concat(files))
  )
)

task('test', 'Run the CoffeeScript test suite with nodeunit', () ->
  {reporters} = require('nodeunit')
  process.chdir(__dirname)
  reporters.default.run(['test'], undefined, (failure) -> 
    if failure?
      console.log(failure)
      process.exit(1)
  )
)


task('publish', 'Publish to npm and add git tags', () ->
  process.chdir(__dirname)
  runSync('cake test')  # Doing this externally to make it synchronous
  process.chdir(__dirname)
  runSync('cake compile')
  console.log('checking git status --porcelain')
  runSync('git status --porcelain', [], (stdout) ->
    if stdout.length == 0

      console.log('checking origin/master')
      {stderr, stdout} = runSyncNoExit('git rev-parse origin/master')

      console.log('checking master')
      stdoutOrigin = stdout
      {stderr, stdout} = runSyncNoExit('git rev-parse master')
      stdoutMaster = stdout

      if stdoutOrigin == stdoutMaster

        console.log('running npm publish')
        runSyncNoExit('npm publish .')

        if fs.existsSync('npm-debug.log')
          console.error('`npm publish` failed. See npm-debug.log for details.')
        else

          console.log('creating git tag')
          runSyncNoExit("git tag v#{require('./package.json').version}")
          runSyncNoExit("git push --tags")
      else
        console.error('Origin and master out of sync. Not publishing.')
    else
      console.error('`git status --porcelain` was not clean. Not publishing.')
  )
)

