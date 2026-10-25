# !/bin/sh
cat > tmp.c <<- EOM
#include "raylib.h"
EOM

./c2ffi tmp.c -I native/raylib/ -o bindman/assets/raylib.json
rm tmp.c

cat > tmp.c <<- EOM
#include "SDL.h"
EOM

./c2ffi tmp.c -I native/SDL/ -o bindman/assets/sdl.json
rm tmp.c