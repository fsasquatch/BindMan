// NOTE: c2ffi doesn't generate details for defines.
// NOTE: c2ffi doesn't generate details for places where function pointers is used.
// IDEA: Parse the header separately to get all instances of a defined function pointer and replace it there.
// NOTE: Things to handle:
//       structs, typedefs, enums, unions, functions, values [array, pointers, function pointers, double pointers]
package bindman;

import sys.io.Process;

import bindman.BindType;
import bindman.CTypes;

using StringTools;

class BindMan {
    public static var definedTypes:Array<String> = [];
    public static var enumRegister:Map<Int, String> = [];

    public static function parseType(field:FFIEntry, ?parent:FFIEntry):BindType {
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
            case "size_t":
                return UInt32;
            case "wchar_t":
                return WChar;
            case "float":
                return Float32;
            case "double":
                return Float64;
            case "long":
                return Float64; // TODO
            case "long-long":
                return Float64;
            case "unsigned-long":
                return Float64;
            case "unsigned-long-long":
                return Float64; // cause fuck you
            case "char":
                return Char;
            case "_Bool":
                return Boolean;
            case "struct":
                // ! This is temporary solution !
                if(parent != null && Utils.sanitizeTypeName(parent.type.tag) == "pointer") {
                    return Struct(field.type.name);
                }
                return Struct(fieldType);
            case "union":
                return Struct(fieldType);
            case "array":
                return Array(parseType(field.type), field.type.size);
            case "pointer":
                return Pointer(parseType(field.type, field));
            case "function-pointer":
                return FunctionPointer(field.name);
            case "va_list":
                return VarList;
            default:
                Sys.println('Unrecognized Type: ${field.name} -> ${fieldType}');
                return Invalid;
        }

