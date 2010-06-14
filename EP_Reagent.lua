local _, ns = ...

local format = string.format
local floor = math.floor

local EPReagent = CreateFrame('Frame')
EPReagent:RegisterEvent('MERCHANT_SHOW')
EPReagent:RegisterEvent('ADDON_LOADED')

function EPReagent:MessageOutput(inputMessage)
	DEFAULT_CHAT_FRAME:AddMessage(format('|cffDAFF8A[Reagent]|r %s', inputMessage))
end

function EPReagent:RestockFromVendor(reagentName, stack, quantityNeeded)
	local itemName, price, quantity, numAvailable, isUsable
	local soldItems = GetMerchantNumItems()

	local counter = 1
	while counter <= soldItems do
		itemName, _, price, quantity, numAvailable, isUsable, _ = GetMerchantItemInfo(counter)

		if itemName == reagentName then break end -- found it, break out of the loop

		counter = counter + 1
	end

	-- vendor does not sell the item, quit out
	if itemName ~= reagentName then return end

	-- quit out for now, might add something about this later
	if not isUsable then return end

	-- re-evaluate the number needed depending upon how many are sold in a batch
	local revisedQuantity = floor(quantityNeeded / quantity)
	-- re-evaluate the number per stack depending upon how many are sold in a batch
	local revisedStack = floor(stack / quantity)

	if numAvailable ~= -1 and -- limited number available
	   numAvailable < revisedQuantity then -- fewer available than required
	   	revisedQuantity = numAvailable
	end

	-- we require less than 1 batch so quit
	if revisedQuantity < 1 then return end

	-- calculate total cost of resupply
	local totalCost = price * revisedQuantity

	-- check how much money we have
	local gold = GetMoney()

	local itemLink = GetMerchantItemLink(counter)

	if totalCost > gold then
		-- we cannot afford the full cost, print message and quit out
		self:MessageOutput(format('Cannot afford to purchase required %s!', itemLink))
		return
	else
		-- format the output string depending upon user selected Colour Blind Mode
		local moneyString
		if (GetCVar('colorblindMode') == '0') then
			moneyString = GetCoinTextureString(totalCost)
		else
			moneyString = GetCoinText(totalCost)
		end

		-- we can afford to restock reagents
		self:MessageOutput(format('Purchasing %s worth of %s', moneyString, itemLink))
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

function EPReagent:CheckSupplies(package)
	local name, _, _, _, _, _, _, stack, _, _ = GetItemInfo(package.item)

	-- may not have the item in cache yet, or might have gotten wrong ID
	if not name then return end

	-- Check how many we need to buy
	local requiredAmount = package.amount - GetItemCount(package.item)

	-- none needed so quit out
	if requiredAmount < 1 then return end

	self:RestockFromVendor(name, stack, requiredAmount)
end

function EPReagent:MERCHANT_SHOW(event)
	for i = 1, #self.playerTable do
		self:CheckSupplies(self.playerTable[i])
	end
end

function EPReagent:ADDON_LOADED(event, name)
	if name == 'EP_Reagent' then
		local playerName, _ = UnitName('player')

		self.playerTable = ns.config[playerName] or {}

		ns.config = nil

		self:UnregisterEvent('ADDON_LOADED')
	end
end

EPReagent:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)
