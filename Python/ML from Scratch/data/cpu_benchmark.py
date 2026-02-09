import torch, time

device = torch.device("cpu")
print("Device:", device)

start = time.time()
for _ in range(10):
    x = torch.randn(12000, 12000, device=device)
    y = torch.matmul(x, x)

print("CPU time:", time.time() - start)
