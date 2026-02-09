# gpu_used.py
import torch
import time

assert torch.cuda.is_available(), "CUDA NOT AVAILABLE"

device = torch.device("cuda")
print("Device:", device)

a = torch.randn(12000, 12000, device=device)
b = torch.randn(12000, 12000, device=device)

torch.cuda.synchronize()
start = time.time()
c = torch.matmul(a, b)
torch.cuda.synchronize()

print("Time taken (GPU):", time.time() - start)
