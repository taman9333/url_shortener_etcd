# frozen_string_literal: true

# basic in-memory counter
module Counter
  def self.init
    @count = 0
  end

  def self.increment
    @count += 1
  end

  def self.count
    @count
  end
end
