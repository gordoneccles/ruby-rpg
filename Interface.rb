module Interface

  def get_command(game)
    input = gets.chomp

    if ["n", "s", "e", "w", "ne", "nw", "se", "sw"].include?(input)
      Proc.new {game.move(input)}
    elsif input == "a" || input.match("att")
      Proc.new {game.attack_enemy(input)}
    elsif input == "g" || input.match("get")
      Proc.new {game.get(input)}
    elsif input == "m" || input.match("map")
      Proc.new {game.display_map}
    elsif input == "h" || input.match("health")
      Proc.new {game.display_health}
    elsif input == "i" || input.match("inv")
      Proc.new {game.display_inventory}
    elsif input == "l" || input.match("look")
      Proc.new {game.look}
    elsif input.match("ins")
      Proc.new {game.inspect(input)}
    elsif input.match("equi")
      Proc.new {game.equip(input)}
    elsif input == "eat"
      Proc.new {game.eat}
    elsif input.match("compare")
      Proc.new {game.compare(input)}
    elsif input.match("drop")
      Proc.new {game.drop(input)}
    elsif input.match("hide")
      Proc.new {game.hide}
    elsif input.match("sell")
      Proc.new {game.sell(input)}
    elsif input.match("money")
      Proc.new {game.display_money}
    elsif input == "lvl"
      Proc.new {game.display_level}
    elsif input == "exp"
      Proc.new {game.display_exp}
    elsif input.match("talk")
      Proc.new {game.give_quest}
    elsif input.match("turn in")
      Proc.new {game.turn_in_quest}
    else
      Proc.new {}
    end
  end
end
