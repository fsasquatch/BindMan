package bindman;

#if SDL
// Configuration details (required)
var includeKeyword = "SDL";
var includeHeader = "SDL.h";
var includeDirectory = "native/SDL";
var generatedFile = "bindman/assets/sdl.json";
var bindmanOut = "bindman/assets/sdl_bindman.json";

// Overrides & Special cases
function customReplace(input:String):String {
    var output = input;
    return input;
}
#else
// Configuration details (required)
var includeKeyword = "raylib";  // allows BindMan to ignore other junk
var includeHeader = "raylib.h"; // header to bind
var includeDirectory = "native/raylib";
var generatedFile = "bindman/assets/raylib.json";
var bindmanOut = "bindman/assets/raylib_bindman.json";

// Overrides & Special cases
function customReplace(input:String):String {
    var output = input;
    return input;
}
#end