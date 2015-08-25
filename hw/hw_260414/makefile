C := gcc-4.6
CFLAGS := -m32 -std=c99 -D_POSIX_C_SOURCE=199309L
CXX := g++-4.6
CXXFLAGS := -m32 -lstdc++ -std=c++0x
SOURCES = main.c

TEST_SOURCES = test.cpp
ASM_SOURCES = georgeee_dct.asm
MAIN2_SOURCES = main2.c
MAIN2_ASM_SOURCES = georgeee_dct.asm

ASM = yasm -f elf
EXECUTABLE = main
TEST = test
MAIN2 = main2 

OBJECTS = $(SOURCES:.c=.o) $(ASM_SOURCES:.asm=.ao)
TEST_OBJECTS = $(TEST_SOURCES:.cpp=.o) $(ASM_SOURCES:.asm=.ao)
MAIN2_OBJECTS = $(MAIN2_SOURCES:.c=.o) $(MAIN2_ASM_SOURCES:.asm=.ao_g)

all : $(EXECUTABLE) $(MAIN2) $(TEST)

main.o : main.c
	$(C) -c -o $@ $< $(CFLAGS) -Ofast
test.o : test.cpp
	$(CXX) -c -o $@ $< $(CXXFLAGS) -Ofast
main2.o : main2.c
	$(C) -c -o $@ $< $(CFLAGS) -g

%.ao_g : %.asm
	$(ASM) -g dwarf2 -o $@ $<
%.ao : %.asm
	$(ASM) -o $@ $<


$(MAIN2) : $(MAIN2_OBJECTS)
	$(CXX) $(MAIN2_OBJECTS) $(CXXFLAGS) -g -o $(MAIN2)

$(TEST) : $(TEST_OBJECTS)
	$(CXX) $(TEST_OBJECTS) $(CXXFLAGS) -Ofast -o $@


$(EXECUTABLE) : $(OBJECTS)
	$(CXX) $(OBJECTS) -lm  -lrt $(CXXFLAGS) -Ofast -o $(EXECUTABLE)

clean :
	rm -f $(OBJECTS) $(EXECUTABLE) $(MAIN2_OBJECTS) $(MAIN2) $(TEST) $(TEST_OBJECTS)
