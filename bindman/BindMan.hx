// NOTE: Maybe? https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Existing_C_to_Wasm
// NOTE: c2ffi doesn't generate details for defines, so have them be added via UserProvidedData
// NOTE: c2ffi doesn't generate details for places where function pointers is used.
// IDEA: Parse the header separately to get all instances of a defined function pointer and replace it there.
// NOTE: Things to handle:
//       structs, typedefs, enums, unions, functions, values [array, pointers, function pointers, double pointers]
package bindman;

using StringTools;

typedef FFIEntry = {
    var ?tag:Null<String>;
    var ?id:Null<Int>;
    var ?name:Null<String>;
    var ?location:Null<String>;
    var ?type:Null<FFIEntry>;
    var ?fields:Null<Array<FFIEntry>>;
    var ?value:Null<Int>;
    var ?parameters:Null<Array<FFIEntry>>;
    var ?return_type:Null<FFIEntry>;
    var ?size:Null<Int>;
    var ?bit_offset:Null<Int>;
    var ?bit_size:Null<Int>;
    var ?width:Null<Int>;
}

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
    Callback(name:String);
    Const(type:BindType);
    WChar; // maaaaaaan
    VarList;
}

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

class BindMan {
    public static var structs:Array<CStruct> = [];
    public static var typedefs:Array<CField> = [];
    public static var enums:Array<CEnum> = [];
    public static var functions:Array<CFunction> = [];
    public static var callbacks:Map<String, CFunction> = [];

    // All the types defined within the library to avoid conflicts between structs & typedefs
    public static var definedTypes:Array<String> = [];
    public static var enumRegister:Map<Int, String> = [];

    public static var includeKeyword:String;
    public static var includeHeader:String;
    public static var includeDirectory:String;
    public static var generatedFile:String;

    public static var customReplace:(str:String)->String;

    // Stored for choosing between char & string
    static var _constTypes:Array<{lineNumber:Int, name:String, type:BindType}> = [];

    public static function parseType(field:FFIEntry):BindType {
        if(definedTypes.contains(field.type.tag)) return Struct(field.type.tag);
        var fieldType = Utils.sanitizeTypeName(field.type.tag);

        switch(fieldType) {
            case "void":
                return Void;
            case "int":
                return Int32;
            case "unsigned-char":
                return UInt8;
            case "unsigned-short":
                return UInt16;
            case "unsigned-int":
                return UInt32;
            case "float":
                return Float32;
            case "double":
                return Float64;
            case "long":
                return Float64; // TODO
            case "char":
                return Char;
            case "_Bool":
                return Boolean;
            case "struct":
                return Struct(fieldType);
            case "array":
                return Array(parseType(field.type), field.type.size);
            case "pointer":
                return Pointer(parseType(field.type));
            case "function-pointer":
                return Callback(fieldType);
            case "size_t":
                return UInt32; // cause fuck you
            case "wchar_t":
                return String;
            case "int8_t":
                return Int8;
            case "int16_t":
                return Int16;
            case "int32_t":
                return Int32;
            case "int64_t":
                return Int64;
            case "uint8_t":
                return UInt8;
            case "uint16_t":
                return UInt16;
            case "uint32_t":
                return UInt32;
            case "uint64_t":
                return UInt64;
            case "intptr_t":
                return Pointer(Int32);
            case "long-long":
                return Float64;
            case "unsigned-long":
                return UInt64;
            case "unsigned-long-long":
                return UInt64; // cause fuck you again
            case "va_list":
                return VarList;
            case "union":
                return Struct(fieldType);
            default:
                Sys.println('Unrecognized Type: ${field.name} : ${fieldType}');
                return Invalid;
        }

        return null;
    }

    static function parseStruct(s:Array<CStruct>, entry:FFIEntry) {
        var f:Array<CField> = [];
        for(field in entry.fields) {
            f.push({
                name: field.name,
                type: parseType(field),
                lineNumber: Std.parseInt(entry.location.split(":")[1])
            });
        }

        s.push({
            name: entry.name,
            fields: f,
            opaque: f.length == 0 ? true : false
        });
        definedTypes.push(entry.name);
    }

