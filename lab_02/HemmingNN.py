import numpy as np


# Входные изображения

V = [
    [-1, 1, -1, -1, 1, -1, -1, 1, -1],
    [1, 1, 1, 1, -1, 1, 1, -1, 1],
    [1, -1, 1, 1, 1, 1, 1, -1, 1],
    [1, 1, 1, 1, -1, -1, 1, -1, -1],
    [-1, -1, -1, -1, 1, -1, -1, -1, -1]
]

W = np.array(V).transpose() #/2

b = W.shape[0] #/2
k = 1 # 0.1
Un = b*2 + 1 #1/k
n = len(V)
eps = 1/n

# K = 1000

# W = W*K
# b, k, Un, n, eps = b*K, k*K, Un*K, n*K, eps*K

print(W)
print(b, k, Un, n, eps)


# Линейный слой
def z_layer(X):
    res = [0 for _ in range(len(V))]
    for i in range(len(V)):
        temp_res = 0
        for j in range(len(W)):
            temp_res += X[j] * W[j][i]
        temp_res += b
        res[i] = temp_res
    return res

def z_layer2(X):
    res = [0 for _ in range(len(V))]
    for i in range(len(V)):
        temp_res = 0
        for j in range(len(W)):
            temp_res += X[j] == W[j][i]
        # temp_res += len(W)/2
        res[i] = temp_res
    return res

def z_activation(U):
    if U < 0:
        return 0
    elif U > Un:
        return Un
    else:
        return k*U


def z_layer_act(vec):
    res = [0 for _ in range(len(vec))]
    for i in range(len(vec)):
        res[i] = z_activation(vec[i])
    return res


def maxnet_iter(vec):
    result_vec = [0 for _ in range(len(vec))]
    for i in range(len(vec)):
        temp_res = 0
        for j in range(len(vec)):
            if i != j:
                temp_res += vec[j]
        # temp_res *= eps
        res = (n*vec[i] - temp_res) // n
        if res > 0:
            result_vec[i] = res
    return result_vec

new_vec = z_layer([-1, -1, 1, 1, 1, 1, 1, -1, 1])
new_vec = z_layer_act(new_vec)
print(new_vec)
for i in range(10):
    if new_vec != maxnet_iter(new_vec):
        new_vec = maxnet_iter(new_vec)
        print(new_vec)
    else:
        break

# print(z_layer_act(z_layer([-1, -1, 1, 1, 1, 1, 1, -1, 1])))
