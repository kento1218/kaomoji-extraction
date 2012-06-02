# -*- coding: utf-8 -*-

if RUBY_VERSION < '1.9'
  $KCODE = 'u'
  class String
    def force_encoding(enc)
      self
    end
    def ord
      self.unpack('U')[0]
    end
    def length
      self.chars.count
    end
    def [](arg)
      if arg.kind_of? Fixnum
        return self.chars.to_a[arg]
      elsif arg.kind_of? Range
        return self.chars.to_a[arg].join
      else
        return (self)[arg]
      end
    end
  end
end

def chr(code)
  if RUBY_VERSION < '1.9'
    return [code].pack 'U'
  else
    return code.chr 'utf-8'
  end
end

def main
  sen = ''
  smiley = []
  
  while line = STDIN.gets do
    line.chomp!
    
    if line.empty?
      puts "text: %s" % sen
      puts "result: %s" % smiley.map{|s,l| sen[s..(s+l-1)] }.join(', ')
      sen = ''
      smiley = []
      next
    end
    
    dat = line.split(/\t/)
    code = dat[0]
    tag = dat[-1]
    
    if tag == 'B'
      smiley << [sen.length, 1]
    elsif tag == 'I'
      s, l = smiley.pop
      smiley << [s, l+1]
    end
    
    sen += chr code.to_i
  end
end

main
