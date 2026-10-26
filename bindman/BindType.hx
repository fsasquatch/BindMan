package bindman;

enum BindType {
    Invalid;
    Void;
    Int8;
    Int16;
    Int32;
    Int64;
    UInt8;
    UInt16;
    UInt32;
    UInt64;
    Float32;
    Float64;
    Char;
    String;
    Boolean;
    Struct(name:String);
    Array(type:BindType, size:Int);
    Pointer(type:BindType);
    FunctionPointer(name:String);
    WChar;
    VarList;
}