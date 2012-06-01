# -*- coding: utf-8 -*-
require 'MeCab'

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
  for i in 0..(sen.length-1)
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
    
    for i in 0..(body.length-1)
      c = body[i]
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
      
      puts "%s\t%03d\t%03d\t%s\t%s" % [c.ord, bscore, iscore, feature, tag]
    end
    
    puts ""
  end
end

main
