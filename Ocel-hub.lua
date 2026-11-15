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
 auto_farm=false, farm_mode='Magic', farm_trees=true, farm_ores=true, farm_range=5,
 magic_range=12, aim_mode='Instant', aim_lead=0, cloth=false,
 cloth_color=Color3.fromRGB(235,225,175), magic_tools=false, tools_range=12, tools_auto=false,
 esp_names=true, esp_distance=true, esp_health=true, esp_weapon=true, esp_visibility=true,
 potato=false, bots=true}
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
local reopen=button(gui,'  OCEL / HUB  ·  OPEN',UDim2.fromOffset(218,42),UDim2.new(0,12,1,-54))
reopen.Name='Watermark'; reopen.TextXAlignment=Enum.TextXAlignment.Left
reopen.BackgroundColor3=Color3.fromRGB(15,15,18)
make('UIStroke',{Color=Color3.fromRGB(95,95,100),Thickness=1},reopen)
local function set_menu(visible)
 panel.Visible=visible; reopen.Text='  OCEL / HUB  ·  '..(visible and 'OPEN' or 'HIDDEN')
end
connect(close.Activated,function() set_menu(false) end)
local watermark_input, watermark_start, watermark_position, watermark_moved
connect(reopen.InputBegan,function(i)
 if watermark_input then return end
 if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
  watermark_input=i; watermark_start=Vector2.new(i.Position.X,i.Position.Y)
  watermark_position=reopen.AbsolutePosition; watermark_moved=false
 end
end)
connect(Input.InputChanged,function(i)
 if not watermark_input or not (i==watermark_input or (watermark_input.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then return end
 local delta=Vector2.new(i.Position.X,i.Position.Y)-watermark_start
 if delta.Magnitude>6 then watermark_moved=true end
 if watermark_moved then
  local camera=workspace.CurrentCamera; if not camera then return end
  local pos=watermark_position+delta; local limit=camera.ViewportSize-reopen.AbsoluteSize
  reopen.Position=UDim2.fromOffset(math.clamp(pos.X,0,math.max(0,limit.X)),math.clamp(pos.Y,0,math.max(0,limit.Y)))
 end
end)
connect(Input.InputEnded,function(i)
 if i~=watermark_input then return end
 local point=Vector2.new(i.Position.X,i.Position.Y)
 local pos,size=reopen.AbsolutePosition,reopen.AbsoluteSize
 if not watermark_moved and (point-watermark_start).Magnitude<=6 and point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=pos.Y+size.Y then
  set_menu(not panel.Visible)
 end
 watermark_input=nil
end)
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
for _,entry in ipairs({{'Player names','esp_names'},{'Player distance','esp_distance'},{'Health bar','esp_health'},{'Held weapon','esp_weapon'},{'Bot ESP','bots'},{'Visible green / hidden red','esp_visibility'},{'Potato graphics','potato'}}) do toggle(v,entry[1],entry[2]) end
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
toggle(world,'Tree ESP','trees'); toggle(world,'Ore ESP','ores'); toggle(world,'Cloth ESP','cloth')
slider(world,'Resource ESP distance','resource_distance',50,2000)
slider(world,'Max resource labels','resource_limit',10,150)
toggle(world,'Auto farm nearby','auto_farm')
cycle(world,'Farm mode','farm_mode',{'Magic','Animated'})
toggle(world,'Farm trees','farm_trees'); toggle(world,'Farm ores','farm_ores')
slider(world,'Farm reach','farm_range',2,5)
slider(world,'Magic reach (server limited)','magic_range',2,30)
local farm_status=label(world,'Equip a gathering tool. No auto movement.',UDim2.new(1,-8,0,72))
farm_status.TextWrapped=true; farm_status.TextYAlignment=Enum.TextYAlignment.Top
local a=pages.Aim
for _,x in ipairs({{'Camera aim (toggle)','aim'},{'Silent aim / guns + bow','silent'},{'Visibility check','visible'},{'Ignore teammates','team'}}) do toggle(a,x[1],x[2]) end
cycle(a,'Target part','part',{'Head','HumanoidRootPart'})
slider(a,'FOV radius / pixels','fov',30,400)
slider(a,'Camera response','smooth',1,30)
cycle(a,'Camera aim mode','aim_mode',{'Instant','Smooth'})
slider(a,'Motion lead / seconds','aim_lead',0,.1)
toggle(a,'Magic Tools / rock + spear','magic_tools')
toggle(a,'Magic Tools auto attack','tools_auto')
slider(a,'Tools reach (server limited)','tools_range',5,30)
local tools_status=label(a,'Magic Tools: adapter pending.',UDim2.new(1,-8,0,65))
tools_status.TextWrapped=true; tools_status.TextYAlignment=Enum.TextYAlignment.Top
local status=label(pages.System,'',UDim2.new(1,-8,0,100)); status.TextWrapped=true; status.TextYAlignment=Enum.TextYAlignment.Top
label(pages.System,'Insert: show / hide. Touch: OCEL button.\nUnload restores lighting and local materials.',UDim2.new(1,-8,0,62)).TextWrapped=true
local palettes={Color3.new(1,1,1),Color3.new(.45,.45,.45),Color3.fromRGB(255,70,90),Color3.fromRGB(255,170,60),Color3.fromRGB(255,230,80),Color3.fromRGB(70,230,150),Color3.fromRGB(70,180,255),Color3.fromRGB(180,100,255)}
for _,entry in ipairs({{'ESP','esp_color'},{'Enemy chams','enemy_color'},{'Hands','arms_color'},{'Weapon','weapon_color'},{'Tracers','tracer_color'},{'Trees','tree_color'},{'Ores','ore_color'},{'Cloth','cloth_color'}}) do
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
local bots={}
local function character_root(c)
 return c and (c:FindFirstChild('HumanoidRootPart') or c.PrimaryPart or c:FindFirstChild('Torso') or c:FindFirstChild('Head'))
end
local function index_bot(object)
 local model=object:IsA('Model') and object or object:IsA('Humanoid') and object.Parent
 if model and model:IsA('Model') and model:FindFirstChildOfClass('Humanoid') and not Players:GetPlayerFromCharacter(model) then
  local camera=workspace.CurrentCamera
  if not camera or not model:IsDescendantOf(camera) then
   bots[model]=bots[model] or {Character=model,Name=model.Name,DisplayName=model.Name,is_bot=true}
  end
 end
end
local function record(player)
 local r={lines={},used=0,root=make('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},overlay)}
 r.head=circle(r.root)
 r.highlight=make('Highlight',{Enabled=false,Name='OcelEnemy'},gui)
 r.name=label(r.root,'',UDim2.fromOffset(240,18)); r.name.AnchorPoint=Vector2.new(.5,1)
 r.details=label(r.root,'',UDim2.fromOffset(240,32)); r.details.AnchorPoint=Vector2.new(.5,0)
 for _,text in ipairs({r.name,r.details}) do text.TextXAlignment=Enum.TextXAlignment.Center; text.TextStrokeTransparency=.1; text.TextSize=12; text.Visible=false end
 r.health=make('Frame',{BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=0,Visible=false},r.root)
 r.health_fill=make('Frame',{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),BorderSizePixel=0},r.health)
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
 if ok and ok2 then line(r,a,b,r.color or cfg.esp_color) end
end
local function eligible(p,camera)
 local c=p.Character; local h=c and c:FindFirstChildOfClass('Humanoid'); local root=character_root(c)
 return p~=me and h and h.Health>0 and root and (root.Position-camera.CFrame.Position).Magnitude<=cfg.distance and not (type(p)~='table' and cfg.team and me.Team~=nil and p.Team==me.Team)
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
 local stroke=r.head:FindFirstChildOfClass('UIStroke'); stroke.Color=r.color or cfg.esp_color; stroke.Thickness=cfg.width
end
local function screen_bounds(camera,c)
 local cf,size=c:GetBoundingBox(); local min,max=Vector2.new(math.huge,math.huge),Vector2.new(-math.huge,-math.huge)
 for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
  local p,on=project(camera,cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)); if not on then return end
  min=Vector2.new(math.min(min.X,p.X),math.min(min.Y,p.Y)); max=Vector2.new(math.max(max.X,p.X),math.max(max.Y,p.Y))
 end end end
 return min,max
end
local function boxes(r,camera,c,min,max)
 if not min then min,max=screen_bounds(camera,c) end
 if not min then return end
 local color=r.color or cfg.esp_color
 local tl,tr,bl,br=min,Vector2.new(max.X,min.Y),Vector2.new(min.X,max.Y),max
 if cfg.box_style=='Rectangle' then
  line(r,tl,tr,color); line(r,tr,br,color); line(r,br,bl,color); line(r,bl,tl,color)
 else
  local w,h=(max.X-min.X)*.23,(max.Y-min.Y)*.18
  for _,corner in ipairs({{tl,1,1},{tr,-1,1},{bl,1,-1},{br,-1,-1}}) do
   line(r,corner[1],corner[1]+Vector2.new(w*corner[2],0),color); line(r,corner[1],corner[1]+Vector2.new(0,h*corner[3]),color)
  end
 end
end
local function held_weapon(character)
 local tool=character:FindFirstChildOfClass('Tool')
 if tool then return tool.Name end
 for _,key in ipairs({'EquippedItem','EquippedWeapon','CurrentWeapon','ToolName'}) do
  local value=character:GetAttribute(key)
  if type(value)=='string' and value~='' then return value end
 end
 for _,object in ipairs(character:GetChildren()) do
  if object:IsA('Model') and (object:FindFirstChild('GunComponents') or object:FindFirstChild('ToolComponents')) then return object.Name end
 end
 return '—'
end
local function player_details(r,player,camera,c,min,max)
 if not min then return end
 local mid=(min.X+max.X)*.5
 r.name.Visible=cfg.esp_names; r.name.Text=type(player)=='table' and ('[BOT] '..c.Name) or (player.DisplayName..' (@'..player.Name..')')
 r.name.Position=UDim2.fromOffset(mid,min.Y-3); r.name.TextColor3=r.color
 local details={}
 if cfg.esp_distance then
  local origin=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
  table.insert(details,tostring(math.floor((character_root(c).Position-(origin and origin.Position or camera.CFrame.Position)).Magnitude))..' st')
 end
 if cfg.esp_weapon then table.insert(details,held_weapon(c)) end
 r.details.Visible=#details>0; r.details.Text=table.concat(details,'\n')
 r.details.Position=UDim2.fromOffset(mid,max.Y+3); r.details.TextColor3=r.color
 local humanoid=c:FindFirstChildOfClass('Humanoid')
 r.health.Visible=cfg.esp_health and humanoid~=nil
 if humanoid then
  local ratio=math.clamp(humanoid.Health/math.max(1,humanoid.MaxHealth),0,1)
  r.health.Position=UDim2.fromOffset(min.X-8,min.Y); r.health.Size=UDim2.fromOffset(4,math.max(1,max.Y-min.Y))
  r.health_fill.Size=UDim2.fromScale(1,ratio); r.health_fill.BackgroundColor3=Color3.fromRGB(240,65,65):Lerp(Color3.fromRGB(65,240,110),ratio)
 end
end
-- Do not fight the game's day/night controller by rewriting ClockTime.
local light_values={Brightness=2,Ambient=Color3.fromRGB(210,210,210),OutdoorAmbient=Color3.fromRGB(210,210,210),GlobalShadows=false,FogStart=1e6,FogEnd=1e7,ExposureCompensation=0}
local bright_states={}
local light_on=false
local function force_bright(object,values)
 if bright_states[object] then return end
 local state={values={},connections={}}
 bright_states[object]=state
 for key,value in pairs(values) do
  state.values[key]=object[key]
  table.insert(state.connections,object:GetPropertyChangedSignal(key):Connect(function()
   if hub.alive and light_on and cfg.bright and object[key]~=value then object[key]=value end
  end))
  if object[key]~=value then object[key]=value end
 end
end
local function atmosphere_bright(object)
 if object:IsA('Atmosphere') then force_bright(object,{Density=0,Haze=0,Glare=0}) end
end
local function restore_bright()
 light_on=false
 for object,state in pairs(bright_states) do
  for _,c in ipairs(state.connections) do c:Disconnect() end
  pcall(function() for key,value in pairs(state.values) do object[key]=value end end)
 end
 table.clear(bright_states)
end
local function update_bright()
 if cfg.bright and not light_on then
  light_on=true; force_bright(Lighting,light_values)
  for _,object in ipairs(Lighting:GetChildren()) do atmosphere_bright(object) end
 elseif not cfg.bright and light_on then restore_bright() end
end
connect(Lighting.ChildAdded,function(object)
 if light_on and cfg.bright then atmosphere_bright(object) end
end)
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
local tick_acc=0
local render_name='OcelHubCamera_'..tostring(math.floor(os.clock()*1e6))
Run:BindToRenderStep(render_name,Enum.RenderPriority.Camera.Value+2,function(dt)
 local camera=workspace.CurrentCamera; if not camera then return end
 fit(); local center=camera.ViewportSize*.5
 fov_circle.Visible=cfg.aim or cfg.silent; fov_circle.Position=UDim2.fromOffset(center.X-cfg.fov,center.Y-cfg.fov); fov_circle.Size=UDim2.fromOffset(cfg.fov*2,cfg.fov*2)
 local best=cfg.fov; target=nil
 local subjects=Players:GetPlayers()
 for model,bot in pairs(bots) do
  if not model:IsDescendantOf(workspace) or Players:GetPlayerFromCharacter(model) then
   local r=records[bot]; if r then r.root:Destroy(); r.highlight:Destroy(); records[bot]=nil end
   bots[model]=nil
  elseif cfg.bots then table.insert(subjects,bot)
  elseif records[bot] then records[bot].root.Visible=false; records[bot].highlight.Enabled=false end
 end
 for _,p in ipairs(subjects) do
  if p~=me then
   local r=records[p] or record(p); r.root.Visible=true; r.used=0; r.head.Visible=false; r.highlight.Enabled=false
   r.name.Visible=false; r.details.Visible=false; r.health.Visible=false
   if eligible(p,camera) then
     local c=p.Character; local part=c:FindFirstChild(cfg.part)
     local seen=clear_path(camera,c:FindFirstChild('Head') or character_root(c))
     r.color=cfg.esp_visibility and (seen and Color3.fromRGB(65,235,105) or Color3.fromRGB(245,65,65)) or cfg.esp_color
    r.highlight.Adornee=c; r.highlight.Enabled=cfg.enemies; r.highlight.FillColor=cfg.enemy_color; r.highlight.OutlineColor=cfg.enemy_color; r.highlight.FillTransparency=cfg.enemy_opacity; r.highlight.OutlineTransparency=cfg.outline_opacity; r.highlight.DepthMode=Enum.HighlightDepthMode[cfg.depth]
     if cfg.esp_visibility then r.highlight.FillColor=r.color; r.highlight.OutlineColor=r.color end
     local min,max=screen_bounds(camera,c)
     if cfg.boxes and min then boxes(r,camera,c,min,max) end
     if cfg.skeleton then skeleton(r,camera,c) end
     player_details(r,p,camera,c,min,max)
     if part and type(p)~='table' then local point,on=project(camera,part.Position); local dist=(point-center).Magnitude
     if on and dist<best and (not cfg.visible or clear_path(camera,part)) then best=dist; target=part end
    end
   end
   for i=r.used+1,#r.lines do r.lines[i].Visible=false end
  end
 end
  if cfg.aim and target and not panel.Visible then
   local point=target.Position+target.AssemblyLinearVelocity*cfg.aim_lead
   local desired=CFrame.lookAt(camera.CFrame.Position,point)
   if cfg.aim_mode=='Instant' then camera.CFrame=desired
   else camera.CFrame=camera.CFrame:Lerp(desired,1-math.exp(-cfg.smooth*dt)) end
  end
 update_bright()
 tick_acc=tick_acc+dt
 if tick_acc>.15 then
   tick_acc=0; view_chams(camera); enemy_chams(camera)
 end
end)
connect(Players.PlayerRemoving,function(p) local r=records[p]; if r then r.root:Destroy(); r.highlight:Destroy(); records[p]=nil end end)
connect(Input.InputBegan,function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.Insert then set_menu(not panel.Visible) end end)
local potato_states={}
local potato_queue={}
local potato_index=1
local potato_on=false
local function potato_set(object,key,value)
 local ok,old=pcall(function() return object[key] end)
 if not ok or old==value then return end
 local state=potato_states[object]
 if not state then state={}; potato_states[object]=state end
 if state[key]==nil then state[key]=old end
 pcall(function() object[key]=value end)
end
local function potato_apply(object)
 if not object.Parent then return end
 local ancestor=object
 while ancestor and ancestor~=workspace and ancestor~=Lighting do
  if ancestor==workspace.CurrentCamera or ancestor.Name=='OcelTracer' then return end
  if ancestor:IsA('Model') and ancestor:FindFirstChildOfClass('Humanoid') then return end
  ancestor=ancestor.Parent
 end
 if object:IsA('BasePart') then
  potato_set(object,'Material',Enum.Material.SmoothPlastic); potato_set(object,'Reflectance',0); potato_set(object,'CastShadow',false)
 elseif object:IsA('Decal') or object:IsA('Texture') then potato_set(object,'Transparency',1)
 elseif object:IsA('ParticleEmitter') or object:IsA('Trail') or object:IsA('Beam') or object:IsA('PostEffect') then potato_set(object,'Enabled',false)
 end
end
local function restore_potato()
 potato_on=false; table.clear(potato_queue); potato_index=1
 for object,state in pairs(potato_states) do
  for key,value in pairs(state) do pcall(function() object[key]=value end) end
 end
 table.clear(potato_states)
end
for _,root in ipairs({workspace,Lighting}) do
 connect(root.DescendantAdded,function(object) if potato_on then table.insert(potato_queue,object) end end)
end
connect(Run.Heartbeat,function()
 if cfg.potato and not potato_on then
  potato_on=true; potato_queue=workspace:GetDescendants(); potato_index=1
  for _,object in ipairs(Lighting:GetDescendants()) do table.insert(potato_queue,object) end
 elseif not cfg.potato and potato_on then restore_potato() end
 if potato_on then
  local last=math.min(#potato_queue,potato_index+199)
  for i=potato_index,last do potato_apply(potato_queue[i]) end
  potato_index=last+1
  if potato_index>#potato_queue then table.clear(potato_queue); potato_index=1 end
 end
end)
local resources={}
local resource_labels={}
local resource_pending={}
local function resource_kind(model)
 if not (model:IsA('Model') or model:IsA('BasePart')) or model:FindFirstChildOfClass('Humanoid') then return end
 local name=model.Name:lower()
 if name=='cloth' or name=='hemp' or name=='cloth plant' or name=='clothplant' then
  local ancestor=model.Parent
  while ancestor and ancestor~=workspace do
   local ancestor_name=ancestor.Name:lower()
   if ancestor:FindFirstChildOfClass('Humanoid') or ancestor==workspace.CurrentCamera then return end
   if ancestor_name=='cloth' or ancestor_name=='hemp' or ancestor_name=='cloth plant' or ancestor_name=='clothplant' then return end
   ancestor=ancestor.Parent
  end
  return 'cloth'
 end
 if not model:IsA('Model') then return end
 if name=='tree' then return 'tree' end
 if model:FindFirstChild('System') and (name:find('stone') or name:find('metal') or name:find('sulfur') or name:find('ore')) then return 'ore' end
end
local function index_resource(object)
 if not hub.alive or not object:IsDescendantOf(workspace) then return end
 index_bot(object)
 local kind=resource_kind(object)
 if kind then resources[object]=kind end
end
connect(workspace.DescendantAdded,function(object)
 if object:IsA('Humanoid') then resource_pending[object]=true end
 if object:IsA('Model') or object:IsA('BasePart') then resource_pending[object]=true end
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
  if object:IsA('Model') or object:IsA('BasePart') then index_resource(object) end
  if i%400==0 then task.wait() end
 end
end)
local function resource_position(model)
 if model:IsA('BasePart') then return model.Position end
 local part=model.PrimaryPart or model:FindFirstChildWhichIsA('BasePart',true)
 return part and part.Position
end
local function update_resources()
 for object in pairs(resource_pending) do index_resource(object); resource_pending[object]=nil end
 local camera=workspace.CurrentCamera; if not camera then return end
 local visible={}
 if cfg.trees or cfg.ores or cfg.cloth then
  for model,kind in pairs(resources) do
   if (kind=='tree' and cfg.trees) or (kind=='ore' and cfg.ores) or (kind=='cloth' and cfg.cloth) then
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
  text.Text=(item.kind=='tree' and 'TREE' or item.kind=='cloth' and 'CLOTH' or model.Name:upper())..'  ['..math.floor(item.distance)..' st]'
  text.TextColor3=cfg[item.kind..'_color']
 end
 for model,text in pairs(resource_labels) do if not wanted[model] then text:Destroy(); resource_labels[model]=nil end end
end
local item_data
pcall(function() item_data=require(RS.ItemData).Items end)
local selected_slot
local function equipped_item()
 if not selected_slot or not selected_slot.Parent or not selected_slot.Value then
  local player_gui=me:FindFirstChild('PlayerGui')
  selected_slot=nil
  if player_gui then
   for _,object in ipairs(player_gui:GetDescendants()) do
    if object.Name=='SelectedSlot' and object:IsA('ObjectValue') and object.Value and object.Value:FindFirstChild('ItemName') then selected_slot=object; break end
   end
  end
 end
 if not item_data then pcall(function() item_data=require(RS.ItemData).Items end) end
 local slot=selected_slot and selected_slot:IsA('ObjectValue') and selected_slot.Value
 local item=slot and slot:FindFirstChild('ItemName')
 local data=item and item_data and item_data[item.Value]
 if data and data.ToolInfo then return item.Value,data,slot end
end
local function equipped_tool()
 local name,data,slot=equipped_item()
 if data and data.Gather then return name,data,slot end
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
 local reach=cfg.farm_mode=='Magic' and cfg.magic_range or cfg.farm_range
 local camera=workspace.CurrentCamera
 local exclusions={me.Character}; if camera then table.insert(exclusions,camera) end
 local overlap=OverlapParams.new(); overlap.FilterType=Enum.RaycastFilterType.Exclude; overlap.FilterDescendantsInstances=exclusions
 local ray_params=RaycastParams.new(); ray_params.FilterType=Enum.RaycastFilterType.Exclude; ray_params.FilterDescendantsInstances=exclusions; ray_params.IgnoreWater=true
 local best,best_distance
 for _,part in ipairs(workspace:GetPartBoundsInRadius(head.Position,reach,overlap)) do
  local model,kind=resource_ancestor(part)
  local allowed=model and ((kind=='tree' and cfg.farm_trees and data.Gather.Wood) or (kind=='ore' and cfg.farm_ores and data.Gather.Stone))
  if allowed and part.CanQuery then
   local point=closest_point(part,head.Position)
   local offset=point-head.Position
   if offset.Magnitude<.01 then offset=part.Position-head.Position end
   if offset.Magnitude>.01 and offset.Magnitude<=reach then
    local hit=workspace:Raycast(head.Position,offset.Unit*reach,ray_params)
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
local combat_pending=false
local function stop_farm_animation()
 if farm_track then pcall(function() farm_track:Stop(.1); farm_track:Destroy() end); farm_track=nil end
end
local function farm_tick()
 if not cfg.auto_farm then farm_status.Text='Auto farm OFF. Equip a gathering tool. No movement.'; stop_farm_animation(); return end
 if panel.Visible then farm_status.Text='Paused while menu is open.'; return end
 if combat_pending and cfg.magic_tools and cfg.tools_auto then farm_status.Text='Paused: Magic Tools has a target.'; return end
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
local melee_modules={}
local melee_count=0
local melee_attack
for _,module in ipairs(game:GetDescendants()) do
 if module:IsA('ModuleScript') and module.Name=='MeleeClient' then
  local ok,exports=pcall(require,module)
  if ok and type(exports)=='table' and type(exports.Check)=='function' and not melee_modules[exports] then
   melee_modules[exports]=true
   local original=exports.Check
   local function extended_check(tool_name,...)
    local ray,hit=original(tool_name,...)
    if not hub.alive or not cfg.magic_tools or panel.Visible or (tool_name~='Rock' and tool_name~='Wooden Spear') then return ray,hit end
    local character=me.Character
    local head=character and character:FindFirstChild('Head')
    local humanoid=character and character:FindFirstChildOfClass('Humanoid')
    local camera=workspace.CurrentCamera
    if not camera or not head or not humanoid or humanoid.Health<=0 then return ray,hit end
    local center=camera.ViewportSize*.5
    local best=cfg.fov
    local chosen
    for _,player in ipairs(Players:GetPlayers()) do
     if eligible(player,camera) then
      local part=player.Character:FindFirstChild(cfg.part)
      if part and (part.Position-head.Position).Magnitude<=cfg.tools_range then
       local point,on=project(camera,part.Position)
       local score=(point-center).Magnitude
       if on and score<best and clear_path(camera,part) then best=score; chosen=part end
      end
     end
    end
    if not chosen then return ray,hit end
    local delta=chosen.Position-head.Position
    if delta.Magnitude<.001 then return ray,hit end
    -- Preserve the stock Hit -> Swing path and its tool name; do not move the character.
    return Ray.new(ray.Origin,delta.Unit),{Part=chosen,Position=chosen.Position}
   end
   exports.Check=extended_check
   if type(exports.Hit)=='function' then melee_attack=exports end
   table.insert(hub.restores,function() if exports.Check==extended_check then exports.Check=original end end)
   melee_count=melee_count+1
  end
 end
end
local tools_summary='Magic Tools adapters: '..melee_count
tools_status.Text=tools_summary..'\nEnable Magic Tools + auto attack, equip Rock / Wooden Spear, hide the menu.'
local tools_clock=0
connect(Run.Heartbeat,function(dt)
 tools_clock=tools_clock+dt
 if tools_clock<.1 then return end
 tools_clock=0
 combat_pending=false
 if not cfg.tools_auto then return end
 if not cfg.magic_tools then tools_status.Text=tools_summary..'\nAuto attack paused: enable Magic Tools.'; return end
 if panel.Visible then tools_status.Text=tools_summary..'\nAuto attack paused: menu open.'; return end
 if not melee_attack then tools_status.Text='Auto attack unavailable: MeleeClient.Hit missing.'; return end
 local name,data=equipped_item()
 if name~='Rock' and name~='Wooden Spear' then tools_status.Text=tools_summary..'\nSelect Rock or Wooden Spear in the hotbar.'; return end
 local character=me.Character; local humanoid=character and character:FindFirstChildOfClass('Humanoid')
 if not humanoid or humanoid.Health<=0 then return end
 local camera=workspace.CurrentCamera; if not camera then return end
 local system=RS:FindFirstChild('ToolSystem'); local remotes=system and system:FindFirstChild('RemoteEvents')
 local swing=remotes and remotes:FindFirstChild('Swing')
 if not swing or not swing:IsA('RemoteEvent') then tools_status.Text='Auto attack: Swing unavailable.'; return end
 local ok,err=pcall(function()
  local _,hit=melee_attack.Check(name)
  local part=hit and hit.Part
  local model=part and part:FindFirstAncestorOfClass('Model')
  local player=model and Players:GetPlayerFromCharacter(model)
  if not player or not eligible(player,camera) then tools_status.Text=tools_summary..'\nWaiting for an enemy in range / FOV.'; return end
  local point,on=project(camera,part.Position)
  if not on or (point-camera.ViewportSize*.5).Magnitude>cfg.fov or not clear_path(camera,part) then return end
  combat_pending=true
  if os.clock()<next_farm or farm_busy then return end
  local info=data.ToolInfo
  next_farm=os.clock()+math.max(.35,info.HitInterval or ((info.PlayTime or .5)+(info.WaitTime or .25)))
  local head=character:FindFirstChild('Head')
  if not head then return end
  local direction=part.Position-head.Position
  if direction.Magnitude<.001 or direction.Magnitude>cfg.tools_range then return end
  -- Hitmarker.Show is client-only; sending the request is not proof of damage.
  swing:FireServer(direction.Unit,name,hit)
  tools_status.Text=tools_summary..'\nAuto → '..player.Name..' / '..name..' (damage not verified)'
 end)
 if not ok then next_farm=os.clock()+2; tools_status.Text='Auto attack: '..tostring(err) end
end)
status.Text='OCEL / client adapter\nWeapon modules connected: '..hooked..'\n'..(hooked>0 and 'Silent ray adapter installed. Server hit validation still applies.' or 'Silent / tracers unavailable: executor hook APIs or module access missing.')
function hub:Destroy()
 if not self.alive then return end; self.alive=false
 Run:UnbindFromRenderStep(render_name)
 for _,c in ipairs(self.connections) do c:Disconnect() end
 for exports,original in pairs(self.hooks) do exports.Shoot=original end
 for _,restore in ipairs(self.restores) do restore() end
 for part,state in pairs(modified) do restore_part(part,state) end
 for part,state in pairs(enemy_modified) do restore_part(part,state) end
 stop_farm_animation()
 restore_potato()
 restore_bright()
 for object in pairs(self.objects) do object:Destroy() end
 gui:Destroy()
 if env.OcelHub==self then env.OcelHub=nil end
end
connect(exit.Activated,function() hub:Destroy() end)
