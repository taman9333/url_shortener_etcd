# frozen_string_literal: trues

# to run application thin start in the root directory

require './server'
require './counter'

Counter.init

run Sinatra::Application
