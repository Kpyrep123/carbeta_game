model:CreateSequence(
	{
		name = "@turns_lookFrame_0",
		snap = true,
		delta = true,
		hidden = true,
		cmds = {
			{ cmd = "fetchframe", sequence = "@turns", frame = 0, dst = 0 },
			{ cmd = "fetchframe", sequence = "@turns", frame = 1, dst = 1 },
			{ cmd = "subtract", dst = 0, src = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "@turns_lookFrame_1",
		snap = true,
		delta = true,
		hidden = true,
		cmds = {
			{ cmd = "fetchframe", sequence = "@turns", frame = 1, dst = 0 },
			{ cmd = "fetchframe", sequence = "@turns", frame = 1, dst = 1 },
			{ cmd = "subtract", dst = 0, src = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "@turns_lookFrame_2",
		snap = true,
		delta = true,
		hidden = true,
		cmds = {
			{ cmd = "fetchframe", sequence = "@turns", frame = 2, dst = 0 },
			{ cmd = "fetchframe", sequence = "@turns", frame = 1, dst = 1 },
			{ cmd = "subtract", dst = 0, src = 1 }
		}
	}
)

model:CreateSequence(
	{
		name = "turns",
		delta = true,
		poseParamX = model:CreatePoseParameter( "turn", -1, 1, 0, false ),
		sequences = {
			{ "@turns_lookFrame_0", "@turns_lookFrame_1", "@turns_lookFrame_2" }
		}
	}
)
-- Workshop Importer [run_anims]: Run sequence
model:CreateSequence(
	{
		name = "run",
		looping = true,
		sequences = {
			{ "@run" }
		},
		addlayer = { "turns" },
		activities = {
				{ name = "ACT_DOTA_RUN", weight = 1 }
		}
	}
)
-- -- Workshop Importer [run_anims]: Run sequence
-- model:CreateSequence(
-- 	{
-- 		name = "run_injured",
-- 		looping = true,
-- 		sequences = {
-- 			{ "@run_injured" }
-- 		},
-- 		addlayer = { "turns" },
-- 		activities = {
-- 				{ name = "ACT_DOTA_RUN", weight = 1 },
-- 				{ name = "injured", weight = 1 }
-- 		}
-- 	}
-- )