if not LPH_OBFUSCATED then
	function LPH_NO_VIRTUALIZE(f)
		return f
	end
	function LPH_JIT(...)
		return ...
	end
	function LPH_JIT_MAX(...)
		return ...
	end
	function LPH_NO_UPVALUES(f)
		return function(...)
			return f(...)
		end
	end
	function LPH_ENCSTR(...)
		return ...
	end
	function LPH_ENCNUM(...)
		return ...
	end
	function LPH_CRASH()
		return print(debug.traceback())
	end
end

repeat
	task.wait()
until game:IsLoaded()

local clone_reference = cloneref or function(...) -- i need to cloneref stuf fso
	return ...
end

local players: Players = clone_reference(game:GetService("Players"))
local run_service: RunService = clone_reference(game:GetService("RunService"))
local replicated_storage: ReplicatedStorage = clone_reference(game:GetService("ReplicatedStorage"))
local user_input_service: UserInputService = clone_reference(game:GetService("UserInputService"))
local lighting: Lighting = clone_reference(game:GetService("Lighting"))
local core_gui: CoreGui = clone_reference(game:GetService("CoreGui"))
local http_service: HttpService = clone_reference(game:GetService("HttpService"))

local local_player = players.LocalPlayer

if game.PlaceId == 10228136016 then
	return local_player:Kick("execute ingame")
end

do
	local exploit_functions = {
		["cloneref"] = cloneref or false,
		["listfiles"] = listfiles or false,
		["Drawing"] = Drawing or false,
		["sethiddenproperty"] = sethiddenproperty or false,
		["run_on_actor"] = run_on_actor or false,
		["getactors"] = getactors or false,
		["gethui"] = gethui or false,
		["getcallingscript"] = getcallingscript or false,
		["hookfunction"] = hookfunction or false,
		["isfunctionhooked"] = isfunctionhooked or false,
		["create_comm_channel"] = create_comm_channel or false,
	}

	for i, v in exploit_functions do
		if v == false then
			return local_player:Kick(string.format("unsupported exploit! [%s]", i))
		end
	end
end

