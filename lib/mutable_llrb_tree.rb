class MutableLlrbTree
  RED = Object.new
  BLACK = Object.new

  class EmptyNode
    def search(key)
      nil
    end

    def empty?
      true
    end

    def search(key)
      nil
    end
  end

  EMPTY = EmptyNode.new.freeze

  class Node
    attr_accessor :key, :value, :colour, :left, :right

    def initialize(key, value)
      @key = key
      @value = value
      @colour = RED
      @left = @right = EMPTY
    end

    def empty?
      false
    end

    def search(key)
      x = self

      until x.empty?
        cmp = (key <=> x.key)

        if cmp == 0
          return x.value
        elsif cmp < 0
          x = x.left
        else
          x = x.right
        end
      end

      nil
    end
  end

  def initialize(values = {})
    @root = EMPTY

    values.each do |k, v|
      insert!(k, v)
    end
  end

  def search(key)
    @root.search(key)
  end

  alias :[] :search

  def insert!(key, value)
    @root = do_insert(@root, key, value)
    @root.colour = BLACK
  end

  alias :[]= :insert!

  def delete_min!
    @root = do_delete_min(@root)
    @root.colour = BLACK unless @root.empty?
  end

  def delete!(key)
    @root = do_delete(@root, key)
    @root.colour = BLACK unless @root.empty?
  end

  def each(&block)
    do_each(@root, block)
  end

  def to_h
    r = {}

    each do |k, v|
      r[k] = v
    end

    r
  end

  def to_a
    r = []

    each do |k, v|
      r << [k, v]
    end

    r
  end

  def to_s
    "#<#{self.class.name} #{to_h}>"
  end

  private

  def do_insert(h, key, value)
    return Node.new(key, value) if h.empty?

    flip_colours!(h) if is_red?(h.left) && is_red?(h.right)

    cmp = (key <=> h.key)

    if cmp == 0
      h.value = value
    elsif cmp < 0
      h.left = do_insert(h.left, key, value)
    else
      h.right = do_insert(h.right, key, value)
    end

    h = rotate_left(h) if !is_red?(h.left) && is_red?(h.right)
    h = rotate_right(h) if is_red?(h.left) && is_red?(h.left.left)

    h
  end

  def do_delete(h, key)
    if key < h.key
      unless h.left.empty?
        h = move_red_left(h) if !is_red?(h.left) && !is_red?(h.left.left)
        h.left = do_delete(h.left, key)
      end
    else
      h = rotate_right(h) if is_red?(h.left)
      return EMPTY if key == h.key && h.right.empty?
      h = move_red_right(h) if !is_red?(h.right) && !is_red?(h.right.left)

      if key == h.key
        right_min = min_node(h.right)
        h.key = right_min.key
        h.value = right_min.value #h.right.search(right_min.key)
        h.right = do_delete_min(h.right)
      else
        h.right = do_delete(h.right, key)
      end
    end

    fix_up(h)
  end

  def do_delete_min(h)
    return EMPTY if h.left.empty?

    h = move_red_left(h) if !is_red?(h.left) && !is_red?(h.left.left)

    h.left = do_delete_min(h.left)

    fix_up(h)
  end

  def move_red_left(h)
    flip_colours!(h)

    if is_red?(h.right.left)
      h.right = rotate_right(h.right)
      h = rotate_left(h)
      flip_colours!(h)
    end

    h
  end

  def move_red_right(h)
    flip_colours!(h)

    if is_red?(h.left.left)
      h = rotate_right(h)
      flip_colours!(h)
    end

    h
  end

  def do_each(h, block)
    return if h.empty?

    do_each(h.left, block)
    block.(h.key, h.value)
    do_each(h.right, block)
  end

  def is_red?(h)
    !h.empty? && h.colour == RED
  end

  def invert_colour(colour)
    colour == RED ? BLACK : RED
  end

  def rotate_left(h)
    x = h.right
    h.right = x.left
    x.left = h
    x.colour = h.colour
    h.colour = RED
    x
  end

  def rotate_right(h)
    x = h.left
    h.left = x.right
    x.right = h
    x.colour = h.colour
    h.colour = RED
    x
  end

  def flip_colours!(h)
    h.colour = invert_colour(h.colour)
    h.left.colour = invert_colour(h.left.colour)
    h.right.colour = invert_colour(h.right.colour)
  end

  def min_node(h)
    h = h.left until h.left.empty?
    h
  end

  def fix_up(h)
    h = rotate_left(h) if is_red?(h.right)
    h = rotate_right(h) if is_red?(h.left) && is_red?(h.left.left)
    flip_colours!(h) if is_red?(h.left) && is_red?(h.right)
    h
  end
end