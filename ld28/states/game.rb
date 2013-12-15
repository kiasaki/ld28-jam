require "engine/state"
require "engine/game/world"
require "engine/game/entity"
require "engine/utils/images"
require "pp"

module LD28
  module States
    class Game < State
      @world = nil
      @camera = nil

      def update delta
        super delta
        @world.update delta
        @camera.center_on @player

        if (@now_in_for / 1500) % 3 == 0
          @player.say ['I am the HOOONLY hero!']
        elsif (@now_in_for / 1500) % 3 == 1
          @player.say ['Me saaave whorld!', 'Mhe noo sthupid!']
        else
          @player.say nil
        end
      end

      def draw
        transition 0x000000FF, 0, 1000, @now_in_for
        set_color 0x309BD0FF
        draw_rect 0, 0, @game.width, @game.height
        Images[:desert_bg].draw -768 - @camera.pos_x, 130 - @camera.pos_y, 0
        Images[:desert_bg].draw 0 - @camera.pos_x, 130 - @camera.pos_y, 0
        Images[:desert_bg].draw 768 - @camera.pos_x, 130 - @camera.pos_y, 0
        Images[:castle].draw -300 - @camera.pos_x, 160 - @camera.pos_y, 1
        set_color 0x1e1e1eFF
        draw_rect -5000 - @camera.pos_x, 350 - @camera.pos_y, 10000, 20

        # BEHOLD! Debugging down here
          @world.draw @camera
          set_color 0xEE00EEFF
          @world.entities.each do |e|
            draw_rect_outline e.pos_x - @camera.pos_x, e.pos_y - @camera.pos_y, e.width, e.height
          end
      end

      def init
        super

        self.input_down Gosu::KbLeft, Proc.new {
          if @player.last_collision.in_collision_bottom
            @player.image_sheet.tile_y = 2
            @player.velocity_x -= 2
          else
            @player.image_sheet.tile_y = 3
            @player.velocity_x -= 0.1
          end
        }
        self.input_down Gosu::KbRight, Proc.new {
          if @player.last_collision.in_collision_bottom
            @player.image_sheet.tile_y = 6
            @player.velocity_x += 2
          else
            @player.image_sheet.tile_y = 7
            @player.velocity_x += 0.1
          end
        }
        self.input_down Gosu::KbUp, Proc.new {
          if @player.last_collision.in_collision_bottom
            @player.velocity_y -= 6
          end
        }
      end

      def enter
        super
        @world = World.new

        hero_img_sheet = ImageSheet.new File.join('res', 'images', 'homme.png'), 24, 48, :frames_per_second => 10
        omg_sheet = ImageSheet.new File.join('res', 'images', 'homme.png'), 24, 48, :frames_per_second => 10
        @player = Hero.new 100, 120, 18, 32,
        { :image_sheet => hero_img_sheet,
          :health => 100,
          :image_sheet_offset_x => -3,
          :image_sheet_offset_y => -16}
        @world.add @player
        @world.add Character.new 30, 130, 24, 48, :image_sheet => omg_sheet, :health => 100

        @world.add Entity.new -300, 160, 300, 200, {:gravitates => false, :collides => false}
        @world.add Entity.new 60, 120, 40, 6, {:gravitates => true, :collides => true}
        @world.add Entity.new -5000, 350, 10000, 20, {:gravitates => false, :collides => false}

        @camera = Camera.new 0, 0, @game.width, @game.height
      end

      def leave
      end

    end
  end
end
