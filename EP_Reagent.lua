--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--   C O N F I G U R A T I O N    B E L O W
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local PlayerTable = {
		-- Change this to your characters name if you wish to add stuff to a specific character
		["ExamplePriest"] = {
			-- Change these item codes to your liking, examples are available further down
			{["item"] = 44615, ["amount"] = 40},   -- Devout Candle
			{["item"] = 33445, ["amount"] = 20},   -- Honeymint Tea
			{["item"] = 43236, ["amount"] = 0}     -- Star's Sorrow
		},

		-- same goes for this one too
		["ExampleRogue"] = {
			{["item"] = 43237, ["amount"] = 20},  -- Anesthetic Poison II
			{["item"] = 3775,  ["amount"] = 20},  -- Crippling Poison
			{["item"] = 43233, ["amount"] = 20},  -- Deadly Poison VIII
			{["item"] = 43231, ["amount"] = 20},  -- Instant Poison IX
			{["item"] = 5237,  ["amount"] = 20},  -- Mind-numbing Poison
			{["item"] = 43235, ["amount"] = 20}   -- Wound Poison VII
		}
		-- add more after for as many characters as you like, but remember the commas
	};

--  ~~~~~~~~~~~~~~~~~~~~
--   Example Item Codes
--  ~~~~~~~~~~~~~~~~~~~~
--[[ 

			------- Death Knight -------
			{["item"] = 37201, ["amount"] = 0}    -- Corpse Dust

			-------    Druid     -------
			{["item"] = 17034, ["amount"] = 0}    -- Maple Seed
			{["item"] = 17035, ["amount"] = 0}    -- Stranglethorn Seed
			{["item"] = 17036, ["amount"] = 0}    -- Ashwood Seed
			{["item"] = 17037, ["amount"] = 0}    -- Hornbeam Seed
			{["item"] = 17038, ["amount"] = 0}    -- Ironwood Seed
			{["item"] = 22147, ["amount"] = 0}    -- Flintwood Seed
			{["item"] = 44614, ["amount"] = 0}    -- Starleaf Seed
			{["item"] = 17026, ["amount"] = 0}    -- Wild Thornroot
			{["item"] = 22148, ["amount"] = 0}    -- Wild Quillvine
			{["item"] = 44605, ["amount"] = 0}    -- Wild Spineleaf

			-------    Rogue     -------
			{["item"] = 21835, ["amount"] = 0}    -- Anesthetic Poison
			{["item"] = 43237, ["amount"] = 0}    -- Anesthetic Poison II
			{["item"] = 3775,  ["amount"] = 0}    -- Crippling Poison
			{["item"] = 2892,  ["amount"] = 0}    -- Deadly Poison I
			{["item"] = 2893,  ["amount"] = 0}    -- Deadly Poison II
			{["item"] = 8984,  ["amount"] = 0}    -- Deadly Poison III
			{["item"] = 8985,  ["amount"] = 0}    -- Deadly Poison IV
			{["item"] = 20844, ["amount"] = 0}    -- Deadly Poison V
			{["item"] = 22053, ["amount"] = 0}    -- Deadly Poison VI
			{["item"] = 22054, ["amount"] = 0}    -- Deadly Poison VII
			{["item"] = 43232, ["amount"] = 0}    -- Deadly Poison VII
			{["item"] = 43233, ["amount"] = 0}    -- Deadly Poison VIII
			{["item"] = 6947,  ["amount"] = 0}    -- Instant Poison I
			{["item"] = 6949,  ["amount"] = 0}    -- Instant Poison II
			{["item"] = 6950,  ["amount"] = 0}    -- Instant Poison III
			{["item"] = 8926,  ["amount"] = 0}    -- Instant Poison IV
			{["item"] = 8927,  ["amount"] = 0}    -- Instant Poison V
			{["item"] = 8928,  ["amount"] = 0}    -- Instant Poison VI
			{["item"] = 21927, ["amount"] = 0}    -- Instant Poison VII
			{["item"] = 43230, ["amount"] = 0}    -- Instant Poison VIII
			{["item"] = 43231, ["amount"] = 0}    -- Instant Poison IX
			{["item"] = 5237,  ["amount"] = 0}    -- Mind-numbing Poison
			{["item"] = 10918, ["amount"] = 0}    -- Wound Poison I
			{["item"] = 10920, ["amount"] = 0}    -- Wound Poison II
			{["item"] = 10921, ["amount"] = 0}    -- Wound Poison III
			{["item"] = 10922, ["amount"] = 0}    -- Wound Poison IV
			{["item"] = 22055, ["amount"] = 0}    -- Wound Poison V
			{["item"] = 43234, ["amount"] = 0}    -- Wound Poison VI
			{["item"] = 43235, ["amount"] = 0}    -- Wound Poison VII

			-------    Shaman    -------
			{["item"] = 17030, ["amount"] = 0}    -- Ankh

			-------    Priest    -------
			{["item"] = 17028, ["amount"] = 0}    -- Holy Candle
			{["item"] = 17029, ["amount"] = 0}    -- Sacred Candle
			{["item"] = 44615, ["amount"] = 0}    -- Devout Candle

			-------    Hunter    -------
			none for you, slackers

			-------     Mage     -------
			{["item"] = 17020, ["amount"] = 0}    -- Arcane Powder
			{["item"] = 17032, ["amount"] = 0}    -- Rune of Portals
			{["item"] = 17031, ["amount"] = 0}    -- Rune of Teleportation

			-------   Warlock    -------
			{["item"] = 16583, ["amount"] = 0}    -- Demonic Figurine
			{["item"] = 5565,  ["amount"] = 0}    -- Infernal Stone

			-------   Warrior    -------
			none for you, slackers

			-------   Paladin    -------
			{["item"] = 17033, ["amount"] = 0}    -- Symbol of Divinity
			{["item"] = 21177, ["amount"] = 0}    -- Symbol of Kings

]]--
-- ~~~~~~~~~~~~~~~~~~~~~~~
-- DO NOT EDIT BELOW HERE
-- ~~~~~~~~~~~~~~~~~~~~~~~

