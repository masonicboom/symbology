# Sound is produced when something vibrates.
class Vibrator
  
  # The overtone series is the set of pitches produced when the string
  # vibrates. Override this.
  def overtones
    []
  end
  
  def fundamental
    overtones[0]
  end
  
end

class MusicalString < Vibrator
  
  def initialize(length)
    @length = length
  end
  
end

class Pipe < Vibrator
  
  # The overtones of a pipe depend on its length and whether it's open or
  # closed.
  def initialize(length, is_open)
    @length = length
    @is_open = is_open
  end
  
end

class Instrument
  
  @vibrators = []
  
end
