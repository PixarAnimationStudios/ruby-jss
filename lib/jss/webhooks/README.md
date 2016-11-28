
# WebHooks for ruby-jss

- [Introduction](#introduction)
- [The Framework](#the-framework)
  - [Event Handlers](#event-handlers)
    - [Internal Handlers](#internal-handlers)
    - [External Handlers](#external-handlers)
  - [Putting it together](#putting-it-together)
  - [Events and Event objects](#events-and-event-objects)
- [The Server](#the-server)
- [Installing JSSWebHooks into ruby-jss](#installing-jsswebhooks-into-ruby-jss)
- [TODOs](#todos)

 <!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:0 orderedList:0 -->


<!-- /TOC -->

## Introduction

JSSWebHooks is a sub-module of ruby-jss which implements both a framework for
working with JSS Webhook events, and a simple http server, based on Sinatra and
Webrick, for handling those events.

You do not need to be a Ruby programmer to make use of this framework! "Event Handlers"
can be written in any language and used by the web server included with the module.
See _Event Handlers_ and _The Server_  below for more info.

JSSWebHooks is still in early development. While the basics seem to work,
there's much to do before it can be released in the ruby-jss gem.

For details about the JSS Webhooks API, and the JSON data it passes, please see
[Bryson Tyrrell's excellent
documentation.](https://unofficial-jss-api-docs.atlassian.net/wiki/display/JRA/Webhooks+API)

**Note:** when creating WebHooks in your JSS to be handled by the framework, you must
specify JSON in the 'Content Type' section. This framework doesn't support XML
formated WebHook data.

## The Framework

The JSSWebHooks framework abstracts WebHook events and their parts as Ruby
classes. When the JSON payload of a JSS WebHook POST request is passed into the
`JSSWebHooks::Event.parse_event` method, an instance of the appropriate subclass
of `JSSWebHooks::Event` is returned, for example
`JSSWebHooks::ComputerInventoryCompletedEvent`

Each event instance contains these important attributes:

* **webhook:** A read-only instance of `JSSWebHook::Event::WebHook`
  representing the WebHook stored in the JSS which cause the POST request. This
  object has attributes matching those in the "webhook" dict. of the POSTed
  JSON.

* **event_object:** A read-only instance of a `JSSWebHook::EventObject::<Class>`
  representing the 'event object' that accompanies the event that triggered the
  WebHook. It comes from the 'object' dict of the POSTed JSON, and different
  events come with different objects attached. For example, the
  ComputerInventoryCompleted event comes with a "computer" object, containing
  data about the JSS computer that completed inventory.

  This is not full `JSS::Computer` instance from the REST API, but rather a group
  of named attributes about that computer. At the moment the JSSWebHooks
  framework makes no attempt to use the event object to create a `JSS::Computer`
  instance but the handlers written for the event could easily do so if needed.

* **event_json:** The JSON content from the POST request, parsed into
  a Ruby hash with symbolized keys (meaning the JSON key "deviceName" becomes
  the symbol :deviceName)

* **raw_json:** A String containing the raw JSON from the POST
  request.

* **handlers:** An Array of custom plugins for working with the
  event. See _Event Handlers_, below.


### Event Handlers

A handler is a file containing code to run when a webhook event occurs. These
files are located in a specified directory, /Library/Application
Support/JSSWebHooks/ by default, and are loaded at runtime. It's up to the Casper
administrator to create these handlers to perform desired tasks. Each class of
event can have as many handlers as desired, all will be executed when the event's
`handle` method is called.

Handler files must begin with the name of the event they handle, e.g.
ComputerAdded, followed by: nothing, a dot, a dash, or an underscore. Hander
filenames are case-insensitive.

All of these filenames work as handlers for ComputerAdded events:

- ComputerAdded
- computeradded.sh
- COMPUTERAdded_notify_team
- Computeradded-update-ldap

There are two kinds of handlers:

#### Internal Handlers

These handlers are _non-executable_ files containing Ruby code. The code is
loaded at runtime and executed in the context of the JSSWebHooks Framework when
called by an event.

Internal handlers must be defined as a [ruby code block](http://rubylearning.com/satishtalim/ruby_blocks.html) passed to the
`JSSWebHooks.event_handler` method. The block must take one parameter, the
JSSWebHooks::Event subclass instance being handled. Here's a simple example of
a handler for a JSSWebHooks::ComputerAddedEvent

```ruby
JSSWebHooks.event_handler do |event|
  cname = event.event_object.deviceName
  uname = event.event_object.realName
  puts "Computer '#{cname}' was just added to the JSS for user #{uname}."
end
```

In this example, the codeblock takes one parameter, which it expects to be
a JSSWebHooks::ComputerAddedEvent instance, and uses it in the variable "event".
It then extracts the "deviceName" and "realName" values from the event_object
contained in the event, and uses them to send a message to stdout.

Internal handlers **must not** be executable files. Executability is how the
framework determines if a handler is internal or external.

#### External Handlers

External handlers are _executable_ files that are executed when called by an
event. They can be written in any language, but they must accept raw JSON on
their standard input. It's up to them to parse that JSON and react to it as
desired. In this case the JSSWebHooks framework is merely a conduit for passing
the Posted JSON to the executable program.

Here's a simple example using bash and [jq](https://stedolan.github.io/jq/) to
do the same as the ruby example above:

```bash
#!/bin/bash
JQ="/usr/local/bin/jq"
while read line ; do JSON="$JSON $line" ; done
cname=`echo $JSON | "$JQ" -r '.event.deviceName'`
uname=`echo $JSON | "$JQ" -r '.event.realName'`
echo "Computer '${cname}' was just added to the JSS for user ${uname}."
```

External handlers **must** be executable files. Executability is how the
framework determines if a handler is internal or external.

See ruby-jss/lib/jss/webhooks/data/sample_handlers/RestAPIOperation-executable
for a more detailed bash example that handles RestAPIOperation events.

### Putting it together

Here's a commented sample of ruby code that uses the framework to process a
ComputerAdded event:

```ruby
# load in the framework
require 'jss/webhooks'

# The framework comes with sample JSON files for each event type.
# In reality, a webserver would extract this from the data POSTed from the JSS
posted_json = JSSWebHooks.sample_jsons[:ComputerAdded]

# Create JSSWebHooks::Event::ComputerAddedEvent instance for the event
event = JSSWebHooks::Event.parse_event posted_json

# Call the events #handle method, which will execute any ComputerAdded
# handlers that were in the Handler directory when the framework was loaded.
event.handle
```

Of course, you can use the framework without using the built-in #handle method,
and if you don't have any handlers in the directory, it won't do anything
anyway. Instead you are welcome to use the Event objects as desired in your own
Ruby code.

### Events and Event objects

Here are the Event classes supported by the framework and the  EventObject classes
they contain.
For details about the attributes of each EventObject, see [The Unofficial JSS API
Docs](https://unofficial-jss-api-docs.atlassian.net/wiki/display/JRA/Webhooks+API)

Each Event class is a subclass of `JSSWebHooks::Event`, where all of their
functionality is defined.

The EventObject classes aren't suclasses, but are dynamically-defined members of
the `JSSWebHooks::EventObjects` module.

| Event Classes | Event Object Classes |
| -------------- | ------------ |
| JSSWebHooks::ComputerAddedEvent | JSSWebHooks::EventObjects::Computer |
| JSSWebHooks::ComputerCheckInEvent | JSSWebHooks::EventObjects::Computer |
| JSSWebHooks::ComputerInventoryCompletedEvent | JSSWebHooks::EventObjects::Computer |
| JSSWebHooks::ComputerPolicyFinishedEvent | JSSWebHooks::EventObjects::Computer |
| JSSWebHooks::ComputerPushCapabilityChangedEvent | JSSWebHooks::EventObjects::Computer |
| JSSWebHooks::JSSShutdownEvent | JSSWebHooks::EventObjects::JSS |
| JSSWebHooks::JSSStartupEvent | JSSWebHooks::EventObjects::JSS |
| JSSWebHooks::MobilDeviceCheckinEvent | JSSWebHooks::EventObjects::MobileDevice |
| JSSWebHooks::MobilDeviceCommandCompletedEvent | JSSWebHooks::EventObjects::MobileDevice |
| JSSWebHooks::MobilDeviceEnrolledEvent | JSSWebHooks::EventObjects::MobileDevice |
| JSSWebHooks::MobilDevicePushSentEvent | JSSWebHooks::EventObjects::MobileDevice |
| JSSWebHooks::MobilDeviceUnenrolledEvent | JSSWebHooks::EventObjects::MobileDevice |
| JSSWebHooks::PatchSoftwareTitleUpdateEvent | JSSWebHooks::EventObjects::PatchSoftwareTitleUpdate |
| JSSWebHooks::PushSentEvent | JSSWebHooks::EventObjects::Push |
| JSSWebHooks::RestAPIOperationEvent | JSSWebHooks::EventObjects::RestAPIOperation |
| JSSWebHooks::SCEPChallengeEvent | JSSWebHooks::EventObjects::SCEPChallenge |
| JSSWebHooks::SmartGroupComputerMembershipChangeEvent | JSSWebHooks::EventObjects::SmartGroup |
| JSSWebHooks::SmartGroupMobileDeviveMembershipChangeEvent | JSSWebHooks::EventObjects::SmartGroup |


## The Server

JSSWebHooks comes with a simple http server that uses the JSSWebHooks framework
to handle all incoming webhook POST requests from the JSS via a single URL.

To use it you'll need to install the [sinatra](http://www.sinatrarb.com/
) ruby gem (`sudo gem install sinatra`).

After that, just run the `jss-webhook-server` command located in the bin
directory for ruby-jss and then point your WebHooks at:
http://_my_hostname_/handle_webhook_event

It will then process all incoming webhook POST requests using whatever handlers
you have installed.

To automate it on a dedicated machine, just make a LaunchDaemon plist to run
that command and keep it running.

## Installing JSSWebHooks into ruby-jss

Until JSSWebHooks is officially released as part of ruby-jss, here's how to get
it up and running:

0. Write a handler or two (see _Handlers_ above) and put them into
   /Library/Application Support/JSSWebHooks/
0. Clone ruby-jss from github into some path like /path/to/github/clone/
1. If you don't already have it, install the ruby-jss gem `sudo gem install ruby-jss`
2. Install sinata: `sudo gem install sinatra`
3. Install immutable-struct: `sudo gem install immutable-struct`
4. From /path/to/github/clone/lib/jss/ copy the webhooks folder **and** webhooks.rb
   and into /Library/Ruby/Gems/2.0.0/gems/ruby-jss-_version_/lib/jss/ or
   where-ever your gems are installed.
5. From /path/to/github/clone/bin/ copy 'jss-webhook-server' into
   /Library/Ruby/Gems/2.0.0/gems/ruby-jss-_version_/bin/

Then fire up `irb` and `require jss/webhooks` to start playing around. (remember
the sample JSON strings available in `JSSWebHooks.sample_jsons`)

OR

run /Library/Ruby/Gems/2.0.0/gems/ruby-jss-_version_/bin/jss-webhook-server  and
point some WebHooks at your machine.


## TODOs

- Add SSL support to the server
- Better (any!) thread management for handlers
- Logging and Debug options
- handler reloading for individual, or all, Event subclasses
- Generate the YARD docs
- better namespace protection for internal handlers
- Use and improve the configuration stuff.
- write proper documentation beyond this README
- I'm sure there's more to do...
