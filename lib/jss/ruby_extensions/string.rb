#############################################
### Convert a string into a ruby DateTime object.
###
### The JSS API can take incoming timestamp data in three formats:
### - plain date: YYYY-mm-dd HH:MM:SS, which is assumed to be in the local timezone
### - UTC date: YYYY-mm-ddTHH:MM:SS.mmm[+-]zzzz, the local time with milliseconds and the timezone offset
### - Unix epoch with milliseconds, nnnnnnnnnnnnn,  which like all epoch times, is UTC
###
### Here we extend String to parse the three formats into DateTime objects for use withing ruby.
###
### When reading from the API, all three formats are returned in different xml elements, 
### and the APIObjects in the gem will use the epoch format and the JSS.parse_datetime method (q.v.) to store 
### the data as a ruby DateTime. The real work of JSS.parse_datetime happens here in String#to_jss_datetime.
###
### If the string is all digits it is assumed to be a unix epoch timestamp must be 9, 10, 12, or 13 digits long.
### - Nine or Ten digits is assumed to be a unix epoch without milliseconds.
### - Twelve or 13 digits is a unix epoch with milliseconds (as stored in the JSS).
### Any other length of pure digits will raise an error.
### 
### Why?
### - Less than 9, not using milliseconds, would be before Sat Mar 3 01:46:40 PST 1973, which was before Casper existed.
### - Greater than 10, but not using milliseconds, would be around the year 2286
### - 10 or 11, using milliseconds, would mean the non partial part would be before 1973
### - Greater than 13 would be beyond 2286 even with milliseconds.
### 
### If not all digits, it is parsed with DateTime.parse, and if the resulting DateTime doesn't 
### have timezone offset, the local offset is applied, to ensure all stored dates are known in relation
### to UTC.
###
class String
  def to_jss_datetime
    if self =~ /^\d+$/
      case self.length
        when 9..10
          return DateTime.strptime(self, '%s')
        when 12..13
          return DateTime.strptime(self, '%Q')
        else 
          raise JSS::InvalidDataError, "Epoch times must have either 9-10 or 12-13 digits (without/with milliseconds)"
      end # case
    end # if digits
    
    ### Parse the datetime from the string
    the_dt = DateTime.parse(self)
    
    ### if the UTC offset of the datetime is zero, make a new one with the correct local offset
    ### (which might also be zero if we happen to be in GMT)
    if the_dt.offset == 0
    
      ### The milli/micro seconds are stored as a fraction of a day.
      ### Convert them to an integer of microseconds
      usec = (the_dt.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
      
      ### then add them to the secs to make a new fractional number of seconds
      secs = the_dt.sec + Rational(usec, 10**6)
      
      return DateTime.new(the_dt.year, the_dt.month, the_dt.day, the_dt.hour, the_dt.min, secs, JSS::TIME_ZONE_OFFSET)
    
    else
      return the_dt
    end
    
  end # to_jss_datetime
end # String
