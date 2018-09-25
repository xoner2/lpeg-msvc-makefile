LUA_LIB_DIR      = ../lib
LUA_INCLUDE_DIR  = ../lua-5.1/include
LUA_LIB          = lua51.lib

SRC_DIR          = .

# Output directories
BUILD_PREFIX = ..\lib\build\lpeg
BUILD_LIBDIR = $(BUILD_PREFIX)\Release\lib
BUILD_BINDIR = $(BUILD_PREFIX)\Release\bin
BUILD_OBJDIR = $(BUILD_PREFIX)\Release\obj

# Install directory
LUA_CLIB_DIR = ..\lib\lua-clibs

CFLAGS = \
    -I$(LUA_INCLUDE_DIR)\
    -c\
    -W4\
    -MP\
    -Gm-\
    -errorReport:prompt\
    -nologo\
    -EHsc\
    -O2\
    -MD\
    -DLUA_BUILD_AS_DLL\
    -DWIN32\
    -D_WINDOWS\
    -D_CRT_SECURE_NO_DEPRECATE=1\
    -I$(LUA_INCLUDE_DIR)

LFLAGS = \
    $(LUA_LIB)\
    kernel32.lib\
    -SAFESEH\
    -SUBSYSTEM:CONSOLE\
    -nologo\
    -INCREMENTAL:NO

LIBFLAGS = \
    -LIBPATH:$(BUILD_LIBDIR)\
    -LIBPATH:$(BUILD_OBJDIR)\
    -LIBPATH:$(LUA_LIB_DIR)

all: $(BUILD_PREFIX) $(BUILD_LIBDIR) $(BUILD_BINDIR) $(BUILD_OBJDIR) lpeg

# individual targets
lpeg: $(BUILD_BINDIR)/lpeg.dll

# Make output directories
$(BUILD_PREFIX):
	-if not exist "$@" mkdir "$@"
$(BUILD_LIBDIR):
	-if not exist "$@" mkdir "$@"
$(BUILD_BINDIR):
	-if not exist "$@" mkdir "$@"
$(BUILD_OBJDIR):
	-if not exist "$@" mkdir "$@"
# Make install directories
$(LUA_CLIB_DIR):
	-if not exist "$@" mkdir "$@"

# lpeg: batch mode inference rule
{$(SRC_DIR)}.c{$(BUILD_OBJDIR)}.obj::
	@echo. & echo lpeg: compiling objects
	$(CC) $(CFLAGS) -Fo$(BUILD_OBJDIR)/ -TC $<

# lpeg
lpeg_OBJECTS = \
    $(BUILD_OBJDIR)\lpvm.obj\
    $(BUILD_OBJDIR)\lpcap.obj\
    $(BUILD_OBJDIR)\lptree.obj\
    $(BUILD_OBJDIR)\lpcode.obj\
    $(BUILD_OBJDIR)\lpprint.obj
$(BUILD_BINDIR)/lpeg.dll: $(lpeg_OBJECTS)
	@echo. & echo lpeg: linking
	link $(LFLAGS) $(LIBFLAGS) -DLL\
    -def:lpeg.def\
    $** -OUT:$@ -IMPLIB:$(BUILD_LIBDIR)/lpeg.lib

check-lpeg:
	lua -e"package.cpath=[[$(BUILD_BINDIR)]]..'/?.dll;'..package.cpath" test.lua


check: check-lpeg

clean: clean-lpeg

clean-lpeg:
	-del $(BUILD_BINDIR)\lpeg.dll
	-del $(BUILD_BINDIR)\lpeg.dll.manifest
	-del $(BUILD_BINDIR)\lpeg.ilk
	-del $(BUILD_BINDIR)\lpeg.pdb
	-del $(BUILD_LIBDIR)\lpeg.lib
	-del $(BUILD_LIBDIR)\lpeg.exp
	-del $(lpeg_OBJECTS)

install: $(LUA_CLIB_DIR) $(BUILD_BINDIR)/lpeg.dll
	xcopy /Y/D $(BUILD_BINDIR)\lpeg.dll "$(LUA_CLIB_DIR)"
