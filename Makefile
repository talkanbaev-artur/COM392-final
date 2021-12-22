CC= g++
CDC= $(shell ./scripts/find_cuda.sh) --std c++14 -dc
FINAL_CDC = $(shell ./scripts/find_cuda.sh) --std c++14
SDIR= src
BDIR= bin
FLAGS=  -L/usr/local/cuda/lib64 -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
ANIMLIBS= -lglut -lGL
ALGO_FILES = $(shell ls src/algorithm | grep .cu | sed --expression='s/^/$(BDIR)\/algorithm\//g' | tr '\n' ' ' | sed --expression='s/\.cu/\.o/g')
#placeholder n - later would be updated
YAML_F= n

# -o flag builder
OUT = -o $@

.SILENT: dirs clean

all: preps $(ALGO_FILES) $(BDIR)/interface.o $(BDIR)/gpuCode.o $(BDIR)/animate.o $(BDIR)/hostCode.o $(BDIR)/random.o
	$(FINAL_CDC) -o bin/vs bin/*.o bin/algorithm/*.o $(FLAGS) $(ANIMLIBS) $(YAML_F)

$(BDIR)/interface.o: src/interface.cpp src/hostCode.h
	$(CDC) -w -c src/interface.cpp $(OUT) $(YAML_F)

$(BDIR)/hostCode.o: src/hostCode.cpp src/hostCode.h src/params.h
	$(CDC) -c -w src/hostCode.cpp $(OUT)

$(BDIR)/gpuCode.o: src/gpuCode.cu src/gpuCode.h src/params.h
	$(CDC) -w -c src/gpuCode.cu $(OUT)

$(BDIR)/animate.o: src/animate.cu src/animate.h src/gpuCode.h src/params.h
	$(CDC) -w -c src/animate.cu $(OUT)

$(BDIR)/random.o: src/random.cu src/random.cuh
	$(CDC) -w -c $< -o $@

$(ALGO_FILES): $(BDIR)/%.o: src/%.cu
	$(CDC) -w -c $< -o $@


# ---------- PREPARATION STAGE ----------

preps: dirs

#run script to check if needed libraries are here
setup_yaml: YAML_F =  $(shell ./scripts/yaml.sh && true)
	YAML_F = $(shell ./scripts/yaml.sh && true)

#dynamic update of YAML_F var
#update_yaml : YAML_F = $(shell pkg-config --cflags --libs yaml-cpp)
#	YAML_F = $(shell pkg-config --cflags --libs yaml-cpp)

# create a bin dir for build artifacts
dirs:
	mkdir -p $(BDIR)/algorithm

# ---------- Utils ----------
clean:
	rm -rf $(BDIR)
