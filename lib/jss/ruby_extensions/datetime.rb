#############################################
### The JSS API can take incoming timestamp data in three formats:
### - plain date: YYYY-mm-dd HH:MM:SS, which is assumed to be in the local timezone
### - UTC date: YYYY-mm-ddTHH:MM:SS.mmm [+-]zzzz, the local time with milliseconds and the timezone offset
### - Unix epoch with milliseconds, nnnnnnnnnnnnn,  which like all epoch times, is UTC
###
### Here we extend DateTime to return the three formats for use in XML data to pass
### back to the API. The API xml works with any of the formats, in appropriate elements. Generally we use 
### the epoch format for passing values back to the API but any should work.
###
### When reading from the API, all three formats are returned in different xml elements, 
### and the APIObjects in the gem will use the epoch format and the JSS.parse_datetime method (q.v.) to store 
### the data as a ruby DateTime. The real work of JSS.parse_datetime happens in String.to_jss_datetime.
###
class DateTime

  def to_jss_xml_date
    self.strftime '%Y-%m-%d %H:%M:%S'
  end
  
  def to_jss_xml_utc
    self.strftime("%Y-%m-%dT%H:%M:%S.%L%z")
  end
  
  def to_jss_xml_epoch
    self.strftime '%s%L' # '%Q' - seems to be a bug in some calls to this.
  end

end

