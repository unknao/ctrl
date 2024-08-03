if SERVER then

	util.AddNetworkString("ctrl.countdown")
	util.AddNetworkString("ctrl.abort")

	require("finishedloading")

	local countdown_start_time = RealTime()

	function ctrl.countdown(delay, name, fancy, func, ...)

		ctrl.message("Countdown started, duration: " .. delay .. " seconds")
		local delay = delay
		local remainder = delay
		countdown_start_time = RealTime()
		local vararg = {...}

		net.Start("ctrl.countdown")
		net.WriteString(name)
		net.WriteFloat(delay)
		net.WriteFloat(remainder)
		net.WriteBool(fancy)
		net.Broadcast()

		--Do not exclude the people connecting mid countdown
		hook.Add("FinishedLoading", "ctrl.countdown", function(ply)

			local time_remaining = (countdown_start_time + delay) - RealTime()
			if time_remaining <= 0 then return end

			net.Start("ctrl.countdown")
			net.WriteString(name)
			net.WriteFloat(time_remaining)
			net.WriteFloat(remainder)
			net.WriteBool(fancy)
			net.Send(ply)

		end)

		timer.Create("ctrl.countdown", delay, 1, function()

			ctrl.message("Countdown ended.")
			func(unpack(vararg))
			hook.Remove("FinishedLoading", "ctrl.countdown")

		end)

	end

	function ctrl.abort()

		ctrl.message("Countdown aborted.")
		timer.Stop("ctrl.countdown")
		hook.Remove("FinishedLoading", "ctrl.countdown")
		net.Start("ctrl.abort")
		net.Broadcast()

	end

	concommand.Add("ctrltestcountdown", function()
		ctrl.countdown(10, "testing countdown", true, print, "hi")
	end)
end

