-- Library with functions useful for Pikmin 2 scripts.
--
-- Written by APerson13, adapted by Julian-Beides.

-- To have proper namespacing, only this object is made accessible to the outside.
local pik2 = {}

local IsDemo = false
local MoviePlayerPtrPtr = 0x80516114
local RNGPtr = 0x805147e0
local NaviMgrPtr = 0x805158a0

local NaviStateIDs = {
    [0]="walk",
    [1]="follow",
    [2]="punch", --not sure
    [3]="change",
    [4]="gather",
    [5]="throw",
    [6]="throw wait", --not sure
    [7]="dope",
    [8]="pluck",
    [9]="pluck adjust",
    [10]="container",
    [11]="absorb",
    [12]="flick",
    [13]="damaged",
    [14]="pressed",
    [15]="fall meck",
    [16]="koke damage",
    [17]="snitchbug",
    [18]="snitchbug exit",
    [19]="dead",
    [20]="stuck",
    [21]="demo ufo",
    [22]="demo hole",
    [23]="pellet",
    [24]="carry bomb",
    [25]="climb",
    [26]="path move"
}
pik2.NaviStateIDs = NaviStateIDs

-- Call this in `onScriptStart()` to get essential offsets and info about the current game version.
local function initialize()
    GameID = GetGameID()
	if (GameID ~= "GPVE01") and (GameID ~= "PIKE51") and (GameID ~= "GPVJ01") then
		SetScreenText("")
		CancelScript()
    --This just tests a random instruction offset in US Demo 1 that doesn't have any nearby similar instructions in US Final.
    elseif (GameID == "GPVE01" or GameID == "PIKE51") and ReadValue32(0x80471828) == 0x9421fb70 then
        IsDemo = true
    elseif GameID == "GPVE01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0xc0
        RNGPtr = RNGPtr + 0xc8
        NaviMgrPtr = NaviMgrPtr + 0xc0
    elseif GameID == "GPVJ01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0x1bc0
        RNGPtr = RNGPtr + 0x1bc8
        NaviMgrPtr = NaviMgrPtr + 0x1bc0
    end
end
pik2.initialize = initialize

--Function by LuigiM
local function floatHack(intVal)
    return string.unpack("f", string.pack("I4", intVal))
end
pik2.floatHack = floatHack

-- Make sure no bad pointers are read
local function isGoodPtr(ptr)
	return ptr ~= nil and ptr > 0x80000000 and 0x817ffff0 > ptr
end
pik2.isGoodPtr = isGoodPtr

--Gives various values in Navi objects
local function naviObjects()
    -- TODO return an object here instead of setting global variables.
	
	-- Return early when the pointers are bad.
	if not isGoodPtr(NaviMgrPtr) then
		return nil
	end
	
	navimgr = ReadValue32(NaviMgrPtr)
	if not isGoodPtr(navimgr) then
		return nil
	end
	
	NaviOne = ReadValue32(navimgr + 0x28)
	NaviTwo = NaviOne + 0x320
	if not isGoodPtr(NaviOne) or not isGoodPtr(NaviTwo) then
		return nil
	end

	OlimarPosX, OlimarPosY, OlimarPosZ = floatHack(ReadValue32(NaviOne + 0x20c)), floatHack(ReadValue32(NaviOne + 0x210)), floatHack(ReadValue32(NaviOne + 0x214))
	LouiePosX, LouiePosY, LouiePosZ = floatHack(ReadValue32(NaviTwo + 0x20c)), floatHack(ReadValue32(NaviTwo + 0x210)), floatHack(ReadValue32(NaviTwo + 0x214))

	OlimarVelX, OlimarVelZ = floatHack(ReadValue32(NaviOne+0x200)), floatHack(ReadValue32(NaviOne+0x208))
	LouieVelX, LouieVelZ = floatHack(ReadValue32(NaviTwo+0x200)), floatHack(ReadValue32(NaviTwo+0x208))
	OlimarVelY, LouieVelY = floatHack(ReadValue32(NaviOne+0x204)), floatHack(ReadValue32(NaviTwo+0x204))

	OlimarCurrTri = ReadValue32(NaviOne + 0xc8)
	LouieCurrTri = ReadValue32(NaviTwo + 0xc8)

	OlimarStateObj = ReadValue32(NaviOne + 0x274)
	LouieStateObj = ReadValue32(NaviTwo + 0x274)

	if OlimarVelX and OlimarVelZ then OlimarVelXZ = math.sqrt((OlimarVelX^2) + (OlimarVelZ^2)) end
	if LouieVelX and LouieVelZ then LouieVelXZ = math.sqrt((LouieVelX^2) + (LouieVelZ^2)) end

	if isGoodPtr(OlimarCurrTri) then OlimarColl = ReadValue8(OlimarCurrTri + 0x5c) >> 4 end
	if isGoodPtr(LouieCurrTri) then LouieColl = ReadValue8(LouieCurrTri + 0x5c) >> 4 end

	if isGoodPtr(OlimarStateObj) then OlimarStateID = ReadValue32(OlimarStateObj + 4) end
	if isGoodPtr(LouieStateObj) then LouieStateID = ReadValue32(LouieStateObj + 4) end
end
pik2.naviObjects = naviObjects

-- Get the DemoState, which is non-zero during button lockout and cutscenes.
local function demoState()
	if isGoodPtr(MoviePlayerPtrPtr) then 
		local MoviePlayerPtr = ReadValue32(MoviePlayerPtrPtr)
		if isGoodPtr(MoviePlayerPtr) then 
			return ReadValue32(MoviePlayerPtr + 0x18) 
		end
	end
	return nil
end
pik2.demoState = demoState

local function isDemoVersion()
	return IsDemo
end
pik2.isDemoVersion = isDemoVersion

-- Read the global state of Pikmin2's RNG function.
local function readRngSeed()
	if isGoodPtr(RNGPtr) then 
		return ReadValue32(RNGPtr) 
	end
	return nil
end
pik2.readRngSeed = readRngSeed

return pik2