xpcall(function()
	local done = false
	local id, channel = create_comm_channel()
	channel.Event:Connect(function()
		done = true
	end)

	local module_bypassed = false
	local offsets = {
		[76] = function(func)
			hookfunction(func, function(detection)
				if tonumber(detection) then
					local skyyy = Instance.new("Sky")
					skyyy.Name = detection
					skyyy._ = 0
				end

				print("corescript", "module", detection)
			end)
			print("corescript", "bypassed module vector util")
			module_bypassed = true
		end,
	}
	for _, func in getgc(false) do
		if type(func) ~= "function" or (iscclosure(func)) or (isexecutorclosure(func)) then
			continue
		end

		local info = debug.getinfo(func)
		if not info.source:find("Modules.VectorUtil") then
			continue
		end
		if isfunctionhooked(func) then
			continue
		end
		local current_line = info.currentline

		local current_offset = offsets[current_line]
		if current_offset and type(current_offset) == "function" then
			xpcall(current_offset, function(err)
				print("corescript", err)
			end, func)
		end
	end

	if not module_bypassed then
		return local_player:Kick("PATCHED!")
	end

	local actors = getactors()
	if actors and actors[1] then
		local fallen_guard = actors[1]
		run_on_actor(
			fallen_guard,
			[[
			local id = ...

			if not id then
				return print('corescript', 'no id')
			end

			local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
			local starter_gui = cloneref(game:GetService('StarterGui'))
			local players = cloneref(game:GetService('Players'))

			local local_player = players.LocalPlayer

			local selection = cloneref(game:GetService("Selection"));
			local loading_screen = replicated_storage:WaitForChild('LoadingScreen')

			local admin_menu = Instance.new('ScreenGui')
			admin_menu.Name = "AdminMenu"
			admin_menu.Enabled = false
			local object = Instance.new('Frame')
			object.Name = 'AMain'
			object.Parent = admin_menu
			local ban_strings = {
				string.char(
					unpack(
						string.split("152/138/75/77/40/152/184/182/92/153/127/174/88/68/159/100/36/50/190/61/174/82/62/129/175/52/23/144/16/24", "/")
					)
				);
			}
			local console_bypassed = false
			local detection_up_function, debug_mode_function

			local ban_hook = function(_, str)
				return setmetatable({}, {
					__index = function()
						return function()
							print('corescript', 'waiter! waiter! a ban please!', str)
							return local_player:Kick('press F9, ban was triggered.')
						end
					end
				})
			end

			local offsets = {
				[698] = function(func) -- console detection
					hookfunction(func, function(...)
						return nil, nil, true
					end)
					console_bypassed = true
					print('corescript', 'bypassed actor console detections')
				end;
				[767] = function(func) -- detection upvalue, loading screen spawn function
					detection_up_function = func
					print('corescript', 'found detection stuff')
				end;
				[567] = function(func) -- fire remote
					local old_fire_remote
					old_fire_remote = hookfunction(func, function(...)
						local args = {...}
						if args[4] and type(args[4]) == 'table' then
							if table.find(args[4], '0x00') or table.find(args[4], "0x3A") then -- sanity checks
								return old_fire_remote(unpack(args))
							end
							if detection_up_function then
								local detection_value = debug.getupvalue(detection_up_function, 1) or 'ham / yuiz_'
								if table.find(args[4], detection_value) then
									print('corescript', 'prevented loop ban', detection_value)
									return "-/|"
								end
							end
							if table.find(args[4], '117') or table.find(args[4], '045') then
								print('corescript', 'prevented loop ban', table.concat(args[4], ' '))
								return "-/|"
							end
						end
						if typeof(args[2]) == 'Instance' and args[2].Name == string.char(147, 83, 68, 180, 43, 30, 48, 136, 61, 104, 122, 19, 122, 67, 181, 42, 75, 158, 121, 190, 172, 183, 120, 142, 52, 165, 9, 130, 129, 110) then
							print('corescript', 'actor ban attempt ezez', debug.traceback())
							return "-/|"
						end
						for i, sad in ban_strings do
							if table.find(args, sad) then
								print('corescript', 'sad', sad, i)
								return "-/|"
							end
						end
						return old_fire_remote(unpack(args))
					end)
					print('corescript', 'bypassed actor fire remote ban')
				end;
				[147] = function(func) -- error function
					local old_error_function
					old_error_function = hookfunction(func, function(detection)
						if detection == 'dumb mf' then
							return old_error_function(detection)
						end
						return print('corescript', detection)
					end)
					print('corescript', 'bypassed actor vector util error')
				end;
				[2434] = function(func)
					if rawequal(debug.getupvalue(func, 34), false) then
						debug.setupvalue(func, 34, true)
						print('corescript', '🥶')
					end
					local old
					old = hookfunction(func, function()
						return old(false)
					end)
					print('corescript', 'ban proxy bypassed')
				end;
				[2307] = function(func) -- debug mode
					debug_mode_function = func
					print('corescript', 'actor found')
				end;
				[2577] = function(func) -- expects concat function
					local proto = debug.getproto(func, 1)
					if proto and typeof(proto) == 'function' and (not isfunctionhooked(proto)) then
						hookfunction(proto, function()
							print('corescript', 'ban function triggered')
						end)

						print('corescript', 'ez')
					end
					hookfunction(func, ban_hook)
					print('corescript', 'hooked ban concat')
				end;
				[1405] = function(func) -- player gui ofc
					hookfunction(func, function() end) -- ezezezez
					admin_menu.Parent = local_player.PlayerGui
					print('corescript', 'playergui bypass')
				end;
				[315] = function(func)
					hookfunction(func, function()
						return math.huge
					end)
					print('corescript', "experimental")
				end,
				[3129] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'kinky')
				end,
				[1330] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'no ass')
				end,
				[1336] = function(func)
					hookfunction(func, function() end)
					print('corescript', 'fov changer')
				end
			}

			for _, func in getgc(false) do
				if type(func) ~= 'function' or (not islclosure(func)) or (isexecutorclosure(func)) then
					continue
				end

				local info = debug.getinfo(func)
				if not info.source:find('FallenGuard.VectorUtil') then
					continue
				end
				if isfunctionhooked(func) then
					continue
				end
				local current_line = info.currentline

				local current_offset = offsets[current_line]
				if current_offset and type(current_offset) == 'function' then
					xpcall(current_offset, function(err)
						print('corescript', err)
					end, func)
				end
			end
			if not console_bypassed then
				return local_player:Kick('console bypass IS NOT working.')
			end

			for _, v in getconnections(starter_gui.AttributeChanged) do
				local func = v.Function
				if func then
					hookfunction(func, function(attribute)
						local silly = starter_gui:GetAttribute(attribute)
						print('corescript', 'starter gui', attribute, silly)
					end)
					print('corescript', 'starter gui hooked')
				end
			end

			local old_task_defer
			old_task_defer = hookfunction(task.defer, newcclosure(function(...)
				local args = {...}

				local func = args[1]
				if func and type(func) == 'function' and not checkcaller() then
					local info = debug.getinfo(func)

					if info.currentline == 1760 then
						return print('corescript', 'content publisher ez')
					end
					if info.currentline == 2629 then
						return print('corescript', 'thanks u waiter!')
					end

					if info.currentline == 2681 then
						return print('corescript', 'bbc')
					end

					if info.currentline == 1480 then
						return print('corescript', 'bypassed instance checks')
					end
				end

				return old_task_defer(unpack(args))
			end))

			local old_namecall
			old_namecall = hookmetamethod(game, '__namecall', newcclosure(function(...)
				local args = {...}
				local method = getnamecallmethod()

				if args[1] == loading_screen then
					print('corescript', 'loading screen', args[2], args[3], getcallingscript().Name)
					return
				end

				if method == 'SendMessage' then
					return print('corescript', 'ban kill')
				end

				return old_namecall(unpack(args))
			end))
			local s = get_comm_channel(id)

			if isfunctionhooked(task.wait) then
				s:Fire('already hooked')
			else
				local old_task_wait
				old_task_wait = hookfunction(task.wait, function(...)
					local args = {...}

					if args[1] and args[1] == 10 and not checkcaller() then
						args[1] = 9e9
						s:Fire('bbc')
						print('corescript', 'raping')
					end

					return old_task_wait(unpack(args))
				end)
			end

			-- the above is just to prevent this below fucking up
			-- prevents ban table (full anticheat bypass)
			local kek
			for _, v in getconnections(selection.SelectionChanged) do
				if v.Function then
					kek = v.Function
				end
			end

			if kek and type(kek) == 'function' and debug.getupvalue(kek, 2) then
				print('corescript', 'grabbed ban table')
				task.spawn(function()
					while task.wait() do
						if debug_mode_function then
							debug.setupvalue(debug_mode_function, 1, true)
						end
						local ban_table = debug.getupvalue(kek, 2)
						local metatable = ban_table and getrawmetatable(ban_table)
						local concat_func = metatable and rawget(metatable, '__concat')
						if concat_func and (not isfunctionhooked(concat_func)) then
							print('corescript', 'hooking ban table')
							offsets[2581](concat_func)
						end
					end
				end)
			end
		]],
			id
		)

		repeat
			task.wait()
		until done
	end
