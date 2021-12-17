CC= g++
CDC= $(shell ./scripts/find_cuda.sh)
SDIR= src
BDIR= bin
FLAGS=  -std=c++17 -L/usr/local/cuda/lib64 -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
ANIMLIBS= -lglut -lGL

#placeholder n - later would be updated
YAML_F= n

# -o flag builder
OUT = -o $@

all: preps $(BDIR)/interface.o $(BDIR)/gpuCode.o $(BDIR)/animate.o $(BDIR)/hostCode.o
	$(CC) -o bin/myTemplate bin/interface.o bin/gpuCode.o bin/hostCode.o bin/animate.o $(FLAGS) $(ANIMLIBS) $(YAML_F)

$(BDIR)/interface.o: src/interface.cpp src/interface.h src/params.h src/animate.h src/animate.cu
	$(CC) -w -c src/interface.cpp $(FLAGS) $(OUT) 

$(BDIR)/hostCode.o: src/hostCode.cpp src/hostCode.h src/params.h
	$(CC) -c -w src/hostCode.cpp $(FLAGS) $(OUT)

$(BDIR)/gpuCode.o: src/gpuCode.cu src/gpuCode.h src/params.h
	$(CDC) -w -c src/gpuCode.cu $(OUT)

$(BDIR)/animate.o: src/animate.cu src/animate.h src/gpuCode.h src/params.h
	$(CDC) -w -c src/animate.cu $(OUT)

# ---------- PREPARATION STAGE ----------

preps: setup_yaml dirs

#run script to check if needed libraries are here
setup_yaml:
	$(shell ./scripts/yaml.sh)

#dynamic update of YAML_F var
update_yaml : YAML_F = $(shell pkg-config --cflags --libs yaml-cpp)
	YAML_F = $(shell pkg-config --cflags --libs yaml-cpp)

# create a bin dir for build artifacts
dirs:
	mkdir -p $(BDIR)

# ---------- Utils ----------
clean:
	rm -rf $(BDIR)
