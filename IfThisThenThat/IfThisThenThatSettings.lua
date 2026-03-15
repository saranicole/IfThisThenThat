local IFTTT = IFTTT

local LAM = LibHarvensAddonSettings

if not LibHarvensAddonSettings then
    return
end

IFTTT.categorySelectStage = ""
IFTTT.triggerCategorySelectStage = ""
IFTTT.triggerMountCategorySelectStage = ""
IFTTT.triggerSelectDisable = { 
["TriggerCollectibles"] = { ["Skills"] = true, ["TriggerMounts"] = true },
["Skills"] = { ["TriggerCollectibles"] = true, ["TriggerMounts"] = true }, 
["TriggerMounts"] = { ["Skills"] = true, ["TriggerCollectibles"] = true },
}
IFTTT.triggerSelected = {}
IFTTT.deleteSelected = {}

function IFTTT:BuildMenu()

  self.panel = LAM:AddAddon(self.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = false    -- Enable automatic control updates
  })

  self.panel:AddSetting {
    type = LAM.ST_SECTION,
    label = IFTTT.Lang.TRIGGER_HEADING
  }
  local triggerMountItem = IFTTT.Triggers.items.TriggerMounts
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.MOUNT_HEADING,
      items = triggerMountItem.subcategories,
      getFunction = function() 
        return triggerMountItem.selectedSubcategory.name or triggerMountItem.subcategories[1].name or ""
      end,
      setFunction = function(var, itemName, itemData)
        triggerMountItem.selectedSubcategory.name = itemName
        triggerMountItem.selectedSubcategory.data = itemData.data
        triggerMountItem:GetCollectibles()
        self.panel:UpdateControls()
      end,
      default = triggerMountItem.selectedSubcategory.name or triggerMountItem.subcategories[1].name or "",
      disable = function()
        for k, item in pairs(IFTTT.triggerSelectDisable["TriggerMounts"]) do
          if next(IFTTT.Triggers.items[k].selected) ~= nil then
            return true
          end
        end
        return false
      end,
    }
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.MOUNT_HEADING,
      items = function()
        local nodata = { name = GetString(SI_NOT_APPLICABLE), data = 0 }
        if next(triggerMountItem.collectibles) then
          return triggerMountItem.collectibles
        else
          return nodata
        end
      end,
      getFunction = function() 
        if next(triggerMountItem.collectibles) then
          return triggerMountItem.collectibles[1].name
        end
        if next(triggerMountItem.selected) then
          return triggerMountItem.selected.name
        end
        return ""
      end,
      setFunction = function(var, itemName, itemData)
        triggerMountItem.selected.name = itemName
        triggerMountItem.selected.data = itemData.data
        self.triggerSelected = triggerMountItem.selected
        self.panel:UpdateControls()
      end,
