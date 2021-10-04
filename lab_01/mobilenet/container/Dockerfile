FROM python:3.7.3

RUN python3 -m pip install --upgrade pip
RUN pip3 install -U pip setuptools wheel tqdm torch==1.1.0 torchvision==0.3.0

RUN apt-get -y update
RUN apt-get -y install htop

CMD ["bash"]
