require './Helper_Functions.rb'
require './BigText'

class Map
  attr_accessor :grid

  def initialize(game)
    @game = game
    @grid = Array.new(30){Array.new(60)}
    @types = [:forest, :field, :water]
    setup_rooms
  end

  def setup_rooms
    generate_rooms
    populate_room_types
    connect_rooms
  end

  def area
    @grid.count * @grid.first.count
  end

  def wipe
    wipe_items
    wipe_enemies
    wipe_vendors
    wipe_quest
  end

  def random_location
    room = @grid.flatten.sample
    if room.water?
      return random_location
    else
      return room
    end
  end

  def random_walk_from(room, steps)
    return room if steps == 0

    next_room = room.neighbors.values.sample
    random_walk_from(next_room, steps - 1)
  end

  def [](coords)
    y = coords[0]; x = coords[1]
    @grid[y][x]
  end

  def generate_rooms
    new_grid = Array.new(@grid.length){Array.new(@grid.first.length)}

    @grid.each_with_index do |row, y|
      row.each_with_index do |ele, x|
        new_grid[y][x] = Room.new(@game, [y, x])
      end
    end

    @grid = new_grid
  end

  def connect_rooms
    @grid.each do |row|
      row.each do |room|

        all_directions(room) do |other_room, dir|
          room.add_neighbor(other_room, dir) unless other_room.type == :water
        end

      end
    end
  end

  def all_directions(room, &proc)
    y = room.coords[0]; x = room.coords[1]

    proc.call(self[[y - 1, x]], :n) if on_grid?([y - 1, x])
    proc.call(self[[y + 1, x]], :s) if on_grid?([y + 1, x])
    proc.call(self[[y, x + 1]], :e) if on_grid?([y, x + 1])
    proc.call(self[[y, x - 1]], :w) if on_grid?([y, x - 1])

    proc.call(self[[y - 1, x + 1]], :ne) if on_grid?([y - 1, x + 1])
    proc.call(self[[y - 1, x - 1]], :nw) if on_grid?([y - 1, x - 1])
    proc.call(self[[y + 1, x + 1]], :se) if on_grid?([y + 1, x + 1])
    proc.call(self[[y + 1, x - 1]], :sw) if on_grid?([y + 1, x - 1])
  end

  def on_grid?(coords)
    y = coords.first; x = coords.last
    return false if y < 0 || x < 0

    !@grid[y].nil? && !self[coords].nil?
  end

  def populate_room_types
    @grid.each do |row|
      row.each do |room|
        common_type = get_common_type(room)
        assign_type(room, common_type)
      end
    end
  end

  def get_common_type(room)
    return [:forest, :field].sample if room.coords == [0, 0]
    nearby_rooms = get_nearby_rooms(room)
    nearby_rooms.group_by{|room| room.type}.delete_if{|type_count, room_arr| room_arr.first.type.nil?}.max_by{|count, room_arr| room_arr.count}[1][0].type
  end

  def get_nearby_rooms(room)
    rooms = []
    all_directions(room) do |other_room, dir|
      rooms << other_room
    end
    rooms
  end

  def assign_type(room, common_type)
    if room.coords == [0, 0]
      room.type = [:forest, :field].sample
      room.set_header
      return
    end

    roll = rand(101)
    if roll > 75
      room.type = @types.sample
    else
      room.type = common_type
    end

    room.set_header
  end

  def wipe_items
    @grid.flatten.each {|room| room.reset_items}
  end

  def wipe_enemies
    @grid.flatten.each {|room| room.reset_enemies}
  end

  def wipe_vendors
    @grid.flatten.each {|room| room.reset_vendor}
  end

  def wipe_quest
    @grid.flatten.each {|room| room.questgiver = nil}
    @grid.flatten.each {|room| room.questreceiver = nil}
  end

  def display(location = nil)
    (@grid.first.count + 2).times{print "_"}
    puts
    @grid.each do |row|
      print "|"
      row.each do |room|
        print room.to_s
      end
      puts "|"
    end
    (@grid.first.count + 2).times{print "-"}
    puts
  end
