# <a name="title"></a> Busser::RunnerPlugin::Ansiblespec

[![Gem Version](https://badge.fury.io/rb/busser-ansiblespec.png)](http://rubygems.org/gems/busser-ansiblespec)
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/busser-ansiblespec?type=total&color=brightgreen)](https://rubygems.org/gems/busser-ansiblespec)

A Busser runner plugin for Ansible.

By default this enables testing using the ansiblespec format. The serverspec tests are specified with the roles in the ansible repository.
* Multiple hosts and multiple roles can be tested.
* It also supports storing the spec tests in the spec directory and in test-kitchen style test/integration directory.
* Serverspec using ssh to communicate with the server to be tested.
* It reads the ansible playbook and inventory files to determine the hosts to test and the roles for each host.


See [ansible-sample-tdd](https://github.com/volanja/ansible-sample-tdd)

## <a name="usage"></a> Usage

### Directory

In the ansible repository specify:

the spec files with the roles.

the spec_helper in the spec folder and a dummy test/integration folder.

a dummy test/integration/<suite>/ansiblespec/localhost/<suite>_spec.rb containing just a dummy comment.

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
+-- test
    +-- integration
        +-- default      # name of test-kitchen suite
            +-- ansiblespec
                +-- localhost
                    +-- default_spec.rb   # <suite>_spec.rb
```


## <a name="spec_helper"></a> spec_helper

```
require 'rubygems'
require 'bundler/setup'

require 'serverspec'
require 'pathname'
require 'net/ssh'

ENV['KITCHEN_PATH'] = '/tmp/kitchen'
ENV['PLAYBOOK'] = 'default.yml'
ENV['INVENTORY'] = 'hosts'
ENV['PATTERN'] = 'ansiblespec' # can 'spec' and 'serverspec'
ENV['SSH_KEY'] =  '/tmp/kitchen/spec/my_private_ssh_key.pem'
ENV['LOGIN_PASSWORD'] = 'myrootpassword'

RSpec.configure do |config|
  set :host,  ENV['TARGET_HOST']
  # ssh via password
  #set :ssh_options, :user => 'root', :password] = ENV['LOGIN_PASSWORD']
  # ssh via ssh key
  set :ssh_options, :user => 'root', :host_key => 'ssh-rsa', :keys => [ ENV['SSH_KEY'] ]
  set :backend, :ssh
  set :request_pty, true
end
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
