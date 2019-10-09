
local StateMachine = {}

local function callHandler(handler, ...)
	if handler then
		return handler(...)
	end
end

local function reify(t, k)
	if t and k then
		return t[k]
	end
end

-- Define some static constants
StateMachine.NONE = "None"
StateMachine.ANY = "*"

-- Creates a new state machine with the given options
function StateMachine.new(options)
	local self = setmetatable({}, StateMachine)
	
	options = options or {}
	
	local initial = options.Initial or StateMachine.NONE
	local states = options.States or {}
	local events = options.Events or {}
	
	for name, event in pairs(events) do
		self[name] = function(eventOptions)
			local currentState = self.Current
			local nextState = event.Map[currentState] or event.Map[StateMachine.ANY]
			if nextState then
				if type(nextState) == "function" then
					nextState = nextState(currentState, options)
				end
				local onBefore = callHandler(event.OnBefore, self, currentState, nextState, eventOptions)
				if onBefore == false then return false end
				local onLeave = callHandler(reify(states[currentState], "OnLeave"), self, name, nextState, eventOptions)
				if onLeave == false then return false end
				local onEnter = callHandler(reify(states[nextState], "OnEnter"), self, name, currentState, eventOptions)
				self.Current = nextState
				local onAfter = callHandler(event.OnAfter, self, currentState, nextState, eventOptions)
				callHandler(self.OnStateChange, self, name, currentState, nextState, eventOptions)
			end
		end
	end
	
	for k, v in pairs(options.Stuff or {}) do
		self[k] = v
	end
	
	self.Initial = initial -- might be useful to store this idk
	self.Current = initial
	self.States = states
	self.Events = events
	self.OnStateChanged = options.OnStateChange
	
	for _, state in pairs(self.States) do
		callHandler(state.Init, self, initial)
	end
	
	return self
end

-- Simply looks better than a regular comparison.
-- Returns true if the current state matches the passed in string.
function StateMachine:Is(state)
	if self.Current == state then
		return true
	end
	return false
end

return StateMachine
