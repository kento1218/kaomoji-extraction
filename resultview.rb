# -*- coding: utf-8 -*-

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
    
    sen += code.to_i.chr 'utf-8'
  end
end

main
