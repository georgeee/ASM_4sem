CXX := gcc-4.6
CXXFLAGS := -m32 -g
SOURCES = main.c

ASM_SOURCES = print.asm
GENERATOR_SOURCES = generator.c
GENERATOR_ASM_SOURCES = generator.asm

ASM = yasm -f elf -g dwarf2
EXECUTABLE = main
GENERATOR = generator

OBJECTS = $(SOURCES:.c=.o) $(ASM_SOURCES:.asm=.ao)
GENERATOR_OBJECTS = $(GENERATOR_SOURCES:.c=.o) $(GENERATOR_ASM_SOURCES:.asm=.ao)

%.o : %.c
	$(CXX) -c $< -o $@ $(CXXFLAGS)

%.ao : %.asm
	$(ASM) -o $@ $<

all : $(EXECUTABLE)

$(GENERATOR) : $(GENERATOR_OBJECTS)
	$(CXX) $(GENERATOR_OBJECTS) -m32 -g -o $(GENERATOR)

hex_printer :
	ghc Main.hs -o hex_printer

precalc.txt : $(GENERATOR) hex_printer
	./precalc_compiler.sh

$(EXECUTABLE) : $(OBJECTS)
	$(CXX) $(OBJECTS) -m32 -g -o $(EXECUTABLE)


clean :
	rm -f $(OBJECTS) $(EXECUTABLE) $(GENERATOR_OBJECTS) $(GENERATOR) Main.hi Main.o hex_printer precalc.txt
