arena_cast_error_outside = class({})

function arena_cast_error_outside:CastFilterResult()
	return UF_FAIL_CUSTOM
end

function arena_cast_error_outside:GetCustomCastError()
	return "Cannot cast abilities outside of The Arena!"
end