end

class Room
  include HelperFunctions
  include BigText

  attr_accessor :coords, :type, :neighbors, :items, :enemies, :vendor, :questgiver, :questreceiver

  def initialize(game, coords)
    @game = game
    @coords = coords
    @neighbors = {}
    @items = []
    @enemies = []
  end

  def set_header
    @header = header(@type)
  end

  def player_here?
    !@game.location.nil? && @game.location == self
  end

  def player_openly_here?
    player_here? && !@game.player_hidden?
  end

  def player_secretly_here?
    player_here? && @game.player_hidden?
  end

  def queue_enemies
    @enemies.each{|enemy| enemy.start_fighting} if player_openly_here?
  end

  def get_item(item_type, which)
    if item_type.nil?
      @items.shift
    else
      item = filter(@items, item_type)[positions[which]]
      @items.delete(item)
      item
    end
  end

  def get_enemy(enemy_type, which)
    if enemy_type.nil?
      @enemies.first
    else
      filter(@enemies, enemy_type)[positions[which]]
    end
  end

  def inspect(item_type, which)
    if item_type.nil?
      item = @items.first.inspect
    elsif @items.any?{|item| item.type == item_type}
      item = filter(@items, item_type)[positions[which]].inspect
    end

    item.inspect if item.is_a?(Weapon)
  end

  def remove_enemy(enemy)
    @enemies.delete(enemy)
  end

  def add_neighbor(room, dir)
    @neighbors[dir] = room
  end

  def reset_items
    @items = [] unless player_here?
  end

  def reset_enemies
    @enemies = [] unless player_here?
  end

  def reset_vendor
    @vendor = nil unless player_here?
  end

  def add_enemy(enemy)
    @enemies << enemy
  end

  def add_vendor(vendor)
    @vendor = vendor
  end

  def add_questgiver(giver)
    @questgiver = giver
  end

  def add_questreceiver(receiver)
    @questreceiver = receiver
  end

  def add_item(item)
    @items << item
  end

  def give_quest
    @questgiver.start_quest if @questgiver
  end

  def turn_in_quest
    @questreceiver.turn_in_quest if @questreceiver
  end

  def display
    print @header
    print_dirs
    print_vendor
    print_giver
    print_receiver
    print_items
    print_enemies
  end

  def print_dirs
    print "You can move ".display
    dir_strings = {:n => "north", :s => "south", :e => "east",
      :w => "west", :ne => "northeast", :nw => "northwest",
      :se => "southeast", :sw => "southwest"}
    dirs = []
    @neighbors.each_key{|dir| dirs << dir_strings[dir]}
    print dirs.join(", ")
    puts
  end

  def print_vendor
    puts "A trader is here!".display if @vendor
  end

  def print_giver
    puts "You see a stranger nearby.".display if @questgiver
  end

  def print_receiver
    puts "You see someone nearby. They look like they need help.".display if @questreceiver
  end

  def print_items
    if @items.empty?
      return
    elsif @items.count == 1
      puts "You see #{@items.first.to_s.add_article}.".display
    elsif @items.count == 2
      puts "You see #{@items.first.to_s.add_article} and #{@items.last.to_s.add_article}".display
    else
      print "You see ".display
      items = []
      @items[0...-1].each{|item| items << item.to_s.add_article}
      items = items.join(", ") + ", and " + @items.last.to_s.add_article
      puts items
    end
  end

  def print_enemies
    @enemies.each {|enemy| puts "#{enemy.to_s.add_article.capitalize} is here!".display}
  end

  def to_s
    if player_here?
      "X"
    elsif @questgiver
      "Q"
    elsif @questreceiver
      "R"
    else
      {:forest => "t", :field => "-", :water => " "}[@type]
    end
  end

  def water?
    @type == :water
  end
end
