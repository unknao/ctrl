local function GenerateFakeSteamID()
    local number_sequence = {}
    for i = 1, 8 do
        number_sequence[i] = math.random(0, 9)
    end
    return string.format("STEAM_%i:%i:%s", math.random(0, 1), math.random(0, 1), table.concat(number_sequence, ""))
end

local function GenerateFakeName(target)
    if not IsValid(target) then return "noname" end
    local model = target:GetModel()
    if #model > 0 then
        model = string.match(model, ".*/(%S+)%.")
    else
        model = target:GetClass()
    end

    return model
end

function ctrl.kick(target, reason)
    if not IsValid(target) then return end
    local why = reason
    if not isstring(why) or #why == 0 then
        why = "Kicked by admin."
    end
    if not target:IsPlayer() then --kick props
        local tbl = {
            bot = 0,
            networkid = GenerateFakeSteamID(),
            name = GenerateFakeName(target),
            userid = target:EntIndex(),
            reason = why
        }
        hook.Run("player_disconnect", tbl)
        print(string.format("Dropped %s from server (%s)", tbl.name, tbl.reason))
        target:Remove()
        return
    end

    target:Kick(why)
end

function ctrl.ban(target, duration, reason)
    if not IsValid(target) then return end
    local why = reason
    if not isstring(why) or #why == 0 then
        why = "Kicked by admin."
    end
    if not target:IsPlayer() then --kick props
        local tbl = {
            bot = 0,
            networkid = GenerateFakeSteamID(),
            name = GenerateFakeName(target),
            userid = target:EntIndex(),
            reason = why
        }
        hook.Run("player_disconnect", tbl)
        print(string.format("Dropped %s from server (%s)", tbl.name, tbl.reason))
        target:Remove()
        return
    end

    if not target:IsBot() then
        target:Ban(duration, false)
    end
    target:Kick(why)
end