local IFTTT = IFTTT

local Triggers = IFTTT.Triggers
local Skills = Triggers.items.Skills
Skills.available = {}
Skills.previous = {}
Skills.changes = {}
Skills.selections = {}
Skills.selected = {}
local EM = EVENT_MANAGER

function Skills:Refresh()
  ZO_DeepTableCopy(Skills.available, Skills.previous)
  Skills.available = {}
  for slot = 1, 8 do
      local abilityId = GetSlotBoundId(slot, HOTBAR_CATEGORY_PRIMARY)
      if abilityId and abilityId ~= 0 then
          local name = GetAbilityName(abilityId)
          table.insert(Skills.available, { name=name, bar=HOTBAR_CATEGORY_PRIMARY, slotId=slot, data=HOTBAR_CATEGORY_PRIMARY.."-"..tostring(slot).."-skills" })
      end
  end
  for slot = 1, 8 do
      local abilityId = GetSlotBoundId(slot, HOTBAR_CATEGORY_BACKUP)
      if abilityId and abilityId ~= 0 then
          local name = GetAbilityName(abilityId)
          table.insert(Skills.available, { name=name, bar=HOTBAR_CATEGORY_BACKUP, slotId=slot, data=HOTBAR_CATEGORY_BACKUP.."-"..tostring(slot).."-skills" })
      end
  end
  Skills.changes = IFTTT.DiffTables(Skills.previous, Skills.hotbar)
end

function Skills:callbacks(links)
  EM:UnregisterForEvent(IFTTT.Name, EVENT_ACTION_SLOT_ABILITY_USED)
  EM:RegisterForEvent(IFTTT.Name, EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex) 
    local callbackTable = {}
    for key, link in pairs(links) do
      callbackTable = {}
      local triggerparts = IFTTT.Split(link.trigger.data)
      local outcomeparts = IFTTT.Split(link.outcome.data)
      local type = IFTTT.toCapitalized(outcomeparts[3])
      if tostring(actionSlotIndex) == triggerparts[2] then
        callbackTable[type] = callbackTable[type] or {}
        table.insert(callbackTable[type], link.outcome)
        for k, obj in pairs(callbackTable) do
          IFTTT.Outcomes.items[k]:DoOutcome(obj)
        end
      end
    end
  end)
end

function Skills:RegisterEvents()

end
