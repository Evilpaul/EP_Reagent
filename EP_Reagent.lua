local EPReagent = CreateFrame("Frame")
EPReagent:RegisterEvent("MERCHANT_SHOW")

function EPReagent:MessageOutput (inputMessage)
	ChatFrame1:AddMessage(string.format("|cffDAFF8A[Reagent]|r %s", inputMessage))
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

	local itemLink = GetMerchantItemLink(counter)

	-- quit out for now, might add something about this later
	if not isUsable then return end

	if extendedCost then

		-- purchase of items with other currency is not supported, quit out
		self:MessageOutput("Purchase using alternative currency is not currently supported")
		return

---- DEBUG ----
--[[
		local itemValue, eCostItemLink, availableItemLink
		local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(counter)
		local myHonorPoints = GetHonorCurrency()
		local myArenaPoints = GetArenaCurrency()

		self:MessageOutput(string.format("Extended item cost is %d honor points, %d arena points and %d other currencies", honorPoints, arenaPoints, itemCount))
		self:MessageOutput(string.format("User has %d honor points and %d arena points", myHonorPoints, myArenaPoints))

		if itemCount then
			for i = 1, itemCount do
				_, itemValue, eCostItemLink = GetMerchantItemCostItem(counter, i)
				availableItemLink = GetItemCount(eCostItemLink)
				self:MessageOutput(string.format("Other Currency %d is : %d of %s, user has %d available", i, itemValue, eCostItemLink, availableItemLink))
			end
		end
]]--
	end

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

	-- calculate total cost of resupply
	local totalCost = price * revisedQuantity

	-- check how much money we have
	local gold = GetMoney()

	if totalCost > gold then
		-- we cannot afford the full cost, print message and quit out
		self:MessageOutput("Cannot afford to purchase required " .. itemLink .. "!")
		return
	else
		-- format the output string depending upon user selected Colour Blind Mode
		local moneyString
		if (GetCVar("colorblindMode") == "0") then
			moneyString = GetCoinTextureString(rawAmount)
		else
			moneyString = GetCoinText(rawAmount)
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

function EPReagent:RestockMe()
	local playerName, _ = UnitName("player")

	-- hmmm, using strings for indexing a table...I'm nasty
	local test = EPReagentPlayerTable[playerName]

	-- we have found data for your character
	if test then
		for i = 1, # test do
			self:CheckSupplies(test[i].item, test[i].amount)
		end
	end
end

EPReagent:SetScript("OnEvent", function(self, event, ...)
	self:RestockMe()
end)
