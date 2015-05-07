%Promotes an unsigned data type to the signed 
%datatype which can hold all values that the unsigned can
function data = make_signed(in)
  switch(class(in))
    case 'uint8'
      data = int16(in);
    case 'uint16'
      data = int32(in);
    case 'uint32'
      data = int64(in);
    case 'uint64'
      data = double(in);
    otherwise
      data= in;
   end
end