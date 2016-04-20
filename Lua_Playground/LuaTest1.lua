I = 1

--RETURN TABLE
print('RETURN TABLE')
function print_box(box)
   --Utility function.
   print('('..table.concat(box,',')..')')
end
function shallow_copy(t)
   --Shallow table copy
   local rtrn = {} --`local` specifier is essential!
   for k,v in pairs(t) do
      rtrn[k] = v
   end
   return rtrn
end
function less_shallow_copy(t)
   --Depth-2 table copy
   local rtrn = {} --`local` specifier is essential!
   for k,v in pairs(t) do
      rtrn[k] = shallow_copy(v)
   end
   return rtrn
end
boxes = {{0,0,2,2},{1,1,3,3}}
sings = less_shallow_copy(boxes)
for i,box in ipairs(sings) do --should just print out elements of b
   print_box(box)
end
print()