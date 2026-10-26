package bindman;

import haxe.macro.Context;
import haxe.io.Path;
import sys.FileSystem;
using StringTools;

class Utils {
    public static function titlecase(str:String):String {
        var n = str.split("");
        n[0] = n[0].toUpperCase();
        var name = n.toString();
        name = name.replace("[", "").replace("]", "").replace(",", "").ltrim().rtrim();
        return name;
    }

    public static function sanitizeTypeName(name:String):String {
        return name.replace(":", "").ltrim().rtrim();
    }

    public static function locateHaxelibPath():String {
        for(path in Context.getClassPath()) {
            // var parent = Path.directory(Path.removeTrailingSlashes(path));
            var file = Path.join([path, "showbiz.txt"]);
            if(FileSystem.exists(file)) {
                return path;
            }
        }
        return null;
    }
}