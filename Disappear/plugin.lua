local function not_has(table, val)
    for _, value in pairs(table) do
        if value == val then
            return false
        end
    end

    return true
end

function draw()
    imgui.Begin("Disappear")

    state.IsWindowHovered = imgui.IsWindowHovered()

    --I'll implement some way to input numbers if/when I feel like it
    --Try not to have a 2^-6 * 2^28 ms long map (2^22 ms = 4194304 ms = 4194.304 sec = 1 hour 9 min 54.304 sec)
    local BIG_NUMBER = 2^28 --big number bad, but big number funny and make playfield go brrrrr, numbers higher than this may cause map-wide breaking of LN rendering
    local AVG_SV = 1 --What SV to normalize to
    local INCREMENT = 2^-6 --powers of 2 are your friend, small number also bad, but small number funny and make playfield go teleport, numbers smaller than this may cause rounding errors

    if imgui.Button("poof.") then
        local notes = state.SelectedHitObjects --should check to see if there are enough objects selected but I don't care

        --maybe jank way of removing redundant notes idk
        local starttimes = {}

        for _,note in pairs(notes) do
            if not_has(starttimes, note.StartTime) then
                table.insert(starttimes, note.StartTime)
            end
        end

        local svs = {}

        for _,starttime in pairs(starttimes) do
            table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, BIG_NUMBER * -1 + AVG_SV * 2))
            table.insert(svs, utils.CreateScrollVelocity(starttime, BIG_NUMBER))
            table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, AVG_SV))
        end

        table.remove(svs, 1) --effect starts with teleport at first note's StartTime

        actions.PlaceScrollVelocityBatch(svs)
    end

    if imgui.Button("frozen poof.") then --this is the more painful effect
        local notes = state.SelectedHitObjects --should check to see if there are enough objects selected

        --maybe jank way of removing extra notes of same StartTimes idk
        local starttimes = {}

        for _,note in pairs(notes) do
            if not_has(starttimes, note.StartTime) then
                table.insert(starttimes, note.StartTime)
            end
        end

        --need to find time from one note to another
        local distances = {}
        for i = 2, #starttimes do
            table.insert(distances, starttimes[i]-starttimes[i-1])
        end

        local firststarttime = table.remove(starttimes, 1)

        local svs = {}

        table.insert(svs, utils.CreateScrollVelocity(firststarttime, BIG_NUMBER))
        table.insert(svs, utils.CreateScrollVelocity(firststarttime + INCREMENT, 0))

        local bignumbers = {} --this is probably jank and definitely feels jank
        local bignumber = BIG_NUMBER
        for i = 1, #starttimes do
            bignumber = bignumber - (distances[i]) / INCREMENT * AVG_SV
            table.insert(bignumbers, bignumber)
        end

        for i,starttime in pairs(starttimes) do
            table.insert(svs, utils.CreateScrollVelocity(starttime - INCREMENT, bignumbers[i] * -1))
            table.insert(svs, utils.CreateScrollVelocity(starttime, bignumbers[i]))
            table.insert(svs, utils.CreateScrollVelocity(starttime + INCREMENT, 0))
        end

        actions.PlaceScrollVelocityBatch(svs)
    end

    imgui.End()
end
