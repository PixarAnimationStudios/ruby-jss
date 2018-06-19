# About the ruby-jss test suite

For years, I've attempted to use some ruby testing framework to automate testing of ruby-jss.

Every time I've run into walls because unit testing suites are designed for unit testing, and that's not really what we need to do.  Yes we need to test individual methods of classes and so on, but when working with a REST API, there's a lot of
scaffolding that needs to happen before tests can even start - and that scaffolding itself is testing the code. And the details of the scaffolding will vary in different environments.

For example, the tests *must* be very interactive from the start - you have to tell them what server to connect with, what credentials to use, and so on.

Once connected, objects have to be created before they can be listed, fetched, updated, or deleted - so test order matters.

Also, you need to be able to have later tests refer to the same objects you created in earlier tests. Once I've tested that I can create an object on the server and re-fetch it once, I shuold be able to use that object for all future tests without fetching every time.

Reading most tutorials about ruby testing just leads you in circles when you consider needs such as these.

Many propnents of unit testing might find this suite odd.  Thats ok. Any functional testing suite is better than none and I'm open to suggestions for improvement.

### Here's how to use it:

tldr:

  `/path/to/your/ruby-jss/gem/installation/test/bin/runtests --server myjss.company.com --user myjssusername`

Must be run on a mac, it uses your keychain to store credentials.

See below for the help output

### Here's how this thing works:

 - The tests are ultimatly MiniTest::Spec specifications, defined in files in the 'specs' folder.
   - See http://ruby-doc.org/stdlib-2.0.0/libdoc/minitest/rdoc/MiniTest.html
   - also, google around for help with minitest specs


 - They do NOT use minitest/autorun. Instead, the 'runtests' executable handles loading and running them
   - See below for the help output


 - The runtests command, via methods in the JSSTestHelper module, handles connecting to servers.
   - it takes options to define connection parameters.
     - At the moment they are limited to user, hostname and port, but will be expanded eventually
   - it prompts for passwords as needed
   - it must be run on a Mac! It stores connection parameters in your keychain.
   - it uses connection parameters from your keychain if they are present. meaning after the first use,
     it will connect to the same server as the same user with no commandline options.
   - If any commandline options are different from whats in the keychain, the keychain will be updated,
     prompting for new passwords if needed.


 - The runtest command will run the spec files listed on the command line, or all of them if none are listed.
 - The tests are run verbosely, so you can see what tests are being run.
 - Some tests are interactive - they will ask you to make choices about what's happening.

WARNING: **Be very careful about running these tests on your production JSS !!!**

These tests create and delete objects in the JSS. While they _shouldn't_ hurt any of the existing data - we cannot make any guarantees that they won't hurt something you care about.

As the license text for ruby-jss states:

```
    Unless required by applicable law or agreed to in writing, software
    distributed under the Apache License with the above modification is
    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the Apache License for the specific
    language governing permissions and limitations under the Apache License.
```

As a reminder, if you connect to the same server that's listed in your /etc/ruby-jss.conf, you'll be asked for confirmation before the tests are run.



 ### The Spec Files

 Each spec file defines one or more MiniTest::Spec, each one being a 'describe SomeClass' block, containing methods and individual tests in 'it' blocks.

 If you plan to write any tests, please read up on how to write MiniTest Specs.

However, here's some info that wasn't obvious when I first started, and makes life much easier when writing specs:

 - the 'describe' blocks eventually become classes
   - you can do anything inside them that you would do in a class definition.
 - the 'it' blocks become methods in the class defined by the 'describe' block.
 - the 'it' blocks are run one at a time, each in a separate instance of the class defined by the 'describe' block.
 - by default, the 'it' blocks are run in a random order. See below if you need them to run in the defined order.

 All of the above means that you can use constants, class methods, class-instance variables and instance methods in concert for passing things between the individual tests.

For examples of this, see the file 'patch_title_spec.rb' in the specs folder.

### Running tests in order

The individual spec files are run in the order given on the command line. If none are given on the command line, all files are run in alphabetical order.

If you define multiple 'describe' blocks in a file, they will be run in random order.

The individual tests in a describe block are also run in random order, by default.

If you need the tests to run in order within a 'describe' block, then define this class method somewhere inside it:

       def self.test_order
         :alpha
       end

The presence of that method will cause MiniTest to run them in the order defined.


### Help output from 'runtests -H'


```
   Usage: runtests [options] [spec [spec ...]]

   Runs one or more specification tests of ruby-jss.

   The specifications are files in the directory:
       /Users/chrisl/git/gemdev/ruby-jss/test/specs

   The files must have a _spec.rb suffix, however you need not use the suffix when
   listing tests to run on the command line, e.g. 'patch_source' will run
   'patch_source_spec.rb'

   If no specs files are listed on the command line, all will be run, in
   alphabetical order.

   By default, JSS connection settings are used from your /etc/ruby-jss.conf file
   and/or ~/.ruby-jss.conf. Connection settings from the command line will be used
   if provided.

   WARNING: These tests create, modify, and delete objects in the JSS.
     While no existing objects should be changed, * Be Careful * running them on
     a production server.
     If the server you're connecting to matches one defined in /etc/ruby-jss.conf
     you will be asked for confirmation before proceding.

   The first time you connect from this machine to a given server, you must provide
   a username for the connection with --user, and will be prompted for the password.
   Once authenticated, credentials for the server are saved in your keychain, and
   future connections to that server will read the user & password from there.
   If a different user is later specified for that server, you'll be prompted again
   for a password, and the keychain will be updated.

   Options
     --server, -s <host>         the hostname for the JSS API connection
     --port, -p <port>           the port for the API connection
     --user, -u <user>           the API username for the connection
                                   NOTE: must have permissions to perform the tests!
     --db-server, -S <host>      the hostname for the JSS API connection
     --db-port, -P <port>        the port for the API connectino
     --db-user, -U <user>        the API username for the connection
     --gem-dir, -g, -i <path>    the path from which to require ruby-jss
                                   (sets GEM_HOME to this path before requiring)
     --help, -h, -H              show this help
```
