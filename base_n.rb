# frozen_string_literal: true

# this module for encoding numbers into base n unique string

module BaseN
  CHARSETS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'.split('').freeze
  BASE = CHARSETS.size
  # Increment this addend to the num in encode method as small numbers will generate tokens
  ADDEND = 993_000_000

  def self.encode(num)
    return CHARSETS[num] if num.zero?

    # this addition to make sure we will have not less than 6 chars token
    num += ADDEND
    str = ''
    while num > 0
      str = CHARSETS[num % BASE] + str
      num /= BASE
    end
    str
  end
end