local EPReagent = CreateFrame("Frame");
EPReagent:RegisterEvent("MERCHANT_SHOW");

function EPReagent:MessageOutput (inputMessage)
	ChatFrame1:AddMessage(string.format("|cffDAFF8A[Reagent]|r %s", inputMessage));
end;

-- convert raw money amount into gold, silver and copper amount and output to screen
function EPReagent:PrintMoney(money, itemLink)
	money = math.floor(money);
	local copper = money % 100;
	money = math.floor(money / 100);
	local silver = money % 100;
	money = math.floor(money / 100);
	local gold = money;

	self:MessageOutput(string.format("Purchasing %d|cffd3c63ag|r %d|cffb0b0b0s|r %d|cffb2734ac|r worth of %s", gold, silver, copper, itemLink));
end

function EPReagent:RestockFromVendor(reagentName, quantityNeeded)
	local counter = 1;
	local itemName, price, quantity, numAvailable, isUsable, extendedCost;

	local soldItems = GetMerchantNumItems();

	while counter <= soldItems do
		itemName, _, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(counter);

		if itemName == reagentName then break; end; -- found it, break out of the loop

		counter = counter + 1;
	end;

	-- vendor does not sell the item, quit out
	if itemName ~= reagentName then return; end;

	local itemLink = GetMerchantItemLink(counter);

	-- quit out for now, might add something about this later
	if not isUsable then
		--self:MessageOutput(string.format("Your character cannot use %s", itemLink));
		return;
	end;

	if extendedCost then

		-- purchase of items with other currency is not supported, quit out
		self:MessageOutput("Purchase using alternative currency is not currently supported");
		return;

---- DEBUG ----
--[[
		local itemValue, eCostItemLink, availableItemLink;
		local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(counter);
		local myHonorPoints = GetHonorCurrency();
		local myArenaPoints = GetArenaCurrency();

		self:MessageOutput(string.format("Extended item cost is %d honor points, %d arena points and %d other currencies", honorPoints, arenaPoints, itemCount));
		self:MessageOutput(string.format("User has %d honor points and %d arena points", myHonorPoints, myArenaPoints));

		if itemCount then
			for i = 1, itemCount do
				_, itemValue, eCostItemLink = GetMerchantItemCostItem(counter, i)
				availableItemLink = GetItemCount(eCostItemLink);
				self:MessageOutput(string.format("Other Currency %d is : %d of %s, user has %d available", i, itemValue, eCostItemLink, availableItemLink));
			end;
		end;
]]--
	end;

	-- re-evaluate the number needed depending upon how many are sold in a batch
	local revisedQuantity = math.floor(quantityNeeded / quantity);
	-- re-evaluate the number per stack depending upon how many are sold in a batch
	local stack = GetMerchantItemMaxStack(counter);
	local revisedStack = stack / quantity;

	if numAvailable ~= -1 then -- limited number available
		if numAvailable < revisedQuantity then -- fewer available than required
			revisedQuantity = numAvailable;
		end;
	end;

	-- we require less than 1 batch so quit
	if revisedQuantity < 1 then return; end;

	-- calculate total cost of resupply
	local totalCost = price * revisedQuantity;

	-- check how much money we have
	local gold = GetMoney();

	if totalCost > gold then
		-- we cannot afford the full cost, print message and quit out
		self:MessageOutput("Cannot afford to purchase required " .. itemLink .. "!");
		return;
	else
		-- we can afford to restock reagents
		self:PrintMoney(totalCost, itemLink);
	end;

	-- we need more than a stack
	while revisedQuantity >= revisedStack do
		BuyMerchantItem(counter, revisedStack);
		revisedQuantity = revisedQuantity - revisedStack;
	end;

	-- we need less than a stack
	if revisedStack > revisedQuantity then
		BuyMerchantItem(counter, revisedQuantity);
	end;
end;

function EPReagent:CheckSupplies(id, count)
	local name, currentAmount, requiredAmount;
	name, _, _, _, _, _, _, _, _, _ = GetItemInfo(id);

	-- may not have the item in cache yet, or might have gotten wrong ID
	if not name then return; end;

	-- Check how many we need to buy
	currentAmount = GetItemCount(id);
	requiredAmount = count - currentAmount;

	-- none needed so quit out
	if requiredAmount < 1 then return; end;

	self:RestockFromVendor(name, requiredAmount);
end;

function EPReagent:RestockMe()
	local playerName, _ = UnitName("player");

	-- hmmm, using strings for indexing a table...I'm nasty
	local test = PlayerTable[playerName];

	-- we have found data for your character
	if test then
		for i = 1, # test do
			self:CheckSupplies(test[i].item, test[i].amount);
		end;
	end;
end;

EPReagent:SetScript("OnEvent", function(self, event, addon)
	self:RestockMe();
end);
