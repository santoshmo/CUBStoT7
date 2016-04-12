
function explode(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end

test_or_train_g = io.open("train_test_split.txt")

bounding_boxes_g = io.open("bounding_boxes.txt")

images_g = io.open("images.txt")

part_locs_g = io.open("parts/part_locs.txt")

mturk_g = io.open('parts/part_click_locs.txt')

image_path = 't7/'


for j = 1,11780 do 
    bb_info = explode(" ", tostring(bounding_boxes_g:read()))
    bb_coords = {}
    for i = 2,5 do 
        table.insert(bb_coords, tonumber(bb_info[i])) -- convert from string to num
    end
    bb_coords = torch.Tensor(bb_coords) -- 1x4 tensor
    image_info = explode(" ", tostring(images_g:read()))
    class_id = tonumber(string.sub(image_info[2], 1,3)) -- which bird
    image_id = tonumber(image_info[1]) -- which image of bird
    test_or_train = tonumber(explode(" ", tostring(test_or_train_g:read()))[2]) -- suggested data set
    
    parts = {}
    for k = 1,15 do 
        part_loc_info = explode(" ", part_locs_g:read())
        entry = {}
        for l = 2, 5 do
            table.insert(entry, part_loc_info[l])
        end
        table.insert(parts, entry)
    end
    parts = torch.Tensor(parts)
    
    --  MTurk, user generated data...proceed with caution? 
    mturk_parts = {}
    for k = 1,75 do 
        mturk_part_loc_info = explode(" ", mturk_g:read())
        entry = {}
        for l = 2,6 do
            table.insert(entry, mturk_part_loc_info[l])
        end
        table.insert(mturk_parts, entry)
    end
    mturk_parts = torch.Tensor(mturk_parts)
    
    -- write data to object and save 
    info = {}
    info.image_id = image_id
    info.class_id = class_id
    info.test_or_train = test_or_train
    info.bb_coords = bb_coords
    info.parts = parts
    info.mturk_parts = mturk_parts
    filename = 'image' .. image_id .. '.t7'
    torch.save(image_path .. filename, info)
end


