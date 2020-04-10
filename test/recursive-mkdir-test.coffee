{LocalStorage} = require('../')
fs = require('fs')
path = require('path')
semver = require('semver')
tape = require('tape')

tape('recursive mkdir', (test) =>
  non_existent_directory = path.resolve('./does_not_exist');
  test.notOk(fs.existsSync(non_existent_directory), 'directory does not exist');
  non_existent_subdirectory = path.resolve(path.join(non_existent_directory, 'desired_location'));
  test.notOk(fs.existsSync(non_existent_subdirectory), 'subdirectory does not exist');

  if semver.gte(process.version, '10.12.0')
    ls1 = new LocalStorage(non_existent_subdirectory);
    test.ok(fs.existsSync(non_existent_directory), 'directory now exists');
    test.ok(fs.existsSync(non_existent_subdirectory), 'subdirectory now exists');
    ls1._deleteLocation()
    test.notOk(fs.existsSync(non_existent_subdirectory), 'subdirectory has been removed');
    fs.rmdirSync(non_existent_directory)
    test.notOk(fs.existsSync(non_existent_directory), 'directory has been removed');
  else
    f = () ->
      ls1 = new LocalStorage()
    test.throws(f, 'node version '+process.version+' expected to fail on recursive directory creation')
  test.end()
)
