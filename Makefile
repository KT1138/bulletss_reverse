#CXX = i586-mingw32msvc-g++
#LN = i586-mingw32msvc-gcc
LN = gcc
INCLUDES = -I. -ISDL -Iopengl
LIBS = -lSDL -lGL -lGLU
#LIBS = -lSDL -lopengl32 -lglu32   # for MinGW
CXXFLAGS = -g   # for debug
#CXXFLAGS = -O2 
#CXXFLAGS=-O2 -I/usr/local/include   # for MinGW
CXXOBJS = bulletss.o charactor.o axis.o cpuinput.o camera.o mymath.o mesaglu.o
#COBJS = dirent_d.o

all: bulletss
#all: bulletss.exe

#	$(LN) -o bulletss $(CXXBJS) $(COBJS) bulletml/libbulletml_d.a cpu/libcpu.a -lphobos2 -lpthread -lm -lstdc++ $(LIBS)
	$(LN) -o bulletss $(CXXOBJS) cpu/dfakemain.o bulletml/libbulletml_d.a cpu/libcpu.a -lpthread -lphobos2 -lrt -lm -lstdc++ $(LIBS)
#	$(LN) -o bulletss.exe $(CXXOBJS) cpu/dfakemain.o bulletml/libbulletml_d.a libphobos2.a libSDL.a libglut.a cpu/libcpu.a -L/usr/local/lib -lphobos2 -lrt -lm -lstdc++ $(LIBS)

bulletss: bulletml.h $(CXXOBJS) # $(COBJS)
#bulletss.exe: bulletml.h $(CXXOBJS) # $(COBJS)
	$(MAKE) -C bulletml
	$(MAKE) -C cpu

clean:
	rm -f *.o
	make -C bulletml clean
	make -C cpu clean

$(CXXOBJS): %.o: %.cc
	$(CXX) -c $(INCLUDES) $(CXXFLAGS) $<

