model:CreateSequence(
	{
		name = "run",
		sequences = {
			{ "@run" }
		},
		activities = {
			{ name = "ACT_DOTA_RUN", weight = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "run_injured",
		looping = true,
		sequences = {
			{ "@run_injured" }
		},
		activities = {
				{ name = "ACT_DOTA_RUN", weight = 1 },
				{ name = "injured", weight = 1 }
		}
	}
)