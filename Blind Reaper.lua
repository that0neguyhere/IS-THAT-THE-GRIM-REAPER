game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Arm1'
game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Arm2'
game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Leg1'
game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Leg2'
game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Torso1'
game:GetService("Players").LocalPlayer.Character.RectangleFace.Name = 'Torso2'

wait(3)
local v3_net, v3_808 = Vector3.new(0, 25.1, 0), Vector3.new(8, 0, 8)
		local function getNetlessVelocity(realPartVelocity)
			local mag = realPartVelocity.Magnitude
			if mag > 1 then
				local unit = realPartVelocity.Unit
				if (unit.Y > 0.25) or (unit.Y < -0.75) then
					return unit * (25.1 / unit.Y)
				end
			end 
			return v3_net + realPartVelocity * v3_808
		end
		local simradius = "ssr" --simulation radius (net bypass) method
--simulation radius (net bypass) method
--"shp" - sethiddenproperty
--"ssr" - setsimulationradius
--false - disable
local antiragdoll = true --removes hingeConstraints and ballSocketConstraints from your character
local newanimate = true --disables the animate script and enables after reanimation
local discharscripts = true --disables all localScripts parented to your character before reanimation
local R15toR6 = true --tries to convert your character to r6 if its r15
local hatcollide = true --makes hats cancollide (only method 0)
local humState16 = true --enables collisions for limbs before the humanoid dies (using hum:ChangeState)
local addtools = true --puts all tools from backpack to character and lets you hold them after reanimation
local hedafterneck = false --disable aligns for head and enable after neck is removed
local loadtime = game:GetService("Players").RespawnTime + 0.5 --anti respawn delay
local method = 3 --reanimation method
--methods:
--0 - breakJoints (takes [loadtime] seconds to laod)
--1 - limbs
--2 - limbs + anti respawn
--3 - limbs + breakJoints after [loadtime] seconds
--4 - remove humanoid + breakJoints
--5 - remove humanoid + limbs
local alignmode = 2 --AlignPosition mode
--modes:
--1 - AlignPosition rigidity enabled true
--2 - 2 AlignPositions rigidity enabled both true and false
--3 - AlignPosition rigidity enabled false

healthHide = healthHide and ((method == 0) or (method == 2) or (method == 000)) and gp(c, "Head", "BasePart")

local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local stepped = rs.Stepped
local heartbeat = rs.Heartbeat
local renderstepped = rs.RenderStepped
local sg = game:GetService("StarterGui")
local ws = game:GetService("Workspace")
local cf = CFrame.new
local v3 = Vector3.new
local v3_0 = v3(0, 0, 0)
local inf = math.huge

local c = lp.Character

if not (c and c.Parent) then
	return
end

c.Destroying:Connect(function()
	c = nil
end)

local function gp(parent, name, className)
	if typeof(parent) == "Instance" then
		for i, v in pairs(parent:GetChildren()) do
			if (v.Name == name) and v:IsA(className) then
				return v
			end
		end
	end
	return nil
end

local function align(Part0, Part1)
	Part0.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)

	local att0 = Instance.new("Attachment", Part0)
	att0.Orientation = v3_0
	att0.Position = v3_0
	att0.Name = "att0_" .. Part0.Name
	local att1 = Instance.new("Attachment", Part1)
	att1.Orientation = v3_0
	att1.Position = v3_0
	att1.Name = "att1_" .. Part1.Name

	if (alignmode == 1) or (alignmode == 2) then
		local ape = Instance.new("AlignPosition", att0)
		ape.ApplyAtCenterOfMass = false
		ape.MaxForce = inf
		ape.MaxVelocity = inf
		ape.ReactionForceEnabled = false
		ape.Responsiveness = 200
		ape.Attachment1 = att1
		ape.Attachment0 = att0
		ape.Name = "AlignPositionRtrue"
		ape.RigidityEnabled = true
	end

	if (alignmode == 2) or (alignmode == 3) then
		local apd = Instance.new("AlignPosition", att0)
		apd.ApplyAtCenterOfMass = false
		apd.MaxForce = inf
		apd.MaxVelocity = inf
		apd.ReactionForceEnabled = false
		apd.Responsiveness = 200
		apd.Attachment1 = att1
		apd.Attachment0 = att0
		apd.Name = "AlignPositionRfalse"
		apd.RigidityEnabled = false
	end

	local ao = Instance.new("AlignOrientation", att0)
	ao.MaxAngularVelocity = inf
	ao.MaxTorque = inf
	ao.PrimaryAxisOnly = false
	ao.ReactionTorqueEnabled = false
	ao.Responsiveness = 200
	ao.Attachment1 = att1
	ao.Attachment0 = att0
	ao.RigidityEnabled = false

	if type(getNetlessVelocity) == "function" then
	    local realVelocity = v3_0
        local steppedcon = stepped:Connect(function()
            Part0.Velocity = realVelocity
        end)
        local heartbeatcon = heartbeat:Connect(function()
            realVelocity = Part0.Velocity
            Part0.Velocity = getNetlessVelocity(realVelocity)
        end)
        Part0.Destroying:Connect(function()
            Part0 = nil
            steppedcon:Disconnect()
            heartbeatcon:Disconnect()
        end)
    end
end

local function respawnrequest()
	local ccfr = ws.CurrentCamera.CFrame
	local c = lp.Character
	lp.Character = nil
	lp.Character = c
	local con = nil
	con = ws.CurrentCamera.Changed:Connect(function(prop)
	    if (prop ~= "Parent") and (prop ~= "CFrame") then
	        return
	    end
	    ws.CurrentCamera.CFrame = ccfr
	    con:Disconnect()
    end)
end

local destroyhum = (method == 4) or (method == 5)
local breakjoints = (method == 0) or (method == 4)
local antirespawn = (method == 0) or (method == 2) or (method == 3)

hatcollide = hatcollide and (method == 0)

addtools = addtools and gp(lp, "Backpack", "Backpack")

local fenv = getfenv()
local shp = fenv.sethiddenproperty or fenv.set_hidden_property or fenv.set_hidden_prop or fenv.sethiddenprop
local ssr = fenv.setsimulationradius or fenv.set_simulation_radius or fenv.set_sim_radius or fenv.setsimradius or fenv.set_simulation_rad or fenv.setsimulationrad

if shp and (simradius == "shp") then
	spawn(function()
		while c and heartbeat:Wait() do
			shp(lp, "SimulationRadius", inf)
		end
	end)
elseif ssr and (simradius == "ssr") then
	spawn(function()
		while c and heartbeat:Wait() do
			ssr(inf)
		end
	end)
end

antiragdoll = antiragdoll and function(v)
	if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
		v.Parent = nil
	end
end

if antiragdoll then
	for i, v in pairs(c:GetDescendants()) do
		antiragdoll(v)
	end
	c.DescendantAdded:Connect(antiragdoll)
end

if antirespawn then
	respawnrequest()
end

if method == 0 then
	wait(loadtime)
	if not c then
		return
	end
end

if discharscripts then
	for i, v in pairs(c:GetChildren()) do
		if v:IsA("LocalScript") then
			v.Disabled = true
		end
	end
elseif newanimate then
	local animate = gp(c, "Animate", "LocalScript")
	if animate and (not animate.Disabled) then
		animate.Disabled = true
	else
		newanimate = false
	end
end

