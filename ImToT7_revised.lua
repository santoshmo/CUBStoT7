function split(delimiter, str)
    -- Splits string into a table of words.
    -- Expects a one-character delimiter.
    words = {}
    for w in string.gmatch(str, '[^'..delimiter..']+') do
        table.insert(words, w)
    end
    return words
end

DEFAULT = -1 --DEFAULT tensor coefficient for missing data.
NUM_IMAGES = 11788

test_or_train_g = io.open('train_test_split.txt')
bounding_boxes_g = io.open('bounding_boxes.txt')
images_g = io.open('images.txt')
part_locs_g = io.open('parts/part_locs.txt')
mturk_g = io.open('parts/part_click_locs.txt')
image_path = 't7/'

for j = 1,NUM_IMAGES do
    bb_info = split(' ', bounding_boxes_g:read())
    bb_coords = {}
    for i = 2,5 do
        table.insert(bb_coords, tonumber(bb_info[i])) -- convert from string to num
    end
    bb_coords = torch.Tensor(bb_coords) -- 1x4 tensor (x,y, width,height)
    image_info = split(' ', images_g:read()) -- (imageid, name of image)
    class_id = tonumber(string.sub(image_info[2], 1,3)) -- species id (200 possible)
    image_id = tonumber(image_info[1]) -- image id (11780 possible)
    test_or_train = tonumber(split(' ', test_or_train_g:read())[2]) -- suggested data set

    parts = {}
    for k = 1,15 do
        part_loc_info = split(' ', part_locs_g:read()) -- (image id, part id, x, y, visible); if invisible, x=y=0.
                                                       -- part id's range from 1 through 15.
        entry = {}
        for l = 3, 5 do
            table.insert(entry, part_loc_info[l])
        end
        table.insert(parts, entry)
    end
    parts = torch.Tensor(parts)

    --  MTurk, user generated data...proceed with caution?
    mturk_parts = {}; for c = 1,75 do table.insert(mturk_parts, {DEFAULT,DEFAULT,DEFAULT,DEFAULT}) end
    counts = {}; for c = 1,15 do table.insert(counts, 0) end --counts number of each part seen so far
    prevpid = 0
    for k = 1,75 do
        ss = mturk_g:read(); if ss==nil then break end
        if counts[1]==0 then print(ss) end
        mturk_part_loc_info = split(' ', ss) -- (image id, part id, x, y, visible, time); if invisible, x=y=0.
                                             -- part id's range from 1 through 15.
                                             -- time: how many seconds for MTurkers to label part.
        pid = tonumber(mturk_part_loc_info[2]); if not (prevpid<=pid) then break end
        entry = {}; for l = 3,6 do table.insert(entry, mturk_part_loc_info[l]) end
        mturk_parts[(pid-1)*5+1 + counts[pid]] = entry
        counts[pid] = counts[pid] + 1
        prevpid = pid
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
