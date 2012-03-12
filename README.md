phper
=====

A CLI utility for PHPer.jp.

PHPer.jp is a Platform as a Service of PHP.

Requirements
------------

* Ruby 1.8.7 or later
* git


Install
-------

`gem install phper`


Usage
-----

    phper [options] <commands> [<command options>] args...
        --version                    show version
        --help                       show this message
        --debug                      debug mode

### Commands:

* help
* login
* logout
* list
* create
* destroy
* info
* keys
* keys:add
* keys:remove
* keys:clear
* servers
* servers:add
* servers:remove
* open
* db:init
* deploy
* hosts
* files
* files:get
* files:modified
* files:modified:get

Contributing to phper
---------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011-2012 Yoshihiro TAKAHARA. See LICENSE.txt for further details.

[![endorse](http://api.coderwall.com/tumf/endorsecount.png)](http://coderwall.com/tumf)