        return null;
    }

    static function parseStruct(s:Array<CStruct>, entry:FFIEntry, ?name:String) {
        var f:Array<CField> = [];
        for(field in entry.fields) {
            var type = parseType(field);
            
            // ! This is a temporary solution !
            // handle inline union (problem: SDL_GamepadBinding)
            if(field.type.tag == "union") {
                var t = field.type;
                for(ft in t.fields) {
                    var typeField = parseType(ft);
                    switch(typeField) {
                        case Struct(n):
                            if(n != "struct") {
                                f.push({
                                    name: field.name+"_"+ft.name,
                                    type: typeField
                                });
                            } else {
                                for(a in ft.type.fields) {
                                    f.push({
                                        name: field.name+"_"+a.name,
                                        type: parseType(a)
                                    });
                                }
                            }
                        default:
                            f.push({
                                name: field.name+"_"+ft.name,
                                type: parseType(ft)
                            });
                    }
                }
            } else {
                f.push({
                    name: field.name,
                    type: parseType(field),
                    lineNumber: Std.parseInt(entry.location.split(":")[1])
                });
            }
        }

        var n = name;
        if(name == null) n = entry.name;
        s.push({
            name: n,
            fields: f,
            opaque: f.length == 0 ? true : false,
            lineNumber: Std.parseInt(entry.location.split(":")[1])
        });
        if(!definedTypes.contains(entry.name)) definedTypes.push(entry.name);
    }

    static function parseTypedef(t:Array<CField>, entry:FFIEntry) {
        if(definedTypes.contains(entry.name)) return;
        
        if(entry.type != null) {
            if(Utils.sanitizeTypeName(entry.type.tag) == "enum") {
                enumRegister.set(entry.type.id, entry.name);
                if(!definedTypes.contains(entry.name)) definedTypes.push(entry.name);
            } else if(Utils.sanitizeTypeName(entry.type.tag) == "function-pointer") {
                var type = parseType(entry);
                t.push({
                    name: entry.name,
                    type: type,
                    lineNumber: Std.parseInt(entry.location.split(":")[1])
                });
                if(!definedTypes.contains(entry.name)) definedTypes.push(entry.name);
            } else if(Utils.sanitizeTypeName(entry.type.tag) == "union") {
                // ! This is a temporary solution? !
                var type = parseType(entry);
                t.push({
                    name: entry.name,
                    type: Struct(entry.type.name)
                });
                if(!definedTypes.contains(entry.name)) definedTypes.push(entry.name);
            } else {
                var type = parseType(entry);
                t.push({
                    name: entry.name,
                    type: type,
                    lineNumber: Std.parseInt(entry.location.split(":")[1])
                });
                if(!definedTypes.contains(entry.name)) definedTypes.push(entry.name);
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

    static function parse(includeKeyword:String, ffiEntries:Array<FFIEntry>, ignore:Array<String>):CLib {
        var parsed = {
            structs: [],
            enums: [],
            typedefs: [],
            functions: []
        }

        for(entry in ffiEntries) {
            if(ignore != null) {
                for(i in ignore) {
                    var spl = i.split("~");
                    var n = spl[1];
                    var l = spl[0];
                    if(entry.name == n && entry.location == l) ffiEntries.remove(entry);
                }
            }
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

        // ! This is a temporary solution !
        // Problem: Box3D bindings create new struct when `struct name id;` is used as field
        // Solution: Remove the empty version of the struct generated by checking for structs of
        // the same name. I feel like this is how LLMs talk but idk I've never used it.
        for(s in parsed.structs) {
            for(i in parsed.structs) {
                if(i.name == s.name) {
                    if(i.opaque && !s.opaque)
                        parsed.structs.remove(i);
                    else if(s.opaque && !i.opaque)
                        parsed.structs.remove(s);
                }
            }
        }

        return parsed;
    }

    static function postprocess(lib:Config.Library, str:String):String {
        var s = str;

        if(lib.replace != null) {
            for(k => v in lib.replace) s = s.replace(k, v);
        }

        return s;
    }

    static function build(configFile:String) {
        var libPath = Utils.locateHaxelibPath();
        var config:Config = haxe.Json.parse(sys.io.File.getContent(configFile));
        var c2ffi = haxe.io.Path.join([libPath, "external", "c2ffi"]);
        if(!sys.FileSystem.exists(config.out)) sys.FileSystem.createDirectory(config.out);

        for(lib in config.libraries) {
            if(!sys.FileSystem.exists(haxe.io.Path.join([config.out, lib.library]))) sys.FileSystem.createDirectory(haxe.io.Path.join([config.out, lib.library]));

            // Generate with c2ffi
            var file = haxe.io.Path.join([config.out, lib.library, '${lib.library}_ffi.json']);
            var tmp_c = "";
            if(lib.headerDefines != null) {
                for(define in lib.headerDefines) {
                    tmp_c += "#define "+define+"\n";
                }
            }
            tmp_c += '#include "${lib.includeHeader}"';
            sys.io.File.saveContent("tmp.c", tmp_c);
            var process = new Process(c2ffi, ["tmp.c", "-I", lib.includeDirectory, "-o", file]);
            Sys.print('Running c2ffi  ');
            Sys.println(process.stderr.readAll().toString());
            process.close();
            sys.FileSystem.deleteFile("tmp.c");

            var fileContent = sys.io.File.getContent(file);
            fileContent = fileContent.replace("bit-size", "bit_size");
            fileContent = fileContent.replace("bit-alignment", "bit_alignment");
            fileContent = fileContent.replace("return-type", "return_type");

            var ffiEntries:Array<FFIEntry> = [];
            ffiEntries = haxe.Json.parse(fileContent);

            var parsed = parse(lib.includeKeyword, ffiEntries, lib.ignore);
            sys.io.File.saveContent(haxe.io.Path.join([config.out, lib.library, '${lib.library}_bindman.json']), haxe.Json.stringify(parsed, "    "));
        
            var hxcpp_out = bindman.generator.Hxcpp.generate(parsed, lib.includeHeader, lib.cppXML, config.out);
            hxcpp_out = postprocess(lib, hxcpp_out);
            sys.io.File.saveContent(haxe.io.Path.join([config.out, '${bindman.Utils.titlecase(lib.library)}.cpp.hx']), hxcpp_out);
        
            var hashlink_out = bindman.generator.HL.generate(parsed, lib.includeHeader, config.out, lib.library);
            hashlink_out = postprocess(lib, hashlink_out);
            sys.io.File.saveContent(haxe.io.Path.join([config.out, '${bindman.Utils.titlecase(lib.library)}.hl.hx']), hashlink_out);

            var ext_out = bindman.generator.HLExt.generate(lib.library, parsed, lib.includeHeader);
            sys.io.File.saveContent(haxe.io.Path.join([config.out, '${bindman.Utils.titlecase(lib.library)}_extension.c']), ext_out);
        }
    }
}