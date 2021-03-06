require "./enemy"

module Dungeon
  class SoldierFollowing < MovingEnemy
    @line_of_site_box : Box
    @target : Hash(Symbol, Float32)

    MOVEMENT = 50

    def initialize(loc : Location, @player : Player, @direction = Direction::Up)
      sprite = Sprite.get("player")
      tint = LibRay::ORANGE

      collision_box = Box.new(
        loc: Location.new(-12, 16),
        width: 24,
        height: 16
      )

      super(loc, sprite, collision_box, tint, @direction)

      line_of_site_width = width * 4
      line_of_site_height = height * 4
      @line_of_site_box = Box.new(
        loc: Location.new(-line_of_site_width, -line_of_site_height),
        width: line_of_site_width * 2,
        height: line_of_site_height * 2
      )

      @target = {:x => x, :y => y}
    end

    def viewable?(camera : Camera)
      x_max = x + width / 2
      x_min = x - width / 2

      y_max = y + height / 2
      y_min = y - height / 2

      if draw_collision_box?
        x_max = [x + width / 2, x + @line_of_site_box.x + @line_of_site_box.width].max
        x_min = [x - width / 2, x + @line_of_site_box.x].min

        y_max = [y + height / 2, y + @line_of_site_box.y + @line_of_site_box.height].max
        y_min = [y - height / 2, y + @line_of_site_box.y].min
      end

      x_max >= camera.x && x_min <= camera.x + camera.width &&
        y_max >= camera.y && y_min / 2 <= camera.y + camera.height
    end

    def moving?
      return false if @death_timer.active? || dead?

      # check if player is in line of sight
      if sees_player?
        move_again

        return true
      else
        set_target

        return true unless at_target?
      end

      false
    end

    def set_target
      # Don't need to set the target,
      # target is the last player's seen location,
      # move there.
    end

    def sees_player?
      collision?(@player, other_box: @player.hit_box, own_box: @line_of_site_box)
    end

    def move_delta(delta_t)
      delta_x = delta_y = 0_f32

      delta_x = -(x - @target[:x]) / (x - @target[:x]).abs unless (x - @target[:x]).abs == 0
      delta_y = -(y - @target[:y]) / (y - @target[:y]).abs unless (y - @target[:y]).abs == 0

      delta_x *= delta_t * MOVEMENT
      delta_y *= delta_t * MOVEMENT

      {x: delta_x, y: delta_y}
    end

    def set_direction
      dx = -(x - @target[:x])
      dy = -(y - @target[:y])

      if dx.abs > 0
        if dy.abs > 0
          if dx.abs > dy.abs
            set_direction_x(dx)
          elsif dy.abs > dx.abs
            set_direction_y(dy)
          else
            # dx and dy are the same
            # for now set direction to y
            set_direction_y(dy)
          end
        else
          set_direction_x(dx)
        end
      else
        set_direction_y(dy)
      end

      @animation.row = @direction.value
    end

    def move_again?(delta : NamedTuple(x: Float32, y: Float32))
      reached_x = false
      reached_y = false

      if delta[:x] > 0 && x >= @target[:x]
        reached_x = true
      elsif delta[:x] < 0 && x <= @target[:x]
        reached_x = true
      elsif delta[:x] == 0 && at_target?
        reached_x = true
      end

      return false unless reached_x

      if delta[:y] > 0 && y >= @target[:y]
        reached_y = true
      elsif delta[:y] < 0 && y <= @target[:y]
        reached_y = true
      elsif delta[:y] == 0 && at_target?
        reached_y = true
      end

      reached_y
    end

    def move_again
      if sees_player?
        @target = {:x => @player.x, :y => @player.y}
      end
    end

    def at_target?
      offset = 1

      x >= @target[:x] - offset && x <= @target[:x] + offset && y >= @target[:y] - offset && y <= @target[:y] + offset
    end

    def draw
      @animation.draw(@screen_x, @screen_y)

      if draw_collision_box?
        draw_collision_box
        draw_hit_box
        draw_line_of_site_box
      end

      draw_hit_points if draw_hit_points?
    end

    def draw_line_of_site_box
      draw_box(@line_of_site_box, LibRay::YELLOW)
    end
  end
end
