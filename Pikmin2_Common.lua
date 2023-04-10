-- Library with functions useful for Pikmin 2 scripts.
--
-- Written by APerson13.

local Pikmin2_Common = {}

IsDemo = false
MoviePlayerPtrPtr = 0x80516114
RNGPtr = 0x805147e0
NaviMgrPtr = 0x805158a0

NaviStateIDs = {
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

--Run this to get essential offsets and info about the current game version.
function Initialize()
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

--Function by LuigiM
function FloatHack(intVal)
    return string.unpack("f", string.pack("I4", intVal))
end

function Velocity(oldPos, pos) --This assumes 30FPS. Currently only used for Y velocity since actual captain vertical movement is calculated differently ingame.
    if oldPos and pos then
        return (pos - oldPos) * 30
    end
    return 0
end

--Gives various values in Navi objects
function NaviObjects(navimgr)
    if navimgr > 0x80000000 and 0x817ffff0 > navimgr then
        NaviOne = ReadValue32(navimgr + 0x28)
        NaviTwo = NaviOne + 0x320

        if NaviOne > 0x80000000 and 0x817ffff0 > NaviOne then
            OldOlimarPosY, OldLouiePosY = OlimarPosY, LouiePosY
            OlimarPosX, OlimarPosY, OlimarPosZ = FloatHack(ReadValue32(NaviOne + 0x20c)), FloatHack(ReadValue32(NaviOne + 0x210)), FloatHack(ReadValue32(NaviOne + 0x214))
            LouiePosX, LouiePosY, LouiePosZ = FloatHack(ReadValue32(NaviTwo + 0x20c)), FloatHack(ReadValue32(NaviTwo + 0x210)), FloatHack(ReadValue32(NaviTwo + 0x214))

            -- if OldOlimarPosY and OldLouiePosY then OlimarVelY, LouieVelY = Velocity(OldOlimarPosY, OlimarPosY), Velocity(OldLouiePosY, LouiePosY) end
            OlimarVelX, OlimarVelZ = FloatHack(ReadValue32(NaviOne+0x200)), FloatHack(ReadValue32(NaviOne+0x208))
            LouieVelX, LouieVelZ = FloatHack(ReadValue32(NaviTwo+0x200)), FloatHack(ReadValue32(NaviTwo+0x208))
            OlimarVelY, LouieVelY = FloatHack(ReadValue32(NaviOne+0x204)), FloatHack(ReadValue32(NaviTwo+0x204))

            OlimarCurrTri = ReadValue32(NaviOne + 0xc8)
            LouieCurrTri = ReadValue32(NaviTwo + 0xc8)

            OlimarStateObj = ReadValue32(NaviOne + 0x274)
            LouieStateObj = ReadValue32(NaviTwo + 0x274)

            if OlimarVelX and OlimarVelZ then OlimarVelXZ = math.sqrt((OlimarVelX^2) + (OlimarVelZ^2)) end
            if LouieVelX and LouieVelZ then LouieVelXZ = math.sqrt((LouieVelX^2) + (LouieVelZ^2)) end

            if OlimarCurrTri and OlimarCurrTri > 0x80000000 and 0x817ffff0 > OlimarCurrTri then OlimarColl = ReadValue8(OlimarCurrTri + 0x5c) >> 4 end
            if LouieCurrTri and LouieCurrTri > 0x80000000 and 0x817ffff0 > LouieCurrTri then LouieColl = ReadValue8(LouieCurrTri + 0x5c) >> 4 end

            if OlimarStateObj and OlimarStateObj > 0x80000000 and 0x817ffff0 > OlimarStateObj then
                TestValue = OlimarStateObj
                OlimarStateID = ReadValue32(OlimarStateObj + 4)
            end
            if LouieStateObj and LouieStateObj > 0x80000000 and 0x817ffff0 > LouieStateObj then LouieStateID = ReadValue32(LouieStateObj + 4) end
        end
    end
end

return Pikmin2_Common