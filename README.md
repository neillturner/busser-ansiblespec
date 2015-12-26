# <a name="title"></a> Busser::RunnerPlugin::Ansiblespec

[![Gem Version](https://badge.fury.io/rb/busser-ansiblespec.png)](http://rubygems.org/gems/busser-ansiblespec)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/busser-ansiblespec?type=total&color=brightgreen)](https://rubygems.org/gems/busser-ansiblespec)
[![Build Status](https://travis-ci.org/neillturner/busser-ansiblespec.png)](https://travis-ci.org/neillturner/busser-ansiblespec)

A Busser runner plugin for Ansible.

By default this enables testing using the ansiblespec format. The serverspec tests are specified with the roles in the ansible repository.
* Multiple hosts and multiple roles can be tested.
* It also supports storing the spec tests in the spec directory and in test-kitchen style test/integration directory.
* Serverspec using ssh to communicate with the server to be tested.
* It reads the ansible playbook and inventory files to determine the hosts to test and the roles for each host.

```
     TEST KITCHEN              ANSIBLE AND SERVERSPEC                TOMCAT SERVER
     WORKSTATION               SERVER (built and destroyed      (created separately
     (or Jenkins CI)           automatically)                   could be docker container)
                             +----------------------------+
+-------------------+        |                            |      +-----------------------+
|   test kitchen    |        |                            |      |                       |
|   kitchen-ansible | create |                            |      |                       |
|                   | ser^er |                            |      |      +-----------+    |
|     CREATE    +------------>               +----------+ |      |      | tomcat    |    |
|                   |        |               |          | | install     |           |    |
|                   | install and run        | ansible  +--------------->           |    |
|     CONVERGE  +------------+--------------->          | | tomcat      +-----------+    |
|                   |        |               +----------+ |      |                       |
|                   | install|  +----------+  +---------+ |   test                       |
|     VERIFY    +--------------->busser-   |-->serverspec--------+---->                  |
|                   |and run |  |ansiblespec  |         | |      |                       |
|                   |        |  +----------+  +---------+ |      +-----------------------+
|     DESTROY   +------------>                            |
+-------------------+ delete +----------------------------+
                      server

                   * All connections over SSH

```

See [ansible-sample-tdd](https://github.com/volanja/ansible-sample-tdd)

## <a name="usage"></a> Usage

### Directory

In the ansible repository specify:

  * spec files with the roles.

  * spec_helper in the spec folder (with code as below).

  * test/integration/<suite>/ansiblespec containing config.yml and ssh private keys to access the servers.

See example [https://github.com/neillturner/ansible_repo](https://github.com/neillturner/ansible_repo)

```
.
+-- roles
¦   +-- mariadb
¦   ¦   +-- spec
¦   ¦   ¦   +-- mariadb_spec.rb
¦   ¦   +-- tasks
¦   ¦   ¦   +-- main.yml
¦   ¦   +-- templates
¦   ¦       +-- mariadb.repo
¦   +-- nginx
¦       +-- handlers
¦       ¦   +-- main.yml
¦       +-- spec
¦       ¦   +-- nginx_spec.rb
¦       +-- tasks
¦       ¦   +-- main.yml
¦       +-- templates
¦       ¦   +-- nginx.repo
¦       +-- vars
¦           +-- main.yml
+-- spec
    +-- spec_helper.rb
    +-- my_private_key.pem
+-- test
    +-- integration
        +-- default      # name of test-kitchen suite
            +-- ansiblespec
                +-- config.yml

```


## <a name="spec_helper"></a> spec_helper

```
require 'rubygems'
require 'bundler/setup'

require 'serverspec'
require 'pathname'
require 'net/ssh'

RSpec.configure do |config|
  set :host,  ENV['TARGET_HOST']
  # ssh options at http://net-ssh.github.io/ssh/v1/chapter-2.html
  #                https://net-ssh.github.io/ssh/v2/api/classes/Net/SSH/Config.html
  # change user from root if using ubuntu, vagrant etc
  # ssh via password
  set :ssh_options, :user => 'root', :paranoid => false, :verbose => :error, :password => ENV['LOGIN_PASSWORD'] if ENV['LOGIN_PASSWORD']
  # ssh via ssh key
  set :ssh_options, :user => 'root', :paranoid => false, :verbose => :error, :host_key => 'ssh-rsa', :keys => [ ENV['SSH_KEY'] ] if ENV['SSH_KEY']
  set :backend, :ssh
  set :request_pty, true
end
```

## <a name="config.yml"></a> config.yml

This goes in directory test/integration/default/ansiblespec  where default is the name of test-kitchen suite

```
---
-
  playbook: default.yml
  inventory: hosts
  kitchen_path: '/tmp/kitchen'
  pattern: 'ansiblespec'    # or spec or serverspec
  ssh_key: 'spec/my_private_key.pem'
  login_password: 'myrootpassword'
```

## <a name="Gemfile"></a> Gemfile

To add additionl ruby gems create a Gemfile in directory test/integration/default/ansiblespec

```
source 'https://rubygems.org'

gem 'rake'
```

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Original busser-serverspec created and maintained by [HIGUCHI Daisuke][author] (<d-higuchi@creationline.com>)

modified by [Neill Turner][author] (<neillwturner@gmail.com>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/neillturner
[issues]:           https://github.com/test-kitchen/busser-ansiblespec/issues
[license]:          https://github.com/test-kitchen/busser-ansiblespec/blob/master/LICENSE
[repo]:             https://github.com/test-kitchen/busser-ansiblespec
[plugin_usage]:     http://docs.kitchen-ci.org/busser/plugin-usage
