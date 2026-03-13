local IFTTT = IFTTT

local LAM = LibHarvensAddonSettings

if not LibHarvensAddonSettings then
    return
end

function IFTTT:BuildMenu()

  self.panel = LAM:AddAddon(self.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = true    -- Enable automatic control updates
  })
  local counter = 1
  local counter2 = 1
  for key, item in pairs(IFTTT.Triggers.items) do
    if counter > 2 then
      break
    end
    counter = counter + 1
    self.panel:AddSetting {
      type = LAM.ST_LABEL,
      label = IFTTT.Lang.TRIGGER_HEADING
    }
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = key,
      items = item.available,
      getFunction = function() 
        if #item.selections > 0 then
          return item.selections[1].name
        else
          return item.available[1].name
        end
      end,
      setFunction = function(var, itemName, itemData)
        table.insert(item.selections, {category=key, name=itemName, data=itemData.data})
      end,
      default = "",
    }
  end
  self.panel:AddSetting {
      type = LAM.ST_LABEL,
      label = IFTTT.Lang.EFFECT_HEADING
    }
  for key, item in pairs(IFTTT.Outcomes.items) do
    if counter2 > 2 then
      break
    end
    counter2 = counter2 + 1
    self.panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = key,
      items = item.categories,
      getFunction = function() 
        if #item.selectedCategory > 0 then
          return item.selectedCategory[1].name
        else
          return item.categories[1].name
        end
      end,
      setFunction = function(var, itemName, itemData)
        table.insert(item.selectedCategory, {triggerCategory=key, triggerName=item.selections[1].name, triggerData=item.selections[1].data, name=itemName, data=itemData.data})
        item:callbacks()
      end,
      default = ""
    }
  end
end
