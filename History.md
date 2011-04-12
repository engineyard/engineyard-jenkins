# History

## 0.3.2 - 2011-3-3

* remove dependency on ruby-debug

## 0.3.1 - 2010-12-1

* install_server
  * Updates the default host for `jenkins` CLI to newly created server
  * Explicitly set $HOME/$USER so Jenkins/Java has access to .gitconfig

## 0.3.0 - 2010-11-24

* Renamed task 'server' => 'install_server'
* install_server does the complete job of setup/installation of Jenkins into an environment on AppCloud
* install_server can take --environment/--account options OR auto-discover which environment to install Jenkins into


## 0.2.0 - 2010-10-30

* Initial 'server' task implementation

## 0.1.0 - 2010-10-30

* Initial 'ey-jenkins install .' command
* 'ey-jenkins server' shows 'Coming soon'
