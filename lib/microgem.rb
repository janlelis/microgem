# frozen_string_literal: true

require_relative "microgem/version"
require_relative "microgem/generator"

module Microgem
  def self.run!
    Microgem::Generator.start
  end
end
