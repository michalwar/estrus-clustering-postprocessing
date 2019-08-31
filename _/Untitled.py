#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas as pd
import os
import datetime
import matplotlib.pyplot as plt
from copy import deepcopy
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings("ignore")
from sklearn import decomposition
from sklearn.cluster import MeanShift
from sklearn.mixture import GaussianMixture
from matplotlib.patches import Rectangle
import matplotlib.pylab as pylab
params = {'legend.fontsize': 'x-large',
          'figure.figsize': (15, 5),
         'axes.labelsize': 'x-large',
         'axes.titlesize':'x-large',
         'xtick.labelsize':'x-large',
         'ytick.labelsize':'x-large'}
pylab.rcParams.update(params)


# In[ ]:


def isOk(p, q):
    if q[0] - p[0] > 24*24 or q[0] - p[0] < 17*24:
        return False
    return True


# In[3]:


def getPointMap(ailArr=[], threshold=0):
    pointMap = []
    for idx, ail in enumerate(ailArr):
        if ail < threshold:
            continue
        nearPoints = []
        for subIdx, subAil in enumerate(ailArr[idx:idx+18]):
            if subAil > threshold:
                nearPoints.append((idx + subIdx, subAil))
        if len(nearPoints) == 1:
            pointMap.append(nearPoints[0])
        elif len(nearPoints) > 1:
            pointMap.append((nearPoints[0][0], np.sum([i[1] for i in nearPoints])))
    return pointMap, (len(ailArr)/24)/18 + 1

def getPointSet(ailArr, maxNumEvent, idx, listPoints, maxReward, maxSet):
    reward = rewardFunc(listPoints)
    if reward > maxReward[0]:
        maxReward[0] = reward
        maxSet[0] = listPoints.copy()
    
    if idx >= len(ailArr) or len(listPoints) > maxNumEvent or (reward == -1 and len(listPoints) >= 2):
        return maxReward[0], maxSet[0]
    getPointSet(ailArr, maxNumEvent, idx + 1, listPoints.copy(), maxReward, maxSet)
    listPoints.append(ailArr[idx])
    getPointSet(ailArr, maxNumEvent, idx + 1, listPoints.copy(), maxReward, maxSet)
    return maxReward[0], maxSet[0]


# In[4]:


def rewardFunc(points=[]):
    if len(points) == 0:
        return -1
    first_point = points[0]
    for point in points[1:]:
        if point[0] - first_point[0] > 24*24 or point[0] - first_point[0] < 17*24:
            return -1
        first_point = point
    
    reward = 0
    for point in points:
        reward += point[1]
    
    return reward*(1.2 ** len(points))


# In[ ]:




