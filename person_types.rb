class PersonTypes

  def initialize(*args)
    @types = *args
  end

  def [](type)
    @types.index(type)
  end

end
