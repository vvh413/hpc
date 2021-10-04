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
        # print(pred, target)
        # print(pred.shape, target.shape)
        correct = (pred == target).float().sum() / len(target)
        return correct

transform = T.Compose([
    T.Resize(224), 
    T.CenterCrop(224), 
    T.ToTensor(), 
    T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

val_ds = datasets.ImageFolder("imagenet/val", transform=transform)
val = torch.utils.data.DataLoader(val_ds, batch_size=8, shuffle=False, num_workers=4)

# model = models.mobilenet_v2()
model = torch.load("checkpoints/model.pt")

criterion = nn.CrossEntropyLoss()

model.eval()
accur, losses = [], []
with torch.no_grad():
    for images, target in tqdm(val):

        output = model(images)
        loss = criterion(output, target)

        acc = accuracy(output, target)
        accur.append(acc)

    print(f'Accuracy Val: {np.round(np.mean(accur), 3)}')
