local IFTTT = IFTTT

local Triggers = IFTTT.Triggers
local TriggerCollectibles = Triggers.items.TriggerCollectibles
TriggerCollectibles.categories = {}
TriggerCollectibles.subcategories = {}
TriggerCollectibles.collectibles = {}
TriggerCollectibles.available = {}
TriggerCollectibles.previous = {}
TriggerCollectibles.changes = {}
TriggerCollectibles.selectedCategory = {}
TriggerCollectibles.selectedSubcategory = {}
TriggerCollectibles.selections = {}
TriggerCollectibles.selected = {}
TriggerCollectibles.activeLock = {}
TriggerCollectibles.categoryLock = {}
TriggerCollectibles.existingCooldown = 0
TriggerCollectibles.timeRemaining = {}
TriggerCollectibles.snapshot = {}
local EM = EVENT_MANAGER

local nonUsableCategories = {
  [1] = true, -- Stories
  [2] = true, -- Patrons
  [3] = true, -- Upgrade
  [5] = true, -- Housing
  [6] = true, -- Furnishings
  [7] = true, -- Fragments
  [10] = true, -- Tools
  [11] = true, -- Mounts
  [15] = true, -- Armor Styles
  [16] = true, -- Weapon Styles
  [19] = true, -- Houses
  [22] = true, -- Chapters
  [25] = true, -- House Banks
  [26] = true, -- Fragments
}

function TriggerCollectibles:GetCategoryNames()
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryName, numSubcategories = GetCollectibleCategoryInfo(categoryIndex)
        if not nonUsableCategories[categoryIndex] then
          table.insert(self.categories, {name=categoryName, data=tostring(categoryIndex).."-"..tostring(numSubcategories).."-category"} )
        end
    end
    table.sort(self.categories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    return self.categories
end

function TriggerCollectibles:GetSubcategoryNames()
    if not self.selectedCategory.data then return end
    self.subcategories = {}
    local parts = IFTTT.Split(self.selectedCategory.data, "-")
    for subcategoryIndex = 1, parts[2] do
        local subcategoryName, numCollectibles = GetCollectibleSubCategoryInfo(parts[1], subcategoryIndex)
        table.insert(self.subcategories, {name=subcategoryName, data=tostring(subcategoryIndex).."-"..tostring(numCollectibles).."-subcategory"} )
    end
    table.sort(self.subcategories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    return self.subcategories
end

function TriggerCollectibles:GetCollectibles()
  if not self.selectedSubcategory.data then return end
  self.collectibles = {}
  local parts = IFTTT.Split(self.selectedCategory.data, "-")
  local subparts = IFTTT.Split(self.selectedSubcategory.data, "-")
  for collectibleIndex = 1, tonumber(subparts[2]) do
    local id = GetCollectibleId(parts[1], subparts[1], collectibleIndex)
    local category = GetCollectibleCategoryType(id)
    local name, description, iconFile, _, unlocked, _, purchasable, active = GetCollectibleInfo(id)
    if unlocked then
        table.insert(self.collectibles, {
            data          = id.."-"..parts[1].."_"..category.."_"..subparts[1].."-triggerCollectibles",
            name        = name
        })
    end
  end
  table.sort(self.collectibles, function(a, b)
      return a.name:lower() < b.name:lower()
  end)
  return self.collectibles
end

function TriggerCollectibles:Refresh()
  self.categories = self:GetCategoryNames()
  if next(self.selectedCategory) then
    self.subcategories = self:GetSubcategoryNames(self.selectedCategory)
  end
end

function TriggerCollectibles:removeCallbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED)
end

function TriggerCollectibles:callbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED)
  EM:RegisterForEvent(IFTTT.Name.."TriggerCollectibleCallback", EVENT_COLLECTIBLE_UPDATED, function(_, collectibleId) 
    local callbackTable = {}
    for key, link in pairs(links) do
      callbackTable = {}
      local triggerparts = IFTTT.Split(link.trigger.data)
      local outcomeparts = IFTTT.Split(link.outcome.data)
      local desiredCollectibleId = tonumber(triggerparts[1])
      local type = IFTTT.toCapitalized(outcomeparts[3])
      link.trigger.active = link.trigger.active or {}
      if collectibleId == tonumber(desiredCollectibleId) then
        local category = GetCollectibleCategoryType(collectibleId)
        local toggleOn = IsCollectibleActive(collectibleId)
        local slotKey = triggerparts[1].."-"..triggerparts[2].."-"..outcomeparts[1]
        callbackTable[type] = callbackTable[type] or {}
        table.insert(callbackTable[type], link.outcome)
        for k, obj in pairs(callbackTable) do
          zo_callLater(function()
            IFTTT.Outcomes.items[k]:DoOutcome(obj, toggleOn, self.categoryLock[category])
            if not self.categoryLock[category] then
              self.categoryLock[category] = true
            end
          end, 1500)
        end
      end
    end
  end)
end
