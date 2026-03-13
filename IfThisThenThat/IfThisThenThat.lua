local IFTTT = IFTTT
local EM = EVENT_MANAGER


local function RefreshTriggers()
  for key, obj in pairs(IFTTT.Triggers.items) do
    obj:Refresh()
  end
  for key, obj in pairs(IFTTT.Outcomes.items) do
    obj:RefreshCategories()
  end
  IFTTT:BuildMenu()
end

local function AddCallbacks()
  for key, item in pairs(IFTTT.Triggers.items) do
    item:callbacks()
  end
end


local function onPlayerActivated()
  EM:UnregisterForEvent(IFTTT.Name, EVENT_PLAYER_ACTIVATED)
  IFTTT.Triggers:Init(IFTTT)
  IFTTT.Outcomes:Init(IFTTT)
  RefreshTriggers()
end

EM:RegisterForEvent(IFTTT.Name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
