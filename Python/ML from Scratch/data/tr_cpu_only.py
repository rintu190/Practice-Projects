# cpu_only.py
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"

import torch
import time

device = torch.device("cpu")
print("Device:", device)

# Large matrix multiplication
a = torch.randn(8000, 8000, device=device)
b = torch.randn(8000, 8000, device=device)

start = time.time()
c = torch.matmul(a, b)
print("Time taken (CPU):", time.time() - start)
