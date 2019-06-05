RSpec.describe Rpio::Sysfs::Driver do

  let(:pins) { '@exported_pins' }

  subject { Rpio::Sysfs::Driver.new }

  before(:each) do
    allow(File).to receive(:write).with('/sys/class/gpio/export', 4)
    allow(File).to receive(:write).with('/sys/class/gpio/gpio4/direction', :in)
  end

  describe '#initialize' do
    it 'inherits from Rpio::Driver' do
      expect(Rpio::Sysfs::Driver).to be < Rpio::Driver
    end


    it '#new method exist' do
      expect(Rpio::Sysfs::Driver).to respond_to(:new).with(0).argument
    end

    it 'should not export any pins' do
      expect(subject.instance_variable_get(pins)).to be_empty
    end
  end

  describe '#close' do
    it '#close method exist' do
      is_expected.to respond_to(:close).with(0).argument
    end

    it 'should unexport all exported pins' do
      subject.gpio_direction(4, :in)
      allow(File).to receive(:write).with('/sys/class/gpio/unexport', 4)

      subject.close
      expect(subject.instance_variable_get(pins)).to be_empty
    end
  end
end
