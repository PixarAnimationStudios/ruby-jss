# Copyright 2020 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# The Module
module Jamf

  # Constants
  ###################################

  # These Utility constants are useful all over the place.
  # Many of them are commonly used Strings.

  BLANK = ''.freeze

  UNDERSCORE = '_'.freeze

  # A collection of useful utility methods. Mostly for
  # converting values between formats, parsing data, and
  # user interaction.

  # TODO: confirm need for each method in Jamf Pro API.

  # Converts an OS Version into an Array of higher OS versions.
  #
  # It's unlikely that this library will still be in use as-is by the release of OS X 10.30.20.
  # Hopefully well before then JAMF will implement a "minimum OS" in the JSS itself.
  #
  # @param min_os [String] the mimimum OS version to expand, e.g. ">=10.6.7"  or "10.6.7"
  #
  # @return [Array] Nearly all potential OS versions from the minimum to 10.19.x.
  #
  # @example
  #   JSS.expand_min_os ">=10.6.7" # => returns this array
  #    # ["10.6.7",
  #    #  "10.6.8",
  #    #  "10.6.9",
  #    #   ...
  #    #  "10.6.20",
  #    #  "10.7.x",
  #    #  "10.8.x",
  #    #  ...
  #    #  "10.30.x"]
  #
  #
  def self.expand_min_os(min_os)
    min_os = min_os.delete '>='

    # split the version into major, minor and maintenance release numbers
    (maj, min, maint) = min_os.split('.')
    maint = 'x' if maint.nil? || maint == '0'

    # if the maint release number is an "x" just start the list of OK OS's with it
    if maint == 'x'
      ok_oses = [maj + '.' + min.to_s + '.x']

    # otherwise, start with it and explicitly add all maint releases up to 20
    # (and hope apple doesn't do more than 20 maint releases for an OS)
    else
      ok_oses = []
      (maint.to_i..20).each do |m|
        ok_oses << maj + '.' + min + '.' + m.to_s
      end # each m
    end

    # now account for all OS X versions starting with 10.
    # up to at least 10.30.x
    ((min.to_i + 1)..30).each do |v|
      ok_oses << maj + '.' + v.to_s + '.x'
    end # each v
    ok_oses
  end

  # Scripts and packages can have processor limitations.
  # This method tests a given processor, against a requirement
  # to see if the requirement is met.
  #
  # @param requirement[String] The processor requirement.
  #   either 'ppc', 'x86', or some variation on "none", nil, or empty
  #
  # @param processor[String] the processor to check, defaults to
  #  the processor of the current machine. Any flavor of intel
  ##   is (i486, i386, x86-64, etc) is treated as "x86"
  #
  # @return [Boolean] can this pkg be installed with the processor
  #   given?
  #
  def self.processor_ok?(requirement, processor = nil)
    return true if requirement.to_s.empty? || requirement =~ /none/i
    processor ||= `/usr/bin/uname -p`
    requirement == (processor.to_s.include?('86') ? 'x86' : 'ppc')
  end

  # Scripts and packages can have OS limitations.
  # This method tests a given OS, against a requirement list
  # to see if the requirement is met.
  #
  # @param requirement[String,Array] The os requirement list, a comma-seprated string
  #   or array of strings of allows OSes. e.g. 10.7, 10.8.5 or 10.9.x
  #
  # @param processor[String] the os to check, defaults to
  #  the os of the current machine.
  #
  # @return [Boolean] can this pkg be installed with the processor
  #   given?
  #
  def self.os_ok?(requirement, os_to_check = nil)
    return true if requirement.to_s =~ /none/i
    return true if requirement.to_s == 'n'
    requirement = JSS.to_s_and_a(requirement)[:arrayform]
    return true if requirement.empty?

    os_to_check ||= `/usr/bin/sw_vers -productVersion`.chomp

    # convert the requirement array into an array of regexps.
    # examples:
    #   "10.8.5" becomes  /^10\.8\.5$/
    #   "10.8" becomes /^10.8(.0)?$/
    #   "10.8.x" /^10\.8\.?\d*$/
    req_regexps = requirement.map do |r|
      if r.end_with?('.x')
        /^#{r.chomp('.x').gsub('.', '\.')}(\.?\d*)*$/

      elsif r =~ /^\d+\.\d+$/
        /^#{r.gsub('.', '\.')}(.0)?$/

      else
        /^#{r.gsub('.', '\.')}$/
      end
    end

    req_regexps.each { |re| return true if os_to_check =~ re }
    false
  end

  # Given a list of data as a comma-separated string, or an Array of strings,
  # return a Hash with both versions.
  #
  # Some parts of the JSS require lists as comma-separated strings, while
  # often those data are easier work with as arrays. This method is a handy way
  # to get either form when given either form.
  #
  # @param somedata [String, Array] the data to parse, of either class,
  #
  # @return [Hash{:stringform => String, :arrayform => Array}] the data as both comma-separated String and Array
  #
  # @example
  #   JSS.to_s_and_a "foo, bar, baz" # Hash => {:stringform => "foo, bar, baz", :arrayform => ["foo", "bar", "baz"]}
  #
  #   JSS.to_s_and_a ["foo", "bar", "baz"] # Hash => {:stringform => "foo, bar, baz", :arrayform => ["foo", "bar", "baz"]}
  #
  def self.to_s_and_a(somedata)
    case somedata
    when nil
      valstr = ''
      valarr = []
    when String
      valstr = somedata
      valarr = somedata.split(/,\s*/)
    when Array
      valstr = somedata.join ', '
      valarr = somedata
    else
      raise Jamf::InvalidDataError, 'Input must be a comma-separated String or an Array of Strings'
    end # case
    { stringform: valstr, arrayform: valarr }
  end # to_s_and_a

  # Parse a plist into a Ruby data structure. The plist parameter may be
  # a String containing an XML plist, or a path to a plist file, or it may be
  # a Pathname object pointing to a plist file. The plist files may be XML or
  # binary.
  #
  # @param plist[Pathname, String] the plist XML, or the path to a plist file
  #
  # @param symbol_keys[Boolean] should any Hash keys in the result be converted
  #   into Symbols rather than remain as Strings?
  #
  # @return [Object] the parsed plist as a ruby hash,array, etc.
  #
  def self.parse_plist(plist, symbol_keys: false)
    require 'cfpropertylist'

    # did we get a string of xml, or a string pathname?
    case plist
    when String
      return CFPropertyList.native_types(CFPropertyList::List.new(data: plist).value, symbol_keys) if plist.include? '</plist>'

      plist = Pathname.new plist
    when Pathname
      true
    else
      raise ArgumentError, 'Argument must be a path (as a Pathname or String) or a String of XML'
    end # case plist

    # if we're here, its a Pathname
    raise JSS::MissingDataError, "No such file: #{plist}" unless plist.file?

    CFPropertyList.native_types(CFPropertyList::List.new(file: plist).value, symbol_keys)
  end # parse_plist

  # Convert any ruby data to an XML plist.
  #
  # NOTE: Binary data is tricky. Easiest way is to pass in a
  # Pathname or IO object (anything that responds to `read` and
  # returns a bytestring)
  # and then the CFPropertyList.guess method will read it and
  # convert it to a Plist <data> element with base64 encoded
  # data.
  # For more info, see CFPropertyList.guess
  #
  # @param data [Object] the data to be converted, usually a Hash
  #
  # @return [String] the object converted into an XML plist
  #
  def self.xml_plist_from(data)
    require 'cfpropertylist'
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data, convert_unknown_to_string: true)
    plist.to_str(CFPropertyList::List::FORMAT_XML)
  end

  # TODO: Sill needed in Jamf API?
  #
  # Converts anything that responds to #to_s to a Time, or nil
  #
  # Return nil if the item is nil, 0 or an empty String.
  #
  # Otherwise the item converted to a string, and parsed with DateTime.parse.
  # It is then examined to see if it has a UTC offset. If not, the local offset
  # is applied, then the DateTime is converted to a Time.
  #
  # @param a_datetime [#to_s] The thing to convert to a time.
  #
  # @return [Time, nil] nil is returned if a_datetime is nil, 0 or an empty String.
  #
  def self.parse_time(a_datetime)
    return nil if NIL_DATES.include? a_datetime

    the_dt = DateTime.parse(a_datetime.to_s)

    # The microseconds in DateTimes are stored as a fraction of a day.
    # Convert them to an integer of microseconds
    usec = (the_dt.sec_fraction * 60 * 60 * 24 * (10**6)).to_i

    # if the UTC offset of the datetime is zero, make a new one with the correct local offset
    # (which might also be zero if we happen to be in GMT)
    the_dt = DateTime.new(the_dt.year, the_dt.month, the_dt.day, the_dt.hour, the_dt.min, the_dt.sec, Jamf::TIME_ZONE_OFFSET) if the_dt.offset.zero?
    # now convert it to a Time and return it
    Time.at the_dt.strftime('%s').to_i, usec
  end # parse_time

  # TODO: Sill needed in Jamf API?
  #
  # Converts JSS epoch (unix epoch + milliseconds) to a Ruby Time object
  #
  # @param epoch[String, Integer, nil]
  #
  # @return [Time, nil] nil is returned if epoch is nil, 0 or an empty String.
  #
  def self.epoch_to_time(epoch)
    return nil if NIL_DATES.include? epoch
    Time.at(epoch.to_i / 1000.0)
  end # parse_date

  # TODO: Move to APIObject
  #
  # Given a name, singular or plural, of a Jamf::APIObject subclass as a String
  # or Symbol (e.g. :computer/'computers'), return the class itself
  # (e.g. Jamf::Computer)
  # The available names are the RSRC_LIST_KEY
  # and RSRC_OBJECT_KEY values for each APIObject subclass.
  #
  # @seealso JSS.api_object_names
  #
  # @param name[String,Symbol] The name of a Jamf::APIObject subclass, singluar
  #   or plural
  #
  # @return [Class] The class
  #
  def self.api_object_class(name)
    klass = api_object_names[name.downcase.to_sym]
    raise Jamf::InvalidDataError, "Unknown API Object Class: #{name}" unless klass
    klass
  end

  # TODO: Move to APIObject
  #
  # APIObject subclasses have singular names, and are, of course
  # capitalized, e.g. 'Computer'
  # But we often want to refer to them in the plural, or lowercase,
  # e.g. 'computers'
  # This method returns a Hash of the RSRC_LIST_KEY (a plural symbol)
  # and the RSRC_OBJECT_KEY (a singular symbol) of each APIObject
  # subclass, keyed to the class itself, such that both :computer
  # and :computers are keys for Jamf::Computer and both :policy and
  # :policies are keys for Jamf::Policy, and so on.
  #
  # @return [Hash] APIObject subclass names to Classes
  #
  def self.api_object_names
    return @api_object_names if @api_object_names
    @api_object_names ||= {}
    JSS.constants.each do |const|
      klass = JSS.const_get const
      next unless klass.is_a? Class
      next unless klass.ancestors.include? Jamf::APIObject
      @api_object_names[klass.const_get(:RSRC_LIST_KEY).to_sym] = klass if klass.constants.include? :RSRC_LIST_KEY
      @api_object_names[klass.const_get(:RSRC_OBJECT_KEY).to_sym] = klass if klass.constants.include? :RSRC_OBJECT_KEY
    end
    @api_object_names
  end

  # TODO: Update or remove for Jamf API
  # Parse a JSS Version number into something comparable.
  #
  # This method returns a Hash with these keys:
  # * :major => the major version, Integer
  # * :minor => the minor version, Integor
  # * :maint => the revision, Integer (also available as :patch and :revision)
  # * :build => the revision, String
  # * :version => a Gem::Version object built from :major, :minor, :revision
  #   which can be easily compared with other Gem::Version objects.
  #
  # NOTE: the :version value ignores build numbers, so comparisons
  # only compare major.minor.maint
  #
  # @param version[String] a JSS version number from the API
  #
  # @return [Hash{Symbol => String, Gem::Version}] the parsed version data.
  #
  def self.parse_jss_version(version)
    major, second_part, *_rest = version.split('.')
    raise Jamf::InvalidDataError, 'JSS Versions must start with "x.x" where x is one or more digits' unless major =~ /\d$/ && second_part =~ /^\d/

    release, build = version.split(/-/)

    major, minor, revision = release.split '.'
    minor ||= 0
    revision ||= 0

    {
      major: major.to_i,
      minor:  minor.to_i,
      revision:  revision.to_i,
      maint:  revision.to_i,
      patch:  revision.to_i,
      build:  build,
      version: Gem::Version.new("#{major}.#{minor}.#{revision}")
    }
  end

  # @return [Boolean] is this code running as root?
  #
  def self.superuser?
    Process.euid.zero?
  end

  # Retrive one or all lines from whatever was piped to standard input.
  #
  # Standard input is read completely the first time this method is called
  # and the lines are stored as an Array in the module var @stdin_lines
  #
  # @param line[Integer] which line of stdin is being retrieved.
  #  The default is zero (0) which returns all of stdin as a single string.
  #
  # @return [String, nil] the requested ling of stdin, or nil if it doesn't exist.
  #
  def self.stdin(line = 0)
    @stdin_lines ||= ($stdin.tty? ? [] : $stdin.read.lines.map { |l| l.chomp("\n") })

    return @stdin_lines.join("\n") if line <= 0
    idx = line - 1
    @stdin_lines[idx]
  end

  # Prompt for a password in a terminal.
  #
  # @param message [String] the prompt message to display
  #
  # @return [String] the text typed by the user
  #
  def self.prompt_for_password(message)
    begin
      $stdin.reopen '/dev/tty' unless $stdin.tty?
      $stderr.print "#{message} "
      system '/bin/stty -echo'
      pw = $stdin.gets.chomp("\n")
      puts
    ensure
      system '/bin/stty echo'
    end # begin
    pw
  end

  # Very handy!
  # lifted from
  # http://stackoverflow.com/questions/4136248/how-to-generate-a-human-readable-time-range-using-ruby-on-rails
  #
  def self.humanize_secs(secs)
    [[60, :second], [60, :minute], [24, :hour], [7, :day], [52.179, :week], [1_000_000, :year]].map do |count, name|
      next unless secs > 0

      secs, n = secs.divmod(count)
      n = n.to_i
      "#{n} #{n == 1 ? name : (name.to_s + 's')}"
    end.compact.reverse.join(' ')
  end

  # un/set devmode mode.
  # Useful when coding - methods can call JSS.devmode? and then
  # e.g. spit out something instead of performing some action.
  #
  # @param [Symbol] Set devmode :on or :off
  #
  # @return [Boolean] The new state of devmode
  #
  def self.devmode(setting)
    @devmode = setting == :on
  end

  # is devmode currently on?
  #
  # @return [Boolean]
  #
  def self.devmode?
    @devmode
  end

end # module
