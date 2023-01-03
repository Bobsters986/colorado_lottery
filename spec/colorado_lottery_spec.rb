require './lib/contestant'
require './lib/game'
require './lib/colorado_lottery'

RSpec.describe ColoradoLottery do
  let(:lottery) { ColoradoLottery.new }

  let(:mega_millions) { Game.new('Mega Millions', 5, true) }
  let(:pick_4) { Game.new('Pick 4', 2) }
  let(:cash_5) { Game.new('Cash 5', 1) }

  let(:alexander) do 
    Contestant.new({first_name: 'Alexander',
                                      last_name: 'Aigiades',
                                      age: 28,
                                      state_of_residence: 'CO',
                                      spending_money: 10})
  end

  let(:benjamin) do 
    Contestant.new({first_name: 'Benjamin',
                                      last_name: 'Franklin',
                                      age: 17,
                                      state_of_residence: 'PA',
                                      spending_money: 100})
  end

  let(:frederick) do 
    Contestant.new({first_name: 'Frederick',
                                      last_name: 'Douglass',
                                      age: 55,
                                      state_of_residence: 'NY',
                                      spending_money: 20})
  end

  let(:winston) do 
    Contestant.new({first_name: 'Winston',
                                      last_name: 'Churchill',
                                      age: 18,
                                      state_of_residence: 'CO',
                                      spending_money: 5})
  end

  let(:grace) do 
    Contestant.new({first_name: 'Grace',
                                      last_name: 'Hopper',
                                      age: 20,
                                      state_of_residence: 'CO',
                                      spending_money: 20})
  end

  before do
    alexander.add_game_interest('Pick 4')
    alexander.add_game_interest('Mega Millions')
    frederick.add_game_interest('Mega Millions')
    winston.add_game_interest('Cash 5')
    winston.add_game_interest('Mega Millions')
    benjamin.add_game_interest('Mega Millions')
    grace.add_game_interest('Mega Millions')
    grace.add_game_interest('Cash 5')
    grace.add_game_interest('Pick 4')
  end

  describe "initialize" do
    it 'exists' do
      expect(lottery).to be_an_instance_of(ColoradoLottery)
    end

    it 'has attributes' do
      expect(lottery.registered_contestants).to eq({})
      expect(lottery.winners).to eq([])
      expect(lottery.current_contestants).to eq({})
      
    end
  end

  describe "interested_and_18" do
    it 'returns true' do
      expect(lottery.interested_and_18?(alexander, pick_4)).to eq(true)
      expect(lottery.interested_and_18?(benjamin, mega_millions)).to eq(false)
      expect(lottery.interested_and_18?(alexander, cash_5)).to eq(false)
    end
  end

  describe "#can_register?" do
    it 'returns true when 18_and_interested, CO resident, or natl game' do
      expect(lottery.can_register?(alexander, pick_4)).to eq(true)
      expect(lottery.can_register?(alexander, cash_5)).to eq(false)
      expect(lottery.can_register?(frederick, mega_millions)).to eq(true)
      expect(lottery.can_register?(benjamin, mega_millions)).to eq(false)
      expect(lottery.can_register?(frederick, cash_5)).to eq(false)
    end
  end

  describe '#register_contestant' do
    it "can register a contestant" do
      lottery.register_contestant(alexander, pick_4)
      expect(lottery.registered_contestants).to eq({ 'Pick 4' => [alexander] })

      lottery.register_contestant(alexander, mega_millions)
      expect(lottery.registered_contestants).to eq({ 'Pick 4' => [alexander], 'Mega Millions' => [alexander] })
      
      lottery.register_contestant(frederick, mega_millions)
      lottery.register_contestant(winston, cash_5)
      lottery.register_contestant(winston, mega_millions)

      expected_hash = {
        'Pick 4' => [alexander],
        'Mega Millions' => [alexander, frederick, winston],
        'Cash 5' => [winston]
      }

      expect(lottery.registered_contestants).to eq(expected_hash)

      lottery.register_contestant(grace, mega_millions)
      lottery.register_contestant(grace, cash_5)
      lottery.register_contestant(grace, pick_4)

      expected_hash = {
        'Pick 4' => [alexander, grace],
        'Mega Millions' => [alexander, frederick, winston, grace],
        'Cash 5' => [winston, grace]
      }

      expect(lottery.registered_contestants).to eq(expected_hash)
    end
  end

  describe '#eligible_contestants' do
    it 'returns an array of registered contestants w/ enough money' do
      lottery.register_contestant(alexander, pick_4)
      lottery.register_contestant(alexander, mega_millions)
      lottery.register_contestant(frederick, mega_millions)
      lottery.register_contestant(winston, cash_5)
      lottery.register_contestant(winston, mega_millions)
      lottery.register_contestant(grace, mega_millions)
      lottery.register_contestant(grace, cash_5)
      lottery.register_contestant(grace, pick_4)

      expect(lottery.eligible_contestants(pick_4)).to eq([alexander, grace])
      expect(lottery.eligible_contestants(cash_5)).to eq([winston, grace])
      expect(lottery.eligible_contestants(mega_millions)).to eq([alexander, frederick, winston, grace])
    end
  end

  describe '#charge_contestants' do
    before do
      lottery.register_contestant(alexander, pick_4)
      lottery.register_contestant(alexander, mega_millions)
      lottery.register_contestant(frederick, mega_millions)
      lottery.register_contestant(winston, cash_5)
      lottery.register_contestant(winston, mega_millions)
      lottery.register_contestant(grace, mega_millions)
      lottery.register_contestant(grace, cash_5)
      lottery.register_contestant(grace, pick_4)
    end

    it 'charges the contestant and add to current_contestants hash' do
      lottery.charge_contestants(cash_5)

      expected_hash = {
        cash_5 => [winston.full_name, grace.full_name]
      }
      
      expect(lottery.current_contestants).to eq(expected_hash)
      expect(grace.spending_money).to eq(19)
      expect(winston.spending_money).to eq(4)

      lottery.charge_contestants(mega_millions)

      expected_hash2 = {
        cash_5 => [winston.full_name, grace.full_name],
        mega_millions => [alexander.full_name, frederick.full_name, grace.full_name]
      }

      expect(alexander.spending_money).to eq(5)
      expect(frederick.spending_money).to eq(15)
      expect(lottery.current_contestants).to eq(expected_hash2)
    end
  end

  describe "#draw_winners" do
    before do
      lottery.register_contestant(alexander, pick_4)
      lottery.register_contestant(alexander, mega_millions)
      lottery.register_contestant(frederick, mega_millions)
      lottery.register_contestant(winston, cash_5)
      lottery.register_contestant(winston, mega_millions)
      lottery.register_contestant(grace, mega_millions)
      lottery.register_contestant(grace, cash_5)
      lottery.register_contestant(grace, pick_4)

      lottery.charge_contestants(cash_5)
      lottery.charge_contestants(mega_millions)
      lottery.charge_contestants(pick_4)
    end

    it 'returns the date of the drawing' do
      expect(lottery.draw_winners).to eq(Time.now.strftime("%Y-%m-%d"))
      expect(lottery.winners).to_not be_empty
      expect(lottery.winners.first).to be_a(Hash)
      expect(lottery.winners.last).to be_a(Hash)
      expect(lottery.winners.length).to eq(3)
    end
  end

  # describe "#announce_winner" do
  #   before do
  #     lottery.register_contestant(alexander, pick_4)
  #     lottery.register_contestant(alexander, mega_millions)
  #     lottery.register_contestant(frederick, mega_millions)
  #     lottery.register_contestant(winston, cash_5)
  #     lottery.register_contestant(winston, mega_millions)
  #     lottery.register_contestant(grace, mega_millions)
  #     lottery.register_contestant(grace, cash_5)
  #     lottery.register_contestant(grace, pick_4)

  #     lottery.charge_contestants(cash_5)
  #     lottery.charge_contestants(mega_millions)
  #     lottery.charge_contestants(pick_4)
  #   end

  #   it "returns a string with gam, winner, and date" do

  #     winners = [
  #       { grace.full_name => 'Pick 4' },
  #       { winston.full_name => 'Cash 5' },
  #       { frederick.full_name => 'Mega Millions' }
  #     ]
  #     lottery.draw_winners

  #     allow(lottery).to receive(:draw_winners).and_return(winners)

  #     expect(lottery.announce_winner('Pick 4')).to eq("Grace Hopper won the Pick 4 on 01/02")
  #     expect(lottery.announce_winner('Cash 5')).to eq("Winston Churchill won the Cash 5 on 01/02")
  #     expect(lottery.announce_winner('Mega Millions')).to eq("Frederick Douglass won the Mega Millions on 01/02")
  #   end

  # end
end