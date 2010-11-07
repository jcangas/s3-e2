
# some shared helpers

module Pressman
  module Vector
    # operate squares like vectors
    def vector_sum(ary1, ary2)
      ary1.zip(ary2).map do |pair|
        pair[0].to_i + pair[1].to_i
      end
    end

    def vector_subs(ary1, ary2)
      ary1.zip(ary2).map do |pair|
        pair[0].to_i - pair[1].to_i
      end
    end
  end
end

