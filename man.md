# phper CLI commands
<div>
<a href='#commands_create'/>create</a>&nbsp;
<a href='#commands_db:init'/>db:init</a>&nbsp;
<a href='#commands_deploy'/>deploy</a>&nbsp;
<a href='#commands_destroy'/>destroy</a>&nbsp;
<a href='#commands_files'/>files</a>&nbsp;
<a href='#commands_files:dump'/>files:dump</a>&nbsp;
<a href='#commands_files:get'/>files:get</a>&nbsp;
<a href='#commands_files:modified'/>files:modified</a>&nbsp;
<a href='#commands_files:modified:get'/>files:modified:get</a>&nbsp;
<a href='#commands_help'/>help</a>&nbsp;
<a href='#commands_hosts'/>hosts</a>&nbsp;
<a href='#commands_info'/>info</a>&nbsp;
<a href='#commands_keys'/>keys</a>&nbsp;
<a href='#commands_keys:add'/>keys:add</a>&nbsp;
<a href='#commands_keys:clear'/>keys:clear</a>&nbsp;
<a href='#commands_keys:remove'/>keys:remove</a>&nbsp;
<a href='#commands_list'/>list</a>&nbsp;
<a href='#commands_login'/>login</a>&nbsp;
<a href='#commands_logout'/>logout</a>&nbsp;
<a href='#commands_logs'/>logs</a>&nbsp;
<a href='#commands_logs:tail'/>logs:tail</a>&nbsp;
<a href='#commands_open'/>open</a>&nbsp;
<a href='#commands_servers'/>servers</a>&nbsp;
<a href='#commands_servers:add'/>servers:add</a>&nbsp;
<a href='#commands_servers:remove'/>servers:remove</a>&nbsp;
<a href='#commands_versions'/>versions</a>&nbsp;
<a href='#commands_versions:set'/>versions:set</a>&nbsp;
</div>
<a name='commands_create'/>
## create

    Summery: craete project
    Usage: phper [options] create [<name>]
<a name='commands_db:init'/>
## db:init

    Summery: Initialize project database.
    Usage: phper [options] db:init 
            --project=PROJECT            project
<a name='commands_deploy'/>
## deploy

    Summery: Deploy project
    Usage: phper [options] deploy 
            --project=PROJECT            project
<a name='commands_destroy'/>
## destroy

    Summery: destroy project
    Usage: phper [options] destroy command [--project=<project>]
        -y, --yes                        answer yes for all questions
            --project=PROJECT            project
<a name='commands_files'/>
## files

    Summery: list project files
    Usage: phper [options] files command [--project=<project>]
        -h, --host=HOST                  host
            --project=PROJECT            project
<a name='commands_files:dump'/>
## files:dump

    Summery: dump file.
    Usage: phper [options] files:dump <filename> [--project=<project>]
        -h, --host=HOST                  host
            --project=PROJECT            project
<a name='commands_files:get'/>
## files:get

    Summery: get and put file.
    Usage: phper [options] files:get <filename> [--project=<project>]
        -h, --host=HOST                  host
            --project=PROJECT            project
<a name='commands_files:modified'/>
## files:modified

    Summery: list modified files since last deploy.
    Usage: phper [options] files:modified command [--project=<project>]
        -h, --host=HOST                  host
            --project=PROJECT            project
<a name='commands_files:modified:get'/>
## files:modified:get

    Summery: get modified files since last deploy.
    Usage: phper [options] files:modified:get command [--project=<project>]
        -h, --host=HOST                  host
            --project=PROJECT            project
<a name='commands_help'/>
## help

    Summery: Show command helps.
    Usage: phper [options] help command
<a name='commands_hosts'/>
## hosts

    Summery: list project hosts
    Usage: phper [options] hosts command [--project=<project>]
            --project=PROJECT            project
<a name='commands_info'/>
## info

    Summery: show project info
    Usage: phper [options] info command [--project=<project>]
            --project=PROJECT            project
<a name='commands_keys'/>
## keys

    Summery: list keys
    Usage: phper [options] keys 
<a name='commands_keys:add'/>
## keys:add

    Summery: add keys
    Usage: phper [options] keys:add <public key file>
<a name='commands_keys:clear'/>
## keys:clear

    Summery: remove all keys
    Usage: phper [options] keys:clear 
<a name='commands_keys:remove'/>
## keys:remove

    Summery: remove key
    Usage: phper [options] keys:remove <user@host>
<a name='commands_list'/>
## list

    Summery: get project list
    Usage: phper [options] list 
<a name='commands_login'/>
## login

    Summery: Login to phper.jp.
    Usage: phper [options] login 
<a name='commands_logout'/>
## logout

    Summery: Logout from phper.jp .
    Usage: phper [options] logout 
<a name='commands_logs'/>
## logs

    Summery: list logs
    Usage: phper [options] logs  [--project=<project>]
            --project=PROJECT            project
<a name='commands_logs:tail'/>
## logs:tail

    Summery: list logs
    Usage: phper [options] logs:tail command [--project=<project>]
        -s, --server=SERVER              server
        -n, --name=NAME                  log name
            --project=PROJECT            project
<a name='commands_open'/>
## open

    Summery: Open URL
    Usage: phper [options] open [<host or name pattern>]
            --project=PROJECT            project
<a name='commands_servers'/>
## servers

    Summery: list servers
    Usage: phper [options] servers command [--project=<project>]
            --project=PROJECT            project
<a name='commands_servers:add'/>
## servers:add

    Summery: add server
    Usage: phper [options] servers:add [<host>]
            --name=NAME                  Name of this server
            --root=ROOT                  Document Root
            --project=PROJECT            project
<a name='commands_servers:remove'/>
## servers:remove

    Summery: remove server
    Usage: phper [options] servers:remove [<host or name>]
            --project=PROJECT            project
<a name='commands_versions'/>
## versions

    Summery: list available versions
    Usage: phper [options] versions command [--project=<project>]
            --project=PROJECT            project
<a name='commands_versions:set'/>
## versions:set

    Summery: set versions
    Usage: phper [options] versions:set <ver> [--project=<project>]
            --project=PROJECT            project
