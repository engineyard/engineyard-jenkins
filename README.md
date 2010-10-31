# Easier to do CI than not to.

Run your continuous integration (CI) tests against your Engine Yard AppCloud environments - the exact same configuration you are using in production!

You're developing on OS X or Windows, deploying to Engine Yard AppCloud (Gentoo/Linux), and you're running your CI on your local machine or a spare Ubuntu machine in the corner of the office, or ... you're not running CI at all?

It's a nightmare. It was for me. [Hudson CI](http://hudson-ci.org/), `engineyard-hudson` and the [hudson](http://github.com/cowboyd/hudson.rb) CLI projects now make CI easier to do than not to. A few commands and your Rails applications' tests are automatically running, no additional setup, and its the same environment you are deploying your Rails applications (Engine Yard AppCloud). Sweet.

## Installation

    gem install engineyard-hudson

You might also like the `hudson` CLI to play with your Hudson CI from the command line:

    gem install hudson

## Assumptions

It is assumed you are familiar with the [engineyard](http://github.com/engineyard/engineyard) CLI gem.

You **do not** need to be familiar with custom chef recipes. Just follow the simple commands. Easy peasy.

## Warning (aka TODO list)

In the very first release of `engineyard-hudson`:

* there is no support for authentication/authorization of Hudson CI.
* git URLs are converted to public `git://` urls on Hudson; until deploy key support is added
* no mail server configured for Hudson CI build failure notifications

That is, its really only useful - at this very "alpha" instant in time - to Open Source Rails projects. But that's just me being brutally honest.

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

Do those steps and you're done! Now, you either visit your Hudson CI site or use `hudson list` to see the status of your projects being tested.

## Automatically triggering job builds

In Hudson CI, a "job" is one of your projects. Each time it runs your tests, it is called a "build".

It is often desirable to have your SCM trigger Hudson CI to run your job build whenever you push new code.

### GitHub Service Hooks

* Go to the "Admin" section of your GitHub project
* Click "Service Hooks"
* Click "Post-Receive URLs"
* Enter the URL `http://HUDSON-CI-URL/job/APP-NAME/build`
* Click "Update Settings"

And here's a picture.

<img src="http://img.skitch.com/20101031-d5wrc7hysrahihqr9k53xgxi1t.png" style="width: 100%;">

You can also use the "Test Hook" link to test this is wired up correctly.

### CLI

Using the `hudson` CLI:

    hudson build APP-NAME

### Curl

You are triggering the build via a GET call to an URL endpoint. So you can also use `curl`:

    curl http://HUDSON-CI-URL/job/APP-NAME/build

## Contributions

* Dr Nic Williams
* Bo Jeanes - initial chef recipes for Hudson server + slave

## License

Copyright (c) 2010 Dr Nic Williams, Engine Yard

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.