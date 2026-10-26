package bindman;

typedef CField = {
    var name:String;
    var type:BindType;
    var ?value:Int;
    var ?lineNumber:Int;
}

typedef CStruct = {
    var name:String;
    var fields:Array<CField>;
    var ?opaque:Bool;
    var ?lineNumber:Int;
}

typedef CEnum = {
    var name:String;
    var fields:Array<CField>;
}

typedef CFunction = {
    var name:String;
    var returnType:BindType;
    var parameters:Array<CField>;
}

typedef CLib = {
    structs:Array<CStruct>, 
    enums:Array<CEnum>, 
    typedefs:Array<CField>, 
    functions: Array<CFunction>
}