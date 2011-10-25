class TimeSignature
  
  def initialize(beats_per_measure, beat_note_denominator)
    @beats_per_measure = beats_per_measure
    @beat_note_denominator = beat_note_denominator
  end
  
  def simple_time?
    @beats_per_measure % 2 == 0
  end
  
  def compound_time?
    @beats_per_measure % 2 == 0
  end
  
end

COMMON_TIME = TimeSignature.new(4, 4)
ALLA_BREVE = TimeSignature.new(2, 2)