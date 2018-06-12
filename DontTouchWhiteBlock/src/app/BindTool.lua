BindTool = BindTool or {}

function BindTool.UnPack(param, count, i, ...)
	if i >= count then
		if i == count then
			return param[i], ...
		end
		return ...
	end
	return param[i], BindTool.UnPack(param, count, i + 1, ...)
end

function BindTool.Bind(func, ...)
	if type(func) ~= "function" then
		ErrorLog("BindTool.Bind error!")
		return function() end
	end

	local count = select('#', ...)
	local param = {...}

	if 0 == count then
		return function(...) return func(...) end
	elseif 1 == count then
		return function(...) return func(param[1], ...) end
	elseif 2 == count then
		return function(...) return func(param[1], param[2], ...) end
	elseif 3 == count then
		return function(...) return func(param[1], param[2], param[3], ...) end
	elseif 4 == count then
		return function(...) return func(param[1], param[2], param[3], param[4], ...) end
	end

	return function(...) return func(BindTool.UnPack(param, count, 1, ...)) end
end