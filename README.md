
## MongoDb Info

[![Travis](https://api.travis-ci.org/arzzen/mongodb-info.svg?branch=master)](https://travis-ci.org/arzzen/mongodb-info) 

> `mongodb-info` is a simple and efficient way to access stats in command line.

## Table of Contents

[**Screenshots**](#screenshots)

[**Installation**](#installation)
* [**Unix OS**](#unix-like-os)
* [**OS X**](#os-x-homebrew)
* [**Windows**](#windows-cygwin)

[**Usage**](#usage)
* [**Tests**](#tests)

[**System requirements**](#system-requirements)
* [**Dependences**](#dependences)

[**Contribution**](#contribution)

[**License**](#licensing)


## Screenshots

![screenshot from 2018-05-15 19-55-16](https://user-images.githubusercontent.com/6382002/40074461-f8f6adb0-5879-11e8-865d-7a6b3168f022.png)


## Usage

```bash
# overall stats
./mongodb-info -s '127.7.0.1/dbname'dbname'
# or with collection name
./mongodb-info -s '127.7.0.1/dbname' -c 'collection_name'
```

## Installation

#### Unix like OS

```bash
git clone https://github.com/arzzen/mongodb-info.git && cd mongodb-info
sudo make install
```

For uninstalling, open up the cloned directory and run

```bash
sudo make uninstall
```

For update/reinstall

```bash
sudo make reinstall
```

#### OS X (homebrew)

@todo

#### Windows (cygwin)

@todo

## System requirements

* Unix like OS with a proper shell
* Tools we use: cat ; printf ; shift ; awk ; sed ; tr ; echo ; grep ; cut ; sort ; head ; tail.

#### Dependences

* [mongo](https://docs.mongodb.com/manual/administration/install-on-linux/), [jq](https://stedolan.github.io/jq/download/)

## Contribution 

Want to contribute? Great! First, read this page.

#### Code reviews
All submissions, including submissions by project members, require review. 
We use Github pull requests for this purpose.

#### Some tips for good pull requests:
* Use our code
  When in doubt, try to stay true to the existing code of the project.
* Write a descriptive commit message. What problem are you solving and what
  are the consequences? Where and what did you test? Some good tips:
  [here](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)
  and [here](https://www.kernel.org/doc/Documentation/SubmittingPatches).
* If your PR consists of multiple commits which are successive improvements /
  fixes to your first commit, consider squashing them into a single commit
  (`git rebase -i`) such that your PR is a single commit on top of the current
  HEAD. This make reviewing the code so much easier, and our history more
  readable.

#### Formatting

This documentation is written using standard [markdown syntax](https://help.github.com/articles/markdown-basics/). Please submit your changes using the same syntax.

#### Tests

[![codecov](https://codecov.io/gh/arzzen/mongodb-info/branch/master/graph/badge.svg)](https://codecov.io/gh/arzzen/mongodb-info)

```bash
make test
```

## Licensing
MIT see [LICENSE][] for the full license text.

   [read this page]: http://github.com/arzzen/mongodb-info/blob/master/docs/CONTRIBUTING.md
   [landing page]: http://arzzen.github.io/mongodb-info
   [LICENSE]: https://github.com/arzzen/mongodb-info/blob/master/LICENSE

