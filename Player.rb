class Player
  include HelperFunctions

  attr_accessor :location, :level, :hidden, :inventory

  def initialize(game)
    @game = game
    @location = @game.random_location
    @weapon = @game.new_weapon
    @inventory = []
    @capacity = 10
    @attack_cooldown = Thread.new{}
    @hiding_cooldown = Thread.new{}
    @vulnerability_cooldown = Thread.new{}
    reset_attributes
    @hidden = false
    @money = 0
  end

  def reset_attributes
    @level = @game.level
    @max_health = (20 + @level**2.05).to_i
    @health = @max_health
    @attack = @game.level
    @exp_to_level = (@game.level ** 3).to_i
    @exp = 0
  end

  def defense
    @vulnerability_cooldown.alive? ? @weapon.defense : 80
  end

  def get_attack
    multiplier = get_multiplier
    @hidden = false

    if !@attack_cooldown.alive?
      weapon_cooldown = @weapon.cooldown

      @attack_cooldown = Thread.new(weapon_cooldown) do |weapon_cooldown|
        cooldown(weapon_cooldown).call
      end

      @vulnerability_cooldown = Thread.new{sleep(1)}

      multiplier * ( @weapon.get_attack * ( 1 + @attack.to_f / 100 ) ).to_i
    else
      puts "You can't do that yet!".display
    end
  end

  def take_hit(enemy, damage)
    final_damage = ( damage * ( 1 - defense.to_f / 100 ) ).to_i
    puts "The #{enemy} hit you for #{final_damage} points!".display
    @health -= final_damage
    display_health
    die if dead?
  end

  def get_item(item_type, which, class_type = Item)
    items = filter(@inventory, class_type)

    if item_type.nil?
      items.first
    else
      filter(items, item_type)[positions[which]]
    end
  end

  def inspect(weapon_type, which)
    weapon = get_item(weapon_type, which, Weapon)

    unless weapon.nil?
      puts "Compared to:".display
      weapon.inspect
    end
  end

  def compare(weapon_type, which)
    puts
    puts "Your weapon:".display
    @weapon.inspect
    puts
    inspect(weapon_type, which)
  end

  def equip(weapon_type, which)
    weapon = get_item(weapon_type, which, Weapon)

    unless weapon.nil?
      @inventory << @weapon; @weapon = weapon
      @inventory.delete(weapon)
      puts "You equip the #{weapon}".display
    end
  end

  def eat
    food = filter(@inventory, Food).first

    if food.nil?
      puts "You don't have anything to eat!".display
    else
      @health = (@health + food.health_value).at_most(@max_health)
      display_health
      @inventory.delete(food)
    end
  end

  def drop(item_type, which)
    if @inventory.empty?
      return puts "You don't have anything to drop.".display
    end

    if item_type.nil?
      item = @inventory.shift
    else
      item = filter(@inventory, item_type)[positions[which]]
      @inventory.delete(item)
    end

    item
  end

  def sell(item_type, which)
    items_to_sell = filter(@inventory, Weapon)

    if items_to_sell.empty?
      return puts "You don't have anything to sell.".display
    end

    if item_type.nil?
      item = items_to_sell.shift
      @inventory.delete(item)
    else
      item = filter(items_to_sell, item_type)[positions[which]]
      @inventory.delete(item)
    end

    item
  end

  def hide
    if !@hiding_cooldown.alive?
      @hiding_cooldown = Thread.new {cooldown(15, false).call}
      roll = rand(101)

      if roll > 50
        @hidden = true
        puts "You slip into the shadows."
      else
        puts "You failed to hide!"
      end

    else
      puts "You can't do that yet."
    end
  end

  def add_item(item)
    if @inventory.count < @capacity
      puts "You stow the #{item.type}.".display
      @inventory << item
    else
      puts "You don't have room for that!".display
      @location.add_item(item)
    end
  end

  def display_inventory
    puts "-----------Backpack-----------"
    @inventory.each {|item| puts item.to_s}
    puts "------------------------------"
  end

  def add_exp(amount)
    @exp += amount
    level_up if @exp > @exp_to_level
  end

  def level_up
    @game.level_up
  end

  def add_money(money)
    @money += money
  end

  def display_money
    puts "You have #{@money} silver.".display
  end

  def dead?
    @health <= 0
  end

  def die
    puts "You died!"
    @game.restart
  end

  def display_health
    health_bar = []
    health_bar << "(#{@health}/#{@max_health}): "
    @health.times {health_bar << "H"}
    (@max_health - @health).times {health_bar << "-"}
    puts health_bar.join("").display
  end

  def display_exp
    exp_bar = []
    exp_bar << "(#{@exp}/#{@exp_to_level}): "
    percentage = (@exp.to_f / @exp_to_level * 100).to_i
    percentage.times {exp_bar << "X"}
    (100 - percentage).times {exp_bar << "-"}
    puts exp_bar.join("").display
  end

  def get_multiplier
    @hidden ? 2 : 1
  end
end
