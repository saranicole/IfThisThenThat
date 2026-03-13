local IFTTT = IFTTT

local Triggers = IFTTT.Triggers or ZO_DeferredInitializingObject:Subclass()
Triggers.items = {
  Skills = {},
}

function Triggers:Initialize(parent)
  self.parent = parent
  self.savedVars = parent.CV
  
end

function Triggers.Init( ... )
	Triggers = Triggers:New( ... )
end

IFTTT.Triggers = Triggers
