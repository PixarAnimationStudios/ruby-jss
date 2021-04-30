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

module JSS

  # A collection of useful utility methods. Mostly for
  # converting values between formats, parsing data, and
  # user interaction.

  # Hash of 'minor' => 'maint'
  # The maximum maint release for macOS 10.minor.maint
  # e.g the highest release of 10.6 was 10.6.8, the highest release of
  # 10.15 was 10.15.7
  #
  # 12 is the default for the current OS and higher
  # (and hoping apple doesn't release 10.16.13)
  OS_TEN_MAXS = {
      2 => 8,
      3 => 9,
      4 => 11,
      5 => 8,
      6 => 8,
      7 => 5,
      8 => 5,
      9 => 5,
      10 => 5,
      11 => 6,
      12 => 6,
      13 => 6,
      14 => 6,
      15 => 7
    }

  # Hash of 'major' => 'minor'
  # The maximum minor release for macOS major.minor
  # e.g. the highest release of 11 is 11.12
  #
  # 12 is the default for the current OS and higher
  # (and hoping apple doesn't release, e.g.,  11.13)
  MAC_OS_MAXS = {
    11 => 12,
    12 => 12,
    13 => 12,
    14 => 12,
    15 => 12,
    16 => 12,
    17 => 12,
    18 => 12,
    19 => 12,
    20 => 12
  }

  # Converts an OS Version into an Array of equal or higher OS versions, up to
  # some non-existant max, hopefully far in the future, currently 20.12.10
  #
  # This array can then be joined with commas and used as the value of the
  # os_requirements for Packages and Scripts.
  #
  # It's unlikely that this method, as written, will still be in use by
  # the release of macOS 20.12.10, but currently thats the upper limit.
  #
  # Hopefully well before then JAMF will implement a "minimum OS" in Jamf Pro
  # itself, then we could avoid the inherant limitations in using a method like
  # this.
  #
  # When the highest maint. release of an OS version is not known, because its
  # the currently released OS version or higher, then this method assumes '12'
  # e.g. '10.16.12', '11.12', '12.12', etc.
  #
  # Apple has never released more than 11 updates to a version of macOS
  # (that being 10.4), so hopefully 12 is enough
  #
  # Since Big Sur might report itself as either '10.16' or '11.x.x', this method
  # will allow for both possibilities, and the array will contain whatever
  # iterations needed for both version numbers
  #
  # @param min_os [String] the mimimum OS version to expand, e.g. ">=10.9.4"  or "11.1"
  #
  # @return [Array] Nearly all potential OS versions from the minimum to 20.12.10
  #
  # @example
  #   JSS.expand_min_os ">=10.9.4" # => returns this array
  #    # ["10.9.4",
  #    #  "10.9.5",
  #    #  "10.10.x"
  #    #  ...
  #    #  "10.16.x",
  #    #  "11.x",
  #    #  "12.x",
  #    #  ...
  #    #  "20.x"]
  #
  #
  def self.expand_min_os(min_os)
    min_os = min_os.delete '>='

    # split the version into major, minor and maintenance release numbers
    major, minor, maint = min_os.split('.')
    minor = 'x' if minor.nil? || minor == '0'
    maint = 'x' if maint.nil? || maint == '0'

    ok_oses = []

    # Deal with 10.x.x up to 10.16
    if major == '10'

      # In big sur with SYSTEM_VERSION_COMPAT
      # set, it will only ever report as `10.16`
      # So if major is 10 and minor is 16, ignore maint
      # and start explicitly at '10.16'
      if minor == '16'
        ok_oses << '10.16'

      # But for Catalina and below, we need to
      # expand things out
      else
        # e.g. 10.14.x
        # doesn't expand to anything
        if maint == 'x'
          ok_oses << "10.#{minor}.x"

        # e.g. 10.15.5
        # expand to 10.15.5, 10.15.6, 10.15.7
        else
          max_maint_for_minor = OS_TEN_MAXS[minor.to_i]

          (maint.to_i..max_maint_for_minor).each do |m|
            ok_oses << "#{major}.#{minor}.#{m}"
          end # each m
        end # if maint == x

        # now if we started below catalina, account for everything
        # up to 10.15.x
        if minor.to_i < 15
          ((minor.to_i + 1)..15).each { |v| ok_oses << "10.#{v}.x" }
        end

        # and add big sur with SYSTEM_VERSION_COMPAT
        ok_oses << '10.16'
      end # if minor == 16

      # now reset these so we can go higher
      major = '11'
      minor = 'x'
      maint = 'x'
    end # if major == 10

    # if the min os is 11.0.0 or equiv, and we aven't added 10.16
    # for SYSTEM_VERSION_COMPAT, add it now
    if ['11', '11.x', '11.x.x', '11.0', '11.0.0'].include?(min_os) && !ok_oses.include?('10.16')
      ok_oses << '10.16'
    end

    # e.g. 11.x, or 11.x.x
    # expand to 11.x, 12.x, 13.x, ... 20.x
    if minor == 'x'
      ((major.to_i)..20).each { |v| ok_oses << "#{v}.x" }

    # e.g. 11.2.x
    # expand to 11.2.x, 11.3.x, ... 11.12.x,
    #   12.x, 13.x,  ... 20.x
    elsif maint == 'x'
      # first expand the minors out to their max
      # e.g. 11.2.x, 11.3.x, ... 11.12.x
      max_minor_for_major = MAC_OS_MAXS[major.to_i]
      ((minor.to_i)..max_minor_for_major).each do |m|
        ok_oses << "#{major}.#{m}.x"
      end # each m

      # then add the majors out to 20
      ((major.to_i + 1)..20).each { |v| ok_oses << "#{v}.x" }

    # e.g. 11.2.3
    # expand to 11.2.3, 11.2.4, ... 11.2.10,
    #   11.3.x, 11.4.x, ... 11.12.x,
    #   12.x, 13.x, ... 20.x
    else
      # first expand the maints out to 10
      # e.g. 11.2.3, 11.2.4, ... 11.2.10
      ((maint.to_i)..10).each { |mnt| ok_oses << "#{major}.#{minor}.#{mnt}" }

      # then expand the minors out to their max
      # e.g. 11.3.x, ... 11.12.x
      max_minor_for_major = MAC_OS_MAXS[major.to_i]
      ((minor.to_i + 1)..max_minor_for_major).each { |min| ok_oses << "#{major}.#{min}.x" }

      # then add the majors out to 20
      ((major.to_i + 1)..20).each { |v| ok_oses << "#{v}.x" }
    end

    ok_oses
  end # def self.expand_min_os(min_os)

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
        /^#{r.chomp('.x').gsub('.', '\.')}\.?\d*$/

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
      raise JSS::InvalidDataError, 'Input must be a comma-separated String or an Array of Strings'
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
  # @return [Object] the parsed plist as a ruby hash,array, etc.
  #
  def self.parse_plist(plist)
    require 'cfpropertylist'

    # did we get a string of xml, or a string pathname?
    case plist
    when String
      return CFPropertyList.native_types(CFPropertyList::List.new(data: plist).value) if plist.include? '</plist>'

      plist = Pathname.new plist
    when Pathname
      true
    else
      raise ArgumentError, 'Argument must be a path (as a Pathname or String) or a String of XML'
    end # case plist

    # if we're here, its a Pathname
    raise JSS::MissingDataError, "No such file: #{plist}" unless plist.file?

    CFPropertyList.native_types(CFPropertyList::List.new(file: plist).value)
  end # parse_plist

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
    the_dt = DateTime.new(the_dt.year, the_dt.month, the_dt.day, the_dt.hour, the_dt.min, the_dt.sec, JSS::TIME_ZONE_OFFSET) if the_dt.offset.zero?
    # now convert it to a Time and return it
    Time.at the_dt.strftime('%s').to_i, usec
  end # parse_time

  # Deprecated - to be eventually removed in favor of
  # the more-appropriately named JSS::parse_time
  #
  # @see JSS::parse_time
  #
  def self.parse_datetime(a_datetime)
    parse_time(a_datetime)
  end

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

  # Given a name, singular or plural, of a JSS::APIObject subclass as a String
  # or Symbol (e.g. :computer/'computers'), return the class itself
  # (e.g. JSS::Computer)
  # The available names are the RSRC_LIST_KEY
  # and RSRC_OBJECT_KEY values for each APIObject subclass.
  #
  # @seealso JSS.api_object_names
  #
  # @param name[String,Symbol] The name of a JSS::APIObject subclass, singluar
  #   or plural
  #
  # @return [Class] The class
  #
  def self.api_object_class(name)
    klass = api_object_names[name.downcase.to_sym]
    raise JSS::InvalidDataError, "Unknown API Object Class: #{name}" unless klass

    klass
  end

  # APIObject subclasses have singular names, and are, of course
  # capitalized, e.g. 'Computer'
  # But we often want to refer to them in the plural, or lowercase,
  # e.g. 'computers'
  # This method returns a Hash of the RSRC_LIST_KEY (a plural symbol)
  # and the RSRC_OBJECT_KEY (a singular symbol) of each APIObject
  # subclass, keyed to the class itself, such that both :computer
  # and :computers are keys for JSS::Computer and both :policy and
  # :policies are keys for JSS::Policy, and so on.
  #
  # @return [Hash] APIObject subclass names to Classes
  #
  def self.api_object_names
    return @api_object_names if @api_object_names

    @api_object_names ||= {}
    JSS.constants.each do |const|
      klass = JSS.const_get const
      next unless klass.is_a? Class
      next unless klass.ancestors.include? JSS::APIObject

      @api_object_names[klass.const_get(:RSRC_LIST_KEY).to_sym] = klass if klass.constants.include? :RSRC_LIST_KEY
      @api_object_names[klass.const_get(:RSRC_OBJECT_KEY).to_sym] = klass if klass.constants.include? :RSRC_OBJECT_KEY
    end
    @api_object_names
  end

  # Given a string of xml element text, escape any characters that would make XML unhappy.
  #   * & => &amp;
  #   * " => &quot;
  #   * < => &lt;
  #   * > => &gt;
  #   * ' => &apos;
  #
  # @param string [String] the string to make xml-compliant.
  #
  # @return [String] the xml-compliant string
  #
  def self.escape_xml(string)
    string.gsub(/&/, '&amp;').gsub(/\"/, '&quot;').gsub(/>/, '&gt;').gsub(/</, '&lt;').gsub(/'/, '&apos;')
  end

  # Given an element name and an array of content, generate an Array of
  # REXML::Element objects with that name, and matching content.
  # Given element name 'foo' and the array ['bar','morefoo']
  # The array of REXML elements would render thus:
  #     <foo>bar</foo>
  #     <foo>morefoo</foo>
  #
  # @param element [#to_s] an element_name like :foo
  #
  # @param list [Array<#to_s>] an Array of element content such as ["bar", :morefoo]
  #
  # @return [Array<REXML::Element>]
  #
  def self.array_to_rexml_array(element, list)
    raise JSS::InvalidDataError, 'Arg. must be an Array.' unless list.is_a? Array

    element = element.to_s
    list.map do |v|
      e = REXML::Element.new(element)
      e.text = v
      e
    end
  end

  # Given a simple Hash, convert it to an array of REXML Elements such that each
  # key becomes an element, and its value becomes the text content of
  # that element
  #
  # @example
  #   my_hash = {:foo => "bar", :baz => :morefoo}
  #   xml = JSS.hash_to_rexml_array(my_hash)
  #   xml.each{|x| puts x }
  #
  #   <foo>bar</foo>
  #   <baz>morefoo</baz>
  #
  # @param hash [Hash{#to_s => #to_s}] the Hash to convert
  #
  # @return [Array<REXML::Element>] the Array of REXML elements.
  #
  def self.hash_to_rexml_array(hash)
    raise InvalidDataError, 'Arg. must be a Hash.' unless hash.is_a? Hash

    ary = []
    hash.each_pair do |k, v|
      el = REXML::Element.new k.to_s
      el.text = v
      ary << el
    end
    ary
  end

  # Given an Array of Hashes with :id and/or :name keys, return
  # a single REXML element with a sub-element for each item,
  # each of which contains a :name or :id element.
  #
  # @param list_element [#to_s] the name of the XML element that contains the list.
  # e.g. :computers
  #
  # @param item_element [#to_s] the name of each XML element in the list,
  # e.g. :computer
  #
  # @param item_list [Array<Hash>] an Array of Hashes each with a :name or :id key.
  #
  # @param content [Symbol] which hash key should be used as the content of if list item? Defaults to :name
  #
  # @return [REXML::Element] the item list as REXML
  #
  # @example
  #   comps = [{:id=>2,:name=>'kimchi'},{:id=>5,:name=>'mantis'}]
  #   xml = JSS.item_list_to_rexml_list(:computers, :computer , comps, :name)
  #   puts xml
  #   # output manually formatted for clarity. No newlines in the real xml string
  #   <computers>
  #     <computer>
  #       <name>kimchi</name>
  #     </computer>
  #     <computer>
  #       <name>mantis</name>
  #     </computer>
  #   </computers>
  #
  #   # if content is :id, then, eg. <name>kimchi</name> would be <id>2</id>
  #
  def self.item_list_to_rexml_list(list_element, item_element, item_list, content = :name)
    xml_list = REXML::Element.new  list_element.to_s
    item_list.each do |i|
      xml_list.add_element(item_element.to_s).add_element(content.to_s).text = i[content]
    end
    xml_list
  end

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
    raise JSS::InvalidDataError, 'JSS Versions must start with "x.x" where x is one or more digits' unless major =~ /\d$/ && second_part =~ /^\d/

    release, build = version.split(/-/)

    major, minor, revision = release.split '.'
    minor ||= 0
    revision ||= 0

    {
      major: major.to_i,
      minor: minor.to_i,
      revision: revision.to_i,
      maint: revision.to_i,
      patch: revision.to_i,
      build: build,
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
