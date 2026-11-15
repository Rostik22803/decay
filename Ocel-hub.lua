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
 arms_color=Color3.new(1,1,1), weapon_color=Color3.new(1,1,1), tracer_color=Color3.new(1,1,1),
 enemy_material='Neon', arms_material='Neon', weapon_material='Neon',
 enemy_opacity=.45, arms_opacity=.15, weapon_opacity=.15, outline_opacity=.1,
 trees=false, ores=false, resource_distance=500, resource_limit=80,
 tree_color=Color3.fromRGB(170,230,170), ore_color=Color3.fromRGB(180,205,255),
 auto_farm=false, farm_mode='Magic', farm_trees=true, farm_ores=true, farm_range=5}
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
local reopen=button(gui,'  OCEL / HUB  ·  OPEN',UDim2.fromOffset(218,42),UDim2.fromOffset(12,12))
reopen.Name='Watermark'; reopen.TextXAlignment=Enum.TextXAlignment.Left
reopen.BackgroundColor3=Color3.fromRGB(15,15,18)
make('UIStroke',{Color=Color3.fromRGB(95,95,100),Thickness=1},reopen)
local function set_menu(visible)
 panel.Visible=visible; reopen.Text='  OCEL / HUB  ·  '..(visible and 'OPEN' or 'HIDDEN')
