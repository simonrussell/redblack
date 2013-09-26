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

    def each(block)
      # nothing
    end

    def search(key)
      nil
    end

    def insert(key, value)
      Node.new(key, value)
    end

    def delete(key)
      self
    end

    def black?
      true
    end

    def red?
      false
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

    def red?
      @colour == RED
    end

    def black?
      @colour == BLACK
    end

    def min_node
      h = self
      h = h.left until h.left.empty?
      h
    end

    def each(block)
      @left.each(block)
      block.(@key, @value)
      @right.each(block)
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

    def insert(key, value)
      h = self

      h.flip_colours! if h.left.red? && h.right.red?

      cmp = (key <=> h.key)

      if cmp == 0
        h.value = value
      elsif cmp < 0
        h.left = h.left.insert(key, value)
      else
        h.right = h.right.insert(key, value)
      end

      h = h.rotate_left if h.left.black? && h.right.red?
      h = h.rotate_right if h.left.red? && h.left.left.red?

      h
    end

    def delete(key)
      h = self

      if key < h.key
        unless h.left.empty?
          h = h.move_red_left if h.left.black? && h.left.left.black?
          h.left = h.left.delete(key)
        end
      else
        h = h.rotate_right if h.left.red?
        return EMPTY if key == h.key && h.right.empty?
        h = h.move_red_right if h.right.black? && h.right.left.black?

        if key == h.key
          right_min = h.right.min_node
          h.key = right_min.key
          h.value = right_min.value
          h.right = h.right.delete_min
        else
          h.right = h.right.delete(key)
        end
      end

      h.fix_up
    end

    def delete_min
      h = self

      return EMPTY if h.left.empty?

      h = h.move_red_left if h.left.black? && h.left.left.black?

      h.left = h.left.delete_min

      h.fix_up
    end

    def rotate_left
      x = @right
      @right = x.left
      x.left = self
      x.colour = @colour
      @colour = RED
      x
    end

    def rotate_right
      x = @left
      @left = x.right
      x.right = self
      x.colour = @colour
      @colour = RED
      x
    end

    def flip_colours!
      @colour = invert_colour(@colour)
      @left.colour = invert_colour(@left.colour)
      @right.colour = invert_colour(@right.colour)
    end

    def move_red_left
      h = self

      h.flip_colours!

      if h.right.left.red?
        h.right = h.right.rotate_right
        h = h.rotate_left
        h.flip_colours!
      end

      h
    end

    def move_red_right
      h = self

      h.flip_colours!

      if h.left.left.red?
        h = h.rotate_right
        h.flip_colours!
      end

      h
    end

    def fix_up
      h = self
      h = h.rotate_left if h.right.red?
      h = h.rotate_right if h.left.red? && h.left.left.red?
      h.flip_colours! if h.left.red? && h.right.red?
      h
    end

    private

    def invert_colour(colour)
      colour == RED ? BLACK : RED
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
    @root = @root.insert(key, value)
    @root.colour = BLACK
  end

  alias :[]= :insert!

  def delete!(key)
    @root = @root.delete(key)
    @root.colour = BLACK unless @root.empty?
  end

  def each(&block)
    @root.each(block)
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
end