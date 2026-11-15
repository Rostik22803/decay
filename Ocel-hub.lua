-- Luau | Ocel-hub.lua | Roblox client executor | dump 97393041934796
local env = getgenv and getgenv() or _G
if env.OcelHub then env.OcelHub:Destroy() end
local Players = game:GetService('Players')
local Run = game:GetService('RunService')
local Input = game:GetService('UserInputService')
local Lighting = game:GetService('Lighting')
local RS = game:GetService('ReplicatedStorage')
local me = Players.LocalPlayer
local hub = {alive = true, connections = {}, objects = {}, restores = {}, hooks = {}}
env.OcelHub = hub
local cfg = {boxes=true, skeleton=true, enemies=false, arms=false, weapon=false,
 aim=false, silent=false, visible=true, team=true, bright=false, tracers=false,
 fov=140, distance=1500, smooth=12, width=1.5, opacity=.45, lifetime=1,
 part='Head', box_style='Corners', material='Neon', depth='AlwaysOnTop',
 esp_color=Color3.new(1,1,1), enemy_color=Color3.new(1,1,1),
 arms_color=Color3.new(1,1,1), weapon_color=Color3.new(1,1,1), tracer_color=Color3.new(1,1,1)}
local function connect(signal, fn)
 local c = signal:Connect(fn); table.insert(hub.connections,c); return c
