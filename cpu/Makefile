#INCLUDES += -I../util
INCLUDES += -I./ 
DFLAGS = -g -d
#DFLAGS = -O -release -d
#SOURCES=$(wildcard *.cpp)
SOURCES=$(wildcard *.d)
OBJS=$(SOURCES:.d=.o)
#OBJS=chairma.o cp.o cpputi.o cpu_.o cpuinf.o oblivio.o pai.o positio.o reflectio.o roundtri.o uti.o vet.o
TARGET=libcpu.a

#all: ../cpu.d $(TARGET)
all: $(TARGET)

# ../cpu.d: cpu_d.cpp
# 	perl create_d_import.pl cpu_d.cpp ../cpu.d

$(TARGET): $(OBJS)
	$(AR) cru $(TARGET) $(OBJS)

%.o:%.d
	 ~/usr/src/dmd2/linux/bin32/dmd -c $(DFLAGS) $(INCLUDES) $<
#	 dmd -c $(DFLAGS) $(INCLUDES) $<   

clean:
	rm -f $(OBJS) $(TARGET)

