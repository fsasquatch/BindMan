package bindman;

import haxe.DynamicAccess;

typedef Library = {
    library:String,
    includeKeyword:String,
    includeDirectory:String,
    includeHeader:String,
    replace:DynamicAccess<Dynamic>,
    ignore:Array<String>,
    cppXML:String,
    headerDefines:Array<String>,
};

typedef Config = {
    out:String,
    libraries:Array<Library>
};