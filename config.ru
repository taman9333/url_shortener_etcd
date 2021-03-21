# frozen_string_literal: trues

# to run application thin start in the root directory

require './server'
require './counter'
require './etcd'

Etcd.init
Counter.init

run Sinatra::Application
