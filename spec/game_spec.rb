require './lib/game'

RSpec.describe Game do
  let(:mega_millions) { Game.new('Mega Millions', 5, true) }
  let(:pick_4) { Game.new('Pick 4', 2) }

  describe "#initialize" do
    it 'exists' do
      expect(mega_millions).to be_an_instance_of(Game)
    end

    it 'has attributes' do
      expect(mega_millions.name).to eq("Mega Millions")
      expect(mega_millions.cost).to eq(5)
    end
  end

  describe "#national_drawing?" do
    it 'returns false when not given' do
      expect(pick_4.national_drawing?).to eq(false)
    end

    it 'returns true when given' do
      expect(mega_millions.national_drawing?).to eq(true)
    end
  end

end