if addtools then
	for i, v in pairs(addtools:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = c
		end
	end
end

pcall(function()
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local OLDscripts = {}

for i, v in pairs(c:GetDescendants()) do
	if v.ClassName == "Script" then
		table.insert(OLDscripts, v)
	end
end

local scriptNames = {}

for i, v in pairs(c:GetDescendants()) do
	if v:IsA("BasePart") then
		local newName = tostring(i)
		local exists = true
		while exists do
			exists = false
			for i, v in pairs(OLDscripts) do
				if v.Name == newName then
					exists = true
				end
			end
			if exists then
				newName = newName .. "_"    
			end
		end
		table.insert(scriptNames, newName)
		Instance.new("Script", v).Name = newName
	end
end

c.Archivable = true
local hum = c:FindFirstChildOfClass("Humanoid")
if hum then
	for i, v in pairs(hum:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end
local cl = c:Clone()
if hum and humState16 then
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    if destroyhum then
        wait(1.6)
    end
end
if hum and hum.Parent and destroyhum then
    hum:Destroy()
end

if not c then
    return
end

local head = gp(c, "Head", "BasePart")
local torso = gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart")
local root = gp(c, "HumanoidRootPart", "BasePart")
if hatcollide and c:FindFirstChildOfClass("Accessory") then
    local anything = c:FindFirstChildOfClass("BodyColors") or gp(c, "Health", "Script")
    if not (torso and root and anything) then
        return
    end
    if shp then
        for i,v in pairs(c:GetChildren()) do
            if v:IsA("Accessory") then
                shp(v, "BackendAccoutrementState", 0)
            end 
        end
    end
    anything:Destroy()
end

for i, v in pairs(cl:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Transparency = 1
		v.Anchored = false
	end
end

local model = Instance.new("Model", c)
model.Name = model.ClassName

model.Destroying:Connect(function()
	model = nil
end)

for i, v in pairs(c:GetChildren()) do
	if v ~= model then
		if addtools and v:IsA("Tool") then
			for i1, v1 in pairs(v:GetDescendants()) do
				if v1 and v1.Parent and v1:IsA("BasePart") then
					local bv = Instance.new("BodyVelocity", v1)
					bv.Velocity = v3_0
					bv.MaxForce = v3(1000, 1000, 1000)
					bv.P = 1250
					bv.Name = "bv_" .. v.Name
				end
			end
		end
		v.Parent = model
	end
end

if breakjoints then
	model:BreakJoints()
else
	if head and torso then
		for i, v in pairs(model:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Snap") or v:IsA("Glue") or v:IsA("Motor") or v:IsA("Motor6D") then
				local save = false
				if (v.Part0 == torso) and (v.Part1 == head) then
					save = true
				end
				if (v.Part0 == head) and (v.Part1 == torso) then
					save = true
				end
				if save then
					if hedafterneck then
						hedafterneck = v
					end
				else
					v:Destroy()
				end
			end
		end
	end
	if method == 3 then
		spawn(function()
			wait(loadtime)
			if model then
				model:BreakJoints()
			end
		end)
	end
end

cl.Parent = c
for i, v in pairs(cl:GetChildren()) do
	v.Parent = c
end
cl:Destroy()

local modelDes = {}
for i, v in pairs(model:GetDescendants()) do
	if v:IsA("BasePart") then
		i = tostring(i)
		v.Destroying:Connect(function()
			modelDes[i] = nil
		end)
		modelDes[i] = v
	end
end
local modelcolcon = nil
local function modelcolf()
	if model then
		for i, v in pairs(modelDes) do
			v.CanCollide = false
		end
	else
		modelcolcon:Disconnect()
	end
end
modelcolcon = stepped:Connect(modelcolf)
modelcolf()

for i, scr in pairs(model:GetDescendants()) do
	if (scr.ClassName == "Script") and table.find(scriptNames, scr.Name) then
		local Part0 = scr.Parent
		if Part0:IsA("BasePart") then
			for i1, scr1 in pairs(c:GetDescendants()) do
				if (scr1.ClassName == "Script") and (scr1.Name == scr.Name) and (not scr1:IsDescendantOf(model)) then
					local Part1 = scr1.Parent
					if (Part1.ClassName == Part0.ClassName) and (Part1.Name == Part0.Name) then
						align(Part0, Part1)
						break
					end
				end
			end
		end
	end
end

if (typeof(hedafterneck) == "Instance") and head then
	local aligns = {}
	local con = nil
	con = hedafterneck.Changed:Connect(function(prop)
	    if (prop == "Parent") and not hedafterneck.Parent then
	        con:Disconnect()
    		for i, v in pairs(aligns) do
    			v.Enabled = true
    		end
		end
	end)
	for i, v in pairs(head:GetDescendants()) do
		if v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
			i = tostring(i)
			aligns[i] = v
			v.Destroying:Connect(function()
			    aligns[i] = nil
			end)
			v.Enabled = false
		end
	end
end

for i, v in pairs(c:GetDescendants()) do
	if v and v.Parent then
		if v.ClassName == "Script" then
			if table.find(scriptNames, v.Name) then
				v:Destroy()
			end
		elseif not v:IsDescendantOf(model) then
			if v:IsA("Decal") then
				v.Transparency = 1
			elseif v:IsA("ForceField") then
				v.Visible = false
			elseif v:IsA("Sound") then
				v.Playing = false
			elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
				v.Enabled = false
			end
		end
	end
end

if newanimate then
	local animate = gp(c, "Animate", "LocalScript")
	if animate then
		animate.Disabled = false
	end
end

if addtools then
	for i, v in pairs(c:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = addtools
		end
	end
end

local hum0 = model:FindFirstChildOfClass("Humanoid")
if hum0 then
    hum0.Destroying:Connect(function()
        hum0 = nil
    end)
end

local hum1 = c:FindFirstChildOfClass("Humanoid")
if hum1 then
    hum1.Destroying:Connect(function()
        hum1 = nil
    end)
end

if hum1 then
	ws.CurrentCamera.CameraSubject = hum1
	local camSubCon = nil
	local function camSubFunc()
		camSubCon:Disconnect()
		if c and hum1 then
			ws.CurrentCamera.CameraSubject = hum1
		end
	end
	camSubCon = renderstepped:Connect(camSubFunc)
	if hum0 then
		hum0.Changed:Connect(function(prop)
			if hum1 and (prop == "Jump") then
				hum1.Jump = hum0.Jump
			end
		end)
	else
		respawnrequest()
	end
end

local rb = Instance.new("BindableEvent", c)
rb.Event:Connect(function()
	rb:Destroy()
	sg:SetCore("ResetButtonCallback", true)
	if destroyhum then
		c:BreakJoints()
		return
	end
	if hum0 and (hum0.Health > 100) then
		model:BreakJoints()
		hum0.Health = 100
	end
	if antirespawn then
	    respawnrequest()
	end
end)
sg:SetCore("ResetButtonCallback", rb)

spawn(function()
	while c do
		if hum0 and hum1 then
			hum1.Jump = hum0.Jump
		end
		wait()
	end
	sg:SetCore("ResetButtonCallback", true)
end)

R15toR6 = R15toR6 and hum1 and (hum1.RigType == Enum.HumanoidRigType.R15)
if R15toR6 then
    local part = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "UpperTorso", "BasePart") or gp(c, "LowerTorso", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
	if part then
	    local cfr = part.CFrame
		local R6parts = { 
			head = {
				Name = "Head",
				Size = v3(2, 1, 1),
				R15 = {
					Head = 0
				}
			},
			torso = {
				Name = "Torso",
				Size = v3(2, 2, 1),
				R15 = {
					UpperTorso = 0.2,
					LowerTorso = -100
				}
			},
			root = {
				Name = "HumanoidRootPart",
				Size = v3(2, 2, 1),
				R15 = {
					HumanoidRootPart = 0
				}
			},
			leftArm = {
				Name = "Left Arm",
				Size = v3(1, 2, 1),
				R15 = {
					LeftHand = -0.73,
					LeftLowerArm = -0.2,
					LeftUpperArm = 0.4
				}
			},
			rightArm = {
				Name = "Right Arm",
				Size = v3(1, 2, 1),
				R15 = {
					RightHand = -0.73,
					RightLowerArm = -0.2,
					RightUpperArm = 0.4
				}
			},
			leftLeg = {
				Name = "Left Leg",
				Size = v3(1, 2, 1),
				R15 = {
					LeftFoot = -0.73,
					LeftLowerLeg = -0.15,
					LeftUpperLeg = 0.6
				}
			},
			rightLeg = {
				Name = "Right Leg",
				Size = v3(1, 2, 1),
				R15 = {
					RightFoot = -0.73,
					RightLowerLeg = -0.15,
					RightUpperLeg = 0.6
				}
			}
		}
		for i, v in pairs(c:GetChildren()) do
			if v:IsA("BasePart") then
				for i1, v1 in pairs(v:GetChildren()) do
					if v1:IsA("Motor6D") then
						v1.Part0 = nil
					end
				end
			end
		end
		part.Archivable = true
		for i, v in pairs(R6parts) do
			local part = part:Clone()
			part:ClearAllChildren()
			part.Name = v.Name
			part.Size = v.Size
			part.CFrame = cfr
			part.Anchored = false
			part.Transparency = 1
			part.CanCollide = false
			for i1, v1 in pairs(v.R15) do
				local R15part = gp(c, i1, "BasePart")
				local att = gp(R15part, "att1_" .. i1, "Attachment")
				if R15part then
					local weld = Instance.new("Weld", R15part)
					weld.Name = "Weld_" .. i1
					weld.Part0 = part
					weld.Part1 = R15part
					weld.C0 = cf(0, v1, 0)
					weld.C1 = cf(0, 0, 0)
					R15part.Massless = true
					R15part.Name = "R15_" .. i1
					R15part.Parent = part
					if att then
						att.Parent = part
						att.Position = v3(0, v1, 0)
					end
				end
			end
			part.Parent = c
			R6parts[i] = part
		end
		local R6joints = {
			neck = {
				Parent = R6parts.torso,
				Name = "Neck",
				Part0 = R6parts.torso,
				Part1 = R6parts.head,
				C0 = cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
				C1 = cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			},
			rootJoint = {
				Parent = R6parts.root,
				Name = "RootJoint" ,
				Part0 = R6parts.root,
				Part1 = R6parts.torso,
				C0 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
				C1 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			},
			rightShoulder = {
				Parent = R6parts.torso,
				Name = "Right Shoulder",
				Part0 = R6parts.torso,
				Part1 = R6parts.rightArm,
				C0 = cf(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				C1 = cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			},
			leftShoulder = {
				Parent = R6parts.torso,
				Name = "Left Shoulder",
				Part0 = R6parts.torso,
				Part1 = R6parts.leftArm,
				C0 = cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				C1 = cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
			},
			rightHip = {
				Parent = R6parts.torso,
				Name = "Right Hip",
				Part0 = R6parts.torso,
				Part1 = R6parts.rightLeg,
				C0 = cf(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				C1 = cf(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			},
			leftHip = {
				Parent = R6parts.torso,
				Name = "Left Hip" ,
				Part0 = R6parts.torso,
				Part1 = R6parts.leftLeg,
				C0 = cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				C1 = cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
			}
		}
		for i, v in pairs(R6joints) do
			local joint = Instance.new("Motor6D")
			for prop, val in pairs(v) do
				joint[prop] = val
			end
			R6joints[i] = joint
		end
		hum1.RigType = Enum.HumanoidRigType.R6
		hum1.HipHeight = 0
	end
end



--find rig joints

local function fakemotor()
    return {C0=cf(), C1=cf()}
end

local torso = gp(c, "Torso", "BasePart")
local root = gp(c, "HumanoidRootPart", "BasePart")

local neck = gp(torso, "Neck", "Motor6D")
neck = neck or fakemotor()

local rootJoint = gp(root, "RootJoint", "Motor6D")
rootJoint = rootJoint or fakemotor()

local leftShoulder = gp(torso, "Left Shoulder", "Motor6D")
leftShoulder = leftShoulder or fakemotor()

local rightShoulder = gp(torso, "Right Shoulder", "Motor6D")
rightShoulder = rightShoulder or fakemotor()

local leftHip = gp(torso, "Left Hip", "Motor6D")
leftHip = leftHip or fakemotor()

local rightHip = gp(torso, "Right Hip", "Motor6D")
rightHip = rightHip or fakemotor()

--120 fps

local fps = 0
local event = Instance.new("BindableEvent", c)
event.Name = "120 fps"
local floor = math.floor
fps = 1 / fps
local tf = 0
local con = nil
con = game:GetService("RunService").RenderStepped:Connect(function(s)
	if not c then
		con:Disconnect()
		return
	end
    --tf += s
	if tf >= fps then
		for i=1, floor(tf / fps) do
			event:Fire(c)
		end
		tf = 0
	end
end)
local event = event.Event

local hedrot = v3(0, 5, 0)

local uis = game:GetService("UserInputService")
local function isPressed(key)
    return (not uis:GetFocusedTextBox()) and uis:IsKeyDown(Enum.KeyCode[key])
end

local biggesthandle = nil

local mouse = lp:GetMouse()
local fling = false
mouse.Button1Down:Connect(function()
    fling = true
end)
mouse.Button1Up:Connect(function()
    fling = false
end)
local function doForSignal(signal, vel)
    spawn(function()
        while signal:Wait() and c and handle1 and biggesthandle do
            if fling and mouse.Target then
                biggesthandle.Position = mouse.Hit.Position
            end
            handle1.RotVelocity = vel
        end
    end)
end
doForSignal(stepped, v3(100, 100, 100))
doForSignal(renderstepped, v3(100, 100, 100))
doForSignal(heartbeat, v3(20000, 20000, 20000)) --https://web.roblox.com/catalog/63690008/Pal-Hair

local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local stepped = rs.Stepped
local heartbeat = rs.Heartbeat
local renderstepped = rs.RenderStepped
local sg = game:GetService("StarterGui")
local ws = game:GetService("Workspace")
local cf = CFrame.new
local v3 = Vector3.new
local v3_0 = Vector3.zero
local inf = math.huge

local cplayer = lp.Character

local v3 = Vector3.new

local function gp(parent, name, className)
    if typeof(parent) == "Instance" then
        for i, v in pairs(parent:GetChildren()) do
            if (v.Name == name) and v:IsA(className) then
                return v
            end
        end
    end
    return nil
end

local hat2 = gp(cplayer, "CylinderHead", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Head"]
att2.Position = Vector3.new(0, 0.1, 0)
att2.Rotation = Vector3.new(0, 0, 0)

local hat2 = gp(cplayer, "Torso1", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Torso"]
att2.Position = Vector3.new(0.4, -0, 0)
att2.Rotation = Vector3.new(0, 0, 0)

local hat2 = gp(cplayer, "Torso2", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Torso"]
att2.Position = Vector3.new(-0.4, -0, 0)
att2.Rotation = Vector3.new(0, 0, 0)


local hat2 = gp(cplayer, "Arm1", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Left Arm"]
att2.Position = Vector3.new(0.05, -0, 0)
att2.Rotation = Vector3.new(0, 0, 0)

local hat2 = gp(cplayer, "Arm2", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Right Arm"]
att2.Position = Vector3.new(-0.05, -0, 0)
att2.Rotation = Vector3.new(0, 0, 0) --LavanderHair

local hat2 = gp(cplayer, "Leg1", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Right Leg"]
att2.Position = Vector3.new(-0.05, 0, 0)
att2.Rotation = Vector3.new(0, 0, 0)

local hat2 = gp(cplayer, "Leg2", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Left Leg"]
att2.Position = Vector3.new(0.05, 0, 0)
att2.Rotation = Vector3.new(0, 0, 0)

 --end of myx reanim1!1!1!

local script = game:GetObjects("rbxassetid://13134428195")[1] --important stuff
script.Parent = game:GetService("Players").LocalPlayer


local Player = game:GetService("Players").LocalPlayer Mouse = Player:GetMouse() 
--local Mouse--,mouse,UserInputService,ContextActionService
do
	local CAS = {Actions={}}
	local Event = Instance.new("RemoteEvent")
	Event.Name = "UserInputEvent"
	Event.Parent = Player.Character
	local fakeEvent = function()
		local t = {_fakeEvent=true}
		t.Connect = function(self,f)self.Function=f end
		t.connect = t.Connect
		return t
	end
    local m = {Target=nil,Hit=CFrame.new(),KeyUp=fakeEvent(),KeyDown=fakeEvent(),Button1Up=fakeEvent(),Button1Down=fakeEvent()}
	local UIS = {InputBegan=fakeEvent(),InputEnded=fakeEvent()}
	function CAS:BindAction(name,fun,touch,...)
		CAS.Actions[name] = {Name=name,Function=fun,Keys={...}}
	end
	function CAS:UnbindAction(name)
		CAS.Actions[name] = nil
	end
	local function te(self,ev,...)
		local t = m[ev]
		if t and t._fakeEvent and t.Function then
			t.Function(...)
		end
	end
	m.TrigEvent = te
	UIS.TrigEvent = te
	Event.OnClientEvent:Connect(function(plr,io)
	    if plr~=Player then return end
		if io.isMouse then
			m.Target = io.Target
			m.Hit = io.Hit
		elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
	        if io.UserInputState == Enum.UserInputState.Begin then
				m:TrigEvent("Button1Down")
			else
				m:TrigEvent("Button1Up")
			end
		else
			for n,t in pairs(CAS.Actions) do
				for _,k in pairs(t.Keys) do
					if k==io.KeyCode then
						t.Function(t.Name,io.UserInputState,io)
					end
				end
			end
	        if io.UserInputState == Enum.UserInputState.Begin then
	            m:TrigEvent("KeyDown",io.KeyCode.Name:lower())
				UIS:TrigEvent("InputBegan",io,false)
			else
				m:TrigEvent("KeyUp",io.KeyCode.Name:lower())
				UIS:TrigEvent("InputEnded",io,false)
	        end
	    end
	end)
	--Mouse,mouse,UserInputService,ContextActionService = m,m,UIS,CAS
end

--BasicFunctions
local ins = Instance.new
local v3 = Vector3.new
local cf = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local huge = math.huge
local cos = math.cos
local sin = math.sin
local tan = math.tan
local abs = math.abs
local ray = Ray.new
local random = math.random
local ud = UDim.new
local ud2 = UDim2.new
local c3 = Color3.new
local rgb = Color3.fromRGB
local bc = BrickColor.new

--Services
local plrs = game:GetService("Players")
local tweens = game:GetService("TweenService")
local debrs = game:GetService("Debris")
local runservice = game:GetService("RunService")
 
--Variables
local plr = Player
local plrg = plr.PlayerGui
local char = plr.Character
local h = char.Head
local t = char.Torso
local ra = char["Right Arm"]
local la = char["Left Arm"]
local rl = char["Right Leg"]
local ll = char["Left Leg"]
local rut = char.HumanoidRootPart
local hum = char:FindFirstChildOfClass("Humanoid")
local nec = t.Neck
local rutj = rut.RootJoint
local rs = t["Right Shoulder"]
local ls = t["Left Shoulder"]
local rh = t["Right Hip"]
local lh = t["Left Hip"]

necc0,necc1=cf(0,t.Size.Y/2,0),cf(0,-h.Size.Y/2,0)
rutjc0,rutjc1=cf(0,0,0),cf(0,0,0)
rsc0,rsc1=cf(t.Size.X/2,t.Size.Y/4,0),cf(-ra.Size.X/2,ra.Size.Y/4,0)
lsc0,lsc1=cf(-t.Size.X/2,t.Size.Y/4,0),cf(la.Size.X/2,la.Size.Y/4,0)
rhc0,rhc1=cf(t.Size.X/4,-t.Size.Y/2,0),cf(0,rl.Size.Y/2,0)
lhc0,lhc1=cf(-t.Size.X/4,-t.Size.Y/2,0),cf(0,ll.Size.Y/2,0)
script.Client.Disabled = false
local muted = false
local using = false

local anim = "idle"
local asset = "rbxassetid://"

local change = 1
local sine = 0

local combo = 1

local timePos = 0
local staticTimePos = 0

local ws = 25
local jp = 65

--
local stepsounds = {
Grass = asset.."1201103066",
Sand = asset.."1436385526",
Plastic = asset.."1569994049",
Stone = asset.."507863857", --379398649
Wood = asset.."1201103959",
Pebble = asset.."1201103211",
Ice = asset.."265653271",
Glass = asset.."145180170",
Metal = asset.."379482691"
}

local directions = {In = Enum.EasingDirection.In,
    Out = Enum.EasingDirection.Out,
    InOut = Enum.EasingDirection.InOut
}

local styles = {Linear = Enum.EasingStyle.Linear,
    Back = Enum.EasingStyle.Back,
    Bounce = Enum.EasingStyle.Bounce,
    Sine = Enum.EasingStyle.Sine,
    Quad = Enum.EasingStyle.Quad,
    Elastic = Enum.EasingStyle.Elastic,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint
}

local swings = {
	2490619022,
	2490619317
}

local stepped = runservice.Heartbeat

--Removing joints/Animations
if char:FindFirstChild("Animate") then
	char.Animate:Destroy()
end

if hum:FindFirstChildOfClass("Animator") then
	char.Humanoid.Animator:Destroy()
end

hum.MaxHealth = 25000
hum.Health = hum.MaxHealth

nec.Parent = nil
rutj.Parent = nil
rs.Parent = nil
ls.Parent = nil
rh.Parent = nil
lh.Parent = nil

--Joints
local nec = ins("Motor6D",t) nec.Name = "Neck" nec.Part0 = t nec.Part1 = h
local rutj = ins("Motor6D",rut) rutj.Name = "RootJoint" rutj.Part0 = t rutj.Part1 = rut
local rs = ins("Motor6D",t) rs.Name = "Right Shoulder" rs.Part0 = t rs.Part1 = ra
local ls = ins("Motor6D",t) ls.Name = "Left Shoulder" ls.Part0 = t ls.Part1 = la
local rh = ins("Motor6D",t) rh.Name = "Right Hip" rh.Part0 = t rh.Part1 = rl
local lh = ins("Motor6D",t) lh.Name = "Left Hip" lh.Part0 = t lh.Part1 = ll

--Setting CFrames
nec.C1 = necc1
nec.C0 = necc0
rs.C1 = rsc1
rs.C0 = rsc0
ls.C1 = lsc1
ls.C0 = lsc0
rh.C1 = rhc1
rh.C0 = rhc0
lh.C1 = lhc1
lh.C0 = lhc0
rutj.C1 = rutjc1
rutj.C0 = rutjc0

--Functions1
function createWeld(p1,p2,c0,c1)
	c0 = c0 or cf(0,0,0)
	c1 = c1 or cf(0,0,0)
	local weld = ins("Motor6D",p1)
	weld.Part0 = p1
	weld.Part1 = p2
	weld.C0 = c0
	weld.C1 = c1
	return weld
end

--Adds
local damageBil = script.UIs.SPDamageUI

local scythe = script.Models.Scythe
scythe.Parent = char
--scythe.Transparency = 1


local handle = scythe.Handle
local blade = scythe.NeonBlade
blade.Transparency = 1
--Handle.Transparency = 1

game:GetService("Players").LocalPlayer.Character["DemonLordAxe"].Handle.att1_Handle.Parent = handle
handle.att1_Handle.Rotation = Vector3.new(-65,0,0)
handle.att1_Handle.Position = Vector3.new(0,2.5,-0.8) --PlaneModel

local handleWeld = createWeld(ra,handle,cf(0,-1,0) * angles(rad(-90),rad(0),rad(0)))

local shadow = ins("Model",char)
shadow.Name = "Shadow"

local ff = ins("ForceField",char)
ff.Visible = false

local effects = ins("Model",char)
effects.Name = "Effects"

local theme = ins("Sound",t)
theme.Volume = 1.5
theme.SoundId = asset..1493059596
theme.Looped = true
theme:Play()

local static = ins("Sound",blade)
static.Volume = 1
static.SoundId = asset..1080752200
static.Looped = true
static:Play()

function createShadow(p,off,trans)
	if trans >1 then
		return
	end
	local pa = ins("Part",shadow)
	pa.Size = v3(.1*p.Size.x,.1*p.Size.y,.1*p.Size.z)
	pa.Material = "Plastic"
	pa.CanCollide = false
	pa.Locked = true
	pa.Color = c3(0,0,0)
	pa.Transparency = trans
	pa.Massless = true
	pa.Name = "Shadow"
	local mesh = ins("SpecialMesh",pa)
	mesh.Scale = v3(1.255,1.265/2,1.255) * 10
	mesh.Offset = v3(0,off,0)
	local weld = createWeld(p,pa,cf(0,0,0),cf(0,0,0))
	return pa
end

local off = .325*h.Size.y
for i = .325*h.Size.y,-.15*h.Size.y,-.0045*h.Size.y do
	local e = createShadow(h,off,1 - i*2.75)
	off = off -.0075*h.Size.y
end

local shaker = script.DistShaker:Clone()

--Functions2

function remove(instance,time)
	time = time or 0
	game:GetService("Debris"):AddItem(instance,time)
end

function swait()
	game:GetService("RunService").Stepped:Wait()
end

function rayc(spos,direc,ignore,dist)
    local rai = ray(spos,direc.Unit * dist)
    local rhit,rpos,rrot = workspace:FindPartOnRayWithIgnoreList(rai,ignore,false,false)
    return rhit,rpos,rrot
end

function sound(id,vol,pitch,parent,maxdist)
	local mdist = 30 or maxdist
	local newsound = Instance.new("Sound",parent)
	newsound.Volume = vol
	newsound.SoundId = "rbxassetid://"..id
	newsound.Pitch = pitch
	newsound:Play()
	coroutine.resume(coroutine.create(function()
		wait(.1)
		remove(newsound,newsound.TimeLength/newsound.Pitch)
	end))
	return newsound
end

function placesoundpart(rcf,id,vol,pitch,maxdist)
	pcall(function()
		local mdist = 30 or maxdist
		local spart = ins("Part",effects)
		spart.Anchored = true
		spart.CanCollide = false
		spart.Locked = true
		spart.Transparency = 1
		spart.CFrame = rcf
		local ssound = sound(id,vol,pitch,spart,mdist)
		remove(spart,ssound.TimeLength/ssound.Pitch)
	end)
end

local tlerp = function(part,tablee,leinght,easingstyle,easingdirec)
    local info = TweenInfo.new(
    leinght,
    easingstyle,
    easingdirec,
    0,
    false,
    0
    )
    local lerp = tweens:Create(part,info,tablee)
    lerp:Play()
end

local Effects = {
	Ring = function(pos,color,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local ring = script.Effects.Ring:Clone()
		ring.Size = sSize
		ring.Transparency = sTrans
		ring.CFrame = pos
		ring.Color = color
		ring.Parent = effects
		remove(ring,time)
		tlerp(ring,{Size = eSize,Transparency = eTrans},time,styles[style],directions.Out)
	end,
	SpinningRing = function(pos,color,rotation,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local ring = script.Effects.Ring:Clone()
		ring.Size = sSize
		ring.Transparency = sTrans
		ring.CFrame = pos
		ring.Color = color
		ring.Parent = effects
		remove(ring,time)
		tlerp(ring,{Size = eSize,Transparency = eTrans},time,styles[style],directions.Out)
		coroutine.wrap(function()
			repeat
				ring.CFrame = ring.CFrame * rotation
				wait(1/30)
			until not ring.Parent
		end)()
	end,
	Sphere = function(pos,color,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local sphere = ins("Part")
		sphere.Shape = "Ball"
		sphere.Size = v3(sSize,sSize,sSize)
		sphere.Transparency = sTrans
		sphere.CFrame = pos
		sphere.Color = color
		sphere.Parent = effects
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Locked = true
		sphere.Material = "Neon"
		remove(sphere,time)
		tlerp(sphere,{Size = v3(eSize,eSize,eSize),Transparency = eTrans},time,styles[style],directions.Out)
		return sphere
	end,
	Beam = function(pos,color,sLength,eLength,sThickness,eThickness,sTrans,eTrans,time,style)
		style = style or "Linear"
		local sphere = ins("Part")
		sphere.Shape = "Block"
		sphere.Size = v3(sThickness,sLength,sThickness)
		sphere.Transparency = sTrans
		sphere.CFrame = pos
		sphere.Color = color
		sphere.Parent = effects
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Locked = true
		sphere.Material = "Neon"
		ins("CylinderMesh",sphere)
		remove(sphere,time)
		tlerp(sphere,{Size = v3(eThickness,eLength,eThickness),Transparency = eTrans},time,styles[style],directions.Out)
	end,
	SpinningBlock = function(pos,color,sSize,eSize,sTrans,eTrans,cfRotation,time,style)
		style = style or "Linear"
		local part = ins("Part")
		part.Size = v3(sSize,sSize,sSize)
		part.Transparency = sTrans
		part.CFrame = pos
		part.Color = color
		part.Parent = effects
		part.Anchored = true
		part.CanCollide = false
		part.Locked = true
		part.Material = "Neon"
		remove(part,time)
		tlerp(part,{Size = v3(eSize,eSize,eSize),Transparency = eTrans},time,styles[style],directions.Out)
		coroutine.wrap(function()
			repeat
				part.CFrame = part.CFrame * cfRotation
				wait(1/30)
			until not part.Parent
		end)()
	end,
	CustomSphere = function(pos,endPos,color,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local sphere = ins("Part")
		sphere.Size = sSize
		sphere.Transparency = sTrans
		sphere.CFrame = pos
		sphere.Color = color
		sphere.Parent = effects
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Locked = true
		sphere.Material = "Neon"
		
		local mesh = ins("SpecialMesh",sphere)
		mesh.MeshType = "Sphere"
		
		remove(sphere,time)
		tlerp(sphere,{Size = eSize,Transparency = eTrans,CFrame = endPos},time,styles[style],directions.Out)
	end,
	CustomSphereBoomerang = function(pos,endPos,color,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local sphere = ins("Part")
		sphere.Size = sSize
		sphere.Transparency = sTrans
		sphere.CFrame = pos
		sphere.Color = color
		sphere.Parent = effects
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Locked = true
		sphere.Material = "Neon"
		
		local mesh = ins("SpecialMesh",sphere)
		mesh.MeshType = "Sphere"
		coroutine.wrap(function()
			remove(sphere,time)
			tlerp(sphere,{Transparency = eTrans},time * 1.25,styles[style],directions.Out)
			tlerp(sphere,{Size = eSize,CFrame = endPos},time/2,styles[style],directions.Out)
			wait(time/2)
			tlerp(sphere,{Size = sSize},time/2,styles[style],directions.Out)
		end)()
	end,
	CustomSphereBoomerangPlusPos = function(pos,endPos,color,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local sphere = ins("Part")
		sphere.Size = sSize
		sphere.Transparency = sTrans
		sphere.CFrame = pos
		sphere.Color = color
		sphere.Parent = effects
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Locked = true
		sphere.Material = "Neon"
		
		local mesh = ins("SpecialMesh",sphere)
		mesh.MeshType = "Sphere"
		coroutine.wrap(function()
			remove(sphere,time)
			tlerp(sphere,{Transparency = eTrans},time * 1.25,styles[style],directions.Out)
			tlerp(sphere,{Size = eSize,CFrame = endPos},time/2,styles[style],directions.Out)
			wait(time/2)
			tlerp(sphere,{Size = sSize,CFrame = pos},time/2,styles[style],directions.Out)
		end)()
	end,
	Wind = function(pos,color,rotation,sSize,eSize,sTrans,eTrans,time,style)
		style = style or "Linear"
		local ring = script.Effects.Wind:Clone()
		ring.Size = sSize
		ring.Transparency = sTrans
		ring.CFrame = pos
		ring.Color = color
		ring.Parent = effects
		remove(ring,time)
		tlerp(ring,{Size = eSize,Transparency = eTrans},time,styles[style],directions.Out)
		coroutine.wrap(function()
			repeat
				ring.CFrame = ring.CFrame * angles(rad(0),rad(rotation),rad(0))
				wait(1/30)
			until not ring.Parent
		end)()
	end,
	CreateCamShake = function(part,maxDist,intensivity,time)
		maxDist = maxDist or 20
		intensivity = intensivity or 1
		time = time or .1
		
		local bool = ins("BoolValue",part)
		bool.Name = "Shaking"
		bool.Value = true
		
		local MaxDist = ins("NumberValue",bool)
		MaxDist.Name = "MaxDist"
		MaxDist.Value = maxDist
		
		local Intensivity = ins("NumberValue",bool)
		Intensivity.Name = "Intensivity"
		Intensivity.Value = intensivity
		
		remove(bool,time)
	end,
	SoundEffect = function(sound,effect)
		ins(effect.."SoundEffect",sound)
	end
}

function death(whom)
	coroutine.wrap(function()
		if whom then
			whom:BreakJoints()
			remove(whom,7.5)
			local p = whom:FindFirstChildWhichIsA("BasePart")
			if p then
				placesoundpart(p.CFrame,1835350947,2.5,random(120,130)/100,5)
			end
			for i,v in pairs(whom:GetChildren()) do
				if v:IsA("BasePart") then
					coroutine.wrap(function()
						local clon = v:Clone()
						remove(v)
						clon.Anchored = true
						clon.Massless = true
						clon.CanCollide = false
						clon.Locked = true
						clon.Material = "Neon"
						clon.CFrame = v.CFrame
						clon.Transparency = 0
						clon:ClearAllChildren()
						clon.Color = bc("Royal purple").Color
						if clon.Name == "Head" then
							clon.Size = v3(clon.Size.Z,clon.Size.Z,clon.Size.Z)
						end
						clon.Parent = effects
						local ori = clon.Orientation
						local pos = clon.Position
						local time = random(15,30)/10 * (clon.Size).Magnitude
						local size = clon.Size
						coroutine.wrap(function()
							for i = 1,time,time/20 do
								local c = clon.CFrame * cf(random(-(clon.Size.X * 10),(clon.Size.X * 10))/20,random(-(clon.Size.Y * 10),(clon.Size.Y * 10))/20,random(-(clon.Size.Z * 10),(clon.Size.Z * 10))/20)
								Effects.CustomSphere(cf(c.Position),cf(c.Position) * cf(0,(-random(10,25)/10) * (clon.Size).Magnitude,0),bc("Royal purple").Color,v3(.15,.15,.15) * (clon.Size).Magnitude,v3(0,1,0) * (clon.Size).Magnitude,clon.Transparency,1,(random(15,30)/100) * (clon.Size).Magnitude,"Linear")
								wait(time/20)
							end
						end)()
						remove(clon,time)
						tlerp(clon,{Position = pos + v3(0,(random(5,15)/10) * (clon.Size).Magnitude,0),Orientation = ori + v3(random(-15,15),random(-15,15),random(-15,15)) * (clon.Size).Magnitude,Transparency = 1},time,styles.Quart,directions.Out)
						tlerp(clon,{Size = size * .5},time/2,styles.Back,directions.InOut)
						wait(time/2)
						tlerp(clon,{Size = size * 1.5},time/2,styles.Linear,directions.Out)
					end)()
				else
					remove(v)
				end
			end
		end
	end)()
end

function showDamage(pos,text,time,animTime)
	coroutine.wrap(function()
		pos = pos or t.CFrame
		text = text or "NULL"
		time = time or 2
		animTime = animTime or .5
	
		local clon = damageBil:Clone()
		local backG = clon.MainFrame
		local tex = backG.Damage
		local dFrame = clon.DropsFrame
		local drop = dFrame.Drop
		local p = ins("Part")
		
		p.Locked = true
		p.Massless = true
		p.CanCollide = false
		p.Anchored = true
		p.Size = v3(0,0,0)
		p.Transparency = 1
		p.CFrame = cf(pos.Position) * cf(random(-25,25)/10,random(-25,25)/10,random(-25,25)/10)
		p.Parent = effects
		
		clon.Parent = p
		drop.Parent = nil
		drop.Visible = true
		
		tex.Text = text
		
		remove(p,time + (animTime * 2))
		
		coroutine.wrap(function()
			repeat
				if p.Parent ~= effects then
					remove(p)
				end
				local dClon = drop:Clone()
				local dropPos = random(0,100)/100
				local dropSize = random(5,15)/100
				local growTime = random(15,25)/100
				local fallTime = random(7,15)/100
				local fallDelay = random(7,15)/100
				
				dClon.Parent = dFrame
				dClon.Position = ud2(dropPos,0,0,0)
				dClon.Size = ud2(0,0,0,0)
				dClon.ImageTransparency = 1
				dClon.Visible = true
				
				coroutine.wrap(function()
					remove(dClon,growTime + fallTime + fallDelay)
					tlerp(dClon,{ImageTransparency = backG.BackgroundTransparency,Size = ud2(dropSize,0,dropSize,0)},growTime,styles.Sine,directions.Out)
					wait(growTime + fallDelay)
					tlerp(dClon,{ImageTransparency = 1,Size = ud2(dropSize/2,0,dropSize * 12.5,0)},fallTime,styles.Sine,directions.Out)
				end)()
				
				wait(random(5,15)/100)
			until not p.Parent
		end)()
		
		tlerp(backG,{BackgroundTransparency = .5},animTime,styles.Back,directions.In)
		tlerp(tex,{TextTransparency = 0,TextStrokeTransparency = 0},animTime,styles.Back,directions.In)
		
		wait(time)
		
		tlerp(backG,{BackgroundTransparency = 1},animTime,styles.Back,directions.In)
		tlerp(tex,{TextTransparency = 1,TextStrokeTransparency = 1},animTime,styles.Back,directions.In)
	end)()
end

function damage(humanoid,Damage,knockback,knockbackStartPoint,knockbackTime,knockDelay,damageSound)
	Damage = Damage or random(0,0)
	knockback = knockback or 15
	knockbackStartPoint = knockbackStartPoint or v3(0,0,0)
	knockbackTime = knockbackTime or .15
	knockDelay = knockDelay or .2
	damageSound = damageSound or sound(851453784,1.5,random(90,110)/100,nil,1)
	if humanoid and not humanoid:FindFirstChild("Dbounce'd") and humanoid.Health > .01 then
		Damage = math.floor(Damage * (0 + humanoid.MaxHealth/0))
		local part = humanoid.Parent:FindFirstChildOfClass("Part") or humanoid.Parent:FindFirstChildOfClass("MeshPart")
		local deb = ins("BoolValue",humanoid)
		deb.Name = "Dbounce'd"
		remove(deb,knockDelay)
		if part then
			damageSound.Parent = part
			local knock = ins("BodyVelocity",part)
			knock.MaxForce = v3(huge,huge,huge)
			knock.Velocity = -cf(part.Position,knockbackStartPoint).LookVector * knockback
			showDamage(part.CFrame,"-"..Damage,random(0,0)/0,0)
			remove(knock,knockbackTime)
		end
		if humanoid.MaxHealth > 0 then
			sound(1753674936,5,1,t,5)
			death(humanoid.Parent)
		end
		humanoid.Health = humanoid.Health - Damage
		if humanoid.Health < .01 then
			death(humanoid.Parent)
			if part then
				placesoundpart(part,2801263,15,random(90,110)/100,1)
			end
		end
	end
end

--[[function magDamage(pos,partSize,size,Damage,knockback,knockbackTime,knockDelay,damageSound)
	local reg
	local knockPoint
	if typeof(pos) == "Vector3" then
		reg = Region3.new(pos - v3(size/2,size/2,size/2),pos + v3(size/2,size/2,size/2))
		knockPoint = pos
	elseif typeof(pos) == "Instance" then
		knockPoint = pos.Position
		if partSize then
			reg = Region3.new(pos.CFrame * cf(-pos.Size.X/2,-pos.Size.Y/2,-pos.Size.Y/2).Position,pos.CFrame * cf(pos.Size.X/2,pos.Size.Y/2,pos.Size.Z/2).Position)
		else
			reg = Region3.new(pos.Position - v3(size/2,size/2,size/2),pos.Position + v3(size/2,size/2,size/2))
		end
	end
	if reg then
		for i,v in pairs(workspace:FindPartsInRegion3WithIgnoreList(reg,{char},0)) do
			local humm = v.Parent:FindFirstChildOfClass("Humanoid")
			if humm then
				damage(humm,Damage,knockback,knockPoint,knockbackTime,knockDelay,damageSound)
			end
		end
	end
end]]

function swing1()
	using = true
	local oldWS = ws
	local oldJP = jp
	ws = 4
	jp = 45
	local add = -.035
	local alpha = .5
	sound(swings[random(1,#swings)],2.5,random(60,80)/100,ra,1)
	for i = 0,1,.075 do
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-5),rad(35),rad(0)),alpha)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,.1,-.1) * angles(rad(-5),rad(45),rad(-5)),alpha)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,-.15,.25) * angles(rad(205),rad(25),rad(0)) * angles(rad(-5),rad(0),rad(15)),alpha)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(.075,-.15,.15) * angles(rad(15),rad(-25),rad(-7.5)),alpha)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(2.5),rad(-5),rad(2.5)),alpha)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,.05,-.05) * angles(rad(-20),rad(15),rad(-5)),alpha)
		handleWeld.C0 = handleWeld.C0:Lerp(cf(0,-1,0) * angles(rad(-75),rad(10),rad(0)),alpha)
		alpha = alpha + add
		swait()
	end
	alpha = .25
	add = .15
	for i = 0,1,.125 do
		local s = sound(566593606,1.5,random(85,115)/100,nil,2.5)
		s.TimePosition = .075
		--magDamage(blade,false,10,random(15,25),random(20,40),.1,.35,s)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(2.5),rad(-30),rad(0)),alpha)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,.125,.25) * angles(rad(5),rad(-45),rad(5)),alpha)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,-.25,-.35) * angles(rad(35),rad(-50),rad(0)) * angles(rad(0),rad(0),rad(-7.5)),alpha)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(.1,-.2,.1) * angles(rad(-15),rad(15),rad(-5)),alpha)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.05,-.05) * angles(rad(-12.5),rad(-10),rad(2.5)),alpha)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(5),rad(5),rad(2.5)),alpha)
		handleWeld.C0 = handleWeld.C0:Lerp(cf(0,-1,0) * angles(rad(-110),rad(20),rad(0)),alpha)
		alpha = alpha + add
		if alpha >1 then
			add = -math.abs(add)
		end
		swait()
	end
	ws = oldWS
	jp = oldJP
	using = false
end

function swing2()
	using = true
	local oldWS = ws
	local oldJP = jp
	ws = 4
	jp = 45
	local add = -.035
	local alpha = .5
	sound(swings[random(1,#swings)],2.5,random(60,80)/100,ra,1)
	for i = 0,1,.075 do
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(0),rad(-60),rad(0)),alpha)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(2.5),rad(-60),rad(-7.5)),alpha)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,-.5) * angles(rad(85),rad(95),rad(0)) * angles(rad(20),rad(0),rad(0)),alpha)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,-.2,.15) * angles(rad(-10),rad(10),rad(-5)),alpha)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,-.1,0) * angles(rad(-15),rad(-5),rad(-5)),alpha)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,-.1,-.15) * angles(rad(20),rad(5),rad(-10)),alpha)
		handleWeld.C0 = handleWeld.C0:Lerp(cf(0,-1,0) * angles(rad(-85),rad(0),rad(0)),alpha)
		alpha = alpha + add
		swait()
	end
	alpha = .25
	add = .15
	for i = 0,1,.125 do
		local s = sound(566593606,1.5,random(85,115)/100,nil,2.5)
		s.TimePosition = .075
		--magDamage(blade,false,10,random(15,25),random(20,40),.1,.35,s)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(0),rad(75),rad(0)),alpha)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(-2.5),rad(75),rad(0)),alpha)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,-.35) * angles(rad(90),rad(85),rad(0)) * angles(rad(-105),rad(0),rad(0)),alpha)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,-.25,.25) * angles(rad(25),rad(-35),rad(-7.5)),alpha)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(15),rad(-5),rad(1.5)),alpha)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(-15),rad(5),rad(-5)),alpha)
		handleWeld.C0 = handleWeld.C0:Lerp(cf(0,-1,0) * angles(rad(-120),rad(0),rad(0)),alpha)
		alpha = alpha + add
		if alpha >1 then
			add = -math.abs(add)
		end
		swait()
	end
	ws = oldWS
	jp = oldJP
	using = false
