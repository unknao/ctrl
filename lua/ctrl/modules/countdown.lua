if SERVER then

	util.AddNetworkString("ctrl.countdown")
	util.AddNetworkString("ctrl.abort")

	require("finishedloading")

	local CountdownStarted = RealTime()

	function ctrl.countdown(duration, name, fancy, func, ...)

		ctrl.msg("Countdown started, duration: " .. duration .. " seconds")
		local duration = duration
		local remainder = duration
		CountdownStarted = RealTime()
		local vararg = {...}

		net.Start("ctrl.countdown")
		net.WriteString(name)
		net.WriteFloat(duration)
		net.WriteFloat(remainder)
		net.WriteBool(fancy)
		net.Broadcast()

		--Do not exclude the people connecting mid countdown
		hook.Add("FinishedLoading", "ctrl.countdown", function(ply)

			local TimeRemaining = (CountdownStarted + duration) - RealTime()
			if TimeRemaining <= 0 then return end

			net.Start("ctrl.countdown")
			net.WriteString(name)
			net.WriteFloat(TimeRemaining)
			net.WriteFloat(remainder)
			net.WriteBool(fancy)
			net.Send(ply)

		end)

		timer.Create("ctrl.countdown", duration, 1, function()

			ctrl.msg("Countdown ended.")
			func(unpack(vararg))
			hook.Remove("FinishedLoading", "ctrl.countdown")

		end)

	end

	function ctrl.abort()

		ctrl.msg("Countdown aborted.")
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

	local fancylines = {

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

		local CountdownStarted = RealTime()

		local name = net.ReadString()
		local duration = net.ReadFloat()
		local remainder = net.ReadFloat()
		local fancy = net.ReadBool()

		hook.Add("HUDPaint", "ctrl.countdown", function()

			local TimeRemaining = ((CountdownStarted + duration) - RealTime())
			if TimeRemaining < 0 then return end

			draw.RoundedBox(0, 0, 0, ScrW() * (TimeRemaining / remainder) + 2, 7, color_black)
			draw.RoundedBox(0, 0, 0, ScrW() * (TimeRemaining / remainder), 5, color_white)

			draw.Text({
				text = name,
				font = "ctrl.countdownname",
				xalign = 1,
				yalign = 4,
				pos = {ScrW() / 2, 40}
			})

			draw.Text({
				text = string.FormattedTime(TimeRemaining, "%02i:%02i.%02i"),
				font = "ctrl.countdown",
				xalign = 1,
				yalign = 3,
				pos = {ScrW() / 2, 40}
			})

		end)

		if fancy then

			local fancysounds = {
				"ambient/atmosphere/city_tone.wav",
				"ambient/atmosphere/underground.wav",
				"ambient/atmosphere/cave_outdoor1.wav",
				"ambient/voices/appartments_crowd_loop1.wav",
				"ambient/atmosphere/tone_quiet.wav",
				"ambient/energy/electric_loop.wav",
				"ambient/atmosphere/cargo_hold1.wav",
			}
			ctrl.Sounds = ctrl.Sounds or {}

			if table.IsEmpty(ctrl.Sounds) then
				for i, v in ipairs(fancysounds) do
					ctrl.Sounds[i] = CreateSound(game.GetWorld(), v)
					if ctrl.Sounds[i] then ctrl.Sounds[i]:SetSoundLevel(0) end
				end
			end

			local SoundStartTime = math.max(remainder - 10, 0)
			timer.Create("ctrl.countdown.fancysounds", SoundStartTime, 1, function()
				for i, v in ipairs(ctrl.Sounds) do
					v:PlayEx(0, 100)
				end
			end)

			local LastTime, Time = 0, 0
			local BeamPos1, BeamPos2, vec = Vector(0, 0, 0), Vector(0, 0, 0), Vector(1, 1, 1) --Caching for faster runtime
			local m = Matrix()
			local DrawColor = Color(255, 255, 255, 0)

			--Make it look like the end of the world.
			hook.Add("PostDrawTranslucentRenderables", "ctrl.countdown", function(bDepth, bSkybox)

				local TimeRemaining = math.max((CountdownStarted + duration) - RealTime(), 0)
				local Fraction = math.min(TimeRemaining / math.min(remainder, 10), 1)

				LastTime = Time
				Time = math.ceil(TimeRemaining)

				if LastTime ~= Time and fancylines[Time] then
					surface.PlaySound(fancylines[Time])
				end

				if Fraction == 1 then return end

				util.ScreenShake(vector_origin, math.ease.InExpo(1 - Fraction) * 6, 50, 0.1, 0)

				for i, v in ipairs(ctrl.Sounds) do
					v:ChangeVolume(math.ease.InExpo(1 - Fraction))
				end

				render.SetColorMaterial()
				local mult = math.ease.OutExpo(1 - math.max((1 - Fraction) * 1.1 - 1, 0) * 10)

				DrawColor.r = 255 * mult
				DrawColor.g = 255 * mult
				DrawColor.b = 255 * mult
				DrawColor.a = 255 * math.min((1 - Fraction) * 1.2, 1)

				for _ = 1, math.floor(math.ease.InCirc(1 - Fraction) * 5000) do
					local x, y = math.random(-32767, 32767), math.random(-32767, 32767)
					BeamPos1:SetUnpacked(x, y, -32767)
					BeamPos2:SetUnpacked(x, y, 32767)
					render.DrawBeam(BeamPos1, BeamPos2, 5, 1, 1, DrawColor)
				end
				m:Identity()
				m:SetTranslation(EyePos())
				m:Scale(vec * (10 + 10000 * Fraction))
				cam.PushModelMatrix(m)
					render.CullMode(1)
					render.DrawSphere(vector_origin, 1, 50, 50, DrawColor)
					render.CullMode(0)
				cam.PopModelMatrix()
			end)
		end

		timer.Create("ctrl.countdown", duration, 1, function()

			surface.PlaySound("buttons/button1.wav")
			hook.Remove("HUDPaint", "ctrl.countdown")
			timer.Simple(2, function()
				hook.Remove("PostDrawTranslucentRenderables", "ctrl.countdown")
				for i, v in ipairs(ctrl.Sounds) do v:Stop() end
				surface.PlaySound("buttons/lightswitch2.wav")
			end)

		end)

	end)

	net.Receive("ctrl.abort", function()

		hook.Remove("HUDPaint", "ctrl.countdown")
		hook.Remove("PostDrawTranslucentRenderables", "ctrl.countdown")
		timer.Stop("ctrl.countdown")
		timer.Stop("ctrl.countdown.fancysounds")

		for i, v in ipairs(ctrl.Sounds) do v:Stop() end
		surface.PlaySound("buttons/button1.wav")

	end)
end
