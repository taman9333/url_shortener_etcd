# frozen_string_literal: true

require 'etcdv3'

# Etcd connection wrapper
module Etcd
  def self.init
    @conn = Etcdv3.new(endpoints: 'http://127.0.0.1:2379, http://127.0.0.1:2380')
  end

  def self.conn
    @conn
  end
end