--       disable = function()
--         for k, item in pairs(IFTTT.triggerSelectDisable["TriggerMounts"]) do
--           if next(IFTTT.Triggers.items[k].selected) ~= nil then
--             return true
--           end
--         end
--         return false
--       end,
    }
  local triggerCollectibleItem = IFTTT.Triggers.items.TriggerCollectibles
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.TRIGGERCOLLECTIBLE_HEADING,
      items = function() 
        if IFTTT.triggerCategorySelectStage == "" then
          return triggerCollectibleItem.categories
        elseif IFTTT.triggerCategorySelectStage == "category" then
          return triggerCollectibleItem.subcategories
        elseif IFTTT.triggerCategorySelectStage == "subcategory" then
          return triggerCollectibleItem.collectibles
        end
        return triggerCollectibleItem.categories
      end ,
      getFunction = function() 
        if IFTTT.triggerCategorySelectStage == "category" then
          return triggerCollectibleItem.selectedCategory.name
        elseif IFTTT.triggerCategorySelectStage == "subcategory" then
          return triggerCollectibleItem.selectedSubcategory.name
        elseif IFTTT.triggerCategorySelectStage == "triggerCollectibles" then
          return triggerCollectibleItem.selected.name
        end
        return triggerCollectibleItem.categories[1].name or ""
      end,
      setFunction = function(var, itemName, itemData)
        local type = IFTTT.Split(itemData.data, "-")
        IFTTT.triggerCategorySelectStage = type[3]
        if type[3] == "category" then
          triggerCollectibleItem.selectedCategory.name = itemName
          triggerCollectibleItem.selectedCategory.data = itemData.data
          triggerCollectibleItem:GetSubcategoryNames()
        elseif type[3] == "subcategory" then
          triggerCollectibleItem.selectedSubcategory.name = itemName
          triggerCollectibleItem.selectedSubcategory.data = itemData.data
          triggerCollectibleItem:GetCollectibles()
        elseif type[3] == "triggerCollectibles" then
          triggerCollectibleItem.selected.name = itemName
          triggerCollectibleItem.selected.data = itemData.data
          self.triggerSelected = triggerCollectibleItem.selected
        end
        self.panel:UpdateControls()
      end,
      default = triggerCollectibleItem.categories[1].name or "",
      disable = function()
        for k, item in pairs(IFTTT.triggerSelectDisable["TriggerCollectibles"]) do
          if next(IFTTT.Triggers.items[k].selected) ~= nil then
            return true
          end
        end
        return false
      end,
    }
    self.panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.BACK,
      buttonText = IFTTT.Lang.BACK,
      clickHandler = function()
        if IFTTT.triggerCategorySelectStage == "category" then
          IFTTT.triggerCategorySelectStage = ""
        elseif IFTTT.triggerCategorySelectStage == "subcategory" then
          IFTTT.triggerCategorySelectStage = "category"
        elseif IFTTT.triggerCategorySelectStage == "collectible" then
          IFTTT.triggerCategorySelectStage = "subcategory"
          triggerCategorySelectStage.collectibles = {}
          triggerCategorySelectStage.selected = {}
        end
        self.panel:UpdateControls()
      end
    })
  for k, triggerItem in pairs(IFTTT.Triggers.items) do
    if k ~= "TriggerCollectibles" and k ~= "TriggerMounts" then
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang[string.upper(k).."_HEADING"],
      items = triggerItem.available,
      getFunction = function() 
        if next(triggerItem.selected) then
          return triggerItem.selected.name
        end
        return triggerItem.available[1].name or ""
      end,
      setFunction = function(var, itemName, itemData)
        triggerItem.selected = {name=itemName, data=itemData.data}
        self.triggerSelected = triggerItem.selected
        self.panel:UpdateControls()
      end,
      default = "",
      disable = function()
        for key, item in pairs(IFTTT.triggerSelectDisable[k]) do
          if next(IFTTT.Triggers.items[key].selected) ~= nil then
            return true
          end
        end
        return false
      end,
    }
    self.panel:AddSetting({
    type = LAM.ST_BUTTON,
    label = IFTTT.Lang.RESET_TRIGGERS,
    buttonText = IFTTT.Lang.RESET_TRIGGERS,
    clickHandler = function()
      for k, triggerItem in pairs(IFTTT.Triggers.items) do
        IFTTT.Triggers.items[k].selected = {}
      end
      self.panel:UpdateControls()
    end
  })
  self.panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang.EFFECT_HEADING
    }
    local collectibleItem = IFTTT.Outcomes.items.Collectible
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.COLLECTIBLE_HEADING,
      items = function() 
        if IFTTT.categorySelectStage == "" then
          return IFTTT.Outcomes.items.Collectible.categories
        elseif IFTTT.categorySelectStage == "category" then
          return IFTTT.Outcomes.items.Collectible.subcategories
        elseif IFTTT.categorySelectStage == "subcategory" then
          return IFTTT.Outcomes.items.Collectible.collectibles
        end
        return IFTTT.Outcomes.items.Collectible.categories
      end ,
      getFunction = function() 
        if IFTTT.categorySelectStage == "category" then
          return collectibleItem.selectedCategory.name
        elseif IFTTT.categorySelectStage == "subcategory" then
          return collectibleItem.selectedSubcategory.name
        elseif IFTTT.categorySelectStage == "collectible" then
          return collectibleItem.selected.name
        end
        return collectibleItem.categories[1].name or ""
      end,
      setFunction = function(var, itemName, itemData)
        local type = IFTTT.Split(itemData.data, "-")
        IFTTT.categorySelectStage = type[3]
        if type[3] == "category" then
          collectibleItem.selectedCategory.name = itemName
          collectibleItem.selectedCategory.data = itemData.data
          IFTTT.Outcomes.items.Collectible:GetSubcategoryNames()
        elseif type[3] == "subcategory" then
          collectibleItem.selectedSubcategory.name = itemName
          collectibleItem.selectedSubcategory.data = itemData.data
          IFTTT.Outcomes.items.Collectible:GetCollectibles()
        elseif type[3] == "collectible" then
          collectibleItem.selected.name = itemName
          collectibleItem.selected.data = itemData.data
        end
        self.panel:UpdateControls()
      end,
      default = collectibleItem.categories[1].name or ""
    }
    self.panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.BACK,
      buttonText = IFTTT.Lang.BACK,
      clickHandler = function()
        if IFTTT.categorySelectStage == "category" then
          IFTTT.categorySelectStage = ""
        elseif IFTTT.categorySelectStage == "subcategory" then
          IFTTT.categorySelectStage = "category"
        elseif IFTTT.categorySelectStage == "collectible" then
          IFTTT.categorySelectStage = "subcategory"
          collectibleItem.collectibles = {}
          collectibleItem.selected = {}
        end
        self.panel:UpdateControls()
      end
    })
    self.panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.ADD_LINK,
      buttonText = IFTTT.Lang.ADD,
      tooltip = IFTTT.Lang.ADD_TOOLTIP,
      clickHandler = function()
        local linkTrigger = { trigger = self.triggerSelected, outcome = collectibleItem.selected }
        table.insert(self.Links.savedVarsChar.links, linkTrigger)
        triggerItem.selected = {}
        collectibleItem.selectedCategory = {}
        collectibleItem.selectedSubcategory = {}
        collectibleItem.selected = {}
        self:AddCallbacks()
        self.panel:UpdateControls()
      end
    })
    self.panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.ACC_ADD_LINK,
      buttonText = IFTTT.Lang.ACC_ADD,
      tooltip = IFTTT.Lang.ACC_ADD_TOOLTIP,
      clickHandler = function()
        local linkTrigger = { trigger = self.triggerSelected, outcome = collectibleItem.selected }
        table.insert(self.Links.savedVarsAcc.links, linkTrigger)
        triggerItem.selected = {}
        collectibleItem.selectedCategory = {}
        collectibleItem.selectedSubcategory = {}
        collectibleItem.selected = {}
        self:AddCallbacks()
        self.panel:UpdateControls()
      end
    })
  end