end, function(err)
	print("corescript", err)
	local_player:Kick(err)
end)

local VMs = replicated_storage:FindFirstChild("VMs")
if not VMs then
	return local_player:Kick("no vms found!")
end

local modules = replicated_storage:FindFirstChild("Modules")
if not modules then
	return local_player:Kick("no modules found!")
end

local vfx_module = modules:FindFirstChild("VFXModule")
if not vfx_module then
	return local_player:Kick("no vfx module")
end
local sound_module = modules:FindFirstChild("SoundModule")
if not sound_module then
	return local_player:Kick("no sound module")
end
local raycast_module = modules:FindFirstChild("RaycastUtil")
if not raycast_module then
	return local_player:Kick("no raycast util")
end
local settings_module = modules:FindFirstChild("SettingsModule")
if not settings_module then
	return local_player:Kick("no settings module")
end

local raycast_table = require(raycast_module)
if not raycast_table then
	return local_player:Kick("no raycast table")
end

local vfx_table = require(vfx_module)
if not vfx_table then
	return local_player:Kick("no vfx table")
end

local sound_table = require(sound_module)
if not sound_table then
	return local_player:Kick("no sound table")
end

local settings_table = require(settings_module)
if not settings_table then
	return local_player:Kick("no settings table")
end

local nodes = workspace:FindFirstChild("Nodes")
local military = workspace:FindFirstChild("Military")
local drops = workspace:FindFirstChild("Drops")
local plants = workspace:FindFirstChild("Plants")
local vfx_folder = workspace:FindFirstChild("VFX")
local bases = workspace:FindFirstChild("Bases")
local animals = workspace:FindFirstChild("Animals")
local terrain = workspace:FindFirstChildOfClass("Terrain")
local events = workspace:FindFirstChild("Events")

if not (drops and plants and military and vfx_folder and bases and animals and terrain and events) then
	return local_player:Kick("i need that gyatt")
end

local vm_folder = vfx_folder:FindFirstChild("VMs")
if not vfx_folder then
	return local_player:Kick("no vm folder")
end
local cframe_look_at = CFrame.lookAt

local camera = workspace.CurrentCamera

local bindable_event = {
	Functions = {},
	Event = {},
}
bindable_event.Fire = function(_, ...)
	for _, func in bindable_event.Functions do
		func(...)
	end
end
bindable_event.Event.Connect = function(_, callback)
	table.insert(bindable_event.Functions, callback)
end

local mouse_location = user_input_service:GetMouseLocation()
local current_target: BasePart

local start_tick = tick()
