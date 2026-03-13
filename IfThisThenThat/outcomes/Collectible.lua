local IFTTT = IFTTT

local Outcomes = IFTTT.Outcomes
local Collectible = Outcomes.items.Collectible
Collectible.categories = {}
Collectible.available = {}
Collectible.previous = {}
Collectible.changes = {}
Collectible.selectedCategory = {}
Collectible.selectedSubcategory = {}
Collectible.selections = {}
DM = ZO_COLLECTIBLE_DATA_MANAGER

-- COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
local function retrieveCollectibleCategory(category)
  local numCategories = DM:GetNumCategories()
  for i = 1, numCategories do
    local categoryName, numSubcategories, numCollectibles, categoryType = GetCollectibleCategoryInfo(i)
    if categoryType == category then
       return categoryName, numSubcategories, numCollectibles
    end
  end
end

local function GetCategoryNames()
    local categories = {}
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryName, numSubcategories = GetCollectibleCategoryInfo(categoryIndex)
        table.insert(categories, categoryName)
        end
    end
    return categories
end

local function GetSubcategoryNames(targetCategoryName)
    local subcategories = {}
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryName, numSubcategories = GetCollectibleCategoryInfo(categoryIndex)

        if categoryName == targetCategoryName then
            for subcategoryIndex = 1, numSubcategories do
                local subcategoryName = GetCollectibleSubcategoryInfo(categoryIndex, subcategoryIndex)
                table.insert(subcategories, subcategoryName)
            end
            break
        end
    end
    return subcategories
end

function Collectible:RefreshCategories()
  Collectible.categories = GetCategoryNames()
  if next(Collectible.selectedCategory) then
    Collectible.categories = GetSubcategoryNames(Collectible.selectedCategory)
  end
end
