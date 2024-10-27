require "spec"

lib C
  struct PilStruct
    byte1, byte2, character1, character2 : UInt8
    int : Int32
    long : Int64
    string : UInt8*
    array : UInt8[8]
  end
end

fun extract(c_struct : UInt64) : Int32
  arr = UInt8.static_array(80, 105, 99, 111, 76, 105, 115, 112)
  str_ptr = "pilcrystal\x00".to_slice.to_unsafe

  newstruct = C::PilStruct.new(
    byte1: 42,
    byte2: 43,
    character1: 65,
    character2: 66,
    int: 65535,
    long: 9223372036854775807,
    string: str_ptr,
    array: arr
  )

  mystruct = Pointer(C::PilStruct).new(c_struct)

  # Tests
  mystruct.value.byte1.should eq(32)
  mystruct.value.byte2.should eq(33)
  mystruct.value.character1.should eq(67)
  mystruct.value.character2.should eq(68)
  mystruct.value.int.should eq(-1)
  mystruct.value.long.should eq(1)
  mystruct.value.array.should eq(UInt8.static_array(1, 2, 3, 4, 5, 6, 7, 8))

  # Write struct
  mystruct.value.byte1 = newstruct.byte1
  mystruct.value.byte2 = newstruct.byte2
  mystruct.value.character1 = newstruct.character1
  mystruct.value.character2 = newstruct.character2
  mystruct.value.int = newstruct.int
  mystruct.value.long = newstruct.long
  mystruct.value.string = newstruct.string
  mystruct.value.array = newstruct.array

  return 0
end
