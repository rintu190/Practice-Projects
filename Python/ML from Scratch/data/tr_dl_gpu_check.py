# dl_gpu_check.py
import torch
import torch.nn as nn

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using:", device)

model = nn.Sequential(
    nn.Linear(1024, 4096),
    nn.ReLU(),
    nn.Linear(4096, 10)
).to(device)

x = torch.randn(2048, 1024).to(device)
y = torch.randint(0, 10, (2048,)).to(device)

loss_fn = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters())

for i in range(10):
    optimizer.zero_grad()
    output = model(x)
    loss = loss_fn(output, y)
    loss.backward()
    optimizer.step()
    print(f"Step {i}, Loss {loss.item()}")
