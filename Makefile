# Конфигурация компилятора
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17 -O2
TARGET := karatsuba_gen
SRC := karatsuba_gen.cpp

# Параметры по умолчанию
DEFAULT_N := 16
DEFAULT_B := 4
OUT_DIR := build

.PHONY: all clean gen test help

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)
	rm -rf $(OUT_DIR)

gen: $(TARGET)
	@mkdir -p $(OUT_DIR)
	./$(TARGET) -N $(DEFAULT_N) -B $(DEFAULT_B)

# Генерация с кастомной разрядностью (make gen_custom N=64 B=8)
gen_custom: $(TARGET)
	@mkdir -p $(OUT_DIR)
	./$(TARGET) -N $(N) -B $(if $(B),$(B),$(DEFAULT_B))

test: $(TARGET)
	@mkdir -p $(OUT_DIR)
	./$(TARGET) -N $(DEFAULT_N)
	iverilog -o $(OUT_DIR)/tb $(OUT_DIR)/mul_karatsuba_tb.v $(OUT_DIR)/mul_karatsuba.v
	vvp $(OUT_DIR)/tb

help:
	@echo "KARATSUBA VERILOG GENERATOR MAKEFILE"
	@echo "===================================="
	@echo "Цели:"
	@echo "  all       : Компилирует генератор Verilog (по умолчанию)"
	@echo "  clean     : Удаляет сгенерированные файлы и бинарник"
	@echo "  gen       : Генерирует 16-битный умножитель в build/"
	@echo "  gen_custom: Генерирует умножитель с кастомными параметрами"
	@echo "              Пример: make gen_custom N=64 B=8"
	@echo "  test      : Запускает тесты для 16-битного умножителя"
	@echo "  help      : Выводит эту справку"
	@echo ""
	@echo "Все файлы всегда генерируются в директорию: $(OUT_DIR)"
	@echo ""
	@echo "Примеры:"
	@echo "  make gen_custom N=32     # 32-бит с порогом B=4"
	@echo "  make gen_custom N=64 B=8 # 64-бит с порогом B=8"
	@echo "  make test                # Тест 16-битного умножителя"