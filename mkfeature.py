# -*- coding: utf_8 -*-
import sys
import math
import re
import MeCab
import optparse


def begin_node_list(bos, sen, i):
	result = []
	if sen[i] != u' ':
		spaces = re.compile(' +$').search(sen[:i])
		nspaces = len(spaces.group()) if spaces else 0
		node = bos.begin_node_list(len(sen[:i].encode('utf-8'))-nspaces)
		while node:
			result.append(node)
			node = node.bnext
	return result


def all_morph(bos, sen):
	morph = []
	for i in range(len(sen)):
		nodes = begin_node_list(bos, sen, i)
		for n in nodes:
			surf = n.surface.decode('utf-8')
			morph.append( (i, len(surf), n) )
	return morph


def test():
	sen = u'井ノ上     です'
	t = MeCab.Tagger('-a -l2')
	bos = t.parseToNode(sen.encode('utf-8'))
	morph = all_morph(bos, sen)
	
	for entry in morph:
		(pos, length, node) = entry
		print "%s\t%s\t%s\t%s" % (pos, length, node.surface, node.feature)
	
	print "========="
	
	pos = 8
	begin = [e[2] for e in filter(lambda e:e[0] == pos, morph)]
	for node in begin:
		print "%s\t%s" % (node.surface, node.feature)


'''
   boundary check.
'''
def bcheck(test, start, length):
	return test >= start and test < (start + length)


def read_smiley(filename):
	smiley = {}
	for line in file(filename):
		body = line.decode('utf-8').strip().split('\t')
		elms = []
		for s in body[1:]:
			dat = s.split(':')
			elms.append({'offset':int(dat[0]), 'len':int(dat[1])})
		smiley[body[0]] = elms
	return smiley


def main():
	parser = optparse.OptionParser()
	parser.add_option('--tag', '-t', default=None, help='tagged file')
	parser.add_option('--raw', '-r', default=False, action='store_true', help='use raw input')
	(opt, args) = parser.parse_args()

	smiley = None
	if opt.tag:
		smiley = read_smiley(opt.tag)
	
	for line in sys.stdin:
		line1 = line.decode('utf-8').strip()
		if not opt.raw:
			dat = line1.split('\t')
			if len(dat) != 2:
				continue
			id = dat[0]
			body = dat[1]
		else:
			id = None
			body = line1
		
		t = MeCab.Tagger('-a -l2')
		bos = t.parseToNode(body.encode('utf-8'))
		morph = all_morph(bos, body)
		
		for i in range(len(body)):
			c = body[i]
			if c != u' ':
				cov = [e[2] for e in filter(lambda e:bcheck(i, e[0], e[1]), morph)]
				begin = [e[2] for e in filter(lambda e:e[0] == i, morph)]
				mid = filter(lambda l: l.id not in [n.id for n in begin], cov)
				
				total = sum([n.prob for n in cov])
				bprob = sum([n.prob for n in begin])
				if total:
					bscore = -1 * int(math.log(bprob / total + 1E-10) * 10.0)
					iscore = -1 * int(math.log((total - bprob) / total + 1E-10) * 10.0)
				else:
					bscore = -1 * int(math.log(1E-10) * 10.0)
					iscore = -1 * int(math.log(1E-10) * 10.0)
				
				if begin:
					maxnode = max(begin, key=lambda n:n.prob)
					feature = ','.join(maxnode.feature.decode('utf-8').split(',')[:2])
				else:
					feature = 'None'
			else: # c == u' '
				bscore = -1 * int(math.log(1E-10) * 10.0)
				iscore = -1 * int(math.log(1E-10) * 10.0)
				feature = u'記号,空白'
			
			if smiley:
				stags = filter(lambda e:bcheck(i, e['offset'], e['len']), smiley[id]) if id in smiley else []
				if stags:
					tag = u'B' if i == stags[0]['offset'] else u'I'
				else:
					tag = u'O'
			else:
				tag = ''
			
			print (u"%s\t%03d\t%03d\t%s\t%s" % (ord(c), bscore, iscore, feature, tag)).encode('utf-8')
		print

if __name__ == '__main__':
	main()
