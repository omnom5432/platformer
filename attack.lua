Attack = {}

--Constructor
function Attack:new()
	--location
	local object = {
	x = 0,
	y = 0,
	width = 0,
	height = 0,
	duration = 0,
	force = 0,
	owner = 0,
	}

	setmetatable(object, {__index = Attack})
	return object
end