    static function parseTypedef(t:Array<CField>, entry:FFIEntry) {
        if(definedTypes.contains(entry.name)) return;
        
        if(entry.type != null) {
            if(Utils.sanitizeTypeName(entry.type.tag) == "enum") {
                enumRegister.set(entry.type.id, entry.name);
                definedTypes.push(entry.name);
            } else {
                var type = parseType(entry);
                t.push({
                    name: entry.name,
                    type: type,
                    lineNumber: Std.parseInt(entry.location.split(":")[1])
                });
                definedTypes.push(entry.name);
            }
            return;
        }

    }

    static function parseEnum(e:Array<CEnum>, entry:FFIEntry) {
        var fields:Array<CField> = [];
        for(field in entry.fields) {
            fields.push({
                name: field.name,
                type: Int32,
                value: field.value
            });
        }

        var name = entry.name;
        if(entry.name == "") name = enumRegister.get(entry.id); 
        e.push({
            name: name,
            fields: fields
        });
    }

    static function parseFunction(f:Array<CFunction>, entry:FFIEntry) {
        var returnType = Invalid;
        var field = entry;
        field.type = entry.return_type;
        returnType = parseType(field);

        var params:Array<CField> = [];
        for(p in entry.parameters) {
            params.push({
                name: p.name,
                type: parseType(p),
                lineNumber: Std.parseInt(entry.location.split(":")[1]) 
            });
        }

        f.push({
            name: entry.name,
            returnType: returnType,
            parameters: params
        });
    }

    static function parse(includeKeyword:String, ffiEntries:Array<FFIEntry>):{structs:Array<CStruct>, enums:Array<CEnum>, typedefs:Array<CField>, functions: Array<CFunction>} {
        var parsed = {
            structs: [],
            enums: [],
            typedefs: [],
            functions: []
        }
        
        // NOTE: These are separated in two because of enums missing `name` because of ordering (typedefs first).
        for(entry in ffiEntries) {
            if(!entry.location.contains(includeKeyword)) continue;

            switch(entry.tag) {
                case "struct":
                    parseStruct(parsed.structs, entry);
                case "union":
                    parseStruct(parsed.structs, entry);
                case "typedef":
                    parseTypedef(parsed.typedefs, entry);
            }
        }

        for(entry in ffiEntries) {
            if(!entry.location.contains(includeKeyword)) continue;

            switch(entry.tag) {
                case "enum":
                    parseEnum(parsed.enums, entry);
                case "function":
                    parseFunction(parsed.functions, entry);
            }
        }
        
        for(s in parsed.structs) {
            for(field in s.fields) {
                for(const in _constTypes) {
                    if(field.lineNumber == const.lineNumber) {
                        if(field.name == const.name) field.type = Const(field.type);
                    }
                }
            }
        }

        for(f in parsed.functions) {
            for(const in _constTypes) {
                if(f.name == const.name) f.returnType = Const(f.returnType);
            }

            for(field in f.parameters) {
                for(const in _constTypes) {
                    if(field.lineNumber == const.lineNumber) {
                        if(field.name == const.name) field.type = Const(field.type);
                    }
                }
            }
        }

        return parsed;
    }

    static function main() {
        includeKeyword = UserProvidedData.includeKeyword;
        includeHeader = UserProvidedData.includeHeader;
        includeDirectory = UserProvidedData.includeDirectory;
        generatedFile = UserProvidedData.generatedFile;
        customReplace = UserProvidedData.customReplace;

        var out = haxe.io.Path.join(["interop", Utils.titlecase(includeHeader.replace(".h", ".hx"))]);

        var fileContent = sys.io.File.getContent(generatedFile);
        fileContent = fileContent.replace("bit-size", "bit_size");
        fileContent = fileContent.replace("bit-alignment", "bit_alignment");
        fileContent = fileContent.replace("return-type", "return_type");

        var ffiEntries:Array<FFIEntry> = [];
        ffiEntries = haxe.Json.parse(fileContent);

        var parsed = parse(includeKeyword, ffiEntries); // first get all the type details
        enums = parsed.enums;
        typedefs = parsed.typedefs;

        // var header_content = sys.io.File.getContent(haxe.io.Path.join([includeDirectory, includeHeader]));
        // parseExtraDetails(includeKeyword, ffiEntries, header_content, file);

        parsed = parse(includeKeyword, ffiEntries); // then generate again with extra details
        structs = parsed.structs;
        functions = parsed.functions;

        var bout = UserProvidedData.bindmanOut;
        sys.io.File.saveContent(bout, haxe.Json.stringify({structs: structs, typedefs:typedefs, enums:enums, functions:functions, const:_constTypes}, "    "));

        var hashlinkOut = GeneratorHL.generateBindings();
        var extOut = GeneratorHL.generateExt();
        var hxcppOut = GeneratorHxcpp.generateBindings();
        
        var i = includeHeader.split("/");
        var f = i[i.length-1];
        sys.io.File.saveContent("interop/"+Utils.titlecase(f.replace(".h", ".cpp.hx")), hxcppOut);
        sys.io.File.saveContent("interop/"+Utils.titlecase(f.replace(".h", ".hl.hx")), hashlinkOut);
        sys.io.File.saveContent("interop/extension_"+Utils.titlecase(f.replace(".h", ".c")), extOut);
    }
}

