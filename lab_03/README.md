# Лаба №3

## Ресурсы

 * [Методичка](https://docs.google.com/document/d/16lugWl7jzaZLu77CT7Nwth-79i9-Q3JlWTn30_YbY18)
 * [Мануал](https://docs.google.com/document/d/1VIQyMu8k8y6vo3g0n1pe_v-3JwgqNzK2B6mT7LT_3wQ/)
 * Репозиторий [Verilog Generator of Neural Net Digit Detector for FPGA](https://github.com/ZFTurbo/Verilog-Generator-of-Neural-Net-Digit-Detector-for-FPGA)

## Выполнение

### Обучение

* Скачаем репозиторий
```bash
git clone https://github.com/ZFTurbo/Verilog-Generator-of-Neural-Net-Digit-Detector-for-FPGA
```

* Установим библиотеки
```bash
pip install pillow opencv-python tensorflow keras
```

* Выполним скрипты
```bash
python r01_train_neural_net_and_prepare_initial_weights.py
python r02_rescale_weights_to_use_fixed_point_representation.py
python r03_find_optimal_bit_for_weights.py
python r04_verilog_generator_grayscale_file.py
python r05_verilog_generator_neural_net_structure.py
```

### Компиляция и загрузка

Полученный код на Verilog находится в директории `verilog`. Для удобства он был загружен в данный репозиторий. Также сюда были загружены полученные веса (директория `weigths`).

В директории `verilog/imp` находится проект Quartus. Запустим его и выполним компиляцию. Файл прошивки с расширением `.sof` можно будет найти в директории `verilog/imp/output_files`.

