CC= g++
CDC= nvcc
SDIR= src
BDIR= bin
FLAGS= -L/usr/local/cuda/lib64 -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
ANIMLIBS= -lglut -lGL

# -o flag builder
OUT = -o $(BDIR)/$@


all: dirs interface.o gpuCode.o animate.o hostCode.o
	g++ -o bin/myTemplate bin/interface.o bin/gpuCode.o bin/hostCode.o bin/animate.o $(FLAGS) $(ANIMLIBS)

interface.o: src/interface.cpp src/interface.h src/params.h src/animate.h src/animate.cu
	g++ -w -c src/interface.cpp $(FLAGS) $(OUT)

hostCode.o: src/hostCode.cpp src/hostCode.h src/params.h
	g++ -c -w src/hostCode.cpp $(FLAGS) $(OUT)

gpuCode.o: src/gpuCode.cu src/gpuCode.h src/params.h
	nvcc -w -c src/gpuCode.cu $(OUT)

animate.o: src/animate.cu src/animate.h src/gpuCode.h src/params.h
	nvcc -w -c src/animate.cu $(OUT)

# create a bin dir for build artifacts
dirs:
	mkdir -p $(BDIR)

clean:
	rm -rf $(BDIR)
