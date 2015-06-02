fs            = require('fs')
{execSync, spawnSync} = require('child_process')

runSyncOld = (command) ->
  try
    stdout = execSync(command, {encoding: 'utf8'})
  catch error
    console.log("Error running '#{command}'...\n#{error}\n")
    process.exit(1)
  console.log("Output of running '#{command }'...\n#{stdout}\n")
  return stdout

runSync = (command, args = []) ->
  results = spawnSync(command, args, {encoding: 'utf8'})
  {status, stdout, stderr} = results
  if stderr?.length > 0 or status > 0
    console.error("Error running: '#{command + ' ' + args.join(' ')}'\n#{stderr}\n")
    process.exit(status)
  else
    console.log("Output of running '#{command + ' ' + args.join(' ')}'\n#{stdout}\n")
    return stdout

task('compile', 'Compile CoffeeScript source files to JavaScript', () ->
  process.chdir(__dirname)
  fs.readdir('./', (err, contents) ->
    files = ("#{file}" for file in contents when (file.indexOf('.coffee') > 0))
    command = ['coffee ', '-c'].concat(files).join(' ')
    runSync(command)
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
  runSync('cake', ['test'])  # Doing this externally to make it synchronous
  process.chdir(__dirname)
  runSync('cake', ['compile'])
  console.log('checking git status --porcelain')
  stdout = runSync('git', ['status', '--porcelain'])
  if stdout.length > 0
    console.error('`git status --porcelain` was not clean. Not publishing.')
  else
    console.log('checking origin/master')
    stdout = runSync('git', ['rev-parse', 'origin/master'])

    console.log('checking master')
    stdoutOrigin = stdout
    stdout = runSync('git', ['rev-parse', 'master'])
    stdoutMaster = stdout

    if stdoutOrigin == stdoutMaster

      console.log('running npm publish')
      runSync('npm', ['publish', '.'])

      if fs.existsSync('npm-debug.log')
        console.error('`npm publish` failed. See npm-debug.log for details.')
      else

        console.log('creating git tag')
        runSync("git", ["tag", "v#{require('./package.json').version}"])
        runSync("git", ["push", "--tags"])
    else
      console.error('Origin and master out of sync. Not publishing.')
)


