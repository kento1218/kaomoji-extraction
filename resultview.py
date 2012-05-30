import sys


def main():
    sen = u''
    smileya = []
    
    for line in sys.stdin:
        line = line.strip()
        
        ''' bos detected '''
        if not line:
            print "text: %s" % sen.encode('utf-8')
            print "result: %s" % u', '.join(map(lambda (s, l): sen[s:s+l], smileya)).encode('utf-8')
            sen = u''
            smileya = []
            continue
        
        dat = line.split('\t')
        code = dat[0]
        tag = dat[-1]
        
        if tag == 'B':
            smileya.append( (len(sen), 1) )
        if tag == 'I':
            (s, l) = smileya.pop()
            smileya.append( (s, l+1) )
        
        sen += unichr(int(code))


if __name__ == '__main__':
    main()
