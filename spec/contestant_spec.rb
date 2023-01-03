require './lib/contestant'

RSpec.describe do Contestant
  let(:alexander) do 
    Contestant.new({first_name: 'Alexander',
                                      last_name: 'Aigiades',
                                      age: 28,
                                      state_of_residence: 'CO',
                                      spending_money: 10})
  end

  describe '#initialize' do
    it 'exists' do
      expect(alexander).to be_an_instance_of(Contestant)
    end

    it 'has attributes' do
      expect(alexander.full_name).to eq("Alexander Aigiades")
      expect(alexander.age).to eq(28)
      expect(alexander.state_of_residence).to eq("CO")
      expect(alexander.spending_money).to eq(10)
      expect(alexander.game_interests).to eq([])
    end
  end

  describe '#out_of_state?' do
    it 'should return false when resident of CO' do
      expect(alexander.out_of_state?).to be false
    end
  end

  describe '#add_game_interests' do
    it 'can add games of interest' do
      alexander.add_game_interest('Mega Millions')
      alexander.add_game_interest('Pick 4')
      expect(alexander.game_interests).to eq(['Mega Millions', 'Pick 4'])
    end
  end

end