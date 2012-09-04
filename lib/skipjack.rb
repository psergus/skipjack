require "skipjack/version"
require "core_extensions/array"
require "core_extensions/integer"

module Skipjack

  class Cipher

    F = [
          [0xa3, 0xd7, 0x09, 0x83, 0xf8, 0x48, 0xf6, 0xf4, 0xb3, 0x21, 0x15, 0x78, 0x99, 0xb1, 0xaf, 0xf9],
          [0xe7, 0x2d, 0x4d, 0x8a, 0xce, 0x4c, 0xca, 0x2e, 0x52, 0x95, 0xd9, 0x1e, 0x4e, 0x38, 0x44, 0x28],
          [0x0a, 0xdf, 0x02, 0xa0, 0x17, 0xf1, 0x60, 0x68, 0x12, 0xb7, 0x7a, 0xc3, 0xe9, 0xfa, 0x3d, 0x53],
          [0x96, 0x84, 0x6b, 0xba, 0xf2, 0x63, 0x9a, 0x19, 0x7c, 0xae, 0xe5, 0xf5, 0xf7, 0x16, 0x6a, 0xa2],
          [0x39, 0xb6, 0x7b, 0x0f, 0xc1, 0x93, 0x81, 0x1b, 0xee, 0xb4, 0x1a, 0xea, 0xd0, 0x91, 0x2f, 0xb8],
          [0x55, 0xb9, 0xda, 0x85, 0x3f, 0x41, 0xbf, 0xe0, 0x5a, 0x58, 0x80, 0x5f, 0x66, 0x0b, 0xd8, 0x90],
          [0x35, 0xd5, 0xc0, 0xa7, 0x33, 0x06, 0x65, 0x69, 0x45, 0x00, 0x94, 0x56, 0x6d, 0x98, 0x9b, 0x76],
          [0x97, 0xfc, 0xb2, 0xc2, 0xb0, 0xfe, 0xdb, 0x20, 0xe1, 0xeb, 0xd6, 0xe4, 0xdd, 0x47, 0x4a, 0x1d],
          [0x42, 0xed, 0x9e, 0x6e, 0x49, 0x3c, 0xcd, 0x43, 0x27, 0xd2, 0x07, 0xd4, 0xde, 0xc7, 0x67, 0x18],
          [0x89, 0xcb, 0x30, 0x1f, 0x8d, 0xc6, 0x8f, 0xaa, 0xc8, 0x74, 0xdc, 0xc9, 0x5d, 0x5c, 0x31, 0xa4],
          [0x70, 0x88, 0x61, 0x2c, 0x9f, 0x0d, 0x2b, 0x87, 0x50, 0x82, 0x54, 0x64, 0x26, 0x7d, 0x03, 0x40],
          [0x34, 0x4b, 0x1c, 0x73, 0xd1, 0xc4, 0xfd, 0x3b, 0xcc, 0xfb, 0x7f, 0xab, 0xe6, 0x3e, 0x5b, 0xa5],
          [0xad, 0x04, 0x23, 0x9c, 0x14, 0x51, 0x22, 0xf0, 0x29, 0x79, 0x71, 0x7e, 0xff, 0x8c, 0x0e, 0xe2],
          [0x0c, 0xef, 0xbc, 0x72, 0x75, 0x6f, 0x37, 0xa1, 0xec, 0xd3, 0x8e, 0x62, 0x8b, 0x86, 0x10, 0xe8],
          [0x08, 0x77, 0x11, 0xbe, 0x92, 0x4f, 0x24, 0xc5, 0x32, 0x36, 0x9d, 0xcf, 0xf3, 0xa6, 0xbb, 0xac],
          [0x5e, 0x6c, 0xa9, 0x13, 0x57, 0x25, 0xb5, 0xe3, 0xbd, 0xa8, 0x3a, 0x01, 0x05, 0x59, 0x2a, 0x46]
        ]

    def initialize(secret_key)
      if (secret_key.is_a? Array) && (secret_key.size == 10)
        secret_key.each do |elem |
          raise 'You should pass byte elements' if (elem < 0)||(elem > 255)
        end
        @key = secret_key
      else
        raise 'You should pass an array'
      end
    end

    def G(r, word)
      a = word.to_bytes
      b1 = a[0]
      b2 = a[1]
      a = (b2 ^ @key[(4*r-4) % 10]).to_half_bytes
      b3 = F[a[0]][a[1]] ^ b1

      a = (b3 ^ @key[(4*r-3) % 10]).to_half_bytes
      b4 = F[a[0]][a[1]] ^ b2

      a = (b4 ^ @key[(4*r-2) % 10]).to_half_bytes
      b5 = F[a[0]][a[1]] ^ b3

      a = (b5 ^ @key[(4*r-1) % 10]).to_half_bytes
      b6 = F[a[0]][a[1]] ^ b4

      [b5, b6].to_word
    end

    def G_r(r, word)
      a = word.to_bytes
      b5 = a[0]
      b6 = a[1]
      a = (b5 ^ @key[(4*r-1) % 10]).to_half_bytes
      b4 = F[a[0]][a[1]] ^ b6

      a = (b4 ^ @key[(4*r-2) % 10]).to_half_bytes
      b3 = F[a[0]][a[1]] ^ b5

      a = (b3 ^ @key[(4*r-3) % 10]).to_half_bytes
      b2 = F[a[0]][a[1]] ^ b4

      a = (b2 ^ @key[(4*r-4) % 10]).to_half_bytes
      b1 = F[a[0]][a[1]] ^ b3

      [b1, b2].to_word
    end

    def A(r, w)
      z = w[3]
      w[3] = w[2]
      w[2] = w[1]
      w[1] = G(r, w[0])
      w[0] = w[1] ^ z ^ r
    end

    def B(r, w)
      z = w[3]
      w[3] = w[2]
      w[2] = w[0] ^ w[1] ^ r
      w[1] = G(r, w[0])
      w[0] = z
    end

    def A_r(r, w)
      z = w[3]
      w[3] = w[0] ^ w[1] ^ r
      w[0] = G_r(r, w[1])
      w[1] = w[2]
      w[2] = z
      w
    end

    def B_r(r, w)
      z = w[0]
      w[0] = G_r(r, w[1])
      w[1] = w[0] ^ w[2] ^ r
      w[2] = w[3]
      w[3] = z
      w
    end

    def encode_block(w)
      1.upto(32) do |r|
        ((r <= 8)||((r >= 17)&&(r <= 24))) ? A(r, w) : B(r, w)
      end
      w
    end

    def decode_block(w)
      32.downto(1) do |r|
        ((r <= 8)||((r >= 17)&&(r <= 24))) ? A_r(r, w) : B_r(r, w)
      end
      w
    end

    def encode(plain_text)
      raise 'You should pass string as a parameter' unless plain_text.is_a? String
      plain_text << '0' until (plain_text.size % 8 == 0)
      cipher_text = ''
      blocks_count = plain_text.size / 8
      0.upto(blocks_count - 1) do |i|
        w = []
        0.upto(7) do |j|
          if j % 2 == 0
            w << [plain_text[(i*8) + j], plain_text[(i*8) + j + 1]].to_word
          end
        end
        encode_block(w).each do |elem|
          a = elem.to_bytes
          cipher_text << a[0] << a[1]
        end
      end
      cipher_text
    end

    def decode(cipher_text)
      raise 'You should pass string as a parameter' unless cipher_text.is_a? String
      plain_text = ''
      blocks_count = cipher_text.size / 8
      0.upto(blocks_count - 1) do |i|
        w = []
        0.upto(7) do |j|
          if j % 2 == 0
            w << [cipher_text[(i*8) + j], cipher_text[(i*8) + j + 1]].to_word
          end
        end
        decode_block(w).each do |elem|
          a = elem.to_bytes
          plain_text << a[0] << a[1]
        end
      end
      plain_text
    end

  end
end