end
connect(close.Activated,function() set_menu(false) end)
connect(reopen.Activated,function() set_menu(not panel.Visible) end)
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
local tab_names={'Visuals','Chams','Aim','World','Colors','System'}
for n,name in ipairs(tab_names) do
 local page=make('ScrollingFrame',{Size=UDim2.new(1,-24,1,-111),Position=UDim2.fromOffset(12,101),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=n==1},panel)
 make('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},page)
 make('UIPadding',{PaddingBottom=UDim.new(0,12),PaddingRight=UDim.new(0,5)},page)
 pages[name]=page
 local b=button(tabs,name,UDim2.new(1/#tab_names,-4,1,0),UDim2.new((n-1)/#tab_names,0,0,0))
 b.TextSize=11
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
for _,x in ipairs({{'Boxes','boxes'},{'Articulated skeleton','skeleton'},{'Bullet tracers','tracers'},{'Fullbright','bright'}}) do toggle(v,x[1],x[2]) end
cycle(v,'Box style','box_style',{'Corners','Rectangle'})
slider(v,'Line thickness','width',1,4)
slider(v,'Draw distance','distance',100,3000)
slider(v,'Tracer lifetime','lifetime',.1,3)
local materials={'Neon','ForceField','SmoothPlastic','Glass','Metal','Foil'}
local chams=pages.Chams
for _,entry in ipairs({{'Enemies','enemies','enemy'},{'Hands','arms','arms'},{'Weapon','weapon','weapon'}}) do
 toggle(chams,entry[1],entry[2])
 cycle(chams,entry[1]..' material',entry[3]..'_material',materials)
 slider(chams,entry[1]..' transparency',entry[3]..'_opacity',0,.95)
end
cycle(chams,'Enemy depth','depth',{'AlwaysOnTop','Occluded'})
slider(chams,'Enemy outline transparency','outline_opacity',0,1)
local world=pages.World
toggle(world,'Tree ESP','trees'); toggle(world,'Ore ESP','ores')
slider(world,'Resource ESP distance','resource_distance',50,2000)
slider(world,'Max resource labels','resource_limit',10,150)
toggle(world,'Auto farm nearby','auto_farm')
cycle(world,'Farm mode','farm_mode',{'Magic','Animated'})
toggle(world,'Farm trees','farm_trees'); toggle(world,'Farm ores','farm_ores')
slider(world,'Farm reach','farm_range',2,5)
local farm_status=label(world,'Equip a gathering tool. No auto movement.',UDim2.new(1,-8,0,72))
farm_status.TextWrapped=true; farm_status.TextYAlignment=Enum.TextYAlignment.Top
local a=pages.Aim
for _,x in ipairs({{'Camera aim (toggle)','aim'},{'Silent aim / guns + bow','silent'},{'Visibility check','visible'},{'Ignore teammates','team'}}) do toggle(a,x[1],x[2]) end
cycle(a,'Target part','part',{'Head','HumanoidRootPart'})
slider(a,'FOV radius / pixels','fov',30,400)
slider(a,'Camera response','smooth',1,30)
local status=label(pages.System,'',UDim2.new(1,-8,0,100)); status.TextWrapped=true; status.TextYAlignment=Enum.TextYAlignment.Top
label(pages.System,'Insert: show / hide. Touch: OCEL button.\nUnload restores lighting and local materials.',UDim2.new(1,-8,0,62)).TextWrapped=true
local palettes={Color3.new(1,1,1),Color3.new(.45,.45,.45),Color3.fromRGB(255,70,90),Color3.fromRGB(255,170,60),Color3.fromRGB(255,230,80),Color3.fromRGB(70,230,150),Color3.fromRGB(70,180,255),Color3.fromRGB(180,100,255)}
for _,entry in ipairs({{'ESP','esp_color'},{'Enemy chams','enemy_color'},{'Hands','arms_color'},{'Weapon','weapon_color'},{'Tracers','tracer_color'},{'Trees','tree_color'},{'Ores','ore_color'}}) do
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
local enemy_modified={}
local function restore_part(part,state)
 pcall(function() part.Color=state.Color; part.Material=state.Material; part.Transparency=state.Transparency end)
end
local function apply_material(part,prefix,store,wanted)
 local state=store[part]
 if not state and part.Transparency>=1 then return end
 if not state then
  state={Color=part.Color,Material=part.Material,Transparency=part.Transparency}
  store[part]=state
 end
 wanted[part]=true
 part.Color=cfg[prefix..'_color']; part.Material=Enum.Material[cfg[prefix..'_material']]
 part.Transparency=cfg[prefix..'_opacity']
end
local function restore_unused(store,wanted)
 for part,state in pairs(store) do
  if not wanted[part] then restore_part(part,state); store[part]=nil end
 end
end
local function enemy_chams(camera)
 local wanted={}
 if cfg.enemies then
  for _,p in ipairs(Players:GetPlayers()) do
   if eligible(p,camera) then
    for _,part in ipairs(p.Character:GetChildren()) do
     if part:IsA('BasePart') and part.Name~='HumanoidRootPart' then apply_material(part,'enemy',enemy_modified,wanted) end
    end
   end
  end
 end
 restore_unused(enemy_modified,wanted)
end
local function view_chams(camera)
 local wanted={}
 if cfg.arms or cfg.weapon then
  for _,part in ipairs(camera:GetDescendants()) do
   if part:IsA('BasePart') then
    local name=part.Name:lower()
    local arm=name:find('arm') or name:find('hand')
    local enabled=arm and cfg.arms or not arm and cfg.weapon
     if enabled then apply_material(part,arm and 'arms' or 'weapon',modified,wanted) end
   end
  end
 end
 restore_unused(modified,wanted)
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
    r.highlight.Adornee=c; r.highlight.Enabled=cfg.enemies; r.highlight.FillColor=cfg.enemy_color; r.highlight.OutlineColor=cfg.enemy_color; r.highlight.FillTransparency=cfg.enemy_opacity; r.highlight.OutlineTransparency=cfg.outline_opacity; r.highlight.DepthMode=Enum.HighlightDepthMode[cfg.depth]
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
   tick_acc=0; view_chams(camera); enemy_chams(camera)
  if cfg.bright then
   Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.GlobalShadows=false; Lighting.FogEnd=1e6
  elseif light_on then for k,value in pairs(saved_light) do Lighting[k]=value end end
  light_on=cfg.bright
 end
end)
connect(Players.PlayerRemoving,function(p) local r=records[p]; if r then r.root:Destroy(); r.highlight:Destroy(); records[p]=nil end end)
connect(Input.InputBegan,function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.Insert then set_menu(not panel.Visible) end end)
local resources={}
local resource_labels={}
local resource_pending={}
local function resource_kind(model)
 if not model:IsA('Model') or model:FindFirstChildOfClass('Humanoid') then return end
 local name=model.Name:lower()
 if name=='tree' then return 'tree' end
 if model:FindFirstChild('System') and (name:find('stone') or name:find('metal') or name:find('sulfur') or name:find('ore')) then return 'ore' end
end
local function index_resource(object)
 if not hub.alive or not object:IsDescendantOf(workspace) then return end
 local kind=resource_kind(object)
 if kind then resources[object]=kind end
end
connect(workspace.DescendantAdded,function(object)
 if object:IsA('Model') then resource_pending[object]=true end
 local parent=object.Parent
 if parent and parent:IsA('Model') then resource_pending[parent]=true end
end)
connect(workspace.DescendantRemoving,function(object)
 if resources[object] then
  resources[object]=nil
  if resource_labels[object] then resource_labels[object]:Destroy(); resource_labels[object]=nil end
 end
 resource_pending[object]=nil
end)
task.spawn(function()
 for i,object in ipairs(workspace:GetDescendants()) do
  if not hub.alive then return end
  if object:IsA('Model') then index_resource(object) end
  if i%400==0 then task.wait() end
 end
end)
local function resource_position(model)
 local part=model.PrimaryPart or model:FindFirstChildWhichIsA('BasePart',true)
 return part and part.Position
end
local function update_resources()
 for object in pairs(resource_pending) do index_resource(object); resource_pending[object]=nil end
 local camera=workspace.CurrentCamera; if not camera then return end
 local visible={}
 if cfg.trees or cfg.ores then
  for model,kind in pairs(resources) do
   if (kind=='tree' and cfg.trees) or (kind=='ore' and cfg.ores) then
    local pos=resource_position(model)
    if pos then
     local distance=(pos-camera.CFrame.Position).Magnitude
     local point,on=project(camera,pos)
     if on and distance<=cfg.resource_distance then table.insert(visible,{model=model,kind=kind,distance=distance,point=point}) end
    end
   end
  end
 end
 table.sort(visible,function(a,b) return a.distance<b.distance end)
 local wanted={}
 for i=1,math.min(#visible,math.floor(cfg.resource_limit)) do
  local item=visible[i]; local model=item.model; wanted[model]=true
  local text=resource_labels[model]
  if not text then
   text=label(overlay,'',UDim2.fromOffset(180,26)); text.AnchorPoint=Vector2.new(.5,.5)
   text.TextXAlignment=Enum.TextXAlignment.Center; text.TextStrokeTransparency=.15; text.TextSize=12
   resource_labels[model]=text
  end
  text.Position=UDim2.fromOffset(item.point.X,item.point.Y)
  text.Text=(item.kind=='tree' and 'TREE' or model.Name:upper())..'  ['..math.floor(item.distance)..' st]'
  text.TextColor3=item.kind=='tree' and cfg.tree_color or cfg.ore_color
 end
 for model,text in pairs(resource_labels) do if not wanted[model] then text:Destroy(); resource_labels[model]=nil end end
end
local item_data
pcall(function() item_data=require(RS.ItemData).Items end)
local selected_slot
local function equipped_tool()
 if not selected_slot or not selected_slot.Parent then
  local player_gui=me:FindFirstChild('PlayerGui')
  local hotbar=player_gui and player_gui:FindFirstChild('Hotbar',true)
  selected_slot=hotbar and hotbar:FindFirstChild('SelectedSlot')
 end
 local slot=selected_slot and selected_slot:IsA('ObjectValue') and selected_slot.Value
 local item=slot and slot:FindFirstChild('ItemName')
 local data=item and item_data and item_data[item.Value]
 if data and data.Gather and data.ToolInfo then return item.Value,data,slot end
end
local function resource_ancestor(part)
 local object=part
 while object and object~=workspace do
  if resources[object] then return object,resources[object] end
  object=object.Parent
 end
end
local function closest_point(part,origin)
 local p=part.CFrame:PointToObjectSpace(origin); local half=part.Size*.5
 return part.CFrame:PointToWorldSpace(Vector3.new(math.clamp(p.X,-half.X,half.X),math.clamp(p.Y,-half.Y,half.Y),math.clamp(p.Z,-half.Z,half.Z)))
end
local function farm_target(head,data)
 local camera=workspace.CurrentCamera
 local exclusions={me.Character}; if camera then table.insert(exclusions,camera) end
 local overlap=OverlapParams.new(); overlap.FilterType=Enum.RaycastFilterType.Exclude; overlap.FilterDescendantsInstances=exclusions
 local ray_params=RaycastParams.new(); ray_params.FilterType=Enum.RaycastFilterType.Exclude; ray_params.FilterDescendantsInstances=exclusions; ray_params.IgnoreWater=true
 local best,best_distance
 for _,part in ipairs(workspace:GetPartBoundsInRadius(head.Position,cfg.farm_range,overlap)) do
  local model,kind=resource_ancestor(part)
  local allowed=model and ((kind=='tree' and cfg.farm_trees and data.Gather.Wood) or (kind=='ore' and cfg.farm_ores and data.Gather.Stone))
  if allowed and part.CanQuery then
   local point=closest_point(part,head.Position)
   local offset=point-head.Position
   if offset.Magnitude<.01 then offset=part.Position-head.Position end
   if offset.Magnitude>.01 and offset.Magnitude<=cfg.farm_range then
    local hit=workspace:Raycast(head.Position,offset.Unit*cfg.farm_range,ray_params)
    if hit and hit.Instance:IsDescendantOf(model) then
     local distance=(hit.Position-head.Position).Magnitude
     if not best_distance or distance<best_distance then best={model=model,direction=offset.Unit}; best_distance=distance end
    end
   end
  end
 end
 return best
end
local farm_track
local farm_busy=false
local next_farm=0
local function stop_farm_animation()
 if farm_track then pcall(function() farm_track:Stop(.1); farm_track:Destroy() end); farm_track=nil end
end
local function farm_tick()
 if not cfg.auto_farm then farm_status.Text='Auto farm OFF. Equip a gathering tool. No movement.'; stop_farm_animation(); return end
 if panel.Visible then farm_status.Text='Paused while menu is open.'; return end
 if farm_busy or os.clock()<next_farm then return end
 local character=me.Character
 local head=character and character:FindFirstChild('Head')
 local humanoid=character and character:FindFirstChildOfClass('Humanoid')
 if not head or not humanoid or humanoid.Health<=0 then farm_status.Text='Waiting for character.'; return end
 local name,data,slot=equipped_tool()
 if not name then farm_status.Text='Select a gathering tool in the hotbar.'; return end
 local tool_system=RS:FindFirstChild('ToolSystem')
 local remotes=tool_system and tool_system:FindFirstChild('RemoteEvents')
 local swing=remotes and remotes:FindFirstChild('Swing')
 if not swing or not swing:IsA('RemoteEvent') then farm_status.Text='ToolSystem.Swing unavailable.'; return end
 local choice=farm_target(head,data)
 if not choice then farm_status.Text='No compatible resource within reach ('..name..').' ; return end
 local info=data.ToolInfo
 next_farm=os.clock()+math.max(.35,info.HitInterval or ((info.PlayTime or .5)+(info.WaitTime or .25)))
 farm_status.Text=cfg.farm_mode..' → '..choice.model.Name..' / '..name..' (yield not verified)'
 if cfg.farm_mode=='Magic' then
  swing:FireServer(choice.direction,name,nil)
  return
 end
 farm_busy=true
 task.spawn(function()
  local ok,err=pcall(function()
   local camera=workspace.CurrentCamera
   local animations=info.Animations
   local animation=animations and animations.Swing
   local controller=camera and camera:FindFirstChildWhichIsA('AnimationController',true)
   local animator=controller and controller:FindFirstChildOfClass('Animator')
   if not animation or not animator then error('No equipped viewmodel swing animation') end
   stop_farm_animation(); farm_track=animator:LoadAnimation(animation); farm_track:Play(.05)
   local replication=RS:FindFirstChild('Replication'); local events=replication and replication:FindFirstChild('Events'); local attack=events and events:FindFirstChild('Attack')
   local item_type=slot:FindFirstChild('ItemType')
   if attack and item_type then attack:FireServer(name,item_type.Value) end
   task.wait(math.max(.05,info.HitTime or .1))
   if not hub.alive or not cfg.auto_farm or cfg.farm_mode~='Animated' or panel.Visible or me.Character~=character then return end
   local current=equipped_tool(); if current~=name then return end
   local refreshed=farm_target(head,data)
   if refreshed then swing:FireServer(refreshed.direction,name,nil) end
  end)
  farm_busy=false
  if not ok and hub.alive then farm_status.Text='Farm: '..tostring(err); next_farm=os.clock()+2 end
 end)
end
local resource_clock=0
connect(Run.Heartbeat,function(dt)
 resource_clock=resource_clock+dt
 if resource_clock>=.25 then
  resource_clock=0; update_resources()
  local ok,err=pcall(farm_tick)
  if not ok then farm_status.Text='Farm: '..tostring(err); next_farm=os.clock()+2 end
 end
end)
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
 for part,state in pairs(enemy_modified) do restore_part(part,state) end
 stop_farm_animation()
 if light_on then for k,value in pairs(saved_light) do Lighting[k]=value end end
 for object in pairs(self.objects) do object:Destroy() end
 gui:Destroy()
 if env.OcelHub==self then env.OcelHub=nil end
end
connect(exit.Activated,function() hub:Destroy() end)
