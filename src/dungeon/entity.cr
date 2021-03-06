module Dungeon
  class Entity
    property loc : Location
    property width : Int32
    property height : Int32
    property collision_box : Box
    property origin : Location
    getter hit_box : Box
    getter? centered
    getter? bottom_layer

    @tint : LibRay::Color

    TINT_DEFAULT = LibRay::WHITE

    DRAW_COLLISION_BOXES = Game::DEBUG

    def initialize(@loc : Location, @width, @height, @collision_box : Box, @hit_box : Box, @tint = TINT_DEFAULT)
      @origin = Location.new(
        x: collision_box.x + collision_box.width / 2,
        y: collision_box.y + collision_box.height / 2
      )
      @screen_x = @screen_y = 0_f32
      @centered = true
      @bottom_layer = false
    end

    def initialize(loc, width, height, collision_box : Box, tint = TINT_DEFAULT)
      initialize(loc, width, height, collision_box, collision_box, tint)
    end

    def initialize(loc, width, height, tint = TINT_DEFAULT)
      collision_box = Box.new(
        loc: Location.new(-width / 2, -height / 2),
        width: width,
        height: height
      )
      initialize(loc, width, height, collision_box, collision_box, tint)
    end

    def x=(x)
      @loc.x = x
    end

    def x
      @loc.x
    end

    def y=(y)
      @loc.y = y
    end

    def y
      @loc.y
    end

    def draw_collision_box?
      DRAW_COLLISION_BOXES
    end

    def draw
      raise "implement in super class"
    end

    def draw_collision_box
      draw_box(collision_box)

      # draw origin
      line_size = 5

      # x line
      LibRay.draw_line_bezier(
        start_pos: LibRay::Vector2.new(x: @screen_x + origin.x + line_size, y: @screen_y + origin.y),
        end_pos: LibRay::Vector2.new(x: @screen_x + origin.x - line_size, y: @screen_y + origin.y),
        thick: 1,
        color: LibRay::MAGENTA
      )

      # y line
      LibRay.draw_line_bezier(
        start_pos: LibRay::Vector2.new(x: @screen_x + origin.x, y: @screen_y + origin.y + line_size),
        end_pos: LibRay::Vector2.new(x: @screen_x + origin.x, y: @screen_y + origin.y - line_size),
        thick: 1,
        color: LibRay::MAGENTA
      )
    end

    def draw_hit_box
      draw_box(@hit_box)
    end

    def draw_box(box : Box, color = LibRay::WHITE)
      LibRay.draw_rectangle_lines(
        pos_x: @screen_x + box.x,
        pos_y: @screen_y + box.y,
        width: box.width,
        height: box.height,
        color: color
      )
    end

    def viewable?(camera : Camera)
      divisor = centered? ? 2 : 1

      x + width / divisor >= camera.x && x - width / divisor <= camera.x + camera.width &&
        y + height / divisor >= camera.y && y - height / divisor <= camera.y + camera.height
    end

    def update_to_camera(camera : Camera)
      @screen_x = x - camera.x
      @screen_y = y - camera.y

      updates_to_camera(camera)
    end

    def updates_to_camera(camera : Camera)
    end

    def update(_entities)
    end

    def bump_damage
    end

    # used for checking for movement collisions
    def collidable?
      false
    end

    def collisions?(entities : Array(Entity))
      entities.any? { |entity| collision?(entity) }
    end

    def collision?(entity : Entity, other_box : Box = entity.collision_box, own_box : Box = collision_box)
      x + own_box.x < entity.x + other_box.x + other_box.width &&
        x + own_box.x + own_box.width > entity.x + other_box.x &&
        y + own_box.y < entity.y + other_box.y + other_box.height &&
        y + own_box.y + own_box.height > entity.y + other_box.y
    end

    def removed?
      false
    end
  end
end
