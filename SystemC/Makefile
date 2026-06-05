# SystemC build Makefile for the direct-mapped cache model

CXX ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra
SYSTEMC_HOME ?= /usr/local/systemc
SYSTEMC_INCLUDE ?= $(SYSTEMC_HOME)/include
SYSTEMC_LIB_DIR ?= $(SYSTEMC_HOME)/lib
SYSTEMC_LIBS ?= -lsystemc

TARGET = dcache_systemc
SRCS = SystemCMain.cpp DcacheSystemC.cpp TrafficGenerator.cpp
OBJS = $(SRCS:.cpp=.o)

INCLUDES = -I$(SYSTEMC_INCLUDE)
LDFLAGS = -L$(SYSTEMC_LIB_DIR) $(SYSTEMC_LIBS)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)
