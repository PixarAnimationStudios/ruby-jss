#############################################
### A few augmentations to IPAddr handling.
###
class IPAddr
  
  ### Return a Masked IPV4 IPAddr object from the 
  ### starting and ending address of the subnet.
  ### Addrs can be Strings or IPAddrs
  ### e.g. '10.0.0.0', '10.0.0.255' => #<IPAddr: IPv4:10.0.0.0/255.255.255.0>
  ###
  def self.masked_v4addr(starting,ending)
    IPAddr.new "#{starting}/#{self.cidr_from_ends(starting,ending)}"
  end #self.masked_v4addr(starting,ending)
  
  ### Return the Integer CIDR from the starting and ending addresses
  ### for the subnet. Addrs can be Strings or IPAddrs.
  ### eg  '10.0.0.0', '10.0.0.255' => 24
  ###
  def self.cidr_from_ends(starting,ending)
    
    starting = IPAddr.new(starting) unless starting.kind_of? IPAddr
    ending = IPAddr.new(ending) unless ending.kind_of? IPAddr
    
    ### how many possible addresses in the range?
    num_addrs =  ending.to_i - starting.to_i + 1
    
    ### convert the number of possible addresses to 
    ### binary then subtract the number of bits from
    ### the full length of an IPv4 addr 
    ### (32 bits) and that gives the CIDR prefix
    return 32 - num_addrs.to_s(2).length + 1
    
  end #self.get_cidr(starting,ending)

  ### Return an ending IPAddr for a subnet
  ### when given a starting address (IPAddr or String) and a CIDR
  ###
  def self.ending_address(starting, cidr)
    IPAddr.new( "#{starting}/#{cidr}").to_range.max
  end # ending_address
    
end # Class IPAddr
