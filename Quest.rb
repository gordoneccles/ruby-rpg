class Quest
  attr_accessor :item_type

  def initialize(game)
    @game = game
    @item_type = [:staff, :sword, :axe].sample
    @first_time = true
  end

 def description
   if @first_time
     @first_time = false
     "A friend of mine is in need of #{@item_type.to_s.add_article}. Please, find one and bring it to her!"
   else
     "Have you brought the #{@item_type} to my friend?"
   end
 end

 def attempt_turn_in(inventory)
   item = match_item(inventory)

   if item
     puts "What? You brought me #{@item_type.to_s.add_article}? Thank you! Here, please take this in return!".display
     @game.turn_in(item)
   else
     puts "I could really use #{@item_type.to_s.add_article}...".display
   end
 end

 def match_item(inventory)
   inventory.select{|item| item.type == @item_type}.first
 end
end
