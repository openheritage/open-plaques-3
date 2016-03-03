  class FormatNad83

    attr_reader :a, :e, :e1sq, :k0, :force_hemisphere

    def initialize
      @a = 6378137
      # b = 6356752.3142 - derivatives already computed; provide for reference
      @e = 0.081819191
      @e1sq = 0.006739497
      @k0 = 0.9996
      @force_hemisphere = false
    end

  end