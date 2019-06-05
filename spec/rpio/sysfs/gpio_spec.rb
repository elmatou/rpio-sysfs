RSpec.describe Rpio::Sysfs::Gpio do

  subject { Rpio::Sysfs::Driver.new }

  let(:pins) { '@exported_pins' }

  before(:each) do
    allow(File).to receive(:write).with('/sys/class/gpio/export', 4)
    allow(File).to receive(:write).with('/sys/class/gpio/gpio4/direction', :in)
  end


  describe '#gpio_direction' do
    it '#gpio_direction(pin, direction)' do
      is_expected.to respond_to(:gpio_direction).with(2).arguments
    end

    it 'should export the pin' do
      allow(File).to receive(:write)
      allow(subject).to receive(:gpio_exported?).with(4).and_return(true)
      expect(subject).to receive(:gpio_export).with(4)
      subject.gpio_direction(4, :in)
    end

    it 'should set the pin to :in when given :in' do
      expect(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/direction', :in))

      subject.gpio_direction(4, :in)
    end

    it 'should set the pin to :out when given :out' do
      expect(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/direction', :out))

      subject.gpio_direction(4, :out)
    end

    it 'should allow multiple pins to be exported' do
      allow(File).to receive(:write).with('/sys/class/gpio/export', 5)
      allow(File).to(
        receive(:write).with('/sys/class/gpio/gpio5/direction', :in))

      subject.gpio_direction(4, :in)
      subject.gpio_direction(5, :in)

      expect(subject.instance_variable_get(pins)).to include(4, 5)
    end

    it 'should raise an error if pin is already exported' do
      subject.gpio_direction(4, :in)

      expect { subject.gpio_direction(4, :in) }.to raise_error(RuntimeError)
    end

    it 'should raise an error on invalid directions' do
      expect { subject.gpio_direction(4, :bad) }.to raise_error(ArgumentError)
    end

    it 'should raise an error if export fails' do
      allow(subject).to receive(:gpio_exported?).with(4).and_return(false)
      expect { subject.gpio_direction(4, :in) }.to(
        raise_error(RuntimeError, 'Pin 4 not exported'))
    end
  end

  describe '#gpio_write' do
    it '#gpio_write(pin, value)' do
      is_expected.to respond_to(:gpio_write).with(2).arguments
    end

    it 'should write the value to the pin' do
      allow(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/direction', :out))
      subject.gpio_direction(4, :out)
      expect(File).to receive(:write).with('/sys/class/gpio/gpio4/value', 1)
      subject.gpio_write(4, 1)
    end

    it 'should raise an error if invalid value' do
      expect { subject.gpio_write(4, 25) }.to raise_error(ArgumentError)
    end

    it 'should raise an error if pin is not exported' do
      expect { subject.gpio_write(4, 1) }.to(
        raise_error(ArgumentError, 'Pin 4 not exported'))
    end
  end

  describe '#gpio_read' do
    it '#gpio_read(pin)' do
      is_expected.to respond_to(:gpio_read).with(1).argument
    end

    it 'should return the value of the pin' do
      subject.gpio_direction(4, :in)
      expect(File).to receive(:read).with('/sys/class/gpio/gpio4/value')
      subject.gpio_read(4)
    end

    it 'should raise an error if pin is not exported' do
      expect { subject.gpio_read(4) }.to(
        raise_error(ArgumentError, 'Pin 4 not exported'))
    end
  end


  describe '#gpio_set_pud' do
    it '#gpio_set_pud(pin, value)' do
      is_expected.to respond_to(:gpio_set_pud).with(2).arguments
    end

    it 'should raise not implemented error because it is not implemented' do
      expect { subject.gpio_set_pud(4, :up) }.to raise_error(NotImplementedError)
    end
  end


  describe '#gpio_set_trigger' do
    before(:each) do
      subject.gpio_direction(4, :in)
    end

    it '#gpio_set_trigger(pin, trigger)' do
      is_expected.to respond_to(:gpio_set_trigger).with(2).arguments
    end

    it 'should set the trigger for the pin to :both' do
      expect(File).to receive(:write).with('/sys/class/gpio/gpio4/edge', :both)
      subject.gpio_set_trigger(4, :both)
    end

    it 'should set the trigger for the pin to :none' do
      expect(File).to receive(:write).with('/sys/class/gpio/gpio4/edge', :none)
      subject.gpio_set_trigger(4, :none)
    end

    it 'should set the trigger for the pin to :falling' do
      expect(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/edge', :falling))
      subject.gpio_set_trigger(4, :falling)
    end

    it 'should set the trigger for the pin to :rising' do
      expect(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/edge', :rising))
      subject.gpio_set_trigger(4, :rising)
    end

    it 'should raise an error for invalid triggers' do
      expect { subject.gpio_set_trigger(4, :invalid) }.to(
        raise_error(ArgumentError))
    end

    it 'should raise an error if pin is not exported' do
      expect { subject.gpio_set_trigger(5, :rising) }.to(
        raise_error(ArgumentError, 'Pin 5 not exported'))
    end
  end

  describe '#gpio_wait_for' do
    it '#gpio_wait_for(pin)' do
      is_expected.to respond_to(:gpio_wait_for).with(1).arguments
      # FIXME: doe's should have trigger argument or not ?
    end
  end


  describe '#gpio_unexport' do
    before(:each) do
      subject.gpio_direction(4, :in)
    end

    it 'should unexport the pin' do
      allow(File).to receive(:write).with('/sys/class/gpio/unexport', 4)
      subject.gpio_unexport(4)
      expect(subject.instance_variable_get(pins)).to be_empty
    end

    it 'should not export other pins' do
      allow(File).to receive(:write).with('/sys/class/gpio/unexport', 4)
      allow(File).to receive(:write).with('/sys/class/gpio/export', 5)
      allow(File).to(
        receive(:write).with('/sys/class/gpio/gpio5/direction', :in))
      subject.gpio_direction(5, :in)

      subject.gpio_unexport(4)

      exported_pins = subject.instance_variable_get(pins)
      expect(exported_pins).to include(5)
      expect(exported_pins).not_to include(4)
    end
  end

  describe '#gpio_unexport_all' do
    it 'should unexport all pins' do
      allow(File).to receive(:write).with('/sys/class/gpio/export', 5)
      allow(File).to(
        receive(:write).with('/sys/class/gpio/gpio5/direction', :in))
      allow(File).to receive(:write).with('/sys/class/gpio/unexport', 4)
      allow(File).to receive(:write).with('/sys/class/gpio/unexport', 5)

      subject.gpio_direction(4, :in)
      subject.gpio_direction(5, :in)

      subject.gpio_unexport_all
      expect(subject.instance_variable_get(pins)).to be_empty
    end
  end

  describe '#gpio_exported?' do
    it 'should return true if pin is exported' do
      subject.gpio_direction(4, :in)
      expect(subject.gpio_exported?(4)).to be(true)
    end

    it 'should return false if pin is not exported' do
      expect(subject.gpio_exported?(4)).to be(false)
    end
  end

end
