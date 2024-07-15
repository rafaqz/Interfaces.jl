# We may want to add matching @implements declarations for 
# - SubstitutionString

@implements StringInterface{:length} String ["abc"]
@implements StringInterface{:length} SubString [view("abc", 2:3)]
@implements StringInterface{:length} SubstitutionString [SubstitutionString("abc \\1")]
if VERSION > v"1.8.0"
    @implements StringInterface{:length} LazyString [LazyString("abc", "def")]
end
