class Item
end

class Weapon < Item
  attr_accessor :type, :cooldown, :value, :defense, :level_dif

  def initialize(game, level)
    @game = game
    @level = level
    @type = random_type
    @value = @level ** 2
    set_attributes
  end

  def set_attributes
    set_level
    set_display_name
    set_type_attributes
  end

  def set_level
    @level_dif = [-3, -3, -2, -2, -2, -1, -1, -1, -1, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3].sample
    @level = (@level + @level_dif).at_least(1)
    @level_health = (15 + @level ** 1.65).to_i
  end

  def random_type
    [:sword, :axe, :staff].sample
  end

  def set_type_attributes
    case @type
    when :sword
      @range = (10..65).to_a; @defense = 20; @cooldown = 2
    when :axe
      @range = (40..50).to_a; @defense = 10; @cooldown = 3
    when :staff
      @range = [35]; @defense = 30; @cooldown = 1
    end
  end

  def get_attack
    (@range.sample.to_f / 100 * @level_health).to_i
  end

  def inspect
    min = (@range.first.to_f / 100 * @level_health).to_i
    max = (@range.last.to_f / 100 * @level_health).to_i
    puts "--------#{self}--------".display
    puts "Damage: #{min}-#{max}".display
    puts "------------------------------".display
  end

  def set_display_name
    adjective = ["old", "large", "heavy", "dark", "bright",
    "dented", "light"].sample

    @display_name = [adjective, quality, noun].compact.join(" ")
  end

  def noun
    case @type
    when :sword
      ["longsword", "shortsword", "claymore"].sample
    when :axe
      ["battle axe", "hatchet", "broad axe", "pollaxe"].sample
    when :staff
      "staff"
    end
  end

  def quality
    case @level_dif
    when -3
      "broken"
    when -2
      "battered"
    when -1
      "worn"
    when 0
      nil
    when 1
      "honed"
    when 2
      "perfectly-balanced"
    when 3
      "valyrian steel"
    end
  end

  def to_s
    @display_name
  end
end

class Food < Item
  attr_accessor :type, :health_value

  def initialize(game)
    @type = random_type
    level_health = 15 + game.level ** 2
    @health_value = (level_health * (10..50).to_a.sample / 100.to_f).to_i
    @display_name = random_display_name
  end

  def random_type
    [:apple, :bread, :jerky, :ale].sample
  end

  def random_display_name
    case @type
    when :apple
      ["moldy ", "", "small ", "large "].sample + @type.to_s
    when :bread
      ["hunk of ", "stale piece of ", "loaf of "].sample + @type.to_s
    when :jerky
      "scrap of " + @type.to_s
    when :ale
      ["pint of ", "half pint of "].sample + @type.to_s
    end
  end

  def to_s
    @display_name
  end
end
