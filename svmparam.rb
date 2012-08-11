def main
  filename = ARGV[0]

  fin = open(filename)
  (ver,solver,type,kern,degree,param_g,param_r,param_s,
   msize,csize,dsize,ndsize,dasize,svsize,tsize,fsize,
   _res1,_res2,param_size) = fin.read(144).unpack('a32IIa32IdddIIIIIIIIIII')
  raw_param = fin.read(param_size).split("\0")
  d_param = Hash[*raw_param]
  
  puts "version:  #{ver.strip}"
  puts "solver:   %s" % ['PKB','PKI','PKE'][solver]
  puts "type:     %s" % ['pair-wise','one-vs-rest'][type]
  puts "kernel:   #{kern.strip}"
  puts "features: %s" % d_param['feature_parameter']
  puts "date:     %s" % d_param['date']
end

main
