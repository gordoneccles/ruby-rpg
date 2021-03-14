module BigText

  def header(type)
    case type
    when :field
      grass
    when :forest
      trees
    end
  end

  def grass
    header = ""
    140.times {header << [",", " ", " "].sample}
    header << "\n"
    140.times {header << [",", " "].sample}
    header << "\n"
    140.times {header << ["|", ",", " "].sample}
    header << "\n"
    140.times {header << ["|", ",", " "].sample}
    header << "\n"
    140.times {header << ["|", ",", " "].sample}
    header << "\n"
    140.times {header << ["|", "|", ",", " "].sample}
    header << "\n"
    140.times {header << ["|", "|", "|", " "].sample}
    header << "\n"
    140.times {header << "|"}
    header << "\n"
    header
  end

  def trees
    Forest.new.header
  end

  def death
    "
                        YY          YY            OOOOOOOOO              UU           UU
                          YY       YY           OO         OO            UU           UU
                            YY    YY           OO           OO           UU           UU
                              YY YY            OO           OO           UU           UU
                                YY             OO           OO           UU           UU
                               YY              OO           OO           UU           UU
                              YY               OO           OO           UU           UU
                             YY                 OO         OO             UU         UU
                            YY                    OOOOOOOOO                 UUUUUUUUU

                      DDDDDDDDDDDDD         IIIIIIII        EEEEEEEEEEE       DDDDDDDDDDDDD         !!!
                      DD           DD          II           EE                DD           DD       !!!
                      DD            DD         II           EE                DD            DD      !!!
                      DD             DD        II           EE                DD             DD     !!!
                      DD             DD        II           EE                DD             DD     !!!
                      DD             DD        II           EEEEEEEEEEE       DD             DD     !!!
                      DD             DD        II           EE                DD             DD     !!!
                      DD             DD        II           EE                DD             DD
                      DD            DD         II           EE                DD            DD
                      DD           DD          II           EE                DD           DD       !!!
                      DDDDDDDDDDDDD         IIIIIIII        EEEEEEEEEEE       DDDDDDDDDDDDD         !!!"
    end
end

class Forest
  def initialize
    @grid = Array.new(8){Array.new(28)}
    @seed_ids = [:s_b, :m_b1, :l_b11]
    @next_coords_dif = {
                      :s_t =>   [-1, 0], :s_b =>    [-1, 0],
                      :m_t1 =>  [0, 1],  :m_t2 =>   [-1, -1],
                      :m_b1 =>  [0, 1],  :m_b2 =>   [-1, -1],
                      :l_t1 =>  [0, 1],  :l_t2 =>   [-1, -1],
                      :l_b21 => [0, 1],  :l_b22 =>  [-1, -1],
                      :l_b11 => [0, 1],  :l_b12 =>  [-1, -1]
    }
    @next_id = {
              :s_b =>   :s_t,    :s_t => :s_t,
              :m_b1 =>  :m_b2,   :m_b2 => :m_t1,   :m_t1 =>   :m_t2,
              :m_t2 =>  :m_t1,
              :l_b11 => :l_b12,  :l_b12 => :l_b21, :l_b21 =>  :l_b22,
              :l_b22 => :l_t1,   :l_t1 => :l_t2,   :l_t2 =>   :l_t1
    }
    initialize_patches
    populate_with_trees
  end

  def initialize_patches
    new_grid = Array.new(@grid.length){Array.new(@grid.first.length)}

    @grid.each_with_index do |row, y|
      row.each_with_index do |ele, x|
        new_grid[y][x] = Patch.new(self, [y, x])
      end
    end

    @grid = new_grid
  end

  def populate_with_trees
    @grid.each_with_index do |row, idx|
      next if idx % 2 == 0

      (rand(3)+5).times {plant_tree(row)}
    end
  end

  def plant_tree(row)
    patch = row.select{|patch| patch.empty}.sample
    id = @seed_ids.sample
    grow_tree(id, patch)
  end

  def grow_tree(id, patch)
    patch.draw_partial_tree(id)

    next_id = @next_id[id]

    y = patch.location[0]; x = patch.location[1]
    next_y = y + @next_coords_dif[id][0]
    next_x = x + @next_coords_dif[id][1]

    if on_grid?(next_y, next_x)
      next_patch = @grid[next_y][next_x]
      grow_tree(next_id, next_patch)
    end
  end

  def on_grid?(y, x)
    return false if y < 0 || x < 0
    !@grid[y].nil? && !@grid[y][x].nil?
  end

  def header
    header = ""
    @grid.each do |row|
      row.each do |patch|
        header << patch.to_s
      end
      header << "\n"
    end
    header
  end
end

class Patch
  attr_accessor :location, :empty

  def initialize(forest, location)
    @location = location
    @empty = true
    @tree_strings = {
                nil =>    "     ",
                :s_t =>   " |/| ", :s_b =>    "////\\",
                :m_t1 =>  "  |//", :m_t2 =>    "/|   ",
                :m_b1 =>  " ////", :m_b2 =>   "//\\  ",
                :l_t1 =>  "  |//", :l_t2 =>    "//|  ",
                :l_b21 => " ////", :l_b22 =>  "///\\ ",
                :l_b11 => "/////", :l_b12 =>  "////\\"
    }
    @display_string = "     "
  end

  def draw_partial_tree(part_id)
    @empty = false
    old_string = @display_string
    new_string = @tree_strings[part_id]
    @display_string = overwrite(old_string, new_string)
  end

  def overwrite(old_string, new_string)
     return_string = ""

     new_string.each_char.with_index do |char, idx|
       if char != " "
         return_string << char
       else
         return_string << old_string[idx]
       end
     end
     return_string
   end

   def to_s
     @display_string
   end
end
