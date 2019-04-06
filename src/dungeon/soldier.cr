require "./moving_enemy"

module Dungeon
  class Soldier < MovingEnemy
    @path_delta : Hash(Symbol, Int32)
    @path_end_x : Float32
    @path_end_y : Float32

    MOVEMENT_X = 100
    MOVEMENT_Y = 100

    MOVE_WITH_PATH = true

    def initialize(loc : Location)
      sprite = Sprite.get("player")
      tint = LibRay::ORANGE

      collision_box = Box.new(
        loc: Location.new(-12, 16),
        width: 24,
        height: 16
      )

      super(loc, sprite, collision_box, tint)

      @path_index = 0
      @path_deltas = [
        # {:dx => 20},
        # {:dy => 30},
        {:dx => -20, :dy => 50},
        # {:dy => -30},
        # {:dy => 50},
        {:dx => 20, :dy => 30},
        {:dx => 50, :dy => 10},
        # {:dx => 50},
        {:dx => 30, :dy => -50},
        # {:dy => -10},
      ]
      @path_delta = @path_deltas[0]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)
    end

    def moving?
      @path_deltas.any? && MOVE_WITH_PATH
    end

    def move_delta(delta_t)
      delta_x = delta_y = 0_f32

      delta_x = delta_t * MOVEMENT_X * @path_delta[:dx] / @path_delta[:dx].abs if @path_delta.has_key?(:dx)
      delta_y = delta_t * MOVEMENT_Y * @path_delta[:dy] / @path_delta[:dy].abs if @path_delta.has_key?(:dy)

      {x: delta_x, y: delta_y}
    end

    def set_direction
      if @path_delta.has_key?(:dx)
        if @path_delta.has_key?(:dy)
          if @path_delta[:dx].abs > @path_delta[:dy].abs
            set_direction_x(@path_delta[:dx])
          elsif @path_delta[:dy].abs > @path_delta[:dx].abs
            set_direction_y(@path_delta[:dy])
          end
        else
          set_direction_x(@path_delta[:dx])
        end
      else
        set_direction_y(@path_delta[:dy])
      end
    end

    def move_again?(delta : NamedTuple(x: Float32, y: Float32))
      reached_x = false
      reached_y = false

      if delta[:x] > 0 && x >= @path_end_x
        reached_x = true
      elsif delta[:x] < 0 && x <= @path_end_x
        reached_x = true
      elsif delta[:x] == 0 && x == @path_end_x
        reached_x = true
      end

      return false unless reached_x

      if delta[:y] > 0 && y >= @path_end_y
        reached_y = true
      elsif delta[:y] < 0 && y <= @path_end_y
        reached_y = true
      elsif delta[:y] == 0 && y == @path_end_y
        reached_y = true
      end

      reached_y
    end

    def move_again
      @path_index = rand(@path_deltas.size)

      @path_delta = @path_deltas[@path_index]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)
    end

    def set_direction_x(delta_x)
      if delta_x > 0_f32
        @direction = Direction::Right
        @animation.row = @direction.value
      elsif delta_x < 0_f32
        @direction = Direction::Left
        @animation.row = @direction.value
      end
    end

    def set_direction_y(delta_y)
      if delta_y > 0_f32
        @direction = Direction::Down
        @animation.row = @direction.value
      elsif delta_y < 0_f32
        @direction = Direction::Up
        @animation.row = @direction.value
      end
    end
  end
end
