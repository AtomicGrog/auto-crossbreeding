local gps = require("gps")
local action = require("action")
local database = require("database")
local scanner = require("scanner")
local posUtil = require("posUtil")
local config = require("config")
local tasks = require("tasks")


local args = {...}
local nonstop = false
local docleanup = true
local cleanCount = 0

if #args == 1 then
    if args[1] == "nocleanup" then
        docleanup = false
    elseif args[1] == "nonstop" then
        nonstop = true
    end
end

local function init()
    database.scanFarm()
    if config.keepNewCropWhileMinMaxing then
        database.scanStorage()
    end
    tasks.updateLowest()
    action.restockAll()
end

local function main()
    gps.turnTo(1)
    init()
    while not tasks.breedOnce(nonstop) do
        gps.go({0,0})
        action.restockAll()
        gps.go({0,0})
        cleanCount = cleanCount + 1
        if cleanCount > config.inventoryCleanupCycleFreq then
           if config.takeCareOfDrops then
              action.dumpInventory()
           end
           gps.go({0,0})
        end
    end
    gps.go({0,0})
    if docleanup then
        action.destroyAll()
        gps.go({0,0})
    end
    if config.takeCareOfDrops then
        action.dumpInventory()
    end
    gps.turnTo(1)
    print("Done.\nAll crops are now 21/31/0")
end

main()
