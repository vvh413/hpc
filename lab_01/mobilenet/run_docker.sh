sudo docker run -it \
     --ipc=host --privileged --rm \
    -p 8888:8888 -v $(pwd):/work \
    torch110