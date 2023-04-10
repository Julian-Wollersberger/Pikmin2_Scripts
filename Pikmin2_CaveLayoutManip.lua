-- My current plan for the script:
-- * Do random movement with a "movement RNG seed" 
-- * When the hole cutscene ends, read the game RNG seed, increment it by the right amount, and call cavegen with it.
-- * The filename includes both the game RNG seed and movement RNG seed
-- * Load a savestate and repeat.
--
-- After that has run for a while, I manually look at the generated layouts. 
-- (I don't think this is automateable. Even cavegen judge is not good enouth.) 
-- It still cuts out the tedious part of watching the sublevel transition so many times.
--
-- When I found a good layout, I copy the movement RNG seed from the file name into the script, 
-- to recreate the exact same random movement and thus same game RNG seed.
--
-- TODO: Use caveripper. But that's fiddly at the moment.

---- Imports ----
package.path = GetScriptsDir() .. "Pikmin2_Common.lua"
pik2 = require("Pikmin2_Common")
package.path = GetScriptsDir() .. "Pikmin2_Rng.lua"
rng = require("Pikmin2_Rng")

---- Config ----
-- Absolute path to the cavegen folder, with a trailing slash.
cavegen_path = "D:/Dokumente/Pikmin 2 TAS 2/CaveGen/"
--Starting RNG index of Julian's TAS
local startRngIndex = 139521789


function onScriptStart()
	pik2.initialize()
	
	--local msg = generate_image("SH-6", 64)
	--msg = msg .. get_working_dir()
	--SetScreenText(msg)
	
	-- For one-off scripts.
	--CancelScript()
end

function onScriptCancel()
	--SetScreenText("")
end

function generate_image(sublevel, seed)
	local seed_text = string.format("0x%x", seed)
	-- First set working dir, then execute cavegen.
	local command = "cd /d \"" .. cavegen_path .. "\" & java -jar \"" .. cavegen_path .. "CaveGen.jar\" cave " .. sublevel .. " -seed " .. seed_text .. " & pause"
	
	-- Problem: cd doesn't work. And cavegen needs its local paths.
	
	-- These don't work:
	--local command = "dir & cd \"" .. cavegen_path .. "\" & dir & pause"
	--local command = "dir & cd D:\\Dokumente\\ & dir & pause"
	--local command = "dir & cd D:/ & dir & pause"
	--local command = "dir & cd \"D:/\" & dir & pause"
	
	-- These work:
	--local command = "echo Hello & pause"
	--local command = "dir & cd .. & dir & pause"
	--local command = "dir & cd Sys & dir & pause"
	--local command = "dir & cd Sys/Scripts & dir & pause"
	--local command = "dir & cd /d D: & dir & pause"
	--local command = "dir & cd /d \"" .. cavegen_path .. "\" & dir & pause"
	
	-- Solution: Use `cd /d` to make it accept an absolute path. AHHHHHHHHHHHHHHHHHHHHHHHHHRG
	
	
	local success, result, num = os.execute(command)
	
	local msg = "Cavegen:\n"
	msg = msg .. "command: " .. command .. "\n"
	msg = msg .. "success: " .. tostring(success) .. ", result: " .. tostring(result) .. ", num: " .. tostring(num) .. "\n"
	--msg = msg .. "success: " .. string.format("%s", success)
	return msg .. "\n"
end

function get_working_dir()
	-- In powershell, `pwd` prints the working directory and some annoying decoration.
	--local handle = io.popen("pwd")
	-- ...but Lua seems to use CMD instead. And of course the two are not compatible.
	local handle = io.popen("cd")
	
	local msg = "Working Directory:\n"
	for line in handle:lines() do
		msg = msg .. line .. "\n"
	end
	
	return msg .. "\n"
end


function onScriptUpdate()
	local rngSeed = pik2.readRngSeed()
	local rngIndex = rng.rnginverse(rngSeed) - startRngIndex
	
	-- Make a simple text overlay for debugging.
	local msg = "\n--- Cave Layout Manip ---\n"
	msg = msg .. string.format("Current RNG seed:  0x%x\n", rngSeed)
	msg = msg .. string.format("Current RNG index: %d\n", rngIndex)
	msg = msg .. "\n"
	msg = msg .. string.format("Cutscene/Lockout state: %d\n", pik2.demoState())
	
	SetScreenText(msg)
end

function onStateLoaded()
end

function onStateSaved()
end

