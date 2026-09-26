local MazxBoot = { Stage = "starting", Finished = false, Gui = nil, Panel = nil, Label = nil }

function MazxBoot:Show(message, failed)
	warn("[Mazxhub/android-startup-1] " .. tostring(message))
	pcall(function()
		local localPlayer = game:GetService("Players").LocalPlayer
		local parent = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
		if not parent then return end
		if not self.Panel or not self.Panel.Parent then
			local previous = parent:FindFirstChild("MazxhubStartup")
			if previous then previous:Destroy() end
			local screen = Instance.new("ScreenGui")
			screen.Name = "MazxhubStartup"
			screen.ResetOnSpawn = false
			screen.DisplayOrder = 1000
			screen.Parent = parent
			self.Panel = screen
			local body = Instance.new("Frame")
			body.Size = UDim2.new(0.9, 0, 0, 200)
			body.Position = UDim2.new(0.05, 0, 0.12, 0)
			body.BackgroundColor3 = Color3.fromRGB(15, 25, 40)
			body.Parent = screen
			local text = Instance.new("TextLabel")
			text.Size = UDim2.new(1, -20, 1, -56)
			text.Position = UDim2.new(0, 10, 0, 10)
			text.BackgroundTransparency = 1
			text.Font = Enum.Font.SourceSans
			text.TextSize = 16
			text.TextWrapped = true
			text.TextXAlignment = Enum.TextXAlignment.Left
			text.TextYAlignment = Enum.TextYAlignment.Top
			text.TextColor3 = Color3.fromRGB(210, 235, 255)
			text.Parent = body
			self.Label = text
			local dismiss = Instance.new("TextButton")
			dismiss.Size = UDim2.new(1, -20, 0, 36)
			dismiss.Position = UDim2.new(0, 10, 1, -44)
			dismiss.Text = "Close / ปิด"
			dismiss.Font = Enum.Font.SourceSans
			dismiss.TextSize = 18
			dismiss.Parent = body
			dismiss.Activated:Connect(function() screen:Destroy() end)
		end
		self.Label.TextColor3 = failed and Color3.fromRGB(255, 160, 160) or Color3.fromRGB(210, 235, 255)
		self.Label.Text = "Mazxhub • android-startup-1\n" .. tostring(message):sub(1, 900)
	end)
end

function MazxBoot:Fail(message)
	self.Finished = true
	if self.Gui then pcall(function() self.Gui:Destroy() end) end
	self:Show("ERROR at " .. self.Stage .. "\n" .. tostring(message)
		.. "\nถ่ายภาพข้อความนี้ส่งกลับมา / Send a screenshot of this error", true)
end

MazxBoot:Show("Loading / กำลังโหลด...", false)
task.delay(12, function()
	if not MazxBoot.Finished then
		MazxBoot:Show("Still loading: " .. MazxBoot.Stage .. "\nยังโหลดไม่เสร็จ กรุณาถ่ายภาพข้อความนี้", false)
	end
end)

local function startMazxhub()
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local GuiService       = game:GetService("GuiService")

MazxBoot.Stage = "waiting for LocalPlayer / PlayerGui"
local player = Players.LocalPlayer
local playerDeadline = os.clock() + 20
while not player and os.clock() < playerDeadline do
	task.wait(0.1)
	player = Players.LocalPlayer
end
assert(player, "LocalPlayer unavailable after 20 seconds; run after entering the game")
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 20)
assert(playerGui, "PlayerGui unavailable after 20 seconds")
MazxBoot:Show("Creating menu / กำลังสร้างเมนู...", false)
local Camera    = workspace.CurrentCamera

for _, g in ipairs(playerGui:GetChildren()) do
	if g:IsA("ScreenGui") and g.Name == "LuminUI" then
		g:Destroy()
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	local char = plr.Character
	if char then
		for _, d in ipairs(char:GetDescendants()) do
			if d.Name == "LuminESP"
			or d.Name == "LuminESPTag"
			or d.Name == "LuminESPLine" then
				d:Destroy()
			end
		end
	end
end

local LUMIN_RUN_TOKEN = {}
_G.__LUMIN_RUNNING = LUMIN_RUN_TOKEN
MazxBoot.Perf = { NpcScans = 0, BossScans = 0 }
task.delay(15, function()
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	print(string.format("[Mazxhub Perf] first 15s: NPC scans=%d, boss scans=%d (idle should be 0)",
		MazxBoot.Perf.NpcScans, MazxBoot.Perf.BossScans))
end)

local T = {
	Bg        = Color3.fromRGB(7, 12, 20),
	Sidebar   = Color3.fromRGB(9, 17, 28),
	Card      = Color3.fromRGB(14, 25, 39),
	CardHover = Color3.fromRGB(22, 42, 60),
	Stroke    = Color3.fromRGB(36, 69, 91),
	Track     = Color3.fromRGB(32, 49, 65),
	Text      = Color3.fromRGB(228, 243, 252),
	Sub       = Color3.fromRGB(139, 168, 190),
	Accent    = Color3.fromRGB(88, 204, 255),
	AccentSoft = Color3.fromRGB(19, 54, 76),
	Ink       = Color3.fromRGB(5, 22, 33),
	Mint      = Color3.fromRGB(110, 231, 183),
	Danger    = Color3.fromRGB(190, 70, 80),
	Gold      = Color3.fromRGB(230, 180, 80),
}

local TI  = TweenInfo.new(0.20, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TIB = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local I18N = {
	-- Start in English every time; the language dropdown can still switch to Thai.
	Language = "en",
	Entries = {}, Bindings = {},
}
for _, entry in ipairs({
	{"ฟาร์ม", "Farm"}, {"สถานะ", "Status"}, {"โลก", "World"},
	{"ต่อสู้", "Combat"}, {"ตัวละคร", "Player"}, {"การแสดงผล", "Visuals"},
	{"การมองเห็น", "Visibility"},
	{"เพิ่มความสว่าง • ปิดเงา • ล็อกแสงกลางวัน", "Increase brightness • disable shadows • lock daylight"},
	{"เปิด Full Bright แล้ว", "Full Bright enabled"},
	{"ปิด Full Bright และคืนค่าแสงเดิมแล้ว", "Full Bright disabled; lighting restored"},
	{"วาร์ป", "Teleport"}, {"ตั้งค่า", "Setting"}, {"โปรไฟล์", "Profile"},
	{"อุปกรณ์", "Loadout"}, {"ค้นหา", "Search"}, {"RightShift  /  เมนู", "RightShift  /  Menu"},
	{"ภาษา", "Language"}, {"ภาษาเมนู", "Menu language"},
	{"แตะรูปเพื่อเปิดเมนู", "Tap avatar to open menu"},
	{"ปรับค่า →", "Settings →"}, {"← ตัวเลือก", "← Controls"},
	{"ใช้ปุ่มลอย", "Use floating button"},
	{"อาวุธที่ถืออยู่", "Equipped weapon"},
	{"สกิลออโต้บนมือถือขึ้นกับการรองรับปุ่มจำลองของตัวรัน", "Mobile Auto Skills requires simulated-key support from your runtime"},
	{"มือถือ: เลือกอาวุธบนแถบเกมก่อน แล้วใช้ ‘อาวุธที่ถืออยู่’", "Mobile: select a weapon in the game, then use ‘Equipped weapon’"},
	{"สกิลอัตโนมัติ", "Auto Skills"},
	{"กดสกิลขณะฟาร์มใกล้เป้าหมาย พักเมื่อเปิดเมนูหรือแชต", "Uses skills near farm targets; pauses for menus and chat"},
	{"ช่วงเวลากดซ้ำ ไม่ใช่คูลดาวน์จริงของเกม", "Repeat interval, not the game's actual cooldown"},
	{"เปิดสกิลอัตโนมัติแล้ว", "Auto Skills enabled"},
	{"ปิดสกิลอัตโนมัติแล้ว", "Auto Skills disabled"},
	{"ส่งปุ่มสกิลไม่สำเร็จ", "Unable to send skill input"},
	{"เปลี่ยนข้อความทุกหน้าทันที", "Apply to every menu immediately"},
	{"พร้อม", "Ready"}, {"ฟาร์มมอน (เปิด/ปิด)", "Mob farm (on/off)"},
	{"ต้องเลือกมอนก่อน", "Select a mob first"}, {"ปิดฟาร์มมอนแล้ว", "Mob farm stopped"},
	{"เลือกมอน", "Select mob"}, {"เลือกอาวุธก่อนฟาร์ม", "Farm weapon"},
	{"ตรวจจับจากช่องไอเทมและ Backpack", "Hotbar slots and Backpack tools"},
	{"อัตโนมัติ", "Automatic"}, {"หมัด / Fist", "Fist"},
	{"ไอเทมไม่ทราบชื่อ", "Unnamed item"},
	{"ยังอ่าน Hotbar ไม่ได้ • แสดงเฉพาะ Tool ที่พบ", "Hotbar not detected; showing available Tools"},
	{"Hotbar ไม่มีไอเทมที่อ่านได้", "No readable items in Hotbar"},
	{"Auto รับเควส", "Auto quest"}, {"ขนาดฮิตบ็อกซ์", "Hitbox Size"},
	{"ขนาด hitbox", "Hitbox dimensions"}, {"ระยะใต้เป้าหมาย", "Depth Under"},
	{"ถอยเมื่อโดนตี", "Retreat on damage"}, {"ระยะถอย", "Retreat distance"},
	{"ความลึกหลบเมื่อโดนตี", "Damage dodge depth"},
	{"หลบลงใต้พื้นเมื่อเสียเลือด", "Dive below the ground when damaged"},
	{"ระยะถอยหลังครบคอมโบ", "Retreat distance after a full combo"},
	{"ตั้งค่าระยะและฮิตบ็อกซ์", "Range and hitbox settings"},
	{"ตั้งค่าการถอย", "Retreat settings"},
	{"ระยะห่างจากมอนตอนถอย", "Distance from the target while retreating"},
	{"เวลารอก่อนกลับไปตี", "Wait before returning"},
	{"หยุดโจมตีระหว่างถอย แล้วกลับไปฟาร์มต่อ", "Pause attacks while retreating, then resume farming"},
	{"ระยะโจมตี", "Attack range"},
	{"ระยะเริ่มตี • เซิร์ฟเวอร์เป็นผู้ตรวจว่าตีโดน", "Attack trigger range; server validates hits"},
	{"ระยะใต้ตัวมอน (แนะนำ 2)", "Distance below target (suggested: 2)"},
	{"ฟาร์มบอส (เปิด/ปิด)", "Boss farm (on/off)"}, {"ต้องเลือกบอสก่อน", "Select a boss first"},
	{"เก็บของหลังบอสตาย", "Auto collect boss loot"},
	{"เก็บกล่องและไอเทมใกล้บอสที่ฟาร์ม", "Collect chests and items near the farmed boss"},
	{"พักฟาร์มระหว่างเปิด Auto Quest Betty", "Farming pauses while Auto Quest Betty is enabled"},
	{"ไอดีนี้เคยผ่าน Chaka แล้ว", "This account has already visited Chaka"},
	{"ครบ 4 ตัวแล้ว หยุด Quest 1", "Four kills reached; Quest 1 stopped"},
	{"กลับ Kazu แล้ว ห้ามย้อน Noote", "Returned to Kazu; Noote will be skipped"},
	{"จำขั้นตอนในตัวรันนี้ ไม่ใช่การยืนยันจากเซิร์ฟเวอร์", "Progress is stored locally, not confirmed by the server"},
	{"กลับ Betty แล้ว รอ Gemstone1 ชิ้นใหม่", "Returned to Betty; waiting for another Gemstone1"},
	{"รับพัสดุจาก MoldySugar ไปคุย Elara แล้วกลับ MoldySugar", "Request the package from MoldySugar, talk to Elara, then return to MoldySugar"},
	{"กลับ MoldySugar แล้ว หยุด Quest 3", "Returned to MoldySugar; Quest 3 stopped"},
	{"ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 3 ใหม่เมื่อพร้อม", "Character changed or died; restart Quest 3 when ready"},
	{"เก็บ Lost Page1 ถึง Lost Page5 แล้วกลับ Kona", "Collect Lost Page1 through Lost Page5, then return to Kona"},
	{"กลับ Kona แล้ว หยุด Quest 4", "Returned to Kona; Quest 4 stopped"},
	{"ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 4 ใหม่เมื่อพร้อม", "Character changed or died; restart Quest 4 when ready"},
	{"เก็บเนื้อหมี 4 ตัว แล้วกลับ Lucy", "Collect 4 bear meat, then return to Lucy"},
	{"กลับ Lucy แล้ว หยุด Quest 5", "Returned to Lucy; Quest 5 stopped"},
	{"ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 5 ใหม่เมื่อพร้อม", "Character changed or died; restart Quest 5 when ready"},
	{"ไปหา Betty รับเควส แล้วกด T ค้าง 1 วินาทีที่ Gemstone1", "Visit Betty, request the quest, then hold T for 1 second at Gemstone1"},
	{"ปิด Auto Quest Betty", "Auto Quest Betty off"},
	{"รอปิดเมนูหรือช่องแชต", "Waiting for menus or chat to close"},
	{"รอตัวละครพร้อม", "Waiting for character"},
	{"รอ Betty หรือระบบเควส", "Waiting for Betty or quest service"},
	{"กำลังไปหา Betty", "Going to Betty"},
	{"ส่งคำขอเควส Betty แล้ว", "Betty quest request sent"},
	{"รอ Gemstone1", "Waiting for Gemstone1"},
	{"กำลังเก็บ Gemstone1", "Collecting Gemstone1"},
	{"Gemstone1 หายไป รอชิ้นใหม่", "Gemstone1 disappeared; waiting for another"},
	{"ยังยืนยันการเก็บไม่ได้ รอไอเทมเปลี่ยนหรือเปิดใหม่", "Pickup unconfirmed; waiting for item change or restart"},
	{"Auto Quest Betty ขัดข้อง ลองใหม่ใน 3 วินาที", "Auto Quest Betty error; retrying in 3 seconds"},
	{"เลือกบอส", "Select boss"}, {"เลือกเป้าหมายก่อนเปิดฟาร์มบอส", "Choose a target before farming"},
	{"โจมตีอัตโนมัติ", "Auto attack"}, {"เริ่มและหยุดพร้อมสวิตช์ฟาร์ม", "Starts and stops with farming"},
	{"ความเร็วโจมตี", "Attack interval"}, {"ไม่รบกวนเมนูและช่องพิมพ์", "Pauses while using menus or typing"},
	{"ตีถี่", "Fast Attack"}, {"ซ่อนท่าโจมตีพื้นฐาน", "No Swing Animation"},
	{"ความสูงเหนือหัวมอน", "Height Above Head"},
	{"อยู่เหนือหัวมอนแล้วตีลงมา ไม่วาปหนี", "Stay above the target's head and attack without retreating"},
	{"เควส", "Quest"}, {"กำลังไปหา Krue...", "Going to Krue..."},
	{"หา Krue หรือ SignalEvent ไม่เจอ", "Krue or SignalEvent not found"},
	{"⟶ วาปหา Krue + เควส Bandit", "⟶ Krue + Bandit quest"},
	{"⟶ วาปหา Krue + เควส Boss", "⟶ Krue + boss quest"},
	{"บอสนี้ยังไม่มีข้อมูลเควส", "No quest data for this boss"},
	{"↻ เช็ค ActiveNpcs", "↻ Check ActiveNpcs"}, {"ไม่พบ ActiveNpcs", "ActiveNpcs not found"},
	{"⟶ วาปไปมอนที่เลือก", "⟶ Teleport to selected target"}, {"ไม่พบมอน", "Target not found"},
	{"⟶ ขยาย Hitbox เดี๋ยวนี้", "⟶ Expand hitbox now"}, {"ขยายแล้ว", "Hitbox expanded"},
	{"ทดสอบ", "Test"}, {"⟶ ตี 1 ครั้ง", "⟶ Attack once"}, {"ตี 1 ครั้ง", "Attacked once"},
	{"สถานะบอส / เวลาเกิด", "Boss status / respawn time"},
	{"เวลาประมาณจากการตาย → เกิดที่ตรวจพบในเซสชันนี้\nถ้าข้อมูลบอสยังไม่โหลด อาจยังไม่พบแม้บอสเกิดแล้ว",
	 "Estimates use deaths and spawns seen this session.\nUnloaded bosses may not appear here yet."},
	{"กำลังตรวจสอบ...", "Checking..."}, {"ยังไม่พบในเซสชันนี้", "Not seen this session"},
	{"เกิดแล้ว • พร้อมฟาร์ม", "Alive • ready to farm"}, {"ยังไม่พบข้อมูลโซน", "Zone data unavailable"},
	{"ถึงเวลาประมาณแล้ว • รอตรวจพบบอส", "Estimate reached • awaiting boss"},
	{"ตายแล้ว • ยังไม่ทราบเวลาเกิด", "Dead • respawn time unknown"},
	{"ยังไม่พบ • ยังไม่ทราบเวลาเกิด", "Not found • respawn time unknown"},
	{"สภาพแวดล้อม", "Environment"}, {"No Fog (ลบหมอก)", "Remove fog"},
	{"ลบ Atmosphere", "Remove atmosphere"}, {"ระยะหมอก", "Fog End"},
	{"ระยะไกลสุดของหมอก", "Maximum fog distance"}, {"— ยังไม่มีฟีเจอร์ —", "— No features yet —"},
	{"การเคลื่อนที่", "Movement"}, {"วิ่งไว", "Speed boost"},
	{"ปิดวิ่งไวแล้ว", "Speed boost disabled"}, {"ความเร็ววิ่ง", "Walk speed"},
	{"ค่าเริ่มต้นที่แนะนำ 40", "Suggested starting value: 40"},
	{"กระโดดสูง", "High jump"}, {"ปิดกระโดดสูงแล้ว", "High jump disabled"},
	{"แรงกระโดด", "Jump power"}, {"ปรับได้ทั้งเกมที่ใช้ JumpPower และ JumpHeight", "Supports JumpPower and JumpHeight"},
	{"การชน", "Collision"}, {"ทะลุสิ่งกีดขวาง", "No Clip"},
	{"เปิด No Clip", "No Clip enabled"}, {"ปิด No Clip และคืนค่าการชนแล้ว", "No Clip disabled; collision restored"},
	{"ปิดสวิตช์เพื่อคืนค่าตัวละครเดิม", "Switch off to restore original values"},
	{"ESP ผู้เล่น", "Player ESP"}, {"เส้น ESP", "ESP Line"}, {"เส้นขอบ ESP", "ESP Outline"},
	{"เส้นจากกึ่งกลางล่างจอ → ผู้เล่น / NPC / บอสที่เปิด ESP", "Bottom-center tracers to players and enabled NPCs / bosses"},
	{"ESP สีหลัก", "ESP primary color"}, {"ESP สี Outline", "ESP outline color"},
	{"ESP ระยะสูงสุด", "ESP maximum distance"}, {"ระยะการแสดงผลสูงสุด", "Max render distance"},
	{"ESP NPC ใน ActiveNpcs", "NPC ESP in ActiveNpcs"},
	{"Bandit = สีแดง  •  Civilian = สีเขียว", "Bandit = red  •  Civilian = green"},
	{"ESP บอสทั้งหมด (เปิด/ปิด)", "All boss ESP (on/off)"},
	{"สีทอง • เลือกบอสที่ต้องการแสดงด้านล่าง", "Gold • choose which bosses to show below"},
	{"NPCs — Windy Peak / Misc", "NPCs — Windy Peak / Misc"},
	{"เลือก NPC ที่จะวาป", "Choose an NPC to teleport to"},
	{"⟶ วาปไป NPC ที่เลือก", "⟶ Teleport to selected NPC"},
	{"↻ รีเฟรชรายชื่อ", "↻ Refresh list"}, {"วาปด่วนรายตัว", "Quick teleport"},
	{"อื่น ๆ", "Other"}, {"⟶ จุดเกิด", "⟶ Spawn"},
	{"⟶ ขึ้นฟ้า (+100)", "⟶ Move up (+100)"}, {"⟶ ลงพื้น (Raycast)", "⟶ Ground (Raycast)"},
	{"ป้ายชื่อผู้เล่น", "Player labels"}, {"ปุ่มลัด", "Use keybind"},
	{"รูปแบบป้ายชื่อ", "Label layout"}, {"การจัดวางข้อความ", "Stacking style"},
	{"เรียงซ้อน", "Stacked"}, {"บรรทัดเดียว", "Inline"}, {"กะทัดรัด", "Compact"},
	{"ขนาดป้ายชื่อ", "Label scale"}, {"ตัวคูณขนาดตัวอักษร", "Text size multiplier"},
	{"แสดงระยะทาง", "Show distance"}, {"ซ่อนขณะเล็ง", "Hide when aiming"},
	{"หน้าต่างเมนู", "Interface"}, {"เบลอพื้นหลัง", "Blur background"},
	{"แอนิเมชัน", "Animations"}, {"ความทึบของเมนู", "UI opacity"},
	{"ความโปร่งใสของหน้าต่าง", "Panel transparency"},
	{"ไม่มีตัวละคร", "no character"}, {"ไม่พบจุดอ้างอิงตัวละคร", "no hrp"},
}) do
	local pair = { th = entry[1], en = entry[2] }
	I18N.Entries[entry[1]], I18N.Entries[entry[2]] = pair, pair
end

function I18N:Text(raw)
	raw = tostring(raw or "")
	local entry = self.Entries[raw]
	if entry then return entry[self.Language] end
	if self.Language == "th" then return raw end
	local a, b, c, d
	a, b = raw:match("^ช่อง (%d+) — (.+)$")
	if a then return "Slot " .. a .. " — " .. self:Text(b) end
	a = raw:match("^พบไอเทมใน Hotbar (%d+) ช่อง$")
	if a then return "Detected " .. a .. " occupied Hotbar slots" end
	a = raw:match("^ช่อง (%d+)$")
	if a then return "Slot " .. a end
	a = raw:match("^อาวุธ: (.+)$")
	if a then return "Weapon: " .. self:Text(a) end
	a, b = raw:match("^ฟาร์ม (.+) %((%d+) ตัว%)$")
	if a then return "Farming " .. a .. " (" .. b .. " targets)" end
	a = raw:match("^ฟาร์ม (.+) %(boss%)$")
	if a then return "Farming " .. a .. " (boss)" end
	a = raw:match("^รอ (.+) เกิด%.%.%.$")
	if a then return "Waiting for " .. a .. " to spawn..." end
	a = raw:match("^ปิดฟาร์ม (.+) แล้ว$")
	if a then return "Stopped farming " .. a end
	a = raw:match("^รับเควส (.+) แล้ว$")
	if a then return "Accepted quest: " .. a end
	a = raw:match("^(.+) ยังไม่เกิด — รอก่อนรับเควส Boss$")
	if a then return a .. " has not spawned; waiting before accepting quest" end
	a, b, c, d = raw:match("^ทั้งหมด (%d+) | Bandit (%d+) | Civil (%d+) | Boss (%d+)$")
	if a then return "Total " .. a .. " | Bandit " .. b .. " | Civil " .. c .. " | Boss " .. d end
	a = raw:match("^วาป → (.+)$")
	if a then return "Teleport → " .. a end
	a = raw:match("^ไม่พบ: (.+)$")
	if a then return "Not found: " .. a end
	a = raw:match("^ล้มเหลว: (.+)$")
	if a then return "Failed: " .. self:Text(a) end
	a, b = raw:match("^เจอ (%d+) / (%d+)$")
	if a then return "Found " .. a .. " / " .. b end
	a = raw:match("^เปิดวิ่งไว: (.+)$")
	if a then return "Speed boost: " .. a end
	a = raw:match("^เปิดกระโดดสูง: (.+)$")
	if a then return "High jump: " .. a end
	a, b = raw:match("^(.-) | รอบที่วัดได้ ~(.+)$")
	if a then return self:Text(a) .. " | Measured interval ~" .. b end
	a = raw:match("^พบล่าสุด (.+)$")
	if a then return "Last seen " .. a end
	a = raw:match("^คาดว่าจะเกิดใน ~(.+)$")
	if a then return "Estimated respawn in ~" .. a end
	return raw
end

function I18N:Bind(object, property)
	local binding = { Object = object, Property = property, Source = object[property] }
	local function render()
		binding.Rendered = self:Text(binding.Source)
		object[property] = binding.Rendered
	end
	binding.Render = render
	self.Bindings[binding] = true
	render()
	binding.Change = object:GetPropertyChangedSignal(property):Connect(function()
		local value = object[property]
		if value == binding.Rendered then return end
		binding.Source = value
		render()
	end)
	binding.Destroy = object.Destroying:Connect(function()
		self.Bindings[binding] = nil
		binding.Change:Disconnect()
		binding.Destroy:Disconnect()
	end)
end

function I18N:SetLanguage(language)
	if language ~= "th" and language ~= "en" then return end
	for binding in pairs(self.Bindings) do
		local value = binding.Object[binding.Property]
		if value ~= binding.Rendered then binding.Source = value end
	end
	self.Language = language
	_G.__LUMIN_LANGUAGE = language
	for binding in pairs(self.Bindings) do binding.Render() end
end

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	if class == "TextLabel" or class == "TextButton" then I18N:Bind(o, "Text") end
	if class == "TextBox" then I18N:Bind(o, "PlaceholderText") end
	return o
end

local function corner(p, r)
	new("UICorner", {CornerRadius = UDim.new(0, r or 10)}, p)
end

local function stroke(p, c, t)
	new("UIStroke", {
		Color = c or T.Stroke, Thickness = t or 1, Transparency = 0.4,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, p)
end

local function pad(p, top, bot, left, right)
	new("UIPadding", {
		PaddingTop    = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bot   or top),
		PaddingLeft   = UDim.new(0, left  or top),
		PaddingRight  = UDim.new(0, right or left or top),
	}, p)
end

local function label(parent, text, size, color, font, pos, sz)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Text = text, TextSize = size, TextColor3 = color,
		Font = font or Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = pos or UDim2.new(0, 0, 0, 0),
		Size     = sz  or UDim2.new(1, 0, 1, 0),
	}, parent)
end

local function tween(o, p, i)
	TweenService:Create(o, i or TI, p):Play()
end

MazxBoot.Stage = "creating ScreenGui"
local gui = new("ScreenGui", {
	Name = "LuminUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 50,
}, playerGui)
MazxBoot.Gui = gui

local MobileUI = {
	Touch = UserInputService.TouchEnabled, Compact = false, Column = 1,
	Pages = {}, Connections = {}, Drags = {}, ScrollLocks = {},
}
MobileUI.Surface = new("Frame", {
	Name = "SafeControls", Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1, BorderSizePixel = 0,
}, gui)

function MobileUI:Connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function MobileUI:OwnsMove(held, input)
	return held and (input == held or (held.UserInputType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseMovement))
end

function MobileUI:LockScroll(node)
	local locked = {}
	while node and node ~= gui do
		if node:IsA("ScrollingFrame") then
			local state = self.ScrollLocks[node]
			if not state then state = { Count = 0, Enabled = node.ScrollingEnabled }; self.ScrollLocks[node] = state end
			state.Count += 1
			node.ScrollingEnabled = false
			table.insert(locked, node)
		end
		node = node.Parent
	end
	return function()
		for _, frame in ipairs(locked) do
			local state = self.ScrollLocks[frame]
			if state then
				state.Count -= 1
				if state.Count <= 0 then
					if frame.Parent then frame.ScrollingEnabled = state.Enabled end
					self.ScrollLocks[frame] = nil
				end
			end
		end
		locked = {}
	end
end

function MobileUI:CancelDrags()
	for cancel in pairs(self.Drags) do cancel() end
end

local fab = new("ImageButton", {
	Name = "Fab",
	Size = UDim2.fromOffset(52, 52),
	Position = UDim2.new(0, 28, 0.5, -26),
	BackgroundColor3 = T.Card, AutoButtonColor = false,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
}, MobileUI.Surface)
corner(fab, 26); stroke(fab, T.Accent, 1.5)

local Appearance = { Opacity = 96 }
local main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(740, 500),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = T.Bg, BackgroundTransparency = 1 - Appearance.Opacity / 100,
	BorderSizePixel = 0, Visible = false,
}, MobileUI.Surface)
corner(main, 6); stroke(main, T.Stroke, 1)
new("UIGradient", {
	Rotation = 90,
	Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(185, 216, 245)),
}, main)

-- Static HUD corner accents: no render-loop work or external textures.
do
	for _, edge in ipairs({ {0, 0}, {1, 0}, {0, 1}, {1, 1} }) do
		new("Frame", {
			Name = "TechCornerH", AnchorPoint = Vector2.new(edge[1], edge[2]),
			Position = UDim2.new(edge[1], edge[1] == 0 and 7 or -7, edge[2], edge[2] == 0 and 4 or -4),
			Size = UDim2.fromOffset(20, 2), BackgroundColor3 = T.Accent,
			BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 8,
		}, main)
		new("Frame", {
			Name = "TechCornerV", AnchorPoint = Vector2.new(edge[1], edge[2]),
			Position = UDim2.new(edge[1], edge[1] == 0 and 4 or -4, edge[2], edge[2] == 0 and 7 or -7),
			Size = UDim2.fromOffset(2, 16), BackgroundColor3 = T.Accent,
			BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 8,
		}, main)
	end
end

local sidebar = new("Frame", {
	Size = UDim2.new(0, 96, 1, 0),
	BackgroundColor3 = T.Sidebar, BackgroundTransparency = 1 - Appearance.Opacity / 100,
	BorderSizePixel = 0,
}, main)
corner(sidebar, 6)
local sidebarEdge = new("Frame", {
	Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -16, 0, 0),
	BackgroundColor3 = T.Sidebar, BackgroundTransparency = 1 - Appearance.Opacity / 100,
	BorderSizePixel = 0,
}, sidebar)

-- Thin separator between the left navigation and page content.
local sidebarDivider = new("Frame", {
	Name = "SidebarDivider",
	Size = UDim2.new(0, 1, 1, -24),
	Position = UDim2.new(1, -1, 0, 12),
	BackgroundColor3 = T.Stroke,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	ZIndex = 3,
}, sidebar)

function Appearance:SetOpacity(value)
	self.Opacity = math.clamp(value, 0, 100)
	local transparency = 1 - self.Opacity / 100
	main.BackgroundTransparency = transparency
	sidebar.BackgroundTransparency = transparency
	sidebarEdge.BackgroundTransparency = transparency
end

local head = new("Frame", {Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1}, sidebar)
local ava = new("ImageLabel", {
	Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0.5, -15, 0, 12),
	BackgroundColor3 = T.Card, BorderSizePixel = 0,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
}, head)
corner(ava, 17)
stroke(ava, T.Accent)
local brandLabel = label(head, "M A Z X", 10, T.Accent, Enum.Font.Code, UDim2.new(0, 0, 0, 46), UDim2.new(1, 0, 0, 16))
brandLabel.TextXAlignment = Enum.TextXAlignment.Center
new("Frame", {
	Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 0, 70),
	BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.6, BorderSizePixel = 0,
}, sidebar)
local menuHint = label(sidebar, MobileUI.Touch and "Menu" or "RightShift", 9, T.Sub, Enum.Font.Gotham,
	UDim2.new(0, 8, 1, -28), UDim2.new(1, -16, 0, 18))
menuHint.TextXAlignment = Enum.TextXAlignment.Center

local navList = new("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -136), Position = UDim2.new(0, 0, 0, 88),
	BackgroundTransparency = 1,
	BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
	ScrollBarImageColor3 = T.Accent,
}, sidebar)
local navLayout = new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, navList)
pad(navList, 0, 0, 10, 10)

local pages          = {}
local activeNavSet   = nil

function MobileUI:NavIcon(parent, name)
	local frame = new("Frame", { Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0.5, -10, 0, 1), BackgroundTransparency = 1 }, parent)
	local fills, outlines = {}, {}
	local function shape(x, y, w, h, round, rotation, hollow)
		local part = new("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
			BackgroundColor3 = T.Sub, BorderSizePixel = 0, Rotation = rotation or 0,
			BackgroundTransparency = hollow and 1 or 0 }, frame)
		if round then corner(part, round) end
		if hollow then table.insert(outlines, new("UIStroke", {Color=T.Sub, Thickness=1.4}, part))
		else table.insert(fills, part) end
	end
	if name == "Farm" then
		shape(8, 1, 3, 18, 1, 42); shape(8, 1, 3, 18, 1, -42)
		shape(1, 2, 7, 3, 1, -42); shape(12, 2, 7, 3, 1, 42)
	elseif name == "World" then
		shape(2, 2, 16, 16, 8, 0, true); shape(7, 2, 6, 16, 4, 0, true)
		shape(3, 9, 14, 2, 1)
	elseif name == "Player" then
		shape(7, 1, 7, 7, 4); shape(3, 11, 15, 8, 4)
	else
		for i = 0, 2 do
			shape(2, 3 + i * 6, 16, 2, 1)
			shape(i == 1 and 12 or 5, 1 + i * 6, 4, 6, 2)
		end
	end
	return function(color)
		for _, part in ipairs(fills) do tween(part, {BackgroundColor3=color}) end
		for _, line in ipairs(outlines) do tween(line, {Color=color}) end
	end
end

local function addNav(name, icon, onSelect)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, MobileUI.Touch and 44 or 36),
		BackgroundColor3 = T.AccentSoft, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false,
	}, navList)
	corner(b, 8)

	local tintIcon = MobileUI:NavIcon(b, name)
	local tx = label(b, name, 10, T.Sub, Enum.Font.GothamMedium, UDim2.new(0, 2, 0, 21), UDim2.new(1, -4, 0, 13))
	tx.TextXAlignment = Enum.TextXAlignment.Center

	local bar = new("Frame", {
		Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = T.Accent, BorderSizePixel = 0,
	}, b)
	corner(bar, 2)

	-- Subtle divider makes each navigation row easier to scan.
	local divider = new("Frame", {
		Name = "NavDivider",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 2),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundColor3 = T.Stroke,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
	}, b)

	local isActive = false
	local function setActive(on)
		isActive = on
		tween(b,   {BackgroundTransparency = on and 0 or 1})
		tintIcon(on and T.Accent or T.Sub)
		tween(tx,  {TextColor3 = on and T.Text or T.Sub})
		tween(bar, {Size = UDim2.new(0, 3, 0, on and 16 or 0)})
		tween(divider, {BackgroundTransparency = on and 0.42 or 0.78})
	end

	local function select()
		if activeNavSet then activeNavSet(false) end
		activeNavSet = setActive
		setActive(true)
		if onSelect then onSelect() else
			for n, p in pairs(pages) do p.Visible = (n == name) end
		end
	end

	b.MouseEnter:Connect(function() if not isActive then tween(b, {BackgroundTransparency = 0.4}) end end)
	b.MouseLeave:Connect(function() if not isActive then tween(b, {BackgroundTransparency = 1})   end end)
	b.Activated:Connect(select)

	return b, select
end

local right = new("Frame", {
	Size = UDim2.new(1, -96, 1, 0), Position = UDim2.new(0, 96, 0, 0),
	BackgroundTransparency = 1,
}, main)

local top = new("Frame", {Size = UDim2.new(1, 0, 0, 94), BackgroundTransparency = 1, ZIndex = 5}, right)
new("Frame", {
	Size = UDim2.new(1, -32, 0, 1), Position = UDim2.new(0, 16, 1, -1),
	BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.65, BorderSizePixel = 0,
}, top)

local search = new("Frame", {
	Size = UDim2.new(0, 190, 0, 30), Position = UDim2.new(0, 16, 0, 15),
	BackgroundColor3 = T.Card, BorderSizePixel = 0, ZIndex = 5,
}, top)
corner(search, 4); stroke(search)
local si = label(search, "⌕", 15, T.Sub, Enum.Font.GothamBold, UDim2.new(0, 8, 0, 0), UDim2.new(0, 16, 1, 0))
si.ZIndex = 6
new("TextBox", {
	BackgroundTransparency = 1, Text = "", PlaceholderText = "Search",
	PlaceholderColor3 = T.Sub, TextColor3 = T.Text, TextSize = 12,
	Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -38, 1, 0),
	ClearTextOnFocus = false, ZIndex = 6,
}, search)

local tabs = new("ScrollingFrame", {
	Size = UDim2.new(1, -32, 0, 34), Position = UDim2.new(0, 16, 0, 54),
	BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
	ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2,
	ScrollBarImageColor3 = T.AccentSoft,
}, top)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 4),
	VerticalAlignment = Enum.VerticalAlignment.Center,
}, tabs)

local activeTabSet = nil

local function addTab(name, icon, default, onSelect)
	local b = new("TextButton", {
		Size = UDim2.new(0, 78, 1, -3),
		BackgroundColor3 = T.Card, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, ZIndex = 5,
	}, tabs)
	corner(b, 8)

	local l = label(b, name, 12, T.Sub, Enum.Font.GothamMedium, nil, UDim2.new(1, 0, 1, 0))
	l.TextXAlignment = Enum.TextXAlignment.Center
	l.ZIndex = 6

	local underline = new("Frame", {
		Name = "TabUnderline",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -1),
		Size = UDim2.new(1, -28, 0, 2),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, b)
	corner(underline, 2)

	local function set(on)
		tween(b, {BackgroundTransparency = on and 0 or 1})
		tween(l, {TextColor3 = on and T.Accent or T.Sub})
		tween(underline, {BackgroundTransparency = on and 0 or 1})
	end

	local function select()
		if activeTabSet then activeTabSet(false) end
		activeTabSet = set
		set(true)
		if onSelect then onSelect() end
	end

	b.Activated:Connect(select)
	if default then select() end
	return b, select
end

local hubName = label(top, "Mazxhub", 16, T.Accent, Enum.Font.GothamBold,
	UDim2.new(1, -176, 0, 15), UDim2.fromOffset(120, 30))
hubName.TextXAlignment = Enum.TextXAlignment.Right
hubName.ZIndex = 6
MobileUI.TechCaption = label(top, "CONTROL // PANEL", 10, T.Sub, Enum.Font.Code,
	UDim2.fromOffset(222, 15), UDim2.fromOffset(150, 30))
MobileUI.TechCaption.ZIndex = 6

local close = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -40, 0, 16),
	BackgroundColor3 = T.Card, Text = "✕", TextColor3 = T.Sub,
	TextSize = 13, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 6,
}, top)
corner(close, 8)
close.MouseEnter:Connect(function() tween(close, {BackgroundColor3 = T.Danger, TextColor3 = T.Text}) end)
close.MouseLeave:Connect(function() tween(close, {BackgroundColor3 = T.Card,  TextColor3 = T.Sub})  end)

local function makePage(name)
	local p = new("Frame", {
		Name = name, Visible = false, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -94), Position = UDim2.new(0, 0, 0, 94),
	}, right)

	local cols = {}
	for i = 1, 2 do
		local sc = new("ScrollingFrame", {
			Size = UDim2.new(0.5, -24, 1, -12),
			Position = UDim2.new(0.5 * (i - 1), (i == 1) and 16 or 8, 0, 0),
			BackgroundColor3 = T.Card, BackgroundTransparency = 0.15, BorderSizePixel = 0,
			ScrollBarThickness = 3, ScrollBarImageColor3 = T.AccentSoft,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, p)
		corner(sc, 7); stroke(sc, T.Stroke, 1)
		new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sc)
		pad(sc, 8, 16, 8, 8)
		cols[i] = sc
	end

	pages[name] = p
	MobileUI.Pages[name] = cols
	return cols[1], cols[2]
end

local function Section(parent, title, default, cb)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, MobileUI.Touch and 48 or 34), BackgroundColor3 = T.AccentSoft,
		BackgroundTransparency = 0.45, BorderSizePixel = 0}, parent)
	corner(f, 5)

	local t = label(f, title, 12, T.Text, Enum.Font.GothamBold, UDim2.new(0, 24, 0, 0), UDim2.new(1, cb and -86 or -36, 1, 0))
	t.TextTruncate = Enum.TextTruncate.AtEnd

	local dot = new("Frame", {
		Size = UDim2.fromOffset(2, 12), BackgroundColor3 = T.Accent, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 11, 0.5, 0),
	}, f)
	corner(dot, 3)

	local box = new("TextButton", {
		Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -52, 0.5, -11),
		BackgroundColor3 = T.Track, Text = "", AutoButtonColor = false,
		Visible = cb ~= nil,
	}, f)
	corner(box, 11)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = T.Text, BorderSizePixel = 0,
	}, box)
	corner(knob, 8)

	local on = default or false
	local function render()
		tween(box,  {BackgroundColor3 = on and T.Accent or T.Track})
		tween(knob, {Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
	end
	local function set(state, fireCallback)
		on = state == true
		render()
		if fireCallback and cb then cb(on) end
	end
	render()
	local tap = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Visible = cb ~= nil, ZIndex = box.ZIndex + 1}, f)
	tap.Activated:Connect(function()
		set(not on, true)
	end)

	return f, function() return on end, function(state, fireCallback)
		set(state, fireCallback == true)
	end
end

local function Toggle(parent, title, default, cb)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, MobileUI.Touch and 48 or 32), BackgroundColor3 = T.Card,
		BackgroundTransparency = 0.65, BorderSizePixel = 0}, parent)
	corner(f, 5)
	label(f, title, 12, T.Text, Enum.Font.GothamMedium, UDim2.new(0, 12, 0, 0), UDim2.new(1, -76, 1, 0))

	local box = new("TextButton", {
		Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -52, 0.5, -11),
		BackgroundColor3 = T.Track, Text = "", AutoButtonColor = false,
	}, f)
	corner(box, 11)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = T.Text, BorderSizePixel = 0,
	}, box)
	corner(knob, 8)

	local on = default or false
	local function render()
		tween(box,  {BackgroundColor3 = on and T.Accent or T.Track})
		tween(knob, {Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
	end
	render()
	local tap = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, ZIndex = box.ZIndex + 1}, f)
	tap.Activated:Connect(function()
		on = not on; render(); if cb then cb(on) end
	end)

	return f, function() return on end
end

local function Slider(parent, title, desc, min, max, default, suffix, cb)
	local hasDesc = type(desc) == "string" and desc ~= ""
	local frameHeight = MobileUI.Touch and (hasDesc and 82 or 62) or (hasDesc and 58 or 44)
	local trackY = MobileUI.Touch and (hasDesc and 56 or 38) or (hasDesc and 44 or 30)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, frameHeight), BackgroundTransparency = 1}, parent)

	label(f, title, 12.5, T.Text, Enum.Font.GothamBold, UDim2.new(0, 0, 0, 0), UDim2.new(1, -70, 0, 16))
	local val = label(f, "", 12, T.Text, Enum.Font.GothamBold, UDim2.new(1, -70, 0, 0), UDim2.new(0, 70, 0, 16))
	val.TextXAlignment = Enum.TextXAlignment.Right
	if hasDesc then
		label(f, desc, 11, T.Sub, Enum.Font.Gotham, UDim2.new(0, 0, 0, 18), UDim2.new(1, 0, 0, 14))
	end

	local track = new("Frame", {
		Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, trackY),
		BackgroundColor3 = T.Track, BorderSizePixel = 0,
	}, f)
	corner(track, 3)
	local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0}, track)
	corner(fill, 3)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = T.Text, BorderSizePixel = 0,
	}, track)
	corner(knob, 7)

	local cur = default
	local function set(v)
		cur = math.clamp(v, min, max)
		local a = (max == min) and 0 or (cur - min) / (max - min)
		val.Text = (suffix == " s" and string.format("%.1f", cur) or tostring(math.floor(cur + 0.5))) .. (suffix or "")
		fill.Size     = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		if cb then cb(cur) end
	end
	set(default)

	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, MobileUI.Touch and 44 or 24), Position = UDim2.new(0, 0, 0, MobileUI.Touch and -19 or -9),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	}, track)

	local dragging, unlockScroll
	local function cancel()
		dragging = nil
		if unlockScroll then unlockScroll(); unlockScroll = nil end
		if knob.Parent then tween(knob, {Size = UDim2.fromOffset(14, 14)}) end
	end
	MobileUI.Drags[cancel] = true
	f.Destroying:Connect(function() cancel(); MobileUI.Drags[cancel] = nil end)
	local function move(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		set(min + (max - min) * a)
	end

	hit.InputBegan:Connect(function(i)
		if dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = i
			unlockScroll = MobileUI:LockScroll(f.Parent)
			move(i.Position.X)
			tween(knob, {Size = UDim2.fromOffset(18, 18)})
		end
	end)

	MobileUI:Connect(UserInputService.InputChanged, function(i)
		if MobileUI:OwnsMove(dragging, i) then move(i.Position.X) end
	end)
	MobileUI:Connect(UserInputService.InputEnded, function(i)
		if i == dragging then cancel() end
	end)

	return f, function() return cur end
end

local function Dropdown(parent, title, desc, options, default, cb)
	local hasDesc = type(desc) == "string" and desc ~= ""
	local BASE = MobileUI.Touch and (hasDesc and 86 or 68) or (hasDesc and 74 or 56)
	local buttonY = hasDesc and 40 or 22
	local selectedOption = default
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, BASE), BackgroundTransparency = 1}, parent)

	label(f, title, 12.5, T.Text, Enum.Font.GothamBold, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))
	if hasDesc then
		label(f, desc, 11, T.Sub, Enum.Font.Gotham, UDim2.new(0, 0, 0, 18), UDim2.new(1, 0, 0, 14))
	end

	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, MobileUI.Touch and 44 or 32), Position = UDim2.new(0, 0, 0, buttonY),
		BackgroundColor3 = T.Card, Text = "", AutoButtonColor = false,
	}, f)
	corner(btn, 8); stroke(btn)
	local sel   = label(btn, default or "—", 12, T.Text, Enum.Font.GothamMedium, UDim2.new(0, 12, 0, 0), UDim2.new(1, -34, 1, 0))
	local arrow = label(btn, "⌄", 15, T.Sub, Enum.Font.GothamBold, UDim2.new(1, -26, 0, -4), UDim2.new(0, 16, 1, 0))
	arrow.TextXAlignment = Enum.TextXAlignment.Center

	local ITEM_H = MobileUI.Touch and 45 or 27
	local MAX_VISIBLE = MobileUI.Touch and 4 or 8

	local menu = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, BASE + 2),
		BackgroundColor3 = T.Card, BorderSizePixel = 0,
		Visible = false, ClipsDescendants = true, ZIndex = 20,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent,
	}, f)
	corner(menu, 8); stroke(menu)
	new("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder}, menu)
	pad(menu, 4)

	local open = false
	local closeMenu
	local function setOpen(state)
		if state and MobileUI.ActiveDropdownClose and MobileUI.ActiveDropdownClose ~= closeMenu then
			MobileUI.ActiveDropdownClose()
		end
		open = state
		if open then
			MobileUI.ActiveDropdownClose = closeMenu
			menu.Visible = true
		elseif MobileUI.ActiveDropdownClose == closeMenu then
			MobileUI.ActiveDropdownClose = nil
		end
		local h = math.min(#options, MAX_VISIBLE) * ITEM_H + 8
		tween(menu,  {Size = UDim2.new(1, 0, 0, open and h or 0)})
		tween(f,     {Size = UDim2.new(1, 0, 0, open and (BASE + h + 6) or BASE)})
		tween(arrow, {Rotation = open and 180 or 0})
		if not open then
			task.delay(0.22, function() if not open then menu.Visible = false end end)
		end
	end

	local function setOptions(newOptions, selected)
		options = {}
		for _, opt in ipairs(newOptions or {}) do table.insert(options, tostring(opt)) end
		for _, child in ipairs(menu:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		local wanted = selected
		if not wanted or not table.find(options, wanted) then wanted = options[1] or "—" end
		selectedOption = wanted
		sel.Text = wanted

		for index, opt in ipairs(options) do
			local o = new("TextButton", {
				Size = UDim2.new(1, -6, 0, ITEM_H - 1), LayoutOrder = index,
				BackgroundColor3 = T.CardHover, BackgroundTransparency = 1,
				Text = opt, TextColor3 = T.Sub, TextSize = 12, Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 21,
			}, menu)
			corner(o, 6); pad(o, 0, 0, 8, 8)
			o.MouseEnter:Connect(function() tween(o, {BackgroundTransparency = 0, TextColor3 = T.Text}) end)
			o.MouseLeave:Connect(function() tween(o, {BackgroundTransparency = 1, TextColor3 = T.Sub}) end)
			o.Activated:Connect(function()
				selectedOption = opt
				sel.Text = opt
				setOpen(false)
				if cb then cb(opt) end
			end)
		end
		if open then setOpen(true) end
	end

	setOptions(options, default)

	closeMenu = function()
		if open then setOpen(false) end
	end
	btn.Activated:Connect(function() setOpen(not open) end)
	f:GetPropertyChangedSignal("Visible"):Connect(function()
		if not f.Visible then closeMenu() end
	end)
	return f, function() return selectedOption end, setOptions
end

-- Reusable search row kept outside the large page-builder function.
-- This avoids Luau's 200-local-register limit when Farm UI grows.
local function SearchDropdownFilter(parent, placeholder, sourceList, getCurrent, setOptions, onSelected, statusLbl, noun)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, MobileUI.Touch and 48 or 38),
		BackgroundTransparency = 1,
	}, parent)
	local box = new("TextBox", {
		Size = UDim2.new(1, -92, 1, 0),
		BackgroundColor3 = T.Card,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = T.Sub,
		TextColor3 = T.Text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 8)
	stroke(box)
	pad(box, 0, 0, 10, 10)

	local button = new("TextButton", {
		Size = UDim2.new(0, 84, 1, 0),
		Position = UDim2.new(1, -84, 0, 0),
		BackgroundColor3 = T.Accent,
		Text = "Search",
		TextColor3 = T.Ink,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	corner(button, 8)

	local function apply()
		local query = box.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
		local filtered = {}
		for _, name in ipairs(sourceList) do
			if query == "" or name:lower():find(query, 1, true) then
				table.insert(filtered, name)
			end
		end
		if #filtered == 0 then
			statusLbl.Text = noun .. " not found: " .. box.Text
			statusLbl.TextColor3 = T.Danger
			return
		end
		local selected = getCurrent and getCurrent() or filtered[1]
		if not table.find(filtered, selected) then selected = filtered[1] end
		setOptions(filtered, selected)
		if onSelected then onSelected(selected) end
		statusLbl.Text = (#filtered == 1)
			and (noun .. ": " .. selected)
			or ("Found " .. #filtered .. " " .. noun:lower() .. "s")
		statusLbl.TextColor3 = T.Mint
	end

	button.Activated:Connect(apply)
	box.FocusLost:Connect(function(enterPressed)
		if enterPressed then apply() end
	end)
end

local function ColorRow(parent, title, hex, color, cb)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1}, parent)
	label(f, title, 12.5, T.Text, Enum.Font.GothamBold, UDim2.new(0, 0, 0, 5),  UDim2.new(1, -70, 0, 16))
	local hexLbl = label(f, hex, 11, T.Sub, Enum.Font.Gotham, UDim2.new(0, 0, 0, 23), UDim2.new(1, -70, 0, 14))

	local sw = new("TextButton", {
		Size = UDim2.fromOffset(52, MobileUI.Touch and 44 or 26), Position = UDim2.new(1, -52, 0.5, MobileUI.Touch and -22 or -13),
		BackgroundColor3 = color, Text = "", AutoButtonColor = false,
	}, f)
	corner(sw, 13); stroke(sw, T.Stroke, 1.5)

	sw.Activated:Connect(function()
		if cb then cb(sw.BackgroundColor3, sw, hexLbl) end
	end)
	return f, sw
end

local function Keybind(parent, title, defaultKey, cb)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, MobileUI.Touch and 48 or 34), BackgroundTransparency = 1}, parent)
	label(f, title, 12.5, T.Sub, Enum.Font.GothamMedium, UDim2.new(0, 0, 0, 0), UDim2.new(1, -80, 1, 0))

	local btn = new("TextButton", {
		Size = UDim2.fromOffset(80, MobileUI.Touch and 44 or 26), Position = UDim2.new(1, -80, 0.5, MobileUI.Touch and -22 or -13),
		BackgroundColor3 = T.Card, Text = MobileUI.Touch and not UserInputService.KeyboardEnabled and "ใช้ปุ่มลอย" or defaultKey.Name, TextColor3 = T.Text,
		TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false,
	}, f)
	corner(btn, 7); stroke(btn)

	local key, listening = defaultKey, false
	btn.Activated:Connect(function()
		if MobileUI.Touch and not UserInputService.KeyboardEnabled then
			btn.Text = "ใช้ปุ่มลอย"
			return
		end
		listening = true
		btn.Text = "..."
		tween(btn, {BackgroundColor3 = T.Accent})
	end)

	MobileUI:Connect(UserInputService.InputBegan, function(i, gp)
		if listening and not gp and i.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			key = i.KeyCode
			btn.Text = key.Name
			tween(btn, {BackgroundColor3 = T.Card})
			if cb then cb(key) end
		end
	end)

	return f, function() return key end
end

local function Button(parent, title, color, cb)
	local background = color or T.Accent
	local bright = (background.R * 0.299 + background.G * 0.587 + background.B * 0.114) > 0.6
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, MobileUI.Touch and 48 or 40),
		BackgroundColor3 = background,
		Text = title, TextColor3 = bright and T.Ink or T.Text, TextSize = 12.5,
		Font = Enum.Font.GothamBold, AutoButtonColor = false,
	}, parent)
	corner(b, 10)
	stroke(b, bright and background or T.Stroke)
	b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = background:Lerp(T.Text, 0.1)}) end)
	b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = background}) end)
	b.Activated:Connect(function() if cb then cb() end end)
	return b
end
local BOSS_TYPES = {
	"Zuko", "Gyorei", "Stone Trainee", "Thunder Trainee", "Water Trainee Sabito",
	"Giyen", "Yahari", "Reaper", "Saneri", "Shinora", "Enru", "Gyutai", "Datai",
	"Obari", "Mother Bear", "Kaiden", "Akazo", "Serpent Trainee", "Hoyuzo", "Zentaro",
	"Wind Trainee", "Tengai", "Sound Trainee", "Sumari", "Flame Trainee",
	"Nezura", "Fujiko", "Insect Trainee", "Soryu Trainee Goki", "Yeti Demon", "Rengu",
}
local BOSS_REGIONS = {
	Zuko = "Windy Peak",
	["Mother Bear"] = "Bamboo Grove",
	Kaiden = "Bamboo Grove",
	Hoyuzo = "Bamboo Grove",
	Akazo = "Misc",
	["Serpent Trainee"] = "Misc",
	Gyutai = "Misc",
	Datai = "Misc",
	["Thunder Trainee"] = "Misc",
	Zentaro = "Misc",
	["Wind Trainee"] = "Misc",
	Tengai = "Misc",
	["Sound Trainee"] = "Misc",
	Sumari = "Misc",
	["Flame Trainee"] = "Misc",
	Nezura = "Misc",
	Fujiko = "Misc",
	["Insect Trainee"] = "Misc",
	["Soryu Trainee Goki"] = "Misc",
	["Yeti Demon"] = "Temporary",
	Rengu = "Misc",
}
local BOSS_WARP_POSITIONS = {
	Zuko = Vector3.new(-282.24, 1226.70, -1035.92),
	["Mother Bear"] = Vector3.new(500.41, 1122.17, -995.84),
	Kaiden = Vector3.new(582.14, 1148.99, -1314.34),
	Gyutai = Vector3.new(-263.21, 1045.74, -1142.99),
	Datai = Vector3.new(-162.96, 1045.50, -1138.90),
	["Serpent Trainee"] = Vector3.new(-271.11, 1294.50, -1536.17),
	["Wind Trainee"] = Vector3.new(-941.91, 1383.50, -2634.24),
	Tengai = Vector3.new(-134.29, 1351.50, -2629.80),
	["Sound Trainee"] = Vector3.new(191.50, 1351.50, -2584.06),
	Obari = Vector3.new(771.11, 1123.49, -1049.57),
	Zentaro = Vector3.new(1329.28, 823.50, -1016.46),
	["Thunder Trainee"] = Vector3.new(2427.88, 1076.01, -553.91),
	["Stone Trainee"] = Vector3.new(2686.55, 1075.90, -563.85),
	Gyorei = Vector3.new(2577.35, 1091.50, -740.00),
	["Water Trainee Sabito"] = Vector3.new(813.75, 1020.62, 102.49),
	Giyen = Vector3.new(391.82, 1020.50, -86.08),
	Sumari = Vector3.new(393.49, 1020.50, -621.29),
	Yahari = Vector3.new(827.42, 1021.70, -636.29),
	Reaper = Vector3.new(97.02, 1045.48, -571.47),
	Saneri = Vector3.new(-380.61, 1095.87, -424.20),
	Shinora = Vector3.new(-450.38, 967.00, -0.95),
	Enru = Vector3.new(822.20, 798.06, 544.81),
	["Flame Trainee"] = Vector3.new(-1131.45, 1031.55, 998.73),
	Nezura = Vector3.new(-1460.55, 278.45, 937.27),
	Fujiko = Vector3.new(-2460.92, 40.33, 1118.08),
	["Insect Trainee"] = Vector3.new(-1394.92, 264.00, 71.03),
	["Soryu Trainee Goki"] = Vector3.new(-425.90, 291.16, 541.26),
	Hoyuzo = Vector3.new(748.19, 1003.50, -1414.87),
	["Yeti Demon"] = Vector3.new(-1389.28, -35.35, 503.90),
	Rengu = Vector3.new(-715.71, 967.50, 884.20),
}
local NPC_ESP_REGIONS = { "Windy Peak", "Misc", "Bamboo Grove", "Temporary" }
local ESP = {
	Enabled      = false,
	Lines        = false,
	Outlines     = false,
	Color        = Color3.fromRGB(139, 124, 246),
	OutlineColor = Color3.fromRGB(255, 255, 255),
	MaxDistance  = 1000,
	_cache       = {},
}

local NPC_ESP = {
	Bandit      = false,
	Civilian    = false,
	BossEnabled = false,
	BossSelected = {},
	BossNames = {},
	MaxDistance = 1000,
	Colors      = {
		Bandit = Color3.fromRGB(255, 90, 90),
		Civilian = Color3.fromRGB(110, 231, 183),
	},
	_cache = {},
}
for _, name in ipairs(BOSS_TYPES) do
	NPC_ESP.BossNames[name:lower()] = name
	NPC_ESP.BossSelected[name] = true
	NPC_ESP.Colors[name] = T.Gold
end

local function npcESPEnabled(npcType)
	if NPC_ESP.BossSelected[npcType] ~= nil then
		return NPC_ESP.BossEnabled and NPC_ESP.BossSelected[npcType]
	end
	return NPC_ESP[npcType] == true
end

local espLineLayer = new("Frame", {
	Name = "LuminESPLines", Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1, Active = false, ZIndex = 0,
}, gui)

local function makeESPLine(color)
	return new("Frame", {
		Name = "LuminESPLine", AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color, BorderSizePixel = 0,
		Visible = false, Active = false, ZIndex = 0,
	}, espLineLayer)
end

local function updateESPLine(line, root, enabled, maxDistance, camera)
	line.Visible = false
	if not enabled or not camera or not root or not root.Parent then return end
	if (camera.CFrame.Position - root.Position).Magnitude > maxDistance then return end
	local point, onScreen = camera:WorldToViewportPoint(root.Position)
	if not onScreen or point.Z <= 0 then return end
	local origin = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 2)
	local target = Vector2.new(point.X, point.Y)
	local delta = target - origin
	if delta.Magnitude < 1 then return end
	local middle = (origin + target) * 0.5
	line.Position = UDim2.fromOffset(middle.X, middle.Y)
	line.Size = UDim2.fromOffset(delta.Magnitude, 2)
	line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	line.Visible = true
end

local function clearESP(plr)
	local data = ESP._cache[plr]
	if not data then return end
	if data.highlight then data.highlight:Destroy() end
	if data.billboard then data.billboard:Destroy() end
	if data.line      then data.line:Destroy()      end
	ESP._cache[plr] = nil
end

local function makeESP(plr)
	if plr == player then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	clearESP(plr)
	if not ESP.Enabled and not ESP.Lines and not ESP.Outlines then return end
	local char = plr.Character
	if not char then return end
	local hrp  = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	if not hrp or not head then return end

	local data = { character = char }

	local hl = Instance.new("Highlight")
	hl.Name = "LuminESP"
	hl.Adornee = char
	hl.FillColor = ESP.Color
	hl.FillTransparency = 0.75
	hl.OutlineColor = ESP.OutlineColor
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = ESP.Outlines
	hl.Parent = char
	data.highlight = hl

	local bb = Instance.new("BillboardGui")
	bb.Name = "LuminESPTag"
	bb.Adornee = head
	bb.Size = UDim2.fromOffset(200, 50)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = ESP.MaxDistance
	bb.Enabled = ESP.Enabled
	bb.Parent = char

	local nameLbl = Instance.new("TextLabel")
	nameLbl.BackgroundTransparency = 1
	nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
	nameLbl.Text = plr.Name
	nameLbl.TextColor3 = ESP.Color
	nameLbl.TextStrokeTransparency = 0
	nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLbl.TextSize = 14
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.Parent = bb

	local distLbl = Instance.new("TextLabel")
	distLbl.BackgroundTransparency = 1
	distLbl.Size = UDim2.new(1, 0, 0.5, 0)
	distLbl.Position = UDim2.new(0, 0, 0.5, 0)
	distLbl.Text = ""
	distLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
	distLbl.TextStrokeTransparency = 0
	distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	distLbl.TextSize = 12
	distLbl.Font = Enum.Font.Gotham
	distLbl.Parent = bb
	data.billboard = bb
	data.nameLbl = nameLbl
	data.distLbl = distLbl

	data.line = makeESPLine(ESP.Color)

	ESP._cache[plr] = data
end

local function refreshAllESP()
	for _, p in ipairs(Players:GetPlayers()) do
		makeESP(p)
	end
end

local function npcESPFolder(region)
	local node = workspace
	for _, name in ipairs({ "Humanoids", "Regions", region, "ActiveNpcs" }) do
		node = node and node:FindFirstChild(name)
		if not node then return nil end
	end
	return node
end

local function npcESPType(root, folder)
	local node = root.Parent
	while node and node ~= folder do
		local lowerName = node.Name:lower()
		if lowerName == "bandit" then return "Bandit" end
		if lowerName == "civilian" then return "Civilian" end
		if NPC_ESP.BossNames[lowerName] then return NPC_ESP.BossNames[lowerName] end
		node = node.Parent
	end
	return nil
end

local function clearNpcESP(root)
	local data = NPC_ESP._cache[root]
	if not data then return end
	if data.highlight then data.highlight:Destroy() end
	if data.billboard then data.billboard:Destroy() end
	if data.line then data.line:Destroy() end
	NPC_ESP._cache[root] = nil
end

local function makeNpcESP(root, npcType)
	if not root or not root.Parent or NPC_ESP._cache[root] then return end
	local adornee = root.Parent:IsA("Model") and root.Parent or root
	local color = NPC_ESP.Colors[npcType] or T.Accent

	for _, item in ipairs(adornee:GetDescendants()) do
		if item.Name == "LuminNpcESP" or item.Name == "LuminNpcESPTag" then
			item:Destroy()
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "LuminNpcESP"
	highlight.Adornee = adornee
	highlight.FillColor = color
	highlight.FillTransparency = 0.72
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = adornee

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LuminNpcESPTag"
	billboard.Adornee = root
	billboard.Size = UDim2.fromOffset(180, 42)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = NPC_ESP.MaxDistance
	billboard.Parent = root

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Text = npcType
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard

	NPC_ESP._cache[root] = {
		type = npcType,
		highlight = highlight,
		billboard = billboard,
		label = textLabel,
		line = makeESPLine(color),
	}
end

local function refreshNpcESP()
	if not NPC_ESP.Bandit and not NPC_ESP.Civilian and not NPC_ESP.BossEnabled then
		for root in pairs(NPC_ESP._cache) do clearNpcESP(root) end
		return
	end
	MazxBoot.Perf.NpcScans += 1
	local seen = {}
	for _, region in ipairs(NPC_ESP_REGIONS) do
		local folder = npcESPFolder(region)
		if not folder then continue end
		for _, item in ipairs(folder:GetDescendants()) do
			if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
				local npcType = npcESPType(item, folder)
				if npcType then
					seen[item] = true
					if not NPC_ESP._cache[item] then
						local adornee = item.Parent:IsA("Model") and item.Parent or item
						for _, old in ipairs(adornee:GetDescendants()) do
							if old.Name == "LuminNpcESP" or old.Name == "LuminNpcESPTag" then
								old:Destroy()
							end
						end
					end
					local hum = item.Parent:FindFirstChildWhichIsA("Humanoid", true)
					if npcESPEnabled(npcType) and (not hum or hum.Health > 0) then
						makeNpcESP(item, npcType)
					else
						clearNpcESP(item)
					end
				end
			end
		end
	end

	for root, data in pairs(NPC_ESP._cache) do
		if not root.Parent or not seen[root] or not npcESPEnabled(data.type) then
			clearNpcESP(root)
		end
	end
end

task.spawn(function()
	while gui.Parent and _G.__LUMIN_RUNNING == LUMIN_RUN_TOKEN do
		refreshNpcESP()
		if ESP.Enabled or ESP.Lines or ESP.Outlines then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player then
					local data = ESP._cache[p]
					if not data or data.character ~= p.Character then makeESP(p) end
				end
			end
		else
			for p in pairs(ESP._cache) do clearESP(p) end
		end
		task.wait(1.5)
	end
end)

local espRemovingConnection = Players.PlayerRemoving:Connect(function(p)
	clearESP(p)
end)

local espRenderConnection = RunService.RenderStepped:Connect(function()
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	if not next(ESP._cache) and not next(NPC_ESP._cache) then return end
	if os.clock() < (ESP._nextRenderAt or 0) then return end
	ESP._nextRenderAt = os.clock() + 1 / 30
	local camera = workspace.CurrentCamera
	if not camera then
		for _, data in pairs(ESP._cache) do data.line.Visible = false end
		for _, data in pairs(NPC_ESP._cache) do data.line.Visible = false end
		return
	end
	for plr, data in pairs(ESP._cache) do
		local char = plr.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local alive = hrp ~= nil and char == data.character and (not hum or hum.Health > 0)
		local distance = alive and (camera.CFrame.Position - hrp.Position).Magnitude or math.huge
		local visible = alive and distance <= ESP.MaxDistance
		data.billboard.Enabled = visible and ESP.Enabled
		data.highlight.Enabled = visible and ESP.Outlines
		if visible then data.distLbl.Text = string.format("[%d studs]", math.floor(distance)) end
		updateESPLine(data.line, hrp, visible and ESP.Lines, ESP.MaxDistance, camera)
	end

	for root, data in pairs(NPC_ESP._cache) do
		local visible = false
		if root.Parent then
			local hum = root.Parent:FindFirstChildWhichIsA("Humanoid", true)
			local distance = (camera.CFrame.Position - root.Position).Magnitude
			visible = npcESPEnabled(data.type) and distance <= NPC_ESP.MaxDistance
				and (not hum or hum.Health > 0)
			if data.label then
				data.label.Text = string.format("%s  [%d studs]", data.type, math.floor(distance))
			end
		end
		if data.billboard then data.billboard.Enabled = visible end
		if data.highlight then data.highlight.Enabled = visible end
		updateESPLine(data.line, root, visible and ESP.Lines, NPC_ESP.MaxDistance, camera)
	end
end)

gui.Destroying:Connect(function()
	espRenderConnection:Disconnect()
	espRemovingConnection:Disconnect()
	for plr in pairs(ESP._cache) do clearESP(plr) end
	for root in pairs(NPC_ESP._cache) do clearNpcESP(root) end
end)

--------------------------------------------------------------
-- AIMBOT / FOV MODULE
--------------------------------------------------------------
local Aimbot = {
	Enabled = false,
	SkillEnabled = false,
	-- The FOV guide is visible by default, but Aimbot itself stays OFF.
	ShowFOV = false,
	FOV = 180,
	TargetPlayers = true,
	TargetNPCs = true,
	AltCenter = false,
	RightMouseHeld = false,
	SkillHeld = {},
	SkillKeys = { Z = true, X = true, C = true, V = true, B = true, N = true, K = true },
	NPCs = {},
	NextNPCScan = 0,
	Target = nil,
	Connections = {},
}

local aimLayer = new("Frame", {
	Name = "LuminAimLayer",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Active = false,
	ZIndex = 40,
}, gui)

local fovCircle = new("Frame", {
	Name = "AimbotFOV",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(Aimbot.FOV * 2, Aimbot.FOV * 2),
	BackgroundColor3 = T.Accent,
	BackgroundTransparency = 0.985,
	Visible = Aimbot.ShowFOV,
	Active = false,
	ZIndex = 80,
}, aimLayer)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fovCircle)
new("UIStroke", {
	Color = Color3.fromRGB(150, 220, 255),
	Thickness = 2.5,
	Transparency = 0,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, fovCircle)

-- Fallback ring made from normal Frames. Some executors/clients do not
-- render UIStroke correctly on a fully transparent rounded Frame.
local fovSegments = {}
local FOV_SEGMENT_COUNT = 72
for i = 1, FOV_SEGMENT_COUNT do
	local seg = new("Frame", {
		Name = "FOVSeg" .. i,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 2),
		BackgroundColor3 = Color3.fromRGB(150, 220, 255),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = Aimbot.ShowFOV,
		Active = false,
		ZIndex = 81,
	}, aimLayer)
	fovSegments[i] = seg
end

local fovCenterDot = new("Frame", {
	Name = "FOVCenter",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(4, 4),
	BackgroundColor3 = Color3.fromRGB(150, 220, 255),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Visible = Aimbot.ShowFOV,
	Active = false,
	ZIndex = 82,
}, aimLayer)
corner(fovCenterDot, 2)

function Aimbot:FOVCenter(camera)
	if self.AltCenter and camera then
		return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	end
	return UserInputService:GetMouseLocation()
end

function Aimbot:RefreshNPCs()
	local out = {}
	local root = workspace:FindFirstChild("Humanoids")
	if root then
		for _, hum in ipairs(root:GetDescendants()) do
			if hum:IsA("Humanoid") and hum.Health > 0 then
				local model = hum.Parent
				local myCharacter = player.Character
				local isSelf = myCharacter and model
					and (model == myCharacter or model:IsDescendantOf(myCharacter) or myCharacter:IsDescendantOf(model))
				local part = (not isSelf) and model
					and (model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart"))
				if part and part:IsA("BasePart") then
					table.insert(out, { Model = model, Humanoid = hum, Part = part })
				end
			end
		end
	end
	self.NPCs = out
	self.NextNPCScan = os.clock() + 0.5
end

function Aimbot:SkillActive()
	for key in pairs(self.SkillHeld) do
		if self.SkillKeys[key] then return true end
	end
	return false
end

function Aimbot:FindTarget(camera, center)
	local bestPart, bestDistance
	local function consider(part, hum)
		if not part or not part.Parent or (hum and hum.Health <= 0) then return end
		local myCharacter = player.Character
		if myCharacter and (part:IsDescendantOf(myCharacter)
			or (hum and hum:IsDescendantOf(myCharacter))) then
			return
		end
		local point, visible = camera:WorldToViewportPoint(part.Position)
		if not visible or point.Z <= 0 then return end
		local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
		if distance > self.FOV then return end
		if not bestDistance or distance < bestDistance then
			bestPart, bestDistance = part, distance
		end
	end

	if self.TargetPlayers then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local part = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
				consider(part, hum)
			end
		end
	end

	if self.TargetNPCs then
		if os.clock() >= self.NextNPCScan then self:RefreshNPCs() end
		for _, data in ipairs(self.NPCs) do
			if data.Humanoid and data.Humanoid.Parent and data.Humanoid.Health > 0 then
				local part = data.Model and (data.Model:FindFirstChild("Head") or data.Model:FindFirstChild("HumanoidRootPart"))
				data.Part = part or data.Part
				consider(data.Part, data.Humanoid)
			end
		end
	end
	return bestPart
end

function Aimbot:UpdateFOVVisual()
	if not self.ShowFOV then
		if self._fovWasVisible ~= false then
			fovCircle.Visible, fovCenterDot.Visible = false, false
			for _, segment in ipairs(fovSegments) do segment.Visible = false end
			self._fovWasVisible = false
		end
		return
	end
	self._fovWasVisible = true
	local camera = workspace.CurrentCamera
	if not camera then return end
	local center = self:FOVCenter(camera)
	local visible = self.ShowFOV == true
	local radius = math.max(10, self.FOV)

	fovCircle.Visible = visible
	fovCircle.Position = UDim2.fromOffset(center.X, center.Y)
	fovCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
	fovCenterDot.Visible = visible
	fovCenterDot.Position = UDim2.fromOffset(center.X, center.Y)

	local arcLength = math.max(5, math.floor((2 * math.pi * radius / FOV_SEGMENT_COUNT) * 0.82))
	for i, seg in ipairs(fovSegments) do
		local angle = ((i - 1) / FOV_SEGMENT_COUNT) * math.pi * 2
		local x = center.X + math.cos(angle) * radius
		local y = center.Y + math.sin(angle) * radius
		seg.Visible = visible
		seg.Position = UDim2.fromOffset(x, y)
		seg.Size = UDim2.fromOffset(arcLength, 2)
		seg.Rotation = math.deg(angle) + 90
	end
end

function Aimbot:Step()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local center = self:FOVCenter(camera)

	-- Never lock unless the right mouse button is being held.
	local shouldAim = self.RightMouseHeld
		and (self.Enabled or (self.SkillEnabled and self:SkillActive()))
	if not shouldAim then
		self.Target = nil
		return
	end

	local target = self:FindTarget(camera, center)
	self.Target = target
	if target and target.Parent then
		camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
	end
end

table.insert(Aimbot.Connections, UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		Aimbot.AltCenter = true
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 and not processed then
		Aimbot.RightMouseHeld = true
	end
	local name = input.KeyCode.Name
	if Aimbot.SkillKeys[name] and not processed then
		Aimbot.SkillHeld[name] = true
	end
end))
table.insert(Aimbot.Connections, UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		Aimbot.AltCenter = false
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aimbot.RightMouseHeld = false
		Aimbot.Target = nil
	end
	Aimbot.SkillHeld[input.KeyCode.Name] = nil
end))

-- Keep the FOV renderer separate from the aiming code. This way the ring
-- remains visible even if the camera/aim update is temporarily skipped.
Aimbot.FOVConnection = RunService.RenderStepped:Connect(function()
	if not gui.Parent then return end
	Aimbot:UpdateFOVVisual()
end)

local AIM_RENDER_NAME = "LuminAimbot_" .. tostring(player.UserId)
RunService:BindToRenderStep(AIM_RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function()
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	Aimbot:Step()
end)

gui.Destroying:Connect(function()
	RunService:UnbindFromRenderStep(AIM_RENDER_NAME)
	if Aimbot.FOVConnection then Aimbot.FOVConnection:Disconnect() end
	for _, connection in ipairs(Aimbot.Connections) do connection:Disconnect() end
	Aimbot.Connections = {}
end)

--------------------------------------------------------------
-- TELEPORT MODULE
--------------------------------------------------------------
local TP = {
	Root = { "Debree", "Regions", "Windy Peak", "StationaryNpcs" },
	RootsByNPC = {
		["Baitmonger Nori"] = { "Debree", "Regions", "Hidden Mist Village", "StationaryNpcs" },
		["Blacksmith Togane"] = { "Debree", "Regions", "Hidden Mist Village", "StationaryNpcs" },
		["Betty"] = { "Debree", "Regions", "Bamboo Grove", "StationaryNpcs" },
		["Kuro"] = { "Debree", "Regions", "Bamboo Grove", "StationaryNpcs" },
		["Serpent Trainer Obari"] = { "Debree", "Regions", "Misc", "StationaryNpcs" },
		["Stone Trainer Gyorei"] = { "Debree", "Regions", "Misc", "StationaryNpcs" },
		["Thunder Trainer Zentaro"] = { "Debree", "Regions", "Misc", "StationaryNpcs" },
		["Weaver Hatsu"] = { "Debree", "Regions", "Misc", "StationaryNpcs" },
		["Elara"] = { "Debree", "Regions", "Mistfall Harbor", "StationaryNpcs" },
		["Rin"] = { "Debree", "Regions", "Mistfall Harbor", "StationaryNpcs" },
		["Refiner Hagane"] = { "Debree", "Regions", "Hidden Mist Village", "StationaryNpcs" },
		["Stonemason Tobei"] = { "Debree", "Regions", "Hidden Mist Village", "StationaryNpcs" },
		["Yagane"] = { "Debree", "Regions", "Hidden Mist Village", "StationaryNpcs" },
		["Tailor Omi"] = { "Debree", "Regions", "Misc", "StationaryNpcs" },
		["Tom"]        = { "Debree", "Regions", "Bamboo Grove", "StationaryNpcs" },
		["Chaka"]      = { "Debree", "Regions", "Bamboo Grove", "StationaryNpcs" },
		["Wagwan"]     = { "Debree", "Regions", "Bamboo Grove", "StationaryNpcs" },
		["Demon Slayer Mitsu"] = { "Debree", "Regions", "Iceveil Valley", "StationaryNpcs" },
	},
	NPCs = {
		"Kazu", "Kona", "Krue", "Lucy", "MoldySugar", "Noote", "Raze", "Rika",
		"Tailor Omi", "Tom", "Chaka", "Wagwan", "Betty", "Kuro",
		"Serpent Trainer Obari", "Stone Trainer Gyorei", "Thunder Trainer Zentaro",
		"Weaver Hatsu", "Baitmonger Nori", "Refiner Hagane", "Yagane", "Blacksmith Togane",
		"Liv", "Rin", "Elara", "Ginzo", "Estate Worker Niko", "Jugg",
		"Dock Master Sofen", "Alchemist Meku", "Angler Runo", "Shady Individual Rooyi",
		"Ren", "Shiori", "Old Trapper Retsu", "Wounded Slayer Tomoi", "Demon Delroy",
		"Winter Store Rep Lynx", "Iceveil Guard Shiro", "Shrine Messenger Akio",
		"Sound Trainer Tengai", "Demon Slayer Mitsu", "Stonemason Tobei", "Demon Mokuro",
	},
	Positions = {
		["Weaver Hatsu"] = Vector3.new(2281.17, 812.50, 14.75),
		["Baitmonger Nori"] = Vector3.new(1643.24, 672.25, -190.13),
		["Refiner Hagane"] = Vector3.new(1865.27, 696.71, -434.26),
		Yagane = Vector3.new(1814.00, 661.55, -516.00),
		["Blacksmith Togane"] = Vector3.new(1732.07, 696.53, -764.55),
		Betty = Vector3.new(714.00, 1123.70, -808.00),
		Wagwan = Vector3.new(723.76, 1021.70, -801.98),
		Liv = Vector3.new(657.36, 1021.20, 139.75),
		Rin = Vector3.new(432.25, 1020.50, 73.10),
		Elara = Vector3.new(427.82, 943.58, 507.45),
		Ginzo = Vector3.new(273.80, 944.00, 528.19),
		["Estate Worker Niko"] = Vector3.new(260.66, 876.00, 803.78),
		Jugg = Vector3.new(487.70, 876.50, 1007.79),
		["Dock Master Sofen"] = Vector3.new(-160.81, 798.75, 703.29),
		["Alchemist Meku"] = Vector3.new(-138.15, 798.90, 518.74),
		["Angler Runo"] = Vector3.new(-561.10, 798.87, 683.70),
		["Shady Individual Rooyi"] = Vector3.new(-772.94, 967.07, -8.56),
		Ren = Vector3.new(-1609.65, 289.00, 10.49),
		Shiori = Vector3.new(-1814.34, 314.31, -101.07),
		Krue = Vector3.new(-425.49, 1243.50, -952.49),
		Rika = Vector3.new(-497.04, 1249.66, -1176.81),
		Noote = Vector3.new(-515.55, 1245.40, -1251.24),
		Kazu = Vector3.new(-626.00, 1245.00, -1138.00),
		Lucy = Vector3.new(-615.50, 1261.00, -1177.50),
		Raze = Vector3.new(-594.00, 1245.08, -1095.00),
		MoldySugar = Vector3.new(-701.60, 1245.69, -982.73),
		Kona = Vector3.new(-791.60, 1262.57, -1130.91),
		["Serpent Trainer Obari"] = Vector3.new(36.96, 1307.50, -1179.50),
		Chaka = Vector3.new(471.00, 1148.50, -1260.00),
		Tom = Vector3.new(507.20, 1123.92, -970.30),
		["Old Trapper Retsu"] = Vector3.new(440.00, 1179.00, -1504.01),
		["Wounded Slayer Tomoi"] = Vector3.new(485.34, 1225.07, -1813.00),
		["Demon Delroy"] = Vector3.new(139.61, 1256.72, -1911.30),
		["Winter Store Rep Lynx"] = Vector3.new(-91.65, 1353.67, -2705.57),
		["Iceveil Guard Shiro"] = Vector3.new(-106.78, 1351.50, -2498.56),
		["Shrine Messenger Akio"] = Vector3.new(-207.07, 1352.19, -2423.00),
		["Sound Trainer Tengai"] = Vector3.new(464.88, 1487.80, -3272.80),
		["Demon Slayer Mitsu"] = Vector3.new(-824.30, 1384.00, -2537.85),
		Kuro = Vector3.new(667.27, 1123.70, -1100.76),
		["Stone Trainer Gyorei"] = Vector3.new(2578.58, 1091.50, -828.40),
		["Thunder Trainer Zentaro"] = Vector3.new(1970.18, 1662.50, -609.81),
		["Stonemason Tobei"] = Vector3.new(1876.00, 661.55, -206.00),
		["Demon Mokuro"] = Vector3.new(-1948.43, 30.71, 374.31),
	},
}

local function tpFindNPC(name)
	local node = workspace
	for _, seg in ipairs(TP.RootsByNPC[name] or TP.Root) do
		node = node and node:FindFirstChild(seg)
		if not node then return nil end
	end
	return node:FindFirstChild(name)
end

local function tpCFrameOf(npc)
	if not npc then return nil end
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root.CFrame + Vector3.new(0, 3, 0)
	end
	if npc:IsA("Model") then
		return npc:GetPivot() + Vector3.new(0, 3, 0)
	elseif npc:IsA("BasePart") then
		return npc.CFrame + Vector3.new(0, 3, 0)
	end
	return nil
end

function TP.Destination(name)
	local live = tpCFrameOf(tpFindNPC(name))
	if live then return live end
	if game.PlaceId ~= 136406881576517 then return nil end
	local position = TP.Positions[name]
	return position and CFrame.new(position + Vector3.new(0, 3, 0)) or nil
end

-- Warp straight to the saved NPC coordinate in one move.
-- Callers still resolve the real NPC and recheck interaction distance
-- before issuing any quest remote.
function TP.ApproachSaved(root, name)
	if game.PlaceId ~= 136406881576517 or not root then return false end
	local position = TP.Positions[name]
	if not position then return false end
	local destination = position + Vector3.new(0, 0, -3)
	root.CFrame = CFrame.lookAt(destination, position)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	return true
end

local function tpSafeGo(cf)
	local char = player.Character
	if not char or not cf then return false, "no character" end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return false, "no hrp" end

	pcall(function() hrp:SetNetworkOwner(player) end)

	hum:ChangeState(Enum.HumanoidStateType.Physics)
	hum.PlatformStand = true
	task.wait()

	hrp.CFrame = cf
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	task.wait()

	-- Never restore Physics/PlatformStanding after a teleport. Re-enter a normal
	-- humanoid state so repeated raid teleports cannot leave the player sliding.
	hum.PlatformStand = false
	pcall(function() hum.Sit = false end)
	pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	task.defer(function()
		if hum.Parent and hum.Health > 0 and not hum.PlatformStand then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end
	end)
	return true
end

-- TELEPORT TO OTHER PLAYERS
-- Kept outside the large page builder to avoid Luau's local-register limit.
local function BuildPlayerTeleportPanel(parent, statusLbl)
	local function playerNames()
		local names = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				table.insert(names, plr.Name)
			end
		end
		table.sort(names, function(a, b) return a:lower() < b:lower() end)
		if #names == 0 then table.insert(names, "— ไม่มีผู้เล่นอื่น —") end
		return names
	end

	Section(parent, "วาปไปหาผู้เล่น", true)
	local names = playerNames()
	local _, getPlayer, setPlayerOptions = Dropdown(
		parent, "Players", "เลือกผู้เล่นในเซิร์ฟเวอร์",
		names, names[1]
	)

	local function teleportToPlayer(name)
		local targetPlayer = Players:FindFirstChild(name)
		if not targetPlayer or targetPlayer == player then return false, "ไม่พบผู้เล่น" end

		local deadline = os.clock() + 2
		local targetChar, targetRoot
		repeat
			local humanoidsFolder = workspace:FindFirstChild("Humanoids")
			targetChar = (humanoidsFolder and humanoidsFolder:FindFirstChild(name)) or targetPlayer.Character
			targetRoot = targetChar and (
				targetChar:FindFirstChild("HumanoidRootPart", true)
				or targetChar:FindFirstChild("UpperTorso", true)
				or targetChar:FindFirstChild("Torso", true)
				or targetChar.PrimaryPart
				or targetChar:FindFirstChildWhichIsA("BasePart", true)
			)
			if targetRoot then break end
			task.wait(0.05)
		until os.clock() >= deadline

		if not targetRoot then
			return false, "หา RootPart ของผู้เล่นไม่เจอ"
		end

		local humanoidsFolder = workspace:FindFirstChild("Humanoids")
		local char = (humanoidsFolder and humanoidsFolder:FindFirstChild(player.Name)) or player.Character
		local root = char and (
			char:FindFirstChild("HumanoidRootPart", true)
			or char:FindFirstChild("UpperTorso", true)
			or char:FindFirstChild("Torso", true)
			or char.PrimaryPart
			or char:FindFirstChildWhichIsA("BasePart", true)
		)
		local hum = char and char:FindFirstChildWhichIsA("Humanoid", true)
		if not char or not root or not hum or hum.Health <= 0 then
			return false, "ตัวละครของเรายังไม่พร้อม"
		end

		-- Move directly instead of tpSafeGo. Some games immediately override
		-- Physics/PlatformStand teleports, so repeat PivotTo/CFrame briefly.
		for _ = 1, 3 do
			if not targetRoot.Parent or not root.Parent then break end
			local destination = targetRoot.CFrame * CFrame.new(0, 2.5, 5)
			pcall(function() char:PivotTo(destination) end)
			root.CFrame = destination
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			pcall(function() hum.Sit = false end)
			task.wait(0.08)
		end
		return true
	end

	Button(parent, "⟶ วาปไปผู้เล่นที่เลือก", T.Accent, function()
		local name = getPlayer and getPlayer()
		if not name or name == "— ไม่มีผู้เล่นอื่น —" then
			statusLbl.Text = "ไม่มีผู้เล่นอื่นในเซิร์ฟเวอร์"
			statusLbl.TextColor3 = T.Danger
			return
		end

		local ok, err = teleportToPlayer(name)
		if ok then
			statusLbl.Text = "→ Player: " .. tostring(name)
			statusLbl.TextColor3 = T.Mint
		else
			statusLbl.Text = "วาปผู้เล่นล้มเหลว: " .. tostring(err)
			statusLbl.TextColor3 = T.Danger
		end
	end)

	local function bringPlayer(name)
		local targetPlayer = Players:FindFirstChild(name)
		if not targetPlayer or targetPlayer == player then return false, "ไม่พบผู้เล่น" end
		local myChar = player.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local targetChar = targetPlayer.Character
		local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
		local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
		if not myRoot then return false, "ตัวละครของเรายังไม่พร้อม" end
		if not targetChar or not targetRoot or not targetHum or targetHum.Health <= 0 then
			return false, "ตัวละครผู้เล่นยังไม่พร้อม"
		end
		local destination = myRoot.CFrame * CFrame.new(0, 0, -4)
		for _ = 1, 4 do
			if not targetChar.Parent or not targetRoot.Parent then break end
			pcall(function() targetChar:PivotTo(destination) end)
			pcall(function()
				targetRoot.CFrame = destination
				targetRoot.AssemblyLinearVelocity = Vector3.zero
				targetRoot.AssemblyAngularVelocity = Vector3.zero
			end)
			task.wait(0.05)
		end
		return true
	end

	Button(parent, "⇢ ดึงผู้เล่นที่เลือกมาหาเรา", T.Gold, function()
		local name = getPlayer and getPlayer()
		if not name or name == "— ไม่มีผู้เล่นอื่น —" then
			statusLbl.Text = "ไม่มีผู้เล่นอื่นในเซิร์ฟเวอร์"
			statusLbl.TextColor3 = T.Danger
			return
		end
		local ok, err = bringPlayer(name)
		if ok then
			statusLbl.Text = "Bring → " .. tostring(name)
			statusLbl.TextColor3 = T.Gold
		else
			statusLbl.Text = "Bring ล้มเหลว: " .. tostring(err)
			statusLbl.TextColor3 = T.Danger
		end
	end)

	Button(parent, "↻ รีเฟรชรายชื่อผู้เล่น", T.Card, function()
		local refreshed = playerNames()
		local current = getPlayer and getPlayer()
		if not table.find(refreshed, current) then current = refreshed[1] end
		setPlayerOptions(refreshed, current)
		statusLbl.Text = (#refreshed == 1 and refreshed[1] == "— ไม่มีผู้เล่นอื่น —")
			and "ไม่มีผู้เล่นอื่นในเซิร์ฟเวอร์"
			or ("เจอผู้เล่นอื่น " .. #refreshed .. " คน")
		statusLbl.TextColor3 = T.Mint
	end)
end


--------------------------------------------------------------
-- NO FOG MODULE
--------------------------------------------------------------
local NoFog = {
	Enabled = false,
	_originals = nil,
}

local function noFogApply()
	local originals = {}
	for _, a in ipairs(Lighting:GetChildren()) do
		if a:IsA("Atmosphere") then
			originals[a] = a.Density
			a.Density = 0
		end
		if a:IsA("Clouds") then
			originals[a] = a.Cover
			a.Cover = 0
		end
	end
	originals.FogEnd   = Lighting.FogEnd
	originals.FogStart = Lighting.FogStart
	originals.FogColor = Lighting.FogColor
	Lighting.FogEnd   = 1e6
	Lighting.FogStart = 1e6
	Lighting.FogColor = Color3.fromRGB(255, 255, 255)
	NoFog._originals = originals
end

local function noFogRestore()
	local o = NoFog._originals
	if not o then return end
	for inst, val in pairs(o) do
		if typeof(inst) == "Instance" and inst.Parent then
			if inst:IsA("Atmosphere") then inst.Density = val
			elseif inst:IsA("Clouds") then inst.Cover = val end
		end
	end
	if o.FogEnd   then Lighting.FogEnd   = o.FogEnd   end
	if o.FogStart then Lighting.FogStart = o.FogStart end
	if o.FogColor then Lighting.FogColor = o.FogColor end
	NoFog._originals = nil
end

local function noFogSet(on)
	NoFog.Enabled = on
	if on then noFogApply() else noFogRestore() end
end

--------------------------------------------------------------
-- FULL BRIGHT MODULE
--------------------------------------------------------------
-- Use one local post-processing effect instead of repeatedly rewriting
-- Lighting every 0.25s. Rewriting ClockTime/Brightness while the game also
-- controls them can cause visible flashing/flicker.
local FullBright = {
	Enabled = false,
	Effect = nil,
}

local function fullBrightEffect()
	local effect = Lighting:FindFirstChild("LuminFullBright")
	if effect and not effect:IsA("ColorCorrectionEffect") then
		effect:Destroy()
		effect = nil
	end
	if not effect then
		effect = Instance.new("ColorCorrectionEffect")
		effect.Name = "LuminFullBright"
		effect.Parent = Lighting
	end
	FullBright.Effect = effect
	return effect
end

local function fullBrightApply()
	local effect = fullBrightEffect()
	-- Stable client-side brightness. Do not force ClockTime/Ambient every frame.
	effect.Enabled = true
	effect.Brightness = 0.22
	effect.Contrast = -0.08
	effect.Saturation = 0.02
	effect.TintColor = Color3.fromRGB(255, 255, 255)
end

local function fullBrightRestore()
	local effect = FullBright.Effect or Lighting:FindFirstChild("LuminFullBright")
	if effect then
		effect:Destroy()
	end
	FullBright.Effect = nil
end

local function fullBrightSet(on)
	FullBright.Enabled = on == true
	if FullBright.Enabled then
		fullBrightApply()
	else
		fullBrightRestore()
	end
end

gui.Destroying:Connect(function()
	FullBright.Enabled = false
	fullBrightRestore()
end)

--------------------------------------------------------------
-- FARM MODULE
--------------------------------------------------------------
local Farm = {
	Enabled        = false,
	MobName        = nil,
	BossEnabled    = false,
	BossName       = "Zuko",
	MultiBossEnabled = false,
	MultiBossSelected = {},
	MultiBossOrder = {},
	MultiBossIndex = 1,
	_multiBossPendingAdvance = nil,
	_multiBossDeathConn = nil,
	_multiBossSaved = nil,
	AutoLoot       = true,
	_lootBusy      = false,
	_bettyBusy     = false,
	_storyBusy     = false,
	_deliveryBusy  = false,
	_pagesBusy     = false,
	_bearBusy      = false,
	AutoQuest      = false,
	AutoAttack     = false,
	Hitbox         = 18,
	PlayerAttackHitbox = 30,
	PlayerHitboxTest = false,
	HeadHeight     = 3,
	AttackInterval = 0.008,
	BurstHits = 5,
	AdaptiveFastAttack = false,
	FastAttack = true,
	BypassComboGate = true,
	NoSwingAnimation = false,
	AttackRange    = 12,
	RetreatEnabled = false,
	CounterAttackOnHit = false,
	_counterAttackPending = false,
	ComboHits = 5,
	ComboRetreatDelay = 4.0,
	RetreatDistance = 18,
	DamageDodgeDepth = 60,
	RetreatDelay = 2.0,
	_hitboxOriginals = setmetatable({}, { __mode = "k" }),
	_mobHitboxOriginals = setmetatable({}, { __mode = "k" }),
	_mobHitboxTarget = nil,
	_mobHitboxNextAt = 0,
	SelectedWeapon = "ช่อง 1",
	_lastHotbarSelection = nil,
	_lastHotbarCharacter = nil,
	_detectedHotbarSlots = {},
	QuestNpcName   = "Krue",
	QuestKills     = 0,
	_conn          = nil,
	_attackConn    = nil,
	_cameraConn    = nil,
	_attackTarget  = nil,
	_inputPauseUntil = 0,
	_sendingClick  = false,
	_systemMenuOpen = false,
	_inputConnections = {},
	_questBusy     = false,
	_questNeeded   = true,
	_acceptedQuestText = nil,
	_lastQuestAt   = -math.huge,
	_questReadyAt  = 0,
}

table.insert(Farm._inputConnections, UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape
	or input.KeyCode == Enum.KeyCode.Slash
	or input.KeyCode == Enum.KeyCode.Return then
		Farm._inputPauseUntil = os.clock() + 1
	end
end))

pcall(function()
	table.insert(Farm._inputConnections, GuiService.MenuOpened:Connect(function()
		Farm._systemMenuOpen = true
	end))
	table.insert(Farm._inputConnections, GuiService.MenuClosed:Connect(function()
		Farm._systemMenuOpen = false
		Farm._inputPauseUntil = os.clock() + 0.35
	end))
end)

local FARM_PATH  = { "Humanoids", "Regions", "Windy Peak", "ActiveNpcs" }
local FARM_TYPES = { "Bandit", "Civilian", "Bear Cub", "Kaiden Subordinate", "Hoyuzo Subordinate", "Beast Born Demon", "Fire Profound Demon" }
local BOSS_QUEST_SPECS = {
	Zuko = {
		Text = "Ill take the bandit boss(Lv 7)",
		RequiredKills = 1,
		TargetName = "Zuko",
		NPCName = "Krue",
	},
	["Mother Bear"] = {
		Text = "Ill fell the Mother Bear(Lv 18)",
		RequiredKills = 1,
		TargetName = "Mother Bear",
		NPCName = "Tom",
	},
	Kaiden = {
		Text = "Ill deal with Kaiden(Lv 34)",
		RequiredKills = 1,
		TargetName = "Kaiden",
		NPCName = "Chaka",
	},
	Hoyuzo = {
		Text = "I will take care of Hoyuzo(Lv 50)",
		RequiredKills = 1,
		TargetName = "Hoyuzo",
		NPCName = "Wagwan",
	},
}

local function farmActiveFolder()
	local node = workspace
	for _, seg in ipairs(FARM_PATH) do
		node = node and node:FindFirstChild(seg)
		if not node then return nil end
	end
	return node
end

local RAID_BOX_POINTS = {
	[1] = Vector3.new(331.1376953125, 1021.4044189453125, -686.1722412109375),
	[2] = Vector3.new(802.3745727539062, 1124.2423095703125, -1002.8580322265625),
	[3] = Vector3.new(942.5108032226562, 1104.9501953125, -1147.0958251953125),
	[4] = Vector3.new(538.2649536132812, 1021.5513305664062, 201.63821411132812),
	[5] = Vector3.new(1055.079833984375, 1049.7620849609375, -452.88006591796875),
	[6] = Vector3.new(-669.5108032226562, 1007.0742797851562, 1160.7030029296875),
	[7] = Vector3.new(389.7073974609375, 1124.5743408203125, -1170.9603271484375),
	[8] = Vector3.new(321.6490783691406, 1225.0743408203125, -1771.9432373046875),
	[9] = Vector3.new(-667.1080932617188, 1385.0743408203125, -2732.900390625),
	[10] = Vector3.new(-966.843505859375, 1385.07421875, -2553.394287109375),
	[11] = Vector3.new(392.162841796875, 1351.4998779296875, -2311.40966796875),
	[12] = Vector3.new(386.46990966796875, 1124.57421875, -1170.58935546875),
	[13] = Vector3.new(320.561279296875, 1225.07421875, -1771.89697265625),
	[14] = Vector3.new(390.47357177734375, 1351.499755859375, -2312.249755859375),
	[15] = Vector3.new(155.78236389160156, 1320.4747314453125, -2226.569580078125),
	[16] = Vector3.new(-964.1453857421875, 1385.07421875, -2553.462158203125),
	[17] = Vector3.new(-1230.3951416015625, 1384.384033203125, -2261.093994140625),
	[18] = Vector3.new(-1797.848388671875, 314.9781188964844, 1098.8353271484375),
	[19] = Vector3.new(-1261.2542724609375, 288.99993896484375, 746.497802734375),
	[20] = Vector3.new(-1377.419189453125, 265.0743713378906, -53.3534049987793),
	[21] = Vector3.new(-788.6260375976562, 966.8233032226562, 121.39598083496094),
	[22] = Vector3.new(918.4935302734375, 1021.5743408203125, 15.780023574829102),
	[23] = Vector3.new(1052.7286376953125, 1045.9229736328125, -481.54010009765625),
	[24] = Vector3.new(789.4100952148438, 1229.9996337890625, 420.6759033203125),
}

local function farmActiveFolderForName(name)
	local wanted = tostring(name or ""):lower()
	if wanted == "bear cub" or wanted == "kaiden subordinate" or wanted == "hoyuzo subordinate" then
		local humanoids = workspace:FindFirstChild("Humanoids")
		local regions = humanoids and humanoids:FindFirstChild("Regions")
		local grove = regions and regions:FindFirstChild("Bamboo Grove")
		return grove and grove:FindFirstChild("ActiveNpcs")
	end
	if wanted == "beast born demon" then
		local humanoids = workspace:FindFirstChild("Humanoids")
		local regions = humanoids and humanoids:FindFirstChild("Regions")
		local harbor = regions and regions:FindFirstChild("Mistfall Harbor")
		return harbor and harbor:FindFirstChild("ActiveNpcs")
	end
	if wanted == "fire profound demon" then
		local humanoids = workspace:FindFirstChild("Humanoids")
		local regions = humanoids and humanoids:FindFirstChild("Regions")
		local iceveil = regions and regions:FindFirstChild("Iceveil Valley")
		return iceveil and iceveil:FindFirstChild("ActiveNpcs")
	end
	local raidPoint = tonumber(wanted:match("^raid box point (%d+)$"))
	if raidPoint and RAID_BOX_POINTS[raidPoint] then
		local humanoids = workspace:FindFirstChild("Humanoids")
		local regions = humanoids and humanoids:FindFirstChild("Regions")
		local temporary = regions and regions:FindFirstChild("Temporary")
		return temporary and temporary:FindFirstChild("ActiveNpcs")
	end
	return farmActiveFolder()
end

local function farmFindMobsByName(name)
	local out, seenRoots = {}, {}
	local wanted = tostring(name):lower()
	local folder = farmActiveFolderForName(name)
	if not folder then return out end

	local raidPoint = tonumber(wanted:match("^raid box point (%d+)$"))
	if raidPoint and RAID_BOX_POINTS[raidPoint] then
		-- Detect every living NPC around this chest point instead of relying on
		-- NPC names. Some raid points reuse/change names, especially point 6.
		local raidOrigin = RAID_BOX_POINTS[raidPoint]
		local raidRadius = raidPoint == 6 and 180 or 110
		local candidates = {}
		local seenModels = {}
		for _, hum in ipairs(folder:GetDescendants()) do
			if hum:IsA("Humanoid") and hum.Health > 0 then
				local model = hum.Parent
				if model and model:IsA("Model") and not seenModels[model] then
					local root = model:FindFirstChild("HumanoidRootPart")
						or model:FindFirstChild("HumanoidRootPart", true)
					if root and root:IsA("BasePart") and not seenRoots[root] then
						local distance = (root.Position - raidOrigin).Magnitude
						if distance <= raidRadius then
							seenModels[model] = true
							seenRoots[root] = true
							table.insert(candidates, { Model = model, Distance = distance })
						end
					end
				end
			end
		end
		table.sort(candidates, function(a, b) return a.Distance < b.Distance end)
		for _, candidate in ipairs(candidates) do
			table.insert(out, candidate.Model)
		end
		return out
	end
	-- Wrapped mobs can appear both as direct named wrappers and inside
	-- GetChildren() entries. Resolve by name instead of relying on child indexes.
	if wanted == "kaiden subordinate" or wanted == "hoyuzo subordinate"
		or wanted == "beast born demon" then
		local exactName = wanted == "kaiden subordinate" and "Kaiden Subordinate"
			or wanted == "hoyuzo subordinate" and "Hoyuzo Subordinate"
			or "Beast Born Demon"
		for _, wrapper in ipairs(folder:GetChildren()) do
			local model
			if wrapper.Name:lower() == wanted then
				model = wrapper:FindFirstChild(exactName) or wrapper
			else
				model = wrapper:FindFirstChild(exactName)
			end
			if model then
				local root = model:FindFirstChild("HumanoidRootPart")
					or model:FindFirstChild("HumanoidRootPart", true)
				local hum = model:FindFirstChildWhichIsA("Humanoid", true)
				if root and root:IsA("BasePart") and not seenRoots[root]
					and (not hum or hum.Health > 0) then
					seenRoots[root] = true
					table.insert(out, model)
					if wanted == "kaiden subordinate" and #out >= 4 then break end
					if wanted == "beast born demon" and #out >= 3 then break end
				end
			end
		end
		return out
	end

	for _, item in ipairs(folder:GetDescendants()) do
		if item:IsA("BasePart") and item.Name == "HumanoidRootPart" and not seenRoots[item] then
			local node = item.Parent
			local matched = false
			while node and node ~= folder do
				if node.Name:lower() == wanted then
					matched = true
					break
				end
				node = node.Parent
			end
			if matched and wanted ~= "zuko" then
				seenRoots[item] = true
				table.insert(out, item.Parent)
			end
		end
	end
	return out
end

local function farmBossFolder(name)
	local humanoids = workspace:FindFirstChild("Humanoids")
	local regions = humanoids and humanoids:FindFirstChild("Regions")
	if not regions then return nil end

	local wanted = tostring(name or ""):lower()
	if wanted == "" then return nil end

	-- Search every region first. Several bosses move/live in regions that do not
	-- match the old static BOSS_REGIONS table, so a saved warp position alone
	-- was not enough for the farm to acquire a target.
	for _, region in ipairs(regions:GetChildren()) do
		local active = region:FindFirstChild("ActiveNpcs")
		if active then
			local direct = active:FindFirstChild(name)
			if direct then return active end

			for _, node in ipairs(active:GetDescendants()) do
				if node.Name:lower() == wanted then
					return active
				end
			end
		end
	end

	-- Fallback for bosses that have not spawned yet but have a known region.
	local region = regions:FindFirstChild(BOSS_REGIONS[name] or "Misc")
	return region and region:FindFirstChild("ActiveNpcs")
end

local function farmBossModel(name, includeDead)
	local folder = farmBossFolder(name)
	if not folder then return nil end
	local wanted = tostring(name or ""):lower()
	if wanted == "" then return nil end

	-- Exact nested boss paths.
	if wanted == "zentaro" or wanted == "yeti demon" then
		local exactName = wanted == "zentaro" and "Zentaro" or "Yeti Demon"
		local wrapper = folder:FindFirstChild(exactName)
		local model = wrapper and wrapper:FindFirstChild(exactName)
		local root = model and (
			model:FindFirstChild("HumanoidRootPart")
			or model:FindFirstChild("HumanoidRootPart", true)
		)
		local hum = model and model:FindFirstChildWhichIsA("Humanoid", true)
		if model and root and (not hum or hum.Health > 0) then return model end
		if includeDead and model and root then return model end
		-- If the exact layout changed, fall through to the generic recursive scan.
	end

	if wanted == "kaiden" or wanted == "akazo" or wanted == "serpent trainee"
		or wanted == "gyutai" or wanted == "datai" or wanted == "thunder trainee" then
		local exactName = wanted == "kaiden" and "Kaiden"
			or wanted == "akazo" and "Akazo"
			or wanted == "gyutai" and "Gyutai"
			or wanted == "datai" and "Datai"
			or wanted == "thunder trainee" and "Thunder Trainee"
			or "Serpent Trainee"
		local wrapper = folder:FindFirstChild(exactName)
		local model = wrapper and (wrapper:FindFirstChild(exactName) or wrapper)
		if model then
			local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("HumanoidRootPart", true)
			local hum = model:FindFirstChildWhichIsA("Humanoid", true)
			if root and (not hum or hum.Health > 0) then return model end
			if includeDead and root then return model end
		end
		-- If the exact layout changed, fall through to the generic recursive scan.
	end

	local deadModel
	for _, item in ipairs(folder:GetDescendants()) do
		if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
			local node = item.Parent
			while node and node ~= folder do
				if node.Name:lower() == wanted then
					local bossModel = item.Parent
					local bossHumanoid = bossModel:IsA("Model")
						and bossModel:FindFirstChildWhichIsA("Humanoid", true)
						or nil
					if not bossHumanoid or bossHumanoid.Health > 0 then
						return bossModel
					end
					deadModel = bossModel
					break
				end
				node = node.Parent
			end
		end
	end
	return includeDead and deadModel or nil
end

local function farmFindBossByName(name)
	return farmBossModel(name, false)
end

local function farmFindBoss()
	return farmFindBossByName(Farm.BossName)
end

local function farmWarpToBossSpawn(name)
	local position = BOSS_WARP_POSITIONS[name]
	if not position then return false, "no saved boss position" end
	return tpSafeGo(CFrame.new(position))
end

local function farmListMobTypes()
	local list = {}
	for _, n in ipairs(FARM_TYPES) do table.insert(list, n) end
	return list
end

local function farmListBossTypes()
	local list = {}
	for _, name in ipairs(BOSS_TYPES) do
		table.insert(list, name)
	end
	return list
end

local BossStatus = { States = {}, Running = true }

function BossStatus:MarkDead(state, model)
	if not self.Running or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	if state.Model ~= model or state.DeadAt then return end
	state.DeadAt = os.clock()
	state.Alive = false
end

function BossStatus:Update(name)
	MazxBoot.Perf.BossScans += 1
	local state = self.States[name]
	if not state then
		state = {}
		self.States[name] = state
	end
	state.FolderLoaded = farmBossFolder(name) ~= nil
	local model = farmBossModel(name, true)
	local hum = model and model:FindFirstChildWhichIsA("Humanoid", true)
	local alive = model ~= nil and (not hum or hum.Health > 0)
	if alive then
		if not state.Alive then
			if state.DeadAt then
				state.RespawnSeconds = os.clock() - state.DeadAt
				state.Samples = (state.Samples or 0) + 1
			end
			state.LastSeenTime = os.date("%H:%M:%S")
			state.DeadAt = nil
		end
		state.Alive = true
		if state.Model ~= model or state.Humanoid ~= hum then
			if state.DeathConnection then state.DeathConnection:Disconnect() end
			state.Model, state.Humanoid = model, hum
			state.DeathConnection = hum and hum.HealthChanged:Connect(function(health)
				if health <= 0 then self:MarkDead(state, model) end
			end) or nil
		end
	else
		if state.Alive and model == state.Model and hum and hum.Health <= 0 then
			self:MarkDead(state, model)
		end
		state.Alive = false
	end
	state.DeadVisible = model ~= nil and hum ~= nil and hum.Health <= 0
	return state
end

function BossStatus:Duration(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

function BossStatus:Describe(state)
	local detail = state.LastSeenTime and ("พบล่าสุด " .. state.LastSeenTime) or "ยังไม่พบในเซสชันนี้"
	if state.RespawnSeconds then
		detail = detail .. " | รอบที่วัดได้ ~" .. self:Duration(state.RespawnSeconds)
	end
	if state.Alive then return "เกิดแล้ว • พร้อมฟาร์ม", detail, T.Mint end
	if not state.FolderLoaded then return "ยังไม่พบข้อมูลโซน", detail, T.Sub end
	if state.DeadAt and state.RespawnSeconds then
		local remaining = state.DeadAt + state.RespawnSeconds - os.clock()
		if remaining > 0 then
			return "คาดว่าจะเกิดใน ~" .. self:Duration(remaining), detail, T.Gold
		end
		return "ถึงเวลาประมาณแล้ว • รอตรวจพบบอส", detail, T.Gold
	end
	if state.DeadAt or state.DeadVisible then
		return "ตายแล้ว • ยังไม่ทราบเวลาเกิด", detail, T.Sub
	end
	return "ยังไม่พบ • ยังไม่ทราบเวลาเกิด", detail, T.Sub
end

function BossStatus:Stop()
	self.Running = false
	for _, state in pairs(self.States) do
		if state.DeathConnection then state.DeathConnection:Disconnect() end
	end
end

gui.Destroying:Connect(function() BossStatus:Stop() end)

local function farmNearestByName(name, bossMode)
	if Farm.Dungeon and Farm.Dungeon.Enabled then return Farm.Dungeon:FindTarget() end
	local list
	if bossMode then
		local b = farmFindBossByName(name)
		list = b and { b } or {}
	else
		list = farmFindMobsByName(name)
	end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best, bestD = nil, math.huge
	for _, mob in ipairs(list) do
		local mobHumanoid = mob:IsA("Model") and mob:FindFirstChildWhichIsA("Humanoid", true) or nil
		local alive = not mobHumanoid or mobHumanoid.Health > 0
		local pivot
		if alive and mob:IsA("Model") then pivot = mob:GetPivot().Position
		elseif alive and mob:IsA("BasePart") then pivot = mob.Position
		elseif alive then
			local p = mob:FindFirstChildWhichIsA("BasePart", true)
			if p then pivot = p.Position end
		end
		if pivot then
			local d = (pivot - hrp.Position).Magnitude
			if d < bestD then bestD = d; best = mob end
		end
	end
	return best
end

local function farmMultiBossDisconnectDeath()
	if Farm._multiBossDeathConn then
		Farm._multiBossDeathConn:Disconnect()
		Farm._multiBossDeathConn = nil
	end
end

local function farmMultiBossWatchTarget(target)
	farmMultiBossDisconnectDeath()
	if not Farm.MultiBossEnabled or not Farm.BossEnabled or not target then return end
	local hum = target:FindFirstChildWhichIsA("Humanoid", true)
	if not hum then return end
	local watchedName = Farm.BossName
	Farm._multiBossDeathConn = hum.HealthChanged:Connect(function(health)
		if health <= 0 and Farm.MultiBossEnabled and Farm.BossName == watchedName
			and Farm._target == target then
			Farm._multiBossPendingAdvance = watchedName
		end
	end)
	if hum.Health <= 0 then Farm._multiBossPendingAdvance = watchedName end
end

local function farmMultiBossAdvance(deadName)
	if not Farm.MultiBossEnabled then return false end
	local order = Farm.MultiBossOrder
	local count = #order
	if count == 0 then return false end

	local currentIndex = Farm.MultiBossIndex
	if order[currentIndex] ~= deadName then
		for index, name in ipairs(order) do
			if name == deadName then
				currentIndex = index
				break
			end
		end
	end

	Farm.MultiBossIndex = (currentIndex % count) + 1
	Farm.BossName = order[Farm.MultiBossIndex]
	Farm._multiBossPendingAdvance = nil
	farmMultiBossDisconnectDeath()
	if Farm.MultiBossLabel and Farm.MultiBossLabel.Parent then
		Farm.MultiBossLabel.Text = "Multi Boss • ไปตี " .. tostring(Farm.BossName)
		Farm.MultiBossLabel.TextColor3 = T.Mint
	end
	print("[Mazxhub MultiBoss] next -> " .. tostring(Farm.BossName))
	return true
end

local function farmMultiBossAdd(name)
	if not name or Farm.MultiBossSelected[name] then return false end
	Farm.MultiBossSelected[name] = true
	table.insert(Farm.MultiBossOrder, name)
	return true
end

local function farmMultiBossRemove(name)
	if not name or not Farm.MultiBossSelected[name] then return false end
	Farm.MultiBossSelected[name] = nil
	for index = #Farm.MultiBossOrder, 1, -1 do
		if Farm.MultiBossOrder[index] == name then table.remove(Farm.MultiBossOrder, index) end
	end
	if Farm.MultiBossIndex > #Farm.MultiBossOrder then Farm.MultiBossIndex = 1 end
	return true
end

local function farmMultiBossClear()
	Farm.MultiBossSelected = {}
	Farm.MultiBossOrder = {}
	Farm.MultiBossIndex = 1
	Farm._multiBossPendingAdvance = nil
	farmMultiBossDisconnectDeath()
end

local function farmMultiBossText()
	if #Farm.MultiBossOrder == 0 then return "ยังไม่ได้เลือกบอส" end
	return "เลือก: " .. table.concat(Farm.MultiBossOrder, " → ")
end

local function farmCFrameOf(mob)
	if not mob then return nil end
	if mob:IsA("Model") then
		local root = mob:FindFirstChild("HumanoidRootPart")
			or mob.PrimaryPart
			or mob:FindFirstChildWhichIsA("BasePart", true)
		if root then return root.CFrame end
		return mob:GetPivot()
	elseif mob:IsA("BasePart") then return mob.CFrame
	else
		local p = mob:FindFirstChildWhichIsA("BasePart", true)
		if p then return p.CFrame end
	end
	return nil
end

local function farmGetSignal()
	if Farm._cachedSignal and Farm._cachedSignal.Parent then return Farm._cachedSignal end
	local now = os.clock()
	if now < (Farm._signalRetryAt or 0) then return nil end
	Farm._signalRetryAt = now + 0.5
	local rs = game:GetService("ReplicatedStorage")
	local ok, sig = pcall(function()
		return rs.Communication.ServerAndClient.Signals.SignalEvent.Event
	end)
	if not ok or not sig then
		local node = rs:FindFirstChild("Communication", true)
		local signals = node and node:FindFirstChild("SignalEvent", true)
		sig = signals and signals:FindFirstChild("Event")
	end
	if sig and sig:IsA("RemoteEvent") then Farm._cachedSignal = sig; return sig end
	return nil
end

local MITSU_LV115_QUEST = "Ill put out the blaze(Lv 115)"

local function farmAcceptMitsuLv115Quest()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local ev = farmGetSignal()
	if not char or not hum or hum.Health <= 0 or not root then
		return false, "ตัวละครยังไม่พร้อม"
	end
	if not ev then return false, "ไม่พบ SignalEvent" end

	local npc = tpFindNPC("Demon Slayer Mitsu")
	local npcCf = farmCFrameOf(npc) or TP.Destination("Demon Slayer Mitsu")
	if not npcCf then return false, "ไม่พบ Demon Slayer Mitsu" end

	local stand = npcCf * CFrame.new(0, 0, -3)
	root.CFrame = CFrame.lookAt(stand.Position, npcCf.Position)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	task.wait(0.30)

	pcall(function() ev:FireServer("NpcTalking", "Ended") end)
	task.wait(0.12)
	local ok, err = pcall(function()
		ev:FireServer("AddQuest", MITSU_LV115_QUEST)
	end)
	if not ok then return false, tostring(err) end
	task.wait(0.12)
	pcall(function() ev:FireServer("NpcTalking", "Ended") end)

	Farm._acceptedQuestText = MITSU_LV115_QUEST
	Farm._questNeeded = false
	Farm._lastQuestAt = os.clock()
	return true
end

local function farmCurrentQuestSpec()
	if Farm.MultiBossEnabled then return nil end
	if Farm.BossEnabled then
		return BOSS_QUEST_SPECS[Farm.BossName]
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "bandit" then
		return {
			Text = "Ill take 3 bandits",
			RequiredKills = 3,
			TargetName = "Bandit",
			NPCName = "Krue",
		}
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "bear cub" then
		return {
			Text = "Ill drive the bears back(Lv 10)",
			RequiredKills = 4,
			TargetName = "Bear Cub",
			NPCName = "Tom",
		}
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "kaiden subordinate" then
		return {
			Text = "Ill clear out his subordinates(Lv 26)",
			RequiredKills = 4,
			TargetName = "Kaiden Subordinate",
			NPCName = "Chaka",
			ExactGroupSize = 4,
		}
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "hoyuzo subordinate" then
		return {
			Text = "I will clear out his guards(Lv 40)",
			RequiredKills = 4,
			TargetName = "Hoyuzo Subordinate",
			NPCName = "Wagwan",
			ExactGroupSize = 4,
		}
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "beast born demon" then
		return {
			Text = "Ill drive them off(Lv 47)",
			RequiredKills = 3,
			TargetName = "Beast Born Demon",
			NPCName = "Rin",
			ExactGroupSize = 3,
		}
	end
	if type(Farm.MobName) == "string" and Farm.MobName:lower() == "fire profound demon" then
		return {
			Text = MITSU_LV115_QUEST,
			TargetName = "Fire Profound Demon",
			NPCName = "Demon Slayer Mitsu",
			RequiredKills = 8,
			ExactGroupSize = 8,
		}
	end
	return nil
end

local QuestRuntime = {
	Generation = 0, Request = nil, Watchers = {}, Failures = 0,
	DeadHumanoids = setmetatable({}, { __mode = "k" }),
	SubmittedAt = 0, ProgressAt = 0, LastDeathAt = 0, LastHitAt = 0, Reconciliations = 0, NextProbeAt = 0,
}

function QuestRuntime:RemoveWatcher(record)
	for _, conn in ipairs(record.Connections) do conn:Disconnect() end
	record.Connections = {}
	if self.Watchers[record.Mob] == record then self.Watchers[record.Mob] = nil end
end

function QuestRuntime:ClearWatchers()
	for _, record in pairs(self.Watchers) do self:RemoveWatcher(record) end
	self.Watchers = {}
end

function QuestRuntime:Reset(reason, preserveReconciliation)
	self.Generation += 1
	self.Request = nil
	self:ClearWatchers()
	self.Failures, self.SubmittedAt, self.ProgressAt, self.LastHitAt = 0, 0, 0, 0
	self.LastDeathAt = 0
	self.NextProbeAt = 0
	if not preserveReconciliation then self.Reconciliations = 0 end
	Farm.QuestKills = 0
	Farm._questBusy = false
	Farm._questNeeded = Farm.AutoQuest and farmCurrentQuestSpec() ~= nil
	Farm._acceptedQuestText = nil
	Farm._lastQuestAt = -math.huge
	Farm._questReadyAt = 0
	Farm._target, Farm._attackTarget = nil, nil
	if Farm.ReleaseInputs then Farm.ReleaseInputs() end
end

local function farmResetQuest(reason)
	QuestRuntime:Reset(reason)
end

function QuestRuntime:Valid(request)
	if self.Request ~= request or self.Generation ~= request.Generation then return false, "cancelled" end
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then return false, "cancelled" end
	if not Farm.Enabled or not Farm.AutoQuest then return false, "cancelled" end
	if Farm._lootBusy or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then return false, "paused" end
	if Farm.InputBlocked and Farm.InputBlocked() then return false, "paused" end
	if player.Character ~= request.Character or request.Humanoid.Health <= 0 then return false, "character" end
	if request.Character:FindFirstChildOfClass("Humanoid") ~= request.Humanoid then return false, "character" end
	if request.Root.Parent ~= request.Character
		or request.Character:FindFirstChild("HumanoidRootPart") ~= request.Root then return false, "character" end
	local current = farmCurrentQuestSpec()
	if not current or current.Text ~= request.Quest.Text
		or current.TargetName ~= request.Quest.TargetName or Farm.BossEnabled ~= request.BossMode then
		return false, "cancelled"
	end
	return true
end

function QuestRuntime:Wait(request, seconds)
	task.wait(seconds)
	return self:Valid(request)
end

function QuestRuntime:Visit(request)
	local valid, reason = self:Valid(request)
	if not valid then return false, reason end
	local ev = farmGetSignal()
	local npcName = request.Quest.NPCName or Farm.QuestNpcName
	local npc = tpFindNPC(npcName)
	local npcCf = farmCFrameOf(npc)
	local loadDeadline = os.clock() + 45
	while ev and not npcCf and os.clock() < loadDeadline do
		if not TP.ApproachSaved(request.Root, npcName) then break end
		valid, reason = self:Wait(request, 0.4)
		if not valid then return false, reason end
		npc = tpFindNPC(npcName)
		npcCf = farmCFrameOf(npc)
	end
	if not ev or not npcCf then return false, "unavailable" end
	local standPosition = (npcCf * CFrame.new(0, 0, -3)).Position
	request.Root.CFrame = CFrame.lookAt(standPosition, npcCf.Position)
	request.Root.AssemblyLinearVelocity = Vector3.zero
	request.Root.AssemblyAngularVelocity = Vector3.zero
	valid, reason = self:Wait(request, 0.35)
	if not valid then return false, reason end
	ev:FireServer("NpcTalking", "Ended")
	valid, reason = self:Wait(request, 0.15)
	if not valid then return false, reason end
	if request.BossMode and farmFindBossByName(request.Quest.TargetName) ~= request.Boss then
		return false, "boss missing"
	end
	npcCf = farmCFrameOf(npc)
	if not npc.Parent or not npcCf or (request.Root.Position - npcCf.Position).Magnitude > 8 then
		return false, "out of range"
	end
	ev:FireServer("AddQuest", request.Quest.Text)
	valid, reason = self:Wait(request, 0.15)
	if not valid then return false, reason end
	ev:FireServer("NpcTalking", "Ended")
	valid, reason = self:Wait(request, 0.35)
	if not valid then return false, reason end
	return true
end

function QuestRuntime:Try()
	local quest = farmCurrentQuestSpec()
	if not Farm.Enabled or not Farm.AutoQuest or Farm._lootBusy or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy or not quest or self.Request then return end
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then return end
	if Farm.InputBlocked and Farm.InputBlocked() then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or hum.Health <= 0 or not root then return end
	local now = os.clock()
	if Farm._acceptedQuestText == quest.Text and not Farm._questNeeded then
		-- Poll tracked combat targets as well as listening to death events.
		-- A missing model with positive HP is not evidence of a kill.
		local pendingDeaths = {}
		for _, record in pairs(self.Watchers) do
			if record.Generation == self.Generation and record.Humanoid.Health <= 0 then
				table.insert(pendingDeaths, record)
			end
		end
		for _, record in ipairs(pendingDeaths) do self:ConfirmDeath(record, false) end
		if Farm._questNeeded then return end
		-- Bandit repeats are driven strictly by three confirmed deaths, not time.
		if quest.TargetName == "Bandit" then return end
		-- Damage alone is not quest progress. A missed death/failed acceptance must
		-- not latch this state until respawn. Retry conservatively, never per swing.
		local recoveryDelay = self.Reconciliations == 0 and 45 or 120
		if self.LastHitAt > 0 and now - self.LastHitAt < 2
			and now - self.LastDeathAt >= recoveryDelay and now - self.SubmittedAt >= recoveryDelay then
			self.Reconciliations += 1
			self:Reset("stale progress", true)
			Farm._questReadyAt = now + 1.5
		end
		return
	end
	Farm._questNeeded = true
	if now < Farm._questReadyAt or now - Farm._lastQuestAt < 2 then return end
	if now < self.NextProbeAt then return end
	self.NextProbeAt = now + 0.35
	local boss = Farm.BossEnabled and farmFindBossByName(quest.TargetName) or nil
	if Farm.BossEnabled and not boss then return end
	local request = {
		Generation = self.Generation, Character = char, Humanoid = hum, Root = root,
		Quest = quest, BossMode = Farm.BossEnabled, Boss = boss,
	}
	self.Request = request
	Farm._questBusy, Farm._lastQuestAt = true, now
	Farm._target, Farm._attackTarget = nil, nil
	if Farm.ReleaseInputs then Farm.ReleaseInputs() end
	task.spawn(function()
		local ok, dispatched, reason = pcall(function() return self:Visit(request) end)
		if self.Request ~= request or self.Generation ~= request.Generation then return end
		local valid = self:Valid(request)
		self.Request = nil
		Farm._questBusy = false
		if ok and dispatched and valid then
			self.Failures = 0
			self.SubmittedAt, self.ProgressAt, self.LastHitAt = os.clock(), os.clock(), 0
			self.LastDeathAt = self.SubmittedAt
			Farm._acceptedQuestText, Farm._questNeeded, Farm._questReadyAt = quest.Text, false, 0
		else
			self.Failures = math.min(self.Failures + 1, 4)
			local delay = reason == "paused" and 0.5 or math.min(2 ^ self.Failures, 12)
			Farm._questNeeded = true
			Farm._questReadyAt = os.clock() + delay
		end
	end)
end

local function farmTryAutoQuest()
	QuestRuntime:Try()
end

function QuestRuntime:ConfirmDeath(record, diedSignal)
	if record.Counted or self.Watchers[record.Mob] ~= record or record.Generation ~= self.Generation then return end
	-- Every quest mob/boss must have been hit by this farm and its HP must
	-- actually reach 0. A despawn/disappearance by itself never counts.
	if not record.HitObserved or record.Humanoid.Health > 0 then return end
	local quest = farmCurrentQuestSpec()
	if not Farm.Enabled or not Farm.AutoQuest or not quest or quest.Text ~= record.Quest.Text
		or Farm._acceptedQuestText ~= quest.Text then return end
	record.Counted = true
	self.DeadHumanoids[record.Humanoid] = true
	self:RemoveWatcher(record)
	self.ProgressAt = os.clock()
	self.LastDeathAt = self.ProgressAt
	Farm.QuestKills += 1
	local requiredKills = tonumber(quest.RequiredKills)
	print("[Mazxhub Quest] " .. tostring(quest.TargetName) .. " " .. Farm.QuestKills .. "/" .. tostring(requiredKills or "?"))
	if requiredKills and Farm.QuestKills >= requiredKills then
		-- Required confirmed kills completed: immediately return to the same
		-- quest giver, then let the normal auto-quest flow accept the next round.
		local completedText = quest.Text
		local completedTarget = quest.TargetName
		local completedNpc = quest.NPCName or Farm.QuestNpcName
		self:Reset("round complete")
		Farm._questReadyAt = os.clock() + 0.35

		task.delay(0.05, function()
			if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then return end
			if not Farm.Enabled or not Farm.AutoQuest then return end
			local cf = TP.Destination(completedNpc)
			if cf then
				tpSafeGo(cf)
			else
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then TP.ApproachSaved(root, completedNpc) end
			end
		end)

		task.delay(0.45, function()
			if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then return end
			if not Farm.Enabled or not Farm.AutoQuest or Farm.BossEnabled then return end
			local current = farmCurrentQuestSpec()
			if not current or current.Text ~= completedText or current.TargetName ~= completedTarget then return end
			Farm._questNeeded = true
			Farm._acceptedQuestText = nil
			Farm._lastQuestAt = -math.huge
			self.NextProbeAt = 0
			self:Try()
		end)
	end
end

function QuestRuntime:Track(mob, beforeHealth)
	local quest = farmCurrentQuestSpec()
	if not Farm.Enabled or not Farm.AutoQuest or not quest or not mob or not mob.Parent
		or self.Request or Farm._acceptedQuestText ~= quest.Text then return end
	local hum = mob:IsA("Model") and mob:FindFirstChildWhichIsA("Humanoid", true) or nil
	if not hum or self.DeadHumanoids[hum] then return end

	-- farmTrackQuestDeath is called at the real attack point before dispatch.
	-- Start tracking only while the target is alive.
	if type(beforeHealth) ~= "number" then beforeHealth = hum.Health end
	if beforeHealth <= 0 or hum.Health <= 0 then return end
	self.DeadHumanoids[hum] = nil
	self.LastHitAt = os.clock()

	local previous = self.Watchers[mob]
	if previous and previous.Humanoid == hum and previous.Generation == self.Generation then
		-- If a previous swing changed HP before the HealthChanged listener was
		-- observed, detect that drop from the next attack's beforeHealth value.
		if beforeHealth < (previous.LastHealth or beforeHealth) then
			previous.HitObserved = true
			self.ProgressAt = os.clock()
		end
		previous.LastHealth = math.min(previous.LastHealth or beforeHealth, beforeHealth)
		if hum.Health <= 0 then self:ConfirmDeath(previous, false) end
		return
	end
	if previous then self:RemoveWatcher(previous) end

	local record = {
		Mob = mob, Humanoid = hum, Quest = quest, Generation = self.Generation,
		Counted = false, HitObserved = false, Connections = {}, LastHealth = beforeHealth,
		Folder = Farm.BossEnabled and farmBossFolder(quest.TargetName) or farmActiveFolderForName(quest.TargetName),
	}
	self.Watchers[mob] = record

	table.insert(record.Connections, hum.Died:Connect(function()
		self:ConfirmDeath(record, true)
	end))
	table.insert(record.Connections, hum.HealthChanged:Connect(function(health)
		if self.Watchers[mob] ~= record or record.Generation ~= self.Generation then return end
		if health < record.LastHealth then
			record.HitObserved = true
			self.ProgressAt = os.clock()
		end
		record.LastHealth = health
		if health <= 0 then self:ConfirmDeath(record, false) end
	end))

	local function removed()
		if hum.Health <= 0 then self:ConfirmDeath(record, false) end
		if record.Counted or record.RemovalPending then return end
		record.RemovalPending = true
		task.delay(0.5, function()
			if self.Watchers[mob] ~= record or record.Generation ~= self.Generation then return end
			if hum.Health <= 0 then self:ConfirmDeath(record, false) end
			if mob.Parent and (not record.Folder or mob:IsDescendantOf(record.Folder)) then
				record.RemovalPending = false
			else
				-- Do not count this as a kill unless HP was confirmed at 0.
				self:RemoveWatcher(record)
			end
		end)
	end
	table.insert(record.Connections, mob.Destroying:Connect(removed))
	table.insert(record.Connections, mob.AncestryChanged:Connect(function()
		if not mob.Parent or (record.Folder and not mob:IsDescendantOf(record.Folder)) then removed() end
	end))
end

local function farmTrackQuestDeath(mob, beforeHealth)
	if Farm.TrackStoryDeath then Farm.TrackStoryDeath(mob, beforeHealth) end
	if Farm.TrackBearDeath then Farm.TrackBearDeath(mob, beforeHealth) end
	QuestRuntime:Track(mob, beforeHealth)
end

-- Auto block after taking damage: hold F for 3 seconds, then release.
-- The explicit UnHold signal is sent on release as a fallback for the game.
local DamageBlock = {
	Holding = false,
	Until = 0,
	Generation = 0,
	Input = nil,
}

function DamageBlock:Release()
	if not self.Holding then return end
	self.Holding = false
	self.Generation += 1
	local input = self.Input
	self.Input = nil
	if input then
		pcall(function()
			input:SendKeyEvent(false, Enum.KeyCode.F, false, game)
		end)
	end
	pcall(function()
		local ev = farmGetSignal()
		if not ev then return end
		local pos
		if vector and vector.create then
			pos = vector.create(574.9617919921875, 1120.5, -896.7974243164062)
		else
			pos = Vector3.new(574.9617919921875, 1120.5, -896.7974243164062)
		end
		ev:FireServer("server_skill_controller_signaler", "Blocking", "UnHold", pos)
	end)
end

function DamageBlock:Hold(seconds)
	seconds = tonumber(seconds) or 3
	local now = os.clock()
	self.Until = math.max(self.Until, now + seconds)
	if not self.Holding then
		self.Holding = true
		self.Generation += 1
		local input = game:GetService("VirtualInputManager")
		self.Input = input
		pcall(function()
			input:SendKeyEvent(true, Enum.KeyCode.F, false, game)
		end)
	end

	local generation = self.Generation
	task.spawn(function()
		while self.Holding and self.Generation == generation do
			local remaining = self.Until - os.clock()
			if remaining <= 0 then break end
			task.wait(math.min(remaining, 0.1))
		end
		if self.Holding and self.Generation == generation and os.clock() >= self.Until then
			self:Release()
		end
	end)
end

-- Client-side only: suppress obvious hurt/stun reaction tracks so Auto Attack
-- can keep trying to swing after taking damage. Server-side stun/cooldown can
-- still reject attacks; this does not alter server damage or invulnerability.
local function farmCancelHitReactionAnimations(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if not animator then return end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		local animation = track.Animation
		local raw = (tostring(track.Name or "") .. " " .. tostring(animation and animation.Name or "")):lower()
		local compact = raw:gsub("[%s_%-]", "")
		local reaction = compact:find("hitreact", 1, true)
			or compact:find("hitstun", 1, true)
			or compact:find("hurt", 1, true)
			or compact:find("stun", 1, true)
			or compact:find("flinch", 1, true)
			or compact:find("knockback", 1, true)
			or compact:find("knockdown", 1, true)
			or compact:find("dazed", 1, true)
			or compact:find("damage", 1, true)
		if reaction then
			pcall(function() track:Stop(0) end)
		end
	end
end

local FarmRetreat = {
	Until = 0, Position = nil, Humanoid = nil, Connection = nil,
	Threat = nil, StartedAt = 0, MaxUntil = 0, NextCandidateAt = 0,
	Underground = nil, NextDamageProbeAt = 0,
}

function FarmRetreat:LeaveUnderground()
	local saved = self.Underground
	self.Underground = nil
	if not saved or not saved.Root.Parent then return end
	if player.Character == saved.Character and saved.Humanoid.Health > 0 then
		pcall(function()
			saved.Root.CFrame = saved.ReturnCFrame
			saved.Root.AssemblyLinearVelocity = Vector3.zero
			saved.Root.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	pcall(function() saved.Root.Anchored = saved.Anchored end)
end

function FarmRetreat:Clear()
	self:LeaveUnderground()
	self.Until = 0
	self.Position = nil
	self.Threat = nil
	self.StartedAt, self.MaxUntil, self.NextCandidateAt = 0, 0, 0
	self.NextDamageProbeAt = 0
end

function FarmRetreat:Stop()
	self:Clear()
	if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
	self.Humanoid = nil
end

function FarmRetreat:FindPosition(char, root, hum, target)
	local cf = farmCFrameOf(target)
	if not cf then return nil end
	local away = Vector3.new(root.Position.X - cf.Position.X, 0, root.Position.Z - cf.Position.Z)
	if away.Magnitude < 0.1 then away = Vector3.new(-cf.LookVector.X, 0, -cf.LookVector.Z) end
	if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
	away = away.Unit
	local side = Vector3.new(-away.Z, 0, away.X)
	local distance = math.clamp(tonumber(Farm.RetreatDistance) or 18, 10, 60)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char, target }
	params.RespectCanCollide = true
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = { char, target }
	overlap.RespectCanCollide = true
	local bodyHeight = math.max(root.Size.Y + math.max(hum.HipHeight, 0) * 2, 5)
	local clearance = Vector3.new(math.max(root.Size.X + 1, 3), bodyHeight, math.max(root.Size.Z + 1, 3))
	for _, angle in ipairs({ 0, math.pi / 4, -math.pi / 4, math.pi / 2, -math.pi / 2, math.pi }) do
		local direction = away * math.cos(angle) + side * math.sin(angle)
		local probe = cf.Position + direction * distance
		local ground = workspace:Raycast(probe + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), params)
		if ground and ground.Normal.Y >= 0.65 then
			local position = Vector3.new(probe.X, ground.Position.Y + math.max(hum.HipHeight, 0) + root.Size.Y * 0.5 + 0.5, probe.Z)
			local origin = Vector3.new(cf.Position.X, position.Y, cf.Position.Z)
			local wall = workspace:Raycast(origin, position - origin, params)
			if not wall then
				local boxCenter = Vector3.new(position.X, ground.Position.Y + bodyHeight * 0.5 + 0.2, position.Z)
				local blocked = false
				for _, part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(boxCenter), clearance, overlap)) do
					if part.CanCollide then blocked = true; break end
				end
				if not blocked then
					return CFrame.lookAt(position, Vector3.new(cf.Position.X, position.Y, cf.Position.Z))
				end
			end
		end
	end
	return nil
end

function FarmRetreat:FindUndergroundPosition(char, root, hum, target)
	local cf = farmCFrameOf(target)
	if not cf then return nil end
	local origin = Vector3.new(root.Position.X, math.max(root.Position.Y, cf.Position.Y) + 20, root.Position.Z)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclusions = { char, target }
	local npcs = workspace:FindFirstChild("Humanoids")
	if npcs then table.insert(exclusions, npcs) end
	params.FilterDescendantsInstances = exclusions
	params.RespectCanCollide = true
	local ground = workspace:Raycast(origin, Vector3.new(0, -256, 0), params)
	if not ground or ground.Normal.Y < 0.65 then return nil end
	local depth = math.clamp(tonumber(Farm.DamageDodgeDepth) or 60, 6, 150)
	local y = ground.Position.Y - depth
	local destroyY = workspace.FallenPartsDestroyHeight
	if type(destroyY) == "number" and y <= destroyY + 12 then return nil end
	local position = Vector3.new(root.Position.X, y, root.Position.Z)
	local returnPosition = Vector3.new(root.Position.X,
		ground.Position.Y + math.max(hum.HipHeight, 0) + root.Size.Y * 0.5 + 1, root.Position.Z)
	local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if forward.Magnitude < 0.01 then forward = Vector3.new(0, 0, -1) end
	return CFrame.lookAt(position, position + forward), CFrame.lookAt(returnPosition, returnPosition + forward)
end

function FarmRetreat:BeginDamage(char, root, hum, target)
	if not Farm.RetreatEnabled then self:Clear(); return end
	-- Auto Dungeon must stay on the mob and fight normally.
	-- Never warp/retreat underground when taking damage in Dungeon mode.
	if Farm.Dungeon and Farm.Dungeon.Enabled then
		self:Clear()
		DamageBlock:Release()
		return
	end
	local now = os.clock()
	local retreating = self.Until > now
	local delay = math.clamp(tonumber(Farm.RetreatDelay) or 1.2, 0.3, 5)
	if retreating then
		self.Until = math.min(self.MaxUntil, math.max(self.Until, now + delay))
	end
	if self.Underground then return end
	if now < self.NextDamageProbeAt then return end
	self.NextDamageProbeAt = now + 0.35
	local destination, returnCf = self:FindUndergroundPosition(char, root, hum, target)
	if not destination then return end
	if not retreating then
		self.StartedAt = now
		self.MaxUntil = now + math.min(8, delay * 3)
		self.Until = now + delay
	end
	self.Underground = { Character = char, Root = root, Humanoid = hum,
		Anchored = root.Anchored, ReturnCFrame = returnCf }
	self.Threat, self.Position = target, destination
	Farm._attackTarget = nil
	if Farm.ReleaseInputs then Farm.ReleaseInputs() end
	root.Anchored = true
	root.CFrame = destination
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function FarmRetreat:Watch()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if self.Humanoid == hum then return end
	self:Stop()
	self.Humanoid = hum
	if not hum then return end
	local lastHealth = hum.Health
	self.Connection = hum.HealthChanged:Connect(function(health)
		local damaged = health < lastHealth
		lastHealth = health
		if health <= 0 then self:Clear(); Farm._attackTarget = nil; return end
		if not damaged or not Farm.Enabled or Farm._questBusy or Farm._lootBusy or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then return end
		if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or player.Character ~= char then return end
		if Farm.InputBlocked and Farm.InputBlocked() then return end

		-- Dungeon only: taking damage must NEVER trigger the old underground
		-- retreat/teleport. Stay at the current mob and continue attacking.
		if Farm.Dungeon and Farm.Dungeon.Enabled then
			DamageBlock:Release()
			self:Clear()
			Farm._counterAttackPending = true
			farmCancelHitReactionAnimations(char)
			-- Do not access CombatRuntime here: this callback is defined before
			-- the local CombatRuntime table exists. attackSwing() consumes
			-- _counterAttackPending and resets NextAttackAt safely later.
			return
		end

		if Farm.CounterAttackOnHit then
			-- Keep taking normal damage, but do not enter the damage-retreat/block
			-- routine. Cancel local reaction tracks and request an immediate swing.
			DamageBlock:Release()
			self:Clear()
			Farm._counterAttackPending = true
			farmCancelHitReactionAnimations(char)
			task.delay(0.04, function()
				if Farm.CounterAttackOnHit and player.Character == char and hum.Health > 0 then
					farmCancelHitReactionAnimations(char)
				end
			end)
			task.delay(0.10, function()
				if Farm.CounterAttackOnHit and player.Character == char and hum.Health > 0 then
					farmCancelHitReactionAnimations(char)
				end
			end)
			return
		end

		if not Farm.RetreatEnabled then return end
		-- Normal damage reaction: hold block (F), then retreat underground.
		DamageBlock:Hold(3)

		local now = os.clock()
		local retreating = self.Until > now
		local target = retreating and self.Threat or Farm._attackTarget or Farm._target
		local root = char:FindFirstChild("HumanoidRootPart")
		if not target or not target.Parent or not root then return end
		local ok, err = pcall(function() self:BeginDamage(char, root, hum, target) end)
		if not ok then self:Clear(); Farm._lastRuntimeError = tostring(err) end
	end)
end

function FarmRetreat:BeginCombo(target)
	if not Farm.RetreatEnabled then self:Clear(); return true end
	-- Dungeon has no retreat at all. Treat the combo retreat request as handled
	-- so ComboRuntime immediately resumes normal attacking without teleporting.
	if Farm.Dungeon and Farm.Dungeon.Enabled then
		self:Clear()
		DamageBlock:Release()
		return true
	end
	if not Farm.Enabled or not Farm.RetreatEnabled or Farm._questBusy or Farm._lootBusy or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then return false end
	if self.Until > os.clock() then return false end
	if Farm.InputBlocked and Farm.InputBlocked() then return false end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetHum = target and target:FindFirstChildWhichIsA("Humanoid", true)
	if not root or not hum or hum.Health <= 0 or not target or not target.Parent
		or not targetHum or targetHum.Health <= 0 then return false end

	local destination, returnCf = self:FindUndergroundPosition(char, root, hum, target)
	if not destination or not returnCf then return false end

	local now = os.clock()
	local delay = math.clamp(tonumber(Farm.ComboRetreatDelay) or 4.0, 0.3, 5)
	self:Watch()
	self.StartedAt, self.MaxUntil, self.Until = now, now + delay, now + delay
	self.Threat, self.Position, self.NextCandidateAt = target, destination, now + 0.35
	self.Underground = {
		Character = char,
		Root = root,
		Humanoid = hum,
		Anchored = root.Anchored,
		ReturnCFrame = returnCf,
	}
	Farm._attackTarget = nil
	if Farm.ReleaseInputs then Farm.ReleaseInputs() end
	root.Anchored = true
	root.CFrame = destination
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	return true
end

function FarmRetreat:Step()
	self:Watch()
	if Farm.Dungeon and Farm.Dungeon.Enabled then
		-- Clear any retreat that may have started before Dungeon was enabled.
		self:Clear()
		DamageBlock:Release()
		return false
	end
	if not Farm.Enabled or not Farm.RetreatEnabled or self.Until <= os.clock() then self:Clear(); return false end
	if Farm.InputBlocked and Farm.InputBlocked() then self:Clear(); return false end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or not self.Humanoid or self.Humanoid.Health <= 0 or not self.Position then self:Clear(); return false end
	if self.Underground and (self.Underground.Root ~= root or self.Underground.Character ~= char) then
		self:Clear(); return false
	end
	local threatHum = self.Threat and self.Threat:FindFirstChildWhichIsA("Humanoid", true)
	if not self.Threat or not self.Threat.Parent or (threatHum and threatHum.Health <= 0) then self:Clear(); return false end
	Farm._attackTarget = nil
	if self.Underground then root.Anchored = true end
	root.CFrame = self.Position
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	return true
end
--------------------------------------------------------------
-- BOSS LOOT
--------------------------------------------------------------
local BossLoot = { Watcher = nil, Job = nil, Held = nil, Radius = 250 }

function BossLoot:Release()
	local held = self.Held
	self.Held = nil
	if held and held.Begun then pcall(function() held.Prompt:InputHoldEnd() end) end
end

function BossLoot:Unwatch()
	local record = self.Watcher
	self.Watcher = nil
	if record then for _, connection in ipairs(record.Connections) do connection:Disconnect() end end
end

function BossLoot:Finish()
	self:Release()
	local job = self.Job
	self.Job = nil
	Farm._lootBusy = false
	if job and job.Added then job.Added:Disconnect() end
end

function BossLoot:Reset()
	self:Finish()
	self:Unwatch()
end

function BossLoot:ConfirmDeath(record)
	if self.Watcher ~= record or record.Humanoid.Health > 0 then return end
	self:Unwatch()
	if not Farm.Enabled or not Farm.BossEnabled or not Farm.AutoLoot or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy
		or Farm.BossName ~= record.Name or player.Character ~= record.Character
		or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then return end
	local hum = record.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 or not record.Position then return end
	self:Finish()
	local now = os.clock()
	local job = { Origin = record.Position, Character = record.Character, Name = record.Name,
		StartedAt = now, Deadline = now + 45, LastActivity = now, NextScanAt = now + 0.35,
		Prompts = {}, Records = {}, SeenAny = false, Initialized = false }
	self.Job = job
	Farm._lootBusy, Farm._attackTarget = true, nil
	FarmRetreat:Clear()
	if Farm.ReleaseInputs then Farm.ReleaseInputs() end
	job.Added = workspace.DescendantAdded:Connect(function(instance)
		if self.Job == job and instance:IsA("ProximityPrompt") then job.Prompts[instance] = true end
	end)
end

function BossLoot:Observe()
	local record = self.Watcher
	if not record then return end
	local cf = farmCFrameOf(record.Model)
	if cf then record.Position = cf.Position end
	if record.Humanoid.Health <= 0 then self:ConfirmDeath(record)
	elseif not record.Model.Parent then self:Unwatch() end
end

function BossLoot:Track(target)
	if self.Watcher and self.Watcher.Model == target then return end
	self:Unwatch()
	if not target or not Farm.Enabled or not Farm.BossEnabled or not Farm.AutoLoot or self.Job then return end
	local hum = target:FindFirstChildWhichIsA("Humanoid", true)
	local cf = farmCFrameOf(target)
	if not hum or hum.Health <= 0 or not cf then return end
	local record = { Model = target, Humanoid = hum, Name = Farm.BossName,
		Character = player.Character, Position = cf.Position, Connections = {} }
	self.Watcher = record
	local function changed()
		if self.Watcher ~= record then return end
		local ok, err = pcall(function() self:Observe() end)
		if not ok then self:Reset(); Farm._lastRuntimeError = tostring(err) end
	end
	table.insert(record.Connections, hum.HealthChanged:Connect(changed))
	table.insert(record.Connections, hum.Died:Connect(changed))
	table.insert(record.Connections, target.AncestryChanged:Connect(changed))
end

function BossLoot:Candidate(prompt, job)
	if not prompt.Parent or not prompt.Enabled or not prompt:IsDescendantOf(workspace) then return nil end
	local action = tostring(prompt.ActionText):lower():match("^%s*(.-)%s*$")
	local claim = action == "claim" or action == "collect" or action == "pick up" or action == "pickup"
		or action == "เก็บ" or action == "เก็บของ"
	local open = action == "open" or action == "เปิด"
	if not claim and not open then return nil end
	local chest = tostring(prompt.ObjectText):lower():find("chest", 1, true) ~= nil
	local node, position, container = prompt.Parent, nil, prompt.Parent
	while node and node ~= workspace do
		local name = node.Name:lower()
		if name == "stationarynpcs" or name == "activenpcs" then return nil end
		if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return nil end
		if name:find("chest", 1, true) or name:find("กล่อง", 1, true) or name:find("หีบ", 1, true) then chest = true end
		if not position then
			if node:IsA("Attachment") then position = node.WorldPosition; container = node.Parent
			elseif node:IsA("BasePart") then position = node.Position; container = node
			elseif node:IsA("Model") then position = node:GetPivot().Position; container = node end
		end
		node = node.Parent
	end
	if open and not chest then return nil end
	if not position or (position - job.Origin).Magnitude > self.Radius then return nil end
	if prompt.MaxActivationDistance <= 0 or prompt.HoldDuration > 5 then return nil end
	return { Prompt = prompt, Position = position, Container = container, Kind = claim and "claim" or "open" }
end

function BossLoot:MoveNear(candidate, char, root, hum)
	local position = candidate.Position
	local direction = Vector3.new(root.Position.X - position.X, 0, root.Position.Z - position.Z)
	if direction.Magnitude < 0.1 then direction = Vector3.new(1, 0, 0) end
	local offset = math.min(2.5, candidate.Prompt.MaxActivationDistance * 0.35)
	local probe = position + direction.Unit * offset
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char, candidate.Container }
	params.RespectCanCollide = true
	local ground = workspace:Raycast(probe + Vector3.new(0, 8, 0), Vector3.new(0, -40, 0), params)
	if not ground or ground.Normal.Y < 0.65 then return false end
	local destination = Vector3.new(probe.X, ground.Position.Y + math.max(hum.HipHeight, 0) + root.Size.Y * 0.5 + 0.5, probe.Z)
	if destination.Y <= workspace.FallenPartsDestroyHeight + 12
		or (destination - position).Magnitude > candidate.Prompt.MaxActivationDistance then return false end
	root.CFrame = CFrame.lookAt(destination, Vector3.new(position.X, destination.Y, position.Z))
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	return true
end

function BossLoot:Step()
	local job = self.Job
	if not job then return false end
	local now = os.clock()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not Farm.Enabled or not Farm.BossEnabled or not Farm.AutoLoot or Farm.BossName ~= job.Name
		or char ~= job.Character or not hum or hum.Health <= 0 or not root
		or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent or now >= job.Deadline then
		self:Finish(); return false
	end
	Farm._attackTarget = nil
	if Farm.InputBlocked and Farm.InputBlocked() then self:Release(); return true end
	if Farm._questBusy then self:Release(); return true end
	if self.Held then
		local held = self.Held
		local candidate = self:Candidate(held.Prompt, job)
		if not candidate or candidate.Kind ~= held.Kind
			or (root.Position - candidate.Position).Magnitude > held.Prompt.MaxActivationDistance then
			self:Release()
		elseif held.Pending then
			if now < held.Until then return true end
			held.Pending, held.Begun = false, true
			held.Until = now + math.max(0, held.Prompt.HoldDuration) + 0.1
			local ok, err = pcall(function() held.Prompt:InputHoldBegin() end)
			if not ok then self:Release(); Farm._lastRuntimeError = tostring(err) end
			job.LastActivity = now
			return true
		elseif now >= held.Until then self:Release()
		else return true end
		job.LastActivity = now
	end
	if now < job.NextScanAt then return true end
	job.NextScanAt = now + 0.25
	if not job.Initialized then
		job.Initialized = true
		for _, instance in ipairs(workspace:GetDescendants()) do
			if instance:IsA("ProximityPrompt") then job.Prompts[instance] = true end
		end
	end
	local selected, selectedRecord, bestDistance, pending = nil, nil, math.huge, false
	for prompt in pairs(job.Prompts) do
		if not prompt.Parent then job.Prompts[prompt], job.Records[prompt] = nil, nil
		else
			local candidate = self:Candidate(prompt, job)
			if candidate then
				local record = job.Records[prompt]
				if not record or record.Kind ~= candidate.Kind then
					record = { Kind = candidate.Kind, Attempts = 0, NextAt = 0 }
					job.Records[prompt] = record
					job.LastActivity, job.SeenAny = now, true
				end
				if record.Attempts < 6 then
					pending = true
					local distance = (candidate.Position - root.Position).Magnitude
					local score = distance + (candidate.Kind == "claim" and self.Radius * 2 or 0)
					if now >= record.NextAt and score < bestDistance then
						selected, selectedRecord, bestDistance = candidate, record, score
					end
				end
			end
		end
	end
	if selected then
		local prompt, record = selected.Prompt, selectedRecord
		record.Attempts += 1
		record.NextAt = now + prompt.HoldDuration + 1.25
		job.LastActivity = now
		if self:MoveNear(selected, char, root, hum) then
			self.Held = { Prompt = prompt, Kind = selected.Kind, Until = now + 0.2, Pending = true }
		end
	elseif not pending and now - job.StartedAt >= 8 and (not job.SeenAny or now - job.LastActivity >= 3) then
		self:Finish(); return false
	end
	return true
end

local function farmRestorePlayerHitbox()
	for part, original in pairs(Farm._hitboxOriginals) do
		if part.Parent then
			pcall(function()
				part.Size = original.Size
				part.Transparency = original.Transparency
				part.CanCollide = original.CanCollide
				part.Massless = original.Massless
				part.CanTouch = original.CanTouch
				part.CanQuery = original.CanQuery
			end)
		end
	end
	Farm._hitboxOriginals = setmetatable({}, { __mode = "k" })
	Farm._hitboxTool = nil
	Farm._hitboxNextAt = 0
end

local function farmRestoreHitbox()
	farmRestorePlayerHitbox()

	for part, original in pairs(Farm._mobHitboxOriginals) do
		if part.Parent then
			pcall(function()
				part.Size = original.Size
				part.Transparency = original.Transparency
				part.CanCollide = original.CanCollide
				part.Massless = original.Massless
				part.CanTouch = original.CanTouch
				part.CanQuery = original.CanQuery
			end)
		end
	end
	Farm._mobHitboxOriginals = setmetatable({}, { __mode = "k" })
	Farm._mobHitboxTarget = nil
	Farm._mobHitboxNextAt = 0
end

local function farmExtendHitbox()
	local char = player.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if tool ~= Farm._hitboxTool then
		farmRestorePlayerHitbox()
		Farm._hitboxTool = tool
	end
	if not tool or os.clock() < (Farm._hitboxNextAt or 0) then return end
	Farm._hitboxNextAt = os.clock() + 0.15
	local size = math.clamp(tonumber(Farm.PlayerAttackHitbox) or 30, 5, 100)
	for _, d in ipairs(tool:GetDescendants()) do
		-- Some weapons do not expose a part literally named Hitbox; their
		-- touch/damage region can be Handle, Blade, MeshPart, etc. Expand every
		-- BasePart in the equipped Tool so the character's attack volume is larger.
		if d:IsA("BasePart") then
			if not Farm._hitboxOriginals[d] then
				Farm._hitboxOriginals[d] = {
					Size = d.Size,
					Transparency = d.Transparency,
					CanCollide = d.CanCollide,
					Massless = d.Massless,
					CanTouch = d.CanTouch,
					CanQuery = d.CanQuery,
				}
			end
			pcall(function()
				d.Size = Vector3.new(size, size, size)
				-- While manually testing from the Player page, keep the enlarged
				-- weapon volume slightly visible so its actual client-side size is clear.
				d.Transparency = Farm.PlayerHitboxTest and 0.65 or 1
				d.CanCollide = false
				d.Massless = true
				d.CanTouch = true
				d.CanQuery = true
			end)
		end
	end
end

Farm._playerHitboxTestConn = RunService.Heartbeat:Connect(function()
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	if Farm.PlayerHitboxTest then
		farmExtendHitbox()
	end
end)

local function farmExtendMobHitbox(mob)
	if mob ~= Farm._mobHitboxTarget then
		for part, original in pairs(Farm._mobHitboxOriginals) do
			if part.Parent then
				pcall(function()
					part.Size = original.Size
					part.Transparency = original.Transparency
					part.CanCollide = original.CanCollide
					part.Massless = original.Massless
					part.CanTouch = original.CanTouch
					part.CanQuery = original.CanQuery
				end)
			end
		end
		Farm._mobHitboxOriginals = setmetatable({}, { __mode = "k" })
		Farm._mobHitboxTarget = mob
		Farm._mobHitboxNextAt = 0
	end
	if not mob or not mob.Parent or os.clock() < (Farm._mobHitboxNextAt or 0) then return end
	Farm._mobHitboxNextAt = os.clock() + 0.15

	local size = math.clamp(tonumber(Farm.Hitbox) or 18, 5, 40)
	local root = mob:FindFirstChild("HumanoidRootPart", true)
		or mob:FindFirstChild("UpperTorso", true)
		or mob:FindFirstChild("Torso", true)
		or (mob:IsA("Model") and mob.PrimaryPart)

	if root and root:IsA("BasePart") then
		if not Farm._mobHitboxOriginals[root] then
			Farm._mobHitboxOriginals[root] = {
				Size = root.Size,
				Transparency = root.Transparency,
				CanCollide = root.CanCollide,
				Massless = root.Massless,
				CanTouch = root.CanTouch,
				CanQuery = root.CanQuery,
			}
		end
		pcall(function()
			root.Size = Vector3.new(size, size, size)
			root.Transparency = 1
			root.CanCollide = false
			root.Massless = true
			root.CanTouch = true
			root.CanQuery = true
		end)
	end
end

local FarmCharacterState = {
	Player = nil, Character = nil, NextScanAt = 0,
	Humanoids = setmetatable({}, { __mode = "k" }),
	Parts = setmetatable({}, { __mode = "k" }),
	Cameras = setmetatable({}, { __mode = "k" }),
	SmoothHoverPosition = nil,
	LastHoverUpdate = 0,
}

function FarmCharacterState:ReleaseHover()
	if self.HoverOrientation then self.HoverOrientation:Destroy() end
	self.HoverOrientation = nil
	if self.HoverAlign then self.HoverAlign:Destroy() end
	if self.HoverAttachment then self.HoverAttachment:Destroy() end
	self.HoverAlign, self.HoverAttachment, self.HoverRoot = nil, nil, nil
	self.HoverTarget, self.HoverFacing, self.HoverHeadOffset = nil, nil, nil
	self.SmoothHoverPosition = nil
	self.LastHoverUpdate = 0
end

function FarmCharacterState:HoldPosition(root, position, rotation)
	if self.HoverRoot ~= root or not self.HoverAlign or not self.HoverAlign.Parent
		or not self.HoverOrientation or not self.HoverOrientation.Parent then
		self:ReleaseHover()
		self.HoverRoot = root
		local attachment = Instance.new("Attachment")
		attachment.Name = "LuminFarmHoverAttachment"
		attachment.Parent = root
		self.HoverAttachment = attachment
		local align = Instance.new("AlignPosition")
		align.Name = "LuminFarmHover"
		align.Mode = Enum.PositionAlignmentMode.OneAttachment
		align.Attachment0 = attachment
		align.ApplyAtCenterOfMass = true
		align.MaxForce = math.max(50000, root.AssemblyMass * workspace.Gravity * 6)
		align.MaxVelocity = 55
		align.Responsiveness = 18
		align.Position = position
		align.Parent = root
		self.HoverAlign = align
		local orientation = Instance.new("AlignOrientation")
		orientation.Name = "LuminFarmProne"
		orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		orientation.Attachment0 = attachment
		orientation.MaxTorque = 1000000
		orientation.MaxAngularVelocity = 12
		orientation.Responsiveness = 18
		orientation.CFrame = rotation
		orientation.Parent = root
		self.HoverOrientation = orientation
	end
	self.HoverAlign.Position = position
	self.HoverOrientation.CFrame = rotation
end

function FarmCharacterState:RememberHumanoid(hum)
	if self.Humanoids[hum] == nil then self.Humanoids[hum] = hum.AutoRotate end
end

local function dungeonReleasePreAttack()
	local dungeon = Farm.Dungeon
	local held = dungeon and dungeon.PreAttackHeld
	if not held then return end
	dungeon.PreAttackHeld = nil
	pcall(function()
		held.Input:SendMouseButtonEvent(held.X, held.Y, 0, false, game, 0)
	end)
end

local function dungeonHoldPreAttack(mob)
	local dungeon = Farm.Dungeon
	if not dungeon or not dungeon.Enabled then return false end
	if dungeon.PreAttackHeld and dungeon.PreAttackHeld.Target == mob then return true end
	dungeonReleasePreAttack()
	local camera = workspace.CurrentCamera
	if not camera then return false end
	local held
	local ok = pcall(function()
		local vim = game:GetService("VirtualInputManager")
		held = {
			Input = vim,
			X = camera.ViewportSize.X * 0.5,
			Y = camera.ViewportSize.Y * 0.5,
			Target = mob,
		}
		vim:SendMouseButtonEvent(held.X, held.Y, 0, true, game, 0)
	end)
	if not ok or not held then return false end
	dungeon.PreAttackHeld = held
	return true
end

function Farm:AttackPoint(mob)
	if not mob or not mob.Parent then return nil end
	local head = mob:FindFirstChild("Head", true)
	if head and head:IsA("BasePart") then return head.Position end
	local root = mob:FindFirstChild("HumanoidRootPart", true)
	if root and root:IsA("BasePart") then return root.Position end
	return nil
end

-- Name retained for existing farm callers; positioning now follows the head.
local function farmMoveUnder(mob)
	if not mob or not mob.Parent then return false end
	local targetRoot = mob:FindFirstChild("HumanoidRootPart", true)
	local targetPosition = Farm:AttackPoint(mob)
	if not targetRoot or not targetPosition then return false end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return false end

	local changedTarget = FarmCharacterState.HoverTarget ~= mob or FarmCharacterState.HoverRoot ~= hrp
	local facing = FarmCharacterState.HoverFacing
	local headOffset = FarmCharacterState.HoverHeadOffset
	if changedTarget or not facing then
		local look = hrp.CFrame.LookVector
		facing = Vector3.new(look.X, 0, look.Z)
		facing = facing.Magnitude > 0.01 and facing.Unit or Vector3.new(0, 0, -1)
		headOffset = math.clamp(targetPosition.Y - targetRoot.Position.Y, 0, 5)
	end
	local range = math.max(1.5, tonumber(Farm.AttackRange) or 12)
	local height = math.clamp(tonumber(Farm.HeadHeight) or 3, 1, range - 0.5)
	-- Lie face-down above the target with a stable horizontal up axis.
	local rawDesiredPosition = targetRoot.Position + Vector3.new(0, headOffset + height, 0)
	local now = os.clock()
	local dt = math.clamp(now - (FarmCharacterState.LastHoverUpdate or now), 0, 0.05)
	FarmCharacterState.LastHoverUpdate = now
	local smooth = FarmCharacterState.SmoothHoverPosition
	if changedTarget or not smooth or (smooth - rawDesiredPosition).Magnitude > 25 then
		smooth = rawDesiredPosition
	else
		local alpha = 1 - math.exp(-12 * math.max(dt, 1 / 240))
		smooth = smooth:Lerp(rawDesiredPosition, alpha)
	end
	FarmCharacterState.SmoothHoverPosition = smooth
	local desiredPosition = smooth
	local desired = CFrame.lookAt(desiredPosition, desiredPosition - Vector3.yAxis, facing)
	FarmCharacterState:RememberHumanoid(hum)
	if hum.AutoRotate then hum.AutoRotate = false end
	if changedTarget or (hrp.Position - desiredPosition).Magnitude > 10 then
		hrp.CFrame = desired
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	-- Hold both position and prone rotation without rewriting CFrame every frame.
	FarmCharacterState:HoldPosition(hrp, desiredPosition, desired.Rotation)
	FarmCharacterState.HoverTarget = mob
	FarmCharacterState.HoverFacing = facing
	FarmCharacterState.HoverHeadOffset = headOffset
	if Farm.Dungeon and Farm.Dungeon.Enabled then dungeonReleasePreAttack() end
	return true
end

local function farmKeepCharacterVisible()
	if Farm._cameraConn then Farm._cameraConn:Disconnect() end

	if not FarmCharacterState.Player then
		FarmCharacterState.Player = { Mode = player.CameraMode, Min = player.CameraMinZoomDistance, Max = player.CameraMaxZoomDistance }
	end
	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMaxZoomDistance = 24
	player.CameraMinZoomDistance = 7

	Farm._cameraConn = RunService.RenderStepped:Connect(function(dt)
		if not Farm.Enabled then return end
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local camera = workspace.CurrentCamera
		if camera and hum then
			if not FarmCharacterState.Cameras[camera] then
				FarmCharacterState.Cameras[camera] = { Subject = camera.CameraSubject }
			end
			-- Use Roblox's normal Humanoid camera. The old moving anchor amplified
			-- tiny hover corrections into visible screen shake.
			if camera.CameraSubject ~= hum then camera.CameraSubject = hum end
		end
		if char and (FarmCharacterState.Character ~= char or os.clock() >= FarmCharacterState.NextScanAt) then
			FarmCharacterState.Character = char
			FarmCharacterState.NextScanAt = os.clock() + 0.25
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and FarmCharacterState.Parts[part] == nil then
					FarmCharacterState.Parts[part] = part.LocalTransparencyModifier
				end
			end
		end
		for part in pairs(FarmCharacterState.Parts) do
			if part.Parent and char and part:IsDescendantOf(char) then part.LocalTransparencyModifier = 0 end
		end
	end)
end

local function farmRestoreCharacter()
	FarmCharacterState:ReleaseHover()
	if Farm._cameraConn then
		Farm._cameraConn:Disconnect()
		Farm._cameraConn = nil
	end
	for hum, autoRotate in pairs(FarmCharacterState.Humanoids) do
		if hum.Parent then pcall(function() hum.AutoRotate = autoRotate end) end
	end
	for part, transparency in pairs(FarmCharacterState.Parts) do
		if part.Parent then pcall(function() part.LocalTransparencyModifier = transparency end) end
	end
	for camera, saved in pairs(FarmCharacterState.Cameras) do
		if camera.Parent and (saved.Subject == nil or saved.Subject.Parent) then
			pcall(function() camera.CameraSubject = saved.Subject end)
		end
	end
	if FarmCharacterState.CameraAnchor then
		FarmCharacterState.CameraAnchor:Destroy()
		FarmCharacterState.CameraAnchor = nil
	end
	local saved = FarmCharacterState.Player
	if saved then
		player.CameraMode = saved.Mode
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = saved.Max
		player.CameraMinZoomDistance = saved.Min
	end
	FarmCharacterState.Player, FarmCharacterState.Character = nil, nil
	FarmCharacterState.NextScanAt = 0
	FarmCharacterState.Humanoids = setmetatable({}, { __mode = "k" })
	FarmCharacterState.Parts = setmetatable({}, { __mode = "k" })
	FarmCharacterState.Cameras = setmetatable({}, { __mode = "k" })
end

local AUTO_WEAPON_OPTION = "อัตโนมัติ"
local CURRENT_WEAPON_OPTION = "อาวุธที่ถืออยู่"
local FIST_WEAPON_OPTION = "หมัด / Fist"
local HOTBAR_SLOT_PREFIX = "ช่อง "
local HOTBAR_KEYS = {
	[1] = Enum.KeyCode.One,
	[2] = Enum.KeyCode.Two,
	[3] = Enum.KeyCode.Three,
	[4] = Enum.KeyCode.Four,
	[5] = Enum.KeyCode.Five,
}

local function farmWeaponContainers()
	return player.Character, player:FindFirstChildOfClass("Backpack")
end

local HotbarScan = { Found = false, Count = 0 }

function HotbarScan:Visible(node)
	while node and node ~= playerGui do
		if node:IsA("GuiObject") and not node.Visible then return false end
		if node:IsA("ScreenGui") and not node.Enabled then return false end
		node = node.Parent
	end
	return node == playerGui
end

function HotbarScan:Slot(node)
	local value
	if node:IsA("TextLabel") or node:IsA("TextButton") then
		value = tonumber(node.Text:match("^%s*([1-5])%s*$"))
	end
	return value or tonumber(node.Name:lower():match("^slot[_ ]?([1-5])$"))
end

function HotbarScan:Read(container, textures)
	local nodes = { container }
	for _, node in ipairs(container:GetDescendants()) do table.insert(nodes, node) end
	local itemName, hasIcon
	for _, node in ipairs(nodes) do
		for _, attribute in ipairs({ "ItemName", "WeaponName", "ToolName" }) do
			local value = node:GetAttribute(attribute)
			if type(value) == "string" and value ~= "" and value:lower() ~= "empty" then itemName = value end
		end
		local key = node.Name:lower()
		if node:IsA("ObjectValue") and node.Value and node.Value:IsA("Tool") then itemName = node.Value.Name end
		if key == "itemname" or key == "weaponname" or key == "toolname" then
			local value = node:IsA("StringValue") and node.Value
				or ((node:IsA("TextLabel") or node:IsA("TextButton")) and node.Text)
			if type(value) == "string" and value ~= "" and value:lower() ~= "empty" then itemName = value end
		end
		if node:IsA("ViewportFrame") and self:Visible(node) then
			local model = node:FindFirstChildWhichIsA("Model", true)
			if model then
				hasIcon = true
				if model.Name ~= "Model" then itemName = itemName or model.Name end
			end
		end
		if (node:IsA("ImageLabel") or node:IsA("ImageButton")) and self:Visible(node)
		and node.Image ~= "" and node.Image ~= "rbxassetid://0" and node.ImageTransparency < 0.95 then
			local decorative = key:find("background", 1, true) or key:find("border", 1, true)
				or key:find("circle", 1, true) or key:find("selection", 1, true)
				or key:find("cooldown", 1, true) or key:find("lock", 1, true)
			local namedIcon = key:find("icon", 1, true) or key:find("weapon", 1, true) or key:find("item", 1, true)
			if not decorative and (node ~= container or namedIcon) then
				hasIcon = true
				local textureId = node.Image:match("%d+")
				if textureId and textures[textureId] then itemName = itemName or textures[textureId] end
			end
		end
	end
	return itemName, hasIcon or itemName ~= nil
end

function HotbarScan:Scan(char, backpack)
	local slots, textures = {}, {}
	self.Found, self.Count = false, 0
	for _, container in pairs({ char, backpack }) do
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") then
				local id = tool.TextureId:match("%d+")
				if id then textures[id] = tool.Name end
			end
		end
	end
	local camera = workspace.CurrentCamera
	if not camera then return slots end
	local height = camera.ViewportSize.Y
	for _, marker in ipairs(playerGui:GetDescendants()) do
		if marker:IsA("GuiObject") and not marker:IsDescendantOf(gui) and self:Visible(marker)
		and marker.AbsolutePosition.Y >= height * 0.65 then
			local slot = self:Slot(marker)
			if slot then
				self.Found = true
				local container = marker
				for _ = 1, 4 do
					if not container or not container:IsA("GuiObject") then break end
					local size = container.AbsoluteSize
					if size.X > 180 or size.Y > 180 then break end
					local mixed = false
					for _, child in ipairs(container:GetDescendants()) do
						local other = self:Slot(child)
						if other and other ~= slot then mixed = true; break end
					end
					if mixed then break end
					local name, occupied = self:Read(container, textures)
					if occupied then
						local prior = slots[slot]
						if not prior or (name and not prior.Name) then slots[slot] = { Name = name } end
					end
					container = container.Parent
				end
			end
		end
	end
	for slot, entry in pairs(slots) do
		entry.Option = HOTBAR_SLOT_PREFIX .. slot .. " — " .. (entry.Name or "ไอเทมไม่ทราบชื่อ")
		self.Count += 1
	end
	return slots
end

local function farmScanWeaponOptions()
	return {
		HOTBAR_SLOT_PREFIX .. "1",
		HOTBAR_SLOT_PREFIX .. "2",
		HOTBAR_SLOT_PREFIX .. "3",
		HOTBAR_SLOT_PREFIX .. "4",
		HOTBAR_SLOT_PREFIX .. "5",
	}
end

local function farmFindTool(name)
	local char, backpack = farmWeaponContainers()
	for _, container in pairs({ char, backpack }) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") and (not name or item.Name == name) then return item end
			end
		end
	end
	return nil
end

local function farmFindAutomaticWeapon()
	local keywords = { "cutlass", "katana", "sword", "blade", "dagger", "axe", "spear" }
	local char, backpack = farmWeaponContainers()
	for _, keyword in ipairs(keywords) do
		for _, container in pairs({ char, backpack }) do
			if container then
				for _, item in ipairs(container:GetChildren()) do
					if item:IsA("Tool") and item.Name:lower():find(keyword, 1, true) then
						return item
					end
				end
			end
		end
	end
	return farmFindTool(nil)
end

local CombatRuntime = {
	Focused = true, Held = nil, EquipHeld = nil, EquipReadyAt = 0,
	EquipRetryAt = 0, NextAttackAt = 0, NextScanAt = 0, NextRecoveryAt = 0,
	Character = nil, Humanoid = nil, Selection = nil, TargetKey = nil,
	Driver = 1, DriverAttempts = 0, LastProgressAt = 0, LastSwingAt = 0,
	LastHealth = nil, State = "idle", Connections = {},
	AdaptiveInterval = 0.05, NoDamageAttempts = 0,
	HiddenTracks = setmetatable({}, { __mode = "k" }),
}

local CombatTrace = {
	Enabled = false,
	ManualClicks = 0,
	Lines = {},
}

function CombatTrace:Push(message)
	local line = string.format("[CombatTrace %.3f] %s", os.clock(), tostring(message))
	table.insert(self.Lines, line)
	if #self.Lines > 160 then table.remove(self.Lines, 1) end
	_G.__MAZX_COMBAT_TRACE = table.concat(self.Lines, "\n")
	warn(line)
end

function CombatTrace:Snapshot(tag)
	if not self.Enabled then return end
	local char = player.Character
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	local hum = char:FindFirstChildOfClass("Humanoid")
	local keywords = { "combo", "attack", "cooldown", "recover", "stun", "debounce", "swing", "m1", "hit" }
	local function wanted(name)
		name = tostring(name):lower()
		for _, key in ipairs(keywords) do if name:find(key, 1, true) then return true end end
		return false
	end
	self:Push("SNAP " .. tostring(tag))
	for _, root in ipairs({ player, char, hum, tool }) do
		if root then
			for key, value in pairs(root:GetAttributes()) do
				if wanted(key) then self:Push(root.Name .. ".@" .. key .. "=" .. tostring(value)) end
			end
			for _, obj in ipairs(root:GetDescendants()) do
				if wanted(obj.Name) and (obj:IsA("BoolValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then
					self:Push(root.Name .. "." .. obj:GetFullName() .. "=" .. tostring(obj.Value))
				end
			end
		end
	end
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local anim = track.Animation
			self:Push(string.format("ANIM name=%s id=%s pos=%.3f len=%.3f speed=%.2f",
				tostring(track.Name), tostring(anim and anim.AnimationId or ""), track.TimePosition or 0, track.Length or 0, track.Speed or 0))
		end
	end
end

table.insert(CombatRuntime.Connections, UserInputService.InputBegan:Connect(function(input, processed)
	if not CombatTrace.Enabled or processed or Farm._sendingClick then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	CombatTrace.ManualClicks += 1
	local n = CombatTrace.ManualClicks
	CombatTrace:Push("MANUAL M1 #" .. n)
	if n % 5 == 0 then
		CombatTrace:Snapshot("hit5 +0.00")
		for _, delayTime in ipairs({ 0.10, 0.30, 0.70, 1.20 }) do
			task.delay(delayTime, function()
				if CombatTrace.Enabled then CombatTrace:Snapshot(string.format("hit5 +%.2f", delayTime)) end
			end)
		end
	end
end))

function CombatRuntime:RecordFrame(dt)
	self.PerfFrames = (self.PerfFrames or 0) + 1
	self.PerfSeconds = (self.PerfSeconds or 0) + dt
	if self.PerfSeconds < 1 then return end
	local elapsed = self.PerfSeconds
	if self.PerfLabel and self.PerfLabel.Parent then
		local method = self.Driver == 3 and "Signal" or (self.Driver == 2 and "Tool" or "Mouse")
		self.PerfLabel.Text = string.format("FPS ~%.0f | ส่ง %.1f/s | HP ลด %.1f ครั้ง/s\n%s | %s",
			self.PerfFrames / elapsed, (self.SentAttacks or 0) / elapsed,
			(self.HealthDrops or 0) / elapsed, method, self.State)
	end
	self.PerfFrames, self.PerfSeconds, self.SentAttacks, self.HealthDrops = 0, 0, 0, 0
end

function CombatRuntime:RestoreSwingAnimations()
	for track, weight in pairs(self.HiddenTracks) do
		pcall(function() if track.IsPlaying then track:AdjustWeight(weight, 0.08) end end)
		self.HiddenTracks[track] = nil
	end
end

function CombatRuntime:HideSwingAnimation(track)
	if not Farm.NoSwingAnimation or not self:CombatReady() or Farm._skillHeld
		or os.clock() < (Farm._skillReadyAt or 0) then return end
	pcall(function()
		if self.HiddenTracks[track] == nil then self.HiddenTracks[track] = track.WeightTarget end
		-- Keep the track running: Stop/AdjustSpeed can break weapon hit markers.
		track:AdjustWeight(0, 0)
	end)
end

function CombatRuntime:ReleaseAttack()
	local held = self.Held
	if not held then return end
	self.Held = nil
	Farm._sendingClick = false
	pcall(function()
		if held.Tool then held.Tool:Deactivate()
		else held.Input:SendMouseButtonEvent(held.X, held.Y, 0, false, game, 0) end
	end)
end

function CombatRuntime:ReleaseEquip()
	local held = self.EquipHeld
	if not held then return end
	self.EquipHeld = nil
	pcall(function() held.Input:SendKeyEvent(false, held.Key, false, game) end)
end

function CombatRuntime:Release(preserveHover)
	if not preserveHover then FarmCharacterState:ReleaseHover() end
	self:ReleaseAttack()
	self:RestoreSwingAnimations()
	self:ReleaseEquip()
	if Farm.ReleaseSkills then Farm.ReleaseSkills() end
	if Farm.ResetCombo then Farm.ResetCombo() end
end
Farm.ReleaseInputs = function() CombatRuntime:Release() end

function CombatRuntime:ResetEquipment()
	self:Release()
	Farm._lastHotbarSelection, Farm._lastHotbarCharacter = nil, nil
	self.EquipReadyAt, self.EquipRetryAt = 0, 0
	self.Selection = Farm.SelectedWeapon
end

function CombatRuntime:ResetProgress()
	if Farm.ResetCombo then Farm.ResetCombo() end
	self.Driver = Farm.FastAttack and 1 or (self.PreferredDriver or (UserInputService.TouchEnabled and 2 or 1))
	self.DriverAttempts = 0
	self.DriverHasDamage = false
	self.LastHealth, self.LastSwingAt = nil, 0
	self.AdaptiveInterval = math.clamp(tonumber(Farm.AttackInterval) or 0.008, 0.005, 0.08)
	self.NoDamageAttempts = 0
	self.LastProgressAt = os.clock()
end

function CombatRuntime:NextDriver()
	self.DriverHasDamage = false
	-- Hiding an animation must not lock combat to a signal that causes no damage.
	if Farm.FastAttack then
		self.Driver = 1
		return
	end
	self.Driver = UserInputService.TouchEnabled and (self.Driver == 2 and 3 or 2) or (self.Driver % 3 + 1)
end

function CombatRuntime:TargetAlive(target)
	if Farm.Dungeon and Farm.Dungeon.Enabled then return Farm.Dungeon:ValidTarget(target) end
	if not target or not target.Parent then return false end
	local folder = Farm.BossEnabled and farmBossFolder(Farm.BossName) or farmActiveFolderForName(Farm.MobName)
	if not folder or not target:IsDescendantOf(folder) then return false end
	local hum = target:FindFirstChildWhichIsA("Humanoid", true)
	local root = target:FindFirstChild("HumanoidRootPart", true)
	return hum ~= nil and hum.Health > 0 and root ~= nil and root:IsA("BasePart")
end

local function attackInputBlocked()
	-- Keep farm/combat running even when the hub is hidden or Roblox loses focus.
	-- Only pause for a short explicit input cooldown, Roblox system menu, or chat/text input.
	if os.clock() < Farm._inputPauseUntil then return true end
	if Farm._systemMenuOpen or UserInputService:GetFocusedTextBox() then return true end
	local ok, menuOpen = pcall(function() return GuiService.MenuIsOpen end)
	return ok and menuOpen == true
end
Farm.InputBlocked = attackInputBlocked

local function farmSelectHotbarSlot(slot, char)
	slot = math.floor(tonumber(slot) or 0)
	local now = os.clock()
	if slot < 1 or slot > 5 then return false end
	if Farm._lastHotbarSelection == slot and Farm._lastHotbarCharacter == char then
		return now >= CombatRuntime.EquipReadyAt
	end
	if now < CombatRuntime.EquipRetryAt or Farm._skillHeld then return false end

	CombatRuntime:ReleaseAttack()
	local ev = farmGetSignal()
	if not ev then
		CombatRuntime.EquipRetryAt = now + 1
		return false
	end

	local ok = pcall(function()
		ev:FireServer("Item_Equip", slot)
	end)
	if not ok then
		CombatRuntime.EquipRetryAt = now + 1
		return false
	end

	Farm._lastHotbarSelection = slot
	Farm._lastHotbarCharacter = char
	Farm._lastItemEquipAt = now
	CombatRuntime.EquipReadyAt = now + 0.2
	return false
end

local function farmEquipSelectedWeapon(char, hum)
	if CombatRuntime.Selection ~= Farm.SelectedWeapon then CombatRuntime:ResetEquipment() end
	if Farm.SelectedWeapon == CURRENT_WEAPON_OPTION then return char:FindFirstChildOfClass("Tool"), true end
	local selectedSlot = Farm.SelectedWeapon
		and tonumber(Farm.SelectedWeapon:match("^" .. HOTBAR_SLOT_PREFIX .. "(%d+)"))
	local tool
	if selectedSlot then
		local ready = farmSelectHotbarSlot(selectedSlot, char)
		tool = char:FindFirstChildOfClass("Tool")
		return tool, ready
	elseif Farm.SelectedWeapon and Farm.SelectedWeapon ~= AUTO_WEAPON_OPTION then
		tool = farmFindTool(Farm.SelectedWeapon)
		if not tool then return nil, false end
	else
		tool = farmFindAutomaticWeapon()
		if not tool then
			for slot = 1, 5 do
				if Farm._detectedHotbarSlots[slot] then
					local ready = farmSelectHotbarSlot(slot, char)
					return char:FindFirstChildOfClass("Tool"), ready
				end
			end
			return nil, true
		end
	end
	local now = os.clock()
	if tool.Parent ~= char then
		if now < CombatRuntime.EquipRetryAt or Farm._skillHeld then return nil, false end
		CombatRuntime:ReleaseAttack()
		CombatRuntime.EquipRetryAt = now + 0.5
		local ok = pcall(function() hum:EquipTool(tool) end)
		CombatRuntime.EquipReadyAt = now + (ok and 0.2 or 1)
		return tool, false
	end
	return tool, not CombatRuntime.EquipHeld and now >= CombatRuntime.EquipReadyAt
end

function CombatRuntime:CombatReady()
	if not Farm.Enabled or not Farm.AutoAttack
		or not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return false, "ฟาร์มยังไม่เปิด" end
	if Farm._questBusy or Farm._lootBusy or Farm._bettyBusy or Farm._storyBusy
		or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then return false, "รอเควส / เก็บของ" end
	if not Farm.FastAttack and FarmRetreat.Until > os.clock() then return false, "รอถอยหลังคอมโบ" end
	if attackInputBlocked() then return false, "รอปิดแชต / เมนูเกม" end
	local quest = Farm.AutoQuest and farmCurrentQuestSpec() or nil
	if quest and (Farm._questNeeded or Farm._acceptedQuestText ~= quest.Text) then return false, "รอรับเควส" end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local target = Farm._attackTarget
	if char ~= self.Character or not hum or hum.Health <= 0 or not root then return false, "รอตัวละครพร้อม" end
	if not self:TargetAlive(target) then return false, "รอเป้าหมาย" end
	local aim = Farm:AttackPoint(target)
	if not aim then return false, "ไม่พบจุดโจมตี" end
	local range = tonumber(Farm.AttackRange) or 12
	if Farm.Dungeon and Farm.Dungeon.Enabled then range = math.max(range, 5) end
	local distance = (aim - root.Position).Magnitude
	if distance > range then return false, string.format("นอกระยะ %.1f / %.1f", distance, range) end
	return true
end

function CombatRuntime:UnbindGameComboGate()
	if self.ComboGateConnection then
		self.ComboGateConnection:Disconnect()
		self.ComboGateConnection = nil
	end
	self.ComboGateValue = nil
	self.PendingComboReset = false
	self.PendingComboAt = nil
	self.PendingComboTarget = nil
end

function CombatRuntime:BindGameComboGate()
	self:UnbindGameComboGate()
	if not Farm.FastAttack or not Farm.BypassComboGate then return end

	local scripts = player:FindFirstChild("PlayerScripts")
	local cu = scripts and scripts:FindFirstChild("CU")
	local combat = cu and cu:FindFirstChild("Combat")
	local combo = combat and combat:FindFirstChild("ComboValue")
	if not combo or not (combo:IsA("IntValue") or combo:IsA("NumberValue")) then return end

	self.ComboGateValue = combo
	self.ComboGateConnection = combo:GetPropertyChangedSignal("Value"):Connect(function()
		if not Farm.FastAttack or not Farm.BypassComboGate then return end
		if combo.Parent and combo.Value >= 5 then
			-- Do NOT reset immediately. Resetting before the fifth hit is
			-- server-confirmed can cancel its damage packet.
			self.PendingComboReset = true
			self.PendingComboAt = os.clock()
			self.PendingComboTarget = Farm._attackTarget
		end
	end)
end

function CombatRuntime:ConfirmComboDamage(target)
	if not Farm.FastAttack or not Farm.BypassComboGate then return end
	if not self.PendingComboReset then return end
	if self.PendingComboTarget and target ~= self.PendingComboTarget then return end

	local combo = self.ComboGateValue
	if combo and combo.Parent and (combo:IsA("IntValue") or combo:IsA("NumberValue")) then
		pcall(function()
			if combo.Value >= 5 then combo.Value = 1 end
		end)
	end

	self.PendingComboReset = false
	self.PendingComboAt = nil
	self.PendingComboTarget = nil
	self.NextAttackAt = 0
end

function CombatRuntime:Dispatch(tool)
	if self.Driver == 1 and main.Visible and not Farm.FastAttack then
		if tool and tool.Parent == player.Character then
			self.Driver = 2
			self.DriverHasDamage = false
		else
			return nil
		end
	end
	if self.Driver == 1 then
		local camera = workspace.CurrentCamera
		if not camera then return false end
		local held
		local ok = pcall(function()
			local vim = game:GetService("VirtualInputManager")
			held = { Input = vim, X = camera.ViewportSize.X * 0.5, Y = camera.ViewportSize.Y * 0.5 }
			self.Held = held
			Farm._sendingClick = true
			vim:SendMouseButtonEvent(held.X, held.Y, 0, true, game, 0)
		end)
		if not ok then self:ReleaseAttack(); return false end
		task.delay(Farm.FastAttack and 0.004 or 0.015, function()
			if self.Held == held then self:ReleaseAttack() end
		end)
		return true
	elseif self.Driver == 2 then
		if not tool or tool.Parent ~= player.Character then return false end
		local held = { Tool = tool }
		self.Held = held
		local ok = pcall(function() tool:Activate() end)
		if not ok then self:ReleaseAttack(); return false end
		task.delay(0.015, function()
			if self.Held == held then self:ReleaseAttack() end
		end)
		return true
	else
		local ev = farmGetSignal()
		if not ev then return false end
		-- Fast burst: keep one Heartbeat driver, but send several combat requests
		-- inside the scheduled attack window so the client does not wait on swing recovery.
		local burst = Farm.FastAttack and math.clamp(math.floor(tonumber(Farm.BurstHits) or 5), 1, 10) or 1
		return pcall(function()
			for _ = 1, burst do
				ev:FireServer("Combat_Service", "Combat", 1, false, 0.13, false, nil)
			end
		end)
	end
end

local ComboRuntime = {
	Required = Farm.ComboHits or 5, Count = 0, Generation = 0, Connections = {}, Source = nil,
	LastDispatchAt = -math.huge, LastEvidenceAt = -math.huge,
	PendingAt = nil, RetryAt = 0, InFlight = false, Buffered = {},
}

function ComboRuntime:ClearCount()
	self.Count, self.Source = 0, nil
	self.PendingAt, self.RetryAt = nil, 0
	self.PendingExpiresAt = nil
	self.LastEvidenceAt = -math.huge
	Farm._comboPending = false
	Farm._comboCount = 0
end

function ComboRuntime:Reset()
	CombatRuntime:RestoreSwingAnimations()
	self.Generation += 1
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	self.Connections = {}
	self.Target, self.Character, self.Weapon, self.Humanoid, self.Animator = nil, nil, nil, nil, nil
	self.LastDispatchAt = -math.huge
	self.InFlight, self.Buffered = false, {}
	self:ClearCount()
end
Farm.ResetCombo = function() ComboRuntime:Reset() end

function ComboRuntime:IsBasicTrack(track)
	if track.Looped then return false end
	local animation = track.Animation
	local combined = (tostring(track.Name or "") .. " " .. tostring(animation and animation.Name or "")):lower()
	for _, excluded in ipairs({ "skill", "dash", "jump", "fall", "idle", "walk", "run", "equip", "block", "hurt", "stun" }) do
		if combined:find(excluded, 1, true) then return false end
	end
	for _, raw in ipairs({ track.Name or "", animation and animation.Name or "" }) do
		local name = raw:lower():gsub("[%s_%-]", "")
		if name:match("^[1-5]$") then return true end
		for _, stem in ipairs({ "m1", "attack", "basicattack", "lightattack", "slash", "swing", "punch", "melee" }) do
			if name:find(stem, 1, true) then return true end
		end
	end
	-- Some weapons use generic track names. Only classify an Action-priority
	-- track during our direct basic-attack window, never during a skill window.
	return Farm.FastAttack and Farm.NoSwingAnimation and CombatRuntime.Driver == 3
		and not Farm._skillHeld and os.clock() >= (Farm._skillReadyAt or 0)
		and (self.InFlight or os.clock() - self.LastDispatchAt <= 0.2)
		and track.Priority ~= nil and track.Priority.Value >= Enum.AnimationPriority.Action.Value
end

function ComboRuntime:RefreshHiddenTracks()
	if not Farm.NoSwingAnimation then return end
	local now = os.clock()
	if now < (self.NextWeightRefresh or 0) then return end
	self.NextWeightRefresh = now + 0.1
	-- Reapply only to the small set of known attack tracks if the game fades
	-- them back in. Do not scan all animations or stop their hit markers.
	for track in pairs(CombatRuntime.HiddenTracks) do
		pcall(function()
			if not track.IsPlaying then CombatRuntime.HiddenTracks[track] = nil
			elseif track.WeightTarget > 0 then track:AdjustWeight(0, 0) end
		end)
	end
end

function ComboRuntime:OnBasicTrack(track)
	if not self:IsBasicTrack(track) then return end
	self:Evidence("animation", track)
	CombatRuntime:HideSwingAnimation(track)
end

function ComboRuntime:Evidence(source, track)
	-- No block, animation recovery wait, or retreat after five hits in this mode.
	if not Farm.RetreatEnabled or (Farm.Dungeon and Farm.Dungeon.Enabled) then return end
	if self.InFlight then
		table.insert(self.Buffered, { Source = source, Track = track })
		return
	end
	local now = os.clock()
	if not CombatRuntime:CombatReady() or Farm._skillHeld or now < (Farm._skillReadyAt or 0)
		or self.Target ~= Farm._attackTarget or now - self.LastDispatchAt > 0.7 then return end
	if self.PendingAt then
		if source == "health" then self.PendingAt = math.min(self.PendingAt, now) end
		return
	end
	if now - self.LastEvidenceAt > 2 then self:ClearCount() end
	if self.Source and self.Source ~= source then return end
	if now - self.LastEvidenceAt < 0.12 then return end
	self.Source = source
	self.LastEvidenceAt = now
	self.Required = math.clamp(math.floor(tonumber(Farm.ComboHits) or 5), 1, 20)
	self.Count += 1
	Farm._comboCount = self.Count
	if self.Count < self.Required then return end

	-- Combo reached the selected hit count: block with F for 3 seconds too.
	DamageBlock:Hold(3)

	Farm._comboPending = true
	self.PendingExpiresAt = now + 3
	if source == "animation" and track then
		local remaining = math.max(0, (track.Length or 0) - (track.TimePosition or 0))
			/ math.max(math.abs(track.Speed or 1), 0.1)
		self.PendingAt = now + math.clamp(remaining, 0.08, 1.2)
		local generation = self.Generation
		table.insert(self.Connections, track.Stopped:Connect(function()
			if self.Generation == generation and self.PendingAt then self.PendingAt = os.clock() end
		end))
	else
		self.PendingAt = now
	end
end

function ComboRuntime:Prepare(target, char, hum, tool)
	if self.Target ~= target or self.Character ~= char or self.Humanoid ~= hum or self.Weapon ~= tool then
		self:Reset()
		self.Target, self.Character, self.Humanoid, self.Weapon = target, char, hum, tool
		local targetHum = target:FindFirstChildWhichIsA("Humanoid", true)
		local generation = self.Generation
		local previousHealth = targetHum.Health
		if targetHum.HealthChanged then
			table.insert(self.Connections, targetHum.HealthChanged:Connect(function(health)
				local damage = health < previousHealth
				previousHealth = health
				if generation ~= self.Generation then return end
				if health <= 0 then self:Reset(); return end
				if damage then self:Evidence("health") end
			end))
		end
	end
	if not self.Animator then
		local ok, animator = pcall(function() return hum:FindFirstChildOfClass("Animator") end)
		if ok and animator then
			self.Animator = animator
			local generation = self.Generation
			table.insert(self.Connections, animator.AnimationPlayed:Connect(function(track)
				if generation == self.Generation then self:OnBasicTrack(track) end
			end))
			-- Hide a basic swing already playing when the target is acquired.
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				if self:IsBasicTrack(track) then CombatRuntime:HideSwingAnimation(track) end
			end
		end
	end
	self.InFlight, self.Buffered = true, {}
end

function ComboRuntime:Dispatched(success)
	self.InFlight = false
	local buffered = self.Buffered
	self.Buffered = {}
	if not success then return end
	self.LastDispatchAt = os.clock()
	for _, event in ipairs(buffered) do self:Evidence(event.Source, event.Track) end
end

function ComboRuntime:Step()
	if not Farm.RetreatEnabled or (Farm.Dungeon and Farm.Dungeon.Enabled) then
		if self.PendingAt or self.Count > 0 then self:ClearCount() end
		return false
	end
	if not self.PendingAt then return false end
	if self.Character ~= player.Character or self.Target ~= Farm._attackTarget
		or self.Weapon ~= player.Character:FindFirstChildOfClass("Tool")
		or not CombatRuntime:CombatReady() then self:Reset(); return false end
	CombatRuntime:ReleaseAttack()
	if os.clock() >= self.PendingExpiresAt then
		self:Reset()
		CombatRuntime.NextAttackAt = os.clock() + 0.2
		return true
	end
	if os.clock() < self.PendingAt then return true end
	if os.clock() < self.RetryAt then return true end
	self.RetryAt = os.clock() + 0.35
	if FarmRetreat:BeginCombo(self.Target) then
		self:Reset()
	else
		CombatRuntime.State = "waiting for safe retreat"
	end
	return true
end

local function attackSwing()
	local now = os.clock()
	if Farm._counterAttackPending then
		Farm._counterAttackPending = false
		CombatRuntime.NextAttackAt = 0
	end
	-- Rate-limit readiness scans as well as remote dispatches.
	if now < CombatRuntime.NextAttackAt and not CombatRuntime.Held then return end
	-- Movement happens only in CombatRuntime:Step(), not again per attack.
	local ready, reason = CombatRuntime:CombatReady()
	if not ready then
		-- Movement owns hover cleanup; a temporary attack pause must not drop us.
		CombatRuntime:Release(true)
		CombatRuntime.State = reason or "waiting"
		CombatRuntime.NextAttackAt = now + (Farm.FastAttack and 0.005 or 0.05)
		return
	end
	if not Farm.FastAttack and (Farm._skillHeld or now < (Farm._skillReadyAt or 0)) then
		CombatRuntime:ReleaseAttack()
		CombatRuntime:RestoreSwingAnimations()
		CombatRuntime.State = "รอสกิลจบ"
		return
	end
	if not Farm.FastAttack then
		if ComboRuntime:Step() then
			CombatRuntime.State = "รอพักหลังคอมโบ"
			return
		end
		ComboRuntime:RefreshHiddenTracks()
	end
	if CombatRuntime.Held or now < CombatRuntime.NextAttackAt then return end
	local char = player.Character
	local hum = char:FindFirstChildOfClass("Humanoid")
	local tool, equipped = farmEquipSelectedWeapon(char, hum)
	if not equipped then CombatRuntime.State = "equipping"; return end
	local target = Farm._attackTarget
	local targetHum = target:FindFirstChildWhichIsA("Humanoid", true)
	local health = targetHum.Health
	local previousHealth = CombatRuntime.LastHealth
	local serverConfirmedHit = previousHealth ~= nil and health < previousHealth
	if serverConfirmedHit then
		CombatRuntime.DriverHasDamage = true
		CombatRuntime.PreferredDriver = CombatRuntime.Driver
		CombatRuntime.HealthDrops = (CombatRuntime.HealthDrops or 0) + 1
		-- Only restart the combo after replicated target HP proves the
		-- previous attack really dealt damage.
		CombatRuntime:ConfirmComboDamage(target)
	end
	if previousHealth == nil or serverConfirmedHit then
		CombatRuntime.LastProgressAt = now
		CombatRuntime.DriverAttempts = 0
		CombatRuntime.NoDamageAttempts = 0
		if Farm.FastAttack and Farm.AdaptiveFastAttack and serverConfirmedHit then
			CombatRuntime.AdaptiveInterval = math.max(0.005,
				(CombatRuntime.AdaptiveInterval or Farm.AttackInterval or 0.008) - 0.001)
		end
	elseif Farm.FastAttack and Farm.AdaptiveFastAttack then
		CombatRuntime.NoDamageAttempts = (CombatRuntime.NoDamageAttempts or 0) + 1
		if CombatRuntime.NoDamageAttempts >= 6 then
			CombatRuntime.AdaptiveInterval = math.min(0.08,
				(CombatRuntime.AdaptiveInterval or Farm.AttackInterval or 0.008) + 0.002)
			CombatRuntime.NoDamageAttempts = 0
		end
	end
	CombatRuntime.LastHealth, CombatRuntime.LastSwingAt = health, now
	-- Only allow the longer combo-recovery window after observing HP loss
	-- with this method on this target. Unproven methods should fail over sooner.
	local recoveryWindow = 5
	if not Farm.FastAttack and now - CombatRuntime.LastProgressAt >= recoveryWindow and CombatRuntime.DriverAttempts >= 8 then
		CombatRuntime:ReleaseAttack()
		if Farm.FastAttack then
			CombatRuntime.DriverAttempts = 0
			CombatRuntime.LastProgressAt = now
			CombatRuntime.NextAttackAt = now + 0.005
			CombatRuntime.State = "fast attack"
		else
			CombatRuntime:NextDriver()
			CombatRuntime.DriverAttempts = 0
			CombatRuntime.LastProgressAt = now
			CombatRuntime.NextAttackAt = now + 0.2
			CombatRuntime.State = "switching attack method"
		end
		return
	end
	if not Farm.FastAttack then ComboRuntime:Prepare(target, char, hum, tool) end
	farmTrackQuestDeath(target, health)
	local dispatched = CombatRuntime:Dispatch(tool)
	if not Farm.FastAttack then ComboRuntime:Dispatched(dispatched) end
	-- Adaptive mode speeds up only while replicated HP proves damage is landing.
	local nextInterval = Farm.FastAttack and Farm.AdaptiveFastAttack
		and (CombatRuntime.AdaptiveInterval or Farm.AttackInterval)
		or Farm.AttackInterval
	-- Burst mode schedules aggressively; the single Heartbeat connection prevents runaway task spam.
	CombatRuntime.NextAttackAt = now + math.clamp(tonumber(nextInterval) or 0.008, 0.005, 0.08)
	if dispatched then
		CombatRuntime.SentAttacks = (CombatRuntime.SentAttacks or 0) + 1
		-- Dungeon Kill Aura may only finish a mob after this normal Auto Attack
		-- has actually dispatched two attack presses to the same target.
		if Farm.Dungeon and Farm.Dungeon.Enabled and Farm.Dungeon.KillAura and target then
			local presses = Farm.Dungeon.KillAuraPrime[target] or 0
			if presses < 2 then
				Farm.Dungeon.KillAuraPrime[target] = presses + 1
			end
		end
		CombatRuntime.DriverAttempts += 1
		CombatRuntime.BasicTurnPending = false
		CombatRuntime.State = "attacking"
	elseif dispatched == nil then
		CombatRuntime.State = "ซ่อนเมนูเพื่อให้ Mouse โจมตี"
		CombatRuntime.NextAttackAt = now + (Farm.FastAttack and 0.005 or 0.15)
	else
		if Farm.FastAttack then
			CombatRuntime.Driver = 1
			CombatRuntime.NextAttackAt = now + 0.005
			CombatRuntime.State = "fast retry"
		else
			CombatRuntime:NextDriver()
			CombatRuntime.NextAttackAt = now + 0.5
			CombatRuntime.State = "retrying"
		end
	end
end

local function attackStop()
	Farm.AutoAttack = false
	if Farm._attackConn then Farm._attackConn:Disconnect(); Farm._attackConn = nil end
	CombatRuntime:UnbindGameComboGate()
	CombatRuntime:Release()
end

local function attackStart()
	if Farm._attackConn then Farm._attackConn:Disconnect() end
	CombatRuntime.NextAttackAt = 0
	CombatRuntime:ResetProgress()
	CombatRuntime:BindGameComboGate()
	CombatRuntime.PerfFrames, CombatRuntime.PerfSeconds = 0, 0
	CombatRuntime.SentAttacks, CombatRuntime.HealthDrops = 0, 0
	Farm._attackConn = RunService.Heartbeat:Connect(function(dt)
		CombatRuntime:RecordFrame(dt)
		if os.clock() < (CombatRuntime.AttackErrorAt or 0) then return end
		local ok, err = pcall(attackSwing)
		if not ok then
			CombatRuntime:Release()
			CombatRuntime.AttackErrorAt = os.clock() + 1
			Farm._lastRuntimeError = tostring(err)
		end
	end)
end

local function attackSet(on)
	Farm.AutoAttack = on
	if on then attackStart() else attackStop() end
end

function CombatRuntime:SetTarget(target)
	BossLoot:Track(target)
	farmMultiBossWatchTarget(target)
	if Farm._target == target then return end
	self:Release()
	if not Farm.FastAttack then farmExtendMobHitbox(target) end
	Farm._target, Farm._attackTarget = target, nil
	self:ResetProgress()
end

function CombatRuntime:Step()
	if not Farm.Enabled then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if Farm.Dungeon and Farm.Dungeon.Enabled and char ~= Farm.Dungeon.Character then
		Farm.Dungeon:ClearIsolation()
		Farm.Dungeon.Character = char
		Farm.Dungeon.NextTargetAt = 0
	end
	-- Missing/dead characters use the normal respawn wait below; keep the toggle on.
	if char ~= self.Character or hum ~= self.Humanoid then
		BossLoot:Reset()
		self:Release()
		farmResetQuest("character changed")
		FarmRetreat:Stop()
		farmRestoreHitbox()
		self:SetTarget(nil)
		self.Character, self.Humanoid = char, hum
		self:ResetEquipment()
		self.NextScanAt = 0
		self.WasAlive = false
	end
	if not hum or hum.Health <= 0 or not char:FindFirstChild("HumanoidRootPart") then
		BossLoot:Reset()
		if self.WasAlive then
			farmResetQuest("character died")
			self:ResetEquipment()
		end
		self.WasAlive = false
		self:SetTarget(nil)
		self.NextScanAt = 0
		self:Release()
		FarmRetreat:Stop()
		farmRestoreHitbox()
		self.State = "respawning"
		return
	end
	self.WasAlive = true
	if Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then self:Release(); FarmRetreat:Clear(); self.State = "NPC quest"; return end
	BossLoot:Observe()
	if Farm.MultiBossEnabled and Farm._target then
		local bossHumanoid = Farm._target:FindFirstChildWhichIsA("Humanoid", true)
		if bossHumanoid and bossHumanoid.Health <= 0 then
			Farm._multiBossPendingAdvance = Farm.BossName
		end
	end
	FarmRetreat:Watch()
	if Farm._hitboxTool and Farm._hitboxTool.Parent ~= char then farmRestoreHitbox() end
	if attackInputBlocked() then
		BossLoot:Release()
		if BossLoot.Job and os.clock() >= BossLoot.Job.Deadline then BossLoot:Finish() end
		Farm._attackTarget = nil
		self:Release()
		FarmRetreat:Clear()
		self.State = "paused"
		return
	end
	local key = (Farm.BossEnabled and "boss:" or "mob:") .. tostring(Farm.BossEnabled and Farm.BossName or Farm.MobName)
	if key ~= self.TargetKey then
		BossLoot:Reset()
		self.TargetKey = key
		self:SetTarget(nil)
		FarmRetreat:Clear()
		self.NextScanAt = 0
	end
	if BossLoot:Step() then self:Release(); self.State = "collecting boss loot"; return end

	if Farm.MultiBossEnabled and Farm._multiBossPendingAdvance and not BossLoot.Job then
		local deadName = Farm._multiBossPendingAdvance
		self:SetTarget(nil)
		FarmRetreat:Clear()
		if farmMultiBossAdvance(deadName) then
			self.TargetKey = nil
			self.NextScanAt = 0
			self.State = "switching boss"
			return
		end
	end

	if Farm._target and not self:TargetAlive(Farm._target) then
		local oldTarget = Farm._target
		local oldHum = oldTarget and oldTarget:FindFirstChildWhichIsA("Humanoid", true)
		local confirmedDead = oldTarget == nil or oldTarget.Parent == nil
			or (oldHum ~= nil and oldHum.Health <= 0)

		self:SetTarget(nil)
		FarmRetreat:Clear()
		self.NextScanAt = 0

		if Farm.Dungeon and Farm.Dungeon.Enabled and confirmedDead then
			Farm.Dungeon:ClearIsolation()
			Farm.Dungeon.NextTargetAt = os.clock()
				+ math.clamp(tonumber(Farm.Dungeon.NextTargetDelay) or 0.5, 0.1, 3)
			self.State = "waiting next dungeon target"
			return
		end
	end
	if FarmRetreat:Step() then self.State = "retreating"; return end
	farmTryAutoQuest()
	local quest = Farm.AutoQuest and farmCurrentQuestSpec() or nil
	if Farm._questBusy or (quest and (Farm._questNeeded or Farm._acceptedQuestText ~= quest.Text)) then
		Farm._attackTarget = nil
		self:Release()
		self.State = "quest"
		return
	end
	local dungeonTargetReady = not (Farm.Dungeon and Farm.Dungeon.Enabled)
		or os.clock() >= (Farm.Dungeon.NextTargetAt or 0)
	if not Farm._target and dungeonTargetReady and os.clock() >= self.NextScanAt then
		self.NextScanAt = os.clock() + 0.25
		if Farm.MultiBossEnabled and not farmFindBossByName(Farm.BossName) then
			-- An absent first boss must not block another selected, living boss.
			for offset = 1, #Farm.MultiBossOrder - 1 do
				local index = (Farm.MultiBossIndex + offset - 1) % #Farm.MultiBossOrder + 1
				local name = Farm.MultiBossOrder[index]
				if farmFindBossByName(name) then
					Farm.MultiBossIndex, Farm.BossName = index, name
					Farm._multiBossPendingAdvance = nil
					farmMultiBossDisconnectDeath()
					self.TargetKey = "boss:" .. name
					if Farm.MultiBossLabel and Farm.MultiBossLabel.Parent then
						Farm.MultiBossLabel.Text = "Multi Boss • ไปตี " .. name
					end
					break
				end
			end
		end
		self:SetTarget(farmNearestByName(Farm.BossEnabled and Farm.BossName or Farm.MobName, Farm.BossEnabled))
	end
	local target = Farm._target
	if not self:TargetAlive(target) then
		Farm._attackTarget = nil
		if Farm.Dungeon and Farm.Dungeon.Enabled then
			if os.clock() < (Farm.Dungeon.NextTargetAt or 0) then
				self:Release()
				self.State = "waiting next dungeon target"
				return
			end
			Farm.Dungeon:ClearIsolation()
			self:SetTarget(Farm.Dungeon:FindTarget())
			target = Farm._target
			if self:TargetAlive(target) then
				self.NextScanAt = 0
			else
				self.State = "waiting"
				return
			end
		else
			self.State = "waiting"
			return
		end
	end
	-- Direct attacks do not need huge touching weapon parts. Avoid repeatedly
	-- resizing every blade/handle and the NPC's physics root in fast mode.
	if Farm.FastAttack then
		if not Farm.PlayerHitboxTest and (next(Farm._hitboxOriginals) or next(Farm._mobHitboxOriginals)) then farmRestoreHitbox() end
	else
		farmExtendHitbox()
		farmExtendMobHitbox(target)
	end
	if farmMoveUnder(target) then
		Farm._attackTarget = target
	else
		Farm._attackTarget = nil
		self:Release()
	end
end

local function farmRecoverCharacterControl()
	DamageBlock:Release()
	FarmRetreat:Stop()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		pcall(function()
			root.Anchored = false
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end)
		-- If farm was stopped while standing under a target, lift the player back
		-- above the ground instead of leaving the root intersecting the floor.
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local excluded = { char }
		local npcs = workspace:FindFirstChild("Humanoids")
		if npcs then table.insert(excluded, npcs) end
		params.FilterDescendantsInstances = excluded
		params.RespectCanCollide = true
		local ground = workspace:Raycast(root.Position + Vector3.new(0, 12, 0), Vector3.new(0, -40, 0), params)
		if ground and hum then
			local safeY = ground.Position.Y + math.max(hum.HipHeight, 0) + root.Size.Y * 0.5 + 0.5
			if root.Position.Y < safeY then
				local look = root.CFrame.LookVector
				local safePos = Vector3.new(root.Position.X, safeY, root.Position.Z)
				pcall(function() root.CFrame = CFrame.lookAt(safePos, safePos + look) end)
			end
		end
	end
	if hum and hum.Health > 0 then
		pcall(function()
			hum.PlatformStand = false
			hum.Sit = false
			hum.AutoRotate = true
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
		task.defer(function()
			if hum.Parent and hum.Health > 0 and not hum.PlatformStand then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end
		end)
	end
end

local function farmStop()
	BossLoot:Reset()
	attackStop()
	CombatRuntime:SetTarget(nil)
	CombatRuntime:ResetEquipment()
	farmResetQuest("stopped")
	FarmRetreat:Stop()
	farmRestoreHitbox()
	if Farm._conn then Farm._conn:Disconnect(); Farm._conn = nil end
	farmRestoreCharacter()
	farmRecoverCharacterControl()
	CombatRuntime.State = "idle"
end

local function farmStart()
	if Farm._conn then Farm._conn:Disconnect() end
	Farm._conn = RunService.Heartbeat:Connect(function()
		if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
			Farm.Enabled = false
			farmStop()
			return
		end
		if os.clock() < CombatRuntime.NextRecoveryAt then return end
		if os.clock() < (CombatRuntime.NextStepAt or 0) then return end
		CombatRuntime.NextStepAt = os.clock() + 1 / 30
		local ok, err = pcall(function() CombatRuntime:Step() end)
		if not ok then
			Farm._attackTarget = nil
			CombatRuntime:Release()
			BossLoot:Reset()
			FarmRetreat:Clear()
			CombatRuntime.NextRecoveryAt = os.clock() + 1
			Farm._lastRuntimeError = tostring(err)
		end
	end)
end

local function farmSet(on, storyInternal)
	if Farm.StopDungeonCombat then Farm.StopDungeonCombat() end
	if not storyInternal and Farm.StopDungeon then Farm.StopDungeon() end
	if not storyInternal and Farm.StopMultiBoss then Farm.StopMultiBoss() end
	if not storyInternal and Farm.StopRaidChest then Farm.StopRaidChest() end
	if not storyInternal and Farm.StopPages then Farm.StopPages() end
	if not storyInternal and Farm.StopDelivery then Farm.StopDelivery() end
	if not storyInternal and Farm.StopStory then Farm.StopStory() end
	if not storyInternal and Farm.StopBear then Farm.StopBear() end
	farmStop()
	Farm.Enabled = on
	if on then
		CombatRuntime.Character, CombatRuntime.Humanoid = nil, nil
		CombatRuntime.NextScanAt, CombatRuntime.NextRecoveryAt = 0, 0
		CombatRuntime.TargetKey = nil
		farmKeepCharacterVisible()
		farmStart()
		attackSet(true)
	end
end

local function farmSetMultiBoss(on, keepCurrentMode)
	on = on == true
	if on then
		if Farm.MultiBossEnabled then return true end
		if #Farm.MultiBossOrder < 2 then return false, "เลือกบอสอย่างน้อย 2 ตัว" end

		if Farm.StopRaidChest then Farm.StopRaidChest() end
		if Farm.StopPages then Farm.StopPages() end
		if Farm.StopDelivery then Farm.StopDelivery() end
		if Farm.StopStory then Farm.StopStory() end
		if Farm.StopBear then Farm.StopBear() end

		Farm._multiBossSaved = {
			BossName = Farm.BossName,
			BossEnabled = Farm.BossEnabled,
			AutoQuest = Farm.AutoQuest,
		}
		farmSet(false, true)
		Farm.MultiBossEnabled = true
		Farm.MultiBossIndex = 1
		Farm._multiBossPendingAdvance = nil
		farmMultiBossDisconnectDeath()
		Farm.BossEnabled = true
		Farm.BossName = Farm.MultiBossOrder[1]
		farmSet(true, true)
		return true
	end

	if not Farm.MultiBossEnabled then return true end
	Farm.MultiBossEnabled = false
	Farm._multiBossPendingAdvance = nil
	farmMultiBossDisconnectDeath()
	if Farm.Enabled and Farm.BossEnabled then farmSet(false, true) end
	if Farm._multiBossSaved and not keepCurrentMode then
		Farm.BossName = Farm._multiBossSaved.BossName or Farm.BossName
		Farm.BossEnabled = Farm._multiBossSaved.BossEnabled == true
		Farm.AutoQuest = Farm._multiBossSaved.AutoQuest == true
	end
	Farm._multiBossSaved = nil
	Farm.MultiBossIndex = 1
	if Farm.MultiBossSetter then Farm.MultiBossSetter(false, false) end
	return true
end

Farm.StopMultiBoss = function()
	if Farm.MultiBossEnabled then farmSetMultiBoss(false, true) end
end

--------------------------------------------------------------
-- RAID CHEST FARM — AUTO SCAN ALL SAVED POINTS
--------------------------------------------------------------
Farm.RaidChest = {
	Enabled = false,
	Phase = "idle",
	PointIndex = 1,
	MobKey = "Raid Box Point 1",
	Origin = RAID_BOX_POINTS[1],
	SeenCount = 0,
	NextAt = 0,
	CheckUntil = 0,
	CollectUntil = 0,
	LastLootAt = 0,
	Label = nil,
	Setter = nil,
	StatusPrefix = "คุมกล่อง",
}

function Farm.RaidChest:PointName()
	return "จุด " .. tostring(self.PointIndex)
end

function Farm.RaidChest:SetPoint(index)
	local total = #RAID_BOX_POINTS
	index = math.clamp(math.floor(tonumber(index) or 1), 1, total)
	self.PointIndex = index
	self.MobKey = "Raid Box Point " .. index
	self.Origin = RAID_BOX_POINTS[index]
	self.StatusPrefix = "คุมกล่อง • จุด " .. index
end

function Farm.RaidChest:Status(message, color)
	if self.Label and self.Label.Parent then
		self.Label.Text = (self.StatusPrefix or "คุมกล่อง") .. " • " .. tostring(message)
		self.Label.TextColor3 = color or T.Mint
	end
end

function Farm.RaidChest:ReleaseT()
	local held = self.HeldT
	self.HeldT = nil
	if held then
		pcall(function() held:SendKeyEvent(false, Enum.KeyCode.T, false, game) end)
	end
end

function Farm.RaidChest:PromptPosition(prompt)
	if not prompt or not prompt.Parent then return nil end
	local node = prompt.Parent
	while node and node ~= workspace do
		if node:IsA("Attachment") then return node.WorldPosition end
		if node:IsA("BasePart") then return node.Position end
		if node:IsA("Model") then return node:GetPivot().Position end
		node = node.Parent
	end
	return nil
end

function Farm.RaidChest:PromptIsNpc(prompt)
	local node = prompt and prompt.Parent
	while node and node ~= workspace do
		if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return true end
		local n = node.Name:lower()
		if n == "activenpcs" or n == "stationarynpcs" then return true end
		node = node.Parent
	end
	return false
end

function Farm.RaidChest:StartDropWatch()
	if self.AddedConnection then self.AddedConnection:Disconnect() end
	self.NewPrompts = {}
	self.Collected = setmetatable({}, { __mode = "k" })
	self.LootRecords = setmetatable({}, { __mode = "k" })
	self.AddedConnection = workspace.DescendantAdded:Connect(function(instance)
		if self.Enabled and instance:IsA("ProximityPrompt") then
			self.NewPrompts[instance] = true
		end
	end)
end

function Farm.RaidChest:StopDropWatch()
	if self.AddedConnection then self.AddedConnection:Disconnect(); self.AddedConnection = nil end
end

function Farm.RaidChest:NearestPrompt(root, onlyNew)
	local best, bestPos, bestDistance
	if onlyNew then
		-- Loot collection uses the same prompt rules as BossLoot and scans all
		-- existing prompts too, not only DescendantAdded events.
		local job = { Origin = self.Origin }
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") and not self.Collected[prompt] then
				local candidate = BossLoot:Candidate(prompt, job)
				if candidate and candidate.Kind == "claim"
					and (candidate.Position - self.Origin).Magnitude <= 90 then
					local record = self.LootRecords and self.LootRecords[prompt]
					if not record then
						record = { Attempts = 0, NextAt = 0 }
						self.LootRecords[prompt] = record
					end
					if record.Attempts < 6 and os.clock() >= record.NextAt then
						local distance = (candidate.Position - root.Position).Magnitude
						if not bestDistance or distance < bestDistance then
							best, bestPos, bestDistance = prompt, candidate.Position, distance
						end
					end
				end
			end
		end
	else
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") and prompt.Enabled and not self:PromptIsNpc(prompt) then
				local pos = self:PromptPosition(prompt)
				if pos then
					local distance = (pos - self.Origin).Magnitude
					if distance <= 20 and (not bestDistance or distance < bestDistance) then
						best, bestPos, bestDistance = prompt, pos, distance
					end
				end
			end
		end
	end
	return best, bestPos
end

function Farm.RaidChest:BeginPrompt(prompt, seconds)
	if not prompt or not prompt.Parent then return false end
	self:ReleaseT()
	if self.HeldPrompt then pcall(function() self.HeldPrompt:InputHoldEnd() end) end
	local input = game:GetService("VirtualInputManager")
	self.HeldPrompt = prompt
	self.HeldT = input
	self.PromptUntil = os.clock() + math.max(tonumber(seconds) or prompt.HoldDuration or 0, 0.12)
	pcall(function()
		prompt:InputHoldBegin()
		input:SendKeyEvent(true, Enum.KeyCode.T, false, game)
	end)
	return true
end

function Farm.RaidChest:FinishPrompt()
	local prompt = self.HeldPrompt
	self.HeldPrompt = nil
	self.PromptUntil = 0
	if prompt then pcall(function() prompt:InputHoldEnd() end) end
	self:ReleaseT()
	return prompt
end

function Farm.RaidChest:BeginCheck()
	if Farm.Enabled then farmSet(false, true) end
	self:FinishPrompt()
	self:StopDropWatch()
	self.SeenCount = 0
	self.Phase = "checkMove"
	self.NextAt = 0
	self.CheckUntil = 0
end

function Farm.RaidChest:AdvancePoint(delaySeconds)
	if Farm.Enabled then farmSet(false, true) end
	self:FinishPrompt()
	self:StopDropWatch()
	self.SeenCount = 0
	self:SetPoint((self.PointIndex % #RAID_BOX_POINTS) + 1)
	self.Phase = "checkMove"
	self.NextAt = os.clock() + (delaySeconds or 0.15)
	self.CheckUntil = 0
end

function Farm.RaidChest:SetEnabled(on, internal)
	on = on == true
	if self.Enabled == on then return end

	if on then
		if Farm.StopPages then Farm.StopPages() end
		if Farm.StopDelivery then Farm.StopDelivery() end
		if Farm.StopStory then Farm.StopStory() end
		if Farm.StopBear then Farm.StopBear() end

		self.Saved = {
			MobName = Farm.MobName,
			BossEnabled = Farm.BossEnabled,
			AutoQuest = Farm.AutoQuest,
			AutoLoot = Farm.AutoLoot,
		}
		farmSet(false, true)
		self.Enabled = true
		self:SetPoint(1)
		if self.Setter then self.Setter(true, false) end
		self:BeginCheck()
	else
		self.Enabled = false
		self:FinishPrompt()
		self:ReleaseT()
		self:StopDropWatch()
		if Farm.Enabled then farmSet(false, true) end
		farmRecoverCharacterControl()
		if self.Saved then
			Farm.MobName = self.Saved.MobName
			Farm.BossEnabled = self.Saved.BossEnabled
			Farm.AutoQuest = self.Saved.AutoQuest
			Farm.AutoLoot = self.Saved.AutoLoot
		end
		self.Saved = nil
		self.Phase = "idle"
		self.SeenCount = 0
		if self.Setter then self.Setter(false, false) end
		if not internal then self:Status("OFF", T.Sub) end
	end
end

function Farm.RaidChest:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		self:SetEnabled(false, true)
		return
	end
	if Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then
		self:SetEnabled(false, true)
		return
	end

	local now = os.clock()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or hum.Health <= 0 or not root then
		self:FinishPrompt()
		self:Status("รอตัวละครพร้อม", T.Gold)
		return
	end

	if self.HeldPrompt then
		if now < (self.PromptUntil or 0) then return end
		local finished = self:FinishPrompt()
		if finished then
			self.LastLootAt = now
			if self.Phase == "collect" then
				self.LootRecords = self.LootRecords or setmetatable({}, { __mode = "k" })
				local record = self.LootRecords[finished] or { Attempts = 0, NextAt = 0 }
				record.Attempts += 1
				record.NextAt = now + 0.45
				self.LootRecords[finished] = record
				-- Only stop retrying when the prompt disappeared/disabled or
				-- after several attempts, like the boss-loot retry behavior.
				if not finished.Parent or not finished.Enabled or record.Attempts >= 6 then
					self.Collected[finished] = true
				end
			else
				self.Collected = self.Collected or setmetatable({}, { __mode = "k" })
				self.Collected[finished] = true
			end
		end
		self.NextAt = now + 0.15
		return
	end

	if now < (self.NextAt or 0) then return end

	if self.Phase == "checkMove" then
		tpSafeGo(CFrame.new(self.Origin + Vector3.new(0, 3, 0)))
		self.CheckUntil = now + 1.4
		self.Phase = "checkWait"
		self.NextAt = now + 0.35
		self:Status("กำลังตรวจว่ามอนเกิดไหม", T.Gold)
		return
	end

	if self.Phase == "checkWait" then
		local alive = farmFindMobsByName(self.MobKey)
		if #alive > 0 then
			self.SeenCount = #alive
			Farm.MobName = self.MobKey
			Farm.BossEnabled = false
			Farm.AutoQuest = false
			BossLoot:Reset()
			farmSet(true, true)
			self.Phase = "fight"
			self.NextAt = now + 0.15
			self:Status("พบมอน " .. #alive .. " ตัว • เริ่มตี", T.Mint)
			return
		end
		if now >= (self.CheckUntil or 0) then
			self:Status("ไม่มีมอน • ไปตรวจจุดถัดไป", T.Sub)
			self:AdvancePoint(0.1)
		else
			self.NextAt = now + 0.2
		end
		return
	end

	if self.Phase == "fight" then
		if Farm.MobName ~= self.MobKey or not Farm.Enabled then
			Farm.MobName = self.MobKey
			Farm.BossEnabled = false
			Farm.AutoQuest = false
			farmSet(true, true)
		end
		local alive = farmFindMobsByName(self.MobKey)
		if #alive > 0 then
			self.SeenCount = math.max(self.SeenCount or 0, #alive)
			self:Status("กำลังตี • เหลือ " .. #alive .. " ตัว", T.Gold)
			self.NextAt = now + 0.2
			return
		end

		-- We only open this chest if at least one raid mob was actually seen here.
		if (self.SeenCount or 0) > 0 then
			farmSet(false, true)
			self.Phase = "chest"
			self.NextAt = now + 0.15
			self:Status("มอนตายหมด • เปิดกล่อง", T.Mint)
		else
			self:AdvancePoint(0.1)
		end
		return
	end

	if self.Phase == "chest" then
		tpSafeGo(CFrame.new(self.Origin + Vector3.new(0, 2.5, 0)))
		self:StartDropWatch()
		local chestPrompt = self:NearestPrompt(root, false)
		if chestPrompt then
			self:BeginPrompt(chestPrompt, math.max(chestPrompt.HoldDuration, 2.2))
		else
			local input = game:GetService("VirtualInputManager")
			self.HeldT = input
			pcall(function() input:SendKeyEvent(true, Enum.KeyCode.T, false, game) end)
		end
		self.Phase = "chestWait"
		self.NextAt = now + 2.25
		self:Status("กด T ค้างเปิดกล่อง", T.Gold)
		return
	end

	if self.Phase == "chestWait" then
		self:FinishPrompt()
		self:ReleaseT()
		self.Phase = "collect"
		-- Give enough time for multiple drops because each item now holds T for 4 seconds.
		self.CollectUntil = now + 60
		self.LastLootAt = now
		self.NextAt = now + 0.3
		self:Status("รอของดรอป", T.Mint)
		return
	end

	if self.Phase == "collect" then
		local prompt, pos = self:NearestPrompt(root, true)
		if prompt and pos then
			local candidate = BossLoot:Candidate(prompt, { Origin = self.Origin })
			local moved = candidate and BossLoot:MoveNear(candidate, char, root, hum)
			if not moved then
				tpSafeGo(CFrame.new(pos + Vector3.new(0, 2.5, 0)))
			end
			-- Hold T for at least 4 seconds for every dropped item.
			self:BeginPrompt(prompt, math.max(prompt.HoldDuration, 4.0))
			self.CollectUntil = math.max(self.CollectUntil or 0, now + 12)
			self.LastLootAt = now
			self:Status("กด T ค้าง 4 วิ เก็บไอเทม • " .. tostring(prompt.ObjectText), T.Mint)
			return
		end

		if now >= (self.CollectUntil or 0) or now - (self.LastLootAt or now) >= 6 then
			self:Status("เก็บของเสร็จ • ไปตรวจจุดถัดไป", T.Sub)
			self:AdvancePoint(0.15)
		else
			self.NextAt = now + 0.15
		end
		return
	end
end

Farm.StopRaidChest = function()
	if Farm.RaidChest and Farm.RaidChest.Enabled then
		Farm.RaidChest:SetEnabled(false, true)
	end
end

Farm.RaidChest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function()
		Farm.RaidChest:Step()
	end)
	if not ok then
		Farm._lastRuntimeError = tostring(err)
		Farm.RaidChest:Status("ERROR: " .. tostring(err), T.Danger)
	end
end)

gui.Destroying:Connect(function()
	if Farm.RaidChest then
		Farm.RaidChest:SetEnabled(false, true)
		if Farm.RaidChest.Connection then
			Farm.RaidChest.Connection:Disconnect()
			Farm.RaidChest.Connection = nil
		end
	end
end)

--------------------------------------------------------------
-- BETTY QUEST
--------------------------------------------------------------
local BettyQuest = { Enabled = false, Phase = "npc", NextAt = 0, Held = nil,
	Character = nil, Root = nil, Gem = nil, Attempts = 0, Status = "ปิด Auto Quest Betty" }

function BettyQuest:SetStatus(value)
	self.Status = value
	if self.Label and self.Label.Parent then self.Label.Text = value end
end

function BettyQuest:Release()
	local held = self.Held
	self.Held = nil
	if held then pcall(function() held.Input:SendKeyEvent(false, Enum.KeyCode.T, false, game) end) end
end

function BettyQuest:SetEnabled(on)
	if on and Farm.StopPages then Farm.StopPages() end
	if on and Farm.StopDelivery then Farm.StopDelivery() end
	if on and Farm.StopStory then Farm.StopStory() end
	if on and Farm.StopBear then Farm.StopBear() end
	self:Release()
	self.Enabled, Farm._bettyBusy = on, on
	if self.Setter then self.Setter(on, false) end
	self.Phase, self.NextAt, self.Attempts = "npc", 0, 0
	self.Character, self.Root, self.Gem = nil, nil, nil
	BossLoot:Reset()
	FarmRetreat:Stop()
	CombatRuntime:Release()
	farmResetQuest(on and "Betty started" or "Betty stopped")
	self:SetStatus(on and "รอปิดเมนูหรือช่องแชต" or "ปิด Auto Quest Betty")
end

function BettyQuest:NpcRoot()
	local node = workspace
	for _, name in ipairs({ "Debree", "Regions", "Bamboo Grove", "StationaryNpcs", "Betty", "HumanoidRootPart" }) do
		node = node and node:FindFirstChild(name)
		if not node then return nil end
	end
	return node
end

function BettyQuest:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then self:SetEnabled(false); return end
	local now = os.clock()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if char ~= self.Character or root ~= self.Root or not hum or hum.Health <= 0 then
		self:Release()
		self.Character, self.Root = char, root
		self.Phase, self.Attempts, self.NextAt, self.Gem = "npc", 0, 0, nil
	end
	if not root or not hum or hum.Health <= 0 then self:SetStatus("รอตัวละครพร้อม"); return end
	if attackInputBlocked() then
		if self.Held then self:Release(); self.Phase = "gem" end
		self:SetStatus("รอปิดเมนูหรือช่องแชต"); return
	end
	if now < self.NextAt then return end
	if self.Phase == "returnBetty" or self.Phase == "returnTalk" then
		local npc, ev = self:NpcRoot(), farmGetSignal()
		if not npc then TP.ApproachSaved(root, "Betty") end
		if not npc or not ev then self.NextAt = now + 1; return end
		if self.Phase == "returnBetty" or (root.Position - npc.Position).Magnitude > 8 then
			root.CFrame = CFrame.lookAt((npc.CFrame * CFrame.new(0, 0, -3)).Position, npc.Position)
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			self.Phase, self.NextAt = "returnTalk", now + 0.4
		else
			ev:FireServer("NpcTalking", "Ended")
			self.Phase, self.NextAt = "waitSpawn", now + 1
			self:SetStatus("กลับ Betty แล้ว รอ Gemstone1 ชิ้นใหม่")
		end
		return
	end
	if self.Phase == "npc" or self.Phase == "talk" or self.Phase == "accept" or self.Phase == "close" then
		local npc = self:NpcRoot()
		local ev = farmGetSignal()
		if not npc then TP.ApproachSaved(root, "Betty") end
		if not npc or not npc:IsA("BasePart") or not ev then
			self.NextAt = now + 1; self:SetStatus("รอ Betty หรือระบบเควส"); return
		end
		if self.Phase == "npc" then
			root.CFrame = CFrame.lookAt((npc.CFrame * CFrame.new(0, 0, -3)).Position, npc.Position)
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			self.Phase, self.NextAt = "talk", now + 0.4
			self:SetStatus("กำลังไปหา Betty")
		elseif (root.Position - npc.Position).Magnitude > 8 then self.Phase = "npc"
		elseif self.Phase == "talk" then
			ev:FireServer("NpcTalking", "Ended")
			self.Phase, self.NextAt = "accept", now + 0.2
		elseif self.Phase == "accept" then
			ev:FireServer("AddQuest", "Ill look for it(Lv 10)")
			self.Phase, self.NextAt = "close", now + 0.2
			self:SetStatus("ส่งคำขอเควส Betty แล้ว")
		else
			ev:FireServer("NpcTalking", "Ended")
			self.Phase, self.NextAt = "gem", now + 0.5
		end
		return
	end
	local gem = workspace:FindFirstChild("Gemstone1")
	if self.Phase == "waitChange" then
		if gem ~= self.Gem or not gem then
			self.Gem, self.Phase, self.Attempts = nil, "returnBetty", 0
		end
		self.NextAt = now + 1; return
	elseif self.Phase == "waitSpawn" then
		if gem then self.Phase, self.Attempts = "npc", 0 end
		self.NextAt = now + 1; return
	elseif self.Phase == "hold" then
		self:Release()
		self.Phase, self.NextAt = "verify", now + 0.6
		return
	elseif self.Phase == "verify" then
		if gem ~= self.Gem or not gem then
			self.Phase = "returnBetty"
			self:SetStatus("Gemstone1 หายไป รอชิ้นใหม่")
		elseif self.Attempts >= 3 then
			self.Phase = "waitChange"
			self:SetStatus("ยังยืนยันการเก็บไม่ได้ รอไอเทมเปลี่ยนหรือเปิดใหม่")
		else self.Phase, self.NextAt = "gem", now + 1 end
		return
	end
	local cf = farmCFrameOf(gem)
	if not gem or not cf then self.NextAt = now + 1; self:SetStatus("รอ Gemstone1"); return end
	if self.Phase == "gem" then
		self.Gem = gem
		root.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, 2, 2), cf.Position)
		root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		self.Phase, self.NextAt = "press", now + 0.35
	elseif self.Phase == "press" then
		if gem ~= self.Gem or (root.Position - cf.Position).Magnitude > 6 then self.Phase = "gem"; return end
		local input = game:GetService("VirtualInputManager")
		self.Held = { Input = input }
		self.Attempts += 1
		input:SendKeyEvent(true, Enum.KeyCode.T, false, game)
		self.Phase, self.NextAt = "hold", now + 1
		self:SetStatus("กำลังเก็บ Gemstone1")
	end
end

BettyQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() BettyQuest:Step() end)
	if not ok then
		BettyQuest:Release()
		if BettyQuest.Phase == "press" then
			BettyQuest.Phase = BettyQuest.Attempts >= 3 and "waitChange" or "gem"
		end
		BettyQuest.NextAt = os.clock() + 3
		Farm._lastRuntimeError = tostring(err)
		BettyQuest:SetStatus(BettyQuest.Phase == "waitChange"
			and "ยังยืนยันการเก็บไม่ได้ รอไอเทมเปลี่ยนหรือเปิดใหม่"
			or "Auto Quest Betty ขัดข้อง ลองใหม่ใน 3 วินาที")
	end
end)

--------------------------------------------------------------
-- QUEST 1 — Kazu
--------------------------------------------------------------
local KazuQuest = { Enabled = false, Phase = "idle", Kills = 0, NextAt = 0,
	Watchers = {}, Counted = {}, Stage = "new", Character = nil, Root = nil }
KazuQuest.Key = tostring(game.GameId) .. "_" .. tostring(player.UserId)
KazuQuest.File = "MazxhubQuest1_" .. KazuQuest.Key .. ".txt"
if type(_G.__MAZX_QUEST1_PROGRESS) ~= "table" then _G.__MAZX_QUEST1_PROGRESS = {} end
do
	local saved = _G.__MAZX_QUEST1_PROGRESS[KazuQuest.Key]
	if not saved and type(readfile) == "function" then
		local ok, value = pcall(readfile, KazuQuest.File)
		if ok then saved = value end
	end
	if saved == "letter" or saved == "returnKazu" or saved == "done" then KazuQuest.Stage = saved end
end

function KazuQuest:Status(value)
	if self.Label and self.Label.Parent then self.Label.Text = value end
end

function KazuQuest:MarkStage(value)
	local rank = { new = 0, letter = 1, returnKazu = 2, done = 3 }
	if rank[value] < rank[self.Stage] then return end
	self.Stage = value
	_G.__MAZX_QUEST1_PROGRESS[self.Key] = value
	self.Persisted = false
	if type(writefile) == "function" then
		local ok, err = pcall(writefile, self.File, value)
		self.Persisted = ok
		if not ok then Farm._lastRuntimeError = tostring(err) end
	end
	if self.StorageLabel and not self.Persisted then
		self.StorageLabel.Text = "บันทึกข้ามเซสชันไม่ได้ หากเปิดใหม่ให้กดยืนยันว่าเคยผ่าน Chaka แล้ว"
	end
end

function KazuQuest:ClearWatchers()
	for _, record in pairs(self.Watchers) do
		for _, connection in ipairs(record.Connections) do connection:Disconnect() end
	end
	self.Watchers = {}
end

function KazuQuest:SetEnabled(on)
	if on == self.Enabled then return end
	if on and Farm.StopPages then Farm.StopPages() end
	if on and Farm.StopDelivery then Farm.StopDelivery() end
	if on and Farm.StopBear then Farm.StopBear() end
	self.Enabled = on
	self:ClearWatchers()
	if self.Setter then self.Setter(on, false) end
	if on then
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
		self.Saved = { MobName = Farm.MobName, BossEnabled = Farm.BossEnabled, AutoQuest = Farm.AutoQuest }
		farmSet(false, true)
		Farm.MobName, Farm.BossEnabled, Farm.AutoQuest = "*Civilian*", false, false
		Farm._storyBusy = true
		self.Kills, self.Counted, self.Character, self.Root, self.NextAt = 0, {}, nil, nil, 0
		self.Phase = self.Stage == "letter" and "chaka" or self.Stage == "returnKazu" and "returnKazu" or "kazu"
		self:Status("Quest 1 • Kazu • 0/4")
	else
		farmSet(false, true)
		Farm._storyBusy = false
		if self.Saved then
			Farm.MobName, Farm.BossEnabled, Farm.AutoQuest = self.Saved.MobName, self.Saved.BossEnabled, self.Saved.AutoQuest
		end
		self.Saved, self.Visit, self.Phase = nil, nil, "idle"
		self:Status("Quest 1 • OFF")
	end
end

function KazuQuest:Track(mob, beforeHealth)
	local folder = farmActiveFolder()
	if not self.Enabled or self.Phase ~= "fight" or not mob or mob.Name ~= "*Civilian*"
		or self.Kills >= 4 or not folder or not mob:IsDescendantOf(folder) then return end
	local hum = mob:FindFirstChildWhichIsA("Humanoid", true)
	if not hum or self.Counted[hum] or self.Watchers[hum] then return end
	if hum.Health <= 0 and (type(beforeHealth) ~= "number" or beforeHealth <= 0) then return end
	local record = { Connections = {}, Character = player.Character }
	self.Watchers[hum] = record
	local function died()
		if not self.Enabled or self.Phase ~= "fight" or self.Watchers[hum] ~= record
			or player.Character ~= record.Character or hum.Health > 0 or self.Counted[hum] then return end
		self.Counted[hum] = true
		self.Watchers[hum] = nil
		for _, connection in ipairs(record.Connections) do connection:Disconnect() end
		self.Kills += 1
		self:Status("Quest 1 • *Civilian* • " .. self.Kills .. "/4")
		if self.Kills >= 4 then
			Farm._storyBusy, Farm._attackTarget = true, nil
			CombatRuntime:Release()
			self.Phase = "fourDone"
			self:ClearWatchers()
		end
	end
	table.insert(record.Connections, hum.HealthChanged:Connect(died))
	table.insert(record.Connections, hum.Died:Connect(died))
	died()
end

function KazuQuest:BeginVisit(name, region, quest, nextPhase)
	Farm._storyBusy = true
	Farm._attackTarget = nil
	CombatRuntime:Release()
	FarmRetreat:Clear()
	self.Visit = { Name = name, Region = region, Quest = quest, Next = nextPhase, State = "move" }
	self.Phase = "visit"
	self:Status("Quest 1 • " .. name)
end

function KazuQuest:Step()
	if not self.Enabled then return end
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or not gui.Parent then self:SetEnabled(false); return end
	local now, char = os.clock(), player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or hum.Health <= 0 or not root then
		Farm._storyBusy = true
		CombatRuntime:Release()
		self:ClearWatchers()
		self.Character = nil
		self:Status("รอตัวละครพร้อม"); return
	end
	if self.Character and (self.Character ~= char or self.Root ~= root) then self.Character = nil end
	if not self.Character then
		self.Character, self.Root = char, root
		self:ClearWatchers()
		self.Kills, self.Counted, self.Visit = 0, {}, nil
		self.Phase = self.Stage == "letter" and "chaka" or self.Stage == "returnKazu" and "returnKazu" or "kazu"
		Farm._storyBusy = true
	end
	if attackInputBlocked() then CombatRuntime:Release(); return end
	if now < self.NextAt then return end
	if self.Phase == "kazu" then self:BeginVisit("Kazu", "Windy Peak", "Ill help clear them out", "fight")
	elseif self.Phase == "fourDone" then
		farmSet(false, true)
		if self.Stage == "done" then self:SetEnabled(false); self:Status("ครบ 4 ตัวแล้ว หยุด Quest 1")
		elseif self.Stage == "new" then self:BeginVisit("Noote", "Windy Peak", "Ill get this letter delivered", "chaka")
		else self.Phase = self.Stage == "letter" and "chaka" or "returnKazu" end
	elseif self.Phase == "chaka" then self:BeginVisit("Chaka", "Bamboo Grove", nil, "returnKazu")
	elseif self.Phase == "returnKazu" then self:BeginVisit("Kazu", "Windy Peak", nil, "finished")
	elseif self.Phase == "visit" then
		local visit, npc = self.Visit, workspace
		for _, name in ipairs({ "Debree", "Regions", visit.Region, "StationaryNpcs", visit.Name, "HumanoidRootPart" }) do
			npc = npc and npc:FindFirstChild(name)
		end
		local ev = farmGetSignal()
		if not npc or not ev then
			if not npc then TP.ApproachSaved(root, visit.Name) end
			visit.ArrivedAt = nil; self.NextAt = now + 0.4; return
		end
		if visit.State == "move" or (root.Position - npc.Position).Magnitude > 6 then
			local destination = (npc.CFrame * CFrame.new(0, 0, -3)).Position
			local delta = destination - root.Position
			if delta.Magnitude > 80 then destination = root.Position + delta * (80 / delta.Magnitude) end
			root.CFrame = CFrame.lookAt(destination, npc.Position)
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			visit.ArrivedAt = nil
			-- If the server moves us away after talking, retry delivery at the NPC.
			if visit.State == "delivered" then visit.State = "talk" end
			if visit.State == "move" then visit.State = "talk" end
			self.NextAt = now + 0.4; return
		end
		if not visit.ArrivedAt then visit.ArrivedAt = now; self.NextAt = now + 1.2; return end
		if now - visit.ArrivedAt < 1.2 then return end
		if visit.State == "talk" then
			ev:FireServer("NpcTalking", "Ended")
			if visit.Quest then visit.State = "accept"; self.NextAt = now + 0.2; return end
			if visit.Name == "Chaka" then visit.State = "delivered"; self.NextAt = now + 1.5; return end
		elseif visit.State == "accept" then
			ev:FireServer("AddQuest", visit.Quest)
			if visit.Name == "Noote" then self:MarkStage("letter") end
			visit.State, self.NextAt = "close", now + 0.2; return
		elseif visit.State == "close" then ev:FireServer("NpcTalking", "Ended") end
		if visit.Name == "Chaka" then self:MarkStage("returnKazu") end
		self.Phase, self.Visit, self.NextAt = visit.Next, nil, now + 0.4
		if self.Phase == "fight" then
			Farm._storyBusy = false
			farmSet(true, true)
		elseif self.Phase == "finished" then
			self:MarkStage("done")
			self:SetEnabled(false)
			self:Status("กลับ Kazu แล้ว ห้ามย้อน Noote")
		end
	end
end

Farm.TrackStoryDeath = function(mob, health) KazuQuest:Track(mob, health) end
Farm.StopStory = function() if KazuQuest.Enabled then KazuQuest:SetEnabled(false) end end
KazuQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() KazuQuest:Step() end)
	if not ok then
		KazuQuest:SetEnabled(false)
		Farm._lastRuntimeError = tostring(err)
		KazuQuest:Status("Quest 1 • ERROR: " .. tostring(err))
	end
end)

--------------------------------------------------------------
-- QUEST 3 — MoldySugar
--------------------------------------------------------------
local DeliveryQuest = { Enabled = false, Phase = "moveSource", NextAt = 0, Character = nil, Root = nil }

function DeliveryQuest:Status(message)
	if self.Label and self.Label.Parent then self.Label.Text = message end
end

function DeliveryQuest:SetEnabled(on)
	if self.Enabled == on then return end
	if on and Farm.StopPages then Farm.StopPages() end
	if on and Farm.StopBear then Farm.StopBear() end
	if on then
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
		if KazuQuest.Enabled then KazuQuest:SetEnabled(false) end
	end
	self.Enabled, Farm._deliveryBusy = on, on
	self.Phase, self.NextAt, self.Character, self.Root = "moveSource", 0, nil, nil
	self.SourcePosition, self.StreamWaitAt = nil, nil
	if self.Setter then self.Setter(on, false) end
	BossLoot:Reset()
	FarmRetreat:Stop()
	CombatRuntime:Release()
	farmResetQuest(on and "delivery started" or "delivery stopped")
	self:Status(on and "Quest 3 • MoldySugar" or "Quest 3 • OFF")
end

function DeliveryQuest:Npc(name, region)
	local node = workspace
	for _, key in ipairs({ "Debree", "Regions", region, "StationaryNpcs", name, "HumanoidRootPart" }) do
		node = node and node:FindFirstChild(key)
	end
	return node and node:IsA("BasePart") and node or nil
end

function DeliveryQuest:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then self:SetEnabled(false); return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if self.Character and (char ~= self.Character or root ~= self.Root or not hum or hum.Health <= 0) then
		self:SetEnabled(false)
		self:Status("ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 3 ใหม่เมื่อพร้อม"); return
	end
	if not hum or hum.Health <= 0 or not root then self:Status("รอตัวละครพร้อม"); return end
	self.Character, self.Root = char, root
	if attackInputBlocked() then return end
	local now = os.clock()
	if now < self.NextAt then return end
	local atElara = self.Phase == "moveElara" or self.Phase == "equipElara" or self.Phase == "talkElara"
	local name, region = atElara and "Elara" or "MoldySugar", atElara and "Mistfall Harbor" or "Windy Peak"
	local npc = self:Npc(name, region)
	local ev = farmGetSignal()
	if npc and not atElara then self.SourcePosition = npc.Position end
	if not npc then
		-- User-recorded Elara position; the source is recorded before departure.
		local savedPosition = game.PlaceId == 136406881576517 and TP.Positions[name] or nil
		local destination = savedPosition or (not atElara and self.SourcePosition)
		if destination then
			local stand = destination + Vector3.new(0, 0, -3)
			local delta = stand - root.Position
			if delta.Magnitude > 5 then
				local nextPosition = delta.Magnitude > 80 and root.Position + delta * (80 / delta.Magnitude) or stand
				root.CFrame = CFrame.lookAt(nextPosition, destination)
				root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
				self.StreamWaitAt = nil
			else
				self.StreamWaitAt = self.StreamWaitAt or now
				if now - self.StreamWaitAt >= 30 then
					self:SetEnabled(false)
					self:Status("ถึงพิกัดแล้ว แต่ NPC ยังไม่โหลด: " .. name)
					return
				end
			end
			self:Status("Quest 3 • เดินทาง/รอโหลด " .. name)
			self.NextAt = now + 0.4
			return
		end
	end
	if npc then self.StreamWaitAt = nil end
	if not npc or not ev then self:Status("Quest 3 • รอ " .. name); self.NextAt = now + 1; return end
	if self.Phase == "moveSource" or self.Phase == "moveElara" or self.Phase == "returnSource"
		or (root.Position - npc.Position).Magnitude > 8 then
		root.CFrame = CFrame.lookAt((npc.CFrame * CFrame.new(0, 0, -3)).Position, npc.Position)
		root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		if self.Phase == "moveSource" then self.Phase = "talkSource"
		elseif self.Phase == "moveElara" then self.Phase = "equipElara"
		elseif self.Phase == "returnSource" then self.Phase = "finished" end
		self.NextAt = now + 0.4
		self:Status("Quest 3 • " .. name)
	elseif self.Phase == "talkSource" then
		ev:FireServer("NpcTalking", "Ended")
		self.Phase, self.NextAt = "accept", now + 0.2
	elseif self.Phase == "accept" then
		ev:FireServer("AddQuest", "Ill deliver the package")
		self.Phase, self.NextAt = "moveElara", now + 0.4
	elseif self.Phase == "equipElara" then
		ev:FireServer("Item_Equip", 2)
		self.Phase, self.NextAt = "talkElara", now + 0.6
	elseif self.Phase == "talkElara" then
		ev:FireServer("NpcTalking", "Ended")
		self.Phase, self.NextAt = "returnSource", now + 0.4
	elseif self.Phase == "finished" then
		self:SetEnabled(false)
		self:Status("กลับ MoldySugar แล้ว หยุด Quest 3")
	end
end

Farm.StopDelivery = function() if DeliveryQuest.Enabled then DeliveryQuest:SetEnabled(false) end end
DeliveryQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() DeliveryQuest:Step() end)
	if not ok then
		DeliveryQuest:SetEnabled(false)
		Farm._lastRuntimeError = tostring(err)
		DeliveryQuest:Status("Quest 3 • ERROR: " .. tostring(err))
	end
end)

--------------------------------------------------------------
-- QUEST 4 — Kona
--------------------------------------------------------------
local PagesQuest = {
	Enabled = false, Phase = "npc", NextAt = 0,
	Index = 1, Collected = 0, Attempts = 0,
	Held = nil, Character = nil, Root = nil, Target = nil,
	Picked = {}, WaitSince = nil, AcceptSentAt = 0, AcceptDeadline = 0,
}

function PagesQuest:Status(message)
	if self.Label and self.Label.Parent then self.Label.Text = message end
end

function PagesQuest:Release()
	local held = self.Held
	self.Held = nil
	if held then pcall(function() held.Input:SendKeyEvent(false, Enum.KeyCode.T, false, game) end) end
end

function PagesQuest:SetEnabled(on)
	if self.Enabled == on then return end
	self:Release()
	if on then
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
		if KazuQuest.Enabled then KazuQuest:SetEnabled(false) end
		if DeliveryQuest.Enabled then DeliveryQuest:SetEnabled(false) end
		if Farm.StopBear then Farm.StopBear() end
	end
	self.Enabled, Farm._pagesBusy = on, on
	self.Phase, self.NextAt, self.Character, self.Root = "npc", 0, nil, nil
	self.Target, self.WaitSince, self.AcceptSentAt, self.AcceptDeadline = nil, nil, 0, 0
	if on then self.Index, self.Collected, self.Attempts, self.Picked = 1, 0, 0, {} end
	if self.Setter then self.Setter(on, false) end
	BossLoot:Reset(); FarmRetreat:Stop(); CombatRuntime:Release()
	farmResetQuest(on and "pages started" or "pages stopped")
	self:Status(on and "Quest 4 • Kona • 0/5" or "Quest 4 • OFF")
end

function PagesQuest:KonaRoot()
	local node = workspace
	for _, key in ipairs({ "Debree", "Regions", "Windy Peak", "StationaryNpcs", "Kona", "HumanoidRootPart" }) do
		node = node and node:FindFirstChild(key)
		if not node then return nil end
	end
	return node and node:IsA("BasePart") and node or nil
end

function PagesQuest:FindPage(index)
	local page = workspace:FindFirstChild("Lost Page" .. index)
	return page and farmCFrameOf(page) and page or nil
end

function PagesQuest:WarpToKona(npc)
	local char = self.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local stand = (npc.CFrame * CFrame.new(0, 0, -3)).Position
	root.CFrame = CFrame.lookAt(stand, npc.Position)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

function PagesQuest:WarpToPage(page)
	local char = self.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local cf = farmCFrameOf(page)
	if not cf then return end
	root.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, 2, 2), cf.Position)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

function PagesQuest:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then self:SetEnabled(false); return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if self.Character and (char ~= self.Character or root ~= self.Root or not hum or hum.Health <= 0) then
		self:SetEnabled(false)
		self:Status("ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 4 ใหม่เมื่อพร้อม")
		return
	end
	if not root or not hum or hum.Health <= 0 then self:Status("รอตัวละครพร้อม"); return end
	self.Character, self.Root = char, root

	if attackInputBlocked() then
		if self.Held then self:Release(); self.Phase = "verify" end
		self.WaitSince = nil
		return
	end

	local now = os.clock()
	if now < self.NextAt then return end

	if self.Phase == "npc" or self.Phase == "talk" or self.Phase == "accept"
		or self.Phase == "waitAccept" or self.Phase == "return" or self.Phase == "finished" then
		local npc = self:KonaRoot()
		local ev = farmGetSignal()
		if not npc or not ev then
			if not npc then TP.ApproachSaved(root, "Kona") end
			self.NextAt = now + 1
			self:Status("Quest 4 • รอ Kona")
			return
		end
		if self.Phase ~= "waitAccept" and (root.Position - npc.Position).Magnitude > 8 then
			self:WarpToKona(npc)
			if self.Phase == "npc" then self.Phase = "talk"
			elseif self.Phase == "return" then self.Phase = "finished" end
			self.NextAt = now + 0.4
			self:Status("Quest 4 • วาปไป Kona")
			return
		end
		if self.Phase == "npc" then self.Phase = "talk"
		elseif self.Phase == "return" then self.Phase = "finished" end
		if self.Phase == "talk" then
			pcall(function() ev:FireServer("NpcTalking", "Ended") end)
			self.Phase, self.NextAt = "accept", now + 0.25
		elseif self.Phase == "accept" then
			local ok = pcall(function() ev:FireServer("AddQuest", "Ill find the pages") end)
			if not ok then self.NextAt = now + 1; return end
			self.AcceptSentAt, self.AcceptDeadline = now, now + 3
			self.Phase, self.NextAt = "waitAccept", now + 0.4
			self:Status("Quest 4 • ส่งคำขอเควสแล้ว รอระบบตอบ")
		elseif self.Phase == "waitAccept" then
			if now >= self.AcceptDeadline then
				self.Phase, self.NextAt = "page", now + 0.3
				self:Status("Quest 4 • เริ่มเก็บ Lost Page1 • 0/5")
			end
		elseif self.Phase == "finished" then
			self:SetEnabled(false)
			self:Status("กลับ Kona แล้ว หยุด Quest 4")
		end
		return
	end

	if self.Phase == "hold" then
		self:Release()
		self.Phase, self.NextAt = "verify", now + 0.6
		return
	elseif self.Phase == "verify" then
		if self.Target and not self.Target:IsDescendantOf(workspace) and not self.Picked[self.Target] then
			self.Picked[self.Target] = true
			self.Collected += 1
			self.Index += 1
			self.Attempts, self.WaitSince, self.Target = 0, nil, nil
			self.Phase = self.Collected >= 5 and "return" or "page"
			self:Status("Quest 4 • Kona • " .. self.Collected .. "/5")
			self.NextAt = now + 0.25
		elseif self.Attempts >= 4 then
			local name = "Lost Page" .. self.Index
			self:SetEnabled(false)
			self:Status("Quest 4 • ยังยืนยันการเก็บ " .. name .. " ไม่ได้")
		else
			self.Phase, self.NextAt = "page", now + 0.9
		end
		return
	end

	local page = self:FindPage(self.Index)
	if not page or self.Picked[page] then
		self.WaitSince = self.WaitSince or now
		self.NextAt = now + 1
		self:Status("Quest 4 • รอ Lost Page" .. self.Index)
		if now - self.WaitSince >= 20 then
			self:SetEnabled(false)
			self:Status("Quest 4 • ไม่พบ Lost Page" .. self.Index .. " ไม่ได้นับว่าเก็บแล้ว")
		end
		return
	end
	self.WaitSince = nil

	if self.Phase == "page" then
		self.Target = page
		self:WarpToPage(page)
		self.Phase, self.NextAt = "press", now + 0.35
		self:Status("Quest 4 • วาปไป Lost Page" .. self.Index)
	elseif self.Phase == "press" then
		local pageCf = farmCFrameOf(page)
		if page ~= self.Target or not pageCf or (root.Position - pageCf.Position).Magnitude > 6 then
			self.Phase = "page"
			return
		end
		local ok, err = pcall(function()
			local input = game:GetService("VirtualInputManager")
			self.Held = { Input = input }
			self.Attempts += 1
			input:SendKeyEvent(true, Enum.KeyCode.T, false, game)
		end)
		if not ok then
			self:SetEnabled(false)
			Farm._lastRuntimeError = tostring(err)
			self:Status("Quest 4 • ส่งปุ่ม T ไม่สำเร็จ")
			return
		end
		self.Phase, self.NextAt = "hold", now + 1
		self:Status("Quest 4 • เก็บ Lost Page" .. self.Index .. " • " .. self.Collected .. "/5")
	end
end

Farm.StopPages = function() if PagesQuest.Enabled then PagesQuest:SetEnabled(false) end end
PagesQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() PagesQuest:Step() end)
	if not ok then
		PagesQuest:SetEnabled(false)
		Farm._lastRuntimeError = tostring(err)
		PagesQuest:Status("Quest 4 • ERROR: " .. tostring(err))
	end
end)

--------------------------------------------------------------
-- QUEST 5 — Lucy / Tom / Bear Cub x4
--------------------------------------------------------------
local BearQuest = {
	Enabled = false, Phase = "lucy", NextAt = 0,
	Kills = 0, RequiredKills = 4, TotalKills = 0,
	RequiredMeat = 2, TomRuns = 0,
	Character = nil, Root = nil,
	Watchers = {}, Counted = {},
	Target = nil,
	AcceptSentAt = 0, AcceptDeadline = 0,
}

function BearQuest:Status(message)
	if self.Label and self.Label.Parent then self.Label.Text = message end
end

function BearQuest:SetEnabled(on)
	if self.Enabled == on then return end
	if on then
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
		if KazuQuest.Enabled then KazuQuest:SetEnabled(false) end
		if DeliveryQuest.Enabled then DeliveryQuest:SetEnabled(false) end
		if PagesQuest.Enabled then PagesQuest:SetEnabled(false) end
	end
	self.Enabled, Farm._bearBusy = on, on
	if on then
		self.SavedFarm = { MobName = Farm.MobName, BossEnabled = Farm.BossEnabled, AutoQuest = Farm.AutoQuest, AutoAttack = Farm.AutoAttack }
		farmSet(false, true)
		Farm.MobName, Farm.BossEnabled, Farm.AutoQuest, Farm.AutoAttack = "Bear Cub", false, false, true
	else
		farmSet(false, true)
		if self.SavedFarm then
			Farm.MobName, Farm.BossEnabled = self.SavedFarm.MobName, self.SavedFarm.BossEnabled
			Farm.AutoQuest, Farm.AutoAttack = self.SavedFarm.AutoQuest, self.SavedFarm.AutoAttack
		end
		self.SavedFarm = nil
	end
	self.Phase, self.NextAt, self.Character, self.Root = "lucy", 0, nil, nil
	self.Target, self.AcceptSentAt, self.AcceptDeadline = nil, 0, 0
	if on then
		self.Kills, self.TotalKills, self.TomRuns = 0, 0, 0
		self.Watchers, self.Counted = {}, {}
	end
	self:ClearWatchers()
	if self.Setter then self.Setter(on, false) end
	BossLoot:Reset(); FarmRetreat:Stop(); CombatRuntime:Release()
	farmResetQuest(on and "bear quest started" or "bear quest stopped")
	self:Status(on and "Quest 5 • เริ่มที่ Lucy • Tom 2 รอบ x 4 ตัว" or "Quest 5 • OFF")
end

function BearQuest:ClearWatchers()
	for _, record in pairs(self.Watchers) do
		for _, connection in ipairs(record.Connections) do connection:Disconnect() end
	end
	self.Watchers = {}
end

function BearQuest:LucyRoot()
	local node = workspace
	for _, key in ipairs({ "Debree", "Regions", "Windy Peak", "StationaryNpcs", "Lucy", "HumanoidRootPart" }) do
		node = node and node:FindFirstChild(key)
		if not node then return nil end
	end
	return node and node:IsA("BasePart") and node or nil
end

function BearQuest:TomRoot()
	local node = workspace
	for _, key in ipairs({ "Debree", "Regions", "Bamboo Grove", "StationaryNpcs", "Tom", "HumanoidRootPart" }) do
		node = node and node:FindFirstChild(key)
		if not node then return nil end
	end
	return node and node:IsA("BasePart") and node or nil
end

function BearQuest:BearFolder()
	local humanoids = workspace:FindFirstChild("Humanoids")
	local regions = humanoids and humanoids:FindFirstChild("Regions")
	local grove = regions and regions:FindFirstChild("Bamboo Grove")
	return grove and grove:FindFirstChild("ActiveNpcs")
end

-- อ่านจำนวน Bear Meat จาก objective บนหน้าจอ เช่น "Acquire Bear Meat 1/2"
-- และ fallback ไปที่ข้อความไอเทม เช่น "Cooked Bear Meat x2"
function BearQuest:ReadBearMeatCount()
	local best = nil
	for _, node in ipairs(playerGui:GetDescendants()) do
		if node:IsA("TextLabel") or node:IsA("TextButton") then
			local txt = tostring(node.Text or "")
			local lower = txt:lower()
			if lower:find("acquire bear meat", 1, true) then
				local current = tonumber(txt:match("(%d+)%s*/%s*%d+"))
				if current then best = math.max(best or 0, current) end
			elseif lower:find("bear meat", 1, true) then
				local amount = tonumber(txt:match("[xX]%s*(%d+)"))
				if amount then best = math.max(best or 0, amount) end
			end
		end
	end

	local function scanContainer(container)
		if not container then return 0 end
		local total = 0
		for _, node in ipairs(container:GetDescendants()) do
			local lower = node.Name:lower()
			if lower == "cooked bear meat" or lower == "bear meat" then
				local parentName = node.Parent and node.Parent.Name:lower() or ""
				if parentName ~= "cooked bear meat" and parentName ~= "bear meat" then
					local amount
					for _, attr in ipairs({ "Amount", "Count", "Quantity", "Stack", "StackCount" }) do
						local value = node:GetAttribute(attr)
						if type(value) == "number" then amount = math.max(amount or 0, value) end
					end
					for _, child in ipairs(node:GetChildren()) do
						if (child:IsA("IntValue") or child:IsA("NumberValue"))
							and table.find({ "amount", "count", "quantity", "stack", "stackcount" }, child.Name:lower()) then
							amount = math.max(amount or 0, child.Value)
						end
					end
					total += amount or 1
				end
			end
		end
		return total
	end

	local inventoryTotal = scanContainer(player.Character) + scanContainer(player:FindFirstChildOfClass("Backpack"))
	if inventoryTotal > 0 then best = math.max(best or 0, inventoryTotal) end
	return best
end

function BearQuest:FindBear()
	local folder = self:BearFolder()
	if not folder then return nil end
	local best, bestDist
	local hrp = self.Character and self.Character:FindFirstChild("HumanoidRootPart")
	local origin = hrp and hrp.Position
	for _, item in ipairs(folder:GetDescendants()) do
		if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
			local node = item.Parent
			local matched = false
			while node and node ~= folder do
				if node.Name == "Bear Cub" then matched = true; break end
				node = node.Parent
			end
			if matched and item.Parent then
				local hum = item.Parent:FindFirstChildWhichIsA("Humanoid", true)
				if hum and hum.Health > 0 then
					local d = origin and (item.Position - origin).Magnitude or 0
					if not bestDist or d < bestDist then
						best, bestDist = item.Parent, d
					end
				end
			end
		end
	end
	return best
end

function BearQuest:WarpToPart(part)
	local char = self.Character
	if not char or not part then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local stand = (part.CFrame * CFrame.new(0, 0, -3)).Position
	root.CFrame = CFrame.lookAt(stand, part.Position)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

function BearQuest:WarpToBear(bear)
	local char = self.Character
	if not char or not bear then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local bhrp = bear:FindFirstChild("HumanoidRootPart")
	if not root or not bhrp then return end
	local pos = bhrp.Position - Vector3.new(0, 3, 0)
	root.CFrame = CFrame.lookAt(pos + Vector3.new(0, 0, 3), bhrp.Position)
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

function BearQuest:Track(mob, beforeHealth)
	if not self.Enabled or self.Phase ~= "fight" then return end
	if not mob or not mob.Parent or self.Kills >= self.RequiredKills then return end
	local hum = mob:FindFirstChildWhichIsA("Humanoid", true)
	if not hum or self.Counted[hum] then return end

	local record = self.Watchers[hum]
	if record then
		if type(beforeHealth) == "number" and beforeHealth > 0 then
			record.HitObserved = true
			record.LastHealth = math.max(record.LastHealth or 0, beforeHealth)
		end
		return
	end
	if type(beforeHealth) ~= "number" then beforeHealth = hum.Health end
	if beforeHealth <= 0 or hum.Health <= 0 then return end

	record = {
		Connections = {},
		Character = self.Character,
		HitObserved = true,
		LastHealth = beforeHealth,
	}
	self.Watchers[hum] = record

	local function confirmDeath()
		if not self.Enabled or self.Phase ~= "fight" or self.Watchers[hum] ~= record
			or self.Counted[hum] or not record.HitObserved or hum.Health > 0 then return end
		self.Counted[hum] = true
		self.Watchers[hum] = nil
		for _, connection in ipairs(record.Connections) do connection:Disconnect() end
		self.Kills += 1
		self.TotalKills += 1
		self:Status("Quest 5 • Bear Cub ตาย " .. self.Kills .. "/" .. self.RequiredKills
			.. " • รวม " .. self.TotalKills)

		if self.Kills >= self.RequiredKills then
			self.Phase = "tom"
			self.NextAt = 0
			Farm._bearBusy = true
			self.Target = nil
			Farm._attackTarget = nil
			CombatRuntime:Release()
			if Farm.Enabled then farmSet(false, true) end
			self:Status("Quest 5 • Bear Cub 4/4 • กลับไปรับเควส Tom ใหม่")
		end
	end

	table.insert(record.Connections, hum.HealthChanged:Connect(function(health)
		if self.Watchers[hum] ~= record then return end
		if health < (record.LastHealth or beforeHealth) then
			record.HitObserved = true
		end
		record.LastHealth = health
		if health <= 0 then confirmDeath() end
	end))
	table.insert(record.Connections, hum.Died:Connect(confirmDeath))
end

function BearQuest:PruneWatchers()
	for hum, record in pairs(self.Watchers) do
		if not hum.Parent then
			for _, connection in ipairs(record.Connections) do connection:Disconnect() end
			self.Watchers[hum] = nil
		elseif hum.Health <= 0 and record.HitObserved and not self.Counted[hum]
			and self.Phase == "fight" and self.Kills < self.RequiredKills then
			self.Counted[hum] = true
			for _, connection in ipairs(record.Connections) do connection:Disconnect() end
			self.Watchers[hum] = nil
			self.Kills += 1
			self.TotalKills += 1
			self:Status("Quest 5 • Bear Cub ตาย " .. self.Kills .. "/" .. self.RequiredKills
				.. " • รวม " .. self.TotalKills)
			if self.Kills >= self.RequiredKills then
				self.Phase = "tom"
				self.NextAt = 0
				Farm._bearBusy = true
				self.Target = nil
				Farm._attackTarget = nil
				CombatRuntime:Release()
				if Farm.Enabled then farmSet(false, true) end
				self:Status("Quest 5 • Bear Cub 4/4 • กลับไปรับเควส Tom ใหม่")
			end
		end
	end
end

function BearQuest:Drive()
	if self.Phase ~= "fight" then return end
	if self.Kills >= self.RequiredKills then return end
	-- The normal farm owns selection, movement, attacks and combo retreat.
	-- Kill tracking is driven by actual hit attempts through Farm.TrackBearDeath.
	Farm._bearBusy = false
end

function BearQuest:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then self:SetEnabled(false); return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if self.Character and (char ~= self.Character or root ~= self.Root or not hum or hum.Health <= 0) then
		self:SetEnabled(false)
		self:Status("ตัวละครเปลี่ยนหรือเสียชีวิต เปิด Quest 5 ใหม่เมื่อพร้อม")
		return
	end
	if not root or not hum or hum.Health <= 0 then self:Status("รอตัวละครพร้อม"); return end
	self.Character, self.Root = char, root

	self:PruneWatchers()
	if self.Phase ~= "fight" then
		Farm._bearBusy = true
		if Farm.Enabled then farmSet(false, true) end
	end

	if attackInputBlocked() then return end

	local now = os.clock()
	if now < self.NextAt then return end

	if self.Phase == "lucy" or self.Phase == "talkLucy" or self.Phase == "acceptLucy" or self.Phase == "waitAcceptLucy" then
		local npc = self:LucyRoot()
		local ev = farmGetSignal()
		if not npc or not ev then
			if not npc then TP.ApproachSaved(root, "Lucy") end
			self.NextAt = now + 1
			self:Status("Quest 5 • รอ Lucy")
			return
		end
		if self.Phase ~= "waitAcceptLucy" and (root.Position - npc.Position).Magnitude > 8 then
			self:WarpToPart(npc)
			if self.Phase == "lucy" then self.Phase = "talkLucy" end
			self.NextAt = now + 0.4
			self:Status("Quest 5 • วาปไป Lucy")
			return
		end
		if self.Phase == "lucy" then self.Phase = "talkLucy" end
		if self.Phase == "talkLucy" then
			pcall(function() ev:FireServer("NpcTalking", "Ended") end)
			self.Phase, self.NextAt = "acceptLucy", now + 0.25
		elseif self.Phase == "acceptLucy" then
			local ok = pcall(function() ev:FireServer("AddQuest", "Ill restock the pantry(Lv 10)") end)
			if not ok then self.NextAt = now + 1; return end
			-- After Lucy accepts the pantry quest, go straight to Tom.
			self.AcceptSentAt, self.AcceptDeadline = now, now + 0.35
			self.Phase, self.NextAt = "tom", now + 0.25
			self:Status("Quest 5 • รับเควส Lucy แล้ว • วาปไป Tom")
		elseif self.Phase == "waitAcceptLucy" then
			self.Phase, self.NextAt = "tom", now + 0.1
			self:Status("Quest 5 • ไปหา Tom")
		end
		return
	end

	if self.Phase == "tom" or self.Phase == "talkTom" or self.Phase == "acceptTom" or self.Phase == "waitAcceptTom" then
		local npc = self:TomRoot()
		local ev = farmGetSignal()
		if not npc or not ev then
			if not npc then TP.ApproachSaved(root, "Tom") end
			self.NextAt = now + 1
			self:Status("Quest 5 • รอ Tom")
			return
		end
		if self.Phase ~= "waitAcceptTom" and (root.Position - npc.Position).Magnitude > 8 then
			self:WarpToPart(npc)
			if self.Phase == "tom" then self.Phase = "talkTom" end
			self.NextAt = now + 0.4
			self:Status("Quest 5 • วาปไป Tom")
			return
		end
		if self.Phase == "tom" then self.Phase = "talkTom" end
		if self.Phase == "talkTom" then
			pcall(function() ev:FireServer("NpcTalking", "Ended") end)
			self.Phase, self.NextAt = "acceptTom", now + 0.25
		elseif self.Phase == "acceptTom" then
			local ok = pcall(function()
				ev:FireServer("AddQuest", "Ill drive the bears back(Lv 10)")
				task.wait(0.12)
				ev:FireServer("QuestProgress", "Ill restock the pantry(Lv 10)", "Go talk to Tom")
			end)
			if not ok then self.NextAt = now + 1; return end
			self.AcceptSentAt, self.AcceptDeadline = now, now + 0.6
			self.Phase, self.NextAt = "waitAcceptTom", now + 0.2
			self:Status("Quest 5 • รับเควส Tom + อัปเดต Go talk to Tom แล้ว")
		elseif self.Phase == "waitAcceptTom" then
			if now >= self.AcceptDeadline then
				self.TomRuns += 1
				self.Kills = 0
				self.Counted = {}
				self:ClearWatchers()
				self.Phase, self.NextAt = "fight", now + 0.15
				Farm._bearBusy = false
				farmSet(true, true)
				self:Status("Quest 5 • Tom รอบ " .. self.TomRuns .. " • Bear Cub 0/" .. self.RequiredKills)
			end
		end
		return
	end

	if self.Phase == "fight" then
		-- Each Tom round is exactly 4 Bear Cub kills.
		-- Meat count is not used to end the round early.
		self:Drive()
		return
	end

	if self.Phase == "returnLucy" then
		local npc = self:LucyRoot()
		local ev = farmGetSignal()
		if not npc or not ev then
			if not npc then TP.ApproachSaved(root, "Lucy") end
			self.NextAt = now + 1
			self:Status("Quest 5 • วาปกลับ Lucy")
			return
		end
		if (root.Position - npc.Position).Magnitude > 8 then
			self:WarpToPart(npc)
			self.NextAt = now + 0.4
			self:Status("Quest 5 • วาปกลับ Lucy")
			return
		end
		pcall(function() ev:FireServer("NpcTalking", "Ended") end)

		if self.TomRuns < 2 then
			-- First 4-kill round submitted to Lucy: go back to Tom,
			-- accept the bear quest again, kill another 4, then return once more.
			self.Kills = 0
			self.Target = nil
			self.Counted = {}
			self:ClearWatchers()
			self.Phase, self.NextAt = "tom", now + 0.25
			self:Status("Quest 5 • ส่ง Lucy รอบ 1 แล้ว • กลับไปรับ Tom รอบ 2")
		else
			self:SetEnabled(false)
			self:Status("Quest 5 • ส่ง Lucy รอบ 2 แล้ว • DONE")
		end
	end
end

Farm.TrackBearDeath = function(mob, beforeHealth) BearQuest:Track(mob, beforeHealth) end
Farm.StopBear = function() if BearQuest.Enabled then BearQuest:SetEnabled(false) end end
BearQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() BearQuest:Step() end)
	if not ok then
		BearQuest:SetEnabled(false)
		Farm._lastRuntimeError = tostring(err)
		BearQuest:Status("Quest 5 • ERROR: " .. tostring(err))
	end
end)

--------------------------------------------------------------
-- THUNDER BREATHING TRAINING — Zentaro
--------------------------------------------------------------
local ThunderBreathing = {
	Enabled = false,
	Phase = "trainer",
	NextAt = 0,
	Held = nil,
	Character = nil,
	Root = nil,
	TrainingPosition = Vector3.new(-1885.1500244140625, 315.2499694824219, 34.36198425292969),
	Clicks = 0,
	Armed = true,
	LastClickAt = 0,
	LastSeenAt = 0,
	NextScanAt = 0,
	LastPairKey = nil,
	Progress = 0,
}

function ThunderBreathing:Status(message)
	if self.Label and self.Label.Parent then self.Label.Text = message end
end

function ThunderBreathing:ReleaseT()
	local held = self.Held
	self.Held = nil
	if held then
		pcall(function() held.Input:SendKeyEvent(false, Enum.KeyCode.T, false, game) end)
	end
end

function ThunderBreathing:SetEnabled(on)
	if self.Enabled == on then return end
	if on then
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
		if KazuQuest.Enabled then KazuQuest:SetEnabled(false) end
		if DeliveryQuest.Enabled then DeliveryQuest:SetEnabled(false) end
		if PagesQuest.Enabled then PagesQuest:SetEnabled(false) end
		if BearQuest.Enabled then BearQuest:SetEnabled(false) end
		farmSet(false, true)
		Farm._storyBusy = true
	else
		Farm._storyBusy = false
	end
	self:ReleaseT()
	self.Enabled = on
	self.Phase, self.NextAt = "trainer", 0
	self.Character, self.Root = nil, nil
	self.Clicks, self.Armed = 0, true
	self.LastClickAt, self.LastSeenAt, self.NextScanAt = 0, 0, 0
	self.LastPairKey, self.Progress = nil, 0
	if self.Setter then self.Setter(on, false) end
	BossLoot:Reset()
	FarmRetreat:Stop()
	CombatRuntime:Release()
	farmResetQuest(on and "thunder breathing started" or "thunder breathing stopped")
	self:Status(on and "ปราณสายฟ้า • ไปหา Zentaro" or "ปราณสายฟ้า • OFF")
end

function ThunderBreathing:GuiVisible(obj)
	if not obj or not obj:IsA("GuiObject") or not obj.Visible then return false end
	-- Never inspect Mazxhub's own UI; only scan the game's minigame UI.
	if obj:IsDescendantOf(gui) then return false end
	local node = obj.Parent
	while node and node ~= playerGui do
		if node:IsA("GuiObject") and not node.Visible then return false end
		if node:IsA("LayerCollector") and not node.Enabled then return false end
		node = node.Parent
	end
	return obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
end

function ThunderBreathing:GuiColor(obj)
	if not obj or not obj:IsA("GuiObject") then return nil end
	if obj.BackgroundTransparency < 0.9 then return obj.BackgroundColor3 end
	if (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.ImageTransparency < 0.9 then
		return obj.ImageColor3
	end
	return nil
end

function ThunderBreathing:CommonTimingContainer(a, b)
	local node = a and a.Parent
	while node and node ~= playerGui do
		if node:IsA("GuiObject") and b:IsDescendantOf(node) then
			local size = node.AbsoluteSize
			if size.X >= 120 and size.X <= 800 and size.Y >= 12 and size.Y <= 140 then
				return node
			end
		end
		node = node.Parent
	end
	return nil
end

function ThunderBreathing:FindTimingPair()
	local markers, targets = {}, {}
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if obj:IsA("GuiObject") and self:GuiVisible(obj) then
			local color = self:GuiColor(obj)
			if color then
				local size = obj.AbsoluteSize
				local r, g, b = color.R, color.G, color.B
				local nearWhite = r >= 0.72 and g >= 0.72 and b >= 0.72
				local yellow = r >= 0.68 and g >= 0.52 and b <= 0.62 and r >= b + 0.10
				local blue = b >= 0.58 and g >= 0.45 and b >= r + 0.04
				local cyan = g >= 0.62 and b >= 0.62 and r <= math.max(g, b) - 0.04
				local markerShape = size.X >= 8 and size.X <= 70 and size.Y >= 8 and size.Y <= 70
					and (size.X / math.max(size.Y, 1)) >= 0.45
					and (size.X / math.max(size.Y, 1)) <= 2.2
				if markerShape and (blue or cyan or nearWhite) then
					table.insert(markers, { Obj = obj, Blue = blue or cyan })
				end

				-- Different rounds use slightly different target visuals. Support
				-- a thin vertical line as well as a wider white/gold hit zone.
				local thinLine = size.X >= 1 and size.X <= 22 and size.Y >= 6 and size.Y <= 100
				local hitZone = size.X >= 8 and size.X <= 150 and size.Y >= 4 and size.Y <= 45
				if (thinLine or hitZone) and (yellow or nearWhite) then
					table.insert(targets, {
						Obj = obj,
						Yellow = yellow,
						Thin = thinLine,
					})
				end
			end
		end
	end

	local bestMarker, bestTarget, bestContainer, bestScore
	for _, marker in ipairs(markers) do
		local mp, ms = marker.Obj.AbsolutePosition, marker.Obj.AbsoluteSize
		local mx, my = mp.X + ms.X * 0.5, mp.Y + ms.Y * 0.5
		for _, target in ipairs(targets) do
			if target.Obj ~= marker.Obj then
				local tp, ts = target.Obj.AbsolutePosition, target.Obj.AbsoluteSize
				local tx, ty = tp.X + ts.X * 0.5, tp.Y + ts.Y * 0.5
				local dy = math.abs(my - ty)
				local dx = math.abs(mx - tx)
				-- Do not require both objects to have the exact same GUI parent.
				-- Some minigame rounds rebuild the marker/target in separate frames.
				if dy <= math.max(38, ms.Y * 1.6) and dx <= 900 then
					local container = self:CommonTimingContainer(marker.Obj, target.Obj)
					local score = (target.Yellow and 75 or 38)
						+ (target.Thin and 35 or 0)
						+ (marker.Blue and 28 or 0)
						+ (container and 55 or 0)
						- dy * 2 - dx * 0.004
					if not bestScore or score > bestScore then
						bestMarker, bestTarget, bestContainer, bestScore =
							marker.Obj, target.Obj, container, score
					end
				end
			end
		end
	end
	return bestMarker, bestTarget, bestContainer
end

function ThunderBreathing:ReadProgress()
	local best
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and self:GuiVisible(obj) then
			local value = tonumber(tostring(obj.Text or ""):match("(%d+)%s*%%"))
			if value and value >= 0 and value <= 100 then
				best = math.max(best or 0, value)
			end
		end
	end
	if best then self.Progress = math.max(self.Progress or 0, best) end
	return self.Progress
end

function ThunderBreathing:ClickTiming(target, container)
	local input = game:GetService("VirtualInputManager")
	local tp, ts = target.AbsolutePosition, target.AbsoluteSize
	local x = math.floor(tp.X + ts.X * 0.5)
	local y = math.floor(tp.Y + ts.Y * 0.5)
	input:SendMouseButtonEvent(x, y, 0, true, game, 0)
	task.delay(0.018, function()
		pcall(function() input:SendMouseButtonEvent(x, y, 0, false, game, 0) end)
	end)
end

function ThunderBreathing:TimingStep(now)
	if now < self.NextScanAt then return end
	self.NextScanAt = now + 0.008

	local progress = self:ReadProgress()
	if progress and progress >= 100 and self.Clicks > 0 then
		self:SetEnabled(false)
		self:Status("ปราณสายฟ้า • 100% • DONE")
		return
	end

	local marker, target, container = self:FindTimingPair()
	if not marker or not target then
		-- Re-arm quickly between rounds. This is important when the game reuses
		-- the same GUI objects for the next timing check.
		if self.LastSeenAt > 0 and now - self.LastSeenAt > 0.08 then
			self.Armed = true
			self.LastPairKey = nil
			self:Status("ปราณสายฟ้า • " .. tostring(progress or 0) .. "% • รอมินิเกมถัดไป")
		end
		return
	end

	self.LastSeenAt = now
	local pairKey = tostring(marker) .. "|" .. tostring(target)
	if pairKey ~= self.LastPairKey then
		self.LastPairKey = pairKey
		self.Armed = true
	end

	local mp, ms = marker.AbsolutePosition, marker.AbsoluteSize
	local tp, ts = target.AbsolutePosition, target.AbsoluteSize
	local markerLeft, markerRight = mp.X, mp.X + ms.X
	local targetLeft, targetRight = tp.X, tp.X + ts.X
	-- Use rectangle overlap instead of only the marker center. This gives a
	-- wider timing window and catches fast rounds that previously slipped past.
	local tolerance = math.max(5, math.min(16, ms.X * 0.45))
	local inside = markerRight >= targetLeft - tolerance
		and markerLeft <= targetRight + tolerance

	if not inside then
		self.Armed = true
		self:Status("ปราณสายฟ้า • " .. tostring(progress or 0) .. "% • ตรวจจับต่อเนื่อง")
		return
	end
	if not self.Armed or now - self.LastClickAt < 0.065 then return end

	self.Armed = false
	self.LastClickAt = now
	self.Clicks += 1
	self:ClickTiming(target, container)
	self:Status("ปราณสายฟ้า • " .. tostring(progress or 0) .. "% • คลิก #" .. self.Clicks .. " • ตรวจต่อจนจบ")
end

function ThunderBreathing:TrainingCFrame()
	-- Use Zentaro's live facing direction and stand directly in front of him,
	-- instead of warping to the old fixed training coordinate.
	local npc = tpFindNPC("Thunder Trainer Zentaro")
	local npcRoot = npc and (npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart", true))
	if npcRoot and npcRoot:IsA("BasePart") then
		local front = (npcRoot.CFrame * CFrame.new(0, 0, -5)).Position
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = player.Character and { player.Character, npc } or { npc }
		params.IgnoreWater = true

		local result = workspace:Raycast(front + Vector3.new(0, 12, 0), Vector3.new(0, -40, 0), params)
		local safePos = result and Vector3.new(front.X, result.Position.Y + 3.2, front.Z)
			or (front + Vector3.new(0, 3, 0))
		local lookAt = Vector3.new(npcRoot.Position.X, safePos.Y, npcRoot.Position.Z)
		return CFrame.lookAt(safePos, lookAt)
	end

	-- Fallback only if Zentaro has not loaded yet.
	local cf = TP.Destination("Thunder Trainer Zentaro")
	return cf and (cf * CFrame.new(0, 0, -5)) or CFrame.new(self.TrainingPosition + Vector3.new(0, 5, 0))
end

function ThunderBreathing:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then self:SetEnabled(false); return end
	local now = os.clock()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if self.Character and (char ~= self.Character or root ~= self.Root or not hum or hum.Health <= 0) then
		self:ReleaseT()
		self.Character, self.Root = char, root
		self.Phase, self.NextAt = "trainer", 0
	end
	if not root or not hum or hum.Health <= 0 then self:Status("ปราณสายฟ้า • รอตัวละครพร้อม"); return end
	self.Character, self.Root = char, root
	if attackInputBlocked() then
		if self.Held then self:ReleaseT(); self.Phase, self.NextAt = "pressT", now + 0.5 end
		return
	end
	if now < self.NextAt then return end

	if self.Phase == "trainer" then
		local cf = TP.Destination("Thunder Trainer Zentaro")
		if not cf then self.NextAt = now + 1; self:Status("ปราณสายฟ้า • รอ Zentaro"); return end
		tpSafeGo(cf)
		self.Phase, self.NextAt = "talk", now + 0.45
		self:Status("ปราณสายฟ้า • วาปไป Zentaro")
		return
	elseif self.Phase == "talk" then
		local ev = farmGetSignal()
		if not ev then self.NextAt = now + 1; return end
		ev:FireServer("NpcTalking", "Ended")
		self.Phase, self.NextAt = "accept", now + 0.2
		return
	elseif self.Phase == "accept" then
		local ev = farmGetSignal()
		if not ev then self.NextAt = now + 1; return end
		ev:FireServer("AddQuest", "Ill learn Thunder Breathing(Lv 25)")
		self.Phase, self.NextAt = "trainingSpot", now + 0.35
		self:Status("ปราณสายฟ้า • รับเควสแล้ว")
		return
	elseif self.Phase == "trainingSpot" then
		tpSafeGo(self:TrainingCFrame())
		-- The training starts after arriving at the spot; do not press T
		-- or send any other activation key here.
		self:ReleaseT()
		self.Phase, self.NextAt = "minigame", now + 0.55
		self:Status("ปราณสายฟ้า • ถึงจุดฝึก • รอมินิเกม")
		return
	elseif self.Phase == "minigame" then
		self:TimingStep(now)
	end
end

--------------------------------------------------------------
-- CUP GAME — track Cup2 through shuffle and open it when shuffle stops
--------------------------------------------------------------
local CupGame = {
	Enabled = false,
	Highlight = nil,
	Target = nil,
	NextAt = 0,
}

function CupGame:Status(message, color)
	if self.Label and self.Label.Parent then
		self.Label.Text = message
		self.Label.TextColor3 = color or T.Mint
	end
end

function CupGame:Cup2()
	local training = workspace:FindFirstChild("Training")
	local gameFolder = training and training:FindFirstChild("Cup Game")
	local cupgame = gameFolder and gameFolder:FindFirstChild("Cupgame1")
	local cups = cupgame and cupgame:FindFirstChild("Cups")
	return cups and cups:FindFirstChild("Cup2") or nil
end

function CupGame:ClearHighlight()
	if self.Highlight then pcall(function() self.Highlight:Destroy() end) end
	self.Highlight, self.Target = nil, nil
end

function CupGame:ApplyHighlight(target)
	if not target then
		self:ClearHighlight()
		return
	end
	if self.Target ~= target or not self.Highlight or not self.Highlight.Parent then
		self:ClearHighlight()
		local hl = Instance.new("Highlight")
		hl.Name = "MazxCup2ESP"
		hl.Adornee = target
		hl.FillTransparency = 1
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = target
		self.Highlight, self.Target = hl, target
	end
	self.Highlight.Enabled = self.Enabled
end

function CupGame:SetEnabled(on)
	on = on == true
	if self.Enabled == on then return end
	self.Enabled = on
	self.NextAt = 0
	if not on then
		self:ClearHighlight()
		self:Status("Cup2 ESP • OFF", T.Sub)
	else
		self:Status("Cup2 ESP • รอ Cup2", T.Gold)
	end
end

function CupGame:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		self:SetEnabled(false)
		return
	end
	local now = os.clock()
	if now < self.NextAt then return end
	self.NextAt = now + 0.08

	local target = self:Cup2()
	if not target then
		self:ClearHighlight()
		self:Status("Cup2 ESP • รอ workspace.Training[\"Cup Game\"].Cupgame1.Cups.Cup2", T.Gold)
		return
	end

	self:ApplyHighlight(target)
	self:Status("Cup2 ESP • Outline สีขาว", T.Mint)
end

CupGame.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() CupGame:Step() end)
	if not ok then
		Farm._lastRuntimeError = tostring(err)
		CupGame:Status("Cup2 ESP • ERROR: " .. tostring(err), T.Danger)
	end
end)

--------------------------------------------------------------
-- PUSHUPS — auto click the white timing circles
--------------------------------------------------------------
local AutoPushups = {
	Enabled = false,
	NextAt = 0,
	LastClickAt = 0,
	Clicks = 0,
	Progress = 0,
	StartTried = false,
	Starting = false,
	LastStartAttempt = -math.huge,
	PromptState = setmetatable({}, { __mode = "k" }),
	RingState = setmetatable({}, { __mode = "k" }),
}

function AutoPushups:Status(message, color)
	if self.Label and self.Label.Parent then
		self.Label.Text = message
		self.Label.TextColor3 = color or T.Mint
	end
end

function AutoPushups:TrainingPrompt()
	local training = workspace:FindFirstChild("Training")
	local pushups = training and training:FindFirstChild("Pushups")
	local mat = pushups and pushups:FindFirstChild("PushupMat1")
	local root = mat and mat:FindFirstChild("Root")
	local prompt = root and root:FindFirstChild("ProximityPrompt")
	return prompt, root, pushups
end

function AutoPushups:StartTraining()
	if self.Starting then return false, "starting" end
	self.Starting = true
	self.LastStartAttempt = os.clock()

	local prompt, promptRoot = self:TrainingPrompt()
	if not prompt or not prompt:IsA("ProximityPrompt") then
		self.Starting = false
		return false, "Pushup ProximityPrompt not found"
	end
	if not promptRoot or not promptRoot:IsA("BasePart") then
		self.Starting = false
		return false, "PushupMat1.Root not found"
	end

	local stand = promptRoot.CFrame * CFrame.new(0, 3, -2.5)
	local warped = tpSafeGo(stand)
	if not warped then
		self.Starting = false
		return false, "cannot warp to PushupMat1"
	end
	task.wait(0.25)

	local attempted = false
	pcall(function()
		if fireproximityprompt then
			attempted = true
			fireproximityprompt(prompt)
		end
	end)
	pcall(function()
		attempted = true
		prompt:InputHoldBegin()
		task.wait(math.max(0.05, tonumber(prompt.HoldDuration) or 0) + 0.08)
		prompt:InputHoldEnd()
	end)

	local key = prompt.KeyboardKeyCode
	if key ~= Enum.KeyCode.Unknown then
		pcall(function()
			attempted = true
			local input = game:GetService("VirtualInputManager")
			input:SendKeyEvent(true, key, false, game)
			task.wait(math.max(0.08, tonumber(prompt.HoldDuration) or 0) + 0.08)
			input:SendKeyEvent(false, key, false, game)
		end)
	end

	self.Starting = false
	return attempted, attempted and nil or "cannot trigger ProximityPrompt"
end

function AutoPushups:GuiVisible(obj)
	if not obj or not obj:IsA("GuiObject") or not obj.Visible then return false end
	if obj:IsDescendantOf(gui) then return false end
	local node = obj.Parent
	while node do
		if node:IsA("GuiObject") and not node.Visible then return false end
		if node:IsA("LayerCollector") and not node.Enabled then return false end
		node = node.Parent
	end
	return obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
end

function AutoPushups:GuiColor(obj)
	if not obj or not obj:IsA("GuiObject") then return nil end
	local strokeObj = obj:FindFirstChildOfClass("UIStroke")
	if strokeObj and strokeObj.Enabled and strokeObj.Transparency < 0.98 then
		return strokeObj.Color
	end
	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		if obj.ImageTransparency < 0.98 then return obj.ImageColor3 end
	end
	if obj.BackgroundTransparency < 0.98 then return obj.BackgroundColor3 end
	return nil
end

function AutoPushups:IsWhite(obj)
	local c = self:GuiColor(obj)
	if not c then return false end
	local hi = math.max(c.R, c.G, c.B)
	local lo = math.min(c.R, c.G, c.B)
	return lo >= 0.56 and (hi - lo) <= 0.22
end

function AutoPushups:IsLightTarget(obj)
	local c = self:GuiColor(obj)
	if not c then return false end
	local hi = math.max(c.R, c.G, c.B)
	local lo = math.min(c.R, c.G, c.B)
	return lo >= 0.18 and (hi - lo) <= 0.34
end

function AutoPushups:IsRoundish(obj)
	local size = obj.AbsoluteSize
	if size.X < 8 or size.Y < 8 or size.X > 180 or size.Y > 180 then return false end
	local ratio = size.X / math.max(size.Y, 1)
	if ratio < 0.62 or ratio > 1.38 then return false end
	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then return true end
	if obj:FindFirstChildOfClass("UICorner") then return true end
	if obj:FindFirstChildOfClass("UIStroke") then return true end
	return false
end

function AutoPushups:SamePrompt(a, b)
	if a == b then return false end
	if a:IsDescendantOf(b) or b:IsDescendantOf(a) then return true end
	local ap, bp = a.Parent, b.Parent
	if ap and bp and ap == bp then return true end
	if ap and bp and ap.Parent and ap.Parent == bp.Parent then return true end
	return false
end

function AutoPushups:ScanObjects()
	local out, seen = {}, {}
	local roots = { playerGui }
	local _, _, pushups = self:TrainingPrompt()
	if pushups then table.insert(roots, pushups) end
	if workspace.CurrentCamera then table.insert(roots, workspace.CurrentCamera) end
	local coreGui = game:GetService("CoreGui")
	if coreGui then table.insert(roots, coreGui) end

	for _, root in ipairs(roots) do
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("GuiObject") and not seen[obj] then
				seen[obj] = true
				table.insert(out, obj)
			end
		end
	end
	return out
end

function AutoPushups:ReadProgress(objects)
	local best
	for _, obj in ipairs(objects or self:ScanObjects()) do
		if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and self:GuiVisible(obj) then
			local value = tonumber(tostring(obj.Text or ""):match("(%d+)%s*%%"))
			if value and value >= 0 and value <= 100 then
				best = math.max(best or 0, value)
			end
		end
	end
	if best then
		if best < (self.Progress or 0) - 30 then self.Progress = best
		else self.Progress = math.max(self.Progress or 0, best) end
	end
	return self.Progress or 0
end

function AutoPushups:FindPrompts(objects)
	local camera = workspace.CurrentCamera
	if not camera then return {}, {} end
	local viewport = camera.ViewportSize
	local outers, inners, whiteCandidates = {}, {}, {}

	for _, obj in ipairs(objects or self:ScanObjects()) do
		if obj:IsA("GuiObject") and self:GuiVisible(obj) and self:IsRoundish(obj) then
			local p, z = obj.AbsolutePosition, obj.AbsoluteSize
			local cx, cy = p.X + z.X * 0.5, p.Y + z.Y * 0.5
			if cx >= viewport.X * 0.035 and cx <= viewport.X * 0.965
				and cy >= viewport.Y * 0.08 and cy <= viewport.Y * 0.88 then
				if self:IsWhite(obj) then
					table.insert(outers, obj)
					table.insert(whiteCandidates, obj)
				end
				if self:IsLightTarget(obj) then table.insert(inners, obj) end
			end
		end
	end

	local rawPairs = {}
	for _, outer in ipairs(outers) do
		local op, os = outer.AbsolutePosition, outer.AbsoluteSize
		local ocx, ocy = op.X + os.X * 0.5, op.Y + os.Y * 0.5
		local outerD = math.max(os.X, os.Y)
		local bestInner, bestScore

		for _, inner in ipairs(inners) do
			if inner ~= outer then
				local ip, isz = inner.AbsolutePosition, inner.AbsoluteSize
				local innerD = math.max(isz.X, isz.Y)
				local icx, icy = ip.X + isz.X * 0.5, ip.Y + isz.Y * 0.5
				local centerDist = (Vector2.new(ocx, ocy) - Vector2.new(icx, icy)).Magnitude
				local ratio = outerD / math.max(innerD, 1)
				if centerDist <= math.max(18, innerD * 0.5)
					and ratio >= 0.65 and ratio <= 4.2 then
					local bonus = self:SamePrompt(outer, inner) and -25 or 0
					local score = centerDist * 4 + math.abs(ratio - 1.45) * 7 + bonus
					if not bestScore or score < bestScore then
						bestInner, bestScore = inner, score
					end
				end
			end
		end

		if bestInner then
			table.insert(rawPairs, {
				Outer = outer,
				Inner = bestInner,
				Score = bestScore or 999,
				Center = Vector2.new(ocx, ocy),
			})
		end
	end

	table.sort(rawPairs, function(a, b) return a.Score < b.Score end)
	local pairsFound, centers = {}, {}
	for _, pair in ipairs(rawPairs) do
		local duplicate = false
		for _, center in ipairs(centers) do
			if (pair.Center - center).Magnitude <= 22 then
				duplicate = true
				break
			end
		end
		if not duplicate then
			table.insert(centers, pair.Center)
			table.insert(pairsFound, pair)
		end
	end
	return pairsFound, whiteCandidates
end

function AutoPushups:ClickAt(x, y)
	local input = game:GetService("VirtualInputManager")
	local px, py = math.floor(x), math.floor(y)
	local ok = pcall(function()
		-- Move the synthetic cursor first. This minigame reads the current
		-- mouse position when InputBegan fires, not only the coordinates
		-- passed to SendMouseButtonEvent.
		input:SendMouseMoveEvent(px, py, game)
		task.wait(0.012)
		input:SendMouseButtonEvent(px, py, 0, true, game, 0)
		task.wait(0.025)
		input:SendMouseButtonEvent(px, py, 0, false, game, 0)
	end)
	if ok then return true end

	-- Fallback for executors where VIM mouse click is not accepted.
	local virtualUser = game:GetService("VirtualUser")
	return pcall(function()
		local camera = workspace.CurrentCamera
		local cameraCF = camera and camera.CFrame or CFrame.new()
		virtualUser:Button1Down(Vector2.new(px, py), cameraCF)
		task.wait(0.025)
		virtualUser:Button1Up(Vector2.new(px, py), cameraCF)
	end)
end

function AutoPushups:ClickObject(obj)
	if not obj or not obj.Parent then return false end
	local p, z = obj.AbsolutePosition, obj.AbsoluteSize
	return self:ClickAt(p.X + z.X * 0.5, p.Y + z.Y * 0.5)
end

function AutoPushups:SetEnabled(on)
	on = on == true
	if self.Enabled == on then return end
	self.Enabled = on
	self.NextAt = 0
	self.LastClickAt = 0
	self.Clicks = 0
	self.Progress = 0
	self.StartTried = false
	self.Starting = false
	self.LastStartAttempt = -math.huge
	self.PromptState = setmetatable({}, { __mode = "k" })
	self.RingState = setmetatable({}, { __mode = "k" })

	if on then
		task.defer(function()
			if not self.Enabled or self.StartTried then return end
			self.StartTried = true
			local ok, err = self:StartTraining()
			self:Status(ok and "Auto Pushups • เปิด PushupMat1 แล้ว • รอวงกลม"
				or ("Auto Pushups • " .. tostring(err)), ok and T.Mint or T.Gold)
		end)
	else
		self:Status("Auto Pushups • OFF", T.Sub)
	end
end

function AutoPushups:Step()
	if not self.Enabled then return end
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		self:SetEnabled(false)
		return
	end

	local now = os.clock()
	if now < self.NextAt then return end
	self.NextAt = now + 0.008

	local objects = self:ScanObjects()
	local progress = self:ReadProgress(objects)
	local prompts, whiteCandidates = self:FindPrompts(objects)
	local clicked = 0

	-- Preferred path: two separate circular GUI objects share the same center.
	for _, pair in ipairs(prompts) do
		local outer, inner = pair.Outer, pair.Inner
		if outer.Parent and inner.Parent then
			local outerD = math.max(outer.AbsoluteSize.X, outer.AbsoluteSize.Y)
			local innerD = math.max(inner.AbsoluteSize.X, inner.AbsoluteSize.Y)
			local diff = math.abs(outerD - innerD)
			local state = self.PromptState[outer]
			if not state then
				state = { Armed = true, LastDiff = math.huge, ClickedAt = 0 }
				self.PromptState[outer] = state
			end

			if diff >= math.max(18, innerD * 0.38) or diff > state.LastDiff + 5 then
				state.Armed = true
			end
			state.LastDiff = diff

			local tolerance = math.max(8, innerD * 0.24)
			if diff <= tolerance and state.Armed and now - state.ClickedAt >= 0.10 then
				if self:ClickObject(inner) then
					state.Armed = false
					state.ClickedAt = now
					self.LastClickAt = now
					self.Clicks += 1
					clicked += 1
				end
			end
		end
	end

	-- Fallback for the version shown in the video: the outer white ring can be
	-- one ImageLabel containing both circles. Track that single object's tween
	-- and click when it has shrunk to roughly half of its observed size.
	if clicked == 0 then
		for _, ring in ipairs(whiteCandidates) do
			if ring.Parent then
				local size = math.max(ring.AbsoluteSize.X, ring.AbsoluteSize.Y)
				local state = self.RingState[ring]
				if not state then
					state = { Max = size, Last = size, Shrinking = false, Armed = true, ClickedAt = 0 }
					self.RingState[ring] = state
				end

				if size > state.Max then state.Max = size end
				if size < state.Last - 0.8 then state.Shrinking = true end
				if size > state.Last + 4 or size >= state.Max * 0.88 then
					if now - state.ClickedAt > 0.12 then state.Armed = true end
					if size > state.Last + 4 then
						state.Max = math.max(state.Max, size)
						state.Shrinking = false
					end
				end

				local enoughTravel = (state.Max - size) >= math.max(6, state.Max * 0.18)
				local ratio = size / math.max(state.Max, 1)
				if state.Shrinking and enoughTravel and ratio <= 0.58
					and state.Armed and now - state.ClickedAt >= 0.10 then
					if self:ClickObject(ring) then
						state.Armed = false
						state.ClickedAt = now
						self.LastClickAt = now
						self.Clicks += 1
						clicked += 1
					end
				end
				state.Last = size
			end
		end
	end

	if #prompts == 0 and #whiteCandidates == 0 then
		-- Once a percentage is visible, the Pushups minigame is already open.
		-- Do not keep firing the ProximityPrompt because that can interrupt it.
		if progress <= 0 and not self.Starting and now - self.LastStartAttempt >= 3 then
			task.spawn(function()
				local ok, err = self:StartTraining()
				if self.Enabled then
					self:Status(ok and "Auto Pushups • กด Prompt แล้ว • รอวงกลม"
						or ("Auto Pushups • " .. tostring(err)), ok and T.Mint or T.Danger)
				end
			end)
		else
			self:Status("Auto Pushups • " .. tostring(progress) .. "% • มินิเกมทำงาน • รอวง", T.Gold)
		end
		return
	end

	if clicked > 0 then
		self:Status("Auto Pushups • " .. tostring(progress) .. "% • CLICK #" .. self.Clicks, T.Mint)
	else
		self:Status("Auto Pushups • " .. tostring(progress) .. "% • พบวง "
			.. tostring(#whiteCandidates) .. " • จับจังหวะ", T.Gold)
	end
end

AutoPushups.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() AutoPushups:Step() end)
	if not ok then
		Farm._lastRuntimeError = tostring(err)
		AutoPushups:Status("Auto Pushups • ERROR: " .. tostring(err), T.Danger)
	end
end)

Farm.StopThunder = function() if ThunderBreathing.Enabled then ThunderBreathing:SetEnabled(false) end end
ThunderBreathing.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() ThunderBreathing:Step() end)
	if not ok then
		ThunderBreathing:ReleaseT()
		ThunderBreathing.NextAt = os.clock() + 1
		Farm._lastRuntimeError = tostring(err)
		ThunderBreathing:Status("ปราณสายฟ้า • ERROR: " .. tostring(err))
	end
end)

table.insert(CombatRuntime.Connections, UserInputService.WindowFocusReleased:Connect(function()
	-- Do not stop the farm when alt-tabbing / switching windows.
	-- Release only currently-held synthetic inputs so no key/button gets stuck.
	if PagesQuest.Held then PagesQuest:Release(); PagesQuest.Phase = "page" end
	if BettyQuest.Held then BettyQuest:Release(); BettyQuest.Phase = "gem" end
	if ThunderBreathing.Held then ThunderBreathing:ReleaseT(); ThunderBreathing.Phase = "minigame" end
	BossLoot:Release()
	CombatRuntime.Focused = true
	CombatRuntime:Release()
end))
table.insert(CombatRuntime.Connections, UserInputService.WindowFocused:Connect(function()
	CombatRuntime.Focused = true
	Farm._inputPauseUntil = 0
end))
gui.Destroying:Connect(function()
	DamageBlock:Release()
	Farm.Enabled = false
	BettyQuest:SetEnabled(false)
	KazuQuest:SetEnabled(false)
	DeliveryQuest:SetEnabled(false)
	PagesQuest:SetEnabled(false)
	BearQuest:SetEnabled(false)
	ThunderBreathing:SetEnabled(false)
	CupGame:SetEnabled(false)
	AutoPushups:SetEnabled(false)
	if AutoPushups.Connection then AutoPushups.Connection:Disconnect() end
	if CupGame.Connection then CupGame.Connection:Disconnect() end
	if ThunderBreathing.Connection then ThunderBreathing.Connection:Disconnect() end
	if PagesQuest.Connection then PagesQuest.Connection:Disconnect() end
	if DeliveryQuest.Connection then DeliveryQuest.Connection:Disconnect() end
	if KazuQuest.Connection then KazuQuest.Connection:Disconnect() end
	if BettyQuest.Connection then BettyQuest.Connection:Disconnect() end
	if BearQuest.Connection then BearQuest.Connection:Disconnect() end
	farmStop()
	for _, connection in ipairs(CombatRuntime.Connections) do connection:Disconnect() end
	for _, connection in ipairs(Farm._inputConnections) do connection:Disconnect() end
end)

--------------------------------------------------------------
-- PLAYER — Speed / Jump / No Clip / Auto Skills
--------------------------------------------------------------
local AutoSkills = {
	Enabled = false, Focused = true, Keys = { "Z", "X", "C", "V", "B", "N", "K" },
	Settings = {}, Cursor = 0, Held = nil, Running = true, Connections = {},
}
for _, key in ipairs(AutoSkills.Keys) do
	AutoSkills.Settings[key] = { Enabled = false, Interval = 1, NextAt = 0 }
	for _, words in ipairs({ {"สกิล ", "Skill "}, {"ช่วงเวลากด ", "Interval "} }) do
		local pair = { th = words[1] .. key, en = words[2] .. key }
		I18N.Entries[pair.th], I18N.Entries[pair.en] = pair, pair
	end
end

function AutoSkills:Release()
	local held = self.Held
	if not held then return end
	self.Held = nil
	Farm._skillHeld = false
	Farm._skillReadyAt = os.clock() + 0.1
	CombatRuntime.BasicTurnPending = true
	CombatRuntime.BasicTurnUntil = os.clock() + 0.5
	pcall(function() held.Input:SendKeyEvent(false, held.Key, false, game) end)
end

Farm.ReleaseSkills = function() AutoSkills:Release() end

function AutoSkills:CanUse()
	if not self.Running or not self.Enabled then return false end
	if Farm.FastAttack then return false end
	if Farm._comboPending then return false end
	return CombatRuntime:CombatReady()
end

function AutoSkills:Step()
	if not self:CanUse() then self:Release(); return end
	if self.Held then return end
	local now = os.clock()
	if CombatRuntime.Held or CombatRuntime.EquipHeld or now < (Farm._skillReadyAt or 0) then return end
	if CombatRuntime.BasicTurnPending then
		if now < CombatRuntime.BasicTurnUntil then return end
		CombatRuntime.BasicTurnPending = false
	end
	local char = player.Character
	local _, ready = farmEquipSelectedWeapon(char, char:FindFirstChildOfClass("Humanoid"))
	if not ready then return end
	for offset = 1, #self.Keys do
		local index = (self.Cursor + offset - 1) % #self.Keys + 1
		local key = self.Keys[index]
		local setting = self.Settings[key]
		if setting.Enabled and now >= setting.NextAt then
			self.Cursor = index			setting.NextAt = now + setting.Interval
			local ok = pcall(function()
				local input = game:GetService("VirtualInputManager")
				local held = { Input = input, Key = Enum.KeyCode[key], Name = key }
				self.Held = held
				Farm._skillHeld = true
				if Farm.ResetCombo then Farm.ResetCombo() end
				local target = Farm._attackTarget
				local targetHum = target:FindFirstChildWhichIsA("Humanoid", true)
				local health = targetHum and targetHum.Health
				farmTrackQuestDeath(target, health)
				input:SendKeyEvent(true, held.Key, false, game)
				task.delay(0.06, function()
					if self.Held == held then self:Release() end
				end)
			end)
			if not ok then
				self:Release()
				for _, entry in pairs(self.Settings) do entry.NextAt = now + 2 end
				if self.OnError then self.OnError() end
			end
			return
		end
	end
end

function AutoSkills:SetEnabled(on)
	self.Enabled = on
	self:Release()
	for _, setting in pairs(self.Settings) do setting.NextAt = 0 end
end

function AutoSkills:Stop()
	self.Running = false
	self.Enabled = false
	self:Release()
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	self.OnError = nil
end

table.insert(AutoSkills.Connections, RunService.Heartbeat:Connect(function()
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then AutoSkills:Stop(); return end
	AutoSkills:Step()
end))
table.insert(AutoSkills.Connections, UserInputService.WindowFocusReleased:Connect(function()
	-- Keep Auto Skills enabled in the background; only release a key that is
	-- physically being simulated at the exact moment focus changes.
	AutoSkills.Focused = true
	AutoSkills:Release()
end))
table.insert(AutoSkills.Connections, UserInputService.WindowFocused:Connect(function()
	AutoSkills.Focused = true
end))
gui.Destroying:Connect(function() AutoSkills:Stop() end)

local PlayerMods = {
	SpeedEnabled = false,
	JumpEnabled = false,
	NoClipEnabled = false,
	FlyEnabled = false,
	FlySpeed = 120,
	WalkSpeed = 40,
	JumpPower = 100,
	_humanoid = nil,
	_originalWalkSpeed = nil,
	_originalJumpPower = nil,
	_originalJumpHeight = nil,
	_originalAutoRotate = nil,
	_originalCollisions = setmetatable({}, { __mode = "k" }),
	_conn = nil,
	_flyConn = nil,
}

local function playerModsHumanoid()
	local char = player.Character
	return char, char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function playerModsRememberHumanoid(hum)
	if not hum or PlayerMods._humanoid == hum then return end
	PlayerMods._humanoid = hum
	PlayerMods._originalWalkSpeed = hum.WalkSpeed
	PlayerMods._originalJumpPower = hum.JumpPower
	PlayerMods._originalJumpHeight = hum.JumpHeight
	PlayerMods._originalAutoRotate = hum.AutoRotate
end

local function playerModsRestoreMovement()
	local _, hum = playerModsHumanoid()
	if hum and hum == PlayerMods._humanoid then
		if PlayerMods._originalWalkSpeed ~= nil then
			pcall(function() hum.WalkSpeed = PlayerMods._originalWalkSpeed end)
		end
		if PlayerMods._originalJumpPower ~= nil then
			pcall(function() hum.JumpPower = PlayerMods._originalJumpPower end)
		end
		if PlayerMods._originalJumpHeight ~= nil then
			pcall(function() hum.JumpHeight = PlayerMods._originalJumpHeight end)
		end
	end
end

local function playerModsRestoreCollisions()
	for part, original in pairs(PlayerMods._originalCollisions) do
		if part and part.Parent then
			pcall(function() part.CanCollide = original end)
		end
	end
	PlayerMods._originalCollisions = setmetatable({}, { __mode = "k" })
end

local function playerModsSetSpeed(on)
	PlayerMods.SpeedEnabled = on
	local _, hum = playerModsHumanoid()
	if hum then
		playerModsRememberHumanoid(hum)
		if on then
			pcall(function() hum.WalkSpeed = PlayerMods.WalkSpeed end)
		elseif PlayerMods._originalWalkSpeed ~= nil then
			pcall(function() hum.WalkSpeed = PlayerMods._originalWalkSpeed end)
		end
	end
end

local function playerModsSetJump(on)
	PlayerMods.JumpEnabled = on
	local _, hum = playerModsHumanoid()
	if hum then
		playerModsRememberHumanoid(hum)
		if on then
			pcall(function()
				hum.JumpPower = PlayerMods.JumpPower
				hum.JumpHeight = math.max(7.2, PlayerMods.JumpPower / 7)
			end)
		else
			if PlayerMods._originalJumpPower ~= nil then
				pcall(function() hum.JumpPower = PlayerMods._originalJumpPower end)
			end
			if PlayerMods._originalJumpHeight ~= nil then
				pcall(function() hum.JumpHeight = PlayerMods._originalJumpHeight end)
			end
		end
	end
end

local function playerModsSetNoClip(on)
	PlayerMods.NoClipEnabled = on
	if not on then playerModsRestoreCollisions() end
end

local function playerModsSetFly(on)
	PlayerMods.FlyEnabled = on == true
	local char, hum = playerModsHumanoid()
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if hum then
		playerModsRememberHumanoid(hum)
		if PlayerMods.FlyEnabled then
			pcall(function() hum.AutoRotate = false end)
		else
			pcall(function()
				hum.AutoRotate = PlayerMods._originalAutoRotate ~= nil
					and PlayerMods._originalAutoRotate or true
			end)
		end
	end
	if root and not PlayerMods.FlyEnabled then
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(
				root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
			root.AssemblyAngularVelocity = Vector3.zero
		end)
	end
end

local function playerModsFlyStep()
	if not PlayerMods.FlyEnabled then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not hum or hum.Health <= 0 or not root or not camera then return end

	playerModsRememberHumanoid(hum)
	pcall(function() hum.AutoRotate = false end)

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local forward = Vector3.new(look.X, 0, look.Z)
	local side = Vector3.new(right.X, 0, right.Z)
	if forward.Magnitude > 0.001 then forward = forward.Unit end
	if side.Magnitude > 0.001 then side = side.Unit end

	local move = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += side end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= side end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
		move -= Vector3.yAxis
	end

	if move.Magnitude > 1 then move = move.Unit end
	local speed = PlayerMods.FlySpeed
	pcall(function()
		root.AssemblyLinearVelocity = move * speed
		root.AssemblyAngularVelocity = Vector3.zero
		if forward.Magnitude > 0.001 then
			local facing = Vector3.new(forward.X, 0, forward.Z)
			root.CFrame = CFrame.lookAt(root.Position, root.Position + facing)
		end
	end)
end

local function playerModsReset()
	PlayerMods.SpeedEnabled = false
	PlayerMods.JumpEnabled = false
	PlayerMods.NoClipEnabled = false
	PlayerMods.FlyEnabled = false
	local _, hum = playerModsHumanoid()
	if hum then
		pcall(function()
			hum.AutoRotate = PlayerMods._originalAutoRotate ~= nil
				and PlayerMods._originalAutoRotate or true
		end)
	end
	playerModsRestoreMovement()
	playerModsRestoreCollisions()
end

PlayerMods._conn = RunService.Stepped:Connect(function()
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		playerModsReset()
		if PlayerMods._conn then PlayerMods._conn:Disconnect(); PlayerMods._conn = nil end
		return
	end

	local char, hum = playerModsHumanoid()
	if hum then
		playerModsRememberHumanoid(hum)
		if PlayerMods.SpeedEnabled then
			pcall(function() hum.WalkSpeed = PlayerMods.WalkSpeed end)
		end
		if PlayerMods.JumpEnabled then
			pcall(function()
				hum.JumpPower = PlayerMods.JumpPower
				hum.JumpHeight = math.max(7.2, PlayerMods.JumpPower / 7)
			end)
		end
	end

	if PlayerMods.NoClipEnabled and char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if PlayerMods._originalCollisions[part] == nil then
					PlayerMods._originalCollisions[part] = part.CanCollide
				end
				pcall(function() part.CanCollide = false end)
			end
		end
	end
end)

PlayerMods._flyConn = RunService.RenderStepped:Connect(function()
	if _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		if PlayerMods._flyConn then PlayerMods._flyConn:Disconnect(); PlayerMods._flyConn = nil end
		return
	end
	playerModsFlyStep()
end)

gui.Destroying:Connect(function()
	playerModsSetFly(false)
	playerModsReset()
	if PlayerMods._flyConn then PlayerMods._flyConn:Disconnect(); PlayerMods._flyConn = nil end
	if PlayerMods._conn then PlayerMods._conn:Disconnect(); PlayerMods._conn = nil end
end)

--------------------------------------------------------------
-- PLAYER — INVISIBLE
--------------------------------------------------------------
local InvisibleMode = {
	Enabled = false,
	Character = nil,
	OriginalParts = setmetatable({}, { __mode = "k" }),
	OriginalVisuals = setmetatable({}, { __mode = "k" }),
	OriginalHumanoid = nil,
	Highlight = nil,
	NextScanAt = 0,
	Connection = nil,
}

function InvisibleMode:Restore()
	for part, state in pairs(self.OriginalParts) do
		if part and part.Parent then
			pcall(function()
				part.Transparency = state.Transparency
				part.CastShadow = state.CastShadow
			end)
		end
	end
	for visual, transparency in pairs(self.OriginalVisuals) do
		if visual and visual.Parent then
			pcall(function() visual.Transparency = transparency end)
		end
	end
	if self.OriginalHumanoid and self.OriginalHumanoid.Humanoid and self.OriginalHumanoid.Humanoid.Parent then
		local saved = self.OriginalHumanoid
		pcall(function()
			saved.Humanoid.NameDisplayDistance = saved.NameDisplayDistance
			saved.Humanoid.HealthDisplayDistance = saved.HealthDisplayDistance
		end)
	end
	if self.Highlight then pcall(function() self.Highlight:Destroy() end) end
	self.Highlight = nil
	self.Character = nil
	self.OriginalHumanoid = nil
	self.OriginalParts = setmetatable({}, { __mode = "k" })
	self.OriginalVisuals = setmetatable({}, { __mode = "k" })
end

function InvisibleMode:ApplyCharacter(char)
	if not char then return end
	if self.Character ~= char then
		self:Restore()
		self.Character = char
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and not self.OriginalHumanoid then
		self.OriginalHumanoid = {
			Humanoid = hum,
			NameDisplayDistance = hum.NameDisplayDistance,
			HealthDisplayDistance = hum.HealthDisplayDistance,
		}
		pcall(function()
			hum.NameDisplayDistance = 0
			hum.HealthDisplayDistance = 0
		end)
	end

	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") then
			if not self.OriginalParts[obj] then
				self.OriginalParts[obj] = {
					Transparency = obj.Transparency,
					CastShadow = obj.CastShadow,
				}
			end
			pcall(function()
				obj.Transparency = 1
				obj.CastShadow = false
			end)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			if self.OriginalVisuals[obj] == nil then self.OriginalVisuals[obj] = obj.Transparency end
			pcall(function() obj.Transparency = 1 end)
		end
	end

	if not self.Highlight or self.Highlight.Parent ~= char then
		if self.Highlight then pcall(function() self.Highlight:Destroy() end) end
		local hl = Instance.new("Highlight")
		hl.Name = "LuminInvisibleGhost"
		hl.Adornee = char
		hl.FillColor = Color3.fromRGB(180, 220, 255)
		hl.FillTransparency = 0.72
		hl.OutlineColor = Color3.fromRGB(215, 235, 255)
		hl.OutlineTransparency = 0.35
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = char
		self.Highlight = hl
	end
end

function InvisibleMode:SetEnabled(on)
	on = on == true
	if self.Enabled == on then return end
	self.Enabled = on
	if on then
		self.NextScanAt = 0
		self:ApplyCharacter(player.Character)
	else
		self:Restore()
	end
end

InvisibleMode.Connection = RunService.Heartbeat:Connect(function()
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then
		InvisibleMode.Enabled = false
		InvisibleMode:Restore()
		if InvisibleMode.Connection then InvisibleMode.Connection:Disconnect(); InvisibleMode.Connection = nil end
		return
	end
	if not InvisibleMode.Enabled then return end
	if os.clock() < InvisibleMode.NextScanAt then return end
	InvisibleMode.NextScanAt = os.clock() + 0.2
	InvisibleMode:ApplyCharacter(player.Character)
end)

gui.Destroying:Connect(function()
	InvisibleMode.Enabled = false
	InvisibleMode:Restore()
	if InvisibleMode.Connection then InvisibleMode.Connection:Disconnect(); InvisibleMode.Connection = nil end
end)

local DungeonQuest = { Enabled = false, Phase = "npc", NextAt = 0,
	Forge = Vector3.new(-1604.9444580078125, 1002.4012451171875, 1143.3331298828125) }

function DungeonQuest:Status(text)
	if self.Label and self.Label.Parent then self.Label.Text = text end
end

function DungeonQuest:Release()
	local input = self.Input
	self.Input = nil
	if input then pcall(function() input:SendKeyEvent(false, Enum.KeyCode.T, false, game) end) end
end

function DungeonQuest:SetEnabled(on)
	if self.Enabled == on then return end
	self:Release()
	if on then
		farmSet(false)
		if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
	end
	self.Enabled, self.Phase, self.NextAt = on, "npc", 0
	self.Character, self.Root = player.Character, nil
	self.Deadline = os.clock() + 120
	if self.Setter then self.Setter(on, false) end
	self:Status(on and "กำลังไปหา Blacksmith Togane" or "Dungeon • OFF")
end

function DungeonQuest:Step()
	if not self.Enabled then return end
	local now, char = os.clock(), player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN or char ~= self.Character
		or not root or not hum or hum.Health <= 0 or (self.Root and self.Root ~= root)
		or Farm.Enabled or Farm._bettyBusy or Farm._storyBusy or Farm._deliveryBusy or Farm._pagesBusy or Farm._bearBusy then
		self:SetEnabled(false); return
	end
	self.Root = root
	if now >= self.Deadline then
		self:SetEnabled(false); self:Status("หมดเวลารอ Dungeon — ลองเปิดใหม่"); return
	end
	if attackInputBlocked() then
		if self.Input then self:Release(); self.Phase = "forge" end
		return
	end
	if now < self.NextAt then return end
	if self.Phase == "hold" then
		self:SetEnabled(false)
		self:Status("กด T แล้ว — ตรวจผลปลดล็อกในเกม")
		return
	end
	if self.Phase == "forge" or self.Phase == "press" then
		local delta = self.Forge - root.Position
		if delta.Magnitude > 4 then
			local destination = delta.Magnitude > 80 and root.Position + delta * (80 / delta.Magnitude) or self.Forge
			root.CFrame = CFrame.new(destination)
			root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			self.Phase, self.NextAt = "forge", now + 0.2; return
		end
		if self.Phase == "forge" then self.Phase, self.NextAt = "press", now + 0.6; return end
		self.Input = game:GetService("VirtualInputManager")
		self.Input:SendKeyEvent(true, Enum.KeyCode.T, false, game)
		self.Phase, self.NextAt = "hold", now + 1.5
		self:Status("กด T ค้างที่เตาหลอม")
		return
	end
	local npc = tpFindNPC("Blacksmith Togane")
	local cf = farmCFrameOf(npc)
	if not cf then
		TP.ApproachSaved(root, "Blacksmith Togane"); self.NextAt = now + 0.4; return
	end
	if (root.Position - cf.Position).Magnitude > 6 then
		root.CFrame = CFrame.lookAt((cf * CFrame.new(0, 0, -3)).Position, cf.Position)
		root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		self.NextAt = now + 0.6; return
	end
	local ev = farmGetSignal()
	if not ev then self.NextAt = now + 1; return end
	if self.Phase == "npc" then
		ev:FireServer("NpcTalking", "Ended")
		self.Phase, self.NextAt = "accept", now + 0.3
	elseif self.Phase == "accept" then
		ev:FireServer("AddQuest", "Ill find the forge(Lv 65)")
		self.Phase, self.NextAt = "forge", now + 0.6
		self:Status("รับคำขอเควสแล้ว กำลังไปเตาหลอม")
	end
end

Farm.StopDungeon = function() DungeonQuest:SetEnabled(false) end
DungeonQuest.Connection = RunService.Heartbeat:Connect(function()
	local ok, err = pcall(function() DungeonQuest:Step() end)
	if not ok then DungeonQuest:SetEnabled(false); DungeonQuest:Status("Dungeon • " .. tostring(err)) end
end)
gui.Destroying:Connect(function()
	DungeonQuest:SetEnabled(false)
	DungeonQuest.Connection:Disconnect()
end)

-- Dungeon combat shares the normal attack and retreat loops.
Farm.Dungeon = {
	Enabled = false,
	Radius = 300,
	KillAura = false,
	KillAuraRadius = 20,
	KillAuraNextAt = 0,
	KillAuraPrime = setmetatable({}, { __mode = "k" }),
	KillAuraBurst = setmetatable({}, { __mode = "k" }),
	-- Auto Dungeon now fights every NPC at its real server position.
	-- Keep the old isolation fields only for cleanup/backward compatibility.
	LiftLockedTarget = false,
	IsolationHeight = 25,
	IsolationTarget = nil,
	IsolationPosition = nil,
	IsolationOriginalCFrame = nil,
	IsolationStartedAt = 0,
	IsolationLastHealth = nil,
	IsolationLastHealthAt = 0,
	IsolationRetries = 0,
	IsolationFallback = false,
	IsolationActivated = false,
	IsolationActivationHealth = nil,
	IsolationLiftHealth = nil,
	IsolationLiftAt = 0,
	IsolationStallDelay = 1.0,
	IsolationNoLift = setmetatable({}, { __mode = "k" }),
	-- Two-step dungeon approach: wait high above the target, then drop below to hit.
	ApproachTarget = nil,
	ApproachReadyAt = 0,
	ApproachAnchor = nil,
	ApproachDelay = 1.0,
	ApproachSkyHeight = 60,
	ReapproachDistance = 10,
	PreAttackHeld = nil,
	-- Small pause after a mob is confirmed dead before selecting the next one.
	NextTargetDelay = 0.5,
	NextTargetAt = 0,
}

function Farm.Dungeon:TemporaryFolder()
	local humanoids = workspace:FindFirstChild("Humanoids")
	local regions = humanoids and humanoids:FindFirstChild("Regions")
	return regions and regions:FindFirstChild("Temporary")
end

function Farm.Dungeon:ActiveFolder()
	local temporary = self:TemporaryFolder()
	return temporary and temporary:FindFirstChild("ActiveNpcs")
end

function Farm.Dungeon:TargetRoot(model)
	if not model then return nil end
	local root = model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("HumanoidRootPart", true)
	return root and root:IsA("BasePart") and root or nil
end

function Farm.Dungeon:ValidTarget(model)
	if not model or not model.Parent then return false end
	if game:GetService("Players"):GetPlayerFromCharacter(model) then return false end
	local myCharacter = player.Character
	if myCharacter and (model == myCharacter or model:IsDescendantOf(myCharacter)) then return false end
	local hum = model:FindFirstChildWhichIsA("Humanoid", true)
	local root = self:TargetRoot(model)
	return hum ~= nil and hum.Health > 0 and root ~= nil
end

function Farm.Dungeon:StopTargetIndex()
	if self.RootAdded then self.RootAdded:Disconnect(); self.RootAdded = nil end
	if self.RootRemoved then self.RootRemoved:Disconnect(); self.RootRemoved = nil end
	self.RootIndex, self.CachedCandidate, self.NextFindAt = nil, nil, 0
end

function Farm.Dungeon:FindTarget()
	local now = os.clock()
	if now < (self.NextFindAt or 0) then
		return self:ValidTarget(self.CachedCandidate) and self.CachedCandidate or nil
	end
	self.NextFindAt = now + 0.2
	local char = player.Character
	local charRoot = char and char:FindFirstChild("HumanoidRootPart")
	if not charRoot then self.CachedCandidate = nil; return nil end

	if not self.RootIndex then
		local roots = setmetatable({}, { __mode = "k" })
		self.RootIndex = roots
		local function addRoot(part)
			if part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
				roots[part] = true
			end
		end
		self.RootAdded = workspace.DescendantAdded:Connect(addRoot)
		self.RootRemoved = workspace.DescendantRemoving:Connect(function(part)
			roots[part] = nil
		end)
		-- One initial scan, then maintain only the small set of character roots.
		for _, part in ipairs(workspace:GetDescendants()) do addRoot(part) end
	end

	local radius = math.max(1, tonumber(self.Radius) or 300)
	local best, bestDistance = nil, radius
	for part in pairs(self.RootIndex) do
		if part.Parent then
			local distance = (part.Position - charRoot.Position).Magnitude
			if distance <= bestDistance then
				local model = part:FindFirstAncestorOfClass("Model")
				if self:ValidTarget(model) then
					best, bestDistance = model, distance
				end
			end
		else
			self.RootIndex[part] = nil
		end
	end
	self.CachedCandidate = best
	return best
end

function Farm.Dungeon:ClearIsolation()
	-- Never leave a living dungeon NPC stranded in the client-side lift
	-- position when the lock changes. Put it back where it was first found.
	local oldTarget = self.IsolationTarget
	local original = self.IsolationOriginalCFrame
	if oldTarget and original and oldTarget.Parent then
		local oldHum = oldTarget:FindFirstChildWhichIsA("Humanoid", true)
		local oldRoot = oldTarget:FindFirstChild("HumanoidRootPart")
			or oldTarget:FindFirstChild("HumanoidRootPart", true)
		if oldRoot and (not oldHum or oldHum.Health > 0) then
			pcall(function()
				if oldTarget:IsA("Model") then oldTarget:PivotTo(original) end
				oldRoot.CFrame = original
				oldRoot.AssemblyLinearVelocity = Vector3.zero
				oldRoot.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end

	self.IsolationTarget = nil
	self.IsolationPosition = nil
	self.IsolationOriginalCFrame = nil
	self.IsolationStartedAt = 0
	self.IsolationLastHealth = nil
	self.IsolationLastHealthAt = 0
	self.IsolationRetries = 0
	self.IsolationFallback = false
	self.IsolationActivated = false
	self.IsolationActivationHealth = nil
	self.IsolationLiftHealth = nil
	self.IsolationLiftAt = 0
	dungeonReleasePreAttack()
	self.ApproachTarget = nil
	self.ApproachReadyAt = 0
	self.ApproachAnchor = nil
end

function Farm.Dungeon:PrepareTarget(target)
	if not self.Enabled or not self.LiftLockedTarget or not self:ValidTarget(target) then
		if self.IsolationTarget == target or not target then self:ClearIsolation() end
		return false
	end

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
		or target:FindFirstChild("HumanoidRootPart", true)
	local targetHum = target:FindFirstChildWhichIsA("Humanoid", true)
	if not targetRoot or not targetHum or targetHum.Health <= 0 then
		self:ClearIsolation()
		return false
	end

	local now = os.clock()
	if self.IsolationTarget ~= target then
		self:ClearIsolation()
		self.IsolationTarget = target
		self.IsolationOriginalCFrame = targetRoot.CFrame
		self.IsolationPosition = nil
		self.IsolationStartedAt = now
		self.IsolationLastHealth = targetHum.Health
		self.IsolationLastHealthAt = now
		self.IsolationActivated = false
		self.IsolationActivationHealth = targetHum.Health
		self.IsolationLiftHealth = nil
		self.IsolationLiftAt = 0

		pcall(function()
			if setsimulationradius then
				setsimulationradius(math.huge, math.huge)
			elseif sethiddenproperty then
				sethiddenproperty(player, "SimulationRadius", math.huge)
			end
		end)

		-- If this exact NPC already proved that server-side hits stop while
		-- lifted, keep it at its real position for the rest of its lifetime.
		if self.IsolationNoLift[target] then
			self.IsolationActivated = true
			self.IsolationFallback = true
			return true
		end
	end

	-- Do not lift a fresh NPC yet. First stay at its real server position
	-- and let normal Auto Attack land at least one real hit.
	if not self.IsolationActivated then
		local activationHealth = self.IsolationActivationHealth or targetHum.Health
		if targetHum.Health < activationHealth then
			self.IsolationActivated = true
			self.IsolationLastHealth = targetHum.Health
			self.IsolationLastHealthAt = now
			self.IsolationLiftHealth = targetHum.Health
			self.IsolationLiftAt = now
			self.IsolationPosition = targetRoot.Position + Vector3.new(0, tonumber(self.IsolationHeight) or 25, 0)
			self.IsolationRetries = 0
			self.IsolationFallback = false
		else
			-- Keep the client NPC copy at the original location until the first
			-- server-confirmed hit happens, so farmMoveUnder() warps us to it.
			local original = self.IsolationOriginalCFrame
			if original then
				pcall(function()
					if target:IsA("Model") then target:PivotTo(original) end
					targetRoot.CFrame = original
					targetRoot.AssemblyLinearVelocity = Vector3.zero
					targetRoot.AssemblyAngularVelocity = Vector3.zero
				end)
			end
			return false
		end
	end

	if self.IsolationLastHealth == nil or targetHum.Health < self.IsolationLastHealth then
		self.IsolationLastHealth = targetHum.Health
		self.IsolationLastHealthAt = now
		self.IsolationLiftHealth = targetHum.Health
		self.IsolationLiftAt = now
		if not self.IsolationFallback then self.IsolationRetries = 0 end
	end

	-- A lifted NPC can still be server-owned. In that case the client shows it
	-- in the air while the server keeps the real hit target on the ground.
	-- Detect that quickly: if HP stops changing after the lift, stop lifting this
	-- NPC, restore its real position, and keep attacking there instead of swinging
	-- at a client-only position.
	local stallDelay = math.clamp(tonumber(self.IsolationStallDelay) or 1.0, 0.6, 2.0)
	if self.IsolationActivated and not self.IsolationFallback
		and now - (self.IsolationLastHealthAt or now) >= stallDelay then
		self.IsolationRetries = (self.IsolationRetries or 0) + 1
		self.IsolationFallback = true
		self.IsolationNoLift[target] = true
		CombatRuntime.NextScanAt = 0
		CombatRuntime.NextAttackAt = 0
		Farm._attackTarget = nil
	end

	-- Some of the final dungeon NPCs are server-owned and cannot stay lifted.
	-- For those, return the client copy to the saved real position so movement
	-- and Kill Aura operate where the server still considers the NPC to be.
	if self.IsolationFallback and self.IsolationOriginalCFrame then
		local original = self.IsolationOriginalCFrame
		pcall(function()
			if target:IsA("Model") then target:PivotTo(original) end
			targetRoot.CFrame = original
			targetRoot.AssemblyLinearVelocity = Vector3.zero
			targetRoot.AssemblyAngularVelocity = Vector3.zero
		end)
		return true
	end

	local position = self.IsolationPosition
	if not position then return false end
	local look = Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z)
	if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) else look = look.Unit end
	local desired = CFrame.lookAt(position, position + look)

	-- Keep forcing the selected NPC upward while it is the active target.
	pcall(function()
		if target:IsA("Model") then target:PivotTo(desired) end
	end)
	pcall(function()
		targetRoot.CFrame = desired
		targetRoot.AssemblyLinearVelocity = Vector3.zero
		targetRoot.AssemblyAngularVelocity = Vector3.zero
		for _, part in ipairs(target:GetDescendants()) do
			if part:IsA("BasePart") then
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end)

	return true
end

Farm.StopDungeonCombat = function()
	local mode = Farm.Dungeon
	mode:StopTargetIndex()
	if not mode.Enabled then return end
	mode:ClearIsolation()
	mode.Enabled = false
	if mode.Saved then
		Farm.BossEnabled, Farm.AutoQuest, Farm.AutoAttack = mode.Saved.BossEnabled, mode.Saved.AutoQuest, mode.Saved.AutoAttack
	end
	mode.Saved = nil
	if mode.Setter then mode.Setter(false, false) end
end

function Farm.Dungeon:SetEnabled(on)
	if on == self.Enabled then return end
	if not on then Farm.StopDungeonCombat(); farmSet(false, true); return end
	local char = player.Character
	-- Enabling during respawn is allowed; CombatRuntime waits for a living character.
	farmSet(false)
	if BettyQuest.Enabled then BettyQuest:SetEnabled(false) end
	self.Saved = { BossEnabled = Farm.BossEnabled, AutoQuest = Farm.AutoQuest, AutoAttack = Farm.AutoAttack }
	Farm.BossEnabled, Farm.AutoQuest, Farm.AutoAttack = false, false, true
	self.Character = char
	self.LiftLockedTarget = false
	self.NextTargetAt = 0
	self:ClearIsolation()
	-- Dungeon never uses the global damage/combo retreat movement.
	FarmRetreat:Stop()
	DamageBlock:Release()
	farmSet(true, true)
	self.Enabled = true
end

gui.Destroying:Connect(function()
	Farm.Dungeon:StopTargetIndex()
	Farm.Dungeon:SetEnabled(false)
end)

Farm.Dungeon.AutoSkip = false
Farm.Dungeon.NextSkipAt = 0
function Farm.Dungeon:StepAutoSkip()
	if not self.AutoSkip or not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	local now = os.clock()
	if now < self.NextSkipAt or attackInputBlocked() then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	self.NextSkipAt = now + 3
	local ev = farmGetSignal()
	if not ev then return end
	local ok, err = pcall(function()
		ev:FireServer("OuwigaharaRequest", { action = "Skip" })
	end)
	if not ok then
		self.NextSkipAt = now + 5
		Farm._lastRuntimeError = tostring(err)
	end
end
Farm.Dungeon.SkipConnection = RunService.Heartbeat:Connect(function() Farm.Dungeon:StepAutoSkip() end)

function Farm.Dungeon:FindKillAuraTargets()
	local folder = self:ActiveFolder()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not folder or not root then return {} end

	local targets = {}
	local radius = tonumber(self.KillAuraRadius) or 20
	for _, hum in ipairs(folder:GetDescendants()) do
		if hum:IsA("Humanoid") and hum.Health > 0 then
			local model = hum.Parent
			while model and model ~= folder and not model:IsA("Model") do
				model = model.Parent
			end
			if model and model ~= folder and self:ValidTarget(model) then
				local targetRoot = model:FindFirstChild("HumanoidRootPart")
					or model:FindFirstChild("HumanoidRootPart", true)
				if targetRoot and (targetRoot.Position - root.Position).Magnitude <= radius then
					table.insert(targets, { Model = model, Humanoid = hum })
				end
			end
		end
	end
	return targets
end

function Farm.Dungeon:StepKillAura()
	-- Fast Attack already owns the same signal. Never run a second sender.
	if Farm.FastAttack or not self.Enabled or not CombatRuntime:CombatReady() then return end
	if not self.KillAura or not gui.Parent or _G.__LUMIN_RUNNING ~= LUMIN_RUN_TOKEN then return end
	local now = os.clock()
	if now < (self.KillAuraNextAt or 0) then return end

	local char = player.Character
	local myHum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not myHum or myHum.Health <= 0 then return end

	-- Aura follows the exact dungeon target so another nearby NPC cannot steal it.
	local locked = self.IsolationTarget or Farm._target
	if not locked or not self:ValidTarget(locked) then return end
	-- Fresh NPCs must receive one real Auto Attack hit at their server position
	-- before Aura/lifting starts.
	if self.IsolationTarget == locked and not self.IsolationActivated then return end

	local targetRoot = locked:FindFirstChild("HumanoidRootPart")
		or locked:FindFirstChild("HumanoidRootPart", true)
	local targetHum = locked:FindFirstChildWhichIsA("Humanoid", true)
	local myRoot = char:FindFirstChild("HumanoidRootPart")
	if not targetRoot or not targetHum or targetHum.Health <= 0 or not myRoot then return end
	if (targetRoot.Position - myRoot.Position).Magnitude > (tonumber(self.KillAuraRadius) or 20) then return end

	-- Kill Aura is locked until the normal Auto Attack has pressed attack
	-- on this exact mob two times. Aura no longer primes those hits itself.
	local presses = self.KillAuraPrime[locked] or 0
	if presses < 2 then
		self.KillAuraNextAt = now + 0.05
		return
	end

	local _, ready = farmEquipSelectedWeapon(char, myHum)
	if not ready then
		self.KillAuraNextAt = now + 0.08
		return
	end

	local ev = farmGetSignal()
	if not ev then
		self.KillAuraNextAt = now + 0.25
		return
	end

	-- Do NOT force Humanoid.Health = 0 locally. That made ValidTarget() think the
	-- mob was dead before the server accepted the damage, so Aura stopped early.
	-- After the two normal attacks, keep sending server combat pulses until the
	-- replicated Humanoid health actually reaches zero.
	self.KillAuraNextAt = now + 0.05
	local burst = (self.KillAuraBurst[locked] or 0) + 1
	self.KillAuraBurst[locked] = burst

	pcall(function()
		ev:FireServer("Combat_Service", "Combat", 1, false, 0.13, false, nil)
	end)

	-- A second pulse with a tiny gap is more reliable than six calls in one frame
	-- on servers that debounce Combat_Service.
	task.delay(0.025, function()
		if Farm.FastAttack or not CombatRuntime:CombatReady() or Farm._skillHeld then return end
		if not self.KillAura or not self.Enabled then return end
		if Farm._target ~= locked or not locked.Parent then return end
		local hum = locked:FindFirstChildWhichIsA("Humanoid", true)
		if not hum or hum.Health <= 0 then return end
		local signal = farmGetSignal()
		if signal then
			pcall(function()
				signal:FireServer("Combat_Service", "Combat", 1, false, 0.13, false, nil)
			end)
		end
	end)
end

Farm.Dungeon.KillAuraConnection = RunService.Heartbeat:Connect(function()
	Farm.Dungeon:StepKillAura()
end)

gui.Destroying:Connect(function()
	Farm.PlayerHitboxTest = false
	if Farm._playerHitboxTestConn then Farm._playerHitboxTestConn:Disconnect() end
	farmRestorePlayerHitbox()
	Farm.Dungeon.AutoSkip = false
	Farm.Dungeon.KillAura = false
	Farm.Dungeon.SkipConnection:Disconnect()
	Farm.Dungeon.KillAuraConnection:Disconnect()
end)

local function BuildStatusPage(L, R)
		label(L, "สถานะบอส / เวลาเกิด", 13, T.Text, Enum.Font.GothamBold,
			nil, UDim2.new(1, 0, 0, 24))
		local note = label(R, "เวลาประมาณจากการตาย → เกิดที่ตรวจพบในเซสชันนี้\nถ้าข้อมูลบอสยังไม่โหลด อาจยังไม่พบแม้บอสเกิดแล้ว",
			10, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 42))
		note.TextWrapped = true
		local rows = {}
		for index, name in ipairs(BOSS_TYPES) do
			local column = index <= 6 and L or R
			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 98), BackgroundColor3 = T.Card,
			}, column)
			corner(row, 8)
			label(row, name, 12, T.Text, Enum.Font.GothamBold,
				UDim2.fromOffset(10, 6), UDim2.new(1, -20, 0, 18))
			label(row, BOSS_REGIONS[name] or "Misc", 10, T.Sub, Enum.Font.Gotham,
				UDim2.fromOffset(10, 26), UDim2.new(1, -20, 0, 15))
			local status = label(row, "กำลังตรวจสอบ...", 11, T.Gold, Enum.Font.Gotham,
				UDim2.fromOffset(10, 43), UDim2.new(1, -20, 0, 22))
			local detail = label(row, "", 10, T.Sub, Enum.Font.Gotham,
				UDim2.fromOffset(10, 66), UDim2.new(1, -20, 0, 28))
			detail.TextWrapped = true
			rows[name] = { Status = status, Detail = detail }
		end

		task.spawn(function()
			while BossStatus.Running and gui.Parent and _G.__LUMIN_RUNNING == LUMIN_RUN_TOKEN do
				if main.Visible and pages.Status and pages.Status.Visible then
					for _, name in ipairs(BOSS_TYPES) do
						if not gui.Parent or not main.Visible or not pages.Status.Visible then break end
						local state = BossStatus:Update(name)
						local status, detail, color = BossStatus:Describe(state)
						rows[name].Status.Text = status
						rows[name].Status.TextColor3 = color
						rows[name].Detail.Text = detail
						task.wait(0.03)
					end
				end
				task.wait(1.5)
			end
			BossStatus:Stop()
		end)
end

local function BuildQuestPage(L, R)
	local _, _, dungeonCombatSetter = Section(R, "Auto Dungeon • HumanoidRootPart 300 studs", false, function(on)
		Farm.Dungeon:SetEnabled(on)
	end)
	Farm.Dungeon.Setter = dungeonCombatSetter
	label(R, "Hitbox การตีผู้เล่น", 12, T.Gold, Enum.Font.GothamBold,
		nil, UDim2.new(1, 0, 0, 22))
	Slider(R, "Hitbox การตีผู้เล่น", "ขยายพื้นที่ตีของอาวุธฝั่งผู้เล่น • ปรับได้ 5-100", 5, 100, Farm.PlayerAttackHitbox, " st", function(val)
		Farm.PlayerAttackHitbox = math.floor(val + 0.5)
		Farm._hitboxNextAt = 0
	end)
	local combatNote = label(R, "หา HumanoidRootPart ระยะ 300 → วาปขึ้นฟ้า → กด M1 ค้างบนฟ้า → รอ → วาปลงมาตีใต้มอนแล้วปล่อย M1", 11, T.Sub,
		Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 64))
	combatNote.TextWrapped = true
	Slider(R, "ความสูงก่อนวาปลงตี", "ระยะลอยเหนือ HumanoidRootPart ก่อนลงมาตีใต้มอน", 20, 120, Farm.Dungeon.ApproachSkyHeight, " st", function(val)
		Farm.Dungeon.ApproachSkyHeight = math.floor(val + 0.5)
	end)
	Slider(R, "เวลาลอยบนฟ้า", "รอก่อนวาปลงมาตีใต้มอน", 0.1, 3, Farm.Dungeon.ApproachDelay, " s", function(val)
		Farm.Dungeon.ApproachDelay = math.floor(val * 20 + 0.5) / 20
	end)
	Slider(R, "หน่วงก่อนตีตัวถัดไป", "หลังมอนตาย รอก่อนเลือกเป้าตัวใหม่", 0.1, 2, Farm.Dungeon.NextTargetDelay, " s", function(val)
		Farm.Dungeon.NextTargetDelay = math.floor(val * 10 + 0.5) / 10
	end)
	Toggle(R, "Auto Skip", false, function(on)
		Farm.Dungeon.AutoSkip = on
		Farm.Dungeon.NextSkipAt = 0
	end)
	Toggle(R, "Kill Aura", false, function(on)
		Farm.Dungeon.KillAura = on
		Farm.Dungeon.KillAuraNextAt = 0
		Farm.Dungeon.KillAuraPrime = setmetatable({}, { __mode = "k" })
		Farm.Dungeon.KillAuraBurst = setmetatable({}, { __mode = "k" })
		if not on then CombatRuntime:ReleaseAttack() end
	end)
	Slider(R, "Kill Aura Range", "Auto Attack ต้องกดตีมอนตัวนั้น 2 ครั้งก่อน แล้ว Kill Aura ค่อยฆ่า", 5, 60, Farm.Dungeon.KillAuraRadius, " st", function(val)
		Farm.Dungeon.KillAuraRadius = math.floor(val + 0.5)
	end)
	local _, _, dungeonSetter = Section(R, "Quest unlock Dungeon • Lv65+", false, function(on)
		DungeonQuest:SetEnabled(on)
	end)
	DungeonQuest.Setter = dungeonSetter
	local dungeonNote = label(R, "Togane → เตาหลอม → กด T ค้าง", 11, T.Sub,
		Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 40))
	dungeonNote.TextWrapped = true
	DungeonQuest.Label = dungeonNote
	local function questHiddenStatus()
		local x = label(L, "", 1, T.Sub, Enum.Font.Gotham, nil, UDim2.fromOffset(0, 0))
		x.Visible = false
		return x
	end

	local _, _, kazuSetter = Section(L, "Quest 1 • Kazu • Lv 1-10", false, function(on)
		KazuQuest:SetEnabled(on)
	end)
	KazuQuest.Setter = kazuSetter
	KazuQuest.Label = questHiddenStatus()
	KazuQuest.StorageLabel = questHiddenStatus()

	local _, _, bettySetter = Section(L, "Quest 2 • Betty • Lv 10", false, function(on)
		BettyQuest:SetEnabled(on)
	end)
	BettyQuest.Setter = bettySetter
	BettyQuest.Label = questHiddenStatus()

	local _, _, deliverySetter = Section(L, "Quest 3 • MoldySugar • Lv 1-10", false, function(on)
		DeliveryQuest:SetEnabled(on)
	end)
	DeliveryQuest.Setter = deliverySetter
	DeliveryQuest.Label = questHiddenStatus()

	local _, _, pagesSetter = Section(L, "Quest 4 • Kona • Lv 1-10", false, function(on)
		PagesQuest:SetEnabled(on)
	end)
	PagesQuest.Setter = pagesSetter
	PagesQuest.Label = questHiddenStatus()

	local _, _, bearSetter = Section(L, "Quest 5 • Lucy / Tom • Lv 1-10", false, function(on)
		BearQuest:SetEnabled(on)
	end)
	BearQuest.Setter = bearSetter
	BearQuest.Label = questHiddenStatus()
end

local function BuildMultiBossPanel(parent, statusLbl, getBossSelection, setBossFarmToggle, setNormalFarmToggle)
	Farm.MultiBossLabel = statusLbl
	Section(parent, "Multi Boss", true)

	local bossList = farmListBossTypes()
	if #bossList == 0 then bossList = BOSS_TYPES end

	local firstBoss = getBossSelection and getBossSelection() or bossList[1]
	local secondBoss = Farm.MultiBossSecond
	if not secondBoss or not table.find(bossList, secondBoss) or secondBoss == firstBoss then
		secondBoss = bossList[2] or bossList[1]
	end
	Farm.MultiBossSecond = secondBoss

	local _, getBoss2, setBoss2Options = Dropdown(
		parent, "เลือกบอสช่องที่ 2", "",
		bossList, secondBoss, function(opt)
			if Farm.MultiBossEnabled then
				statusLbl.Text = "ปิด Multi Boss ก่อนเปลี่ยนบอสช่องที่ 2"
				statusLbl.TextColor3 = T.Gold
				return
			end
			Farm.MultiBossSecond = opt
			statusLbl.Text = "Boss ช่อง 2: " .. tostring(opt)
			statusLbl.TextColor3 = T.Mint
		end
	)

	SearchDropdownFilter(parent, "Search boss 2...", bossList, getBoss2, setBoss2Options, function(selected)
		if Farm.MultiBossEnabled then return end
		Farm.MultiBossSecond = selected
	end, statusLbl, "Boss 2")

	local _, _, multiSetter = Section(parent, "ฟาร์มบอสหลายตัว (เปิด/ปิด)", false, function(on)
		if on then
			local boss1 = getBossSelection and getBossSelection()
			local boss2 = getBoss2 and getBoss2()
			if not boss1 or not boss2 then
				statusLbl.Text = "กรุณาเลือกบอสช่อง 1 และช่อง 2"
				statusLbl.TextColor3 = T.Danger
				if Farm.MultiBossSetter then Farm.MultiBossSetter(false, false) end
				return
			end
			if boss1 == boss2 then
				statusLbl.Text = "บอสช่อง 1 และช่อง 2 ต้องไม่ซ้ำกัน"
				statusLbl.TextColor3 = T.Danger
				if Farm.MultiBossSetter then Farm.MultiBossSetter(false, false) end
				return
			end

			farmMultiBossClear()
			farmMultiBossAdd(boss1)
			farmMultiBossAdd(boss2)
			Farm.MultiBossSecond = boss2

			if setBossFarmToggle then setBossFarmToggle(false, false) end
			if setNormalFarmToggle then setNormalFarmToggle(false, false) end
			local ok, err = farmSetMultiBoss(true)
			if not ok then
				statusLbl.Text = tostring(err)
				statusLbl.TextColor3 = T.Danger
				if Farm.MultiBossSetter then Farm.MultiBossSetter(false, false) end
				return
			end
			statusLbl.Text = "Multi Boss • " .. boss1 .. " → " .. boss2
			statusLbl.TextColor3 = T.Mint
		else
			farmSetMultiBoss(false)
			statusLbl.Text = "ปิด Multi Boss แล้ว"
			statusLbl.TextColor3 = T.Sub
		end
	end)
	Farm.MultiBossSetter = multiSetter
end

function MobileUI:TagMenuItems(column, group)
	for _, item in ipairs(column:GetChildren()) do
		if item:IsA("GuiObject") and not item:GetAttribute("MenuGroup") then
			item:SetAttribute("MenuGroup", group)
			item:SetAttribute("MenuInitiallyVisible", item.Visible)
		end
	end
end

local function BuildFarmPage(L, R)
		local statusLbl = label(L, "พร้อม", 11, T.Mint, Enum.Font.Gotham,
			UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))

		local setNormalFarmToggle
		local setBossFarmToggle
		local changingFarmMode = false

		local _, _, normalFarmSetter = Section(L, "ฟาร์มมอน (เปิด/ปิด)", false, function(on)
			if changingFarmMode then return end
			if on then
				if not Farm.MobName then
					statusLbl.Text = "ต้องเลือกมอนก่อน"
					statusLbl.TextColor3 = T.Danger
					if setNormalFarmToggle then setNormalFarmToggle(false, false) end
					return
				end

				changingFarmMode = true
				if setBossFarmToggle then setBossFarmToggle(false, false) end
				changingFarmMode = false

				Farm.BossEnabled = false

				-- Fire Profound Demon must take Mitsu's Lv115 quest first.
				if type(Farm.MobName) == "string" and Farm.MobName:lower() == "fire profound demon" then
					statusLbl.Text = "กำลังไปรับเควส Mitsu Lv115..."
					statusLbl.TextColor3 = T.Gold
					local accepted, questErr = farmAcceptMitsuLv115Quest()
					if not accepted then
						statusLbl.Text = "รับเควส Mitsu ไม่สำเร็จ: " .. tostring(questErr)
						statusLbl.TextColor3 = T.Danger
						if setNormalFarmToggle then setNormalFarmToggle(false, false) end
						return
					end
				end

				local cnt = #farmFindMobsByName(Farm.MobName)
				farmSet(true)
				statusLbl.Text = string.format("ฟาร์ม %s (%d ตัว)", Farm.MobName, cnt)
				statusLbl.TextColor3 = T.Mint
			elseif Farm.Enabled and not Farm.BossEnabled then
				farmSet(false)
				statusLbl.Text = "ปิดฟาร์มมอนแล้ว"
				statusLbl.TextColor3 = T.Sub
			end
		end)
		setNormalFarmToggle = normalFarmSetter

		local mobList = farmListMobTypes()
		if #mobList == 0 then mobList = FARM_TYPES end

		local _, getMob, setMobOptions = Dropdown(
			L, "เลือกมอน", "",
			mobList, mobList[1], function(opt)
				local changed = Farm.MobName ~= opt
				Farm.MobName = opt
				if changed and Farm.Enabled and not Farm.BossEnabled then farmResetQuest("mob selection") end
			end
		)
		Farm.MobName = mobList[1]

		SearchDropdownFilter(L, "Search mob...", mobList, getMob, setMobOptions, function(selected)
			if Farm.MobName ~= selected then
				Farm.MobName = selected
				if Farm.Enabled and not Farm.BossEnabled then farmResetQuest("mob search selection") end
			end
		end, statusLbl, "Mob")

		MobileUI:TagMenuItems(L, "Mob")
		local weaponOptions = farmScanWeaponOptions()
		Dropdown(
			L, "เลือกช่องอาวุธ", "ใช้ Item_Equip ช่อง 1-5",
			weaponOptions, Farm.SelectedWeapon, function(opt)
				Farm.SelectedWeapon = opt
				Farm._lastHotbarSelection = nil
				Farm._lastHotbarCharacter = nil
				if Farm.ResetCombo then Farm.ResetCombo() end

				local slot = tonumber(opt:match("^" .. HOTBAR_SLOT_PREFIX .. "(%d+)"))
				if slot then
					local ev = farmGetSignal()
					local ok = ev and pcall(function()
						ev:FireServer("Item_Equip", slot)
					end)
					if ok then
						Farm._lastHotbarSelection = slot
						Farm._lastHotbarCharacter = player.Character
						Farm._lastItemEquipAt = os.clock()
						CombatRuntime.EquipReadyAt = os.clock() + 0.2
						statusLbl.Text = "อาวุธ: ช่อง " .. slot
						statusLbl.TextColor3 = T.Mint
					else
						statusLbl.Text = "เลือกช่องอาวุธไม่สำเร็จ: " .. tostring(slot)
						statusLbl.TextColor3 = T.Danger
					end
				end
			end
		)

		Toggle(L, "Auto รับเควส", false, function(on)
			Farm.AutoQuest = on
			farmResetQuest("auto quest toggle")
		end)

		Button(L, "⟶ รับเควส Mitsu Lv115", T.Card, function()
			local ok, err = farmAcceptMitsuLv115Quest()
			if ok then
				statusLbl.Text = "รับเควส Mitsu • Ill put out the blaze(Lv 115) แล้ว"
				statusLbl.TextColor3 = T.Mint
			else
				statusLbl.Text = "รับเควส Mitsu ไม่สำเร็จ: " .. tostring(err)
				statusLbl.TextColor3 = T.Danger
			end
		end)

		MobileUI:TagMenuItems(L, "Shared")
		local _, _, raidChestSetter = Section(R, "คุมกล่องอัตโนมัติ • จุด 1-10", false, function(on)
			Farm.RaidChest.Label = statusLbl
			Farm.RaidChest:SetEnabled(on)
		end)
		Farm.RaidChest.Setter = raidChestSetter
		Farm.RaidChest.Label = statusLbl
		label(R, "วนวาปตรวจจุด 1-10 → ถ้ามีมอนเกิดให้ตีจนหมด → เปิดกล่อง → เก็บของ → ไปจุดถัดไป",
			10, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 58)).TextWrapped = true

		MobileUI:TagMenuItems(R, "Raids")
		Slider(R, "Mob Hitbox Size", "ขนาด hitbox ของมอนที่ล็อก", 5, 40, Farm.Hitbox, " st", function(val)
			Farm.Hitbox = val
		end)
		Slider(R, "Player Attack Hitbox", "ขยายพื้นที่ตีของ BasePart ทุกชิ้นในอาวุธที่ถืออยู่", 5, 100, Farm.PlayerAttackHitbox, " st", function(val)
			Farm.PlayerAttackHitbox = val
			Farm._hitboxNextAt = 0
		end)
		Slider(R, "ระยะโจมตี", "ระยะเริ่มตี • เซิร์ฟเวอร์เป็นผู้ตรวจว่าตีโดน", 5, 25, Farm.AttackRange, " st", function(val)
			Farm.AttackRange = val
		end)
		Slider(R, "Height Above Head", "อยู่เหนือหัวมอนแล้วตีลงมา ไม่วาปหนี", 1, 8, Farm.HeadHeight, " st", function(val)
			Farm.HeadHeight = val
		end)
		Toggle(R, "Counter Attack When Hit", Farm.CounterAttackOnHit, function(on)
			Farm.CounterAttackOnHit = on
			Farm._counterAttackPending = false
			if on then
				DamageBlock:Release()
				FarmRetreat:Clear()
			end
		end)

		local _, _, bossFarmSetter = Section(L, "ฟาร์มบอส (เปิด/ปิด)", false, function(on)
			if changingFarmMode then return end
			if on then
				if not Farm.BossName then
					statusLbl.Text = "ต้องเลือกบอสก่อน"
					statusLbl.TextColor3 = T.Danger
					if setBossFarmToggle then setBossFarmToggle(false, false) end
					return
				end

				changingFarmMode = true
				if setNormalFarmToggle then setNormalFarmToggle(false, false) end
				changingFarmMode = false

				Farm.BossEnabled = true
				farmSet(true)
				if BOSS_WARP_POSITIONS[Farm.BossName] then
					farmWarpToBossSpawn(Farm.BossName)
				end
				statusLbl.Text = farmFindBoss()
					and ("ฟาร์ม " .. Farm.BossName .. " (boss)")
					or ("รอ " .. Farm.BossName .. " เกิด...")
				statusLbl.TextColor3 = T.Gold
			elseif Farm.Enabled and Farm.BossEnabled then
				farmSet(false)
				statusLbl.Text = "ปิดฟาร์ม " .. tostring(Farm.BossName) .. " แล้ว"
				statusLbl.TextColor3 = T.Sub
			end
		end)
		setBossFarmToggle = bossFarmSetter
		Toggle(L, "เก็บของหลังบอสตาย", Farm.AutoLoot, function(on)
			Farm.AutoLoot = on
			if on then BossLoot:Track(Farm._target) else BossLoot:Reset() end
		end)
		local bossList = farmListBossTypes()
		if #bossList == 0 then bossList = BOSS_TYPES end
		Farm.BossName = bossList[1]
		local _, getBossSelection, setBossOptions = Dropdown(
			L, "เลือกบอสช่องที่ 1", "",
			bossList, Farm.BossName, function(opt)
				if Farm.MultiBossEnabled then
					statusLbl.Text = "เลือก " .. opt .. " • Multi Boss กำลังทำงาน"
					statusLbl.TextColor3 = T.Gold
					return
				end
				local changed = Farm.BossName ~= opt
				Farm.BossName = opt
				if changed and Farm.Enabled and Farm.BossEnabled then
					farmResetQuest("boss selection")
					if BOSS_WARP_POSITIONS[Farm.BossName] then
						farmWarpToBossSpawn(Farm.BossName)
					end
				end
				if Farm.Enabled and Farm.BossEnabled then
					statusLbl.Text = farmFindBoss()
						and ("ฟาร์ม " .. opt .. " (boss)")
						or ("รอ " .. opt .. " เกิด...")
					statusLbl.TextColor3 = T.Gold
				end
			end
		)

		SearchDropdownFilter(L, "Search boss...", bossList, getBossSelection, setBossOptions, function(selected)
			if Farm.MultiBossEnabled then return end
			if Farm.BossName ~= selected then
				Farm.BossName = selected
				if Farm.Enabled and Farm.BossEnabled then
					farmResetQuest("boss search selection")
					if BOSS_WARP_POSITIONS[Farm.BossName] then
						farmWarpToBossSpawn(Farm.BossName)
					end
				end
			end
		end, statusLbl, "Boss")

		BuildMultiBossPanel(L, statusLbl, getBossSelection, setBossFarmToggle, setNormalFarmToggle)
		MobileUI:TagMenuItems(L, "Boss")

		CombatRuntime.PerfLabel = label(R, "FPS / การโจมตี • รอเปิด Auto Attack", 11, T.Sub,
			Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 42))
		CombatRuntime.PerfLabel.TextWrapped = true
		Toggle(R, "Fast Attack", Farm.FastAttack, function(on)
			Farm.FastAttack = on
			CombatRuntime.PreferredDriver = nil
			CombatRuntime:Release()
			CombatRuntime:ResetProgress()
			CombatRuntime.NextAttackAt = 0
			if on and Farm.BypassComboGate then
				CombatRuntime:BindGameComboGate()
			else
				CombatRuntime:UnbindGameComboGate()
			end
		end)
		Toggle(R, "Continuous Combo Reset", Farm.BypassComboGate, function(on)
			Farm.BypassComboGate = on
			if on then
				CombatRuntime:BindGameComboGate()
				CombatRuntime.NextAttackAt = 0
			else
				CombatRuntime:UnbindGameComboGate()
			end
		end)
		Toggle(R, "Combat Trace (manual M1)", false, function(on)
			CombatTrace.Enabled = on
			CombatTrace.ManualClicks = 0
			CombatTrace.Lines = {}
			_G.__MAZX_COMBAT_TRACE = ""
			if on then CombatTrace:Push("TRACE ON • กด M1 เอง 5 ครั้งติด แล้วหยุดรอ 1.5 วิ") end
		end)
		Toggle(R, "No Swing Animation", Farm.NoSwingAnimation, function(on)
			Farm.NoSwingAnimation = on
			if not on then CombatRuntime:RestoreSwingAnimations() end
		end)
		Toggle(R, "Adaptive Fast Attack", Farm.AdaptiveFastAttack, function(on)
			Farm.AdaptiveFastAttack = on
			CombatRuntime.AdaptiveInterval = math.clamp(Farm.AttackInterval, 0.005, 0.08)
			CombatRuntime.NoDamageAttempts = 0
		end)
		Slider(R, "ความเร็วโจมตี", "Burst attack • 5-80 ms ต่อรอบ", 5, 80, Farm.AttackInterval * 1000, " ms", function(val)
			Farm.AttackInterval = val / 1000
			CombatRuntime.AdaptiveInterval = math.clamp(Farm.AttackInterval, 0.005, 0.08)
		end)
		Slider(R, "จำนวน Hit ต่อรอบ", "Fast Attack burst • 1-10 hit", 1, 10, Farm.BurstHits, " hit", function(val)
			Farm.BurstHits = math.floor(val + 0.5)
		end)
		MobileUI:TagMenuItems(R, "Shared")
end

function TP.BuildPage(L, R)
	local statusLbl = label(L, "พร้อม", 11, T.Mint, Enum.Font.Gotham,
		UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))

	local _, getSel = Dropdown(
		L, "NPCs — ทุกโซน", "เลือกแล้ววาปทันที",
		TP.NPCs, TP.NPCs[1], function(name)
			local cf = TP.Destination(name)
			if not cf then
				statusLbl.Text = "ไม่พบพิกัด: " .. tostring(name)
				statusLbl.TextColor3 = T.Danger
				return
			end
			local ok, err = tpSafeGo(cf)
			if ok then
				statusLbl.Text = "→ " .. tostring(name)
				statusLbl.TextColor3 = T.Mint
			else
				statusLbl.Text = "ล้มเหลว: " .. tostring(err)
				statusLbl.TextColor3 = T.Danger
			end
		end
	)

	Button(L, "⟶ วาปไป NPC ที่เลือก", T.Accent, function()
		local name = getSel and getSel()
		local cf = TP.Destination(name)
		if not cf then
			statusLbl.Text = "ไม่พบ: " .. tostring(name)
			statusLbl.TextColor3 = T.Danger
			return
		end
		local ok, err = tpSafeGo(cf)
		if ok then
			statusLbl.Text = "→ " .. name
			statusLbl.TextColor3 = T.Mint
		else
			statusLbl.Text = "ล้มเหลว: " .. tostring(err)
			statusLbl.TextColor3 = T.Danger
		end
	end)

	Button(L, "↻ รีเฟรชรายชื่อ", T.Card, function()
		local found = 0
		for _, npcName in ipairs(TP.NPCs) do
			if TP.Destination(npcName) then found += 1 end
		end
		statusLbl.Text = string.format("เจอ %d / %d", found, #TP.NPCs)
		statusLbl.TextColor3 = (found == #TP.NPCs) and T.Mint or T.Danger
	end)

	BuildPlayerTeleportPanel(L, statusLbl)

	Section(R, "วาปด่วนรายตัว", true)
	for _, npcName in ipairs(TP.NPCs) do
		Button(R, "⟶ " .. npcName, T.Card, function()
			local cf = TP.Destination(npcName)
			if not cf then
				statusLbl.Text = "ไม่พบ: " .. npcName
				statusLbl.TextColor3 = T.Danger
				return
			end
			if tpSafeGo(cf) then
				statusLbl.Text = "→ " .. npcName
				statusLbl.TextColor3 = T.Mint
			else
				statusLbl.Text = "ล้มเหลว: " .. npcName
				statusLbl.TextColor3 = T.Danger
			end
		end)
	end

	Section(R, "อื่น ๆ", false)
	Button(R, "⟶ Spawn", T.Card, function()
		local sp = workspace:FindFirstChildOfClass("SpawnLocation")
		if sp then tpSafeGo(sp.CFrame + Vector3.new(0, 3, 0)) end
	end)
	Button(R, "⟶ ขึ้นฟ้า (+100)", T.Card, function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then tpSafeGo(hrp.CFrame + Vector3.new(0, 100, 0)) end
	end)
	Button(R, "⟶ ลงพื้น (Raycast)", T.Card, function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local ray = Ray.new(hrp.Position, Vector3.new(0, -500, 0))
		local hit = workspace:FindPartOnRay(ray, player.Character)
		if hit then tpSafeGo(CFrame.new(hit.Position + Vector3.new(0, 3, 0))) end
	end)
end

--------------------------------------------------------------
-- TABS + NAV + UI PAGES
--------------------------------------------------------------
MobileUI.MenuGroups = {
	{ Name = "Farm", Tabs = {
		{ "Mob Farm", "Farm", "Mob" }, { "Boss Farm", "Farm", "Boss" },
		{ "Quests", "Quest", "Quests" }, { "Dungeon", "Quest", "Dungeon" },
		{ "Raids", "Farm", "Raids" }, { "Status", "Status" },
	} },
	{ Name = "World", Tabs = { { "World", "World" }, { "Teleport", "Teleport" } } },
	{ Name = "Player", Tabs = { { "Player", "Player" }, { "Combat", "Combat" }, { "Visuals", "Visuals" } } },
	{ Name = "Setting", Tabs = { { "Settings", "Setting" } } },
}

function MobileUI:SelectMenuTab(entry)
	-- Never carry an expanded dropdown into another Farm/Boss tab.
	if self.ActiveDropdownClose then self.ActiveDropdownClose() end
	for name, page in pairs(pages) do page.Visible = name == entry[2] end
	local columns = self.Pages[entry[2]]
	if not columns then return end
	for _, column in ipairs(columns) do
		column.CanvasPosition = Vector2.new(0, 0)
		for _, item in ipairs(column:GetChildren()) do
			local group = item:GetAttribute("MenuGroup")
			if item:IsA("GuiObject") and group then
				local matches = group == entry[3] or (group == "Shared" and (entry[3] == "Mob" or entry[3] == "Boss"))
				item.Visible = item:GetAttribute("MenuInitiallyVisible") and matches
			end
		end
	end
	if self.Compact then
		self.Column = (entry[3] == "Dungeon" or entry[3] == "Raids") and 2 or 1
		self:ApplyColumns()
	end
end

function MobileUI:SelectMenuGroup(group)
	activeTabSet = nil
	for _, item in ipairs(tabs:GetChildren()) do if item:IsA("TextButton") then item:Destroy() end end
	tabs.CanvasPosition = Vector2.new(0, 0)
	for index, entry in ipairs(group.Tabs) do
		addTab(entry[1], "", index == (group.Selected or 1), function()
			group.Selected = index
			self:SelectMenuTab(entry)
		end)
	end
end

-- Keep page-building temporaries out of the startup function's register frame.
-- Some executors compile with optimization disabled (200-register limit).
function MobileUI:BuildMenuPages()
MazxBoot.Stage = "building menu pages"
local navItems = {
	{"Farm",      "⚒"},
	{"Quest",     "Q"},
	{"Status",    "◷"},
	{"World",     "◉"},
	{"Combat",    "⚔"},
	{"Player",    "♟"},
	{"Visuals",   "◈"},
	{"Teleport",  "➤"},
	{"Setting",   "⚙"},
}

for i, v in ipairs(navItems) do
	MazxBoot.Stage = "building " .. v[1] .. " page"
	local L, R = makePage(v[1])

	if v[1] == "Quest" then
		BuildQuestPage(L, R)
		self:TagMenuItems(L, "Quests")
		self:TagMenuItems(R, "Dungeon")
	end

	if v[1] == "Farm" then
		BuildFarmPage(L, R)
	end
	if v[1] == "Status" then
		BuildStatusPage(L, R)
	end
	if v[1] == "World" then
		local worldStatus = label(L, "World ready", 11, T.Mint, Enum.Font.Gotham,
			UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))

		Section(R, "Npc LV 1-7", true)
		Button(R, "⟶ Krue", T.Card, function()
			local npc = tpFindNPC("Krue")
			if not npc then
				worldStatus.Text = "Krue not found"
				worldStatus.TextColor3 = T.Danger
				return
			end
			local ok, err = tpSafeGo(tpCFrameOf(npc))
			if ok then
				worldStatus.Text = "→ Krue"
				worldStatus.TextColor3 = T.Mint
			else
				worldStatus.Text = "Teleport failed: " .. tostring(err)
				worldStatus.TextColor3 = T.Danger
			end
		end)

		Section(R, "Pushups", true)
		AutoPushups.Label = worldStatus
		Toggle(R, "Auto Pushups", false, function(on)
			AutoPushups:SetEnabled(on)
		end)
		label(R, "ตรวจวงกลมสีขาวและคลิกซ้ายอัตโนมัติเมื่อขอบวงนอกหดมาพอดีกับวงเป้าหมาย",
			11, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 42)).TextWrapped = true

		Section(L, "Cup Game", true)
		CupGame.Label = worldStatus
		Toggle(L, "ESP Cup2", false, function(on)
			CupGame:SetEnabled(on)
		end)
		label(L, "Outline สีขาวเฉพาะ workspace.Training[\"Cup Game\"].Cupgame1.Cups.Cup2",
			11, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 34)).TextWrapped = true

		Section(L, "ปราณสายฟ้า", true)
		ThunderBreathing.Label = worldStatus
		Toggle(L, "Auto ทำปราณสายฟ้า", false, function(on)
			ThunderBreathing:SetEnabled(on)
		end)
		Button(L, "⚡ Thunder Trainer Zentaro", T.Card, function()
			local cf = TP.Destination("Thunder Trainer Zentaro")
			if not cf then
				worldStatus.Text = "Thunder Trainer Zentaro not found"
				worldStatus.TextColor3 = T.Danger
				return
			end
			local ok, err = tpSafeGo(cf)
			if ok then
				worldStatus.Text = "→ Thunder Trainer Zentaro • ปราณสายฟ้า"
				worldStatus.TextColor3 = T.Mint
			else
				worldStatus.Text = "Teleport failed: " .. tostring(err)
				worldStatus.TextColor3 = T.Danger
			end
		end)
	end

	if v[1] == "Combat" then
		local aimStatus = label(L, "Aimbot ready", 11, T.Mint, Enum.Font.Gotham,
			UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18))

		Section(L, "Aimbot", false, function(on)
			Aimbot.Enabled = on
			aimStatus.Text = on and "Aimbot enabled • hold Right Mouse to lock" or "Aimbot disabled"
			aimStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		Toggle(L, "Show FOV circle", Aimbot.ShowFOV, function(on)
			Aimbot.ShowFOV = on
		end)
		Slider(L, "FOV radius", "Circle follows mouse • hold Left Alt = screen center",
			50, 500, Aimbot.FOV, " px", function(value)
				Aimbot.FOV = math.floor(value + 0.5)
			end)

		Section(R, "Targets", true)
		Toggle(R, "Aim at players", true, function(on) Aimbot.TargetPlayers = on end)
		Toggle(R, "Aim at NPCs", true, function(on) Aimbot.TargetNPCs = on end)

		Section(R, "Aimbot Skills", false, function(on)
			Aimbot.SkillEnabled = on
			aimStatus.Text = on and "Skill aimbot enabled • Z X C V B N K" or "Skill aimbot disabled"
			aimStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		local skillHint = label(R,
			"Z  X  C  V  B  N  K\nHold Right Mouse + a skill key to lock the closest target inside FOV.",
			11, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 44))
		skillHint.TextWrapped = true
		label(R, "Hold Left Alt to move the FOV circle to the center of the screen.",
			10, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 36)).TextWrapped = true
	end

	if v[1] == "Player" then
		local playerStatus = label(L, "พร้อม", 11, T.Mint, Enum.Font.Gotham,
			UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16))

		Section(L, "การเคลื่อนที่", true)
		Toggle(L, "วิ่งไว", false, function(on)
			playerModsSetSpeed(on)
			playerStatus.Text = on and ("เปิดวิ่งไว: " .. PlayerMods.WalkSpeed) or "ปิดวิ่งไวแล้ว"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		Slider(L, "ความเร็ววิ่ง", "", 16, 150, 40, "", function(val)
			PlayerMods.WalkSpeed = math.floor(val + 0.5)
			if PlayerMods.SpeedEnabled then playerModsSetSpeed(true) end
		end)

		Toggle(L, "กระโดดสูง", false, function(on)
			playerModsSetJump(on)
			playerStatus.Text = on and ("เปิดกระโดดสูง: " .. PlayerMods.JumpPower) or "ปิดกระโดดสูงแล้ว"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		Slider(L, "แรงกระโดด", "", 50, 200, 100, "", function(val)
			PlayerMods.JumpPower = math.floor(val + 0.5)
			if PlayerMods.JumpEnabled then playerModsSetJump(true) end
		end)

		Toggle(L, "Fly", false, function(on)
			playerModsSetFly(on)
			playerStatus.Text = on and ("เปิด Fly • Speed " .. PlayerMods.FlySpeed)
				or "ปิด Fly แล้ว"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		Slider(L, "Fly Speed", "WASD • Space ขึ้น • Ctrl ลง", 20, 500, PlayerMods.FlySpeed, "", function(val)
			PlayerMods.FlySpeed = math.floor(val + 0.5)
		end)

		Section(R, "ทดสอบระยะตี", true)
		Toggle(R, "ทดสอบ Hitbox การตี", Farm.PlayerHitboxTest, function(on)
			Farm.PlayerHitboxTest = on
			Farm._hitboxNextAt = 0
			if not on and not Farm.Enabled then farmRestorePlayerHitbox() end
			playerStatus.Text = on
				and "เปิดทดสอบ Hitbox • ถืออาวุธแล้วลองตีมอนด้วยตัวเอง"
				or "ปิดทดสอบ Hitbox • คืนขนาดอาวุธเดิม"
			playerStatus.TextColor3 = on and T.Gold or T.Sub
		end)
		Slider(R, "ระยะ Hitbox การตี", "เปิดโหมดทดสอบ แล้วถืออาวุธลองตีเอง • 5-100 studs", 5, 100, Farm.PlayerAttackHitbox, " st", function(val)
			Farm.PlayerAttackHitbox = math.floor(val + 0.5)
			Farm._hitboxNextAt = 0
		end)
		label(R, "Hitbox ที่ขยายจะเห็นเป็นชิ้นอาวุธโปร่งใส • ถ้าตีไกลแล้วยังไม่โดน แปลว่าเซิร์ฟเวอร์ตรวจระยะเอง",
			10, T.Sub, Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 42)).TextWrapped = true

		Section(R, "การชน", true)
		Toggle(R, "No Clip", false, function(on)
			playerModsSetNoClip(on)
			playerStatus.Text = on and "เปิด No Clip" or "ปิด No Clip และคืนค่าการชนแล้ว"
			playerStatus.TextColor3 = on and T.Gold or T.Sub
		end)

		Section(R, "Environment", true)
		Toggle(R, "Full Bright", false, function(on)
			fullBrightSet(on)
			playerStatus.Text = on and "Full Bright enabled" or "Full Bright disabled; lighting restored"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		label(R, "Increase brightness • disable shadows • lock daylight", 11, T.Sub, Enum.Font.Gotham,
			nil, UDim2.new(1, 0, 0, 24))
		Toggle(R, "No Fog (ลบหมอก)", false, function(on)
			noFogSet(on)
			playerStatus.Text = on and "เปิด No Fog" or "ปิด No Fog"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		Toggle(R, "ลบ Atmosphere", false, function(on)
			for _, a in ipairs(Lighting:GetChildren()) do
				if a:IsA("Atmosphere") then
					a.Density = on and 0 or 0.3
				end
			end
		end)
		Slider(R, "Fog End", "ระยะไกลสุดของหมอก", 100, 5000, 1000, " st", function(val)
			if NoFog.Enabled then return end
			Lighting.FogEnd = val
		end)

		Section(L, "Invisible", true)
		Toggle(L, "Invisible", false, function(on)
			InvisibleMode:SetEnabled(on)
			playerStatus.Text = on and "Invisible enabled • local ghost visible" or "Invisible disabled"
			playerStatus.TextColor3 = on and T.Mint or T.Sub
		end)
		label(L, "ตัวจริงถูกซ่อน • ฝั่งผู้ใช้เห็นเป็นเงาจางๆ", 11, T.Sub, Enum.Font.Gotham,
			nil, UDim2.new(1, 0, 0, 30)).TextWrapped = true

		Section(R, "สกิลอัตโนมัติ", false, function(on)
			AutoSkills:SetEnabled(on)
			playerStatus.Text = on and "เปิดสกิลอัตโนมัติแล้ว" or "ปิดสกิลอัตโนมัติแล้ว"
		end)
		AutoSkills.OnError = function() playerStatus.Text = "ส่งปุ่มสกิลไม่สำเร็จ" end
		if MobileUI.Touch then
			local skillHint = label(R, "สกิลออโต้บนมือถือขึ้นกับการรองรับปุ่มจำลองของตัวรัน", 11, T.Sub,
				Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 42))
			skillHint.TextWrapped = true
		end
		for _, key in ipairs(AutoSkills.Keys) do
			local setting = AutoSkills.Settings[key]
			Toggle(R, "สกิล " .. key, false, function(on)
				setting.Enabled = on
				setting.NextAt = 0
				if not on and AutoSkills.Held and AutoSkills.Held.Name == key then AutoSkills:Release() end
			end)
			Slider(R, "ช่วงเวลากด " .. key, "",
				0.1, 10, setting.Interval, " s", function(value)
					setting.Interval = math.floor(value * 10 + 0.5) / 10
					setting.NextAt = os.clock() + setting.Interval
				end)
		end
	end

	if v[1] == "Visuals" then
		Section(L, "ESP ผู้เล่น", false, function(on)
			ESP.Enabled = on
			refreshAllESP()
			for _, d in pairs(ESP._cache) do
				if d.billboard then d.billboard.Enabled = on end
			end
		end)
		Toggle(L, "ESP Line", false, function(on)
			ESP.Lines = on
			if on then refreshAllESP() end
			if not on then
				for _, d in pairs(ESP._cache) do d.line.Visible = false end
				for _, d in pairs(NPC_ESP._cache) do d.line.Visible = false end
			end
		end)
		Toggle(L, "ESP Outline", false, function(on)
			ESP.Outlines = on
			for _, d in pairs(ESP._cache) do
				if d.highlight then d.highlight.Enabled = on end
			end
		end)
		ColorRow(L, "ESP สีหลัก", "#8B7CF6", ESP.Color, function(c, sw, hexLbl)
			ESP.Color = c
			sw.BackgroundColor3 = c
			local r = math.floor(c.R * 255 + 0.5)
			local g = math.floor(c.G * 255 + 0.5)
			local b = math.floor(c.B * 255 + 0.5)
			hexLbl.Text = string.format("#%02X%02X%02X", r, g, b)
			for _, d in pairs(ESP._cache) do
				if d.nameLbl then d.nameLbl.TextColor3 = c end
				if d.line    then d.line.BackgroundColor3 = c end
			end
		end)
		ColorRow(L, "ESP สี Outline", "#FFFFFF", ESP.OutlineColor, function(c, sw, hexLbl)
			ESP.OutlineColor = c
			sw.BackgroundColor3 = c
			local r = math.floor(c.R * 255 + 0.5)
			local g = math.floor(c.G * 255 + 0.5)
			local b = math.floor(c.B * 255 + 0.5)
			hexLbl.Text = string.format("#%02X%02X%02X", r, g, b)
			for _, d in pairs(ESP._cache) do
				if d.highlight then d.highlight.OutlineColor = c end
			end
		end)
		Slider(L, "ESP ระยะสูงสุด", "Max render distance", 100, 3000, 1000, " st", function(val)
			ESP.MaxDistance = val
			NPC_ESP.MaxDistance = val
			for _, d in pairs(ESP._cache) do
				if d.billboard then d.billboard.MaxDistance = val end
			end
			for _, d in pairs(NPC_ESP._cache) do
				if d.billboard then d.billboard.MaxDistance = val end
			end
		end)

		label(R, "ESP NPC ใน ActiveNpcs", 13, T.Text, Enum.Font.GothamBold,
			nil, UDim2.new(1, 0, 0, 36))
		Toggle(R, "ESP Bandit", false, function(on)
			NPC_ESP.Bandit = on
			refreshNpcESP()
		end)
		Toggle(R, "ESP Civilian", false, function(on)
			NPC_ESP.Civilian = on
			refreshNpcESP()
		end)
		label(R, "Bandit = สีแดง  •  Civilian = สีเขียว", 11, T.Sub,
			Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 24))

		Section(R, "ESP บอสทั้งหมด (เปิด/ปิด)", false, function(on)
			NPC_ESP.BossEnabled = on
			refreshNpcESP()
		end)
		label(R, "สีทอง • เลือกบอสที่ต้องการแสดงด้านล่าง", 11, T.Sub,
			Enum.Font.Gotham, nil, UDim2.new(1, 0, 0, 24))
		for _, name in ipairs(BOSS_TYPES) do
			Toggle(R, "ESP " .. name, true, function(on)
				NPC_ESP.BossSelected[name] = on
				refreshNpcESP()
			end)
		end
	end

	if v[1] == "Teleport" then
		TP.BuildPage(L, R)
	end

	if v[1] == "Setting" then
		Section(L, "ภาษา", true)
		Dropdown(L, "ภาษาเมนู", "เปลี่ยนข้อความทุกหน้าทันที",
			{ "ไทย / Thai", "English" }, I18N.Language == "en" and "English" or "ไทย / Thai",
			function(option) I18N:SetLanguage(option == "English" and "en" or "th") end)

		Section(L, "Player labels", true)
		Keybind(L, "Use keybind", Enum.KeyCode.RightShift)
		Dropdown(L, "Label layout", "Stacking style", {"Stacked", "Inline", "Compact"}, "Stacked")
		Slider(L, "Label scale", "Text size multiplier", 50, 200, 100, "%")
		Toggle(L, "Show distance", true)
		Toggle(L, "Hide when aiming", false)

		Section(R, "Interface", true)
		Toggle(R, "Blur background", false)
		Toggle(R, "Animations", true)
		Slider(R, "UI opacity", "Panel transparency", 0, 100, Appearance.Opacity, "%", function(value)
			Appearance:SetOpacity(value)
		end)
	end
end

local firstSelect
for _, group in ipairs(self.MenuGroups) do
	local _, select = addNav(group.Name, "", function() self:SelectMenuGroup(group) end)
	firstSelect = firstSelect or select
end
if firstSelect then firstSelect() end
end

MobileUI:BuildMenuPages()

--------------------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------------------
local isOpen = false

MobileUI.ColumnButton = new("TextButton", {
	Name = "ColumnSwitch", Size = UDim2.fromOffset(126, 44), Position = UDim2.fromOffset(8, 7),
	BackgroundColor3 = T.Card, Text = "ปรับค่า →", TextSize = 12, TextColor3 = T.Accent,
	Font = Enum.Font.GothamBold, AutoButtonColor = false, Visible = false, ZIndex = 6,
}, top)
corner(MobileUI.ColumnButton, 8)

function MobileUI:LayoutFor(width, height)
	local compact = width < 780 or height < 430 or (self.Touch and width < 950)
	return {
		Compact = compact,
		Width = math.max(1, math.min(740, width - 16)),
		Height = math.max(1, math.min(self.Touch and compact and 700 or 500, height - 16)),
	}
end

function MobileUI:ClampPoint(x, y, width, height, viewWidth, viewHeight, centered)
	local ax, ay = centered and width * 0.5 or 0, centered and height * 0.5 or 0
	local lowX, lowY = 4 + ax, 4 + ay
	local highX, highY = math.max(lowX, viewWidth - width + ax - 4), math.max(lowY, viewHeight - height + ay - 4)
	return Vector2.new(math.clamp(x, lowX, highX), math.clamp(y, lowY, highY))
end

-- Main window may be dragged mostly outside the screen.
-- Keep only a small grab area visible so it cannot be lost permanently.
function MobileUI:ClampWindowPoint(x, y, width, height, viewWidth, viewHeight)
	local keepVisible = 44
	local halfW, halfH = width * 0.5, height * 0.5
	local lowX = -halfW + keepVisible
	local highX = viewWidth + halfW - keepVisible
	local lowY = -halfH + keepVisible
	local highY = viewHeight + halfH - keepVisible
	return Vector2.new(math.clamp(x, lowX, highX), math.clamp(y, lowY, highY))
end

function MobileUI:ApplyColumns()
	for _, columns in pairs(self.Pages) do
		for index, column in ipairs(columns) do
			column.Visible = not self.Compact or index == self.Column
			column.Size = self.Compact and UDim2.new(1, -24, 1, -12) or UDim2.new(0.5, -24, 1, -12)
			column.Position = self.Compact and UDim2.fromOffset(12, 0)
				or UDim2.new(0.5 * (index - 1), index == 1 and 16 or 8, 0, 0)
			column.ScrollBarThickness = self.Touch and 6 or 3
		end
	end
	self.ColumnButton.Visible = self.Compact
	self.ColumnButton.Text = self.Column == 1 and "ปรับค่า →" or "← ตัวเลือก"
end

function MobileUI:Layout(recenter)
	local size = self.Surface.AbsoluteSize
	if size.X < 1 or size.Y < 1 then return end
	self:CancelDrags()
	local layout = self:LayoutFor(size.X, size.Y)
	self.Compact = layout.Compact
	main.Size = UDim2.fromOffset(layout.Width, layout.Height)
	local center = recenter and Vector2.new(size.X * 0.5, size.Y * 0.5)
		or Vector2.new(main.Position.X.Scale * size.X + main.Position.X.Offset,
			main.Position.Y.Scale * size.Y + main.Position.Y.Offset)
	center = recenter
		and center
		or self:ClampWindowPoint(center.X, center.Y, layout.Width, layout.Height, size.X, size.Y)
	main.Position = UDim2.fromOffset(center.X, center.Y)

	head.Visible, menuHint.Visible, sidebarEdge.Visible = not self.Compact, not self.Compact, not self.Compact
	sidebarDivider.Visible = not self.Compact
	sidebar.Size = self.Compact and UDim2.new(1, 0, 0, 52) or UDim2.new(0, 96, 1, 0)
	navList.Size = self.Compact and UDim2.new(1, 0, 0, 50) or UDim2.new(1, 0, 1, -136)
	navList.Position = self.Compact and UDim2.fromOffset(0, 2) or UDim2.fromOffset(0, 88)
	navList.ScrollingDirection = self.Compact and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
	navList.AutomaticCanvasSize = self.Compact and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
	navLayout.FillDirection = self.Compact and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
	for _, button in ipairs(navList:GetChildren()) do
		if button:IsA("TextButton") then
			button.Size = self.Compact and UDim2.fromOffset(110, 44)
				or UDim2.new(1, 0, 0, self.Touch and 44 or 36)
		end
	end
	right.Size = self.Compact and UDim2.new(1, 0, 1, -52) or UDim2.new(1, -96, 1, 0)
	right.Position = self.Compact and UDim2.fromOffset(0, 52) or UDim2.fromOffset(96, 0)
	search.Visible, tabs.Visible = not self.Compact, true
	self.TechCaption.Visible = not self.Compact
	hubName.Size = UDim2.fromOffset(self.Compact and 100 or 120, 30)
	hubName.Position = UDim2.new(1, self.Compact and -158 or -176, 0, 15)
	close.Size = UDim2.fromOffset(self.Touch and 44 or 32, self.Touch and 44 or 32)
	close.Position = UDim2.new(1, self.Touch and -50 or -40, 0, self.Touch and 7 or 13)
	self:ApplyColumns()

	local point = self:ClampPoint(
		fab.Position.X.Scale * size.X + fab.Position.X.Offset,
		fab.Position.Y.Scale * size.Y + fab.Position.Y.Offset,
		52, 52, size.X, size.Y, false)
	fab.Position = UDim2.fromOffset(point.X, point.Y)
end

function MobileUI:SafeArea()
	local ok, first, last = pcall(function() return GuiService:GetGuiInset() end)
	local left, upper, rightInset, lower = 0, 0, 0, 0
	if ok then left, upper, rightInset, lower = first.X, first.Y, last.X, last.Y end
	self.Surface.Position = UDim2.fromOffset(left, upper)
	self.Surface.Size = UDim2.new(1, -left - rightInset, 1, -upper - lower)
end

local function setOpen(state)
	isOpen = state
	MobileUI:CancelDrags()
	if not state and MobileUI.ActiveDropdownClose then
		MobileUI.ActiveDropdownClose()
	end
	if state then
		MobileUI:Layout(false)
		Appearance:SetOpacity(Appearance.Opacity)
	end
	main.Visible = state
end

MobileUI.ColumnButton.Activated:Connect(function()
	MobileUI:CancelDrags()
	MobileUI.Column = MobileUI.Column == 1 and 2 or 1
	MobileUI:ApplyColumns()
end)

function MobileUI:BindDrag(handle, target, centered, tap)
	local held, start, startPosition, moved
	local function cancel() held, start, startPosition = nil, nil, nil end
	self.Drags[cancel] = true
	handle.InputBegan:Connect(function(input)
		if held or (input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch) then return end
		held, start, moved = input, input.Position, 0
		local size = self.Surface.AbsoluteSize
		startPosition = Vector2.new(target.Position.X.Scale * size.X + target.Position.X.Offset,
			target.Position.Y.Scale * size.Y + target.Position.Y.Offset)
	end)
	self:Connect(UserInputService.InputChanged, function(input)
		if not self:OwnsMove(held, input) then return end
		local delta = input.Position - start
		moved = math.max(moved, delta.Magnitude)
		local size, bounds = self.Surface.AbsoluteSize, target.AbsoluteSize
		local point
		if target == main then
			point = self:ClampWindowPoint(startPosition.X + delta.X, startPosition.Y + delta.Y,
				bounds.X, bounds.Y, size.X, size.Y)
		else
			point = self:ClampPoint(startPosition.X + delta.X, startPosition.Y + delta.Y,
				bounds.X, bounds.Y, size.X, size.Y, centered)
		end
		target.Position = UDim2.fromOffset(point.X, point.Y)
	end)
	self:Connect(UserInputService.InputEnded, function(input)
		if input ~= held then return end
		local tapped = moved < 8
		cancel()
		if tapped and tap then tap() end
	end)
end

MobileUI:BindDrag(fab, fab, false, function() setOpen(not isOpen) end)
local dragHandle = new("Frame", {
	Name = "WindowDrag", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Active = true, ZIndex = 4,
}, top)
MobileUI:BindDrag(dragHandle, main, true)

close.Activated:Connect(function() setOpen(false) end)
MobileUI:Connect(UserInputService.InputBegan, function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then setOpen(not isOpen) end
end)
MobileUI:Connect(UserInputService.WindowFocusReleased, function() MobileUI:CancelDrags() end)
MobileUI:Connect(MobileUI.Surface:GetPropertyChangedSignal("AbsoluteSize"), function() MobileUI:Layout(true) end)
MobileUI:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function() MobileUI:SafeArea(); MobileUI:Layout(true) end)
pcall(function()
	MobileUI:Connect(GuiService:GetPropertyChangedSignal("TopbarInset"), function()
		MobileUI:SafeArea(); MobileUI:Layout(true)
	end)
end)
gui.Destroying:Connect(function()
	MobileUI:CancelDrags()
	for _, connection in ipairs(MobileUI.Connections) do connection:Disconnect() end
	MobileUI.Connections, MobileUI.Drags = {}, {}
end)
MobileUI:SafeArea()
MobileUI:Layout(true)
if MobileUI.Touch then setOpen(true) end
-- END MAZXHUB UI
end

local startupOK, startupError = xpcall(startMazxhub, function(message)
	if debug and debug.traceback then return debug.traceback(tostring(message), 2) end
	return tostring(message)
end)
if startupOK then
	MazxBoot.Finished = true
	MazxBoot.Stage = "ready"
	if MazxBoot.Panel then pcall(function() MazxBoot.Panel:Destroy() end) end
	warn("[Mazxhub/android-startup-1] READY")
else
	MazxBoot:Fail(startupError)
end
