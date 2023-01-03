class Contestant
  attr_reader :full_name,
              :age,
              :state_of_residence,
              :spending_money,
              :game_interests

  def initialize(info)
   @full_name = "#{info[:first_name]} #{info[:last_name]}"
   @age = info[:age]
   @state_of_residence = info[:state_of_residence]
   @spending_money = info[:spending_money]
   @game_interests = []
  end

  def out_of_state?
    @state_of_residence != "CO"
  end

  def add_game_interest(game_name)
    @game_interests << game_name
  end

end