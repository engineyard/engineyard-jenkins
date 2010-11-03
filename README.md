# Easier to do CI than not to.

Run your continuous integration (CI) tests against your Engine Yard AppCloud environments - the exact same configuration you are using in production!

You're developing on OS X or Windows, deploying to Engine Yard AppCloud (Gentoo/Linux), and you're running your CI on your local machine or a spare Ubuntu machine in the corner of the office, or ... you're not running CI at all?

It's a nightmare. It was for me. [Hudson CI](http://hudson-ci.org/), the [hudson](http://github.com/cowboyd/hudson.rb) CLI project, and **engineyard-hudson** now make CI easier to do than not to. A few quick commands and your Rails applications' tests are automatically running, no additional setup, and its the same environment you are deploying your Rails applications (Engine Yard AppCloud). Sweet.

## Installation

    gem install engineyard-hudson

You might also like the `hudson` CLI to play with your Hudson CI from the command line:

    gem install hudson

## Assumptions

It is assumed you are familiar with the [engineyard](http://github.com/engineyard/engineyard) CLI gem.

You **do not** need to be familiar with custom chef recipes. Just follow the simple commands. Easy peasy.

## Warning (aka TODO list)

In the very first release of `engineyard-hudson`:

* There is no support for authentication/authorization of Hudson CI. It _will_ use the deploy keys already installed on your AppCloud instance, as described in engineyard-serverside [#set_up_git_ssh](http://github.com/engineyard/engineyard-serverside/blob/master/lib/engineyard-serverside/strategies/git.rb#L106-134)
* No mail server configured for Hudson CI build failure notifications.

That is, its really only useful - at this very "alpha" instant in time - to Open Source Rails projects. But that's just me being brutally honest.

## Hosting Hudson CI

Hosting Hudson CI on Engine Yard AppCloud is optional; yet delightfully simple. Hudson CI can be hosted anywhere.

### Hosting on Engine Yard AppCloud

Using Engine Yard AppCloud "Quick Start" wizard, create an application with Git Repo `git://github.com/drnic/ci_demo_app.git` (any arbitrary rails/rack application). Name the environment "hudson" (or similar) and boot it as a Single instance (or Custom cluster with a single instance).

Just a few steps and you will have your own Hudson CI:

    $ mkdir hudson_server
    $ cd hudson_server
    $ ey-hudson server . --plugins 'googleanalytics,chucknorris'
    $ ey recipes upload -e hudson
    $ ey recipes apply -e hudson

For the Hudson slaves' configuration, you'll need:

* the `hudson` instance public key:

    $ ey ssh -e hudson
    $ cat /home/deploy/.ssh/id_rsa.pub

* the `hudson` instance URI:

    $ sudo ruby -rubygems -e "require 'json'; puts JSON.parse(File.read('/etc/chef/dna.json'))['engineyard']['environment']['instances'].first['public_hostname']"


Do those steps, copy down the configuration and you're done! Now, you either visit your Hudson CI site or use `hudson list` to see the status of your projects being tested.

### Hosting elsewhere

You need the following information about your Hudson CI:

* Hudson CI public host (& port)
* Hudson CI's user's public key (probably at /home/hudson/.ssh/id_rsa.pub)
* Hudson CI's user's private key path (probably /home/hudson/.ssh/id_rsa)

## Running your tests in Hudson against Engine Yard AppCloud

This is the exciting part - ensuring that your CI tests are being run in the same environment as your production applications. In this case, on Engine Yard AppCloud.

Just a few steps and you will have your applications' tests running.

    $ cd /my/project
    $ ey-hudson install .
    
    Finally:
    * edit cookbooks/hudson_slave/attributes/default.rb as necessary.
    * run: ey recipes upload # use --environment(-e) & --account(-c)
    * run: ey recipes apply  #   to select environment
    * Boot your environment if not already booted.

Do those steps and you're done! Now, you either visit your Hudson CI site or use `hudson list` to see the status of your projects being tested.

### Conventions/Requirements

* Do not use your production environment as your Hudson CI slave. There are no guarantees what will happen. I expect bad things.
* You must name your CI environment with a suffix of `_ci` or `_hudson_slave`.
* You should not name any other environments with a suffix of `_ci` or `_hudson_slave`; lest they offer themselves to your Hudson CI as slave nodes.
* Keep your production and CI environments exactly the same. Use the same Ruby implementation/version, same database, and include the same RubyGems and Unix packages. Why? This is the entire point of the exercise: to run your CI tests in the same environment as your production application runs.

For example, note the naming convention of the two CI environments below (one ends in `_hudson_slave` and the other `_ci`).

<img src="http://img.skitch.com/20101031-dxnk7hbn32yce9rum1ctwjwt1w.png" style="width: 100%">

### What happens?

When you boot your Engine Yard AppCloud CI environments, each resulting EC2 instance executes a special "hudson_slave" recipe (see `cookbooks/hudson_slave/recipes/default.rb` in your project). This does three things:

* Adds this instance to your Hudson CI server as a slave
* Adds each Rails/Rack application for the AppCloud environment into your Hudson CI as a "job".
* Commences the first build of any newly added job.

If your CI instances have already been booted and you re-apply the recipes over and over (`ey recipes apply`), nothing good or bad will happen. The instances will stay registered as slaves and the applications will stay registered as Hudson CI jobs.

If a new application is on the instance, then a new job will be created on Hudson CI.

To delete a job from Hudson CI, you should also delete it from your AppCloud CI environment to ensure it isn't re-added the next time you re-apply or re-build or terminate/boot your CI environment. (To delete a job, use the Hudson CI UI or `hudson remove APP-NAME` from the CLI.)

In essence, to add new Rails/Rack applications into your Hudson CI server you:

* Add them to one of your Engine Yard AppCloud CI environments (the one that matches the production environment where the application will be hosted)
* Rebuild the environment or re-apply the custom recipes (`ey recipes apply`)

### Applications are run in their respective CI environment

Thusly demonstrated below: the application/job "ci_demo_app" is in the middle of a build on its target slave "ci_demo_app_ci". See the AppCloud UI example above to see the relationship between the application/job names and the environment/slave names.

<img src="http://img.skitch.com/20101031-tga2f23wems1acpad1ua41qdmb.png" style="width: 100%">

### Can I add applications/jobs to Hudson CI other ways?

Yes. There are three simple ways to get Hudson CI to run tests for your application ("create a job to run builds"). Above is the first: all "applications" on the Engine Yard AppCloud CI environment will automatically become Hudson CI jobs. The alternates are:

* Use the `hudson create .` command from the [hudson](http://github.com/cowboyd/hudson.rb) CLI. 

Pass the `--assigned_node xyz` flag to make the project's test be executed on a specific slave node. "xyz" is the name of another application on your AppCloud account; your tests will be executed on the same instance, with the same version of Ruby etc.

* Use the Hudson CI UI to create a new job. As above, you can make sure the tests are run on a specific Engine Yard AppCloud instance by setting the assigned node label to be the same as another AppCloud application in your account that is being tested.

Specifically, Hudson CI uses "labels" to match jobs to slaves. A common example usage is to label a Windows slave as "windows". A job could then be restricted to only running on slaves with label "windows". We are using this same mechanism.

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

    hudson build path/to/APP-NAME

### Curl

You are triggering the build via a GET call to an URL endpoint. So you can also use `curl`:

    curl http://HUDSON-CI-URL/job/APP-NAME/build

## Contributions

* Dr Nic Williams ([drnic](http://github.com/drnic))
* Bodaniel Jeanes ([bjeanes](http://github.com/bjeanes)) - initial chef recipes for [Hudson server + slave](http://github.com/bjeanes/ey-cloud-recipes)

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