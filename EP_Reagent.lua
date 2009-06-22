local EPReagent = CreateFrame("Frame")
EPReagent:RegisterEvent("MERCHANT_SHOW")
EPReagent:RegisterEvent("PLAYER_LOGIN")

local playerTable = {}

function EPReagent:MessageOutput(inputMessage)
	ChatFrame1:AddMessage(string.format("|cffDAFF8A[Reagent]|r %s", inputMessage))
end

function EPReagent:CheckHonour(honourPoints)
	if(GetHonorCurrency() >= honourPoints) then
		-- You have enough honour
		return true
	else
		-- You do not have the honour
		return false
	end
end

function EPReagent:CheckArena(arenaPoints)
	if(GetArenaCurrency() >= arenaPoints) then
		-- You have enough arena points
		return true
	else
		-- You do not have the arena points
		return false
	end
end

function EPReagent:CheckItemCostItem(itemLink, amount)
	local availableItemLink = GetItemCount(itemLink)

	if(availableItemLink >= amount) then
		-- You have enough of this item
		return true
	else
		-- You do not have enough of this item
		return false
	end
end

function EPReagent:RestockFromVendor(reagentName, stack, quantityNeeded)
	local counter = 1
	local itemName, price, quantity, numAvailable, isUsable, extendedCost

	local soldItems = GetMerchantNumItems()

	while counter <= soldItems do
		itemName, _, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(counter)

		if itemName == reagentName then break end -- found it, break out of the loop

		counter = counter + 1
	end

	-- vendor does not sell the item, quit out
	if itemName ~= reagentName then return end

	-- quit out for now, might add something about this later
	if not isUsable then return end

	-- re-evaluate the number needed depending upon how many are sold in a batch
	local revisedQuantity = math.floor(quantityNeeded / quantity)
	-- re-evaluate the number per stack depending upon how many are sold in a batch
	local revisedStack = math.floor(stack / quantity)

	if numAvailable ~= -1 then -- limited number available
		if numAvailable < revisedQuantity then -- fewer available than required
			revisedQuantity = numAvailable
		end
	end

	-- we require less than 1 batch so quit
	if revisedQuantity < 1 then return end

	if extendedCost then

		local itemValue, eCostItemLink
		local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(counter)

		if(honorPoints > 0) then
			if(self:CheckHonour(honorPoints * revisedQuantity) == true) then
				self:MessageOutput("you have enough honour points")
			else
				self:MessageOutput("you DO NOT have enough honour points")
			end
		else
			self:MessageOutput("no honour points required")
		end

		if(arenaPoints > 0) then
			if(self:CheckArena(arenaPoints * revisedQuantity) == true) then
				self:MessageOutput("you have enough arena points")
			else
				self:MessageOutput("you DO NOT have enough arena points")
			end
		else
			self:MessageOutput("no arena points required")
		end

		if itemCount and itemCount > 0 then
			for i = 1, itemCount do
				_, itemValue, eCostItemLink = GetMerchantItemCostItem(counter, i)

				if(self:CheckItemCostItem(eCostItemLink, itemValue * revisedQuantity) == true) then
					self:MessageOutput(string.format("you have enough %s", eCostItemLink))
				else
					self:MessageOutput(string.format("you DO NOT have enough %s", eCostItemLink))
				end
			end
		end

		-- purchase of items with other currency is not supported, quit out
		self:MessageOutput("Purchase using alternative currency is not currently supported")
		return
	end

	-- calculate total cost of resupply
	local totalCost = price * revisedQuantity

	-- check how much money we have
	local gold = GetMoney()

	local itemLink = GetMerchantItemLink(counter)

	if totalCost > gold then
		-- we cannot afford the full cost, print message and quit out
		self:MessageOutput(string.format("Cannot afford to purchase required %s!", itemLink))
		return
	else
		-- format the output string depending upon user selected Colour Blind Mode
		local moneyString
		if (GetCVar("colorblindMode") == "0") then
			moneyString = GetCoinTextureString(totalCost)
		else
			moneyString = GetCoinText(totalCost)
		end

		-- we can afford to restock reagents
		self:MessageOutput(string.format("Purchasing %s worth of %s", moneyString, itemLink))
	end

	-- we need more than a stack
	while revisedQuantity >= revisedStack do
		BuyMerchantItem(counter, revisedStack)
		revisedQuantity = revisedQuantity - revisedStack
	end

	-- we need less than a stack
	if revisedStack > revisedQuantity and revisedQuantity > 0 then
		BuyMerchantItem(counter, revisedQuantity)
	end
end

function EPReagent:CheckSupplies(id, count)
	local name, stack, currentAmount, requiredAmount
	name, _, _, _, _, _, _, stack, _, _ = GetItemInfo(id)

	-- may not have the item in cache yet, or might have gotten wrong ID
	if not name then return end

	-- Check how many we need to buy
	currentAmount = GetItemCount(id)
	requiredAmount = count - currentAmount

	-- none needed so quit out
	if requiredAmount < 1 then return end

	self:RestockFromVendor(name, stack, requiredAmount)
end

function EPReagent:MERCHANT_SHOW(event)

	-- we have data for your character
	if playerTable then
		for i = 1, # playerTable do
			self:CheckSupplies(playerTable[i].item, playerTable[i].amount)
		end
	end
end

function EPReagent:PLAYER_LOGIN(event)
	local playerName, _ = UnitName("player")

	-- hmmm, using strings for indexing a table...I'm nasty
	playerTable = EPReagentPlayerTable[playerName]

	EPReagentPlayerTable = nil

	self:UnregisterEvent("PLAYER_LOGIN")
end

EPReagent:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