class GeneratorHL {
    public static function generateBindings():String {
        return "";
    }

    public static function generateExt():String {
        return "";
    }
}

class GeneratorHxcpp {
    public static function getType(type:BindType):String {
        switch(type) {
            case Invalid:
                return 'Invalid';
            case Void:
                return 'cpp.Void';
            case Int8:
                return 'cpp.Int8';
            case Int16:
                return 'cpp.Int16';
            case Int32:
                return 'cpp.Int32';
            case Int64:
                return 'cpp.Int64';
            case UInt8:
                return 'cpp.UInt8';
            case UInt16:
                return 'cpp.UInt16';
            case UInt32:
                return 'cpp.UInt32';
            case UInt64:
                return "cpp.UInt64";
            case Float32:
                return 'cpp.Float32';
            case Float64:
                return 'cpp.Float64';
            case Char:
                return 'cpp.Char';
            case String:
                return 'cpp.CharStar';
            case Boolean:
                return 'Bool';
            case Struct(name):
                return Utils.titlecase(name);
            case Array(type, size):
                if(type == Char) return 'cpp.CastCharStar';
                return 'cpp.${getType(type)}Pointer';
            case Pointer(value):
                switch(value) {
                    case Struct(v):
                        return Utils.titlecase(v);
                    case Pointer(v):
                        if(v == Char) return 'cpp.CastCharStarPointer';
                        return 'cpp.RawPointer<$v>';
                    case Char:
                        return 'cpp.CharStar';
                    default:
                        return getType(value)+'Pointer';
                }
            case Callback(name):
                return null;
            case Const(value): // TODO: Fix this (!!!)
                return 'Const'+getType(value).replace("cpp.", "");
            case WChar:
                return "String";
            case VarList:
                return "cpp.VarList";
        }
        return null;
    }

    public static function generateBindings():String {
        var code = "// This file was auto-generated by BindMan.\npackage interop;\n\n";

        for(s in BindMan.structs) {
            code += '@:semantics(value)\n';
            code += '@:include("${BindMan.includeHeader}")\n';
            code += '@:cpp.ValueType({type: "${s.name}"})\n';
            code += 'extern class ${Utils.titlecase(s.name)} {\n';
            if(!s.opaque) {
                for(field in s.fields) code += '    var ${field.name}:${getType(field.type)};\n';
                code += '\n    function new():Void;\n';
            }
            code += '}\n\n';
        }

        for(e in BindMan.enums) {
            code += '@:semantics(value)\n';
            code += '@:include("${BindMan.includeHeader}")\n';
            code += '@:cpp.ValueType({type: "${e.name}"})\n';
            code += 'extern enum abstract ${Utils.titlecase(e.name)}(${getType(e.fields[0].type)}) {\n';
            for(field in e.fields) code += '    @:native("${field.name}") var ${field.name};\n';
            code += '}\n\n';
        }

        for(t in BindMan.typedefs) {
            code += 'typedef ${t.name} = ${getType(t.type)};\n\n';
        }

        code += "@:keep\n";
        code += "@:buildXml(TODO)\n";
        code += '@:include("${BindMan.includeHeader}")\n';
        code += 'extern class ${Utils.titlecase(BindMan.includeHeader.split(".")[0])} {\n';
        for(f in BindMan.functions) {
            var params = '';
            for(p in f.parameters) params += '${p.name}:${getType(p.type)},';
            params = params.substr(0, -1).ltrim().rtrim();
            code += '    @:native("${f.name}") static function ${f.name}($params):${getType(f.returnType)};\n';
        }
        code += "}";

        return code;
    }
}

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
}