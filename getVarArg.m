%%! Helper Function for retrieving var args
%%!
%%! @Param name      the name of the property
%%! @param default   the default value for the property to take
%%! @param prop      the property list in the form of [NAME1,VAL1,...]
%%!
%%! @return arg      the property value, or the default if unspecified
function arg = getVarArg(name, default, prop)
    arg=default;
    found = find(strcmpi(prop,name)==1);
    if ~isempty(found)
      arg = lower(prop{found+1});
    end
end
