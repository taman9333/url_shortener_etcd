# frozen_string_literal: true

require_relative './etcd'

# basic in-memory counter
module Counter
  COUNTER_RANGE = 1_000_000
  KEY_NAME = 'current_counter'

  def self.init
    current_counter = Etcd.conn.get(KEY_NAME)
    if current_counter.kvs.empty?
      Etcd.conn.put(KEY_NAME, COUNTER_RANGE.to_s)
      @count = 0
    else
      @count = current_counter.kvs.first.value.to_i
    end
    @max = @count + COUNTER_RANGE
    Etcd.conn.put(KEY_NAME, @max.to_s)
  end

  def self.increment
    set_new_counter if !@count < @max
    @count += 1
  end

  def self.count
    @count
  end

  private

  def set_new_counter
    current_counter = Etcd.conn.get(KEY_NAME).kvs.first.value.to_i
    @count = current_counter
    @max = @count + COUNTER_RANGE
    Etcd.conn.put(KEY_NAME, @max.to_s)
  end
end
