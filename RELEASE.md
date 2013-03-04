Releasing a New Version
=======================

This document describes how to release a new version of KATT Blueprint Parser.

  1. **Update `CHANGELOG`**

     Go through all commits since the last release and mention changes that
     affect users or big internal changes in `CHANGELOG`. Small internal changes
     or bugfixes can be grouped under item like "Various code improvements and
     fixes". Use your best judgment to decide into which category each change
     belongs to. Formatting of the new entry should follow the style used in
     previous entries.

     Commit the change in a commit with message "Update CHANGELOG". Do not push
     this commit yet.

  2. **Update version**

     Look at `VERSION` for the current version. Grep for it in the code and
     replace all relevant occurrences (which are usually all occurrences beyond
     the one in `CHANGELOG`) with the new version.

     What the new version should be is determined by the set of changes since
     the last release. The parser uses [semantic
     versioning](http://semver.org/).

     Commit the change in a commit with message "Update version to <version>",
     where `<version>` is the new version. Do not push this commit yet.

  3. **Publish the npm package**

     Run `npm publish .` in the parser root directory. This will create a new
     version of the npm package and publish it, if tests pass.

  4. **Test the published npm package**

     Create a testing project somewhere on the side, install the just released
     npm package into it and make sure it works. Requiring the parser and trying
     it on some simple input is enough.

     If the parser doesn't work, find the cause, fix it and then republish the
     npm package. Repeat this until the parser works.

  5. **Tag the release**

     Tag the release by running `git tag v<version>`, where `<version>` is the
     released version. Push the accumulated commits from previous steps together
     with the tag by running `git push --tags`.
