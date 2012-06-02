# -*- coding: utf-8 -*-
require 'rubygems'
require 'MeCab'
require 'YamCha'

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

def print_result(result)
  sen = ''
  smiley = []
  
  for line in result.lines
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

def begin_node_list(bos, sen, i)
  result = []
  if sen[i] != ' '
    prev = i == 0 ? '' : sen[0..(i-1)]
    
    if / +$/ =~ prev
      tail = $&.length
    else
      tail = 0
    end
    
    node = bos.begin_node_list(prev.bytesize - tail)
    while node do
      result << node
      node = node.bnext
    end
  end
  return result
end

def all_morph(bos, sen)
  morph = []
  sen.chars.each_with_index do |c,i|
    nodes = begin_node_list(bos, sen, i)
    for n in nodes
      surf = n.surface.force_encoding('utf-8')
      morph << {:pos => i, :len => surf.length, :node => n}
    end
  end
  return morph
end

def test
  sen = '井ノ上     です'
  t = MeCab::Tagger.new('-a -l2')
  bos = t.parseToNode(sen)
  morph = all_morph(bos, sen)
  
  for e in morph
    puts "%s\t%s\t%s\t%s" % [e[:pos], e[:len],
    e[:node].surface.force_encoding('utf-8'), e[:node].feature.force_encoding('utf-8')]
  end
end

def main
  while line = STDIN.gets do
    line.chomp!
    body = line
    
    t = MeCab::Tagger.new('-a -l2')
    bos = t.parseToNode(body)
    morph = all_morph(bos, body)
    
    data = ''
    
    body.chars.each_with_index do |c,i|
      if c != ' '
        cov = morph.select {|e| (e[:pos]..(e[:pos]+e[:len]-1)).include? i} .map {|e| e[:node] }
        beg = morph.select {|e| e[:pos] == i } .map {|e| e[:node] }
        
        total = cov.reduce(0.0) {|sum, n| sum+n.prob }
        bprob = beg.reduce(0.0) {|sum, n| sum+n.prob }
        
        if total
          bscore = -1 * (Math.log(bprob / total + 1E-10) * 10.0).to_i
          iscore = -1 * (Math.log((total - bprob) / total + 1E-10) * 10.0).to_i
        else
          bscore = -1 * (Math.log(1E-10) * 10.0).to_i
          iscore = -1 * (Math.log(1E-10) * 10.0).to_i
        end
        
        if !beg.empty?
          maxnode = beg.max_by {|n| n.prob }
          feature = maxnode.feature.force_encoding('utf-8').split(',')[0..1].join(',')
        else
          feature = 'None'
        end
      else # c == ' '
        bscore = -1 * (Math.log(1E-10) * 10.0).to_i
        iscore = -1 * (Math.log(1E-10) * 10.0).to_i
        feature = '記号,空白'
      end
      
      tag = ''
      
      data << "%s\t%03d\t%03d\t%s\t%s\n" % [c.ord, bscore, iscore, feature, tag]
    end
    
    data << "\n"
  end
  
  chunker = YamCha::Chunker.new('__ -m data/smiley13.model'.split)
  result = chunker.parse data
  
  print_result result
end

main
