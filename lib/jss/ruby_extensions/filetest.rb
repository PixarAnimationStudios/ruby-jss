module FileTest
  #############################################
  ### FileTest.file? returns true if
  ### the item is a symlink pointing to a regular file.
  ###
  ### This test, real_file?, returns true if the item is
  ### a regular file but NOT a symlink.
  ###
  def FileTest.real_file?(path)
    FileTest.file?(path) and not FileTest.symlink?(path)
  end # real_file?
end # module FileTest






