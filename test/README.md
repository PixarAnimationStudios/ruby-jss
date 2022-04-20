# About the ruby-jss test suite

### Why not use Minitest, or Rspec or some other testing library

For years, I've attempted to use some ruby testing framework to automate testing of ruby-jss.

Every time I've run into walls of frustration because testing suites are designed for unit testing, and that's not really what we need to do. Yes we need to test individual methods of classes and so on, but when working with a REST API, there's a lot of scaffolding that needs to happen before tests can even start - and that scaffolding itself is testing the code. And the details of the scaffolding will vary in different environments. We need integration tests, not unit tests.

For example, the tests *must* be very interactive from the start - you have to tell them what server to connect with, what credentials to use, and so on.

Once connected, objects have to be created before they can be listed, fetched, updated, or deleted - so test order matters.

Also, you need to be able to have later tests refer to the same objects you created in earlier tests. Once I've tested that I can create an object on the server, I need to test re-fetching it -  I should be able to use that object for all future tests without fetching every time, much less re-creating it every time!

Reading most tutorials about ruby testing has lead me in circles considering needs such as these. The amount of time I've wasted over the past decade trying to do the 'right' thing is huge, and I've always gone back to pasting code into `irb` as the more efficient way to test code as it will actually appear in my apps and tools.

Many proponents of unit testing might disagree and find this suite odd.  Thats ok. Any functional testing suite is better than none.

This [comment from StackOverflow](https://stackoverflow.com/questions/8752654/how-do-i-effectively-force-minitest-to-run-my-tests-in-order) sums it up:

> Note that, as of minitest 5.10.1, the i_suck_and_my_tests_are_order_dependent! method/directive is completely nonfunctional in test suites using MiniTest::Spec syntax. The Minitest.test_order method is apparently not being called at all.
EDIT: This has been a known issue since Minitest 5.3.4: see seattlerb/minitest#514 for the blow-by-blow wailing and preening.
You and I aren't the ones who "suck". What's needed is a BDD specification tool for Ruby without the bloat of RSpec and without the frat-boy attitude and contempt for wider community practices of MiniTest. Does anyone have any pointers?


Since I've always done manual testing by pasting code into an IRB session, all I really want is a more automated way to do exactly that. Given that I already have all these files with pastable 'tests' for IRB,  why not just write an app-ish wrapper for them?

Thats what I've done, avoiding the overhead (and attitude) of dealing with setting up a full test library that doesn't really do what I want and, TBH, I just don't have time for.

With these tests, I perform some tasks, validate some data, and if anything fails, it does so just like any ruby program would, via a raised exception with a printed backtrace to locate it.


### Here's how to use it:

tldr:

  `/path/to/your/ruby-jss/gem/installation/test/bin/runtests --host myjss.company.com`


**IMPORTANT:** It must be run on a Mac from a Finder session: it uses your keychain to store connection data and credentials, so you only have to provide them the first time or when changing them.(Don't have access to a Mac? Why are you using ruby-jss and Jamf Pro?)

Want to test with a different version of ruby? Change the #! line of the `runtests` executable, or change your environment so that `/usr/bin/env ruby` points to the one you want.

### Here's how this thing works

[ Work In Progress ]

 - The individual tests are methods in classes defined in files in the 'tests' directory adjacent to this file.
 - In general, each class test a matching ruby-jss class, usually an APIObject (classic) or JPAPIResource (jamf pro).

**WARNING**: **DANGER DANGER** Be very careful about running these tests on your production Jamf Pro server!!!

These tests create and delete objects in the JSS. While they _shouldn't_ hurt any of the existing data - no guarantees are made that they won't hurt something you care about.

As the license text for ruby-jss states, ruby-jss is...

```
    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.
```

As a reminder, if you connect to the same server that's listed in your /etc/ruby-jss.conf, you'll be asked for confirmation before the tests are run.
