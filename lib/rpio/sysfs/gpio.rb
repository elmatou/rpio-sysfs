module Rpio
  module Sysfs
    module Gpio

      GPIO_HIGH = 1
      GPIO_LOW  = 0

      def gpio_direction(pin, direction)
        raise ArgumentError, "direction should be :in or :out" unless [:in, :out].include? direction
        gpio_export(pin)
        raise RuntimeError, "Pin #{pin} not exported" unless gpio_exported?(pin)
        File.write(gpio_direction_file(pin), direction)
      end

      def gpio_read(pin)
        raise ArgumentError, "Pin #{pin} not exported" unless gpio_exported?(pin)
        File.read(gpio_value_file(pin)).to_i
      end

      def gpio_write(pin, value)
        raise ArgumentError, "value should be GPIO_HIGH or GPIO_LOW" unless [GPIO_LOW, GPIO_HIGH].include? value
        raise ArgumentError, "Pin #{pin} not exported" unless gpio_exported?(pin)
        File.write(gpio_value_file(pin), value)
      end

      def gpio_set_pud(pin, value)
        raise NotImplementedError, "Pull up/down not available with this driver. keep it on :off" unless value == :off
      end

      def gpio_set_trigger(pin, trigger)
        raise ArgumentError, "trigger should be :falling, :rising, :both or :none" unless [:falling, :rising, :both, :none].include? trigger
        raise ArgumentError, "Pin #{pin} not exported" unless gpio_exported?(pin)
        File.write(gpio_edge_file(pin), trigger)
      end

# FIXME: API accept only pin argument, trigger is set previously
      def gpio_wait_for(pin, trigger)
        gpio_set_trigger(pin, trigger)
        fd = File.open(gpio_value_file(pin), 'r')
        value = nil

        loop do
          fd.read
          IO.select(nil, nil, [fd], nil)
          last_value = value
          value = self.gpio_read(pin)
          if last_value != value
            next if trigger == :rising and value == 0
            next if trigger == :falling and value == 1
            break
          end
        end

      end

  # Specific behaviours

      def gpio_unexport(pin)
        File.write("/sys/class/gpio/unexport", pin)
        @exported_pins.delete(pin)
      end

      def gpio_unexport_all
        @exported_pins.dup.each { |pin| gpio_unexport(pin) }
      end

      def gpio_exported?(pin)
        @exported_pins.include?(pin)
      end

      private

      def gpio_export(pin)
        raise RuntimeError, "pin #{pin} is already reserved by another Pin instance" if @exported_pins.include?(pin)
        File.write("/sys/class/gpio/export", pin)
        @exported_pins << pin
      end

      def gpio_value_file(pin)
        "/sys/class/gpio/gpio#{pin}/value"
      end

      def gpio_edge_file(pin)
        "/sys/class/gpio/gpio#{pin}/edge"
      end

      def gpio_direction_file(pin)
        "/sys/class/gpio/gpio#{pin}/direction"
      end

      def gpio_value_changed?(pin, trigger, value)
        last_value = value
        value = gpio_read(pin)
        return false if value == last_value
        return false if trigger == :rising && value == 0
        return false if trigger == :falling && value == 1
        true
      end

    end
  end
end
