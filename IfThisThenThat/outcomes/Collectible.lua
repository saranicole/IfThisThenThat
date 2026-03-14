local IFTTT = IFTTT

local Outcomes = IFTTT.Outcomes
local Collectible = Outcomes.items.Collectible
Collectible.categories = {}
Collectible.subcategories = {}
Collectible.collectibles = {}
Collectible.available = {}
Collectible.previous = {}
Collectible.changes = {}
Collectible.selectedCategory = {}
Collectible.selectedSubcategory = {}
Collectible.selected = {}
Collectible.selections = {}
DM = ZO_COLLECTIBLE_DATA_MANAGER

-- COLLECTIBLE_CATEGORY_TYPE_VANITY_PET

function Collectible:GetCategoryNames()
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryName, numSubcategories = GetCollectibleCategoryInfo(categoryIndex)
        table.insert(self.categories, {name=categoryName, data=tostring(categoryIndex).."-"..tostring(numSubcategories).."-category"} )
    end
    table.sort(self.categories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    return self.categories
end

function Collectible:GetSubcategoryNames()
    if not self.selectedCategory.data then return end
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

function Collectible:GetCollectibles()
  if not self.selectedSubcategory.data then return end
  self.collectibles = {}
  local parts = IFTTT.Split(self.selectedCategory.data, "-")
  local subparts = IFTTT.Split(self.selectedSubcategory.data, "-")
  for collectibleIndex = 1, (subparts[2]) do
    local id = GetCollectibleId(parts[1], subparts[1], collectibleIndex)
    local name, description, iconFile, _, unlocked, _, purchasable, active = GetCollectibleInfo(id)
    if unlocked then
        table.insert(self.collectibles, {
            data          = id.."-place-collectible",
            name        = name
        })
    end
  end
  table.sort(self.collectibles, function(a, b)
      return a.name:lower() < b.name:lower()
  end)
  return self.collectibles
end

function Collectible:RefreshCategories()
  self.categories = self:GetCategoryNames()
  if next(Collectible.selectedCategory) then
    self.subcategories = self:GetSubcategoryNames(Collectible.selectedCategory)
  end
end

function Collectible:DoOutcome(outcome)
  for i = 1, #outcome do
    local outcomeparts = IFTTT.Split(outcome[i].data)
    if IsCollectibleUsable(outcomeparts[1]) then
      UseCollectible(outcomeparts[1])
    end
  end
end