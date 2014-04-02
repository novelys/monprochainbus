class AppColors
  class << self
    def mainGreen
      @mainGreen ||= UIColor.colorWithRed(151/256.0, green: 191/256.0, blue: 11/256.0, alpha: 1.0)
    end

    def tramA; @tramA ||= "#e2001a".to_color; end
    def tramB; @tramB ||= "#009ee0".to_color; end
    def tramC; @tramC ||= "#f29400".to_color; end
    def tramD; @tramD ||= "#009933".to_color; end
    def tramE; @tramE ||= "#8e83b9".to_color; end
    def tramF; @tramF ||= "#b1c800".to_color; end
    def busG;  @busG  ||= "#18437b".to_color; end
    def bus4;  @bus4  ||= "#cd071e".to_color; end
    def bus6;  @bus6  ||= "#7d5da0".to_color; end
    def bus7;  @bus7  ||= "#009036".to_color; end
    def bus10; @bus10 ||= "#faba00".to_color; end
    def bus12; @bus12 ||= "#88cccf".to_color; end
    def bus15; @bus15 ||= "#004a99".to_color; end
    def bus13; @bus13 ||= "#f7c9dc".to_color; end
    def bus27; @bus27 ||= "#9fc207".to_color; end
    def bus30; @bus30 ||= "#ffdd00".to_color; end
    def bus66; @bus66 ||= "#cfb1d1".to_color; end

    alias :bus2   :tramA
    alias :bus6A  :bus6
    alias :bus6B  :bus6
    alias :bus70  :bus10
    alias :bus70A :bus10
    alias :bus22  :bus12
    alias :bus14  :bus12
    alias :bus24  :bus12
    alias :bus15A :bus12
    alias :bus21  :bus12
    alias :bus71  :bus12
    alias :bus17  :bus13
    alias :bus19  :bus13
    alias :bus31  :bus13
    alias :bus62  :bus13
    alias :bus63  :bus13
    alias :bus65  :bus13
    alias :bus72  :bus13
    alias :bus40  :bus30
    alias :bus50  :bus30

    ## CatchAll
    def method_missing(name, *args, &block)
      if name.to_s.start_with?('bus')
        tramA
      end
    end
  end
end
