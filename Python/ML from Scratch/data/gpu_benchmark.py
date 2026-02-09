import torch, time

device = torch.device("cuda")
print("Device:", device)

# warmup
for _ in range(3):
    x = torch.randn(12000, 12000, device=device)
    y = torch.matmul(x, x)

torch.cuda.synchronize()
start = time.time()

for _ in range(10):
    x = torch.randn(12000, 12000, device=device)
    y = torch.matmul(x, x)

torch.cuda.synchronize()
print("GPU time:", time.time() - start)
