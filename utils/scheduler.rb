module SkypeBot
  module Scheduler
    extend self

    # Time monkey-patching
    [Fixnum, Float].each do |cls|
      cls.module_eval do
        {millisecond: 0.001, second: 1, minute: 60, hour: 3600}.each_pair do |k, v|
          define_method(k) { self * v }
          define_method((k.to_s + 's').to_sym) { self * v }
        end
      end
    end

    def every(seconds, instance = self, &block)
      Thread.new do
        loop do
          instance.instance_eval &block
          sleep seconds
        end
      end
    end
  end
end