if CLIENT then

	local fancy_lines = {

		[180] = "npc/overwatch/cityvoice/fcitadel_3minutestosingularity.wav",
		[120] = "npc/overwatch/cityvoice/fcitadel_2minutestosingularity.wav",
		[60] = "npc/overwatch/cityvoice/fcitadel_1minutetosingularity.wav",
		[30] = "npc/overwatch/cityvoice/fcitadel_30sectosingularity.wav",
		[15] = "npc/overwatch/cityvoice/fcitadel_15sectosingularity.wav",
		[5] = "npc/overwatch/radiovoice/five.wav",
		[4] = "npc/overwatch/radiovoice/four.wav",
		[3] = "npc/overwatch/radiovoice/three.wav",
		[2] = "npc/overwatch/radiovoice/two.wav",
		[1] = "npc/overwatch/radiovoice/one.wav",

	}

	surface.CreateFont("ctrl.countdown", {
		font = "Arial",
		outline = true,
		size = 40,
		weight = 1200,
		extended = true,
	})

	surface.CreateFont("ctrl.countdownname", {
		font = "Arial",
		outline = true,
		size = 20,
		weight = 1200,
		extended = true,
	})
	net.Receive("ctrl.countdown", function()

		countdown_start_time = RealTime()

		local name = net.ReadString()
		local duration = net.ReadFloat()
		local remainder = net.ReadFloat()
		local fancy = net.ReadBool()

		hook.Add("HUDPaint", "ctrl.countdown", function()

			local time_remaining = ((countdown_start_time + duration) - RealTime())
			if time_remaining < 0 then return end

			draw.RoundedBox(0, 0, 0, ScrW() * (time_remaining / remainder) + 2, 7, color_black)
			draw.RoundedBox(0, 0, 0, ScrW() * (time_remaining / remainder), 5, color_white)

			draw.Text({
				text = name,
				font = "ctrl.countdownname",
				xalign = 1,
				yalign = 4,
				pos = {ScrW() / 2, 40}
			})

			draw.Text({
				text = string.FormattedTime(time_remaining, "%02i:%02i.%02i"),
				font = "ctrl.countdown",
				xalign = 1,
				yalign = 3,
				pos = {ScrW() / 2, 40}
			})

		end)

		if fancy then

			local fancy_sounds = {
				"ambient/atmosphere/city_tone.wav",
				"ambient/atmosphere/underground.wav",
				"ambient/atmosphere/cave_outdoor1.wav",
				"ambient/voices/appartments_crowd_loop1.wav",
				"ambient/atmosphere/tone_quiet.wav",
				"ambient/energy/electric_loop.wav",
				"ambient/atmosphere/cargo_hold1.wav",
			}
			ctrl.sounds = ctrl.sounds or {}

			if table.IsEmpty(ctrl.sounds) then
				for i, v in ipairs(fancy_sounds) do
					ctrl.sounds[i] = CreateSound(game.GetWorld(), v)
					if ctrl.sounds[i] then ctrl.sounds[i]:SetSoundLevel(0) end
				end
			end

			local sound_start_time = math.max(remainder - 10, 0)
			timer.Create("ctrl.countdown.fancy_sounds", sound_start_time, 1, function()
				for i, v in ipairs(ctrl.sounds) do
					v:PlayEx(0, 100)
				end
			end)

			local time_d, time = 0, 0
			local beam_pos1, beam_pos2, vec = Vector(0, 0, 0), Vector(0, 0, 0), Vector(1, 1, 1) --Caching for faster runtime
			local m = Matrix()
			local fancy_draw_color = Color(255, 255, 255, 0)
			local fancy_final_stage = false
			local fancy_time_fraction = 1

			--Make it look like the end of the world.
			hook.Add("PostDrawEffects", "ctrl.fancyCountdown", function()

				local time_remaining = math.max((countdown_start_time + duration) - RealTime(), 0)
				fancy_time_fraction = math.min(time_remaining / math.min(remainder, 10), 1)

				time_d = time
				time = math.ceil(time_remaining)

				if time_d ~= time and fancy_lines[time] then
					surface.PlaySound(fancy_lines[time])
				end

				if fancy_time_fraction == 1 then return end

				util.ScreenShake(vector_origin, math.ease.InExpo(1 - fancy_time_fraction) * 6, 50, 0.1, 0)

				for i, v in ipairs(ctrl.sounds) do
					v:ChangeVolume(math.ease.InExpo(1 - fancy_time_fraction))
				end

				render.SetColorMaterial()
				local mult = math.ease.OutExpo(1 - math.max((1 - fancy_time_fraction) * 1.1 - 1, 0) * 10)

				fancy_draw_color.r = 255 * mult
				fancy_draw_color.g = 255 * mult
				fancy_draw_color.b = 255 * mult
				fancy_draw_color.a = 255 * math.min((1 - fancy_time_fraction) * 1.2, 1)

				local beam_count = math.floor(math.ease.InCirc(1 - fancy_time_fraction) * 10000)
				cam.Start3D()
					render.StartBeam(beam_count)
						local x, y = math.random(-500, 500), math.random(-500, 50)
						for i = 1, beam_count * 0.25 do
							if i ~= 1 then
								render.AddBeam(beam_pos1, 0, 0, fancy_draw_color)
							end
							beam_pos1:SetUnpacked(x, y, -32767)
							beam_pos2:SetUnpacked(x, y, 32767)

							render.AddBeam(beam_pos1, 8, 0, fancy_draw_color)
							render.AddBeam(beam_pos2, 8, 0, fancy_draw_color)
							render.AddBeam(beam_pos2, 0, 0, fancy_draw_color)
							x, y = math.random(-32767, 32767), math.random(-32767, 32767)
						end
					render.EndBeam()

					m:Identity()
					m:SetTranslation(EyePos())
					m:Scale(vec * (10 + 10000 * fancy_time_fraction))
					cam.PushModelMatrix(m)
						render.CullMode(1)
						render.DrawSphere(vector_origin, 1, 50, 50, fancy_draw_color)
						render.CullMode(0)
					cam.PopModelMatrix()
				cam.End3D()
				if fancy_time_fraction <= 0.05 and not fancy_final_stage then
					fancy_final_stage = true
					hook.Add("PostDrawHUD", "ctrl.fancyCountdownFinalStage", function()
						render.SetColorMaterial()
						local fancy_final_countdown_scalar = math.ease.InCirc((0.05 - fancy_time_fraction) * 20)
						surface.SetDrawColor(fancy_draw_color.r, fancy_draw_color.g, fancy_draw_color.b, fancy_final_countdown_scalar * 255)
						surface.DrawRect(0, 0, ScrW(), ScrH())
					end)
				end
			end)
		end

		timer.Create("ctrl.countdown", duration, 1, function()

			surface.PlaySound("buttons/button1.wav")
			hook.Remove("HUDPaint", "ctrl.countdown")
			timer.Simple(2, function()
				hook.Remove("PostDrawEffects", "ctrl.fancyCountdown")
				hook.Remove("PostDrawHUD", "ctrl.fancyCountdownFinalStage")
				fancy_final_stage = false
				for _, v in ipairs(ctrl.sounds) do v:Stop() end
			end)

		end)

	end)

	net.Receive("ctrl.abort", function()

		hook.Remove("HUDPaint", "ctrl.countdown")
		hook.Remove("PostDrawEffects", "ctrl.fancyCountdown")
		hook.Remove("PostDrawHUD", "ctrl.fancyCountdownFinalStage")
		fancy_final_stage = false
		timer.Stop("ctrl.countdown")
		timer.Stop("ctrl.countdown.fancy_sounds")

		for i, v in ipairs(ctrl.sounds) do v:Stop() end
		surface.PlaySound("buttons/button1.wav")

	end)
end
