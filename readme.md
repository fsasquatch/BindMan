# BindMan <sup>& PrettyWoman</sup>
> [!WARNING]
> *Very work in progress! Go away.*

A library to try and solve (or atleast reduce) the pain of creating bindings in Haxe deterministically. Utilizing [c2ffi](https://github.com/rpav/c2ffi) to process a header file, the library generates a `.json` file which is then used by the generators to create bindings. This library supports generating both `cpp` & `hashlink` bindings.

### Installation
You can install it through `haxelib`
```
haxelib git bindman https://github.com/fsasquatch/BindMan
```
The library only works on Linux at the moment without placing the `c2ffi` binary in the `external/` folder.
### Usage
All you have to do is create a config, add this to your `.hxml` file and run it! *You're required to have the header file of the library for BindMan to generate bindings from.*
```hxml
--macro bindman.BindMan.build("bindman.json") # bindman.json can be any other name :)
```
**Example config**
```json
{
    "out": "interop",
    "libraries": [
        {
            "library": "sdl",
            "includeKeyword": "SDL",
            "includeDirectory": "native/SDL",
            "includeHeader": "SDL.h"
        },
        {
            "library": "raylib",
            "includeKeyword": "raylib",
            "includeDirectory": "native/raylib",
            "includeHeader": "raylib.h",
            "replaceOnce": {
                "dynamic":  "dynamicBuffer"
            }
        }
    ]
}
```
