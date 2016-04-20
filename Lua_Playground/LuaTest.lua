--INDEXING
print('INDEXING')
I = 1 --[[Lua is 1-indexed; we write code as if it is 0-indexed,
      --   adopting idiom table[index+I] for array accesses. 
      --    We avoid embracing the direct 1-indexing because
      --     0-indexing is familiar and hence less liable to mistakes,
      --      and also for the clarity of thought it affords, as
      --       explained in Dijkstra's note EWD831. To distinguish
      --        a `meaningful` 1 from an index-correcting 1, we use
      --         `I` for the indices. This allows generalization to 
      --          arbitrary indices, e.g. if Lua ever becomes 2-indexed.
      --]]
a = {0,2,4,6,8,10}
for i=0,#a-I do
   print(i,a[i+I])
end
print()

--FUNCTIONS
print('FUNCTIONS')
a = {0,1,2,3,4}
function print_length_squared(aa)
    print((#aa)*(#aa))
end
print_length_squared(a) --should get 25
print()

--COPY AND RETURN TABLE
print('COPY AND RETURN TABLE')
function print_box(box)
   --Utility function.
   print('('..table.concat(box,',')..')')
end
function copy_table(t)
   --Shallow table copy
   local rtrn = {}
   for i,c in pairs(t) do      
      rtrn[i] = c
   end
   return rtrn
end
function singletons(boxes)
   --[[Returns a list of length-1 lists, each containing
   --   a shallow copy of a corresponding element of the given list.
   --    Thus, {a,b,c} --> {{a},{b},{c}}
   --]]
   local rtrn = {}
   for i,b in pairs(boxes) do
      rtrn[i] = {copy_table(b)}
   end
   return rtrn
end
boxes = {{0,0,2,2},{1,1,3,3}}
sings = copy_table(singletons(copy_table(boxes)))
for i,wrapped_box in pairs(sings) do --should just print out elements of b
   print_box(wrapped_box[0+I])
end
print()

--TABLE ITERATION
print('TABLE ITERATION')
a = {{0,1},{1,1},{2,2},{3,3},{4,5}}
for i,y in ipairs(a) do
    print(i,y[0+1],y[1+1]) --Lua's tables are 1-indexed
end
print()

--NUMERIC `FOR`
print('NUMERIC `FOR`')
for i=0,5-1 do --like python `for i in range(0,5): ...`
    print(i)
end 
print()

--GENERIC `FOR`
print('GENERIC `FOR`')
a = {0,2,4,6,8,10}
for i,v in ipairs(a) do
   print(i,v)
end
print()

--CONTINUE
print('CONTINUE')
for i=0,5-1 do --like python `for i in range(0,5): ...`
    if i==2 then goto continue end
    print(i)
    ::continue::
end
print()

--BOX FUSION
print('BOX FUSION')
inf = math.huge
function fuse_boxes(boxes, operators, init)
   --[[Returns a fusion of the given list of boxes
   --   Here, a box we represent as (min_x,min_y,max_x,max_y).
   --    The fusion is determined by a given pair of binary
   --     operators; specifically, the min coordinates are all
   --      fused according to the initial operator, the max
   --       coordinates according to the final operator. Thus,
   --        for instance, if operators={max, min}, then the
   --         fusion will be equivalent to intersection.
   --]]
   rtrn = init
   for i,box in ipairs(boxes) do
      for axis=0,2-I do
         for j,m in ipairs(operators) do
            index = 2*(j-I)+axis+I
            rtrn[index] = m(rtrn[index], box[index])
         end
      end
   end
   return rtrn
end
function intersect_boxes(boxes)
   --Returns the largest common containee.
   return fuse_boxes(boxes, {math.max,math.min}, {-inf,-inf, inf,inf})
end
function join_boxes(boxes)
   --Returns the smallest common container.
   return fuse_boxes(boxes, {math.min,math.max}, {inf,inf, -inf,-inf})
end

function boxes_are_equivalent(box0, box1)
   for i=0,4-1 do
      if box0[i+I] ~= box1[i+I] then return false end
   end
   return true
end

function print_box(box)
   print('('..table.concat(box,',')..')')
end

function test_fusion()
   no_squares = {}
   assert(boxes_are_equivalent({-inf,-inf, inf,inf},intersect_boxes(no_squares)))
   assert(boxes_are_equivalent({inf,inf, -inf,-inf},join_boxes(no_squares)))
   two_squares = {{0,0,2,2},{1,1,3,3}}
   assert(boxes_are_equivalent({1,1,2,2},intersect_boxes(two_squares)))
   assert(boxes_are_equivalent({0,0,3,3},join_boxes(two_squares)))
   assert(not (boxes_are_equivalent({0,0,3,3},intersect_boxes(two_squares))))
   assert(not (boxes_are_equivalent({1,1,2,2},join_boxes(two_squares))))
   equal_squares = {{-1,-1,1,1},{-1,-1,1,1},{-1,-1,1,1}}
   assert(boxes_are_equivalent({-1,-1,1,1},intersect_boxes(equal_squares)))
   assert(boxes_are_equivalent({-1,-1,1,1},join_boxes(equal_squares)))
   assert(not (boxes_are_equivalent({-inf,-inf, inf,inf},intersect_boxes(equal_squares))))
   assert(not (boxes_are_equivalent({inf,inf, -inf,-inf},join_boxes(equal_squares))))
   print('TESTS PASSED: fuse_boxes, intersect_boxes, join_boxes, boxes_are_equivalent')
end
test_fusion()
print()