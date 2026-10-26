package bindman;

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