end
local function make(class, props, parent)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent; return o
end
local gui=make('ScreenGui',{Name='Ocel-hub',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=900},me:WaitForChild('PlayerGui'))
local overlay=make('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},gui)
local panel=make('Frame',{Size=UDim2.fromOffset(470,480),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(13,13,15),ClipsDescendants=true},gui)
make('UICorner',{CornerRadius=UDim.new(0,16)},panel)
make('UIStroke',{Color=Color3.fromRGB(75,75,80),Thickness=1},panel)
local scale=make('UIScale',{},panel)
local function fit()
 local camera=workspace.CurrentCamera
 if camera then scale.Scale=math.min(1,(camera.ViewportSize.X-24)/470,(camera.ViewportSize.Y-32)/480) end
end
fit()
local function label(parent,text,size,pos)
 return make('TextLabel',{Text=text,Size=size,Position=pos or UDim2.new(),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},parent)
end
local function button(parent,text,size,pos)
 local b=make('TextButton',{Text=text,Size=size,Position=pos or UDim2.new(),BackgroundColor3=Color3.fromRGB(31,31,35),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamMedium,TextSize=13,AutoButtonColor=true},parent)
 make('UICorner',{CornerRadius=UDim.new(0,8)},b); return b
end
local header=label(panel,'  OCEL / HUB',UDim2.new(1,-90,0,55))
header.TextSize=20
local close=button(panel,'−',UDim2.fromOffset(36,32),UDim2.new(1,-80,0,12))
local exit=button(panel,'×',UDim2.fromOffset(32,32),UDim2.new(1,-40,0,12))
local reopen=button(gui,'OCEL',UDim2.fromOffset(66,44),UDim2.new(0,12,.45,0))
reopen.Visible=false
connect(close.Activated,function() panel.Visible=false; reopen.Visible=true end)
connect(reopen.Activated,function() panel.Visible=true; reopen.Visible=false end)
local dragging, drag_start, panel_start
connect(header.InputBegan,function(i)
 if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=i; drag_start=i.Position; panel_start=panel.Position end
end)
connect(Input.InputChanged,function(i)
 if dragging and (i==dragging or i.UserInputType==Enum.UserInputType.MouseMovement) then
  local d=i.Position-drag_start; panel.Position=panel_start+UDim2.fromOffset(d.X,d.Y)
 end
end)
connect(Input.InputEnded,function(i) if i==dragging then dragging=nil end end)
local tabs=make('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-24,0,36),Position=UDim2.fromOffset(12,57)},panel)
local pages={}
for n,name in ipairs({'Visuals','Aim','Colors','System'}) do
 local page=make('ScrollingFrame',{Size=UDim2.new(1,-24,1,-111),Position=UDim2.fromOffset(12,101),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=n==1},panel)
 make('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},page)
 make('UIPadding',{PaddingBottom=UDim.new(0,12),PaddingRight=UDim.new(0,5)},page)
 pages[name]=page
 local b=button(tabs,name,UDim2.new(.25,-5,1,0),UDim2.new((n-1)*.25,0,0,0))
 connect(b.Activated,function() for k,p in pairs(pages) do p.Visible=k==name end end)
end
local function row(page,text,height)
 local r=make('Frame',{Size=UDim2.new(1,0,0,height or 44),BackgroundColor3=Color3.fromRGB(22,22,25)},page)
 make('UICorner',{CornerRadius=UDim.new(0,9)},r)
 label(r,text,UDim2.new(.64,-12,1,0),UDim2.fromOffset(12,0)); return r
end
local function toggle(page,text,key)
 local r=row(page,text); local b=button(r,'',UDim2.fromOffset(58,30),UDim2.new(1,-68,.5,-15))
 local function update() b.Text=cfg[key] and 'ON' or 'OFF'; b.BackgroundColor3=cfg[key] and Color3.fromRGB(220,220,225) or Color3.fromRGB(40,40,44); b.TextColor3=cfg[key] and Color3.new(0,0,0) or Color3.new(1,1,1) end
 connect(b.Activated,function() cfg[key]=not cfg[key]; update() end); update()
end
local function cycle(page,text,key,values)
 local r=row(page,text); local b=button(r,cfg[key],UDim2.fromOffset(134,30),UDim2.new(1,-144,.5,-15))
 connect(b.Activated,function() local index=table.find(values,cfg[key]) or 1; cfg[key]=values[index%#values+1]; b.Text=cfg[key] end)
end
local function slider(page,text,key,lo,hi)
 local r=row(page,text,65)
 r:FindFirstChildOfClass('TextLabel').Size=UDim2.new(1,-20,0,28)
 local value=label(r,'',UDim2.fromOffset(70,28),UDim2.new(1,-80,0,0)); value.TextXAlignment=Enum.TextXAlignment.Right
 local bar=button(r,'',UDim2.new(1,-28,0,16),UDim2.fromOffset(14,38))
 local fill=make('Frame',{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Size=UDim2.new(0,0,1,0)},bar)
 make('UICorner',{CornerRadius=UDim.new(0,8)},fill)
 local held
 local function update(x)
  if x then cfg[key]=lo+math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(hi-lo) end
  fill.Size=UDim2.fromScale((cfg[key]-lo)/(hi-lo),1); value.Text=string.format(hi<=5 and '%.2f' or '%.0f',cfg[key])
 end
 connect(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then held=i; update(i.Position.X) end end)
 connect(Input.InputChanged,function(i) if held and (i==held or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i.Position.X) end end)
 connect(Input.InputEnded,function(i) if i==held then held=nil end end); update()
end
local v=pages.Visuals
for _,x in ipairs({{'Boxes','boxes'},{'Articulated skeleton','skeleton'},{'Enemy chams','enemies'},{'My hands','arms'},{'My weapon','weapon'},{'Bullet tracers','tracers'},{'Fullbright','bright'}}) do toggle(v,x[1],x[2]) end
cycle(v,'Box style','box_style',{'Corners','Rectangle'})
cycle(v,'Chams material','material',{'Neon','ForceField','SmoothPlastic'})
cycle(v,'Enemy depth','depth',{'AlwaysOnTop','Occluded'})
slider(v,'Line thickness','width',1,4)
slider(v,'Chams transparency','opacity',0,1)
slider(v,'Draw distance','distance',100,3000)
slider(v,'Tracer lifetime','lifetime',.1,3)
local a=pages.Aim
for _,x in ipairs({{'Camera aim (toggle)','aim'},{'Silent aim / guns + bow','silent'},{'Visibility check','visible'},{'Ignore teammates','team'}}) do toggle(a,x[1],x[2]) end
cycle(a,'Target part','part',{'Head','HumanoidRootPart'})
slider(a,'FOV radius / pixels','fov',30,400)
slider(a,'Camera response','smooth',1,30)
local status=label(pages.System,'',UDim2.new(1,-8,0,100)); status.TextWrapped=true; status.TextYAlignment=Enum.TextYAlignment.Top
label(pages.System,'Insert: show / hide. Touch: OCEL button.\nUnload restores lighting and local materials.',UDim2.new(1,-8,0,62)).TextWrapped=true
local palettes={Color3.new(1,1,1),Color3.new(.45,.45,.45),Color3.fromRGB(255,70,90),Color3.fromRGB(255,170,60),Color3.fromRGB(255,230,80),Color3.fromRGB(70,230,150),Color3.fromRGB(70,180,255),Color3.fromRGB(180,100,255)}
for _,entry in ipairs({{'ESP','esp_color'},{'Enemy chams','enemy_color'},{'Hands','arms_color'},{'Weapon','weapon_color'},{'Tracers','tracer_color'}}) do
 local r=row(pages.Colors,entry[1],112); r:FindFirstChildOfClass('TextLabel').Size=UDim2.new(1,-20,0,26)
 for j,col in ipairs(palettes) do
  local b=button(r,'',UDim2.fromOffset(30,26),UDim2.fromOffset(12+(j-1)*38,30)); b.BackgroundColor3=col
  connect(b.Activated,function() cfg[entry[2]]=col end)
 end
 local box=make('TextBox',{Size=UDim2.fromOffset(150,28),Position=UDim2.fromOffset(12,72),Text='#FFFFFF',PlaceholderText='#RRGGBB',ClearTextOnFocus=false,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(40,40,44),TextSize=14,Font=Enum.Font.Code},r)
 connect(box.FocusLost,function()
  local hex=box.Text:gsub('#',''); if hex:match('^%x%x%x%x%x%x$') then cfg[entry[2]]=Color3.fromHex(hex) else box.Text='#'..cfg[entry[2]]:ToHex() end
 end)
end
local function circle(parent)
 local c=make('Frame',{BackgroundTransparency=1,Visible=false},parent)
 make('UICorner',{CornerRadius=UDim.new(1,0)},c)
 make('UIStroke',{Thickness=1,Color=Color3.new(1,1,1)},c); return c
end
local fov_circle=circle(overlay)
local records={}
local function record(player)
 local r={lines={},used=0,root=make('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},overlay)}
 r.head=circle(r.root)
 r.highlight=make('Highlight',{Enabled=false,Name='OcelEnemy'},gui)
 records[player]=r; return r
end
local function line(r,p,q,color)
 r.used=r.used+1
 local l=r.lines[r.used]
 if not l then l=make('Frame',{BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5)},r.root); r.lines[r.used]=l end
 local d=q-p; l.Visible=true; l.Position=UDim2.fromOffset((p.X+q.X)/2,(p.Y+q.Y)/2)
 l.Size=UDim2.fromOffset(d.Magnitude,cfg.width); l.Rotation=math.deg(math.atan2(d.Y,d.X)); l.BackgroundColor3=color
end
local function project(camera,p)
 local s,on=camera:WorldToViewportPoint(p); return Vector2.new(s.X,s.Y),on and s.Z>.1
end
local function segment(r,camera,p,q)
 local a,ok=project(camera,p); local b,ok2=project(camera,q)
 if ok and ok2 then line(r,a,b,cfg.esp_color) end
end
local function eligible(p,camera)
 local c=p.Character; local h=c and c:FindFirstChildOfClass('Humanoid'); local root=c and c:FindFirstChild('HumanoidRootPart')
 return p~=me and h and h.Health>0 and root and (root.Position-camera.CFrame.Position).Magnitude<=cfg.distance and not (cfg.team and me.Team~=nil and p.Team==me.Team)
end
local function clear_path(camera,part)
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 local filter={camera}; if me.Character then table.insert(filter,me.Character) end
 params.FilterDescendantsInstances=filter
 local hit=workspace:Raycast(camera.CFrame.Position,part.Position-camera.CFrame.Position,params)
 return not hit or hit.Instance:IsDescendantOf(part.Parent)
end
local target
local function skeleton(r,camera,c)
 local head=c:FindFirstChild('Head'); local torso=c:FindFirstChild('UpperTorso') or c:FindFirstChild('Torso')
 if not (head and torso) then return end
 local neck=torso.Position+torso.CFrame.UpVector*torso.Size.Y*.5
 local pelvis=c:FindFirstChild('LowerTorso'); local hip=pelvis and pelvis.Position or torso.Position-torso.CFrame.UpVector*torso.Size.Y*.5
 segment(r,camera,head.Position,neck); segment(r,camera,neck,hip)
 for _,side in ipairs({'Left','Right'}) do
  local sign=side=='Left' and -1 or 1
  local upper=c:FindFirstChild(side..'UpperArm'); local lower=c:FindFirstChild(side..'LowerArm'); local hand=c:FindFirstChild(side..'Hand')
  if upper and lower and hand then
   local shoulder=(upper.CFrame*CFrame.new(0,upper.Size.Y*.5,0)).Position
   local elbow=(lower.CFrame*CFrame.new(0,lower.Size.Y*.5,0)).Position
   segment(r,camera,neck,shoulder); segment(r,camera,shoulder,elbow); segment(r,camera,elbow,hand.Position)
  else
   local arm=c:FindFirstChild(side..' Arm')
   if arm then local shoulder=arm.Position+arm.CFrame.UpVector*arm.Size.Y*.5; segment(r,camera,neck,shoulder); segment(r,camera,shoulder,arm.Position); segment(r,camera,arm.Position,arm.Position-arm.CFrame.UpVector*arm.Size.Y*.5) end
  end
  local thigh=c:FindFirstChild(side..'UpperLeg'); local calf=c:FindFirstChild(side..'LowerLeg'); local foot=c:FindFirstChild(side..'Foot')
  if thigh and calf and foot then
   local joint=(thigh.CFrame*CFrame.new(0,thigh.Size.Y*.5,0)).Position
   local knee=(calf.CFrame*CFrame.new(0,calf.Size.Y*.5,0)).Position
   segment(r,camera,hip,joint); segment(r,camera,joint,knee); segment(r,camera,knee,foot.Position)
  else
   local leg=c:FindFirstChild(side..' Leg')
   if leg then local joint=leg.Position+leg.CFrame.UpVector*leg.Size.Y*.5; segment(r,camera,hip,joint); segment(r,camera,joint,leg.Position); segment(r,camera,leg.Position,leg.Position-leg.CFrame.UpVector*leg.Size.Y*.5) end
  end
 end
 local p,on=project(camera,head.Position)
 local edge=project(camera,head.Position+camera.CFrame.RightVector*head.Size.X*.55)
 local radius=math.max(2,(edge-p).Magnitude)
 r.head.Visible=on; r.head.Position=UDim2.fromOffset(p.X-radius,p.Y-radius); r.head.Size=UDim2.fromOffset(radius*2,radius*2)
 local stroke=r.head:FindFirstChildOfClass('UIStroke'); stroke.Color=cfg.esp_color; stroke.Thickness=cfg.width
end
local function boxes(r,camera,c)
 local cf,size=c:GetBoundingBox(); local min,max=Vector2.new(math.huge,math.huge),Vector2.new(-math.huge,-math.huge)
 for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
  local p,on=project(camera,cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)); if not on then return end
  min=Vector2.new(math.min(min.X,p.X),math.min(min.Y,p.Y)); max=Vector2.new(math.max(max.X,p.X),math.max(max.Y,p.Y))
 end end end
 local tl,tr,bl,br=min,Vector2.new(max.X,min.Y),Vector2.new(min.X,max.Y),max
 if cfg.box_style=='Rectangle' then
  line(r,tl,tr,cfg.esp_color); line(r,tr,br,cfg.esp_color); line(r,br,bl,cfg.esp_color); line(r,bl,tl,cfg.esp_color)
 else
  local w,h=(max.X-min.X)*.23,(max.Y-min.Y)*.18
  for _,corner in ipairs({{tl,1,1},{tr,-1,1},{bl,1,-1},{br,-1,-1}}) do
   line(r,corner[1],corner[1]+Vector2.new(w*corner[2],0),cfg.esp_color); line(r,corner[1],corner[1]+Vector2.new(0,h*corner[3]),cfg.esp_color)
  end
 end
end
local saved_light={}
for _,key in ipairs({'Brightness','ClockTime','Ambient','OutdoorAmbient','GlobalShadows','FogEnd'}) do saved_light[key]=Lighting[key] end
local modified={}
local function restore_part(part,state)
 pcall(function() part.Color=state.Color; part.Material=state.Material; part.Transparency=state.Transparency end)
end
local function view_chams(camera)
 local wanted={}
 if cfg.arms or cfg.weapon then
  for _,part in ipairs(camera:GetDescendants()) do
   if part:IsA('BasePart') then
    local name=part.Name:lower()
    local arm=name:find('arm') or name:find('hand')
    local enabled=arm and cfg.arms or not arm and cfg.weapon
    if enabled and part.Transparency<1 then
     wanted[part]=true
     if not modified[part] then modified[part]={Color=part.Color,Material=part.Material,Transparency=part.Transparency} end
     part.Color=arm and cfg.arms_color or cfg.weapon_color; part.Material=Enum.Material[cfg.material]; part.Transparency=cfg.opacity
    end
   end
  end
 end
 for part,state in pairs(modified) do if not wanted[part] then restore_part(part,state); modified[part]=nil end end
end
local light_on=false
local tick_acc=0
connect(Run.RenderStepped,function(dt)
 local camera=workspace.CurrentCamera; if not camera then return end
 fit(); local center=camera.ViewportSize*.5
 fov_circle.Visible=cfg.aim or cfg.silent; fov_circle.Position=UDim2.fromOffset(center.X-cfg.fov,center.Y-cfg.fov); fov_circle.Size=UDim2.fromOffset(cfg.fov*2,cfg.fov*2)
 local best=cfg.fov; target=nil
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=me then
   local r=records[p] or record(p); r.used=0; r.head.Visible=false; r.highlight.Enabled=false
   if eligible(p,camera) then
    local c=p.Character; local part=c:FindFirstChild(cfg.part)
    r.highlight.Adornee=c; r.highlight.Enabled=cfg.enemies; r.highlight.FillColor=cfg.enemy_color; r.highlight.OutlineColor=cfg.enemy_color; r.highlight.FillTransparency=cfg.opacity; r.highlight.DepthMode=Enum.HighlightDepthMode[cfg.depth]
    if cfg.boxes then boxes(r,camera,c) end
    if cfg.skeleton then skeleton(r,camera,c) end
    if part then local point,on=project(camera,part.Position); local dist=(point-center).Magnitude
     if on and dist<best and (not cfg.visible or clear_path(camera,part)) then best=dist; target=part end
    end
   end
   for i=r.used+1,#r.lines do r.lines[i].Visible=false end
  end
 end
 if cfg.aim and target and not panel.Visible then camera.CFrame=camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position,target.Position),1-math.exp(-cfg.smooth*dt)) end
 tick_acc=tick_acc+dt
 if tick_acc>.15 then
  tick_acc=0; view_chams(camera)
  if cfg.bright then
   Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.GlobalShadows=false; Lighting.FogEnd=1e6
  elseif light_on then for k,value in pairs(saved_light) do Lighting[k]=value end end
  light_on=cfg.bright
 end
end)
connect(Players.PlayerRemoving,function(p) local r=records[p]; if r then r.root:Destroy(); r.highlight:Destroy(); records[p]=nil end end)
connect(Input.InputBegan,function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.Insert then panel.Visible=not panel.Visible; reopen.Visible=not panel.Visible end end)
local function tracer(origin,direction)
 if not cfg.tracers then return end
 local camera=workspace.CurrentCamera; local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 local filter={camera}; if me.Character then table.insert(filter,me.Character) end; params.FilterDescendantsInstances=filter
 local hit=workspace:Raycast(origin,direction*cfg.distance,params)
 local endpoint=hit and hit.Position or origin+direction*cfg.distance
 local anchor=make('Part',{Name='OcelTracer',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.one},workspace)
 local a0=make('Attachment',{WorldPosition=origin},anchor); local a1=make('Attachment',{WorldPosition=endpoint},anchor)
 make('Beam',{Attachment0=a0,Attachment1=a1,Width0=.045,Width1=.025,FaceCamera=true,LightEmission=1,Color=ColorSequence.new(cfg.tracer_color),Transparency=NumberSequence.new(.1)},anchor)
 hub.objects[anchor]=true
 task.delay(cfg.lifetime,function() hub.objects[anchor]=nil; anchor:Destroy() end)
end
-- Scope the ray override to Shoot's coroutine: local simulation and remote share it.
local active=setmetatable({},{__mode='k'})
local hooked=0
local ballistics
pcall(function() ballistics=require(RS.GunSystem.Ballistics) end)
local function predicted(origin,part,config)
 local speed=config and config.Speed
 if type(speed)~='number' or speed<=0 then return part.Position end
 local gravity=config.Gravity or Vector3.zero
 if type(gravity)=='number' then gravity=Vector3.new(0,-gravity,0) end
 if typeof(gravity)~='Vector3' then gravity=Vector3.zero end
 local t=(part.Position-origin).Magnitude/speed
 local pos=part.Position
 for _=1,6 do
  local falling=math.max(0,t-(config.StraightTime or 0))
  pos=part.Position+part.AssemblyLinearVelocity*t-gravity*(.5*falling*falling)
  t=(pos-origin).Magnitude/speed
 end
 return pos
end
if hookmetamethod and newcclosure and getnamecallmethod then
 local old
 old=hookmetamethod(game,'__namecall',newcclosure(function(self,...)
  local context=active[coroutine.running()]
  if hub.alive and context and self==workspace.CurrentCamera and getnamecallmethod()=='ViewportPointToRay' then
   local ray=old(self,...); local direction=ray.Direction
   if cfg.silent and target and target.Parent then
    local delta=predicted(ray.Origin,target,context.config)-ray.Origin
    if delta.Magnitude>.001 then direction=delta.Unit end
   end
   task.defer(tracer,ray.Origin,direction)
   return Ray.new(ray.Origin,direction)
  end
  return old(self,...)
 end))
 for _,module in ipairs(game:GetDescendants()) do
  if module:IsA('ModuleScript') and (module.Name=='GunShootModule' or module.Name=='BowShootModule') then
   local ok,exports=pcall(require,module)
   if ok and type(exports)=='table' and type(exports.Shoot)=='function' and not hub.hooks[exports] then
    local original=exports.Shoot; hub.hooks[exports]=original
    exports.Shoot=function(slot,context,...)
     local config
     pcall(function()
      if module.Name=='BowShootModule' then config=ballistics.GetBowConfig(context.ItemData)
      else
       local name=slot.ItemName.Value; local data=require(RS.ItemData).Items[name]
       config=ballistics.ApplyAmmo(ballistics.GetConfig(name,data),require(RS.AmmoTypes).Loaded(slot))
      end
     end)
     local thread=coroutine.running(); active[thread]={config=config}
     local result=table.pack(pcall(original,slot,context,...)); active[thread]=nil
     if not result[1] then error(result[2],0) end
     return table.unpack(result,2,result.n)
    end
    hooked=hooked+1
   end
  end
 end
end
status.Text='OCEL / client adapter\nWeapon modules connected: '..hooked..'\n'..(hooked>0 and 'Silent ray adapter installed. Server hit validation still applies.' or 'Silent / tracers unavailable: executor hook APIs or module access missing.')
function hub:Destroy()
 if not self.alive then return end; self.alive=false
 for _,c in ipairs(self.connections) do c:Disconnect() end
 for exports,original in pairs(self.hooks) do exports.Shoot=original end
 for part,state in pairs(modified) do restore_part(part,state) end
 if light_on then for k,value in pairs(saved_light) do Lighting[k]=value end end
 for object in pairs(self.objects) do object:Destroy() end
 gui:Destroy()
 if env.OcelHub==self then env.OcelHub=nil end
end
connect(exit.Activated,function() hub:Destroy() end)
