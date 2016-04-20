--[[
1AM Convert basic script to Lua

2AM Finish even Voronoi in Lua

3AM Try Scott's GAN on anything

4AM Inspect his bird-part generation code

5AM Take Stock: 4 more hours!

6AM

7AM

8AM

9AM Leave for Scott Meeting, with Gwyn $

--]]

--BOX FUSION
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
function copy_box(box)
   --Shallow table copy
   local rtrn = {}
   for i,c in ipairs(box) do
      table.insert(rtrn,c)
   end
   return rtrn
end

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
   local rtrn = init --copy_box(init)   
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
   --Returns true or false according to shallow comparison of initial 4 elements.
   for i=0,4-1 do
      if box0[i+I] ~= box1[i+I] then return false end
   end
   return true
end

function print_box(box)
   --Utility function.
   print('('..table.concat(box,',')..')')
end

function test_fusion()
   --Tests `fuse_boxes`, `intersect_boxes`, `join_boxes`, `boxes_are_equivalent`.
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

function is_origin(point)
   --Returns true if and only if initial two elements are 0.0
   for i=0,2-1 do
      if point[i+I] ~= 0.0 then return false end
   end
   return true
end

function distance(point0, point1)
   --Returns Euclidean distance between given points.
   sum = 0.0
   for i=0,2-1 do
      sum = sum + (point1[i+I]-point0[i+I])^2 --In Lua, x^y denotes a power operation
   end
   return math.sqrt(sum)
end
function test_distance() 
   assert(math.sqrt(2)==distance({0,0},{1,1}))
end

function makesquare(center, radius)
   x,y = center[0+I],center[1+I]
   return {x-radius,y-radius,x+radius,y+radius}
end

function personal_space(p, keypoints)
   --[[Returns distance from `p` to the closest point within `keypoints`
   --   that is neither `p` nor the origin. If no such point exists, returns
   --    infinity. Used in `personal_squares`.
   --]]
   min_distance = inf
   for i,q in ipairs(keypoints) do
      if q==p or is_origin(q) then goto continue end
      min_distance = math.min(min_distance, distance(p,q))
      ::continue::
   end
   return min_distance
end

function personal_squares(bounding_box, keypoints)
   --[[For each non-origin keypoint, finds disk centered at that keypoint
   --   maximal with respect to the property of containing no other keypoint,
   --    and computes the axis-oriented circumscribing square. For keypoints
   --     equal to the origin, the corresponding square is a point at the origin.
   --      Returns a table of all the computed squares.
   --]]
   local rtrn = {}; rtrn[#keypoints-1 + I] = nil --set rtrn's size
    for i,kp in ipairs(keypoints) do
      if is_origin(kp) then
         table.insert(rtrn, {0,0,0,0})
      else
         radius = personal_space(kp, keypoints)
         table.insert(rtrn, intersect_boxes({bounding_box, makesquare(kp, radius)}))
      end
   end
   return rtrn
end

function voronoi(bounding_box, keypoints)
   
end
def common_container(points):
    return join(*[p+p for p in points])
def voronoi(bounding_box, keypoints, N=30):
    ''' Works by estimating Voronoi diagram (currently with an inefficient and approximate hack). '''
    x,y,X,Y = bounding_box
    coordinates = [((float(xx)/N)*(X-x)+x, (float(yy)/N)*(Y-y)+y) for xx in range(N+1) for yy in range(N+1)]
    domains = {p:[p] for p in keypoints}
    for q in coordinates:
        pp = min((distance(p,q),p) for p in keypoints if q is not p and sum(p))[1]
        domains[pp].append(q)
    return [intersect(bounding_box, common_container(domains[p])) if sum(p) else (0,0,0,0) for p in keypoints]

bounding_box = {0,0,10,10}
keypoints = {{0,0},{1,1},{2,2},{4,4}} --recall that the origin will be ignored
for i,box in ipairs(personal_squares(bounding_box, keypoints)) do
   print_box(box)
end