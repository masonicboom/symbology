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
    'Ab' => 11
  }
  SCIENTIFIC_NOTE_NAMES = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E',  'F', 'F#', 'G', 'G#']
  
  attr_reader :midi_number
  
  def initialize(notation)
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
    (@midi_number-21)/12
  end
  
  def scientific_name
    SCIENTIFIC_NOTE_NAMES[(@midi_number-21) % 12]
  end
  
  def scientific_notation
    n = scientific_name
    "#{n[0]}#{octave}#{n[1]}"
  end
  
  def to_s
    scientific_notation
  end
  
  def offset(whole_steps)
    midi_offset = whole_steps * 2
    Pitch.new(@midi_number + midi_offset)
  end
  
  def flat
    offset(-0.5)
  end
  
  def sharp
    offset(0.5)
  end
  
  def ==(other)
    @midi_number == other.midi_number
  end
  
end

MIDDLE_C = Pitch.new(60)
A440 = Pitch.new(69)


def scale(steps)
  lambda do |root|
    prev = root
    steps.map { |whole_steps| prev = prev.offset(whole_steps) }
  end
end

major_scale = scale([0, 1, 1, 0.5, 1, 1, 1, 0.5])
chromatic_scale = scale([0] + [0.5]*12)

chromatic_scale.call(Pitch.new('C3')).each {|root| p major_scale.call(root)}


class PitchTester < Test::Unit::TestCase
  
  def setup
  end

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
  
end