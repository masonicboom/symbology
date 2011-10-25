require 'test/unit'


class Pitch
  
  NOTE_OFFSETS = {
    'A' => 0,
    'A#' => 1,
    'Bb' => 1,
    'B' => 2,
    'Cb' => 2,
    'C' => 3,
    'C#' => 4,
    'Db' => 4,
    'D' => 5,
    'D#' => 6,
    'Eb' => 6,
    'E' => 7,
    'Fb' => 7,
    'F' => 8,
    'E#' => 8,
    'F#' => 9,
    'Gb' => 9,
    'G' => 10,
    'G#' => 11,
    'Ab' => 11,
  }
  OFFSET_NAMES = {
    0 => { :natural => 'A' },
    1 => { :sharp => 'A#', :flat => 'Bb' },
    2 => { :natural => 'B', :flat => 'Cb' },
    3 => { :natural => 'C' },
    4 => { :sharp => 'C#', :flat => 'Db' },
    5 => { :natural => 'D' },
    6 => { :sharp => 'D#', :flat => 'Eb' },
    7 => { :natural => 'E', :flat => 'Fb' },
    8 => { :natural => 'F', :sharp => 'E#' },
    9 => { :sharp => 'F#', :flat => 'Gb' },
    10 => { :natural => 'G' },
    11 => { :sharp => 'G#', :flat => 'Ab' },
  }
  SCIENTIFIC_NOTE_NAMES = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E',  'F', 'F#', 'G', 'G#']
  
  attr_reader :midi_number
  
  def initialize(notation, accidental_bias=nil)
    @accidental_bias = accidental_bias # should be either :sharp or :flat
    
    if notation.class == Fixnum or notation.class == Float
      initialize_from_midi_number(notation)
    elsif notation.class == String
      initialize_from_scientific_notation(notation)
    else
      raise "Unrecognized pitch notation: #{notation}."
    end
  end
  
  def initialize_from_midi_number(midi_number)
    @midi_number = midi_number.to_int
  end
  
  def initialize_from_scientific_notation(notation)
    match = /(?<name>[A-G])(?<octave>\d)(?<accidental>[\#b])?/.match(notation)
    raise "Unrecognized pitch notation: #{notation}." unless match
    
    name = "#{match[:name]}#{match[:accidental]}"
    @midi_number = 21 + match[:octave].to_i*12 + NOTE_OFFSETS[name]
  end
  
  def octave
    (@midi_number-21) / 12
  end
  
  def offset
    (@midi_number-21) % 12
  end
  
  def scientific_name
    SCIENTIFIC_NOTE_NAMES[offset]
  end
  
  def scientific_notation
    n = scientific_name
    "#{n[0]}#{octave}#{n[1]}"
  end
  
  def to_s
    name = OFFSET_NAMES[offset][@accidental_bias] || scientific_name
    "#{name[0]}#{octave}#{name[1]}"
  end
  
  def +(semitones)
    Pitch.new(@midi_number + semitones)
  end
  
  def -(semitones)
    Pitch.new(@midi_number - semitones)
  end
  
  def flat
    self - 1
  end
  
  def sharp
    self + 1
  end
  
  def ==(other)
    @midi_number == other.midi_number
  end
  
  def enharmonic_name
    name = OFFSET_NAMES[offset][@accidental_bias] || scientific_name
    en = (OFFSET_NAMES[offset].values - [name]).first
    "#{en[0]}#{octave}#{en[1]}"
  end
  
end

MIDDLE_C = Pitch.new(60)
A440 = Pitch.new(69)


class MajorScale

  def initialize(root)
    
  end

end


def scale(steps)
  lambda do |root|
    prev = root
    steps.map { |whole_steps| prev = prev + whole_steps*2 }
  end
end

major_scale = scale([0, 1, 1, 0.5, 1, 1, 1, 0.5])
chromatic_scale = scale([0] + [0.5]*12)

chromatic_scale.call(Pitch.new('C3')).each {|root| p major_scale.call(root)}


class PitchTester < Test::Unit::TestCase
  
  def test_initialize_by_midi_number_works
    Pitch.new(60)
  end
  
  def test_initialize_by_scientific_notation_works
    assert_equal Pitch.new('A0').midi_number, 21
    assert_equal Pitch.new('C3').midi_number, 60
  end
  
  def test_equivalence_of_midi_and_scientific_notation
    assert_equal Pitch.new(60), Pitch.new('C3')
  end
  
  def test_sharp_and_flat_work
    assert_equal Pitch.new(60).sharp, Pitch.new(62).flat
  end
  
  def test_initialize_with_flat_works
    assert_equal Pitch.new('A4#'), Pitch.new('B4b')
  end
  
  def test_enharmonic_name
    assert_equal Pitch.new('A4#').enharmonic_name, 'B4b'
  end
  
end
