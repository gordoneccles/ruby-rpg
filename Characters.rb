require './Quest.rb'

class Enemy
  attr_accessor :level, :location, :type

  def initialize(game)
    @game = game
    set_level
    @location = @game.random_location
    @location.add_enemy(self)
    @type = random_type
    setup_food
    @weapon = @game.new_weapon(@level)
    set_attributes
    @fighting = Thread.new{}
    @vulnerable = Thread.new{}
  end

  def set_level
    @level_dif = [-3, -2, -2, -1, -1, -1, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3].sample
    @level = (@game.level + @level_dif).at_least(1)
  end

  def set_attributes
    @health =  10 + @level**2
    @max_health = @health
    @attack = @level
    @display_name = [difficulty, @type.to_s].compact.join(" ")
  end

  def defense
    if !@location.player_openly_here?
      @weapon.defense
    elsif @vulnerable.alive?
      @weapon.defense
    else
      60
    end
  end

  def setup_food
    @foods = []
    rand(5).times {@foods << @game.new_food}
  end

  def difficulty
    case @level_dif
    when -3
      "dying"
    when -2
      "crippled"
    when -1
      "young"
    when 0
      nil
    when 1
      "seasoned"
    when 2
      "grizzled"
    when 3
      "giant"
    end
  end

  def start_fighting
    cooldown = @weapon.cooldown
    @fighting = Thread.new(cooldown) do |cooldown|
      while @location.player_openly_here?
        sleep (rand(2) + cooldown)
        break if !alive? || !@location.player_openly_here?
        @game.attack_player(self, get_attack)
        @vulnerable = Thread.new{sleep(1)}
      end
    end
  end

  def take_hit(damage)
    final_damage = ( damage * ( 1 - defense.to_f / 100 ) ).to_i
    @health -= final_damage
    puts "You hit the #{@type} for #{final_damage} points!".display
    display_health
    start_fighting if !@fighting.alive? && alive?
    die if !alive?
  end

  def display_health
    health_bar = []
    health_bar << "(#{@health}/#{@max_health}): "
    @health.times {health_bar << "E"}
    (@max_health - @health).times {health_bar << "-"}
    puts health_bar.join("").display
  end

  def alive?
    @health > 0
  end

  def die
    roll = rand(101)
    puts "The #{@display_name} is dead!".display
    @location.items << @weapon if roll > 50
    @foods.each{|food| @location.items << food}
    @game.destroy_enemy(self)
  end

  def random_type
    [:whitewalker, :wildling, :wildling, :wildling, :wildling].sample
  end

  def get_attack
    ( @weapon.get_attack * ( 1 + @attack.to_f / 100 ) ).to_i
  end

  def add_food(food)
    @foods << food
  end

  def to_s
    @display_name
  end
end

class Vendor
  def initialize(game)
    @game = game
    setup_location
    setup_items
    @money = (game.level ** 2) * 3
  end

  def setup_items
    @items = []
    rand(3).times {@items << @game.new_weapon}
  end

  def setup_location
    @location = @game.random_location
    @location = @game.random_location until @location.vendor.nil?
    @location.add_vendor(self)
  end

  def buy(item)
    @items << item
    money = item.value
    @money -= money
    raise "Vendor's money is negative." if @money < 0
    money
  end

  def afford?(item)
    @money - item.value > 0
  end
end

class QuestGiver
  attr_accessor :quest

  def initialize(game, location)
    @game = game
    @location = location
    @location.add_questgiver(self)
    @quest = Quest.new(@game)
    @quest_given = false
  end

  def start_quest
    puts @quest.description.display

    unless @quest_given
      receiver_location = @game.random_walk_from(@location, 400)
      QuestReceiver.new(@game, receiver_location, @quest)
    end
  end
end

class QuestReceiver
  def initialize(game, location, quest)
    @game = game
    @location = location
    @location.add_questreceiver(self)
    @quest = quest
  end

  def turn_in_quest
    inventory = @game.inventory
    @quest.attempt_turn_in(inventory)
  end
end
