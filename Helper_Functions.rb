module HelperFunctions
  
  def filter(item_array, criteria)
    if criteria.is_a?(Class)
      filter_by_class(item_array, criteria)
    else
      filter_by_type(item_array, criteria)
    end
  end

  def filter_by_type(item_array, item_type)
    item_array.select{|item| item.type == item_type}
  end

  def filter_by_class(item_array, class_type)
    item_array.select{|item| item.class == class_type}
  end

  def cooldown(weapon_cooldown, show = true)
    Proc.new do
      wait_time = rand(1) + weapon_cooldown
      counter = wait_time

      wait_time.times do
        seconds = []
        counter.times {seconds << "[]"}
        puts seconds.join("").display if show
        sleep(1)
        counter -= 1
      end

      puts "Ready!".display
    end
  end

  def positions
    {nil => 0, :first => 0, :second => 1, :third => 2, :fourth => 3,
      :fifth => 4, :sixth => 5, :seventh => 6, :eighth => 7,
      :ninth => 8, :tenth => 9}
  end
end

class String
  def add_article
    vowels = %w{a e i o u}
    if vowels.include?(self[0])
      "an " + self
    else
      "a " + self
    end
  end

  def display
    "         " + self
  end
end

class Integer
  def at_least(floor)
    self < floor ? floor : self
  end

  def at_most(ceiling)
    self > ceiling ? ceiling : self
  end
end
