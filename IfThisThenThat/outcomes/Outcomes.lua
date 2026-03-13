local IFTTT = IFTTT

local Outcomes = IFTTT.Outcomes or ZO_DeferredInitializingObject:Subclass()
Outcomes.items = {
  Collectible = {},
}

function Outcomes:Initialize(parent)
  self.parent = parent
  self.savedVars = parent.CV
end

function Outcomes.Init( ... )
	Outcomes = Outcomes:New( ... )
end

IFTTT.Outcomes = Outcomes
