require './Map.rb'
require './Items.rb'
require './Characters.rb'
require './Player.rb'
require './BigText.rb'
require './Interface.rb'
require './Quest.rb'

class Game
  attr_accessor :level, :map, :player
  include Interface
  include BigText

  def initialize
    @level = 1
    @map = Map.new(self)
    @player = Player.new(self)
    populate_map
    location.display
    play
  end

  def populate_map
    setup_enemies
    setup_items
    setup_vendors
    setup_quest
  end

  def setup_quest
    giver_location = map.random_walk_from(location, 400)
    QuestGiver.new(self, giver_location)
  end

  def random_walk_from(location, steps)
    map.random_walk_from(location, steps)
  end

  def setup_enemies
    enemy_area = (@map.area * 0.33).to_i
    enemy_area.times {Enemy.new(self)}
  end

  def setup_vendors
    4.times {Vendor.new(self)}
  end

  def setup_items
    item_area = (@map.area * 0.05).to_i
    item_area.times do
      random_location.add_item(Weapon.new(self, @level))
    end
  end

  def new_weapon(level = @level)
    Weapon.new(self, level)
  end

  def new_food
    Food.new(self)
  end

  def random_location
    location = @map.random_location
    location = @map.random_location until !location.neighbors.empty?
    location
  end

  def play
    loop do
      action = get_command(self)
      action.call
    end
  end

  def move(input)
    next_room = location.neighbors[input.to_sym]

    if next_room.nil?
      puts "You can't move there!".display
    else
      @player.location = next_room
      location.display
      queue_enemies
    end
  end

  def queue_enemies
    return if location.enemies.empty?
    location.queue_enemies
  end

  def attack_player(enemy, damage)
    @player.take_hit(enemy, damage)
  end

  def interpret(input, &proc)
    input = input.split(" ").map!{|word| word.downcase.to_sym}
    object_type = input.last

    if input.count == 1
      proc.call
    elsif input.count > 2
      which = input[-2]
      proc.call(object_type, which)
    else
      proc.call(object_type)
    end
  end

  def get(input)
    item = interpret(input) do |item_type, which|
      location.get_item(item_type, which)
    end

    @player.add_item(item) if item.is_a?(Item)
  end

  def attack_enemy(input)
    damage = @player.get_attack

    target = interpret(input) do |enemy_type, which|
      location.get_enemy(enemy_type, which)
    end

    attack(target, damage) if target.is_a?(Enemy) && damage.is_a?(Integer)
  end

  def inspect(input)
    interpret(input) do |item_type, which|
      location.inspect(item_type, which)
    end
  end

  def equip(input)
    interpret(input) do |item_type, which|
      @player.equip(item_type, which)
    end
  end

  def compare(input)
    interpret(input) do |item_type, which|
      @player.compare(item_type, which)
    end
  end

  def drop(input)
    item = interpret(input) do |item_type, which|
      @player.drop(item_type, which)
    end

    return if item.nil?

    location.add_item(item)
    puts "You drop the #{item}".display
  end

  def sell(input)
    item = interpret(input) do |item_type, which|
      @player.sell(item_type, which)
    end

    return if item.nil?

    if location.vendor.nil?
      puts "There's no one here to sell to.".display
      @player.add_item(item)
    elsif !location.vendor.afford?(item)
      puts "The trader can't afford that item.".display
      @player.add_item(item)
    else
      money = location.vendor.buy(item)
      @player.add_money(money)
      puts "You sell the #{item} for #{money} silver.".display
    end
  end

  def give_quest
    location.give_quest
  end

  def turn_in_quest
    location.turn_in_quest
  end

  def inventory
    @player.inventory
  end

  def turn_in(item)
    @player.add_money(item.value)
    puts "You received #{item.value} silver.".display
    @player.inventory.delete(item)
    level_up
  end

  def display_money
    @player.display_money
  end

  def display_level
    puts "You are level #{@level}.".display
  end

  def hide
    @player.hide
  end

  def player_hidden?
    @player.hidden
  end

  def eat
    @player.eat
  end

  def attack(target, damage)
    target.take_hit(damage)
  end

  def destroy_enemy(enemy)
    @player.add_exp( (enemy.level ** 1.6).to_i )
    enemy.location.remove_enemy(enemy)
  end

  def level_up
    @level += 1
    @map.wipe
    @player.reset_attributes
    populate_map
    puts "You reached level #{level}!".display
  end

  def location
    @player.location
  end

  def look
    location.display
  end

  def display_map
    @map.display(location)
  end

  def display_inventory
    @player.display_inventory
  end

  def display_health
    @player.display_health
  end

  def display_exp
    @player.display_exp
  end

  def positions_hash
    {nil => 0, :first => 0, :second => 1, :third => 2, :fourth => 3,
      :fifth => 4, :sixth => 5, :seventh => 6, :eighth => 7,
      :ninth => 8, :tenth => 9}
  end

  def restart
    puts "You reached level #{@level} and then...".display
    puts death
    puts "New game..."
    @level = 1
    @map = Map.new(self)
    @player = Player.new(self)
    populate_map
    location.display
  end
end

g = Game.new
