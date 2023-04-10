---@diagnostic disable: lowercase-global
---@diagnostic disable: undefined-global

--Starting RNG index of Julian's TAS
startRngIndex = 139521789

package.path = GetScriptsDir() .. "pikminTwoRNG.lua"
pTwoRng = require("pikminTwoRNG")
package.path = GetScriptsDir() .. "Pikmin2_Common.lua"
pTwoCmn = require("Pikmin2_Common")

--Uses Malleo's RNG index functions
function RngCalls(oldSeed, newSeed)
    if newSeed and oldSeed then
        return rnginverse(newSeed) - rnginverse(oldSeed)
    end
    return nil
end

--Add an underscore (_) to the beginning of the filename if you want the script to auto launch once you start a game!

function onScriptStart()
    -- CancelScript()
    Initialize()
end

function onScriptCancel()
	SetScreenText("")
end

function onScriptUpdate()
    if OldFrame ~= GetFrameCount() then
        if MoviePlayerPtrPtr and MoviePlayerPtrPtr > 0x80000000 and 0x817ffff0 > MoviePlayerPtrPtr then --Make sure no bad pointers are read
            MoviePlayerPtr = ReadValue32(MoviePlayerPtrPtr)
            if MoviePlayerPtr > 0x80000000 and 0x817ffff0 > MoviePlayerPtr then DemoState = ReadValue32(MoviePlayerPtr + 0x18) end
        end

        OldRNG = RNG
        if RNGPtr and RNGPtr > 0x80000000 and 0x817ffff0 > RNGPtr then RNG = ReadValue32(RNGPtr) end
        if RNG and OldRNG then FrameRNGCalls = RngCalls(OldRNG, RNG) end
        if FrameRNGCalls then if FrameRNGCalls < 0 and FrameRNGCalls > -1000000 then BaseRNG = RNG end end
        if BaseRNG then StateRNGCalls = RngCalls(BaseRNG, RNG) end

		local RngIndex = rnginverse(RNG) - startRngIndex;

        if NaviMgrPtr > 0x80000000 and 0x817ffff0 > NaviMgrPtr then
            NaviMgr = ReadValue32(NaviMgrPtr)
            NaviObjects(NaviMgr)
        end

        local text = ""
        --if IsDemo then
        --    text = text .. "\nVersion: US Demo 1\n"
        --elseif GameID == "GPVE01" then
        --    text = text .. "\nVersion: US Final\n"
        --elseif GameID == "GPVJ01" then
        --    text = text .. "\nVersion: JPN\n"
        --end

	    text = text .. string.format("\n===RNG===\nSeed on this frame: %x", RNG)
        if OldRNG then text = text .. string.format("\nLast frame seed: %x", OldRNG) end
        if FrameRNGCalls then text = text .. string.format("\nCalls since last frame: %d", FrameRNGCalls) end
        if BaseRNG then text = text .. string.format("\nCalls since state loaded: %d", StateRNGCalls) end
		if RngIndex then text = text .. string.format("\nRNG index: %d", RngIndex) end

        if DemoState then text = text .. string.format("\n\n===Cutscenes===\nButton lockout: %d", DemoState) end

        text = text .. "\n\n===Positions and Velocities==="
        if OlimarPosX and OlimarVelX then text = text .. string.format("\nOlimar:\nX pos: %5f | X speed: %5f", OlimarPosX, OlimarVelX) end
        if OlimarPosY and OlimarVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", OlimarPosY, OlimarVelY) end
        if OlimarPosZ and OlimarVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", OlimarPosZ, OlimarVelZ) end
        if OlimarVelXZ then text = text .. string.format("\nXZ speed: %5f", OlimarVelXZ) end
        if OlimarColl then text = text .. string.format("\nCollision version: %d", OlimarColl) end
        if OlimarStateID and NaviStateIDs[OlimarStateID] then text = text .. "\nState: " .. NaviStateIDs[OlimarStateID] end
        if LouiePosX and LouieVelX then text = text .. string.format("\nLouie:\nX pos: %5f | X speed: %5f", LouiePosX, LouieVelX) end
        if LouiePosY and LouieVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", LouiePosY, LouieVelY) end
        if LouiePosZ and LouieVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", LouiePosZ, LouieVelZ) end
        if LouieVelXZ then text = text .. string.format("\nXZ speed: %5f", LouieVelXZ) end
        if LouieColl then text = text .. string.format("\nCollision version: %d", LouieColl) end
        if LouieStateID and NaviStateIDs[LouieStateID] then text = text .. "\nState: " .. NaviStateIDs[LouieStateID] end

        ----TESTS----
        --if TestValue then text = text .. string.format("\n\nOlimar triangle pointer: %x", TestValue) end

	    SetScreenText(text)
    end
    OldFrame = GetFrameCount()
end

function onStateLoaded()

end

function onStateSaved()

end
