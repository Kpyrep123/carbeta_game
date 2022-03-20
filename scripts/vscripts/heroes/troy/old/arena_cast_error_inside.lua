arena_cast_error_inside = class({})

function arena_cast_error_inside:CastFilterResult()
	return UF_FAIL_CUSTOM
end

function arena_cast_error_inside:GetCustomCastError()
	return "Cannot cast abilities inside of The Arena!"
end