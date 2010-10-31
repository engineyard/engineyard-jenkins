# Easier to do CI than not to.

Run your continuous integration (CI) tests against your Engine Yard AppCloud environments - the exact same configuration you are using in production!

You're developing on OS X or Windows, deploying to Engine Yard AppCloud (Gentoo/Linux), and you're running your CI on your local machine or a spare Ubuntu machine in the corner of the office, or ... you're not running CI at all?

It's a nightmare. It was for me. [Hudson CI](http://hudson-ci.org/), `engineyard-hudson` and the [hudson](http://github.com/cowboyd/hudson.rb) CLI projects now make CI easier to do than not to. A few commands and your Rails applications' tests are automatically running, no additional setup, and its the same environment you are deploying your Rails applications (Engine Yard AppCloud). Sweet.

## Installation

    gem install engineyard-hudson

## Assumptions

It is assumed you are familiar with the `engineyard` CLI gem.

You **do not** need to be familiar with custom chef recipes. Just follow the simple commands. Easy peasy.

## Warning

In the very first release of `engineyard-hudson`:

* there is no support for authentication/authorization of Hudson CI.
* git URLs are converted to public `git://` urls on Hudson; until deploy key support is added

## Hosting Hudson CI on Engine Yard AppCloud

Instructions *coming soon*.

Hosting Hudson CI on Engine Yard AppCloud is optional. It can be hosted anywhere. You need the following information about your Hudson CI:

* Hudson CI host (& port)
* Hudson CI's user's public key (probably at /home/hudson/.ssh/id_rsa.pub)
* Hudson CI's user's private key path (probably /home/hudson/.ssh/id_rsa)

## Running your tests in Hudson against Engine Yard AppCloud

After a couple manual steps, you will have your applications tests running.

    $ cd /my/project
    $ ey-hudson install .
    
    Finally:
    * edit cookbooks/hudson_slave/attributes/default.rb as necessary.
    * run: ey recipes upload # use --environment(-e) & --account(-c)
    * run: ey recipes apply  #   to select environment
    * Boot your environment if not already booted.

Done! Either visit your Hudson CI site or use `hudson list` to see the status of your projects being tested.

## Automatically triggering job builds

In Hudson CI, a "job" is one of your projects. Each time it runs your tests, it is called a "build".

It is often desirable to have your SCM trigger Hudson CI to run your job build whenever you push new code.

### GitHub Service Hooks

* Go to the "Admin" section of your GitHub project
* Click "Service Hooks"
* Click "Post-Receive URLs"
* Enter the URL `http://HUDSON-CI-URL/job/APP-NAME/build`
* Click "Update Settings"

You can also use the "Test Hook" link to test this is wired up correctly.

### CLI

Using the `hudson` CLI:

    hudson build APP-NAME

### Curl

You are triggering the build via a GET call to an URL endpoint. So you can also use `curl`:

    curl http://HUDSON-CI-URL/job/APP-NAME/build
