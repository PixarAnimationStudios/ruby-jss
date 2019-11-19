# Implementing the Jamf Pro API in ruby-jss

The Jamf Pro API, formerly known as the 'Universal' API, aims to be a far more robust, modern, and standardized way to programmatically access a Jamf Pro server.  While its been in development for a while, it is finally starting to settle in to some standards, to the point that its worth releasing some early ruby-jss code to access it.

Because the JP-API is so fundamentally different from the Classic API, it's being implemented as a totally separate ruby module 'Jamf', and many of the underlying standards of ruby-jss's JSS module are being re-thought and modernized, much like the JP_API itself. Therefore there are some very big changes afoot.

This README is a quick overview of the big changes, for both using the Jamf module, and for contributing to its development.

IMPORTANT: As with the JP-API, this is an early work-in-progress, and things might change drastically at any point. The original work on the JP-API code was started long before the current server-side standards were in place, and much of that old-code is still here, but won't work.  Please mention 'ruby-jss' in MacAdmins Slack #jamf-api or #ruby, or email ruby-jss@pixar.com if you have questions or want to contribute.

## The Jamf module

The ruby-jss gem now contains two modules, which can be 'required' separately:

- `require 'ruby-jss'` or `require 'jss'` works as always, and loads in the 'JSS' module, which is unchanged in how it works for accessing the Classic API.  As long as the classic API is around, the JSS module will remain.

- `require 'jamf'` will load the 'Jamf' module, which is where access to the JP-API will happen.

Because everything is separated between the two modules, they can be used side by side, but remember when doing so, that objects are not compatible between them. So you if do `classicPol = JSS::Policy.fetch name: 'myPolicy'` and `jpPol = Jamf::Policy.fetch name: 'myPolicy'`, the objects of `classicPol` and `jpPol` are very different things, even tho they represent the same policy.

## Connecting to the JP-API

### Connection Objects

Connections are instances of Jamf::Connection, analagous to the previous JSS::APIConnection.

The way to access the 'active' connection in the Jamf module is via `Jamf.cnx`, which is the equivalent to the previous `JSS.api`.

Like before, a 'default' one is created when the library is loaded, and it is made the 'active' one. The Jamf module now has a direct `.connect` method so `Jamf.connect <params>` is the same as `Jamf.cnx.connect <params>`

As before, new connection objects can be created and stored in variables, then passsed around to various class methods as needed.

```
cnx1 = Jamf::Connection.new <params>
cnx2 = Jamf::Connection.new <params>

comp1 = Jamf::Computer.fetch id: 12, cnx: cnx1
comp2 = Jamf::Computer.fetch id: 12, cnx: cnx2
```

### Connection Parameters

The older connection parameters should still work as before, although `host: 'myjss.hostname.com'` is preferred over `server: 'myjss.hostname.com'`.

However, thee connection can be made using a URL as the first positional parameter, e.g.

    Jamf.connect 'https://myAPIuser:myAPIpasswd@myjss.hostname.com:8443'

When a URL is provided like this, the following parameters are parsed from it:

- use_ssl:  true if the URL is 'https' scheme
- user: extracted from the URL if provided. Otherwise, must be passed as a param, or available from the config file.
- pw: extracted from the URL if provided. Otherwise, must be passed as a param, or if not, defaults to :prompt
  - WARNING: beware of hard-coding passwords in any code that
- host: extracted from the URL
  - any host: param will be ignored if a URL is used.
- port: extracted from the URL explicitly if provided, or via the URL scheme if not (https = port 443, http = port 80)
  - any port: param will be ignored if a URL is used

If a URL is used, any values present in the URL override any that might be given as a parameter.

If a pw: parameter is not provided or present in a URL, the default is to prompt in a termminal, the same as `pw: :prompt`

### Connection Tokens

The JP-API uses token-based access, which is far more secure than sending the password along with every request.

For the most part, dealing with tokens is invisible to the user of ruby-jss. However, here are some things to think about as you work with them:

#### Tokens are objects

Once you are connected, the token is available in the `#token` method of the Connection object. So for the active connection, `my_token = Jamf.cnx.token`

#### Tokens Expire

Tokens come with an expiration time, defined by the server. After that time, the token is no longer valid and API access using it will fail.  To see the expiration time, use the '#expires' method: `Jamf.cnx.token.expires`.

#### Tokens can be refreshed

As long as you have a valid token, you can use it to refresh itself, which replaces the internally-stored token data and resets the expiration. Just use, e.g. `Jamf.cnx.token.refresh` which will return the new expiration time.

#### Connections can refresh the token automatically

If you have a long-running process that's likely to run longer than the life of a token, you can tell your connection object to automatically refresh its token some number of seconds before the token expires. To do so, just set the connection's 'keep_alive' attribute to true: `Jamf.cnx.keep_alive = true`. This will start a thread in the background that mostly stays asleep. Every 60 seconds it wakes up and checks to see if the current token's expiration is less than 'token_refresh' seconds from now, and if so, will refresh the token.

You can set token_refresh when you create your connection using the `token_refresh:  nnn` param, where nnn is an integer number of seconds. You can also set it dynamically, `Jamf.cnx.token_refresh = nnn`

#### Using a token to make a new connection

Since tokens are objects, they can be used instead of a user and password to make a connection. Just use `token: my_token` in the connection parameters. As long as the token is valid on the API host, and hasn't expired, it will work until it expires, or is invalidated from elsewhere.

#### Tokens can be invalidated

If you know you're done using a token, and want to be sure a copy of it cant be used from anywhere else, use the token's `invalidate` method, which will tell the server to stop accepting it as valid. The Connection object also has a `logout` method which will invalidate the token before reseting all the connection values.

Be careful if you use tokens in multiple places, since you could break some other connection using the token.

## Under the Hood


#### Classes classes everywhere

Because of the more modern standards being used as the JP-API is developed, implementing endpoints in ruby-jss is in some ways far easier than it was in the classic API.

The primary discussion of how this works is in the documentation/comments for the JSONObect abstract class, in the file lib/jamf/api/abstract_classes/json_obect.rb

Please read that for more details.

To summarize:

- All JSON Objects (ruby Hashes) that come from or are sent to the JP-API are defined as ruby classes in the Jamf module, even those that are tiny and deeply embedded in other data structures.

- Each ruby class that represents a JSON Object from the API has a constant 'OBJECT_MODEL' which tells ruby how to turn the JSON into a class instance, and turn that back into the JSON needed for the API.

- The info in the OBJECT_MODEL is used to automatically create getters, setters, validators, and do other 'meta-programming'

- Other abstract classes 'SingletonResource' and 'CollectionResource' are used to define API interaction via the Resource class.

- Mixins are more heavily used to encapsulate shared behavior across classes.

#### Autoloading

Since the number of classes is so huge, and they aren't always needed in any given project, the Jamf module is using ruby's autoloading feature to load most of the files only as they are used.  See the file .../lib/jamf.rb  to see how that all works
