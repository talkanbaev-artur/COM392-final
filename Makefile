
FLAGS= -L/usr/local/cuda/lib64 -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
ANIMLIBS= -lglut -lGL


all: interface.o gpuCode.o animate.o hostCode.o
	g++ -o myTemplate interface.o gpuCode.o hostCode.o animate.o $(FLAGS) $(ANIMLIBS)

interface.o: interface.cpp interface.h params.h animate.h animate.cu
	g++ -w -c interface.cpp $(FLAGS)

hostCode.o: hostCode.cpp hostCode.h params.h
	g++ -c -w hostCode.cpp $(FLAGS)

gpuCode.o: gpuCode.cu gpuCode.h params.h
	nvcc -w -c gpuCode.cu

animate.o: animate.cu animate.h gpuCode.h params.h
	nvcc -w -c animate.cu

clean:
	rm interface.o;
	rm hostCode.o
	rm gpuCode.o;
	rm animate.o;
