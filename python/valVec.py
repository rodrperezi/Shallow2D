import time
import numpy as np
from numpy import linalg as LA

t = time.time()
# w, v = LA.eig(np.diag((1,2,3)))
N = 1000
w, v = LA.eig(np.diag(range(N)))
print 'elapsed %s ' %(time.time() - t)
