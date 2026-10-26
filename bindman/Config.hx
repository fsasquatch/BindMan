package bindman;

import haxe.DynamicAccess;

typedef Library = {
    library:String,
    includeKeyword:String,
    includeDirectory:String,
    includeHeader:String,
    replaceOnce:DynamicAccess<Dynamic>,
    ignore:Array<String>
};

typedef Config = {
    out:String,
    libraries:Array<Library>
};