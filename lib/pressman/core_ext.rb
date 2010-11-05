class Array
  def to_coord
    sum(["a".ord, '1'.ord ]).map {|c| c.chr}.join
  end

  def to_square
    self
  end

  # operate squares like vectors
  def sum(other)
    self.zip(other).map do |pair|
      pair[0].to_i + pair[1].to_i
    end
  end

  def subs(other)
    self.zip(other).map do |pair|
      pair[0].to_i - pair[1].to_i
    end
  end

end

class String
  def to_square
    [self[0].ord, self[1].ord].subs ["a".ord, '1'.ord ]
  end

  def to_coord
    self
  end
end

