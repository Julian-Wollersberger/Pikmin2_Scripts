-- Text overlay for Pikmin 2 TASing.
-- Add an underscore (_)to the beginning of the filename if you want the script to auto launch once you start a game.
--
-- Initially written by APerson13, adapted by Julian-Beides.

package.path = GetScriptsDir() .. "Pikmin2_Rng.lua"
rng = require("Pikmin2_Rng")
package.path = GetScriptsDir() .. "Pikmin2_Common.lua"
pik2 = require("Pikmin2_Common")

--Starting RNG index of Julian's TAS
local startRngIndex = 139521789

function onScriptStart()
    pik2.Initialize()
end

function onScriptCancel()
	SetScreenText("")
end

function onScriptUpdate()
    if OldFrame ~= GetFrameCount() then

        OldRNG = RNG
        if pik2.isGoodPtr(pik2.RNGPtr) then RNG = ReadValue32(pik2.RNGPtr) end
        if RNG and OldRNG then FrameRNGCalls = rng.rngIndexDiff(OldRNG, RNG) end
        if FrameRNGCalls then if FrameRNGCalls < 0 and FrameRNGCalls > -1000000 then BaseRNG = RNG end end
        if BaseRNG then StateRNGCalls = rng.rngIndexDiff(BaseRNG, RNG) end

		local RngIndex = rng.rnginverse(RNG) - startRngIndex;

        if pik2.isGoodPtr(pik2.NaviMgrPtr) then
            NaviMgr = ReadValue32(pik2.NaviMgrPtr)
            -- TODO return an object here instead of setting global variables.
			pik2.NaviObjects(NaviMgr)
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

		local demoState = pik2.demoState()
        if demoState then text = text .. string.format("\n\n===Cutscenes===\nButton lockout: %d", demoState) end

        text = text .. "\n\n===Positions and Velocities==="
        if OlimarPosX and OlimarVelX then text = text .. string.format("\nOlimar:\nX pos: %5f | X speed: %5f", OlimarPosX, OlimarVelX) end
        if OlimarPosY and OlimarVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", OlimarPosY, OlimarVelY) end
        if OlimarPosZ and OlimarVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", OlimarPosZ, OlimarVelZ) end
        if OlimarVelXZ then text = text .. string.format("\nXZ speed: %5f", OlimarVelXZ) end
        if OlimarColl then text = text .. string.format("\nCollision version: %d", OlimarColl) end
        if OlimarStateID and pik2.NaviStateIDs[OlimarStateID] then text = text .. "\nState: " .. pik2.NaviStateIDs[OlimarStateID] end
        if LouiePosX and LouieVelX then text = text .. string.format("\nLouie:\nX pos: %5f | X speed: %5f", LouiePosX, LouieVelX) end
        if LouiePosY and LouieVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", LouiePosY, LouieVelY) end
        if LouiePosZ and LouieVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", LouiePosZ, LouieVelZ) end
        if LouieVelXZ then text = text .. string.format("\nXZ speed: %5f", LouieVelXZ) end
        if LouieColl then text = text .. string.format("\nCollision version: %d", LouieColl) end
        if LouieStateID and pik2.NaviStateIDs[LouieStateID] then text = text .. "\nState: " .. pik2.NaviStateIDs[LouieStateID] end

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