end

--[[
	local alpha = .35
	for i = 0,1,.025 do
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),alpha)
		alpha = alpha -.025
		swait()
	end
function base()
	using = true
	local oldWS = ws
	local oldJP = jp
	ws = 0
	jp = 0
	
	ws = oldWS
	jp = oldJP
	using = false
end
--]]

local combos = {swing1,swing2}

mouse.KeyDown:Connect(function(key)
	if not using then
		
	end
	if key == "m" then
		muted = not muted
	end
end)

mouse.Button1Down:Connect(function()
	if not using then
		combos[combo]()
		combo = combo +1
		if combo >#combos then
			combo = 1
		end
	end
end)

stepped:Connect(function()
	sine = sine + change
	
	local verVel = rut.Velocity.y
	local horVel = (rut.Velocity * v3(1,0,1)).Magnitude

	local Ccf=rut.CFrame
	
	local dir = hum.MoveDirection
	
	if dir == v3(0,0,0) then
		dir = rut.Velocity/10
	end
	
	if theme.Parent ~= t then
		remove(theme)
		theme = ins("Sound",t)
		theme.Volume = 1.5
		theme.SoundId = asset..1493059596
		theme.Looped = true
		theme.TimePosition = timePos
		theme:Play()
	end
	
	if static.Parent ~= t then
		remove(static)
		static = ins("Sound",t)
		static.Volume = 1.5
		static.SoundId = asset..1080752200
		static.Looped = true
		static.TimePosition = staticTimePos
		static:Play()
	end
	
	if not muted then
		theme.Volume = 1.5
	else
		theme.Volume = 0
	end
	theme.SoundId = asset..1493059596
	theme.Looped = true
	theme:Resume()
	theme.Name = "Theme"
	
	static.Volume = .75
	static.SoundId = asset..1080752200
	static.Looped = true
	static:Resume()
	static.Name = "Static"
	
	timePos = theme.TimePosition
	staticTimePos = static.TimePosition

	local Walktest1 = dir * Ccf.LookVector
	local Walktest2 = dir * Ccf.RightVector

	local rotfb = Walktest1.X+Walktest1.Z
	local rotrl = Walktest2.X+Walktest2.Z
	
	if rotfb >1 then
		rotfb = 1
	elseif rotfb <-1 then
		rotfb = -1
	end
	
	if rotrl >1 then
		rotrl = 1
	elseif rotrl <-1 then
		rotrl = -1
	end
	
	hum.WalkSpeed = ws
	hum.JumpPower = jp
	
	--[[for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if not v.PlayerGui:FindFirstChild(shaker.Name) then
			local shak = shaker:Clone()
			shak.Parent = v.PlayerGui
			shak.Disabled = false
		end
    end]]
	
	local hit,pos,nId = rayc(rut.Position + v3(0,-rut.Size.y/2,0),v3(rut.Position.x,-10000,rut.Position.z),{char},3)
	
	if using then
		anim = "idle"
	end
	
	if anim == "idle" and hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(sin(sine/20) * rad(2.5),sin(sine/40) * rad(1),sin(sine/40) * rad(5)),.1)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(sin(sine/40)/15,sin(sine/20)/15,sin(sine/60)/15) * angles(sin(sine/20) * rad(2.5),sin(sine/80) * rad(5),sin(sine/40) * rad(2.5)),.1)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,-sin(sine/20)/15,0) * angles(-sin(sine/20) * rad(1.5),sin(sine/80) * rad(5),sin(sine/40) * rad(1.5)),.1)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,sin(sine/20)/15,0) * angles(-cos(sine/20) * rad(7.5),sin(sine/80) * rad(5),sin(sine/40) * rad(2.5)),.1)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,(sin(sine/20)/15) + (sin(sine/40)/25),0) * angles((sin(sine/20) * rad(3.5)) + (sin(sine/80) * rad(2.5)),rad(0),sin(sine/40) * rad(5)),.1)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,(sin(sine/20)/15) + (-sin(sine/40)/25),0) * angles((sin(sine/20) * rad(3.5)) - (sin(sine/80) * rad(2.5)),rad(0),sin(sine/40) * rad(5)),.1)
	elseif anim == "fall" and not hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
	elseif anim == "jump" and not hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.1)
	elseif anim == "walk" and hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(-sin(sine/1.75) * rad(1),sin(sine/3.5) * rad(3.5),sin(sine/3.5) * rad(2.5)) * angles(0,rotrl/1.5,0),.2)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,sin(sine/1.75)/7.5,0) * angles(sin(sine/1.75) * rad(5),sin(sine/3.5) * rad(5),rad(0)) * angles(-rotfb/7.5,0,-rotrl/6),.2)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,sin(sine/1.75)/10,0) * angles(sin(sine/3.5) * rad(5) * rotfb,rad(0),rad(0)),.2)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,-sin(sine/1.75)/10,-cos(sine/3.5)/10) * angles(sin(sine/3.5) * rad(65) * rotfb,sin(sine/1.75) * rad(7.5),sin(sine/1.75) * rad(1.5)),.2)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,cos(sine/3.5)/5,-cos(sine/3.5)/3.5) * angles((sin(sine/3.5) * rad(60) + rad(7.5)) * rotfb,rad(0),sin(sine/3.5) * rad(45) * rotrl) * angles(rad(0),cos(sine/3.5) * rad(2.5),rad(0)),.2)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,-cos(sine/3.5)/5,cos(sine/3.5)/3.5) * angles((-sin(sine/3.5) * rad(60) + rad(7.5)) * rotfb,rad(0),-sin(sine/3.5) * rad(45) * rotrl) * angles(rad(0),cos(sine/3.5) * rad(2.5),rad(0)),.2)
	end
	if not using then
		handleWeld.C0 = handleWeld.C0:Lerp(cf(0,-1,0) * angles(rad(-90),rad(0),rad(0)),.2)
		if horVel > 5 and verVel >-10 and verVel <10 then
			anim = "walk"
			change = .6
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(.15,-.75,-.25) * angles(rad(175),rad(65),rad(0)) * angles(rad(10),rad(0),rad(0)),.1)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),.2)
		elseif verVel >10 then
			anim = "jump"
			change = 1
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(15),rad(0),rad(0)),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(-5),rad(0),rad(0)),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(.15,-.75,-.25) * angles(rad(175),rad(65),rad(0)) * angles(rad(10),rad(0),rad(0)),.1)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(rad(145),rad(0),rad(-8)),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.1,-.1) * angles(rad(-3.5),rad(0),rad(2)),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,.3,-.25) * angles(rad(-9),rad(0),rad(-3.5)),.2)
		elseif verVel <-10 then
			anim = "fall"
			change = 1
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-5),rad(0),rad(0)),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(5),rad(0),rad(0)),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(.15,-.75,-.25) * angles(rad(175),rad(65),rad(0)) * angles(rad(10),rad(0),rad(0)),.1)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(-.45,-.44,0) * angles(rad(6),rad(0),rad(-97.5)),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.3,-.25) * angles(rad(-9),rad(0),rad(2)),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,.1,-.1) * angles(rad(-3.5),rad(0),rad(-3.5)),.2)
		elseif horVel < 5 and verVel >-10 and verVel <10 then
			anim = "idle"
			change = 1
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-10),rad(0),rad(0)),.1)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,-.05) * angles(rad(-5),rad(0),rad(0)),.1)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(.15,-.75,-.25) * angles(rad(175),rad(65),rad(0)) * angles(rad(10),rad(0),rad(0)),.1)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,-.15,.1) * angles(rad(-6.5),rad(15),rad(-3.5)),.1)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(-5),rad(-5),rad(2.5)),.1)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(-5),rad(5),rad(-2.5)),.1)
		end
	end
end)