end
  self.panel:AddSetting {
    type = LAM.ST_SECTION,
    label = IFTTT.Lang.EXISTING_LINKS
  }
  self.panel:AddSetting {
    type = LAM.ST_LABEL,
    label = function()
      local linkText = ""
      for key, linkItem in pairs(self.Links.savedVarsChar.links) do
        linkText = linkText.."\n"..IFTTT.Lang.CHARACTER.."   "..key.."   "..linkItem.trigger.name.." -> "..linkItem.outcome.name
      end
      return linkText
    end
  }
  self.panel:AddSetting {
    type = LAM.ST_LABEL,
    label = function()
      local linkText = ""
      for key, linkItem in pairs(self.Links.savedVarsAcc.links) do
        linkText = linkText.."\n"..IFTTT.Lang.ACCOUNT.."   "..key.."   "..linkItem.trigger.name.." -> "..linkItem.outcome.name
      end
      return linkText
    end
  }
  self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.COLLECTIBLE_HEADING,
      items = function() 
        local deleteItems = {}
        for key, linkItem in pairs(self.Links.savedVarsAcc.links) do
          table.insert(deleteItems, { name = IFTTT.Lang.ACCOUNT.."   "..key.."   "..linkItem.trigger.name.." -> "..linkItem.outcome.name, data = IFTTT.Lang.ACCOUNT.."-"..key })
        end
        for key, linkItem in pairs(self.Links.savedVarsChar.links) do
          table.insert(deleteItems, { name = IFTTT.Lang.CHARACTER.."   "..key.."   "..linkItem.trigger.name.." -> "..linkItem.outcome.name, data = IFTTT.Lang.CHARACTER.."-"..key })
        end
        return deleteItems
      end,
      getFunction = function() 
        return self.deleteSelected.name or ""
      end,
      setFunction = function(var, itemName, itemData)
        self.deleteSelected.name = itemName
        self.deleteSelected.data = itemData.data
      end
  }
  self.panel:AddSetting({
    type = LAM.ST_BUTTON,
    label = IFTTT.Lang.REMOVE_LINK,
    buttonText = IFTTT.Lang.REMOVE,
    tooltip = IFTTT.Lang.REMOVE_LINK,
    clickHandler = function()
      local deleteParts = self.Split(self.deleteSelected.data)
      if deleteParts[1] == IFTTT.Lang.ACCOUNT then
        self.Links.savedVarsAcc.links[tonumber(deleteParts[2])] = nil
      end
      if deleteParts[1] == IFTTT.Lang.CHARACTER then
        self.Links.savedVarsChar.links[tonumber(deleteParts[2])] = nil
      end
      self.deleteSelected = {}
      self.panel:UpdateControls()
    end
  })
  self.panel:AddSetting({
    type = LAM.ST_BUTTON,
    label = IFTTT.Lang.CLEAR_ALL,
    buttonText = IFTTT.Lang.CLEAR,
    tooltip = IFTTT.Lang.CLEAR_ALL,
    clickHandler = function()
      self:RemoveCallbacks()
      self.Links.savedVarsChar.links = {}
      self.Links.savedVarsAcc.links = {}
      self.panel:UpdateControls()
    end
  })
end
