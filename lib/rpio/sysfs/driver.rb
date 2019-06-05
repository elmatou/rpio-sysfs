module Rpio
  module Sysfs
    class Driver < Rpio::Driver
      GPIO_HIGH = 1
      GPIO_LOW  = 0

      def initialize
        @exported_pins = Set.new
      end

      def close
        gpio_unexport_all
        @exported_pins.empty?
      end

      include Rpio::Sysfs::Gpio

    end
  end
end
