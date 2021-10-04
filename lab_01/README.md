# Практическая работа №1: Проектирование встраиваемых систем с использованием Raspberry Pi

## Задание

 1. Подключить 1 пироэлектрический датчик движения, 1 светодиод. При обнаружении движения датчиком, включать светодиод и начинать прием изображения с камеры. При срабатывании датчика по видеопотоку определять, двигается ли человек. 
 2. Реализовать нейронную сеть MobileNet с использованием Raspberry PI.

## Основная часть

### Установка ОС

 1. Скачать образ с [официального сайта](https://www.raspberrypi.org/software/)
 2. Записать образ на microSD командой
 ```bash
    sudo dd if=2021-05-07-raspios-buster-armhf.img of=/dev/sdb bs=4M status=progress
 ```
 3. Вставить карту памяти в Raspberry Pi и запустить.

### Установка бибилиотек и зависимостей

 1. Необходимые зависимости
 ``` bash
 sudo apt-get -y update
 sudo apt-get -y install libhdf5-dev libhdf5-serial-dev libatlas-base-dev libjasper-dev libqtgui4 \
                         libqt4-test libopenblas-dev libblas-dev m4 cmake cython python3-dev \
                         python3-yaml python3-setuptools python3-wheel python3-pillow python3-numpy
 ```
 2. OpenCV
 ```bash
 sudo pip3 install opencv-contrib-python==4.1.0.25
 ```
 3. PyTorch и torchvision
 ```bash
 git clone https://github.com/marcusvlc/pytorch-on-rpi
 cd pytorch-on-rpi
 sudo pip3 install torch-1.1.0-cp37-cp37m-linux_armv7l.whl
 sudo pip3 install torchvision-0.3.0-cp37-cp37m-linux_armv7l.whl
 sudo mv _C.cpython-37m-arm-linux-gnueabi.so _C.so
 sudo mv _dl.cpython-37m-arm-linux-gnueabi.so _dl.so
 ```

### Задание 1

 1. Произвести подключение пироэлектрический датчик движения и светодиод к GPIO и камеру по USB
 2. Запустить скрипт
 ```bash
 python3 gpio_opencv/main.py
 ```

 Пироэлектрический датчик очень чувствителен к теплу и может большую часть времени выдавать высокий уровень сигнала.

### Задание 2

Используется MobileNet_V2 из библиотеки `torchvision`. По умолчанию, представляет собой классификатор на 1000 классов. Было предположение, что предобучен на ImageNet, но почему-то выдавал accuracy ~25%. Поэтому был было решено переобучить линейный слой классификатора. В итоге получили accyracy 59%, что тоже не очень хороший показательно, но все же лучше, чем было.

Скачать датасет ImageNet с некоторых пор стало сложно сделать с официального сайта. Альтернативная уменьшенная версия была найдена на [kaggle](https://www.kaggle.com/ifigotin/imagenetmini-1000). Сейчас его можно получить так:
 ```bash
 wget https://217.70.27.118:9013/imagenet.zip
 ```
 Также его надо разархивировать
 ```bash
 mkdir imagenet
 unzip imagenet.zip -d imagenet
 ```

Обучение производилось на стационарном компьютере с использованием docker-контейнера для воссоздания необходимый версий библиотек. Порядок действий:
 1. Собрать контейнер
 ```bash
 cd mobilenet
 chmod -R +x *.sh 
 cd container
 ./build.sh
 ```
 В итоге будет собран docker-образ с тегом `torch110`
 
 2. Запустить docker-образ
 ```bash
 cd ..
 ./run_docker.sh
 ```
 Запустится образ, в котором рабочая директория хоста будет смонтирована в директорию `/work`.

 3. Запустить скрипт обучения
 ```bash
 cd /work
 python3 train.py
 ```
 В процессе будут созданы чекпоинты (после каждой эпохи) в директории `checkpoints`. Последний чекпоинт будет продублирован как `model.pt`
 
Теперь можно производить запуск на Raspberry Pi. Для этого сначала необходимо перенести туда чекпоинты и датасет. Сам запуск осуществляется так:
```bash
python3 eval.py
```

Данный скрипт загрузит ческпоинт из `checkpoints/model.pt` и произведет валидацию на изображениях из `imagenet/val`. Изображений там 3923 и валидация занимает больше часа. Для демонстрации рекомендуется отобрать небольшой набор изображений.
```
100%|███████████████████████████████████████████████████| 246/246 [1:18:20<00:00, 19.11s/it]
Accuracy Val: 0.5920000076293945
```