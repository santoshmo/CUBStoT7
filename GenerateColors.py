from random import random, seed
from math import sqrt, pi
tri=.8660
dist = lambda rgb,RGB: sqrt(sum((c-C)**2 for c,C in zip(rgb,RGB)))
def generate_colors():
    '''Generator of RGB values, with no two colors unnecessarily close.
       Highly inefficient (consider the redundant computation due to
       bad flow control and lack of memory-use!),
       but not called from any time-critical functions.
    '''
    seed(0)
    past_colors = []
    for rgb in [(0.999,0,0),(0,0.999,0),(0,0,0.999)]:
        past_colors.append(tuple(int(c*256) for c in rgb))
        yield '#%02x%02x%02x' % past_colors[-1]
    while True:
        max_distance = sqrt(tri/(len(past_colors)+1) / pi) * 256
        rgb = random(),random(),random()
        #rgb=tuple(c/sum(rgb) for c in rgb)
        for pc in past_colors:
            if dist(rgb,pc)<max_distance: break
        else:
            past_colors.append(tuple(int(c*256) for c in rgb))
            yield '#%02x%02x%02x' % past_colors[-1]
