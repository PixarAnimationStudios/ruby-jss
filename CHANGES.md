# Change History

v0.5.6 2014-11-04
- now requires Ruby >= 1.9.3 and rest-client >= 1.7.0. Needed for Casper >= 9.61's lack of support for SSLv3.
- APIConnection now accepts :ssl_version option in the argument hash. Defaults to 'TLSv1'
- Configuration now supports the api_ssl_version key, used for the :ssl_version option of the APIConnection.
- the example programs have been moved to the bin directory, and are now included in the gem installation.
- many documentation updates as we adjust to being live
- minor bugfixes

v0.5.0 2014-10-23 
- first opensource release
