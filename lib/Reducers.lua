local Util = require(script.Parent.Util)

return function (rocs)
	local Reducers = {}

	function Reducers.last(values)
		return values[#values]
	end

	function Reducers.first(values)
			return values[1]
	end

	function Reducers.truthy(values)
		for _, value in ipairs(values) do
			if value then
				return value
			end
		end
	end

	function Reducers.falsy(values)
		for _, value in ipairs(values) do
			if not value then
				return value
			end
		end
	end

	function Reducers.add(values)
		local reducedValue = 0

		for _, value in ipairs(values) do
			reducedValue = reducedValue + value
		end

		return reducedValue
	end

	function Reducers.propertyReducer(propertyReducers, disableMetadata)
		return function(values)
			local properties = {}

			for _, value in ipairs(values) do
				for propName, propValue in pairs(value) do
					if properties[propName] == nil then
						properties[propName] = {}
					end

					table.insert(properties[propName], propValue)
				end
			end

			local reducedValue = {}

			for propName, propValues in pairs(properties) do
				if not disableMetadata and rocs and rocs:_getMetadata(propName) then
					local reducible = rocs:_getMetadata(propName)

					reducedValue[propName] = Util.runReducer(reducible, propValues)
				else
					reducedValue[propName] =
						(propertyReducers[propName] or Reducers.last)(propValues)
				end
			end

			return reducedValue
		end
	end

	function Reducers.propertyReducerAll(reducer, ...)
		return Reducers.propertyReducer(setmetatable({}, {
			__index = function()
				return reducer
			end
		}), ...)
	end

	function Reducers.thisOr(reducer, defaultValue)
		return function(values)
			local result = reducer(values)

			if result == nil then
				return defaultValue
			else
				return result
			end
		end
	end

	local function makeOr(func)
		return function (defaultValue)
			return Reducers.thisOr(func, defaultValue)
		end
	end

	Reducers.truthyOr = makeOr(Reducers.truthy)
	Reducers.falsyOr = makeOr(Reducers.falsy)
	Reducers.default = Reducers.propertyReducer({})

	return Reducers
end
