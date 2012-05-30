import sys


def main():
    sen = u''
    diff = False
    
    smileye = []
    smileya = []
    
    for line in sys.stdin:
        line = line.strip()
        
        ''' bos detected '''
        if not line:
            if diff:
                print sen.encode('utf-8')
                print 'E: %s A: %s' % (smileye, smileya)
            sen = u''
            diff = False
            smileye = []
            smileya = []
            continue
        
        dat = line.split('\t')
        code = dat[0]
        (expect, actual) = dat[-2:]
        
        if expect == 'B':
            smileye.append( (len(sen), 1) )
        if expect == 'I':
            entry = smileye.pop()
            smileye.append( (entry[0], entry[1]+1) )
        
        if actual == 'B':
            smileya.append( (len(sen), 1) )
        if actual == 'I':
            entry = smileya.pop()
            smileya.append( (entry[0], entry[1]+1) )
        
        diff = diff or (expect != actual)
        sen += unichr(int(code))


if __name__ == '__main__':
    main()
