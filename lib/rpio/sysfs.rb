
require "rpio/sysfs/version"

require "rpio"

require "rpio/sysfs/gpio"

require "rpio/sysfs/driver"

module Rpio
  self.driver = Rpio::Sysfs::Driver
end

# TODO: implement SPI and I2C with sysfs
# def self.spidev_out(array)
#   File.open('/dev/spidev0.0', 'wb'){|f| f.write(array.pack('C*')) }
# end


# TODO: create instalation method for kernel module
