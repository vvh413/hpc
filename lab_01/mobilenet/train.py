import numpy as np

import torch
import torch.nn as nn

import torchvision.models as models
import torchvision.datasets as datasets
import torchvision.transforms as T

from tqdm import tqdm

def accuracy(output, target):
    with torch.no_grad():
        pred = output.argmax(-1)
        correct = (pred == target).float().sum() / len(target)
        return correct

transform = T.Compose([
    T.Resize(256), 
    T.CenterCrop(224), 
    T.ToTensor(), 
    T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])
train_ds = datasets.ImageFolder("imagenet/train", transform=transform)
val_ds = datasets.ImageFolder("imagenet/val", transform=transform)

train = torch.utils.data.DataLoader(train_ds, batch_size=32, shuffle=True, num_workers=16)
val = torch.utils.data.DataLoader(val_ds, batch_size=32, shuffle=False, num_workers=16)

model = models.mobilenet_v2(pretrained=True)
# model = models.mobilenet_v2()
for param in model.parameters():
    param.requires_grad = False
model.classifier[1] = nn.Linear(in_features=1280, out_features=1000, bias=True)

lr = 5e-4
# momentum = 0.9
optimizer = torch.optim.Adam(model.parameters(), lr=lr)
criterion = nn.CrossEntropyLoss()

epochs = 5
for n in range(epochs):
    model.train()
    accur, losses = [], []
    bar = tqdm(total=len(train))
    for images, target in train:

        output = model(images)
        loss = criterion(output, target)

        acc = accuracy(output, target)

        losses.append(loss.item())
        accur.append(acc)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        bar.set_description(
            f"Epoch [{n+1}/{epochs}] | Loss: {np.round(np.mean(losses), 3)} | Acc: {np.mean(accur)} ")
        bar.update()

    print(f'Accuracy Train: {np.mean(accur):.3f}')
    torch.save(model, f"checkpoints/checkpoint_{n}.pt")


    model.eval()
    accur, losses = [], []
    with torch.no_grad():
        for images, target in val:

            output = model(images)
            loss = criterion(output, target)

            acc = accuracy(output, target)
            accur.append(acc)

        print(f'Accuracy Val: {np.round(np.mean(accur), 3)}')

torch.save(model, "checkpoints/model.pt")