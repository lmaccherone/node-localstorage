fs = require('fs')
spawnSync = require('child_process').spawnSync
path = require('path')
_ = require('lodash')

isWindows = (process.platform.lastIndexOf('win') == 0)
runSync = (command) ->
  # Spawn things in a sub-shell so things like io redirection and gsutil work
  if isWindows
    shell = 'cmd.exe'
    args = ['/c', command]
  else
    shell = 'sh'
    args = ['-c', command]
  {status, stdout, stderr} = spawnSync(shell, args, {encoding: 'utf8'})
  if stderr?.length > 0 or status > 0
    console.error("Error running: '#{command}'\n#{stderr}\n#{stdout}\n")
    process.exit(status)
  else
    console.log("Output of running '#{command}'\n#{stdout}\n")
    return stdout

task('publish', 'Publish to npm and add git tags', () ->
  console.log('building and testing')
  process.chdir(__dirname)
  runSync('npm test')  # Doing this externally to make it synchronous
  console.log('checking git status --porcelain')
  stdout = runSync('git status --porcelain')
  if stdout.length > 0
    console.error('`git status --porcelain` was not clean. Not publishing.')
  else
    console.log('checking origin/master')
    stdout = runSync('git rev-parse origin/master')

    console.log('checking master')
    stdoutOrigin = stdout
    stdout = runSync('git rev-parse master')
    stdoutMaster = stdout

    if stdoutOrigin == stdoutMaster

      console.log('running npm publish')
      runSync('npm publish')

      console.log('creating git tag')
      runSync("git tag v#{require('./package.json').version}")
      runSync("git push --tags")
    else
      console.error('Origin and master out of sync. Not publishing.')
)


