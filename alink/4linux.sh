#!/bin/bash
#
# Download, modify and build script to make the 'alink' linker compile under
# Linux. The web page for the linker is here: [url=http://alink.sourceforge.net/]http://alink.sourceforge.net/[/url]
# SJK 12/02/09

# Directory where the package will be built
APP_DIR=alink

# Check if we have a build directory and exit if the 'alink' binary file
# already exists. If not create the directory, download, modify and build
# the package.
if [ -d $APP_DIR ]; then
   if [ -f $APP_DIR/alink ]; then
      echo "'alink' binary exists. To rebuild remove it or the build directory."
      exit 0
   else
      rm -f $APP_DIR/*
   fi
else
   mkdir $APP_DIR
fi   

cd $APP_DIR

# Download and unzip the package files


# Rename all source and header files to use lower case


# Create a new Makefile for Linux (note escaped dollar characters)
echo "
%.o: %.c
	gcc -c -o \$@ $<

all: alink

alink.o combine.o util.o output.o objload.o coff.o cofflib.o : alink.h

alink: alink.o combine.o util.o output.o objload.o coff.o cofflib.o
	gcc -o \$@ $^
" > Makefile_linux

# Append this to the alink.h file
echo "
/* Added SJK 12/02/09 */
#ifdef __linux__
#define stricmp strcasecmp
char *strupr (char *a);
char *strdup (const char *string);
#endif
" >> alink.h

# Append this to the util.c file
echo "
/* Added SJK 12/02/09 */
#ifdef __linux__
char *strupr (char *a)
{
 char *ret = a;

while (*a != '\0')
    {
     if (islower(*a))
        *a = toupper(*a);
     ++a;
    }
 return ret;
}

char *strdup (const char *string)
{
 char *new;

if (NULL != (new = malloc(strlen(string) + 1)))
    strcpy(new, string);
 return new;
}
#endif
" >> util.c

# Compile the program
make -f Makefile_linux
