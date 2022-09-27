if not MAGUS then MAGUS = {} end
if not MAGUS.Mjolnir then MAGUS.Mjolnir = {} end

MAGUS.Mjolnir.Setup = function()
	MAGUS.Mjolnir.tick = 0;
	MAGUS.Mjolnir.tickIncrement = .2;
	MAGUS.Mjolnir.amplitude = 0;
	MAGUS.Mjolnir.amplitudeIncrement = 0.0125;
	MAGUS.Mjolnir.amplitudeMax = 1;
	MAGUS.Mjolnir.tickMax = 16;
	MAGUS.Mjolnir.frame = 1;
	MAGUS.Mjolnir.offsetX = -3;
	MAGUS.Mjolnir.offsetY = -4;
	MAGUS.Mjolnir.running = false;
end

MAGUS.Mjolnir.DespawnLightning = function()
	local worldItem = MAGUS.Mjolnir.droppedLightning:getWorldItem();
	MAGUS.Mjolnir.spawnSquare:transmitRemoveItemFromSquare(worldItem);
	worldItem:removeFromSquare();
	worldItem:removeFromWorld();
	worldItem:setSquare(nil);
	MAGUS.Mjolnir.droppedLightning = nil;
end

MAGUS.Mjolnir.DoDropLightning = function()
	if not MAGUS.Mjolnir.running then return end;

	if not MAGUS.Mjolnir.droppedLightning then
		MAGUS.Mjolnir.vfxItem = ScriptManager.instance:getItem("MAGUS.LightningVFX");
		if MAGUS.Mjolnir.vfxItem then
			local vfxItemIconName = "LightningVFX"..tostring(MAGUS.Mjolnir.frame);
			MAGUS.Mjolnir.vfxItem:DoParam("Icon = "..vfxItemIconName);
		else
			print("Error: VFX item does not exist in the script.");
		end;
		MAGUS.Mjolnir.spawnSquare = getWorld():getCell():getGridSquare(MAGUS.Mjolnir.lightningTargetX, MAGUS.Mjolnir.lightningTargetY, MAGUS.Mjolnir.lightningTargetZ);
		MAGUS.Mjolnir.droppedLightning = MAGUS.Mjolnir.spawnSquare:AddWorldInventoryItem("MAGUS.LightningVFX", MAGUS.Mjolnir.offsetX, MAGUS.Mjolnir.offsetY, 0);

	elseif MAGUS.Mjolnir.frame <= 21 then
		if MAGUS.Mjolnir.frame == 7 then
			MAGUS.Mjolnir.spawnSquare:explode();
			for y = -3, 3, 1 do
				for x = -3, 3, 1 do
					local square = cell:getGridSquare(MAGUS.Mjolnir.lightningTargetX + x, MAGUS.Mjolnir.lightningTargetY + y, MAGUS.Mjolnir.lightningTargetZ);
					local movingObjects = square:getMovingObjects();
					for i=movingObjects:size()-1, 0, -1 do
						local movingObject = movingObjects:get(i);
						if instanceof(movingObject, "IsoZombie") then
							movingObject:setHealth(0);
						end;
					end;
				end;
			end;
		end;
	
		MAGUS.Mjolnir.spawnSquare:removeWorldObject(MAGUS.Mjolnir.droppedLightning:getWorldItem());
		local vfxItemIconName = "LightningVFX"..tostring(MAGUS.Mjolnir.frame);
		MAGUS.Mjolnir.vfxItem:DoParam("Icon = "..vfxItemIconName);
		MAGUS.Mjolnir.droppedLightning = MAGUS.Mjolnir.spawnSquare:AddWorldInventoryItem("MAGUS.LightningVFX", MAGUS.Mjolnir.offsetX, MAGUS.Mjolnir.offsetY, 0);

	else
		MAGUS.Mjolnir.DespawnLightning();
		MAGUS.Mjolnir.running = false;
	end

	MAGUS.Mjolnir.frame = MAGUS.Mjolnir.frame + 1;
end

MAGUS.Mjolnir.DoShakeScreen = function()
	if not MAGUS.Mjolnir.running then return end;
	
	if MAGUS.Mjolnir.amplitude >= MAGUS.Mjolnir.amplitudeMax or MAGUS.Mjolnir.tick >= MAGUS.Mjolnir.tickMax then
		MAGUS.Mjolnir.running = false;
		return;
	end;

	MAGUS.Mjolnir.oscVal = math.sin(MAGUS.Mjolnir.tick * math.pi) * (-(MAGUS.Mjolnir.amplitude - 1) ^ 3) * 2 / 5;
	MAGUS.Mjolnir.tick = MAGUS.Mjolnir.tick + MAGUS.Mjolnir.tickIncrement;
	MAGUS.Mjolnir.amplitude = MAGUS.Mjolnir.amplitude + MAGUS.Mjolnir.amplitudeIncrement;
	
	MAGUS.Mjolnir.player:setX(MAGUS.Mjolnir.x + MAGUS.Mjolnir.oscVal);
	MAGUS.Mjolnir.player:setY(MAGUS.Mjolnir.y + MAGUS.Mjolnir.oscVal);
end

MAGUS.Mjolnir.RequestDropLightning = function()
	MAGUS.Mjolnir.frame = 1;
	local mx, my = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), 0);
	MAGUS.Mjolnir.lightningTargetX = mx + 1.5;
	MAGUS.Mjolnir.lightningTargetY = my + 1.5;
	MAGUS.Mjolnir.lightningTargetZ = 0;
	local playerZ = MAGUS.Mjolnir.player:getZ()
	if playerZ > 0 then
		for i = playerZ, 1, -1 do
			MAGUS.Mjolnir.lightningTargetX = mx + 1.5 + i;
			MAGUS.Mjolnir.lightningTargetY = my + 1.5 + i;
			MAGUS.Mjolnir.lightningTargetZ = i;
			break;
		end;
	end;
end

MAGUS.Mjolnir.RequestShakeScreen = function()
	MAGUS.Mjolnir.tick = 0;
	MAGUS.Mjolnir.amplitude = 0;
end

MAGUS.Mjolnir.OnPlayerAttackFinished = function(player, weapon)
	if not player:isLocalPlayer() then return end;
	if not weapon:getFullType() == "MAGUS.Mjolnir" then return end;
	
	MAGUS.Mjolnir.player = player;
	
	MAGUS.Mjolnir.x = MAGUS.Mjolnir.player:getX();
	MAGUS.Mjolnir.y = MAGUS.Mjolnir.player:getY();
	
	if MAGUS.Mjolnir.running then
		MAGUS.Mjornir.DespawnLightning();
	end
	MAGUS.Mjolnir.RequestDropLightning();
	MAGUS.Mjolnir.RequestShakeScreen();
	
	MAGUS.Mjolnir.running = true;
end

Events.OnLoad.Add(MAGUS.Mjolnir.Setup);
Events.OnPlayerUpdate.Add(MAGUS.Mjolnir.DoShakeScreen);
Events.OnPlayerUpdate.Add(MAGUS.Mjolnir.DoDropLightning);
Events.OnPlayerAttackFinished.Add(MAGUS.Mjolnir.OnPlayerAttackFinished);