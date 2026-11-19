--[[
1Mag.ez  (no key system, crash-fixed, fast skin loading)
- Hub opens instantly
- Skins/cosmetics are applied immediately (batched, one viewmodel refresh)
- Everything else in your saved config loads 2 seconds after the hub is up
]]
local FX = {}
FX.HB = {size = 40, trans = 0, locked = false, apply = function() end}
do
local RS = game:GetService("RunService")
FX.Scale = 0.84
local body = Font.fromEnum(Enum.Font.Fantasy)
local heavy = body
pcall(function() heavy = Font.new(body.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal) end)
FX.Body, FX.Heavy = body, heavy
local SEQ = ColorSequence.new({
ColorSequenceKeypoint.new(0,    Color3.fromRGB(205, 205, 205)),
ColorSequenceKeypoint.new(0.34, Color3.fromRGB(205, 205, 205)),
ColorSequenceKeypoint.new(0.43, Color3.fromRGB(205, 255, 255)),
ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(0.57, Color3.fromRGB(255, 215, 255)),
ColorSequenceKeypoint.new(0.66, Color3.fromRGB(205, 205, 205)),
ColorSequenceKeypoint.new(1,    Color3.fromRGB(205, 205, 205)),
})
function FX.shimmer() end
end
local function loadMain()
--[[
1Mag.ez Freemium  (v1.2)
Workspace layout:
1MagHub/1Mag.lua
1MagHub/Assets/logo.png   (auto-written if missing)
1MagHub/Profiles/*.json   (config profiles)
1MagHub/config.json
Sidebar "Tabs" dropdown -> main tabs.  Horizontal sub tabs across the top of each tab.
]]
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Stats        = game:GetService("Stats")
local Marketplace  = game:GetService("MarketplaceService")
local HttpService  = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer
local PG = player:WaitForChild("PlayerGui")
local ROOT      = "1MagHub"
local ASSETS    = ROOT .. "/Assets"
local PROFILES  = ROOT .. "/Profiles"
local CONFIG    = ROOT .. "/config.json"
local LOGO_FILE = ASSETS .. "/logo.png"
local function ensureFolder(path)
if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return end
local acc = ""
for part in path:gmatch("[^/]+") do
acc = (acc == "" and part or acc .. "/" .. part)
pcall(function() if not isfolder(acc) then makefolder(acc) end end)
end
end
ensureFolder(ROOT); ensureFolder(ASSETS); ensureFolder(PROFILES)
local LOGO_ID
local LOGO_TINT = false
-- Decoded monochrome icon atlas: transparent background + white glyph pixels.
-- The theme engine tints the glyph fill and outline independently.
local ICON_PATH = ASSETS .. "/1mag_icons_decoded.png"
local ICON_SHEET
local ICON_DATA = table.concat({
        "iVBORw0KGgoAAAANSUhEUgAABgAAAAQACAYAAAAncZJCAAD+gElEQVR42uzdd5zsVN348c/s3r2XXsReH/VRRFFBFAEVFQsK2EVUrFhQFLvYsPeODVEsYEWw",
        "gYIKAlYQBaSD+vOxYENUOtyyu/P74yTO2dzpm2SSyef9es1rdqckmZNvktNyDkiSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSpPW0TAJJkiRpNO12e9Kb8BhgE+BL01AeaLUslkiSJElFWGHhrV2lzXkK8JUqFsosoEmSvE739Vzg",
        "8GEuo16fNabdgDcBD8z7MKt63lONOY8W5ZnAEdH/5wDbe16VJElN0fgcTcUyxN025iPAyyoVNGaE84y9tsfl0M4ANgL+Tafyo2U8Sl6nK3wNLzX/5flwamOz",
        "DawGNpjmsoLx63m05PNzy7iUJHktL7TMM9G8pdf3Cia8B9HAg+hRwHcrEzRmhPOMvUEBeAVwo4Ym0cOAEweHo/EoeZ2uZUY495OX58Opis29gO80qcxg/Db+",
        "PDqJ83PLuJyaGGyXeb6qGuNU8jxa4TLPRPKVnjfXN+NhVIuKg+8A9zCZGmnLJD7SxwVT+Bs/BRwEfC3zW09090uagmt40RloTZ8vUq3K/zRe54HXuHtUMdsD",
        "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",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIk",
        "SZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIqomUSSPlrt9t12Mz3AgdlXvstsHUtTl4tT1+SJEmSJElSP9agSQWo",
        "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",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmS",
        "JEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJEmSJGl5WibBYO12u06b+xtgQ2At8Bfg9sB3gRfVIiBbhqQkSZIk",
        "5Vie3Q94M3BT4N3A20wVy6KSpAZd40yCoTJMtdnUPu+9APiUmS5JkiRJalR59izgXl3eugq4Brg6KUuuAxaARWAm+cxC8vcKYANgFTAHzCafWyDUK/wF2KXg",
        "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",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AEBn9ewCAACg1O/3j+JrX5rkhkk+N8k5Q96/d73MeBmeniwPAAAAAAAkqSoAFvy4f/9wnj3uugEAYJ1pDgPA2hlRIPTdSS5Ocn7r9c36kSQb9fNuku0kO0m2",
        "6ufmsVs/N8s1n+vV6znWWmfzfrNsv7WO9rqabdoo1nO8fpxI1Wr2WJKTxWffluTVexIAWsR2Lf6W0d2TvHIe6UzxuXZxOsmX9cQTAECn8yHPSvL3Sa5Rp93O",
        "1M8n6nzsdZO8IMlbF7VB65oulBqG9bnIawI3t/uHS+kKJHzW4fzoSfisbcJ7Hh6S5PnzSmuKz7WK02m+qCeeAHB/XqvMtyBYnvgZ58t6Ymi+jgl/WI/rvF0w",
        "130rFbK87pTkz8QqHNoFSa4k7uhI+kR8AcDhvDTJhRn0Rt5N1YN4M9UcOzBLp6XpumXDLgBgjf3Zmv1elYEcFB/9feLkfhmv8F/csZ/nzmg9z7crAWBfv5hq",
        "iJX/TPKhJB9J8okk/5Xk35P8tF3EjClvdkAA4MjdNetbKKkwlsPExbA4+d0ktxR3zMDbkjxsn/d7Qx6/OGLZhyT5NrsUAIZ6epKPJzk31dxlZ1K1zj5d31+P",
        "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",
        "8xOiiyegA/fpZyT5gSXbFXoASEdO47dSzZd2Ism1UzUQOZMp54QSP9ChCzoASDgnSb49yW+PsfxHU7Winn8CQOJZxm0+npRqcuBLklyY5FSqOWi+XXyudJwe",
        "RVA/KMmLxBOwRPfpZUoAzO3C6ZoMsEIXdQAAYDlNUAB2iyRv62L+RWETAADrzBwAAADAtN6eqnD+7qnmRZnHupXkAwAAAADANPr9/iwe39Of3Ev7/f7dZrEd",
        "AACwzrSiAQAA9phxwfm4K7trqrkjZpPhMQQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "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",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALCC/n/SqZgLSAHj3gAAAABJRU5ErkJggg=="
})
local function decodeB64(DATA)
    local decoded
    pcall(function()
        if crypt and type(crypt.base64decode) == "function" then
            decoded = crypt.base64decode(DATA)
        elseif crypt and crypt.base64 and type(crypt.base64.decode) == "function" then
            decoded = crypt.base64.decode(DATA)
        end
    end)
    if not decoded then
        pcall(function()
            if syn and syn.crypt and syn.crypt.base64 and type(syn.crypt.base64.decode) == "function" then
                decoded = syn.crypt.base64.decode(DATA)
            end
        end)
    end
    if not decoded then
        pcall(function()
            if type(base64decode) == "function" then decoded = base64decode(DATA) end
        end)
    end
    if not decoded then
        pcall(function()
            if type(HttpService.Base64Decode) == "function" then decoded = HttpService:Base64Decode(DATA) end
        end)
    end
    return decoded
end
local function decodeIconAtlas() return decodeB64(ICON_DATA) end
if type(writefile) == "function" then
    local decoded = decodeIconAtlas()
    if type(decoded) == "string" and decoded:sub(2,4) == "PNG" then
        pcall(writefile, ICON_PATH, decoded)
    end
end
if type(getcustomasset) == "function" and type(isfile) == "function" then
    pcall(function()
        if isfile(ICON_PATH) then ICON_SHEET = getcustomasset(ICON_PATH) end
    end)
elseif type(getsynasset) == "function" and type(isfile) == "function" then
    pcall(function()
        if isfile(ICON_PATH) then ICON_SHEET = getsynasset(ICON_PATH) end
    end)
end
local SLIDE_ICON_PATH = ASSETS .. "/1mag_slide_icon.png"
local SLIDE_ICON, SLIDE_ICON_W, SLIDE_ICON_H = nil, 52, 38
local SLIDE_ICON_DATA = "iVBORw0KGgoAAAANSUhEUgAAADQAAAAmCAYAAACLZrh7AAAEz0lEQVR42s2ZW2hcVRSGv5mMM2PSpK1Jm0isMYa0KlHRIlVRvISCVdtCX1LxUhAUCxWL5FGoTwVfFLUVLPjiBcSiDSiCImLBoAhqQXxoqbcqpRdNbS42ySTz+/If2JycTGZymcyCDWdy9l5n/eu211pJSaKGqRvYBmwEvgQ+Bs6WPCGpFldKUr9m0rSkHaXOpmrUQk8DbwLjQAZIA1N+lwXuBL5JOliLgHLAGaA+ABNRBOpPoAuYIXy6Bq3TDKwCignypQ2yA2hKOlyLgMqRqZhkHYy2GtQDPAWcA44Cv9itkoS6CIwC+VmAFO1yI8uR5fKSXlEynZT0mqQ7JLVLSgfnDnvPmKQJr0teknT3cmS5DcDXQAvwnzUbabk+wTuO2YLngM1A6yx8HwHen+2jSwEoBTwDvOHfo8CKhH2TQTrOJAD8F9gN3ARcAfxlnkPVvFgbJX0WuEvBzz9L2ijpPkkDkk4kuGDBK3KvgqSrKpVhMcE0SDpv4S4Ggj4hqS62t07SlgBIEjhJ+klSrhI5FpK2m3wJRtTueBn2u4+AtcDbwHTs7DSwqQTvjGOtx/VbtmypynSjGyX1Stoj6SVJhySdkrQttnefNfvwHDz3eN+ESlNkqW8lNSXwSUu6RtJuSUcktZWTFFqB2xzsDb7J00Ad8AdwJEG7UyX43QN85TotX+LiJFa/DQE3A6eBdcAuoA+4YTlruXZnq8kSbhQveYoGlvXz91YwCVn0RDVLn7yFmSpRoUwZzG+Ovz7/ztqiaYMZtlIwmB+BnUBPNfubgTniJoqXs5JWB2e7Ha9J9J6kDWGVsRAhc5KaJV0r6RZJmyQ9KKktYW9/mWAuSGpJOJ+VtF/SiKTTTiprF1L65IArg9Tc7cCsBxr9vt0lzgN2j4hutauNlyg403aj9XO02DmgECSNskqfVqATuNof6PRqso+PAn9bgIguN7hdfh+2Ar8afDEhdiIw4/7GmYUGalJwDrmEP+b3eQdlxil7dSCIvBpthdEYr+fcjCVltagVGAaum3P4UW4huYRpewfwYYkUHbnNMHC/M1VVusP50PUGMx4DMxkASXutAn4A3gHW1KKFGoDffT9kZ1HaZGwAElrxeeBgcM9UzUKpWfh97kwYCVwMrPK6YzQb9EIRuEn/fhk4Bdy12Baqc/bqMPN8UFt1Afud7ULaB7wYaLzo57x5DPrvvcALnq+FVUImZq2DwN45asMZgPLO7ytc6K13mm3z3ZMDzjseCv7bXuB4jFcv8IXvonqDGffzZr+LW7gDeBJ4Nja6Cs++CzxeCaBO3z0tBlVnhtOBG6QtQD3wnac2IW0BPo1ZJhKo5AzAdBmwHTgcWCrkkUnoqZakBU8FPVAhmD9H05m+Cvgc8NlC0MJL0ifVasFzkj7wRy8l1GpbK+BzNFBKyONApS34fMG0B4OOCWs2EuS4C9Zy+Kzx3CBSSsRjpNTsbbEBbQ80OBHTaL+kTJl8bg/OjQXPb83Sbi86oGwwBY1cI/L3QUnrKuDVGyhkLJgU3bvQ3qvcjc1BkxWOZCXpsdgYd65VF1gl4jMgaeViNJPlbnzVH/4nADI4n0GgM9rJgM+j/hvVBLQ1EGBE0s4KrRJfK911di12u19JcfqQB3+HgAu1+l/m/wGvv7paZTujsgAAAABJRU5ErkJggg=="
if type(writefile) == "function" then
    local d = decodeB64(SLIDE_ICON_DATA)
    if type(d) == "string" and d:sub(2,4) == "PNG" then pcall(writefile, SLIDE_ICON_PATH, d) end
end
pcall(function()
    if type(isfile) == "function" and isfile(SLIDE_ICON_PATH) then
        if type(getcustomasset) == "function" then SLIDE_ICON = getcustomasset(SLIDE_ICON_PATH)
        elseif type(getsynasset) == "function" then SLIDE_ICON = getsynasset(SLIDE_ICON_PATH) end
    end
end)
local LOGO_LAYERS
do
local LOGO_DATA = {
glow = table.concat({
"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"
}),
white = table.concat({
"iVBORw0KGgoAAAANSUhEUgAAASwAAADYCAYAAABRCd7OAAA6JElEQVR42u19WYxsWXbVOjcicnz5xnpD11xdPdnVc3f1UDZ2e5BbNkZGtPnAFoMQX2B+GhlLICEwRmL4AH6QAH8hLEvGgv7AqG0kGyTcdCPARu5B1d3VQ70a3pj5coiM8d7Nx9373R0nzzn3ZmZEZkTmXlIqMyNuRNy495x19l5nD4DBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg+FYICJnV8FgSMMmyckQUQvAEj9U8P/Ef4+dc2P/Nc45sqtnMBhhzZqcOnxdcyYlApDxT+6cy/k4OfYigDUAOwB2nHO5b3UZeRkMRljTIKgWk478EIABgBFbTtTgPTIA1wDc5PfYBLAHYOCc27OrbDAYYR2FnDK+XhkTyzK7dA7ABoB9AI+0hZSwwvT1dwDaTFrr7DoWTH77ADaNuAwGI6wm7p3Wn7SLB/4/A7DC1tCw4fut8OvaTHptABf47yGAMX/GKhNhn62uPoAegD3nXGF3yGCEZQTVYgLJmDjEWnIBYXyJCWXbf+4Qn7nM7mObSVG0rzGT2BNsbb3NL1nh3wW7nn0jL4MR1vkhqDa7d0ts4fTZDYvqT0pYb7FlVczwHJeZtMbOubv8WIutr3UmsD67ogMbzgYjrLNJVm2e9GKtrLJVVfBPjy2dkSYu1rE6/Hhxgud6g93Fh975rAK4xee6B2DfOde3YW0wwjo7ZCUhBoVzruD/W/wjO32iR42FmNiyyupE9RmS1jpK/SrXcVp8/pdQaW0E4N5pnKfBYIQ1fTfwSHFNpxnMyee9DIBirh8RraCM57rJbuL3LH7r7I/n83aPTXSfb3IVvUwEedHcRuwCPrYCWdtqodS8brKV9aZdyTM9RjrOuZERluE0yEliu9oodwAH/FihfoAqTquNKuxCouuJf6+ztbUH4C1zD8/suLkAoHuerCwjrPkgKiEchzKkofHuI7/HKv9cYCITgmrx+7113lbiczJ+3gHg7nkKbTHCOl2iyplgJAmajvm+a2xZtVAFp67x068753qWWH2mxtGHAXz1qHGAi4jsHBDDvJ1TJm6dcy53zg2cc6OjbgR4D/UBbAN4COA+ygj5IZPWi0T0hHOO5HVW0mbh8SwvSucGZ5aw5tGSUNH0w2msikw+Gf8451zB5Dfm57vOue8CeAtlQOw6i/Mgosy/PkymhsXBi0JY52XxOTPs7MUmiR5Ec3R+GcqwhNFhv5f+LkJSbKV1nHO76tirAN4J4I5z7g0iugngMwC+iVLE3wNw2Tn3sDycbrEVlrO1Z2k+izPeMwBPs7RwbnBmCMuzFlrz5NezNVMc4nhXfS1XaOKVrWwiegrA3ySi/wrgNpPR32er+d8T0UsAfhnAZSasbzHx/Tci2gLwFIA/BeA/Oee+zBPgPQC+hzJsAuy2mt41n2gBuG6EteCuH0+8ebMUmtTFemxJqe9DnGT9fgB3AOwC+MtE1AHwbgAfAvCj/P7fBfBBlGlF/5CJ6irKwoCfBPBhJranAXwE5Y7iEoDXiegygL/IbuOvOuduGx/M/XiXDAcjrEW1rFQkezGv5xggKKhzFpf2FoBHAH4RwI8DeAeAbwB4BsCTqFJxevyaFQA/AqDLj19GGdM1QlWupq1ITsrYjAH8Fba2AOANAD9ORG8wmf2Rc+4OEbUslmsuLaxLOGei+5n7svNEVjHhXz2uyfYagJfY8nkPk8uzKBOfLzJp9ZlkMj5OVtpVXmmv8TFtfi7n10rZmiU+XooPyg5iwe+7AeBvMQF+DcA/IqK7RlZzO3evoCo5NFearRHWES2ZebSsWDjfAPAcE0gO4CdRCuY/xuRzlS0ksYaW2HIqUMVaQRFRC1WBwJEiM3lcuw66OKGMgxFbbGP+zI8C+LcA/jMRfRnA/3DObRtPzA1WUKZhXTILyzBVK0vIS8R3DvB8AcAn2O27zkTUVWTSY2LSUfBtTHbcEYtJ7yTqrjxCmAUmg4TlvRxKXUwsqDV+zYjf4ykAf57d0z+QShfnKVBxHtdlvkc3+ee6Ly8YYc2xe7UoVh8RXXTO7fCk/xkAz6PcpbuMqiDgOg9GiVQfKesp88x+p35niqDIOy5TRJap/x2qzQmpeioFAXOUYv06SiH+z/HjvwfgDSLKbffw1JAREaHUIlsA3uec+x2Lw5rflWVRrKqMa1ddYHJ6mYjezSTwstKSltRvTSiZ990FY0Vq8jgpUsrVa1oeqYEJSJKnxbqSzxTXUKy9Mb92md3VN51zPeOMk7PMvfsvreKIiH6B79nniOhfAsi5bprWcGle5ZLjkIBZV7M77wzAZ1EGb94A8IMoxfKhR1IdJou2R0RjtbBkyr0rPC0KirD0IiRW2ZCJSUhfqpIOlPsn5LajiK9Atdu4B+C32cq6Xdd0w3AkYqolFj7+VwD8PV58rgH4FwA+f5g5srAeixHW9C0r1qc+gzJ+6kNsVbWVvrSCyX6GQkbSBIMUYYnVNebnc0yK5kNFTC2lX2XqPXrKJRyhCncQAiT1nkP+KZT1JbuM3wTwzwG8hnNW1uQUxpEsYssod2+fBfBpAJ9DqX1uotpM2QDwJQD/EcCfoGxassX3XTZtRmdBe2wvwM3TW/TzOrhcuTi6nNNjngPwUyiDNbeURrWsyGFZkVihyCPkCvT5p6NISRPbUBGUtsREnxLSGXj/Z+qcBqhisx63L1PEtoIyMPWHAbwOwEn+olFMozEi1vMSW9kXUO4E30QZW3cLZQjKRZQ7f1d4obvOz62pt9xVC5ljS+sV/gHPlS6AByiT4R8BeERE25hMjr+HMiB5my3rLo+zEbuec3dv3QLc7M68XrxAlP07APw1tq6e9vSkZWUhtZU7qK0bIeYxJgV3CRDV4Qwd",
"zxXM1aTQmt9IEWHGA1Isqb46l6GyvMSyyvkxEeg7AN4E8DckGt7K1RzJ/ROy0YtPx/tbfq8weT0F4OMAfhpljJ7e3b2MMm7uiwD+H1tYXSayvrKycnVPC7VAyfghTGZamEt4FOtl3sjKC1W4xivlMsoQgM/wYFvnH3H1OpjcuXMBlwxqcBWK4DI12FbYBdArLCnyankTQmKy2solHKjPbXmun7boZCDLOa3zZPhfKHMO/7tz7lUjrRMde1cA/BqAv45qJ/dfAfg756FD+CJYWNm8Rq8T0RMo8/Q+wUQlOtEa/5YdQLGuCmWtiFXVV9ZPT5GPiO9jTDZ3XeX3g3pdpkhuTZHXEFU9ePIsrwKTO5E6LGLIrqx8tqzIF5Ul10eZbP0FtoCNsI5vecXmqE6GH/Nmzh/y2Pu/AD7Fj3eUFEDevT34xgt4zxYhrIHmjay4Q82nAfwE6wZrilRkgK1iUgyHsl6GmBTGO2z15Ip4OsrKailrLeOVVYhRa1UScDri47uocg0LHIzP0ruNWr8Cayy76jFSllqLz+H9rH/8TyLqLuokOHWrIX3N/JplbSanXwfwKQC/yf+3z0MZ7LkkLEUMc+FqqMJ2S1yW9hWUsVVPokqfkR2bTGlRkiqjd9okMLNQBDBUBCJhDjkT0hL/P1Zu2ojft6XcSqdcOL0TuKc+b8UjyaGnYQxQRcBLM4sBqjCIffWZxNrKd8+DKzJHKNgi+0O+H1/h/8/FQjGXhCUkNS+rtWqm+hJbVu9hC0oL57IFrS0Z2a0pFJkto9y1EXdLk5u8j0SdSwedLqoaVWJtLfPrWkwookfJNeuiCv5cZ4tprCwqeW+x4IaoYrCWUOUk7vPjpCxJ2T18L4CfI6IvANh2zj0wPpn9+smL+V0A3wHwNv9fGGEZZJfyOoD3oaw99QJK0Vt0qSXWdi4r16pQRNRXRAH+e4DJnTsdGKp7EY5RbTWLpSXW15A/f49JRZMd+PwkFkfrX3KOPeWuCvHmTKYrSl+Tig6yJb7Or93l174XZYrR7/san2GmGKOMxeqfpy9thBVxSRWZPIlyS/mzKEMVNvhHJvKa0ohEGxI3UchE5/Hp+lQrmKyqsKQsKwlJ0PqRJkOJQt9DtWW9pL5GjjLGZllZX9uK5EaoYsG0hiUi+0B9F9k42FYTZIWJS67FG6ZhnShyXpCGRljnHFKrihs2vIwyWv0SWyhSn0rCBXSKjehM4matKItqpKwu6SG4gsmIcqCKMidlmYkY31FWj+MVdpnfH+y6bfL5jNT5rPBjcm6Fp6P1MFkRooMysHDNI2K9ml/i58RdvEVEDyxl52TkEr5/D5RUYIR1Tq2qFZTRx+9lononu0E32ZqQCb/G7tpQTf4dfn6NB5I8L4L6EFWvwCVlRQ2YxGQwDpQOtYtqZ25FEZYO/Bwoq2mVP6uPyQ2AfZQRzlCWnQSm7vBPh4noEh+/xcdu83tKhUvRtYQYn0cZtGg4WQvrjic3GGGdI7IC16oas04lZEWKlCRws8OT9oFyufaV9fQ4vQGTYrmQxQomdwy11aNz/N7m35eVtbTLVtSACWSZH9/i191TFpsI6ANlsUnIQ0e5vTmqEIYev2ab3+s6qt1BKeC3zd/hKr/2JoAnnXNfMw3rxFCgrNGfnydX3AgLEzWrPogyX+59yuLZUK6T7AJu88TuK9KRNIkRqtQKeV1HuVVCIPI6Edy3+f0zZZ11+bH7qEIahvzZYuVcVO7agInkAT/XVu8pn9Nla0yi4FdQVTLd4+Pv8E9PneOQiS7zdDQJavwAEX37vGkqpzhmC669bxbWOXQBb6Fs8PBxdm/EalpFVYVT3CrRonaVSybWik5KbqESsaUwn4QjSHBnj5/fYQtpHVU4wT1l9fT5mA1MZvGPlbUl7ykkss8kuIQyXqpQxCdJtrLjSExkWlTvqvfZUOS8gSoxepPf+zUA/xtA2zk3MDo5MbyF+esQZYQ1K6uKW2hdY6J6gV2bp5TLRqh24US4zvgxKd3hJyxL66VN/ijpHSe5hG0mg7cVwd1VLqSED+wzKQyUHvWIP2dZuZRCnuDPfoRKuB8wSe0qy2ifj7nF373Fz3+f3/MJVAGjOl1nFZOFAmVXURKp7zrnuuYSnige4JwEjJ5rwuLI9Rsoawxd5Am6y38/4skpyctryirJ+DgRyp3Sr4RIWqgCPS+iSmyWnMFNtkhGynrbYbIcsC6xpAhJ3ECHKiVHAj376r13lHvQV0T3Pf6Mq0y6Pe4K/Sp/5rv4dd9kwrnKpL3B53qZ/5edzn1+L0knEn3rOQBfNbI6UWwbYZ0PVxA80Z9ni+ICk9QqT9SrTAwDVAJzwSuaX01BrJm2sswkNktir3Jl5XyX/9YF8zrsAt5lkmhhsiFEn4nBKR1M6hztotqVfI2PecSvuYcqMbnrayAA3iai+wCWnXPy/CO2INeVNXhJWYM9fv4yqgDWNwF806yrE0fvvF3vc0dYqiTMD/JEFO1pncnqGpPCQ56cIq4/QJVrp9NaxIK6oKwwKEtMCvdt8nsNFBEJ2e2iyvmTHcmuukc9VKEFLaVzyW6kCP3L7Jp9x6sq8bgcjk/eXIVyLMezmEvq3MZs9V1GFQA7VK4h8cQxsf3kx/LovH3nc0FYKpn6EoAXWa+6ym7hDSaDq+wiisZTMFF0FSktKXdQQhyEwNZRCfPE2pFgrAhgn4+XzjSPUInfQnJCFC2laeVMam1lvUnzVNHI1gAMmtYJ14TmHSPR90JKosfpAFT5vEcAXjPrymCENUWriv+8iHI3cJldwadQ7bit8cQUTWaf/xerpqOIRxKBV1GltgyUziMivMRprStXUiLRB+wCSnqLQxX8KWTURZnyIlqZaGurqOpl6RrxlwEMpdLFEa6PLucrpCV/S+MM0c26/Jl959yOTSWDEdZ0rCuxBJ5DWVp2WWlMD1GFIEC5WDqW6SI/LxUKhExErN9hC0jXSe/y4+DPE3dyR32GbqMlQZ9dtswkor6r",
"SLHj6WyyO3lBEeoHUYYZfBFHaIummh/o+vBL/CPiv+w2irX4wKwrgxHWdNFigllFVSNbdCgo6+YRJhOFpYZVjiosYQnl7hopi4yU9bWGKn+wxVaUkNSesr6kk80yqhScvnIrJYWnrfQpiQu7xe/1AoCX+DM+zIT8G+o7HZasdG/EliLnjiIqpyzKB865B0TUKmWvo68rkwafy8/KwFOdlOYNhVUcnc+BssLa1HW2Rjp6cihi8nvzSfWDFr9OSrxInz6JAl/lv99CVSVUXLtdRVZyvASUShWH2/weol1JnqEEkQpxrKGsFvFBJsz7KCtOSpDrinItD3utdEMEp3Q5KYU8VEQlluQDaap6lghmRnKEXR8jrFpIwvI1tq42MClOd9klHKiJniuNSrQtXXFhlY95iEqE30MZdNnl93kbVeS7JDvv8HFSZ0paKuXqZ83T09ZQddvZYKL6DMrNAVkZRazX/QQb61d8XAuT/QyByVrxH+DrJxD3cFNVutSNNLIAaZK3SOjH/N8jAF8+C7uOvBDcQhmYLAuPvsYtn99wsJu3PK6vsdYvdbltvxu4biEHdQ5tAL/vnLu9aO78WXcJr6Jq2iDb/+LKSWS6U2SlOy1L0KgERy7zcbvq5t9h8tpEVXIYypVa5uMf8W8t7suAu6yIUUT1DSbbmyjDL9ZQbhZcYUsNSsNqK/KS3yvK3a1b/SfCGpiEpNhfH8A/QFlldaQmRhaZWClXlCLP66YcGbu3HwBwf4E7fi+hjPEDygYl/w6TO69NXXaKaJGuwXUN3Rtdhvvn2LrPFskCPHOEpYTjJ1F1kJHdux1UwrWQlMQ0ScE6KWqXKUITy+iRGnhCQkNU4Q0OVTS4DJBNtqbuKQ1KlzleQhWqcJFX46dYm7rsrbr7agBrbcR36Q49yXVZaiIaoSzFOyKinnJzdTJ3K7CCw5scFCAl35og9X0kq2DR8+M6vLhIb0BJ7yoaEru/GIQIKnSP/WtKngUs4/oKFjRJ/SxaWC22UC6qibzu6USSpyc6lTQRXVNuj45S31HmtKTHiPbVV9pVT1lgjnWmTVRR6e/kxy/xOa7ya68yOb0XZWfljrLutAvgvIHpAgM9w3Tat4098mlhslJDrp5DA0sgdl56khVHJdw5w1ARuySr54F7iAAh1RGYT1YhQss864ww2aUpW9RrfBYJK0fVaFR31n2kJqIMIGkiWqiB1fIGwBBlWMIlVAGUUm99n0lKN2zY5ZX1Dq+sutTxVSZSEe+fR7kh8HH+7Ouo2nmNPaJyEa0jNCjbTVzClLXl6WCEyf6IITeQEhMt5SLKJJKwibNQfUCPoxWlDxY42PzWv1a+1RlbCAjh3oOa+F1gURirMW+ENSffiZRLJ4L5sufu5ZjcwndqYA3VMduoShOLOL6PgxHxItiLbtVB2V1nA1VenlOkdQPAn0G5KSBR8rHBlgX0DBcQaQv1fWbicSMuoDtvhT/se+rJnC3q4CMiXYMsU38jQFYucF9jJOQSbqB2uyngTpKSQIpFXhTOImGR59K0MdkyXpcrlhCDNc9KaSsLapctoi6qQnlSS1trX4XnZj7B77uuft9A2cyig7JKgiRVjyIDOmtgrVBEP5r29fQJyyUsqiJwjItYEvpYuT/LPPGJm1Mu0gRbU9JCS82xDAd3VCnh9jmkuzc3+X+sFgDtyheLuiicRcKS+CVdt0kafYrrJtVDW4pk1tXkkW434uZJGY9Vb9ANlDUm2pbuNygu6UWU29t/AWUslQieI0yGEGQBV8A1GKDkkZyb4vXMcLC6aExnIYSFYj35Yu+jLcMBJ2UvqiQxUHLAXuKe1S0OrsF9z7wxoMfBKg6GO0gmx5IR1nxAVpO+0hI66ma1lTsoNdd13aqxenzXG4g76hgR7sfK9JfV9Qa7eisodyvXWa+6hUpI166PC7gKIasENeIrzcglLCKuDBITLOW+xCauaImfJqJ76jt9zTm3P8duoM6//BDf8wt8L96FKo90WmRFETcQyrIbAPhqxKqzXcI5cwlzdUNkIHW8wSA119dQRYuPUeX7iQa2hKq6qKToiDv4kAfmh9RzVwD8VZRpM0NFdhL31WrgUtUNXBewalKTYRrXtPBWcyC8U5kir1j8kHyHPt+P/6Du4wjAKwC+QUTZnLqH0v5tBODXAPwYqoYdYmW5BoSdumaU0BP9a7mGMvPi86hSxsQ9lBJHu8DiZSmcRcLqKR1pSRGWEJLUo1pSGoPET/WV+zdgy6ivbrqERTxUltglPu4iymj0azyA9xITPmZ1+FvSQHpHjiKDt5gyWbkAEbmI+4cakkXC1c0VubeVSy/fp0UqafE0g0q9XVSxrHd5/IkFDkwm14dCEA7jJqLB4uCUDrvkjSmp2d/CgvYzPIuENUZV7nhZEYWUHN7nG7mqbtxQ/S2rj9767Sqr6hG/h8TYXEWZMvMiu31CbLlnTWUJyypLuFKpHSJf6KbAJJgGYdW5fLHgRniui2s4MQvlvrcBdIhoGUA2L0XrvJI8Og9VQjNansuWCgA97P1yicUKatxKh6Uuqlr/WcSNNMI6rbHk3cBM+fXy/KqykIbK2hp4ekNPWUrS6qqNqlHFLoD3A/gZVH0Js4D7WRenVByBMGKuVYgUp6FhFQnCDVmMLmFNUQOXWHfEfob/dkT0UOmGm6fl0hDRdVT5nlf4R8oW+aRFATJJ6ZExKzzlRur3kcDVHkscu6ji8iSLwQhrTqAjimXQLHnElSlNahdVR2OdjDxQK9E+gI/wxLkA4JOoOkFLAwsdZe4SJBITrl0DgqIGJO2mTFhOEVbs+1CCsGLnXSC8E6r/loDbX/fceslW+GkAb5xkzqH6rL8L4C9hsjO3LH47ge/qX6uYax+7xq6BNUtqsR2hDF7eLg1CdybagZ05wuIobRkku6iK4ZFa8WQF6iuzWXrwiZYlE6aHMiH3FXb/3oGq2uh1VAGfKXIKkUndjhtwuPQNSlhB07BYi4j1RA10KjTQtEKE",
"RpgM8B2jyhJYwenGEt3jc9hS5yfxe34IhwsQFyILEiWsZ0osdCH3MFfzAUZYcwYlhEoLqhyTwXK6g3OuiKqvxFJdYO8RgDHf9I8D+NNsUUljiXHEXI8FAiIxQOs0qpjF5WtYs0CBsJjvEmSNxPdGxAqNEWau7g1FrLiT1q6kg7bumtRCOng25hZTzTgJLVwxonIzsLKNsGZoXTk1sDM12AseZGuYbO2uOzZLB+UegEdcrUBW8Y+hzPu7q1zKLKC7IOHGHWYXSLtjjfjas0ZmoWG5gCsXsxL8Y1J6Vaoagd6syDw97TTdHD91yj8fSlirLrAAFN73rUvDie0Kk+dNGGHNO2+hqq5wQfn14tsLSY3U4JCONFtMRF0VaU1K+/J3ugrEd2xiEd1NotdTFkvs8VntEhbKQvUJtI50cAjCogBJu4j+I+76ifs6XjiD7GL6BfZilnCT+LmiZiHLahbDkLVnhDXHVlYBYMh1nC57RCOrs7Sb126U7PLtR9JCdK6bnkBZZLWLZeBnSO8UpUIAUoGFesNgmgOVlMU6jpCRQ7o0TBb4DjEdpkgQn57s4wCBnARZZUoH1YnpOkcvVWDPBRaWVNxdnUXuu+QyBlpY4CTy82RhQbmFUvpFShbLTqDEY4n1sMwE1k287Vi5XPAGCCKDLaRP5YmBSIfQdShiCU3b6iDlVvv1repEfn2NWjU6jqv5fiGCHBy2pdkU9Kucx9g2qkBiNCDuunCQGFk7hAN2gXAeYYHZbL4YYc14YHV5IF9SRCNBokN1Y6VGey+09atE1hYmo67rxPKQO4DE4IsNcGpICiFRetqEVUc6oZ3BUFUG/btIkFfIOhELcgnAx4jo+wBenbV7yE14AeCHUIYzPIEqtin3yKKJtlYX9hG7llpuiG345Fj8Iojnh7AUemqySfOEgbJyCiaqbgOLTVJFRjhYxC61kweE8/BSOgTQbLeIPAtQSKU1ZcIaKXfQob6muO/iuQhhNalZ7r9WrvsaynpjYyasWVvsq/zvMyjrod9lzdO3+vxk45CrHyP1VNpTqmCir5GZhXUabt0UggGl9viQXcCxmkQSb9WkMqe/QxXbFUtNxLxmRa3TKVJuhR+6MW3k6vxdRIuK1Wv3zz8WLBqypmLEKDuhUialTUS+q32sOlq8O6zPZRlVKez7nnygx0SBeEegmPWbsoqLyHEucm0LTFarNcI6gdXsQPv0OvKKHDMA8D3+npeUhSVJ0L2GprNDeGdK6wYuQHCh40KrZF30eMxV9FdjvaM3LWhtLCQWZ0jHnR3Km/f0GYpYs22tqc2iJZhPdtxBXIKNJWxAu7PjGlcZCespttPsGo4D/b/IH84I6wQsKiEdTnYdQXUCVq2oluHV81Gvc7oDDIBdJcquKtJ5bLZz2ZK8oY6Te65KaLfH7zlXRLSq0HZ+k9yykCWWY3aie+ERIjxXNGRRxSZMzN1xicnsE7RYxz8L4LNE9PPqvkopod9zzv3WYUvSqDH2t1F2097jefIEf//LPPb2ItcoRLIhizS28XDc0JTcXMLZk1XmnCs46/1FHozPokyDyYnoVefc13ggZTx43uL/rwBYJSKJr9rjv/3WVXueO+jvtDSZuCLYtyJmux5ouUdWsQajrmYwU4115Z/DrGqi+ztQTTQVIB5TVlfjK/Q4POKUbkjPe/f0BoA3jzhpJdj4ZQA/ibIx7hKTIKGM8bsf+T6Fuvcxba5AfZmdugUrleakq5OQEdb0yartnBsT0TrKSo0fBfCLPFCk6N37iehbqOpMveCce5N3bp5FmS+4zDrVt51z/cBHjVEmgmb8eZkWdEMupXpMqniOI+Kzb31cRNXLcKzIagdVWWTf9QHSkfIpdyJk7U0bRUTQTe2SxiwvREgvNSFDpLmDKtFYC9tDTFaLPQo2UXb0lpzBjrK0/YYbRcTSCX2v1D2iGjcwVrDPf21uhDV9opKE5B8loldYU3qFxcwltrTeYhJ6EcAv8Q35EoCbRPRpfispnpbxigsiusUD9g1wAigTz+MJd0hBVnbeRt5KHtoh2gfwFT4X7R4uAXgfqiReSgw4igiuMS1Dtvv1bt40MVYueIF0ldG6KhShSezQPFnaJ01dbtpNUcPT962Ng0nu4xrXtWnJ46YkVfd/aJfRAkenKGqKLgUAP8Fm/B6vZLkiI8mG/1l+/BkAr6FsOjpUJrD0AXwSVVnadZTlR3a0i3iMAazLm+j4LKlqKqEPv+ENWiG8f8bn1MPBdu/+YCwS5OCTFZT1N8b0dwp7qCpVUoOJk9VMUhf5HocR7GOJ2H22cI+LzLvnQ++7+YX5YrXNmtQ6wyGOoRpyFKxjdu3ezgdhKUGzg7J56M8D+Cl+elcNDtlCbvNvSaUZoSyet8xu4JiJ6gHrXVJ5QcrT3gLwnSmER8ig66Bqopqra6hXtGWUO5JbmNw5kiqkY0/j8AedQzyWx3cHdWLwLJtjimse0tdcjRuLGovAJRaIJhPZD6iU+9JiK94dYnxmKDdhnBp3+r75rndRo+PF6q4flqRSjxcRQpt2itb5IywlmudsCT3Pq/cGyt0X6UQzZOtKuiTvKaJY4+OlRLHEndxE1RjiW6hCFp5mwX2nLkC0ZrXtqVVLD9qxNxhztSLvoYqH0QUECeEdxlDydNOGBbqjbzEDwhonXNiQQB6L0QqVQglNvpgrqXfgYqWlWwCGh61GyjKBaJo9VJkR7YRGSIgHEcdK/riae1t33VKfXahxaBrWMTUruZBXAXyCJ8Emqu3iDT6nNbZSwIKn5AUu8TFAWYmhxS6ihDnIz4ifX0K1g/Q6p3EUTS0uddwIwC8EXDa9jS4F3DIWav3tZXFXLmOyOJ0Wi4sacdqfxHrC6rSjaVdrEDezrkKCa2BVxCysVOuy0OdkiPdCvAfgo0T0qwD+NW/QBGP5lNV/DWUYg8R4XWHLvY+q5HWBcFE9iuiNMZct1UEnlTsIxGuokScljIywjuEK8gB7mSfsnwXwkhJy++wS",
"rqLakcnVwFxH1cmmzYNphV93i99zG8Btfs8n+LgRyp2eAb/3kaLneeW9M4XrMPLcK5+kisSgDoUJ+JOkwPQDBnPlao28z8hqtJW6RqBNXZ0YebvAtctQbtyssNzwmyhDHOoSytdZF23z4riKcgdykCAJvdCkAj8ponfVCemuAYn7YTFSFtwI65ju4IiIXgDwObagdAdmuej7fE7LmOyELJHqEhawjqp+dqH0IrlREoLwEFVzzusoy868AaB/WOI6bEWASKS+lFzO1WDPkS6p4lsvsVZhmvymeV8LRbK55yZnCJeLCbmMoYkech11uRZXY82F3CNx0XcAvA5AijBmkVLBUkNYW/E9j6SpxpUjzw2rI5wYKcXCVoqa1/uL2SzKDJ0PwhIBk4ieA/Ap1qXWvYvaZhdOQhS09ZGpwX1BrXiFcoVGalW8gjIcYpePuYKy1PEeyp6BD1Ft/x+JgI4BKcWsO1CH8vTIIwaqcSEcJncvp+0SjpQ1TAHCQsDqSxWrA+KR8Yf5Di7gpkONqTbK+ma1uh4R9T2rcQmTHZQIk9VcfYtWV//QZJFFiDVFvkgQFBIupvPOAUZYRxPaAeDbAP4A5e6gY9KShpN9/nkakwnKLRwMkPRrMq2jqiy6yeK7VByVSbbKq+0eW2+nBeksrcM3YtHj8CZQKvpbBuqG0vCOfd/UfZBGHZmaCBnqU0oc4rugSOh1MY0nJMiHyFy0xBUA/1SRUUc9J1ajBAWvsZQg5bP3UEa0pzYPXEA7KrwFSD4z1QUpFIeGGtfZ1zt1s1ZZkC0O6ygWlnNuSEQ32cLaYYKRXTwRiSVaPWbKFspUl84pfSXMS6utVZTR76+zrjVU77fEn33nlK63DrtoI76jlCHcKSXWKj7zXIFpr649TO6WwZuUhHD9+VT+ZErbClXtDAWmxtqLybHf53G1impTRFq+DdRrZLf5bUXQDxGOg6PAvQhpifCILHT/6tq2uRqr1CcweV4W68II62iktYGy4egqW0F6lRsy4SwzmS2pyXFZrVhDTObndXnQScjBI6WzDPimyev2lSt5CeUu5cMT1O/8bedxRDjWeYipvMFQxclZJj/r3ce6foRN8yBj1hQpKUA3EiHPyqYAgWj3WD5jB5PpUW1MJrPLBO9EFgl9LqEshFhnZ+BgWewM6fi7ELIagT5EWIQFbUU/L6K7CM1XUXXGlUalQlZdVBHhS6w9jb2BlSk3ivg1xMeLLnYB5a7QkD/vHqo8Q2lF74iodQpdg8eexhGKCk81yfRX30xNBi2MT7tVvR+HVVeXPRWOQDXCMzCZn5c30LSKwMQuPLfMD8gl5UZlntVIgQUkdg6psAW/mUYr8ppQHJWWBGLXzf+u8EjZRPejGRhuzDrCBf7MvhJzC7Z6OupGS4zVFpMd2LSX9BBpxfVQuYTEVtYyE9UDTO4yitu4j7LF+WmYy7qUriRB5zi401Mk3Cj/OBnQI6Vf0ZTPObTrlAqYDLl4sa35VANaIJ1rqV8/RrpETSg2ygXuAQVcuFjhxiKgY2k9SROWX2IaEZfNP7fMI/AQQfqlsZdgu4RH1q8KDsp7mUlmGVW0eK4sg4KtpI4SebuodmrGSqPa4p+RsirE9dvm77WqCOyhZ9W0Tsm/H3suXGg739W4gSFB3inrcTwDwtJicpOei6Hoa6pxG/UE9QkitRuIiIDfpNM0Ra59oSwi3/ULEYTvyuqGHS1MpmY1ce9CbmFsPMSCU8c4g5gpYamOJpsAvg7gI5hsjyST7NtMUNdR7vJtKBJr8esz5V5KGIO4j9Kp+XVU29l3UYY3OJQ7PmMmwwsArhLR/VOwsvQOaB4gBjQQrTVZ5Z7bNpyBS6jDJfKA/lZnabmI24KEJqdd/1D/xRzh+mKxvLrQufqNLeB9no7BcgnX0HnWVu59ZluJ4BnC8XSplvShYNMsYOH5reFmUbXjXFhYRERPoQr8lN3APiZTVvbVgBMC2mSykVVrR2lfQ37+OqqtY3H7RCtaYSuLPO1rfEouoWw3D3Bwx6hIuDCpFZcCJDjN7ezcsw5GAUE4D5BRTGRHhETgidO5Z2n5ROi7cTErLxYiEbJWioQOFqvZ7rzroPsTipgPVFkaLnEN6pLJY5kDWcJVN8I6goV1l62oT6IsIzNiYmmpQXqZ/95Wz2/xW73A7uGbynUcMhntskC/ijKWZpsHx66ni8ng33TOPZxSk4tDkTd/fp+/X8ebFEViwiNgrfir7GFaTB2WZEeKqPKI+xUio5iV6CLalsRFrarro3U53WChCAjVR00DignoLqGnkTePVjzS0i7iKKCxxVJ0QmVz6sR9X+Ozmu7HJK4xEX1XiYGbytLoKwvpj9lle5ktq77SrLaZ+GQncRtV0GkPVRG/fRbcBwgH+rVPmqzU4GrzBJQihYhoJITJ2lOhwZl5bgpQ7ZROExImsu+dU4wcQ12eXc1k0xZNhxeiFVQpVlLBo8Xjo+/pazgCUdXFddWV9tHfbcT3tBM4PmeZI8NkswpEFqJYc9lYYK5DuNyQ3gU1wjrMROVcrh/hz/u+WnEk0p3UIFxlS2qLB+rbbEHJDuGIB7RUeRAXcYsHjBCdCPFa8HQoUzXoFEgrQxXd3lPfNyYqOzQrbKe1k3XP9Z3Wee/zT8eb3AWaVReNBUD61oBsqvwbJoDM0zufBfB5AN/AZGPbJr38gHR1z6JGxC+8a6KzC247536biFYCetwVAL8ccBlTFrVLWNaIjBun3FC9g2yEdUgNqyCiGzy4vsSDTgaZTiOR1bWLqvfbJj+2wset8HO3WQcTIrqvVt49JXAWnn61xwR6GhZWSKSliICdmuwxYtC7rtP8bn4BO3jWQCokAQj3GaSIztRSY1Jbin78kuw256gvt9LU8mqSfuM/LiSXKZff3+3UdebhWYa+NpUl3M9QT0cECCs30f0YGhb/vgfgd4noGQDvBvADTD7STVeanEqKxGuo8v6kqqi4CHeZ1K7wzdlm6+ohv35buV+a",
"HCRMoqdW55OGNG7NES4nE7JAQqY/cDCNp8DB8s3Tcgn9Xc1Ymy5K6HExkVk//7jRAy90pHJR9QQcIB4x3oS4jnJM7B4V4LJFRDRSRSq1Rql3tfX1oQABhvQ0n6SyCMn6fRKNsI5pbd3m+uovogoWlbSPTT5URPdLyu8XAX5Xiel32apySshuY7JluyQ6d/iY+6e0OygQ0hx7hBVbResSfzP1o93saWtY/k9MWE+J7CGtpfAma+5ZIo/PQRHXEiZzUJH47RpYVUXCCo7lN+q4qwM5e0K2nsU0UPOtqSUYK+iHiESgg2gHOIM48ZruqGqxt5VlJS2w9jzTtsWPPWQLa4utsp7SgUS41/FdY/X6TGlap7niSAHCnlptKWKVuJqJCG/yy/XSOZPTwlhdZ79jTaqAX8gC8Av/+b38BqgqyoYmsI6/0rpkqoxNyqoqUF/V0yG+o5crDfWAK80k2/Pufyi7IUacofOnwP33raxsBuPgfBGWMpVvsHUkVUBFFB/x/7LK7mKymJqQllQSld22AaogUx2dLFvhsqN4H/VVJ2ctuueKXNsIJ9W6gJsQyiP0O7jkShOcphWZq+vtEG6xlcobjFVN9XfGCmWxpKoY6EYeY9THrlFi0qdc21jdeeddm0HEKtRan1+rKlS5wbc4Ebnnde3S9D0zwjomaRVE9Mf87/MoO+DcZJdtA1XeoEyQHX5OzFuZkDueMKvjkaRErhb2t0QXOcVrLflkmlT8wmspjShGgjqVZYTplxWRSTnAZFhDrIRzzH11CVLWGlVKeymUZe1Hd+vPLJBOLo5d5wLpstShpPO+Grcxq0hH0o+Rru4AHGyw4RKv8cv8ZMrLMJdwSqQlbtojAM+pG9/FZHflXFlYzrMidP1qqAE0UK/tA3h4ClUZUqutziP0k1xD9b8RcbX8UsLFIVyLoxDWKEFIQH00OSIisvO+R11Vhi4m49hi1mms5VYsMDT02aGkbS22jxvohrrUsu5sRAnC9/VNRM4rlL5TKOvdCGuKes4dVDW0pRtORxGOTgeRekaSJ0jehGp5K7PEd+3MkVnsl6/NEyIqRdyDWAUEvdpPW6vTbg/VuIFAPPAxZNX4z3eQ3uUU67qPybAVoD45GDXWaui5WBlnfW06MQmE/+yzHAFMNrpNdYZuUqkjdm6hMAojrOPqWXyRt4joVR5870JZFkYPhrGyqnRgnE7FGHumtoRBYI4sKz3hxFoJ9eNLVTjQk68VmFBF5L2nQVh+0jOQ7q3nGhCEw8H68E3qXukxkSo77JNjXW5eiPgoYSnq5rWu5px76t7XhWI0qUaaWhTlOtou4dTNrDLUYY//fpUJ62k1UfrKFcmUK9hWk0h2sWRCjeaQqKBWWCEVf5s8r3ED/ZXYjxbXk3lq9weTJXy0RhKrromElRCaeH5lzyZu9Rjp2LSmv1NBobFa8/65NMnfJEyK83VWXyrUIZSe5VvdZBbW7CwtKNN5B2UZGqCMsZLqDhfUhMmVyClBmH3nXPewrbhOwSUUy0DixLQJP/aOratf7tdS14Q1TZdQ4uT8Eiy+C5KqMBGKLYt9x7xm4o88zcu3RlP14lPEQDVurAu4XwWaBerqrA4/yDNUTbSJ6w3vuvu/bZdwxuQlUeuyuneVOe1QpWPsYTJa/HHU+imm2xzGJdQ6BiKalR9kWSRcA+2ejDD9ig1aMI41fYg1d425MSmxvi6sQVtkeuLWNcIIuYhNmkCkdjabXutcWaohoZ8auIJNryN4TphLeFJuIpPP42J3RHSHz3UrQEqL0hlEF8AbIN0ZRusR48Qqr10BHZs0K8LKA9ZRncWCiOWIgMUiCxNFFiBJudLBo6FWW6FFIKYRhqwrf3cwC1x3rWFRyosgoqGyVDMc7NAd68VYeLoUIpaefw8scPSU3ERtfZ2FxpA5womvscnul/ClgDvmd5CeZvE2HXIg5V20dpIh3kChSTkZf6dT3PyixiUcoNydC4UJtBAvsdw0f9AFCKwILJBSZaROextgslcgBfQ7qhk3WY2m5QLXySwsw7EsrJGygGINRf3W575Ok3kr6UTSMMpqqjRFPa/AZKdsQri7M5CufZWaYDIW61rUCzk9q6SAsSKuLZQxWnXWXqymfMgllGt/CVU9N02w6yjjCeukAL9nJDUk0liJ6ZiuFsqQMMIyHAnS3myMyVzC2IQPRXOHrDPZNRtMWbuINbdIuSOp+l2piHjJLz0w0ZTVvQPgt9S18yfxKyg3bUZollcYih73/y4AXENVESTkno9C3oEqY3Rf3Xt/oyJVmdW3wLOE9ucL7z0jLMNxJ7+EYPhtqVLWTUy70haWTLx9THc7WwchDgPjxTV0qyhxjG8d5Am5IEdZTTb8oUQt5YJlqA8XoJrvo4l0zzm3fcTrKDvC+hrWpeeEziuvOV5bY11YiWTDFCZ/npgcIbJKuSy+26Jdt2lBh0s0KXFyWDfZ321Mnn+Nq0uefhVqNV9HDr7m9jhIlT/bJSxA1OhQOo0qdf2anFeKbK0elmEqkB6MmTf4fG3IrwmeamOuJ3x7BoSlNSIkJolLuHwhbSuLkHFSLE6Rgyr0J+J2THiv6/eoz/lxCRmpyXWE8JkckwGvRY112mTxi7nmfjFHIyzDka0JidwPVY8sAhM5lNAc2pXTwYLTRh/1EfSuwXf3CS2PWA3HDXgUza2F+g2BUCkZ//lcaXhHxRAHu2c3dQeBZm3nfRIemoVlOC56noUFhLerqeZvPUB1iWSa0Tn7DVrrqo3GiCzWsCJTWs9xiKGPqt5YJ2KNNO2oo11iKTR51ODkUP0uilinKW0rpsuFgncHZmEZjmth6RSXuh01IBzcGBqkboa6hURoFw1cFkqQRMyykBzCbArfYZcJKxaHFQsl8c/fT3ka4HhxgDoXM0d9Q9cYicVammWB8zeX0DCVyR+zVGITp8DBRGc90fVrH6+qU05T0taBS0wyQvO0Fr9EkAR9HseV6Xt6EWq0otTuZQFAmmAcd/KP",
"MRmD5Xf5DrWo988zS7iC49TiuAApa0ZYc2ph7aEShFP6Q6ixZshaAOJVS6cBFyEsX0Ors7qyBvqMvN/2MQirQFVZtlA7irGqpGg4oY9ruY5RBvQWLNoX3m5n8Brq85IOHIHjH//tHd8zC8twXMLqzSrNiKu4zqLKZJcn23FSfvIG1wZEJMnudITv75jsOkS06rmEBRqUHeJrGHJxj7vzWihSCVnAtd83cXzstQNYI1XDFAbuTKBaS7kpn+/2CV+j45DD7QjhFAAuEVHfObefILymovxhcdxdxlksEkZYhtMdRMe0gmKWz4ll/etmpEf87sOE9dQGsAZgP9T5m//PZ3A/Hlupp2DRn7mwhsw45GxYWLPikJMe9NMWiD0dq3WKcsBpfKbFYRkOTIas4aDMToKwlGvTiIwatD4bnaVdplNcqE7jGjqlyx2QC0657Z0R1lHI5jj13w/pRgyJaPmELJRpTo6zUlcpP+XPPlFykHCMw4r7Rljz/d1XUTVlPRTZ8YD4IICPoayHpBOPZVXTNdZzAH+iXz9tAuZzug7gBf7MZZQ1nJbZHWopt6jDP7/jnNuKnBNhwcVb9Z12AbROqe7/iVpY6l5+gIjepe63ZBIIef6uc253FuPRCGv6WAZwBcDOMW7YPkpRuovJiHCd6S/Bn7tCjjMeHCM+L7+YmxCpDNo2n/d24pwk/3Hh4Zw7zRrnp2WlbgF4G1VifEuNhR1wMxdz+effFQQR3SKiH+K/syO+V/usX6uTcGMNBrOw6rEB4JljvscSE2ATt4lOYiU7hOgulkeTnnqGxV2c3THuvRHWPHgHPAk3ALxDPXakMYGyTtLc3PgZiO6FTf2FdYPPXGjDeY7DWgNw2Ya1wWCEtQhYQtlR2mAwGGHNtUsIlLuEl5RrdxS0cAYL/QfcXsNxL+LphFOcOZxn0X0NwBNTIPzsNAZ9qKWUImSKHWc4pVXyhO7DIsVUmYV1ONwA8NQxrYghTkiUPsRAdNOy/PjzTlR0N0tkMYjRLKyTx7sBPE1E64hk8DcYHP2THoixc1SP54s8AcwiNBjwOAgyI6I2//4Klfg0P9+x1d1gMMyKfJwioYyIWokf573+l4hoTEQDIvovRLTkvXfqveTznBGcwWCYFcllRPQ+IvonRDQkoj0iuk9EBRF9kYh+mIhW7EoZDPOLhbEQ2Jppocw6XwawDuAqgGsoA0AvoYyruqj+XuXfNwA8D+BplLrdPkrB3PH7raEUl98E8BbK6gtbAB4CeIAyQViSl7cAbPLvLr9XH1Xdc4PBMCMsmuheoBSVhWwcymoJO0w6q/yzDGCFH1sHcB3AGwB+AMAHmKT2UQaPSsPNrwP4IwB3+P02mbiEkPTvPSarASZ79hkMBsPUrLQWEX2GiP4PEXWJaIeI+kT0K0S0YVfIYDDMzEUMCO914nuLX/sSET3kXcJ/zI9lDcV2E9wNBsOJEV2Hf3+Bxff3SLiDXR2DYb5xHiPdpevu11HqWt9xzhXOubENB4PBCGvuwLt5rwP4vnNufNSKowaDwQjrpPAmgO/ZEDAYjLDmGRIr1UcZWwWc/RIxBoMR1oJjhDKOymAwGGEtBGH1bQgYDEZYi4Ahymh2g8FghDW3EA2rizINRz9mMBiMsOYSOwBu2xAwGIywFgFdAPfMwjIYjLDmFqoETB9lNQaDwWCENfcYs5VldcQNBiOsuUcOi8MyGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMhunh/wPh5HPieEpLcwAAAABJRU5ErkJggg=="
}),
red = table.concat({
"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"
})
}
local ids, okAll = {}, true
for _, k in ipairs({"glow", "white", "red"}) do
    local path = ASSETS .. "/1mag_logo_" .. k .. "_v2.png"
    if type(writefile) == "function" then
        local dd = decodeB64(LOGO_DATA[k])
        if type(dd) == "string" and dd:sub(2, 4) == "PNG" then pcall(writefile, path, dd) end
    end
    local id
    pcall(function()
        if type(isfile) == "function" and isfile(path) then
            if type(getcustomasset) == "function" then id = getcustomasset(path)
            elseif type(getsynasset) == "function" then id = getsynasset(path) end
        end
    end)
    if id then ids[k] = id else okAll = false end
end
if okAll then LOGO_LAYERS = ids end
end
local RAGE_ICON_PATH = ASSETS .. "/1mag_rage_icon.png"
local RAGE_ICON
do
    local d = decodeB64("iVBORw0KGgoAAAANSUhEUgAAACsAAAA0CAYAAAAT3cGOAAAFG0lEQVR42s2aXYhVVRTHf/fMnZkcdcwoM6mU0umLpqwgKciKFEJQCYIe8qWgh3qoIIh6DKKHIMIon4rKPsCQiPAhi9AIP4o+LbKQGmIKJw1zdJzr3Lnn38vasd2cc+4+Z+61WXCYe8/Ze+3/WXvt9fG/U5PEDKUO9AN9wFxgPtAL1IBJ4CjQAk4BzZkuVEX6gRuA5cD9wO0Gtkg+A14Dfga+AU6XXbRW0rLnA08DdwNXBs+mgBRIgvupGcU3zEHgY+BZYCx6dUkx1yJJW3WmTEqakNSU1FJ7adr4yeD+VtPfFkcM0Ac8xa0S4IokS88jkmpVwfZKetUUnTbl3ZCm6Zek7ZIGyoKdI+kjUzDRAUvGWPqEff5a0mAWrqwDNgB8Dqy0Q9PH2RO33vfAzUDDfxie3AR4w4A2zjJQbL0GMAy81C4aPOFt/f8pbv1NeW6wBPgDmJ5BsuikOByLgCOhG7xuAXy2yZthBrsK+Nbzm9kiU/b3OuCgs+x6Azk9y6yaGq5NzrIDwCHgAnOLZJYBnrYIsTgBVgAX2c1kFvrsNDAPWFoHro8oF1Ob5Kqq+gxfLPX8kYyqLKuMvaUmaRewuqC8SwoWpCTotM34rLDp5nyVGFDaAN0J3GUF9zpgj+ffaQWgbwF3AFcDNwHPeVaczsiqADeSU6S4e79IGsooKmqSrpU0UqJQkaRDkpbmFE8LJO0Oxp8h5JRsTUkH8qof75onaSyiKmtJ+r2o/LMrkbQjKBsLwbpBayK7iGHvJVWgb0WkviU5HUiL4A3cwwOS6pHKE0mf5AB2+n4toQ9JO7P0JcC73kl0h+W3EtksBbYF6TFMlx9aOx4rP2REnT0J8EHGiW6VjJsTbZ4fBsq00X9lgN2SWA+fBJYsW8xcUlDMA1xqpEesXBbEXoD9rt8a9aKAJP0taWGkf/XaSW9lRIWWnYljkvoj9fVI+tHzWadzQWIUz4teQG4A5wEPRlphjVl2usCy5wJrI/Wtt2TR8HRuBsbd29zpERf+KV7VxgqLMyzQzLCy27EL2+hbJumwN99Fqtv8VnyhpD+DRdwCj9pWh1u10dpnH2grI8H4pMZxSRtsfqjvPnM/f7zLenN8sDVJezNim1v8mD1/WdI2y1rhGDfvC0m3SnovA7CTI8ZLbJb0qX3P07ctJDku96yUdUDymJRWwGONWArGksC+IHW2CjJdM8d1vnMJxR2AVVbgTmUckD4v3vlXWNMOAI8DJ72QszEY52rhNEJf3fAMW7X3X5m3ISK+JsEVln67gfczksFTGaVfUqCPjBh7hSM5FgQxtqy4Lb64gDc7XpEvc7rflpQkllmqkhpTNvcVYDRnzCTwjFmvUZGZXw30J8C4Ve5VlE3ZvHeC+3OD718G2xorDXOz7UDDbdVKM/eJktvltmmLdQBDkl6w9Pu8BfkhSbvaRIK8gt1xXstDfvZJD8Dpihxrp7han7x+KI9MvrciiFZg7bAtaVZ82XXtmO/5RjX+1EVqvgjsPkvJ82KY75AF329VUFmOoArzssxo19xAXySnjCcoww9UZQrXFgGNtdSo/TpY7wLL6BMfe9sNjt3WsaAf6qS4GqDWKbDndNlnT8Y0lLGL93SZ1mx2CmyN7ktvp9xAXvPWDZ9NgcEYLEmksj1eNEgzQKcVL9e9/kPEP07E/r/BHGCHcaqdllPANcBIp8A6v3oYuMfAL/HKuAmrW5t2uTZl3AL9oHUhdTusPfb5KPCY+1GunfwLavaKRsm6IV0AAAAASUVORK5CYII=")
    if type(writefile) == "function" and type(d) == "string" and d:sub(2,4) == "PNG" then pcall(writefile, RAGE_ICON_PATH, d) end
    pcall(function()
        if type(isfile) == "function" and isfile(RAGE_ICON_PATH) then
            if type(getcustomasset) == "function" then RAGE_ICON = getcustomasset(RAGE_ICON_PATH)
            elseif type(getsynasset) == "function" then RAGE_ICON = getsynasset(RAGE_ICON_PATH) end
        end
    end)
end
local CUSTOM_ICONS = {Slide = {SLIDE_ICON, SLIDE_ICON_W, SLIDE_ICON_H}, Rage = {RAGE_ICON, 43, 52}}
local HOVER_SFX = "rbxassetid://119354387183704"
local CLICK_SFX = "rbxassetid://116080744084010"
local CONFIG_VALUES = {}
local LOADING = false   -- true while the saved config is being applied
local ENABLED, arrayRefresh = {}, nil   -- enabled toggles feed the HUD array list
local function flag(k) return CONFIG_VALUES[k] end
local function playSfx(id, vol)
if LOADING or CONFIG_VALUES["Settings.General.Interface.Sound FX"] == false then return end
local s = Instance.new("Sound")
s.SoundId = id; s.Volume = vol or 0.3; s.PlayOnRemove = true; s.Parent = SoundService
s:Destroy()
end
local function hoverSfx() playSfx(HOVER_SFX, 0.18) end
local function clickSfx() playSfx(CLICK_SFX, 0.32) end
local T = {
Accent = Color3.fromRGB(196, 26, 30), AccentHi = Color3.fromRGB(240, 62, 62),
Bg = Color3.fromRGB(10, 10, 13), Panel = Color3.fromRGB(16, 16, 20), PanelHi = Color3.fromRGB(23, 23, 28),
Element = Color3.fromRGB(28, 28, 34), ElementHi = Color3.fromRGB(42, 42, 50),
Border = Color3.fromRGB(52, 52, 62), Text = Color3.fromRGB(244, 244, 248),
Sub = Color3.fromRGB(165, 165, 176), Dim = Color3.fromRGB(100, 100, 112),
}
local F_BOLD, F_HEAVY = FX.Body, FX.Heavy
local function make(class, props, parent)
local o = Instance.new(class)
for k, v in pairs(props) do
if k == "TextSize" and type(v) == "number" and props.FontFace then v = math.floor(v * FX.Scale + 0.5) end
o[k] = v
end
if parent then o.Parent = parent end
return o
end
local function corner(o, r)
-- Use the requested radius instead of flattening every element to 5px.
-- Keep interior controls restrained; reserve the larger radius for the main window.
local requested = math.floor(tonumber(r) or 5)
local radius = requested >= 16 and 7 or requested >= 10 and 7 or requested >= 8 and 6 or math.clamp(requested, 2, 5)
local sz = o.Size
if sz.X.Scale == 0 and sz.Y.Scale == 0 and sz.X.Offset > 0 and sz.Y.Offset > 0
and radius * 2 >= math.min(sz.X.Offset, sz.Y.Offset) - 1 then
return make("UICorner", {CornerRadius = UDim.new(1, 0)}, o)
end
return make("UICorner", {CornerRadius = UDim.new(0, radius)}, o)
end
local function stroke(o, c, th, tr)
return make("UIStroke", {Color = c, Thickness = th or 1, Transparency = tr or 0,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function padding(o, t, r, b, l)
return make("UIPadding", {PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0),
PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0)}, o)
end
local DUMMY_TW = {Completed = {Connect = function(_, f) task.defer(f); return {Disconnect = function() end} end, Wait = function() task.wait(0.1) end},
Play = function() end, Cancel = function() end, Pause = function() end}
local function tween(o, t, props, style, dir)
if LOADING then
for k, v in pairs(props) do pcall(function() o[k] = v end) end
return DUMMY_TW
end
local tw = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint,
dir or Enum.EasingDirection.Out), props)
tw:Play()
return tw
end
local function ripple(parent, x, y)
local sz = parent.AbsoluteSize
if sz.X < 1 or sz.Y < 1 then return end
local r = make("Frame", {BackgroundColor3 = T.AccentHi, BackgroundTransparency = 0.72, BorderSizePixel = 0,
AnchorPoint = Vector2.new(0.5, 0.5), SizeConstraint = Enum.SizeConstraint.RelativeYY,
Position = UDim2.fromScale((x - parent.AbsolutePosition.X) / sz.X, (y - parent.AbsolutePosition.Y) / sz.Y),
Size = UDim2.fromScale(0, 0), ZIndex = 5}, parent)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, r)
local tw = tween(r, 0.55, {Size = UDim2.fromScale(14, 14), BackgroundTransparency = 1})
tw.Completed:Connect(function() r:Destroy() end)
end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local conns = {}
local function track(c) table.insert(conns, c); return c end
local accentHooks = {}
local function onAccent(f) table.insert(accentHooks, f); pcall(f) end
local function setAccent(c)
T.Accent = c
T.AccentHi = c:Lerp(Color3.new(1, 1, 1), 0.28)
for _, f in ipairs(accentHooks) do pcall(f) end
end
if LOGO_LAYERS then LOGO_ID = LOGO_ID or "layered" end
local function logoImg(props, parent)
if LOGO_LAYERS then
-- Layered logo: theme-coloured glow outline behind, white parts stay white, red parts follow the theme.
props.ScaleType = nil
local z = props.ZIndex or 1
local holder = make("Frame", props, parent)
local function lay(id, zi)
return make("ImageLabel", {BackgroundTransparency = 1, BorderSizePixel = 0, Image = id, Size = UDim2.fromScale(1, 1),
ScaleType = Enum.ScaleType.Fit, ZIndex = zi}, holder)
end
local glow = lay(LOGO_LAYERS.glow, z)
lay(LOGO_LAYERS.white, z + 1)
local red = lay(LOGO_LAYERS.red, z + 2)
onAccent(function() glow.ImageColor3 = T.Accent; red.ImageColor3 = T.AccentHi end)
return holder
end
props.Image = LOGO_ID
local img = make("ImageLabel", props, parent)
if LOGO_TINT then onAccent(function() img.ImageColor3 = T.AccentHi end) end
return img
end
-- Subtab icon atlas (coordinates copied from the supplied 1Mag icon source).
local SHEET_W, SHEET_H = 1536, 1024
local SUBTAB_ICONS = {
["Home"] = {64, 50, 77, 79},
["Combat"] = {223, 51, 82, 83},
["Visual"] = {376, 59, 98, 67},
["Character"] = {554, 50, 75, 82},
["World"] = {721, 49, 84, 83},
["Injector"] = {892, 50, 79, 84},
["Cosmetics"] = {1053, 52, 88, 68},
["1magstrap"] = {1217, 55, 90, 77},
["Settings"] = {1391, 51, 84, 87},
["Overview"] = {66, 249, 68, 79},
["Tips"] = {214, 242, 89, 98},
["Aim Assist"] = {376, 247, 97, 98},
["Silent Aim"] = {561, 248, 91, 87},
["Triggerbot"] = {1100, 244, 96, 99},
["ESP"] = {744, 248, 89, 87},
["Client Effects"] = {935, 245, 88, 83},
["Crosshair"] = {1100, 244, 96, 99},
["Movement"] = {1290, 246, 114, 88},
["Lighting"] = {73, 436, 91, 90},
["Skybox"] = {263, 440, 82, 85},
["Custom Sky"] = {456, 450, 93, 58},
["Effects"] = {662, 446, 63, 67},
["Skybox Cfg Loader"] = {836, 446, 87, 72},
["Texture Injector"] = {1021, 436, 74, 87},
["Custom Skin Tab"] = {1193, 446, 103, 77},
["Font Injector"] = {1382, 446, 90, 62},
["Kill Sounds Injector"] = {79, 642, 65, 63},
["Arena Creator"] = {250, 637, 88, 68},
["Skins"] = {447, 636, 65, 73},
["Wraps"] = {607, 636, 73, 73},
["Charms"] = {777, 634, 51, 79},
["Finishers"] = {927, 643, 77, 56},
["Appearance"] = {1097, 643, 88, 66},
["Mods"] = {1265, 637, 64, 71},
["Weapon Mod"] = {1265, 637, 64, 71},
["Engine Settings"] = {1409, 636, 65, 69},
["Config Profiles"] = {77, 837, 98, 79},
["General"] = {300, 842, 62, 64},
["Theme"] = {476, 835, 84, 83},
["Mobile"] = {682, 834, 54, 83},
["HUD"] = {853, 834, 82, 77},
["Optimisation"] = {1046, 839, 107, 72}
}
local function subtabIcon(name, size, parent)
    local ci = CUSTOM_ICONS[name]
    if ci and ci[1] then
        local holder = make("Frame", {Name="SubtabIcon", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.fromOffset(size,size), ZIndex=5}, parent)
        make("UIScale", {Name="IconScale"}, holder)
        local m = math.max(ci[2], ci[3])
        local clip = make("Frame", {BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true,
            AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
            Size=UDim2.fromOffset(size*ci[2]/m, size*ci[3]/m), ZIndex=5}, holder)
        local outlineImage = make("ImageLabel", {BackgroundTransparency=1, BorderSizePixel=0, Image=ci[1],
            ImageColor3=T.Accent:Lerp(Color3.new(0,0,0),0.55), Size=UDim2.fromScale(1.14,1.14), Position=UDim2.fromScale(-0.07,-0.07), ZIndex=5}, clip)
        local image = make("ImageLabel", {BackgroundTransparency=1, BorderSizePixel=0, Image=ci[1],
            ImageColor3=T.AccentHi, Size=UDim2.fromScale(1,1), ZIndex=6}, clip)
        onAccent(function() image.ImageColor3 = T.AccentHi; outlineImage.ImageColor3 = T.Accent:Lerp(Color3.new(0,0,0),0.55) end)
        return holder
    end
    if name == "Rage" then
        local holder = make("Frame", {Name="SubtabIcon", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.fromOffset(size,size), ZIndex=5}, parent)
        make("UIScale", {Name="IconScale"}, holder)
        local glyph = make("TextLabel", {BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Text="☠", FontFace=F_HEAVY, TextSize=size,
            TextColor3=T.AccentHi, TextStrokeColor3=T.Accent:Lerp(Color3.new(0,0,0),0.55), TextStrokeTransparency=0, TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center, ZIndex=6}, holder)
        onAccent(function() glyph.TextColor3=T.AccentHi; glyph.TextStrokeColor3=T.Accent:Lerp(Color3.new(0,0,0),0.55) end)
        return holder
    end
    local b = SUBTAB_ICONS[name]
    if not (ICON_SHEET and b) then return nil end
    local x,y,w,h = b[1],b[2],b[3],b[4]
    local m = math.max(w,h)
    local holder = make("Frame", {Name="SubtabIcon", BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.fromOffset(size,size), ZIndex=5}, parent)
    make("UIScale", {Name="IconScale"}, holder)
    local clip = make("Frame", {BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true,
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(size*w/m,size*h/m), ZIndex=5}, holder)
    -- Accent silhouette beneath the white glyph creates a clean theme-coloured outline.
    local outlineImage = make("ImageLabel", {BackgroundTransparency=1, BorderSizePixel=0, Image=ICON_SHEET,
        ImageColor3=T.Accent:Lerp(Color3.new(0,0,0),0.55), Size=UDim2.fromScale((SHEET_W/w)*1.14,(SHEET_H/h)*1.14),
        Position=UDim2.fromScale((-x/w)*1.14-0.07,(-y/h)*1.14-0.07), ZIndex=5}, clip)
    local image = make("ImageLabel", {BackgroundTransparency=1, BorderSizePixel=0, Image=ICON_SHEET,
        ImageColor3=T.AccentHi, Size=UDim2.fromScale(SHEET_W/w,SHEET_H/h),
        Position=UDim2.fromScale(-x/w,-y/h), ZIndex=6}, clip)
    onAccent(function() image.ImageColor3 = T.AccentHi; outlineImage.ImageColor3 = T.Accent:Lerp(Color3.new(0,0,0),0.55) end)
    return holder
end
local registry = {}
local toggleKeys = {}
local resetters, markDirty, clearDirty = {}, function() end, function() end
local function encode() return HttpService:JSONEncode(CONFIG_VALUES) end
local CFG_READY = false   -- saving is blocked until the saved config has been applied (so defaults never overwrite it)
local function saveConfig()
if type(writefile) ~= "function" then return false end
if not CFG_READY then return true end
local ok = pcall(function() writefile(CONFIG, encode()) end)
if ok then clearDirty() end
return ok
end
local function applyTable(d)
for k, v in pairs(d) do
CONFIG_VALUES[k] = v
if registry[k] then pcall(registry[k], v) end
end
end
local function loadConfig()
if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(CONFIG) then return false end
local ok, d = pcall(function() return HttpService:JSONDecode(readfile(CONFIG)) end)
if ok and type(d) == "table" then applyTable(d); return true end
return false
end
local SAVED = {}
local BASE_COS = {}   -- cosmetics straight from config.json (profiles must never override these)
do
if type(isfile) == "function" and type(readfile) == "function" and isfile(CONFIG) then
local ok, d = pcall(function() return HttpService:JSONDecode(readfile(CONFIG)) end)
if ok and type(d) == "table" then
SAVED = d
for k, v in pairs(d) do
if type(k) == "string" and k:find("^Cosmetics%.") then BASE_COS[k] = v end
end
end
end
local AUTOLOAD = ROOT .. "/autoload.json"
if type(isfile) == "function" and type(readfile) == "function" and isfile(AUTOLOAD)
and SAVED["Configs.Config Profiles.Auto Load.Auto Load On Startup"] ~= false then
local ok, a = pcall(function() return HttpService:JSONDecode(readfile(AUTOLOAD)) end)
if ok and type(a) == "table" and type(a.profile) == "string" then
local path = PROFILES .. "/" .. a.profile .. ".json"
if isfile(path) then
local ok2, d = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
if ok2 and type(d) == "table" then for k, v in pairs(d) do SAVED[k] = v end end
end
end
end
for k, v in pairs(BASE_COS) do SAVED[k] = v end
for k in pairs(SAVED) do
if type(k) == "string" and k:find("^Visual%.ESP%.") then SAVED[k] = nil end
end
for k, v in pairs(SAVED) do
if type(k) == "string" and (k:find("^Cosmetics%.") or k:find("^Mobile%.pos%.") or k == "World.CustomSkies") then
CONFIG_VALUES[k] = v
SAVED[k] = nil
end
end
do   -- cosmetics have their own file: 1MagHub/cosmetics.json
local COSFILE = ROOT .. "/cosmetics.json"
if type(isfile) == "function" and type(readfile) == "function" and isfile(COSFILE) then
local okc, dc = pcall(function() return HttpService:JSONDecode(readfile(COSFILE)) end)
if okc and type(dc) == "table" then
if type(dc.Equipped) == "table" then CONFIG_VALUES["Cosmetics.Equipped"] = dc.Equipped end
if type(dc.Enabled) == "boolean" then CONFIG_VALUES["Cosmetics.Skins.Master.Enable Cosmetics"] = dc.Enabled end
if type(dc.Invert) == "boolean" then CONFIG_VALUES["Cosmetics.Wraps.Options.Invert Patterns"] = dc.Invert end
end
end
end
end
for _, n in ipairs({"1MagHub", "1MagLoading", "1MagHUD", "1MagFov", "1MagCrosshairImg"}) do
for _, old in ipairs(PG:GetChildren()) do if old.Name == n then pcall(function() old:Destroy() end) end end
end
FX.HOLD = {}   -- overlay GUIs stay hidden until the saved config has been applied
FX.holdGui = function(g) g.Enabled = false; FX.HOLD[#FX.HOLD + 1] = g end
FX.releaseGuis = function() for _, g in ipairs(FX.HOLD) do pcall(function() g.Enabled = true end) end FX.HOLD = {} end
-- Overlay GUIs are released after config application below.
local gui = make("ScreenGui", {Name = "1MagHub", ResetOnSpawn = false, IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999}, PG)
FX.shimmer(gui)
local fpsValue = 60
do
local frames, lastT = 0, tick()
track(RunService.RenderStepped:Connect(function()
frames += 1
local now = tick()
if now - lastT >= 1 then fpsValue = frames; frames = 0; lastT = now end
end))
end
local function getPing()
local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
return ok and math.floor(v) or 0
end
local gameName = "Unknown"
pcall(function() gameName = Marketplace:GetProductInfo(game.PlaceId).Name end)
local notifHolder = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(270, 400), ZIndex = 900}, gui)
make("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom,
HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8),
SortOrder = Enum.SortOrder.LayoutOrder}, notifHolder)
local function notify(title, text, dur, kind)
dur = dur or 3.5
local col = (kind == "danger" and Color3.fromRGB(255, 80, 80)) or (kind == "ok" and Color3.fromRGB(80, 225, 120)) or T.AccentHi
local n = make("CanvasGroup", {BackgroundColor3 = T.PanelHi, Size = UDim2.fromOffset(280, 66),
GroupTransparency = 1, ZIndex = 900}, notifHolder)
corner(n, 10); stroke(n, T.Border, 1, 0.2)
make("Frame", {BackgroundColor3 = col, Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0}, n)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 6), Size = UDim2.new(1, -22, 0, 18),
Text = string.upper(title), FontFace = F_HEAVY, TextSize = 16, TextColor3 = col,
TextXAlignment = Enum.TextXAlignment.Left}, n)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 26), Size = UDim2.new(1, -22, 0, 32),
Text = text, FontFace = F_BOLD, TextSize = 17, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true}, n)
local bar = make("Frame", {BackgroundColor3 = col, BackgroundTransparency = 0.25, AnchorPoint = Vector2.new(0, 1),
Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0}, n)
tween(n, 0.3, {GroupTransparency = 0})
tween(bar, dur, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
task.delay(dur, function()
if n.Parent then tween(n, 0.25, {GroupTransparency = 1}).Completed:Connect(function() n:Destroy() end) end
end)
end
local WIN_W, WIN_H = 780, 470
local TOP_H, SIDE_W, CARD_H, SQ = 42, 152, 48, 40
local SUB_H, DESC_H = 30, 0
local holder = make("Frame", {Name = "Holder", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(WIN_W, WIN_H)}, gui)
local holderScale = make("UIScale", {Scale = 1}, holder)
local glow = make("Frame", {BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(WIN_W + 14, WIN_H + 14), Visible = false}, holder)
corner(glow, 12)
onAccent(function() glow.BackgroundColor3 = T.Accent end)
local shadow = make("ImageLabel", {BackgroundTransparency = 1, ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 1,
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(WIN_W + 60, WIN_H + 60), Image = "rbxasset://textures/ui/Glow.png", Visible = false}, holder)
local win = make("CanvasGroup", {Name = "Window", BackgroundColor3 = T.Bg, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), GroupTransparency = 1, Visible = false, ClipsDescendants = true}, holder)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, win)
do
local ws = make("UIStroke", {Color = Color3.fromRGB(254, 254, 254), Thickness = 2, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, win)
local wg = make("UIGradient", {Name = "NoTheme"}, ws)
onAccent(function() wg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.AccentHi), ColorSequenceKeypoint.new(1, T.Accent)}) end)
TweenService:Create(wg, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
end
-- Light Sway: a faint glow that slowly drifts side to side behind everything else in the window
local LS = {on = true}
local swayGlow = make("ImageLabel", {Name = "LightSway", BackgroundTransparency = 1, Image = "rbxasset://textures/ui/Glow.png",
ImageTransparency = 0.92, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.3, 0.5),
Size = UDim2.fromOffset(WIN_W * 1.1, WIN_W * 1.1), ZIndex = 0}, win)
onAccent(function() swayGlow.ImageColor3 = T.AccentHi end)
task.spawn(function()
while swayGlow.Parent do
if LS.on and win.Visible then
tween(swayGlow, 3.4, {Position = UDim2.fromScale(0.7, 0.42)}, Enum.EasingStyle.Sine).Completed:Wait()
if LS.on and win.Visible then
tween(swayGlow, 3.4, {Position = UDim2.fromScale(0.3, 0.58)}, Enum.EasingStyle.Sine).Completed:Wait()
end
else
task.wait(0.25)
end
end
end)
local winStroke = stroke(win, Color3.new(1, 1, 1), 1, 0.15)
local winGrad = make("UIGradient", {}, winStroke)
onAccent(function()
winGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.35, T.Border),
ColorSequenceKeypoint.new(0.65, T.Border), ColorSequenceKeypoint.new(1, T.AccentHi)})
shadow.ImageColor3 = T.Accent
end)
track(RunService.Heartbeat:Connect(function(dt) winGrad.Rotation = (winGrad.Rotation + dt * 14) % 360 end))
local winScale = make("UIScale", {Scale = 0.88}, win)
FX.Flame = {on = true, n = UIS.TouchEnabled and 24 or 44}
do
local F = FX.Flame
local GLOW = "rbxasset://textures/ui/Glow.png"
local overlay = make("Frame", {Name = "Flame", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 0, Active = false}, gui)
local halo = make("ImageLabel", {BackgroundTransparency = 1, Image = GLOW, AnchorPoint = Vector2.new(0.5, 0.5),
ImageTransparency = 1, ZIndex = 0, Visible = false}, overlay)
local pool, active = {}, {}
local function newSprite()
return make("ImageLabel", {BackgroundTransparency = 1, Image = GLOW, AnchorPoint = Vector2.new(0.5, 0.5),
ImageTransparency = 1, Visible = false, ZIndex = 1}, overlay)
end
local rnd, WHITE = math.random, Color3.new(1, 1, 1)
local hx, hy, hvx, hvy = nil, nil, 0, 0
local last, acc, spawnAcc = os.clock(), 0, 0
local function spawnOne(px, py, pw, ph, sc)
local r, x, y, vx = rnd(), 0, 0, 0
if r < 0.30 then x, y, vx = px + rnd() * pw, py + 2, (rnd() - 0.5) * 30
elseif r < 0.57 then x, y, vx = px + 2, py + rnd() * ph, -rnd() * 35
elseif r < 0.84 then x, y, vx = px + pw - 2, py + rnd() * ph, rnd() * 35
else x, y, vx = px + rnd() * pw, py + ph - 2, (rnd() - 0.5) * 70 end
active[#active + 1] = {s = table.remove(pool) or newSprite(), x = x, y = y, vx = vx * sc, vy = -(55 + rnd() * 75) * sc,
age = 0, life = 0.7 + rnd() * 0.8, size = (20 + rnd() * 22) * sc, ph = rnd() * 6.28}
end
track(RunService.RenderStepped:Connect(function()
local now = os.clock()
acc += now - last; last = now
if acc < (UIS.TouchEnabled and 1 / 30 or 1 / 60) then return end
local dt = math.min(acc, 0.06); acc = 0
local vis = F.on and win.Visible
local alpha = vis and (1 - win.GroupTransparency) or 0
if not vis and #active == 0 then halo.Visible = false; hx = nil; return end
local ap, asz, off = holder.AbsolutePosition, holder.AbsoluteSize, overlay.AbsolutePosition
if hx then
local k = math.min(1, dt * 12)
hvx += ((ap.X - hx) / dt - hvx) * k; hvy += ((ap.Y - hy) / dt - hvy) * k
end
hx, hy = ap.X, ap.Y
local sc = holderScale.Scale
local aB, aA, bg = T.AccentHi, T.Accent, T.Bg
halo.Visible = alpha > 0.01
halo.Position = UDim2.fromOffset(ap.X + asz.X / 2 - off.X, ap.Y + asz.Y / 2 - off.Y)
halo.Size = UDim2.fromOffset(asz.X * 1.4, asz.Y * 1.5)
halo.ImageColor3 = aA
local fl = 0.5 + 0.25 * math.sin(now * 9.3) + 0.15 * math.sin(now * 3.1 + 1) + 0.1 * math.sin(now * 17)
halo.ImageTransparency = 1 - math.clamp((0.14 + 0.1 * fl) * alpha, 0, 1)
if vis and alpha > 0.2 then
local want = math.clamp(F.n, 0, 120)
spawnAcc += dt * want / 1.1
local g = 0
while spawnAcc >= 1 and #active < want * 1.3 and g < 8 do
spawnAcc -= 1; g += 1; spawnOne(ap.X, ap.Y, asz.X, asz.Y, sc)
end
if spawnAcc > 3 then spawnAcc = 0 end
else spawnAcc = 0 end
local hot = aB:Lerp(WHITE, 0.65)
local i = 1
while i <= #active do
local p = active[i]
p.age += dt
local t = p.age / p.life
if t >= 1 then
p.s.Visible = false
if #pool < 140 then pool[#pool + 1] = p.s else p.s:Destroy() end
active[i] = active[#active]; active[#active] = nil
else
p.vy -= 55 * sc * dt
p.vx += math.sin(now * 7 + p.ph + p.y * 0.03) * 70 * sc * dt
p.vx -= hvx * 0.9 * dt; p.vy -= hvy * 0.9 * dt
p.vx *= 1 - math.min(1, 1.4 * dt); p.vy *= 1 - math.min(1, 0.5 * dt)
p.x += p.vx * dt; p.y += p.vy * dt
local col
if t < 0.2 then col = hot:Lerp(aB, t / 0.2)
elseif t < 0.6 then col = aB:Lerp(aA, (t - 0.2) / 0.4)
else col = aA:Lerp(bg, math.min(1, (t - 0.6) / 0.4 * 0.85)) end
local a = math.min(1, t / 0.1) * (1 - t) ^ 1.3
local sz = p.size * (1 - 0.7 * t)
local s = p.s
s.Visible = true
s.ImageColor3 = col
s.ImageTransparency = 1 - math.clamp(a * 0.6 * alpha, 0, 1)
s.Size = UDim2.fromOffset(sz, sz * 1.8)
s.Position = UDim2.fromOffset(p.x - off.X, p.y - off.Y)
s.Rotation = math.clamp(p.vx * 0.15, -25, 25)
i += 1
end
end
end))
end
for _, o in ipairs(Lighting:GetChildren()) do if o.Name == "1MagBlur" then o:Destroy() end end
local blurFx = make("BlurEffect", {Name = "1MagBlur", Size = 0}, Lighting)
local blurOn = true
local refreshBlur = function() end
make("UIGradient", {Rotation = 120, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(196, 196, 202))}, win)
do
local parts = {}
for _, c in ipairs({{0, 0}, {1, 0}, {0, 1}, {1, 1}}) do
local ax, ay = c[1], c[2]
local sx, sy = (ax == 0) and 1 or -1, (ay == 0) and 1 or -1
for _, d in ipairs({{14, 2}, {2, 14}}) do
table.insert(parts, make("Frame", {BackgroundColor3 = T.AccentHi, BorderSizePixel = 0, AnchorPoint = Vector2.new(ax, ay),
Position = UDim2.new(ax, 6 * sx, ay, 6 * sy), Size = UDim2.fromOffset(d[1], d[2]), ZIndex = 12}, win))
end
end
onAccent(function() for _, p in ipairs(parts) do p.BackgroundColor3 = T.AccentHi end end)
end
local sweep = make("Frame", {BackgroundColor3 = T.AccentHi, BorderSizePixel = 0, Size = UDim2.new(0, 110, 1, 0),
Position = UDim2.fromOffset(-120, 0), ZIndex = 11, Visible = false}, win)
make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.82),
NumberSequenceKeypoint.new(1, 1)})}, sweep)
onAccent(function() sweep.BackgroundColor3 = T.AccentHi end)
local topLine = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 0, 2),
BorderSizePixel = 0, ZIndex = 10}, win)
local topGrad = make("UIGradient", {}, topLine)
onAccent(function()
topGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.AccentHi),
ColorSequenceKeypoint.new(1, T.Accent)})
end)
local top = make("Frame", {BackgroundColor3 = T.Panel, Size = UDim2.new(1, 0, 0, TOP_H), BorderSizePixel = 0, ZIndex = 3}, win)
do
local tw = make("Frame", {BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3}, top)
make("UIGradient", {Name = "NoTheme", Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(0.6, 0.94), NumberSequenceKeypoint.new(1, 1)})}, tw)
end
make("Frame", {BackgroundColor3 = T.Border, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
BorderSizePixel = 0, ZIndex = 4}, top)
local leftRow = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 2),
Size = UDim2.new(0, 0, 1, -2), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4}, top)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, leftRow)
if LOGO_ID then
logoImg({BackgroundTransparency = 1, Size = UDim2.fromOffset(32, 32),
ScaleType = Enum.ScaleType.Fit, LayoutOrder = 1, ZIndex = 4}, leftRow)
else
make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(32, 32), Text = "1M", FontFace = F_HEAVY,
TextSize = 22, TextColor3 = T.AccentHi, LayoutOrder = 1, ZIndex = 4}, leftRow)
end
local titleLbl = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
Text = "1Mag.ez", FontFace = F_HEAVY, TextSize = 26, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 2, ZIndex = 4}, leftRow)
local titleGrad = make("UIGradient", {}, titleLbl)
onAccent(function()
titleGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Text), ColorSequenceKeypoint.new(0.5, T.AccentHi),
ColorSequenceKeypoint.new(1, T.Text)})
end)
do
local b = make("Frame", {BackgroundColor3 = T.Element, Size = UDim2.fromOffset(76, 20), BorderSizePixel = 0,
LayoutOrder = 3, ZIndex = 4}, leftRow)
corner(b, 10)
local bs = stroke(b, T.Accent, 1, 0.4)
local bl = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "FREEMIUM",
FontFace = F_HEAVY, TextSize = 15, TextColor3 = T.AccentHi, ZIndex = 5}, b)
onAccent(function() bs.Color = T.Accent; bl.TextColor3 = T.AccentHi end)
end
do -- green "Free" status next to the badge
local GREEN = Color3.fromRGB(70, 225, 110)
local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
LayoutOrder = 4, ZIndex = 4}, leftRow)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, row)
local dotHolder = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(12, 12), LayoutOrder = 1, ZIndex = 4}, row)
local halo = make("Frame", {BackgroundColor3 = GREEN, BackgroundTransparency = 0.6, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BorderSizePixel = 0, ZIndex = 4}, dotHolder)
corner(halo, 6)
local dot = make("Frame", {BackgroundColor3 = GREEN, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(8, 8), BorderSizePixel = 0, ZIndex = 5}, dotHolder)
corner(dot, 4)
make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
Text = "Free", FontFace = F_HEAVY, TextSize = 18, TextColor3 = GREEN, LayoutOrder = 2, ZIndex = 5}, row)
end
local rightRow = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 1), Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4}, top)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, rightRow)
local searchWrap = make("Frame", {BackgroundColor3 = T.Element, Size = UDim2.fromOffset(150, 28), BorderSizePixel = 0,
LayoutOrder = 1, ZIndex = 5}, rightRow)
corner(searchWrap, 9)
local searchStroke = stroke(searchWrap, T.Border, 1, 0.4)
local searchBox = make("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -16, 1, 0),
Text = "", PlaceholderText = "search features...", PlaceholderColor3 = T.Dim, FontFace = F_BOLD, TextSize = 17,
TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 6}, searchWrap)
track(UIS.InputBegan:Connect(function(i, gp)
if gp or i.KeyCode ~= Enum.KeyCode.Slash or UIS:GetFocusedTextBox() then return end
if not searchBox:IsDescendantOf(gui) then return end
searchBox:CaptureFocus()
task.defer(function() searchBox.Text = "" end)
end))
searchBox.Focused:Connect(function() tween(searchStroke, 0.15, {Color = T.Accent, Transparency = 0}) end)
searchBox.FocusLost:Connect(function() tween(searchStroke, 0.15, {Color = T.Border, Transparency = 0.4}) end)
local crumb = make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 24, 0.5, 1),
Size = UDim2.fromOffset(240, 20), Text = "", FontFace = F_HEAVY, TextSize = 16, TextColor3 = T.Dim,
TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4}, top)
local function topButton(text, w, order)
local b = make("TextButton", {BackgroundColor3 = T.Element, Size = UDim2.fromOffset(w, 28), Text = text,
FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.Text, AutoButtonColor = false, LayoutOrder = order, ZIndex = 5}, rightRow)
corner(b, 9)
b.MouseEnter:Connect(function() hoverSfx(); tween(b, 0.15, {BackgroundColor3 = T.ElementHi}) end)
b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = T.Element}) end)
b.MouseButton1Click:Connect(clickSfx)
return b
end
local saveBtn = topButton("SAVE", 52, 2)
local closeBtn = topButton("X", 28, 3)
do
local dot = make("Frame", {BackgroundColor3 = T.AccentHi, Size = UDim2.fromOffset(9, 9), AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, 2, 0, -2), BorderSizePixel = 0, Visible = false, ZIndex = 8}, saveBtn)
corner(dot, 5)
onAccent(function() dot.BackgroundColor3 = T.AccentHi end)
local dirty = false
markDirty = function()
if dirty then return end
dirty = true; dot.Visible = true; dot.Size = UDim2.fromOffset(0, 0)
tween(dot, 0.3, {Size = UDim2.fromOffset(9, 9)}, Enum.EasingStyle.Back)
end
clearDirty = function() dirty = false; dot.Visible = false end
local function doSave()
local ok = saveConfig()
notify("Config", ok and ("Saved to /" .. CONFIG) or "Executor has no writefile", 2.5, ok and "ok" or "danger")
end
saveBtn.MouseButton1Click:Connect(doSave)
track(UIS.InputBegan:Connect(function(i, gp)
if gp or i.KeyCode ~= Enum.KeyCode.S or not win.Visible then return end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then doSave() end
end))
end
local sidebar = make("Frame", {BackgroundColor3 = T.Panel, Position = UDim2.fromOffset(0, TOP_H),
Size = UDim2.new(0, SIDE_W, 1, -TOP_H), BorderSizePixel = 0, ZIndex = 2}, win)
make("Frame", {BackgroundColor3 = T.Border, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, ZIndex = 3}, sidebar)
local sideBody = make("ScrollingFrame", {BackgroundTransparency = 1, Size = UDim2.new(1, -1, 1, -CARD_H), BorderSizePixel = 0,
ScrollBarThickness = 2, ScrollBarImageColor3 = T.Border, CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 2}, sidebar)
padding(sideBody, 8, 7, 7, 7)
make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, sideBody)
local ddList = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true,
LayoutOrder = 1, ZIndex = 2}, sideBody)
make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, ddList)
local ddFullH, sideOrder = 0, 0
local function addGroup(label)
sideOrder += 1
local g = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Text = string.upper(label),
FontFace = F_HEAVY, TextSize = 14, TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
LayoutOrder = sideOrder, ZIndex = 3}, ddList)
padding(g, 6, 0, 0, 10)
ddFullH += 22 + 3
ddList.Size = UDim2.new(1, 0, 0, ddFullH)
end
local card = make("Frame", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
Size = UDim2.new(1, -1, 0, CARD_H), BorderSizePixel = 0, ZIndex = 3}, sidebar)
make("Frame", {BackgroundColor3 = T.Border, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 4}, card)
local avatar = make("ImageLabel", {BackgroundColor3 = T.Element, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(32, 32),
BorderSizePixel = 0, ZIndex = 4, Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=60&h=60&f=png"}, card)
corner(avatar, 9)
local avStroke = stroke(avatar, T.Accent, 1.2, 0.3)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -56, 0, 18),
Text = player.DisplayName, FontFace = F_HEAVY, TextSize = 18, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4}, card)
local cardSub = make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(50, 27), Size = UDim2.new(1, -56, 0, 16),
Text = "Freemium  -  v1.2", FontFace = F_BOLD, TextSize = 15, TextColor3 = T.AccentHi,
TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4}, card)
onAccent(function() avStroke.Color = T.Accent; cardSub.TextColor3 = T.AccentHi end)
local content = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(SIDE_W, TOP_H),
Size = UDim2.new(1, -SIDE_W, 1, -TOP_H), ZIndex = 2}, win)
local subBarHolder = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, SUB_H + 4), ZIndex = 3}, content)
make("Frame", {BackgroundColor3 = T.Border, BackgroundTransparency = 0.4, Position = UDim2.new(0, 10, 0, SUB_H + 3),
Size = UDim2.new(1, -20, 0, 1), BorderSizePixel = 0, ZIndex = 3}, content)
local descLabel = make("TextLabel", {BackgroundTransparency = 1, Visible = false, Position = UDim2.fromOffset(14, SUB_H + 6),
Size = UDim2.new(1, -28, 0, 0), Text = "", FontFace = F_BOLD, TextSize = 16, TextColor3 = T.Sub,
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3}, content)
local pagesHolder = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(0, SUB_H + DESC_H + 8),
Size = UDim2.new(1, 0, 1, -(SUB_H + 8 + 24)), ClipsDescendants = true, ZIndex = 2}, content)
make("Frame", {BackgroundColor3 = T.Border, BackgroundTransparency = 0.5, AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new(0, 10, 1, -24), Size = UDim2.new(1, -20, 0, 1), BorderSizePixel = 0, ZIndex = 3}, content)
make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -3),
Size = UDim2.new(1, -200, 0, 18), Text = "",
FontFace = F_BOLD, TextSize = 14, TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3}, content)
local statLbl = make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -3),
Size = UDim2.fromOffset(180, 18), Text = "", FontFace = F_HEAVY, TextSize = 14, TextColor3 = T.AccentHi,
TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3}, content)
onAccent(function() statLbl.TextColor3 = T.AccentHi end)
task.spawn(function()
while gui.Parent do
local on = 0
for _ in pairs(ENABLED) do on += 1 end
statLbl.Text = fpsValue .. " FPS  |  " .. getPing() .. " ms  |  " .. on .. " ON"
task.wait(0.5)
end
end)
local emptyLbl = make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45),
Size = UDim2.new(1, -40, 0, 40), Text = "", FontFace = F_HEAVY, TextSize = 20, TextColor3 = T.Dim, Visible = false, ZIndex = 3}, pagesHolder)
local mains, activeMain, activeSub = {}, nil, nil
local badgeRefresh
badgeRefresh = function()
for _, m in ipairs(mains) do
if m.badge and m.name ~= "Settings" and m.name ~= "Configs" then
local c, pre = 0, m.name .. "."
for k, v in pairs(CONFIG_VALUES) do
if v == true and type(k) == "string" and string.sub(k, 1, #pre) == pre then c += 1 end
end
m.badge.Text = tostring(c)
m.badge.Visible = c > 0
end
end
end
local filterPage
filterPage = function(page)
if not page then return end
local q = string.lower(searchBox.Text or "")
local collapsed = {}
for _, c in ipairs(page:GetChildren()) do
if c:GetAttribute("IsHeader") and c:GetAttribute("Col") then collapsed[c:GetAttribute("SecId")] = true end
end
for _, c in ipairs(page:GetChildren()) do
if c:IsA("GuiObject") then
local sid = c:GetAttribute("SecId")
if c:GetAttribute("Hid") then
c.Visible = false
elseif c:GetAttribute("IsHeader") then
c.Visible = (q == "")
elseif c:GetAttribute("Sec") then
c.Visible = (q == "") and not collapsed[sid]
else
local sx = c:GetAttribute("S")
if sx then
if q == "" then c.Visible = not collapsed[sid]
else c.Visible = string.find(sx, q, 1, true) ~= nil end
end
end
end
end
end
do
local raw = filterPage
filterPage = function(host)
    if not host then return end
    local q = string.lower(searchBox.Text or "")
    local any = false
    local pages = host:GetAttribute("TwoColumn") and {host:FindFirstChild("LeftColumn"), host:FindFirstChild("RightColumn")} or {host}
    for _, pg in ipairs(pages) do
        if pg then
            raw(pg)
            if q ~= "" then
                for _, c in ipairs(pg:GetChildren()) do
                    if c:IsA("GuiObject") and c.Visible and c:GetAttribute("S") then any = true; break end
                end
            end
        end
    end
    emptyLbl.Visible = (q ~= "" and not any)
    if emptyLbl.Visible then emptyLbl.Text = "Nothing matches \"" .. searchBox.Text .. "\"" end
end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() filterPage(activeSub and activeSub.page) end)
local function selectSub(m, s)
if activeSub == s then return end
if activeSub then
activeSub.page.Visible = false
tween(activeSub.label, 0.18, {TextColor3 = T.Sub}); activeSub.label.FontFace = F_BOLD
tween(activeSub.line, 0.2, {Size = UDim2.new(0, 0, 0, 2)})
if activeSub.icon then tween(activeSub.icon, 0.2, {Scale = 1}) end
end
activeSub = s
m.lastSub = s
s.page.Visible = true
if s.leftPage then s.leftPage.CanvasPosition = Vector2.new(0,0); s.rightPage.CanvasPosition = Vector2.new(0,0) end
filterPage(s.page)
descLabel.Text = s.desc or ""
crumb.Text = string.upper(m.name) .. "   >   " .. string.upper(s.name)
tween(s.label, 0.18, {TextColor3 = T.Text}); s.label.FontFace = F_HEAVY
tween(s.line, 0.28, {Size = UDim2.new(1, -14, 0, 2)}, Enum.EasingStyle.Back)
if s.icon then tween(s.icon, 0.28, {Scale = 1.12}, Enum.EasingStyle.Back) end
s.page.Position = UDim2.fromOffset(14, 0)
tween(s.page, 0.25, {Position = UDim2.fromOffset(0, 0)})
end
local function selectMain(m)
if activeMain == m then return end
if activeMain then
activeMain.bar.scroll.Visible = false
tween(activeMain.item, 0.18, {BackgroundTransparency = 1})
tween(activeMain.itemLbl, 0.18, {TextColor3 = T.Sub}); activeMain.itemLbl.FontFace = F_BOLD
tween(activeMain.itemBar, 0.18, {BackgroundTransparency = 1, Size = UDim2.fromOffset(3, 6)})
if activeSub then activeSub.page.Visible = false; activeSub = nil end
end
activeMain = m
m.bar.scroll.Visible = true
tween(m.item, 0.18, {BackgroundTransparency = 0.8})
tween(m.itemLbl, 0.18, {TextColor3 = T.Text}); m.itemLbl.FontFace = F_HEAVY
tween(m.itemBar, 0.24, {BackgroundTransparency = 0, Size = UDim2.fromOffset(3, 14)}, Enum.EasingStyle.Back)
if m.subs[1] then selectSub(m, m.lastSub or m.subs[1]) end
end
local function addMain(name, desc)
local m = {name = name, desc = desc, subs = {}}
local item = make("TextButton", {BackgroundColor3 = T.Accent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
Text = "", AutoButtonColor = false, LayoutOrder = sideOrder + 1, ZIndex = 3}, ddList)
sideOrder += 1
corner(item, 9)
local itemBar = make("Frame", {BackgroundColor3 = T.Accent, BackgroundTransparency = 1, Size = UDim2.fromOffset(3, 6),
AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), BorderSizePixel = 0, ZIndex = 4}, item)
corner(itemBar, 2)
local itemLbl = make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 0),
Size = UDim2.new(1, -22, 1, 0), Text = name, FontFace = F_BOLD, TextSize = 20, TextColor3 = T.Sub,
TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4}, item)
m.item, m.itemBar, m.itemLbl = item, itemBar, itemLbl
local badge = make("TextLabel", {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.3, AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(22, 16), Text = "", FontFace = F_HEAVY, TextSize = 14,
TextColor3 = Color3.new(1, 1, 1), Visible = false, ZIndex = 4}, item)
corner(badge, 8)
m.badge = badge
onAccent(function() badge.BackgroundColor3 = T.Accent end)
onAccent(function()
item.BackgroundColor3 = T.Accent; itemBar.BackgroundColor3 = T.Accent
end)
local scroll = make("ScrollingFrame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4),
Size = UDim2.new(1, -20, 0, SUB_H - 2), Visible = false, BorderSizePixel = 0, ScrollBarThickness = 0,
ScrollingDirection = Enum.ScrollingDirection.X, CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.X, ZIndex = 3}, subBarHolder)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, scroll)
m.bar = {scroll = scroll}
item.MouseEnter:Connect(function()
if activeMain ~= m then hoverSfx(); tween(item, 0.15, {BackgroundTransparency = 0.9}); tween(itemLbl, 0.15, {TextColor3 = T.Text}) end
end)
item.MouseLeave:Connect(function()
if activeMain ~= m then tween(item, 0.15, {BackgroundTransparency = 1}); tween(itemLbl, 0.15, {TextColor3 = T.Sub}) end
end)
item.MouseButton1Click:Connect(function() if activeMain ~= m then clickSfx(); selectMain(m) end end)
table.insert(mains, m)
ddFullH += 28 + 3
ddList.Size = UDim2.new(1, 0, 0, ddFullH)
return m
end
local function addSub(m, name, desc, singleColumn)
local s = {name = name, desc = desc, main = m}
local btn = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
Text = "", AutoButtonColor = false, LayoutOrder = #m.subs + 1, ZIndex = 4}, m.bar.scroll)
-- Use a real horizontal layout: the icon and title occupy separate slots, never overlap.
local content = make("Frame", {Name="SubtabContent", BackgroundTransparency=1, Size=UDim2.new(0,0,1,0),
AutomaticSize=Enum.AutomaticSize.X, ZIndex=5}, btn)
make("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,9),
SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center}, content)
padding(content,0,10,0,10)
local sIcon = subtabIcon(name, 17, content)
local sIconScale = sIcon and sIcon:FindFirstChild("IconScale")
if sIcon then
    sIcon.LayoutOrder = 1
else
    -- Keep text alignment consistent even for subtabs without an atlas match.
    make("Frame", {Name="IconSpacer", BackgroundTransparency=1, Size=UDim2.fromOffset(17,17),
    LayoutOrder=1, ZIndex=5}, content)
end
local title = make("TextLabel", {Name="SubtabTitle", BackgroundTransparency=1,
Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X, Text=name, FontFace=F_BOLD,
TextSize=19, TextColor3=T.Sub, TextXAlignment=Enum.TextXAlignment.Left,
LayoutOrder=2, ZIndex=6}, content)
local line = make("Frame", {BackgroundColor3 = T.Accent, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
Size = UDim2.new(0, 0, 0, 2), BorderSizePixel = 0, ZIndex = 5}, btn)
corner(line, 2)
onAccent(function() line.BackgroundColor3 = T.Accent end)
s.btn, s.line, s.label, s.icon = btn, line, title, sIconScale
local host, leftPage, rightPage, page
if singleColumn then
    -- Cosmetic pickers need the full content width so weapon and item cards are not squeezed.
    host = make("ScrollingFrame", {Name="SubtabFullWidth", BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1), Visible=false, BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=T.Accent, CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=2}, pagesHolder)
    padding(host,7,8,8,8)
    make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, host)
    onAccent(function() host.ScrollBarImageColor3=T.Accent end)
    page = host
else
    host = make("Frame", {Name="SubtabColumns", BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Visible=false, ZIndex=2}, pagesHolder)
    host:SetAttribute("TwoColumn", true)
    local function newColumn(name, pos)
        local col = make("ScrollingFrame", {Name=name, BackgroundTransparency=1, Position=pos,
            Size=UDim2.new(0.5,-7,1,0), BorderSizePixel=0, ScrollBarThickness=3,
            ScrollBarImageColor3=T.Accent, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=2}, host)
        padding(col,7,8,8,8)
        make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, col)
        onAccent(function() col.ScrollBarImageColor3=T.Accent end)
        return col
    end
    leftPage = newColumn("LeftColumn", UDim2.fromScale(0,0))
    rightPage = newColumn("RightColumn", UDim2.new(0.5,12,0,0))
    page = leftPage
end
local sectionCount = 0
s.page, s.leftPage, s.rightPage = host, leftPage, rightPage
table.insert(m.subs, s)
btn.MouseEnter:Connect(function() if activeSub ~= s then hoverSfx(); tween(title, 0.15, {TextColor3 = T.Text}); if s.icon then tween(s.icon, 0.18, {Scale = 1.18}, Enum.EasingStyle.Back) end end end)
btn.MouseLeave:Connect(function() if activeSub ~= s then tween(title, 0.15, {TextColor3 = T.Sub}); if s.icon then tween(s.icon, 0.18, {Scale = 1}) end end end)
btn.MouseButton1Click:Connect(function() if activeSub ~= s then clickSfx(); selectSub(m, s) end end)
local API, n, curSec, curSecId = {}, 0, "Main", 0
local prefix = m.name .. "." .. name .. "."
local function keyOf(text) return prefix .. curSec .. "." .. text end
local function rowBase(h, text)
n += 1
local f = make("Frame", {BackgroundColor3 = T.Element, Size = UDim2.new(1, 0, 0, h), BorderSizePixel = 0,
LayoutOrder = n, ZIndex = 3}, page)
corner(f, 9)
stroke(f, T.Border, 1, 0.55)
local eh = math.max(8, math.min(h, 36) - 12)
local edge = make("Frame", {Name = "Edge", BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
Position = UDim2.fromOffset(0, (math.min(h, 36) - eh) / 2), Size = UDim2.fromOffset(2, eh), ZIndex = 5}, f)
onAccent(function() if not edge:GetAttribute("Fixed") then edge.BackgroundColor3 = T.Accent end end)
if text then f:SetAttribute("S", string.lower(text)) end
f:SetAttribute("SecId", curSecId)
return f
end
local function rowLabel(parent, text, w)
return make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, w or -24, 1, 0),
Text = text, FontFace = F_BOLD, TextSize = 18, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4}, parent)
end
local function hoverRow(f, hit)
local edge = f:FindFirstChild("Edge")
hit.MouseEnter:Connect(function()
hoverSfx(); tween(f, 0.15, {BackgroundColor3 = T.ElementHi})
if edge and not f:GetAttribute("On") then tween(edge, 0.15, {BackgroundTransparency = 0.5}) end
end)
hit.MouseLeave:Connect(function()
tween(f, 0.15, {BackgroundColor3 = T.Element})
if edge and not f:GetAttribute("On") then tween(edge, 0.15, {BackgroundTransparency = 1}) end
end)
end
function API.Section(text)
curSec = text
sectionCount += 1
page = (sectionCount % 2 == 1) and leftPage or rightPage
local sectionPage = page
n += 1
curSecId = n
local f = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = n, ZIndex = 3}, sectionPage)
f:SetAttribute("Sec", true); f:SetAttribute("IsHeader", true); f:SetAttribute("SecId", n); f:SetAttribute("Col", false)
local rule = make("Frame", {BackgroundColor3 = T.Accent, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -2),
Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 4}, f)
make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1),
NumberSequenceKeypoint.new(0.55, 0.7), NumberSequenceKeypoint.new(1, 1)})}, rule)
local dia = make("Frame", {BackgroundColor3 = T.Accent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 7, 0, 15),
Size = UDim2.fromOffset(7, 7), Rotation = 45, BorderSizePixel = 0, ZIndex = 4}, f)
onAccent(function() rule.BackgroundColor3 = T.Accent; dia.BackgroundColor3 = T.Accent end)
local lbl = make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 5), Size = UDim2.new(1, -50, 0, 22),
Text = string.upper(text), FontFace = F_HEAVY, TextSize = 18, TextColor3 = T.Text,
TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4}, f)
local chev = make("TextLabel", {Name = "Chev", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0, 17), Size = UDim2.fromOffset(18, 18), Text = "v", FontFace = F_HEAVY, TextSize = 17,
TextColor3 = T.Dim, ZIndex = 4}, f)
local hit = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 6}, f)
hit.MouseEnter:Connect(function() tween(chev, 0.12, {TextColor3 = T.AccentHi}); tween(lbl, 0.12, {TextColor3 = T.AccentHi}) end)
hit.MouseLeave:Connect(function() tween(chev, 0.12, {TextColor3 = T.Dim}); tween(lbl, 0.12, {TextColor3 = T.Text}) end)
hit.MouseButton1Click:Connect(function()
clickSfx()
local c = not f:GetAttribute("Col")
f:SetAttribute("Col", c)
tween(chev, 0.22, {Rotation = c and -90 or 0}, Enum.EasingStyle.Back)
filterPage(sectionPage)
end)
hit.MouseButton2Click:Connect(function()
clickSfx()
local anyOpen = false
for _, c in ipairs(sectionPage:GetChildren()) do
if c:GetAttribute("IsHeader") and not c:GetAttribute("Col") then anyOpen = true; break end
end
for _, c in ipairs(sectionPage:GetChildren()) do
if c:GetAttribute("IsHeader") then
c:SetAttribute("Col", anyOpen)
local ch = c:FindFirstChild("Chev")
if ch then tween(ch, 0.22, {Rotation = anyOpen and -90 or 0}, Enum.EasingStyle.Back) end
end
end
filterPage(sectionPage)
end)
end
function API.Hint(text)
n += 1
local f = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = n, ZIndex = 3}, page)
f:SetAttribute("Sec", true); f:SetAttribute("SecId", curSecId)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -14, 1, 0),
Text = text, FontFace = F_BOLD, TextSize = 15, TextColor3 = T.Sub, TextTransparency = 0.25,
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4}, f)
return f
end
function API.Label(text)
local f = rowBase(28, text)
local l = rowLabel(f, text)
l.TextColor3 = T.Sub; l.TextSize = math.floor(17 * FX.Scale + 0.5)
return {Set = function(_, t) l.Text = t end}
end
function API.Toggle(text, default, cb, hide)
local key = keyOf(text)
local def = default and true or false
if CONFIG_VALUES[key] ~= nil then default = CONFIG_VALUES[key] end
local f = rowBase(32, text)
f.ClipsDescendants = true
local lbl = rowLabel(f, text, -64)
local OFF, OFFLINE = Color3.fromRGB(38, 38, 48), Color3.fromRGB(104, 104, 116)
local track = make("Frame", {BackgroundColor3 = OFF, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(36, 18), BorderSizePixel = 0, ZIndex = 5}, f)
corner(track, 99)
make("UIGradient", {Name = "NoTheme", Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 200))}, track)
local bs = stroke(track, OFFLINE, 1, 0)
local knob = make("Frame", {BackgroundColor3 = Color3.fromRGB(254, 254, 252), AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(12, 12), BorderSizePixel = 0, ZIndex = 6}, track)
corner(knob, 99)
local edge = f:FindFirstChild("Edge")
local state = default and true or false
local function paint(on)
tween(track, 0.18, {BackgroundColor3 = on and T.Accent or OFF})
tween(bs, 0.18, {Color = on and T.AccentHi or OFFLINE})
tween(knob, 0.18, {Position = on and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
tween(lbl, 0.18, {TextColor3 = on and T.Text or T.Sub})
f:SetAttribute("On", on)
if edge then tween(edge, 0.2, {BackgroundTransparency = on and 0 or 1}) end
end
local function set(v, silent)
state = v and true or false
CONFIG_VALUES[key] = state
if not hide and not (key:find("^Settings%.") or key:find("^Configs%.")) then
ENABLED[key] = state and text or nil
if arrayRefresh and not LOADING then arrayRefresh() end
end
paint(state)
if badgeRefresh and not LOADING then badgeRefresh() end
if cb and not silent then task.spawn(cb, state) end
end
local hit = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 7}, f)
hoverRow(f, hit)
hit.MouseButton1Click:Connect(function() clickSfx(); markDirty(); set(not state) end)
hit.MouseButton2Click:Connect(function() clickSfx(); markDirty(); set(def) end)
set(state, true)
onAccent(function()
if state then track.BackgroundColor3 = T.Accent; bs.Color = T.AccentHi end
end)
registry[key] = function(v) set(v) end
resetters[key] = function() set(def) end
toggleKeys[key] = true
if cb and state then task.spawn(cb, state) end
return {Set = function(_, v) set(v) end}
end
function API.Slider(text, min, max, default, cb, step)
local key = keyOf(text)
step = step or 1
local def = default
if CONFIG_VALUES[key] ~= nil then default = CONFIG_VALUES[key] end
local f = rowBase(48, text)
local lb = rowLabel(f, text, -100)
lb.Position = UDim2.fromOffset(12, 6); lb.Size = UDim2.new(1, -100, 0, 20)
local val = make("TextBox", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 5),
Size = UDim2.fromOffset(64, 22), FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.AccentHi, Text = "",
ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5}, f)
corner(val, 4); stroke(val, T.Border, 1, 0.5)
local bar = make("Frame", {Position = UDim2.new(0, 12, 1, -16), Size = UDim2.new(1, -24, 0, 6),
BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 4}, f)
corner(bar, 3)
local fill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 5}, bar)
corner(fill, 3)
local fillGrad = make("UIGradient", {}, fill)
local knob = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 6}, bar)
corner(knob, 7)
local ks = stroke(knob, T.Accent, 1.5, 0.1)
onAccent(function() fillGrad.Color = ColorSequence.new(T.Accent, T.AccentHi); ks.Color = T.Accent; val.TextColor3 = T.AccentHi end)
local function setValue(v, silent)
v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
v = tonumber(string.format("%.4f", v))
local a = (v - min) / math.max(1e-9, (max - min))
val.Text = string.format("%g", v)
fill.Size = UDim2.fromScale(a, 1)
knob.Position = UDim2.fromScale(a, 0.5)
CONFIG_VALUES[key] = v
if cb and not silent then task.spawn(cb, v) end
end
setValue(default, true)
if cb then task.spawn(cb, CONFIG_VALUES[key]) end
val.FocusLost:Connect(function()
local typed = tonumber(val.Text)
if typed then setValue(typed); markDirty() else setValue(CONFIG_VALUES[key], true) end
end)
local dragging = false
local function update(i)
local rel = (i.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
setValue(min + (max - min) * math.clamp(rel, 0, 1))
markDirty()
end
f.InputBegan:Connect(function(i)
if isPress(i) then
local p, ap, as = i.Position, val.AbsolutePosition, val.AbsoluteSize
if p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y then return end
dragging = true; update(i)
tween(knob, 0.12, {Size = UDim2.fromOffset(18, 18)})
i.Changed:Connect(function()
if i.UserInputState == Enum.UserInputState.End then
dragging = false; tween(knob, 0.12, {Size = UDim2.fromOffset(14, 14)})
end
end)
end
end)
track(UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then update(i) end end))
hoverRow(f, f)
registry[key] = function(v) setValue(v) end
resetters[key] = function() setValue(def) end
f.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton2 then clickSfx(); markDirty(); setValue(def) end
end)
if cb then task.spawn(cb, CONFIG_VALUES[key]) end
return {Set = function(_, v) setValue(v) end, Frame = f}
end
function API.Button(text, cb)
local f = rowBase(32, text)
f.ClipsDescendants = true
local b = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false, ZIndex = 6}, f)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -44, 1, 0), Text = text,
FontFace = F_HEAVY, TextSize = 18, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4}, f)
local arrow = make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(18, 18), Text = ">", FontFace = F_HEAVY, TextSize = 18, TextColor3 = T.Dim, ZIndex = 4}, f)
hoverRow(f, b)
b.MouseEnter:Connect(function() tween(arrow, 0.18, {Position = UDim2.new(1, -7, 0.5, 0), TextColor3 = T.AccentHi}) end)
b.MouseLeave:Connect(function() tween(arrow, 0.18, {Position = UDim2.new(1, -12, 0.5, 0), TextColor3 = T.Dim}) end)
b.MouseButton1Click:Connect(function()
clickSfx()
local m = UIS:GetMouseLocation()
ripple(f, m.X, m.Y - 36)
tween(f, 0.08, {BackgroundColor3 = T.Accent})
task.delay(0.12, function() tween(f, 0.2, {BackgroundColor3 = T.Element}) end)
if cb then task.spawn(cb) end
end)
end
function API.Danger(text, cb)
local f = rowBase(36, text)
local BASE, HOT, ARMED = Color3.fromRGB(40, 14, 16), Color3.fromRGB(62, 20, 24), Color3.fromRGB(110, 26, 32)
local RED = Color3.fromRGB(235, 70, 76)
f.BackgroundColor3 = BASE
f.ClipsDescendants = true
local fs = f:FindFirstChildOfClass("UIStroke")
if fs then fs.Color = Color3.fromRGB(200, 50, 56); fs.Transparency = 0.4 end
local edge = f:FindFirstChild("Edge")
if edge then edge:SetAttribute("Fixed", true); edge.BackgroundColor3 = RED; edge.BackgroundTransparency = 0 end
local warn = make("TextLabel", {BackgroundColor3 = RED, Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(20, 20),
Text = "!", FontFace = F_HEAVY, TextSize = 17, TextColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 7}, f)
corner(warn, 4)
local b = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = text, FontFace = F_HEAVY,
TextSize = 18, TextColor3 = Color3.fromRGB(255, 130, 130), TextXAlignment = Enum.TextXAlignment.Left,
AutoButtonColor = false, ZIndex = 6}, f)
padding(b, 0, 0, 0, 46)
local bar = make("Frame", {BackgroundColor3 = RED, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
Size = UDim2.new(0, 0, 0, 2), BorderSizePixel = 0, ZIndex = 7}, f)
local armed, token, bt = false, 0, nil
local function disarm()
armed = false; b.Text = text
if bt then bt:Cancel(); bt = nil end
bar.Size = UDim2.new(0, 0, 0, 2)
tween(f, 0.2, {BackgroundColor3 = BASE})
end
b.MouseEnter:Connect(function() hoverSfx(); if not armed then tween(f, 0.15, {BackgroundColor3 = HOT}) end end)
b.MouseLeave:Connect(function() if not armed then tween(f, 0.15, {BackgroundColor3 = BASE}) end end)
b.MouseButton1Click:Connect(function()
local m = UIS:GetMouseLocation()
ripple(f, m.X, m.Y - 36)
if not armed then
clickSfx(); armed = true; token += 1
local mine = token
b.Text = "CLICK AGAIN TO CONFIRM"
tween(f, 0.15, {BackgroundColor3 = ARMED})
bar.Size = UDim2.new(1, 0, 0, 2)
bt = tween(bar, 3, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
task.delay(3, function() if armed and token == mine then disarm() end end)
else
token += 1; disarm()
if cb then task.spawn(cb) end
end
end)
end
function API.IconButton(text, cb)
local f = rowBase(30, text)
rowLabel(f, text, -60)
local b = make("TextButton", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(30, 24), Text = "", AutoButtonColor = false, ZIndex = 5}, f)
corner(b, 7)
local bs = stroke(b, T.Border, 1, 0.3)
local icon = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), ZIndex = 6}, b)
local ring = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6}, icon)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
local rs = stroke(ring, T.AccentHi, 2, 0)
make("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.62, 0),
NumberSequenceKeypoint.new(0.63, 1), NumberSequenceKeypoint.new(0.75, 1),
NumberSequenceKeypoint.new(0.76, 0), NumberSequenceKeypoint.new(1, 0)})}, rs)
local head = make("Frame", {BackgroundColor3 = T.AccentHi, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(1, -1, 0, 2), Size = UDim2.fromOffset(5, 5), Rotation = 45, ZIndex = 7}, icon)
onAccent(function() rs.Color = T.AccentHi; head.BackgroundColor3 = T.AccentHi end)
b.MouseEnter:Connect(function()
hoverSfx(); tween(b, 0.15, {BackgroundColor3 = T.ElementHi}); tween(f, 0.15, {BackgroundColor3 = T.ElementHi})
end)
b.MouseLeave:Connect(function()
tween(b, 0.15, {BackgroundColor3 = T.PanelHi}); tween(f, 0.15, {BackgroundColor3 = T.Element})
end)
b.MouseButton1Click:Connect(function()
clickSfx()
tween(icon, 0.45, {Rotation = icon.Rotation + 360}, Enum.EasingStyle.Quint)
if cb then task.spawn(cb) end
end)
end
function API.TextBox(text, placeholder, cb)
local key = keyOf(text)
local f = rowBase(30, text)
rowLabel(f, text, -170)
local tb = make("TextBox", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.fromOffset(150, 24), Text = CONFIG_VALUES[key] or "", PlaceholderText = placeholder or "type...",
PlaceholderColor3 = T.Dim, FontFace = F_BOLD, TextSize = 17, TextColor3 = T.Text, ClearTextOnFocus = false, ZIndex = 5}, f)
corner(tb, 6); stroke(tb, T.Border, 1, 0.4)
tb.FocusLost:Connect(function()
CONFIG_VALUES[key] = tb.Text
if cb then task.spawn(cb, tb.Text) end
end)
registry[key] = function(v) tb.Text = tostring(v) end
resetters[key] = function() tb.Text = ""; CONFIG_VALUES[key] = "" end
return {Get = function() return tb.Text end, Set = function(_, v) tb.Text = tostring(v) end}
end
function API.Keybind(text, default)
local key = keyOf(text)
if CONFIG_VALUES[key] then default = CONFIG_VALUES[key] end
CONFIG_VALUES[key] = default
local f = rowBase(30, text)
rowLabel(f, text, -120)
local kb = make("TextButton", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.fromOffset(96, 24), Text = default or "None", FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.AccentHi,
AutoButtonColor = false, ZIndex = 5}, f)
corner(kb, 6); stroke(kb, T.Border, 1, 0.4)
onAccent(function() kb.TextColor3 = T.AccentHi end)
kb.MouseEnter:Connect(function() hoverSfx(); tween(kb, 0.15, {BackgroundColor3 = T.ElementHi}) end)
kb.MouseLeave:Connect(function() tween(kb, 0.15, {BackgroundColor3 = T.PanelHi}) end)
local listening
kb.MouseButton1Click:Connect(function()
clickSfx()
if listening then return end
kb.Text = "..."
listening = UIS.InputBegan:Connect(function(i)
if i.KeyCode ~= Enum.KeyCode.Unknown and (i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType.Name:find("^Gamepad")) then
kb.Text = i.KeyCode.Name
CONFIG_VALUES[key] = i.KeyCode.Name
listening:Disconnect(); listening = nil
end
end)
end)
registry[key] = function(v) kb.Text = tostring(v) end
end
local function expandable(text, headW)
local HEAD = 30
local f = rowBase(HEAD, text)
f.ClipsDescendants = true
rowLabel(f, text, -(headW + 20))
local state = {open = false, body = 0}
function state.apply() tween(f, 0.2, {Size = UDim2.new(1, 0, 0, state.open and (HEAD + 6 + state.body) or HEAD)}) end
function state.toggle(v) state.open = v; state.apply() end
return f, HEAD, state
end
function API.Dropdown(text, options, default, cb)
local key = keyOf(text)
local def = default or options[1]
if CONFIG_VALUES[key] then default = CONFIG_VALUES[key] end
local current = default or options[1]
CONFIG_VALUES[key] = current
local f, HEAD, st = expandable(text, 120)
local head = make("TextButton", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 5),
Size = UDim2.fromOffset(120, 24), Text = tostring(current) .. "  v", FontFace = F_HEAVY, TextSize = 17,
TextColor3 = T.Text, AutoButtonColor = false, ZIndex = 5}, f)
corner(head, 6); stroke(head, T.Border, 1, 0.4)
head.MouseEnter:Connect(function() hoverSfx(); tween(head, 0.15, {BackgroundColor3 = T.ElementHi}) end)
head.MouseLeave:Connect(function() tween(head, 0.15, {BackgroundColor3 = T.PanelHi}) end)
local list = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, HEAD + 2),
Size = UDim2.new(1, -16, 0, 0), ZIndex = 4}, f)
make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, list)
local function setCurrent(v, silent)
current = v; CONFIG_VALUES[key] = v; head.Text = tostring(v) .. "  v"
if cb and not silent then task.spawn(cb, v) end
end
local function rebuild(opts)
for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
for i, opt in ipairs(opts) do
local o = make("TextButton", {BackgroundColor3 = T.PanelHi, Size = UDim2.new(1, 0, 0, 26), Text = tostring(opt),
FontFace = F_BOLD, TextSize = 18, TextColor3 = T.Text, AutoButtonColor = false, LayoutOrder = i, ZIndex = 5}, list)
corner(o, 6)
o.MouseEnter:Connect(function() hoverSfx(); tween(o, 0.12, {BackgroundColor3 = T.ElementHi}) end)
o.MouseLeave:Connect(function() tween(o, 0.12, {BackgroundColor3 = T.PanelHi}) end)
o.MouseButton1Click:Connect(function() clickSfx(); markDirty(); setCurrent(opt); st.toggle(false) end)
end
st.body = #opts * 28
list.Size = UDim2.new(1, -16, 0, st.body)
if st.open then st.apply() end
end
rebuild(options)
head.MouseButton1Click:Connect(function() clickSfx(); st.toggle(not st.open) end)
registry[key] = function(v) setCurrent(v) end
resetters[key] = function() setCurrent(def) end
if cb then task.spawn(cb, current) end
return {Set = function(_, v) setCurrent(v) end, SetOptions = function(_, o) rebuild(o) end, Get = function() return current end,
Frame = f, Open = function(v) st.toggle(v ~= false) end}
end
function API.MultiDropdown(text, options, defaults)
local key = keyOf(text)
local sel = {}
local src = CONFIG_VALUES[key] or defaults or {}
for _, v in ipairs(src) do sel[v] = true end
local f, HEAD, st = expandable(text, 120)
local head = make("TextButton", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 5),
Size = UDim2.fromOffset(120, 24), Text = "", FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.Text,
AutoButtonColor = false, ZIndex = 5}, f)
corner(head, 6); stroke(head, T.Border, 1, 0.4)
local list = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, HEAD + 2),
Size = UDim2.new(1, -16, 0, #options * 28), ZIndex = 4}, f)
make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, list)
st.body = #options * 28
local btns = {}
local function refresh()
local arr, c = {}, 0
for _, o in ipairs(options) do
if sel[o] then c += 1; table.insert(arr, o) end
if btns[o] then tween(btns[o], 0.12, {BackgroundColor3 = sel[o] and T.Accent or T.PanelHi}) end
end
head.Text = c .. " selected  v"
CONFIG_VALUES[key] = arr
end
for i, opt in ipairs(options) do
local o = make("TextButton", {BackgroundColor3 = T.PanelHi, Size = UDim2.new(1, 0, 0, 26), Text = tostring(opt),
FontFace = F_BOLD, TextSize = 18, TextColor3 = T.Text, AutoButtonColor = false, LayoutOrder = i, ZIndex = 5}, list)
corner(o, 6)
btns[opt] = o
o.MouseEnter:Connect(hoverSfx)
o.MouseButton1Click:Connect(function() clickSfx(); sel[opt] = not sel[opt]; refresh() end)
end
refresh()
head.MouseEnter:Connect(hoverSfx)
head.MouseButton1Click:Connect(function() clickSfx(); st.toggle(not st.open) end)
registry[key] = function(v) sel = {}; for _, x in ipairs(v) do sel[x] = true end; refresh() end
end
local PALETTE = {"#C41A1E", "#F03E3E", "#F08C00", "#FAB005", "#40C057", "#12B886", "#228BE6", "#7048E8", "#E64980", "#FFFFFF"}
function API.ColorWheel(text, defaultHex, cb)
local key = keyOf(text)
local function resolve(d)
if d == "@accent" then return "#" .. T.Accent:ToHex() elseif d == "@accenthi" then return "#" .. T.AccentHi:ToHex() end
return d
end
local isTheme = type(defaultHex) == "string" and defaultHex:sub(1, 1) == "@"
local follow = isTheme and (CONFIG_VALUES[key] == nil or CONFIG_VALUES[key .. "~f"] == true)
local defHex = resolve(defaultHex)
local hex = follow and defHex or CONFIG_VALUES[key] or defHex or "#FFFFFF"
local okc, c0 = pcall(Color3.fromHex, hex)
if not okc then hex = defHex or "#FFFFFF"; c0 = Color3.fromHex(hex) end
local h, s, v = c0:ToHSV()
local f, HEAD, st = expandable(text, 44)
local sw = make("TextButton", {BackgroundColor3 = c0, AnchorPoint = Vector2.new(0.5, 0.5), Rotation = 0,
Position = UDim2.new(1, -24, 0, HEAD / 2), Size = UDim2.fromOffset(20, 20), Text = "", AutoButtonColor = false, ZIndex = 5}, f)
corner(sw, 99)
local swS = stroke(sw, Color3.fromRGB(254, 254, 254), 2.5, 0)
local swG = make("UIGradient", {Name = "NoTheme", Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 110, 130)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))})}, swS)
TweenService:Create(swG, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
local WD = 152
local BH = WD + 8
local body = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, HEAD + 2),
Size = UDim2.new(1, -16, 0, BH), ZIndex = 4}, f)
st.body = BH + 4
local ui, built = {}, false
local function refresh(silent)
local col = Color3.fromHSV(h, s, v)
hex = "#" .. col:ToHex()
CONFIG_VALUES[key] = hex
if isTheme then CONFIG_VALUES[key .. "~f"] = follow end
sw.BackgroundColor3 = col
swS.Color = col:Lerp(Color3.new(1, 1, 1), 0.3)
if built then
ui.rimG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, col), ColorSequenceKeypoint.new(0.5, col:Lerp(Color3.new(1, 1, 1), 0.7)), ColorSequenceKeypoint.new(1, col)})
local a = h * math.pi * 2
ui.knob.Position = UDim2.fromScale(0.5 + math.sin(a) * s * 0.5, 0.5 - math.cos(a) * s * 0.5)
ui.knobFill.BackgroundColor3 = col
ui.shade.BackgroundTransparency = v
ui.vGrad.Color = ColorSequence.new(Color3.fromHSV(h, s, 1), Color3.new(0, 0, 0))
ui.vKnob.Position = UDim2.fromScale(0.5, 1 - v)
ui.prev.BackgroundColor3 = col
if not ui.hexBox:IsFocused() then ui.hexBox.Text = hex end
ui.info.Text = string.format("Hue %d   Sat %d%%   Val %d%%", math.floor(h * 360 + 0.5),
math.floor(s * 100 + 0.5), math.floor(v * 100 + 0.5))
end
if cb and not silent then task.spawn(cb, hex) end
end
local function build()
if built then return end
built = true
local box = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 4),
Size = UDim2.fromOffset(WD, WD), ZIndex = 5}, body)
local disc = make("CanvasGroup", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
Size = UDim2.fromScale(1, 1), ZIndex = 5}, box)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, disc)
local R, N = WD / 2, 72
local w = math.ceil(2 * math.pi * R / N) + 3
for i = 0, N - 1 do
local hh = i / N
local sp = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, WD + 4), Rotation = hh * 360, ZIndex = 5}, disc)
make("UIGradient", {Name = "NoTheme", Rotation = 90,
Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(hh, 1, 1)),
ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}),
Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0),
NumberSequenceKeypoint.new(0.501, 1), NumberSequenceKeypoint.new(1, 1)})}, sp)
end
ui.shade = make("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = v, BorderSizePixel = 0,
Size = UDim2.fromScale(1, 1), ZIndex = 6}, disc)
local rim = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 7}, box)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, rim)
local rimS = stroke(rim, Color3.fromRGB(254, 254, 254), 3, 0)
ui.rimG = make("UIGradient", {Name = "NoTheme"}, rimS)
TweenService:Create(ui.rimG, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
ui.knob = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(18, 18), ZIndex = 9}, box)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, ui.knob)
stroke(ui.knob, Color3.new(0, 0, 0), 1, 0.4)
ui.knobFill = make("Frame", {BackgroundColor3 = Color3.fromHSV(h, s, v), BorderSizePixel = 0, Position = UDim2.fromOffset(3, 3),
Size = UDim2.new(1, -6, 1, -6), ZIndex = 10}, ui.knob)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, ui.knobFill)
local vb = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
Position = UDim2.fromOffset(4 + WD + 14, 4), Size = UDim2.fromOffset(20, WD), ZIndex = 5}, body)
corner(vb, 6); stroke(vb, T.Border, 1, 0.3)
ui.vGrad = make("UIGradient", {Name = "NoTheme", Rotation = 90}, vb)
ui.vKnob = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 8, 0, 6), BackgroundTransparency = 1, ZIndex = 8}, vb)
stroke(ui.vKnob, Color3.new(1, 1, 1), 2, 0)
local X0 = 4 + WD + 14 + 20 + 18
ui.hexBox = make("TextBox", {BackgroundColor3 = T.PanelHi, Position = UDim2.fromOffset(X0, 4), Size = UDim2.fromOffset(112, 28),
Text = hex, PlaceholderText = "#RRGGBB", PlaceholderColor3 = T.Dim, FontFace = F_HEAVY, TextSize = 19,
TextColor3 = T.AccentHi, ClearTextOnFocus = false, ZIndex = 5}, body)
corner(ui.hexBox, 6); stroke(ui.hexBox, T.Border, 1, 0.4)
ui.prev = make("Frame", {BackgroundColor3 = Color3.fromHSV(h, s, v), BorderSizePixel = 0,
Position = UDim2.fromOffset(X0 + 120, 4), Size = UDim2.fromOffset(60, 28), ZIndex = 5}, body)
corner(ui.prev, 6); stroke(ui.prev, T.Border, 1, 0.2)
make("UIGradient", {Name = "NoTheme", Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 170, 180))}, ui.prev)
ui.info = make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(X0, 40), Size = UDim2.fromOffset(280, 20),
Text = "", FontFace = F_BOLD, TextSize = 16, TextColor3 = T.Sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, body)
local rl = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(X0 + 4, 74), Size = UDim2.fromOffset(300, 28), ZIndex = 5}, body)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 9),
VerticalAlignment = Enum.VerticalAlignment.Center}, rl)
local pal = {table.unpack(PALETTE)}
pal[1] = "#" .. T.Accent:ToHex(); pal[2] = "#" .. T.AccentHi:ToHex()
for _, ph in ipairs(pal) do
local c = make("TextButton", {BackgroundColor3 = Color3.fromHex(ph), Size = UDim2.fromOffset(17, 17), Rotation = 45,
Text = "", AutoButtonColor = false, ZIndex = 6}, rl)
corner(c, 3)
c.MouseEnter:Connect(hoverSfx)
c.MouseButton1Click:Connect(function()
clickSfx(); markDirty()
follow = false; h, s, v = Color3.fromHex(ph):ToHSV(); refresh(false)
end)
end
local mode
local function update(i)
if mode == "wheel" then
local c = box.AbsolutePosition + box.AbsoluteSize / 2
local dx, dy = i.Position.X - c.X, i.Position.Y - c.Y
s = math.clamp(math.sqrt(dx * dx + dy * dy) / math.max(1, box.AbsoluteSize.X / 2), 0, 1)
h = (math.atan2(dx, -dy) / (2 * math.pi)) % 1
elseif mode == "val" then
v = 1 - math.clamp((i.Position.Y - vb.AbsolutePosition.Y) / math.max(1, vb.AbsoluteSize.Y), 0, 1)
end
follow = false; refresh(false); markDirty()
end
local function begin(which)
return function(i)
if not isPress(i) then return end
mode = which; update(i)
i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then mode = nil end end)
end
end
box.InputBegan:Connect(begin("wheel"))
vb.InputBegan:Connect(begin("val"))
track(UIS.InputChanged:Connect(function(i) if mode and isMove(i) then update(i) end end))
ui.hexBox.FocusLost:Connect(function()
local t = (ui.hexBox.Text:gsub("%s", ""))
if t:sub(1, 1) ~= "#" then t = "#" .. t end
local ok, c = pcall(Color3.fromHex, t)
if ok then follow = false; h, s, v = c:ToHSV(); markDirty() end
refresh(false)
end)
refresh(true)
end
sw.MouseButton1Click:Connect(function()
clickSfx()
local o = not st.open
if o then build() end
st.toggle(o)
end)
registry[key] = function(x)
local ok, c = pcall(Color3.fromHex, x)
if ok then follow = isTheme and CONFIG_VALUES[key .. "~f"] == true; h, s, v = c:ToHSV(); refresh(false) end
end
resetters[key] = function() follow = isTheme; h, s, v = Color3.fromHex(resolve(defaultHex) or "#FFFFFF"):ToHSV(); refresh(false) end
refresh(true)
if isTheme then
onAccent(function()
if follow then local c = Color3.fromHex(resolve(defaultHex)); h, s, v = c:ToHSV(); refresh(false) end
end)
end
if cb then task.spawn(cb, hex) end
return {Set = function(_, x) registry[key](x) end, Get = function() return hex end}
end
function API.Color(text, defaultHex, cb) return API.ColorWheel(text, defaultHex, cb) end
API.Page = page
return API
end
local function build(api, list)
for _, e in ipairs(list) do
local k = e[1]
if k == "sec" then api.Section(e[2])
elseif k == "t" then api.Toggle(e[2], e[3] or false, e[4])
elseif k == "s" then api.Slider(e[2], e[3], e[4], e[5], e[7], e[6])
elseif k == "d" then api.Dropdown(e[2], e[3], e[4], e[5])
elseif k == "m" then api.MultiDropdown(e[2], e[3], e[4])
elseif k == "k" then api.Keybind(e[2], e[3])
elseif k == "b" then api.Button(e[2], e[3])
elseif k == "i" then api.IconButton(e[2], e[3])
elseif k == "dg" then api.Danger(e[2], e[3])
elseif k == "c" then api.Color(e[2], e[3])
elseif k == "cw" then api.ColorWheel(e[2], e[3], e[4])
elseif k == "x" then api.TextBox(e[2], e[3], e[4])
elseif k == "l" then api.Label(e[2]) end
end
end
local Cosmetic = (function()
local API = { Ready = false, Blacklist = {} }
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local lp      = Players.LocalPlayer
local BL = {}
function API.Blacklist.Add(name)    if type(name) == "string" then BL[name] = true end end
function API.Blacklist.Remove(name) BL[name] = nil end
function API.Blacklist.Clear()      BL = {} end
function API.Blacklist.Has(name)    return BL[name] == true end
function API.Blacklist.List()
local out = {}
for k in pairs(BL) do out[#out + 1] = k end
table.sort(out)
return out
end
local okInit, initErr = pcall(function()
local ctrl = lp:WaitForChild("PlayerScripts"):WaitForChild("Controllers", 3)
local mods = RS:WaitForChild("Modules", 3)
local enumLib = require(mods:WaitForChild("EnumLibrary", 3))
if enumLib then pcall(function() enumLib:WaitForEnumBuilder() end) end
API._enumLib = enumLib
API._cosLib  = require(mods:WaitForChild("CosmeticLibrary", 3))
API._datCtrl = require(ctrl:WaitForChild("PlayerDataController", 3))
local il = mods:FindFirstChild("ItemLibrary")
if il then API._items = (select(2, pcall(require, il))) end
end)
if not okInit or not API._cosLib or not API._datCtrl then
warn("[Cosmetic] could not load game modules: " .. tostring(initErr))
return API
end
local enumLib, cosLib, datCtrl = API._enumLib, API._cosLib, API._datCtrl
local Cosmetics = cosLib.Cosmetics
local itemsTbl = type(API._items) == "table" and API._items.Items or nil
local function norm(w)
if type(w) == "table" then w = w.Name end
if type(w) ~= "string" then return nil end
return (w:lower():gsub("%s+", ""))
end
local function isPlaceholder(n)
return type(n) == "string" and n:match("^MISSING_") ~= nil
end
local function allowed(name)
if type(name) ~= "string" or BL[name] then return false end
local c = Cosmetics[name]
if type(c) ~= "table" then return false end
if c.ItemName and BL[c.ItemName] then return false end
return not isPlaceholder(name)
end
API.IsAllowed = allowed
local allItemNames
local function itemMap()
if allItemNames then return allItemNames end
allItemNames = {}
if itemsTbl then
for n in pairs(itemsTbl) do
if type(n) == "string" then allItemNames[n] = true end
end
end
return allItemNames
end
local function mkSkin(name)
local base = Cosmetics[name]
if not base then return nil end
local d = {}
for k, v in pairs(base) do d[k] = v end
d.Name = name
d.Type = d.Type or "Skin"
d.Seed = d.Seed or math.random(1, 1000000)
if enumLib then
local ok, id = pcall(enumLib.ToEnum, enumLib, name)
if ok and id then
d.Enum = id
d.ObjectID = d.ObjectID or id
end
end
return d
end
local viewRoot
local function viewModelsRoot()
if viewRoot and viewRoot.Parent then return viewRoot end
local ps = lp:FindFirstChild("PlayerScripts")
local a = ps and ps:FindFirstChild("Assets")
viewRoot = a and a:FindFirstChild("ViewModels")
return viewRoot
end
local weaponCache
function API.Weapons()
if weaponCache then return weaponCache end
local seen, out = {}, {}
for name, c in pairs(Cosmetics) do
local w = type(c) == "table" and c.ItemName
if type(c) == "table" and c.Type == "Skin" and type(w) == "string" and w ~= "" and not isPlaceholder(w)
and not isPlaceholder(name) and not seen[w] then
seen[w] = true
out[#out + 1] = w
end
end
table.sort(out)
weaponCache = out
return out
end
function API.SkinsFor(weapon)
local out = {}
for name, c in pairs(Cosmetics) do
if type(c) == "table" and c.Type == "Skin" and c.ItemName == weapon and allowed(name) then
out[#out + 1] = name
end
end
table.sort(out)
return out
end
function API.PreviewSource(skinName)
local c = Cosmetics[skinName]
local root = viewModelsRoot()
if not (c and root) then return nil end
if type(c.Folder) == "string" and c.Folder ~= "" then
local f = root:FindFirstChild(c.Folder)
local m = f and f:FindFirstChild(skinName, true)
if m then return m end
end
return root:FindFirstChild(skinName, true)
end
function API.IconId(skinName)
local c = Cosmetics[skinName]
if type(c) ~= "table" then return nil end
for _, k in ipairs({ "Icon", "IconId", "Image", "ImageId", "Thumbnail", "PreviewImage" }) do
local v = c[k]
if type(v) == "number" then return "rbxassetid://" .. v end
if type(v) == "string" and v ~= "" then return v end
end
return nil
end
local function folderNames(folder)
if not folder then return nil end
local t = {}
for _, c in ipairs(folder:GetChildren()) do t[c.Name] = true end
return t
end
local namesCache = {}
function API.Names(kind)
if namesCache[kind] then return namesCache[kind] end
local avail
if kind == "Charm" then
local ps = lp:FindFirstChild("PlayerScripts")
local a = ps and ps:FindFirstChild("Assets")
avail = folderNames(a and a:FindFirstChild("Charms"))
elseif kind == "Finisher" then
local m = RS:FindFirstChild("Modules")
avail = folderNames(m and m:FindFirstChild("Finishers"))
end
local out = {}
for name, c in pairs(Cosmetics) do
if type(c) == "table" and c.Type == kind and not isPlaceholder(name) and (avail == nil or avail[name]) then
out[#out + 1] = name
end
end
table.sort(out)
namesCache[kind] = out
return out
end
function API.NamesAllowed(kind)
local out = {}
for _, n in ipairs(API.Names(kind)) do if allowed(n) then out[#out + 1] = n end end
return out
end
function API.CharmModel(name)
local ps = lp:FindFirstChild("PlayerScripts")
local a = ps and ps:FindFirstChild("Assets")
local f = a and a:FindFirstChild("Charms")
return f and f:FindFirstChild(name)
end
function API.WeaponModel(weapon)
local root = viewModelsRoot()
local w = root and root:FindFirstChild("Weapons")
return w and w:FindFirstChild(weapon)
end
local wrapCtrl
function API.WrapController()
if wrapCtrl then return wrapCtrl end
pcall(function()
wrapCtrl = require(lp.PlayerScripts.Controllers.WrapController)
end)
return wrapCtrl
end
local equipped = {}
local active = false   -- OFF by default; the Cosmetics tab toggle turns it on
local origData = {}   -- [normalized weapon] = clone of the untouched viewmodel data
local function entry(weapon, create)
local k = norm(weapon)
if not k then return nil end
local e = equipped[k]
if not e and create then e = { weapon = weapon }; equipped[k] = e end
return e
end
function API.Get(weapon, kind)
local e = entry(weapon)
if not e then return nil end
if kind == "Skin" then return e.skin and e.skin.name end
if kind == "Wrap" then return e.wrap end
if kind == "Charm" then return e.charm end
if kind == "Finisher" then return e.finisher end
end
API.Equipped = function(weapon) return API.Get(weapon, "Skin") end
function API.Inverted(weapon) local e = entry(weapon); return e and e.inverted == true end
local function encodeKey(key)
local toEnum = type(enumLib) == "table" and rawget(enumLib, "_to_enum") or nil
local v = type(toEnum) == "table" and rawget(toEnum, key) or nil
return v ~= nil and v or key
end
local function applySel(data, e, key)
if not (data and e) then return end
if e.skin then
data[key("Skin")] = e.skin.data
data[key("Name")] = e.skin.name
end
if e.wrap then data[key("Wrap")] = { Name = e.wrap, Inverted = e.inverted and true or nil } end
if e.charm then data[key("Charm")] = { Name = e.charm } end
end
local fighterCtrl
local function localFighter()
if not fighterCtrl then
pcall(function() fighterCtrl = require(lp.PlayerScripts.Controllers.FighterController) end)
end
if not fighterCtrl then return nil end
local f = fighterCtrl.LocalFighter
if not f and type(fighterCtrl.GetFighter) == "function" then
local ok, r = pcall(fighterCtrl.GetFighter, fighterCtrl, lp)
f = ok and r or nil
end
return f
end
local function runId2(cb)
local prev = type(getthreadidentity) == "function" and getthreadidentity() or nil
if type(setthreadidentity) == "function" then pcall(setthreadidentity, 2) end
local ok, a, b = pcall(cb)
if prev ~= nil and type(setthreadidentity) == "function" then pcall(setthreadidentity, prev) end
return ok, a, b
end
local function findItem(weapon)
local f = localFighter()
if type(f) ~= "table" then return nil, nil end
local held = rawget(f, "EquippedItem")
if type(held) == "table" and norm(rawget(held, "Name")) == norm(weapon) then return held, f end
for _, field in ipairs({ "Loadout", "Slots", "Items", "EquippedItems" }) do
local items = rawget(f, field)
if type(items) == "table" then
for _, it in pairs(items) do
if type(it) == "table" and norm(rawget(it, "Name")) == norm(weapon) then return it, f end
end
end
end
return nil, f
end
local reloading = {}
function API.Reload(weapon)
local k = norm(weapon)
if not k or reloading[k] then return false end
local item, fighter = findItem(weapon)
local vm = item and rawget(item, "ViewModel")
if type(vm) ~= "table" then return false end
local vmData = rawget(vm, "Data")
if type(vmData) ~= "table" and not origData[k] then return false end
reloading[k] = true
local done = false
pcall(function()
local base = origData[k] and table.clone(origData[k]) or table.clone(vmData)
origData[k] = origData[k] or table.clone(base)
local e = active and entry(weapon) or nil
applySel(base, e, encodeKey)
local cvmClass
pcall(function()
cvmClass = require(lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
end)
if type(cvmClass) ~= "table" or type(cvmClass.Destroy) ~= "function" then return end
local create = item._CreateViewModel
if type(create) ~= "function" then return end
local info = { [encodeKey("Data")] = base }
local armsData
if type(fighter) == "table" and type(fighter.GetArmsData) == "function" then
armsData = table.pack(fighter:GetArmsData())
end
runId2(function() cvmClass.Destroy(vm) end)
local ok, newVm = runId2(function() return create(item, info) end)
if not ok or type(newVm) ~= "table" then return end
rawset(item, "ViewModel", newVm)
runId2(function()
if armsData and type(newVm.SetArmsData) == "function" then
newVm:SetArmsData(unpack(armsData, 1, armsData.n))
end
if type(newVm.Equip) == "function" then newVm:Equip(true) end
end)
local spring = rawget(newVm, "_equip_spring")
if type(spring) == "table" then
rawset(spring, "_position0", 0)
rawset(spring, "_velocity0", 0)
end
done = true
end)
reloading[k] = nil
return done
end
local function retryReload(weapon)
task.spawn(function()
for _ = 1, 15 do
task.wait(2)
if not active then return end
local ok, res = pcall(API.Reload, weapon)
if ok and res then return end
end
end)
end
local pendingRefresh, refreshQueued = {}, false
local function refresh(weapon)
if API.OnChanged then pcall(API.OnChanged) end   -- every change (hub OR in-game screen) gets saved
if weapon then pendingRefresh[weapon] = true end
if refreshQueued then return end
refreshQueued = true
task.defer(function()
refreshQueued = false
local list = pendingRefresh
pendingRefresh = {}
pcall(function() datCtrl.CurrentData:Replicate("WeaponInventory") end)
for w in pairs(list) do
local ok, res = pcall(API.Reload, w)
if ok and res == false then retryReload(w) end
end
end)
end
function API.Snapshot()
local out = { Skin = {}, Wrap = {}, Charm = {}, Finisher = {} }
for _, e in pairs(equipped) do
local w = e.weapon
if type(w) == "table" then w = w.Name end
if type(w) == "string" then
if e.skin and e.skin.name then out.Skin[w] = e.skin.name end
if e.wrap then out.Wrap[w] = e.wrap end
if e.charm then out.Charm[w] = e.charm end
if e.finisher then out.Finisher[w] = e.finisher end
end
end
return out
end
function API.Set(weapon, kind, name, inverted)
local e = entry(weapon, true)
if not e then return false end
if name ~= nil and not allowed(name) then return false end
if inverted ~= nil then e.inverted = inverted and true or false end
if kind == "Skin" then
e.skin = name and { name = name, data = mkSkin(name) } or nil
elseif kind == "Wrap" then e.wrap = name
elseif kind == "Charm" then e.charm = name
elseif kind == "Finisher" then e.finisher = name
else return false end
refresh(weapon)
return true
end
function API.Equip(weapon, skinName) return API.Set(weapon, "Skin", skinName) end
function API.SetInverted(weapon, v)
local e = entry(weapon, true)
if not e then return end
e.inverted = v and true or false
refresh(weapon)
end
for _, key in ipairs({ "OwnsCosmetic", "OwnsCosmeticNormally", "OwnsCosmeticUniversally", "OwnsCosmeticForWeapon" }) do
local orig = cosLib[key]
if type(orig) == "function" then
cosLib[key] = function(self, inv, nm, ...)
if active and allowed(nm) then return true end
return orig(self, inv, nm, ...)
end
end
end
local origGet = datCtrl.Get
local invSrc, invProxy
local invMeta = {
__index = function(_, k)
if not allowed(k) then return nil end
local t = Cosmetics[k].Type
if t == "Wrap" or t == "Charm" or t == "Finisher" then return itemMap() end
return true
end,
}
datCtrl.Get = function(self, key, ...)
local val = origGet(self, key, ...)
if active and key == "CosmeticInventory" then
if invProxy and invSrc == val then return invProxy end
local prx = {}
if type(val) == "table" then for k, v in pairs(val) do prx[k] = v end end
invSrc, invProxy = val, setmetatable(prx, invMeta)
return invProxy
end
return val
end
local origGetWep = datCtrl.GetWeaponData
local wepCache = {}
datCtrl.GetWeaponData = function(self, wn, ...)
local d = origGetWep(self, wn, ...)
if not d then return nil end
local e = active and entry(wn)
if e and (e.skin or e.wrap or e.charm or e.finisher) then
local sig = table.concat({
e.skin and e.skin.name or "", e.wrap or "", tostring(e.inverted),
e.charm or "", e.finisher or "" }, "|")
local c = wepCache[wn]
if c and c.src == d and c.sig == sig then return c.out end
local m = {}
for k, v in pairs(d) do m[k] = v end
m.Name = wn
if e.skin then m.Skin = e.skin.data end
if e.wrap then m.Wrap = { Name = e.wrap, Inverted = e.inverted and true or nil } end
if e.charm then m.Charm = { Name = e.charm } end
if e.finisher then m.Finisher = { Name = e.finisher } end
wepCache[wn] = { src = d, sig = sig, out = m }
return m
end
return d
end
local buildingWep
local cliItem
pcall(function()
cliItem = require(lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
end)
if cliItem and cliItem._CreateViewModel then
local origCVM = cliItem._CreateViewModel
cliItem._CreateViewModel = function(self, vmRef, ...)
local owner = self.ClientFighter and self.ClientFighter.Player
buildingWep = (owner == lp) and self.Name or nil
if owner == lp and type(vmRef) == "table" then
local k = norm(self.Name)
local dk = self:ToEnum("Data")
local data = vmRef[dk] or vmRef.Data
if type(data) == "table" and k and not origData[k] then origData[k] = table.clone(data) end
local e = active and entry(self.Name)
if e and data then
if vmRef[dk] then
applySel(vmRef[dk], e, function(n) return self:ToEnum(n) end)
else
applySel(vmRef.Data, e, function(n) return n end)
end
end
end
local r = origCVM(self, vmRef, ...)
buildingWep = nil
return r
end
end
pcall(function()
local vmMod = lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if not vmMod then return end
local CVM = require(vmMod)
local RC = require(RS.Modules.ReplicatedClass)
local origNew = CVM.new
CVM.new = function(repData, cliItm, ...)
local owner = cliItm.ClientFighter and cliItm.ClientFighter.Player
local wn = buildingWep or cliItm.Name
local e = active and owner == lp and entry(wn)
if e then
local dk = RC:ToEnum("Data")
repData[dk] = repData[dk] or {}
applySel(repData[dk], e, function(n) return RC:ToEnum(n) end)
end
return origNew(repData, cliItm, ...)
end
end)
pcall(function()
local ce = require(lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
if type(ce) ~= "table" or type(ce._PlayFinisher) ~= "function" then return end
local origPF = ce._PlayFinisher
ce._PlayFinisher = function(self, finisherName, ...)
if active then
local f = localFighter()
local held = f and rawget(f, "EquippedItem")
local e = type(held) == "table" and entry(rawget(held, "Name"))
if e and e.finisher then return origPF(self, e.finisher, ...) end
end
return origPF(self, finisherName, ...)
end
end)
-- ===== Inventory bridge (ported from Kiciahook) =====
-- 1) stops the in-game inventory from sending equip requests to the server (server rejects fake items)
-- 2) watches the inventory's selection state and applies picks locally through API.Set
local invBridge = { token = nil, blocked = nil }
local function getEquipModule()
local ok, eq = pcall(function()
return require(lp.PlayerScripts.Modules.UserInterface.Equipment)
end)
if ok and type(eq) == "table" then return eq end
return nil
end
local function blockServerEquip(eq)
if invBridge.blocked then return end
local d = debug
if not (d and d.getprotos and d.getproto and d.getconstants and d.setconstant) then return end
pcall(function()
local t = eq
for _, key in ipairs({ "Interface", "Customize", "Options" }) do t = rawget(t, key) end
local init = rawget(rawget(getmetatable(t), "__index"), "_Init")
local list = {}
for k in pairs(d.getprotos(init)) do
local pr = d.getproto(init, k, true)
local f = pr and pr[1]
if f then
for ci, c in pairs(d.getconstants(f)) do
if c == "FireServer" then
d.setconstant(f, ci, "GetChildren")
list[#list + 1] = { f = f, i = ci }
break
end
end
end
end
if #list > 0 then invBridge.blocked = list end
end)
end
local function unblockServerEquip()
local list = invBridge.blocked
invBridge.blocked = nil
if list then
for _, r in ipairs(list) do pcall(debug.setconstant, r.f, r.i, "FireServer") end
end
end
local PICKABLE = { Skin = true, Wrap = true, Charm = true, Finisher = true }
local function startInventoryBridge(quiet)
if invBridge.token then return end
local eq = getEquipModule()
local state = eq and rawget(eq, "EquipmentState")
if type(state) ~= "table" then
if not quiet then warn("[Cosmetic] inventory UI not found - it will hook in automatically once the Equipment screen is available") end
return
end
blockServerEquip(eq)
local my = {}
invBridge.token = my
task.spawn(function()
local lastW, lastT, lastC, lastI
while invBridge.token == my and active do
local w = rawget(state, "SelectedWeapon")
local t = rawget(state, "CustomizingType")
local c = rawget(state, "SelectedCosmetic")
local inv
pcall(function() inv = state.CosmeticInverted == true end)
if w ~= nil and w == lastW and t == lastT and PICKABLE[t] then
local wname = type(w) == "table" and w.Name or w
if c ~= lastC then
local name = c
if name == "NONE_COSMETIC" then name = nil end
if name ~= "RANDOM_COSMETIC" and API.Get(wname, t) ~= name then
local invArg = (t == "Wrap") and inv or nil
if API.Set(wname, t, name, invArg) and API.InventoryChanged then
pcall(API.InventoryChanged, wname, t, name)
end
end
elseif t == "Wrap" and inv ~= lastI and lastI ~= nil and API.Get(wname, "Wrap") then
API.SetInverted(wname, inv)
end
end
lastW, lastT, lastC, lastI = w, t, c, inv
task.wait(0.1)
end
end)
end
local function retryBridge()
if invBridge.retrying then return end
invBridge.retrying = true
task.spawn(function()
while active do
if not invBridge.token then pcall(startInventoryBridge, true) end
task.wait(1.5)
end
invBridge.retrying = nil
end)
end
local function stopInventoryBridge()
invBridge.token = nil
unblockServerEquip()
end
function API.SetActive(on)
active = on and true or false
local weapons = {}
for _, e in pairs(equipped) do weapons[#weapons + 1] = e.weapon end
wepCache = {}
if active then startInventoryBridge(); retryBridge() else stopInventoryBridge() end
pcall(function() datCtrl.CurrentData:Replicate("CosmeticInventory") end)
pcall(function() datCtrl.CurrentData:Replicate("WeaponInventory") end)
for _, w in ipairs(weapons) do
local ok, res = pcall(API.Reload, w)
if active and ok and res == false then retryReload(w) end
end
end
function API.IsActive() return active end
function API.Unload()
active = false
stopInventoryBridge()
local weapons = {}
for _, e in pairs(equipped) do weapons[#weapons + 1] = e.weapon end
equipped = {}
pcall(function() datCtrl.CurrentData:Replicate("WeaponInventory") end)
for _, w in ipairs(weapons) do pcall(API.Reload, w) end
end
API.Ready = true
return API
end)()
FX.pre = function(k, d)   -- saved value if there is one, else the default (so nothing flashes before the config loads)
local v = SAVED[k]; if v == nil then v = CONFIG_VALUES[k] end
if v == nil then return d end
return v
end
local HUD = {
 on = FX.pre("Settings.HUD.Overlay.Show HUD (above all UIs)", true),
 wm = FX.pre("Settings.HUD.Watermark.Show Watermark", true),
 wmPos = FX.pre("Settings.HUD.Watermark.Watermark Position", "Top Left"),
 name = FX.pre("Settings.HUD.Watermark.Show Name", true),
 fps = FX.pre("Settings.HUD.Watermark.Show FPS", true),
 ping = FX.pre("Settings.HUD.Watermark.Show Ping", true),
 arr = FX.pre("Settings.HUD.Array List.Show Array List", true),
 side = FX.pre("Settings.HUD.Array List.Array Side", "Right"),
 rainbow = FX.pre("Settings.HUD.Array List.Rainbow Colours", false),
}
do
local hudGui = make("ScreenGui", {Name = "1MagHUD", ResetOnSpawn = false, IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2147483647}, PG)
hudGui.Enabled = false; FX.holdGui(hudGui)
gui.Destroying:Connect(function() hudGui:Destroy() end)
FX.shimmer(hudGui)
local BG = Color3.fromRGB(12, 12, 15)
local wm = make("Frame", {BackgroundColor3 = BG, BackgroundTransparency = 0.12, BorderSizePixel = 0,
AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), ZIndex = 5}, hudGui)
corner(wm, 6)
local wmStroke = stroke(wm, T.Accent, 1, 0.55)
local wmLine = make("Frame", {BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(1, -12, 0, 2),
Position = UDim2.fromOffset(6, 0), ZIndex = 7}, wm)
make("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.AccentHi), ColorSequenceKeypoint.new(1, T.Accent)})}, wmLine)
padding(wm, 0, 12, 0, 12)
local wmText = make("TextLabel", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
Text = "", RichText = true, FontFace = F_HEAVY, TextSize = 19, TextColor3 = T.Text, ZIndex = 6}, wm)
local function hex(c) return string.format("#%02X%02X%02X", c.R * 255, c.G * 255, c.B * 255) end
local function wmRefresh()
local parts = {string.format('<font color="%s">1Mag</font>.ez', hex(T.AccentHi))}
if HUD.name then parts[#parts + 1] = player.DisplayName end
if HUD.fps then parts[#parts + 1] = fpsValue .. " fps" end
if HUD.ping then parts[#parts + 1] = getPing() .. " ms" end
wmText.Text = table.concat(parts, '  <font color="#646470">|</font>  ')
end
local function wmPlace()
wm.Visible = HUD.on and HUD.wm
local p = HUD.wmPos
if p == "Top Left" then wm.AnchorPoint = Vector2.new(0, 0); wm.Position = UDim2.fromOffset(12, 12)
elseif p == "Top Right" then wm.AnchorPoint = Vector2.new(1, 0); wm.Position = UDim2.new(1, -12, 0, 12)
elseif p == "Bottom Left" then wm.AnchorPoint = Vector2.new(0, 1); wm.Position = UDim2.new(0, 12, 1, -12)
else wm.AnchorPoint = Vector2.new(1, 1); wm.Position = UDim2.new(1, -12, 1, -12) end
end
local list = make("Frame", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), ZIndex = 5}, hudGui)
local layout = make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1),
HorizontalAlignment = Enum.HorizontalAlignment.Right}, list)
local entries = {}   -- [key] = {row, label, bar}
local function arrPlace()
list.Visible = HUD.on and HUD.arr
local right = HUD.side == "Right"
layout.HorizontalAlignment = right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
list.AnchorPoint = Vector2.new(right and 1 or 0, 0)
local yy = 12
if (not right and HUD.wmPos == "Top Left") or (right and HUD.wmPos == "Top Right") then yy = 50 end
list.Position = right and UDim2.new(1, -12, 0, yy) or UDim2.fromOffset(12, yy)
for _, e in pairs(entries) do
e.bar.AnchorPoint = Vector2.new(right and 1 or 0, 0.5)
e.bar.Position = UDim2.new(right and 1 or 0, right and 7 or -7, 0.5, 0)
if e.grad then e.grad.Rotation = right and 180 or 0 end
e.label.TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
end
end
local function addEntry(key, text)
local right = HUD.side == "Right"
local dir = right and 1 or -1
local row = make("Frame", {BackgroundColor3 = BG, BackgroundTransparency = 1, BorderSizePixel = 0,
AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 0), LayoutOrder = -#text, ClipsDescendants = true, ZIndex = 5}, list)
corner(row, 3)
padding(row, 0, 7, 0, 7)
local wash = make("Frame", {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.6, BorderSizePixel = 0,
Size = UDim2.new(1, 14, 1, 0), Position = UDim2.fromOffset(-7 + dir * 60, 0), ZIndex = 5}, row)
corner(wash, 3)
local grad = make("UIGradient", {Rotation = right and 180 or 0, Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.6, 0.85), NumberSequenceKeypoint.new(1, 1)})}, wash)
local label = make("TextLabel", {BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
Position = UDim2.fromOffset(dir * 60, 0),
Text = text, FontFace = F_HEAVY, TextSize = 13, TextColor3 = T.Text, TextTransparency = 1,
TextXAlignment = right and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left, ZIndex = 7}, row)
local ls = stroke(label, Color3.new(0, 0, 0), 1, 0.55)
local bar = make("Frame", {BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 2, 1, -4),
AnchorPoint = Vector2.new(right and 1 or 0, 0.5), Position = UDim2.new(right and 1 or 0, right and 7 or -7, 0.5, 0),
ZIndex = 8, BackgroundTransparency = 1}, row)
corner(bar, 1)
tween(row, 0.32, {Size = UDim2.fromOffset(0, 16), BackgroundTransparency = 0.45}, Enum.EasingStyle.Quint)
tween(label, 0.45, {TextTransparency = 0, Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back)
tween(wash, 0.45, {Position = UDim2.fromOffset(-7, 0)}, Enum.EasingStyle.Back)
tween(bar, 0.3, {BackgroundTransparency = 0})
task.delay(0.55, function() if row.Parent then row.ClipsDescendants = false end end)
entries[key] = {row = row, label = label, bar = bar, wash = wash, grad = grad}
end
arrayRefresh = function()
for key, text in pairs(ENABLED) do
if not entries[key] then addEntry(key, text) end
end
for key, e in pairs(entries) do
if not ENABLED[key] then
entries[key] = nil
local dir = HUD.side == "Right" and 1 or -1
e.row.ClipsDescendants = true
tween(e.label, 0.28, {TextTransparency = 1, Position = UDim2.fromOffset(dir * 60, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
if e.wash then tween(e.wash, 0.28, {BackgroundTransparency = 1, Position = UDim2.fromOffset(-7 + dir * 60, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In) end
tween(e.bar, 0.2, {BackgroundTransparency = 1})
tween(e.row, 0.32, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
task.delay(0.4, function() e.row:Destroy() end)
end
end
end
local t0 = tick()
local hAcc = 0
local hc = RunService.RenderStepped:Connect(function(dt)
hAcc += dt; if hAcc < 1 / 20 then return end; hAcc = 0
local now = tick() - t0
local i = 0
for _, e in pairs(entries) do
i += 1
local col = HUD.rainbow and Color3.fromHSV((now * 0.25 + i * 0.07) % 1, 0.75, 1) or T.AccentHi
e.bar.BackgroundColor3 = HUD.rainbow and col or T.Accent
if e.wash then e.wash.BackgroundColor3 = HUD.rainbow and col or T.Accent end
end
if HUD.rainbow then wmLine.BackgroundColor3 = Color3.fromHSV(now * 0.25 % 1, 0.75, 1) else wmLine.BackgroundColor3 = T.Accent end
end)
task.spawn(function()
while hudGui.Parent do wmRefresh(); task.wait(0.5) end
end)
gui.Destroying:Connect(function() hc:Disconnect() end)
onAccent(function() wmStroke.Color = T.Accent end)
HUD.apply = function() wmPlace(); arrPlace(); wmRefresh(); arrayRefresh() end
HUD.apply()
end
addGroup("Start")
local mHome   = addMain("Home", "Welcome to 1Mag.ez")
addGroup("Features")
local mCombat = addMain("Combat", "Combat features.")
local mVis    = addMain("Visual", "Visual features.")
local mChar   = addMain("Character", "Character features.")
local mFF     = addMain("FFlags", "Fast flag features.")
local mWorld  = addMain("World", "Lighting, skyboxes and effects.")
addGroup("Tools")
local mTex    = addMain("Injector", "Replace textures, fonts, kill sounds and more with your own.")
local mCosm   = addMain("Cosmetics", "Unlock and equip cosmetics.")
local mStrap  = addMain("1magstrap", "Appearance, mods and engine settings.")
addGroup("System")
local mCfg    = addMain("Configs", "Save, load, and delete config profiles.")
local mSet    = addMain("Settings", "Interface and theme.")
do
local ov = addSub(mHome, "Overview", "")
local f = make("Frame", {BackgroundColor3 = T.Element, Size = UDim2.new(1, 0, 0, 104), BorderSizePixel = 0,
LayoutOrder = 0, ZIndex = 3}, ov.Page)
corner(f, 7)
local fs = stroke(f, T.Accent, 1, 0.6)
onAccent(function() fs.Color = T.Accent end)
local grad = make("UIGradient", {Rotation = 20, Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 1)})}, f)
f.BackgroundColor3 = T.Accent
onAccent(function() f.BackgroundColor3 = T.Accent end)
make("Frame", {BackgroundColor3 = T.Element, BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 3}, f)
local fcorner = f:FindFirstChildOfClass("Frame"); if fcorner then corner(fcorner, 7) end
if LOGO_ID then
logoImg({BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(80, 80),
ScaleType = Enum.ScaleType.Fit, ZIndex = 5}, f)
else
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(80, 80),
Text = "1MAG", FontFace = F_HEAVY, TextSize = 30, TextColor3 = T.AccentHi, ZIndex = 5}, f)
end
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(108, 12), Size = UDim2.new(1, -118, 0, 34),
Text = "1Mag.ez", FontFace = F_HEAVY, TextSize = 34, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, f)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(108, 48), Size = UDim2.new(1, -118, 0, 20),
Text = "", FontFace = F_BOLD, TextSize = 20, TextColor3 = T.Sub,
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5}, f)
make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(108, 70), Size = UDim2.new(1, -118, 0, 20),
Text = "", FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.AccentHi,
TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, f)
ov.Section("Session")
ov.Label("Game: " .. gameName)
ov.Label("Place ID: " .. tostring(game.PlaceId))
local hPlayers = ov.Label("Players: -")
local hPerf = ov.Label("Ping / FPS: -")
task.spawn(function()
while gui.Parent do
hPlayers:Set("Players: " .. #Players:GetPlayers() .. " online")
hPerf:Set(getPing() .. " ms   -   " .. fpsValue .. " FPS")
task.wait(1)
end
end)
local tips = addSub(mHome, "Tips", "")
tips.Section("Quick Start")
tips.Label("Pick a tab on the left, then a sub tab along the top.")
tips.Label("Right-click a control to reset it, or a section header to fold them all.")
tips.Label("Press / to search any feature, Ctrl+S to save, click a slider value to type it.")
tips.Label("Drag the top bar to move; drag the logo button too.")
tips.Label("Save profiles in the Configs tab.")
end
FX.MB = {show = FX.pre("Settings.Mobile.On-Screen Buttons.Show Buttons", true), locked = FX.pre("Settings.Mobile.On-Screen Buttons.Lock Button Positions", false), size = FX.pre("Settings.Mobile.On-Screen Buttons.Button Size", 64)}
do
local MB = FX.MB
local all = {}
local layer = make("Frame", {Name = "MobileButtons", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 400, Active = false}, gui)
local function loc(i)
if i.UserInputType == Enum.UserInputType.Touch then return Vector2.new(i.Position.X, i.Position.Y) end
return UIS:GetMouseLocation()
end
function MB.attach(frame, o)
o.dx, o.dy = o.px, o.py
local saved = CONFIG_VALUES["Mobile.pos." .. o.id]
if type(saved) == "string" then
local a, b = saved:match("^([%d%.%-]+),([%d%.%-]+)$")
if a then o.px, o.py = tonumber(a), tonumber(b) end
end
o.frame = frame
frame.Position = UDim2.fromScale(o.px, o.py)
frame.InputBegan:Connect(function(i)
if i.UserInputType ~= Enum.UserInputType.Touch and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
local start, sx, sy, vp = loc(i), o.px, o.py, gui.AbsoluteSize
local dragging = false
o.wasDragged = false
if o.onDown then o.onDown() end
task.spawn(function()
while i.UserInputState ~= Enum.UserInputState.End and frame.Parent do
local d = loc(i) - start
local lockedNow = (o.id == "hub") and (FX.HB.locked or (FX.HB.trans or 0) >= 0.95) or MB.locked
if not dragging and not lockedNow and d.Magnitude > 10 then
dragging = true; o.wasDragged = true
if o.onCancel then o.onCancel() end
end
if dragging then
o.px = math.clamp(sx + d.X / math.max(vp.X, 1), 0.03, 0.97)
o.py = math.clamp(sy + d.Y / math.max(vp.Y, 1), 0.04, 0.96)
frame.Position = UDim2.fromScale(o.px, o.py)
end
RunService.RenderStepped:Wait()
end
if dragging then
CONFIG_VALUES["Mobile.pos." .. o.id] = string.format("%.4f,%.4f", o.px, o.py)
pcall(markDirty)
elseif o.onUp then o.onUp() end
end)
end)
all[#all + 1] = o
end
function MB.new(id, label, px, py)
local o = {id = id, px = px, py = py, down = false, on = false, kind = "hold", want = function() return false end}
local b = make("TextButton", {Name = "MB_" .. id, AutoButtonColor = false, Text = label, FontFace = F_HEAVY, TextSize = 16,
TextColor3 = T.Text, BackgroundColor3 = T.Panel, BackgroundTransparency = 0.25, AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.fromOffset(MB.size, MB.size), Visible = false, ZIndex = 1}, layer)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, b)
local st = stroke(b, T.Accent, 2, 0.1)
onAccent(function() st.Color = T.Accent end)
o.btn = b
function o.refresh()
local act = o.down or (o.kind == "toggle" and o.on)
b.BackgroundColor3 = act and T.Accent or T.Panel
b.BackgroundTransparency = act and 0.1 or 0.25
end
o.onDown = function() if o.kind == "hold" then o.down = true; o.refresh() end end
o.onCancel = function() o.down = false; o.refresh() end
o.onUp = function()
if o.kind == "toggle" then o.on = not o.on
elseif o.kind == "tap" and o.onTap then pcall(o.onTap) end
o.down = false; o.refresh()
end
MB.attach(b, o)
return o
end
function MB.reset()
for _, o in ipairs(all) do
CONFIG_VALUES["Mobile.pos." .. o.id] = nil
o.px, o.py = o.dx, o.dy
if o.frame then o.frame.Position = UDim2.fromScale(o.px, o.py) end
end
pcall(markDirty)
end
local acc = 0
track(RunService.Heartbeat:Connect(function(dt)
acc += dt; if acc < 0.1 then return end; acc = 0
for _, o in ipairs(all) do
if o.btn then
local v = (MB.show and o.want()) and true or false
if o.btn.Visible ~= v then o.btn.Visible = v; if not v then o.down = false; o.refresh() end end
if o.btn.Size.X.Offset ~= MB.size then o.btn.Size = UDim2.fromOffset(MB.size, MB.size) end
end
end
end))
end
FX.Keys = {}
function FX.Keys.hit(i, name)
if type(name) ~= "string" or name == "None" then return false end
return (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode.Name == name) or i.UserInputType.Name == name
end
function FX.Keys.down(name)
if type(name) ~= "string" or name == "None" then return false end
local ok, kc = pcall(function() return Enum.KeyCode[name] end)
if ok and kc then return UIS:IsKeyDown(kc) or UIS:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, kc) end
local ok2, ut = pcall(function() return Enum.UserInputType[name] end)
return ok2 and ut and UIS:IsMouseButtonPressed(ut) or false
end
FX.Binds = {show = true}
do
local ITEMS = {
{"Aim", "Aim Key", "aim"}, {"Slide", "Slide Key", "slide"}, {"Trigger", "Triggerbot Key"}, {"Flick", "Flickbot Key"},
{"Long Jump", "Long Jump Key"}, {"Rage", "Rage Key"}, {"Hub", "Toggle Hub"},
}
local function bindOf(it)
local suf = "." .. it[2]
for k, v in pairs(CONFIG_VALUES) do
if type(k) == "string" and type(v) == "string" and k:sub(-#suf) == suf then
return (v ~= "" and v ~= "None") and v or nil
end
end
if it[1] == "Hub" then return "RightShift" end
end
local function pretty(n) return (n:gsub("^Button", ""):gsub("Shift", "Shift")) end
function FX.Binds.build(toggle)
local box = make("Frame", {Name = "KeybindsHUD", BackgroundColor3 = T.Panel, BackgroundTransparency = 0.12, Size = UDim2.fromOffset(0, 0),
AutomaticSize = Enum.AutomaticSize.XY, BorderSizePixel = 0, Visible = false, ZIndex = 590}, gui)
corner(box, 9)
local bst = stroke(box, T.Accent, 1.2, 0.2)
onAccent(function() bst.Color = T.Accent end)
padding(box, 5, 8, 5, 8)
make("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder}, box)
local rows = {}
for i, it in ipairs(ITEMS) do
local l = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, Text = "",
RichText = true, FontFace = F_BOLD, TextSize = 15, TextColor3 = T.Sub, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, Visible = false, ZIndex = 591}, box)
rows[i] = l
end
local acc, last = 0, ""
track(RunService.Heartbeat:Connect(function(dt)
acc += dt
local s2 = FX.HB.size
local right = toggle.Position.X.Scale < 0.5
local px, po, py, pof = toggle.Position.X.Scale, toggle.Position.X.Offset, toggle.Position.Y.Scale, toggle.Position.Y.Offset
box.AnchorPoint = Vector2.new(right and 0 or 1, 0.5)
box.Position = UDim2.new(px, po + (right and s2 + 8 or -8), py, pof)
if acc < 0.4 then return end
acc = 0
local any, sig = false, ""
for i, it in ipairs(ITEMS) do
local b = bindOf(it)
rows[i].Visible = b ~= nil
if b then
any = true
local hex = "#" .. T.AccentHi:ToHex()
local t = string.format('%s  <font color="%s">%s</font>', it[1], hex, pretty(b))
if rows[i].Text ~= t then rows[i].Text = t end
sig ..= t
end
end
box.Visible = FX.Binds.show and any and (FX.HB.trans or 0) < 0.95
end))
track(UIS.InputBegan:Connect(function(i)
if UIS:GetFocusedTextBox() then return end
for _, it in ipairs(ITEMS) do
local mb = it[3] and FX.MB[it[3]]
if mb and FX.Keys.hit(i, bindOf(it)) then
if mb.kind == "toggle" then mb.on = not mb.on else mb.down = true end
mb.refresh()
end
end
end))
track(UIS.InputEnded:Connect(function(i)
for _, it in ipairs(ITEMS) do
local mb = it[3] and FX.MB[it[3]]
if mb and mb.kind ~= "toggle" and FX.Keys.hit(i, bindOf(it)) then mb.down = false; mb.refresh() end
end
end))
end
end
do
local A = {on = false, rmb = true, smooth = 0, mode = "Linear", method = "Camera", wall = true, team = false,
fov = 120, show = true, fill = false, anim = "None",
silent = false, sMode = "Silent", part = "Head", ignoreFov = false, sFov = 120,
sShow = true, sFill = false, sGrad = false, wallbang = false, hitChance = 100, wHead = 70, wTorso = 30,
legit = false, act = "Always On", aReact = 0, aSwitch = 0, lReact = 0, lSwitch = 0}
local M = {}
local hasDraw = type(Drawing) == "table" and type(Drawing.new) == "function"
local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
local S = {vy = 0, vp = 0, target = nil, since = 0, flash = 0, vel = setmetatable({}, {__mode = "k"}), noise = 0,
rand = setmetatable({}, {__mode = "k"}), depth = 0, hook = nil, hookAt = 0, lostAt = 0, pend = nil, pendAt = 0, pendDelay = 0, wrapSet = setmetatable({}, {__mode = "k"}), depthAt = 0}
local aa = addSub(mCombat, "Aim Assist", "Camera aim assist. Moves the camera and viewmodel together.")
aa.Section("Aim Assist")
aa.Toggle("Aim Assist", false, function(v) A.on = v end)
aa.Dropdown("Activation", {"Always On", "Button (Hold)", "Button (Toggle)"}, "Always On", function(v)
A.act = v
local b = FX.MB.aim
if b then b.kind = (v == "Button (Toggle)") and "toggle" or "hold"; b.on = false; b.down = false; b.refresh() end
end)
aa.Keybind("Aim Key", "None")
aa.Hint("Always On aims whenever a target is in the FOV. Button modes add a movable on-screen AIM button.")
aa.Dropdown("Aim Mode", {"Linear", "Lock", "Spring", "AI"}, "Linear", function(v) A.mode = v; S.vy, S.vp = 0, 0 end)
aa.Slider("Smoothing", 0, 1, 0, function(v) A.smooth = v end, 0.01)
aa.Hint("0 = snap onto the target, 1 = soft follow.")
aa.Section("Targeting")
aa.Slider("FOV Radius", 20, 600, 120, function(v) A.fov = v end, 5)
aa.Toggle("Visible Check (Walls)", true, function(v) A.wall = v end, true)
aa.Toggle("Target Teammates", false, function(v) A.team = v end, true)
aa.Section("Timing")
aa.Slider("Aim Reaction (ms)", 0, 500, 0, function(v) A.aReact = v end, 5)
aa.Slider("Switch Target (ms)", 0, 1000, 0, function(v) A.aSwitch = v end, 10)
aa.Section("FOV Circle")
aa.Toggle("Show FOV Circle", true, function(v) A.show = v end, true)
aa.Toggle("FOV Fill", false, function(v) A.fill = v end, true)
aa.Dropdown("Fill Animation", {"None", "Pulse", "Rainbow", "Lock Flash"}, "None", function(v) A.anim = v end)
aa.ColorWheel("FOV Color", "#F03E3E")
local sa = addSub(mCombat, "Silent Aim", "Redirects your shots without moving your view.")
local W = {}   -- Weighted sliders, only visible while Hit Part = Weighted
sa.Section("Silent Aim")
sa.Toggle("Silent Aim", false, function(v) A.silent = v; if M.syncHook then M.syncHook() end end)
sa.Dropdown("Mode", {"Silent", "Camera"}, "Silent", function(v) A.sMode = v; if M.syncHook then M.syncHook() end end)
sa.Toggle("Ignore FOV", false, function(v) A.ignoreFov = v end, true)
sa.Hint("Silent = shots only. Camera = Legit-style camera aim.")
sa.Section("Hit Settings")
sa.Slider("Hit Chance (%)", 0, 100, 100, function(v) A.hitChance = v end, 1)
sa.Dropdown("Hit Part", {"Head", "Torso", "Random", "Weighted"}, "Head", function(v)
A.part = v; if M.syncWeighted then M.syncWeighted() end
end)
W.head = sa.Slider("Head Hit Chance", 0, 100, 70, function(v) A.wHead = v end, 1)
W.torso = sa.Slider("Torso Hit Chance", 0, 100, 30, function(v) A.wTorso = v end, 1)
sa.Toggle("Wallbang", false, function(v) A.wallbang = v end, true)
sa.Hint("Wallbang: targets behind walls count as visible.")
sa.Section("FOV Circle")
sa.Toggle("FOV Circle", true, function(v) A.sShow = v end, true)
sa.Slider("Circle Radius", 20, 600, 120, function(v) A.sFov = v end, 5)
sa.ColorWheel("Circle Color", "#F03E3E")
sa.Toggle("FOV Fill", false, function(v) A.sFill = v end, true)
sa.Toggle("Gradient Fill", false, function(v) A.sGrad = v end, true)
sa.ColorWheel("Gradient Color", "#3E7BF0")
sa.Section("Legit")
sa.Toggle("Legit Aim Assist", false, function(v) A.legit = v end)
sa.Slider("Aim Reaction (ms)", 0, 500, 0, function(v) A.lReact = v end, 5)
sa.Slider("Switch Target (ms)", 0, 1000, 0, function(v) A.lSwitch = v end, 10)
sa.Hint("Uses this tab's FOV circle, radius and Hit Part.")
local TB = {on = false, act = "Always On", react = 0, release = 0.05, head = true, torso = true, arms = false, legs = false,
team = false, shield = true, gunOnly = true, tOn = false, rt = nil, rl = 0,
fOn = false, fAct = "Keybind (Hold)", fShoot = true, fDelay = 0, fCool = 250, fDur = 110, fCurve = 12, fHuman = 30,
fPart = "Head", fFov = 250, fWall = true, fTog = false}
local tb = addSub(mCombat, "Triggerbot", "Auto-fires when your crosshair is on an enemy, plus camera Flickbot (ported from Kiciahook).")
tb.Section("Triggerbot")
tb.Toggle("Enable Triggerbot", false, function(v) TB.on = v; TB.rt = nil; TB.rl = 0 end)
tb.Dropdown("Triggerbot Activation", {"Always On", "Keybind (Hold)", "Keybind (Toggle)", "Button (Hold)", "Button (Toggle)"}, "Always On", function(v)
TB.act = v; TB.tOn = false; TB.rt = nil; TB.rl = 0
local b = FX.MB.trig
if b then b.kind = (v == "Button (Toggle)") and "toggle" or "hold"; b.on = false; b.down = false; b.refresh() end
end)
tb.Keybind("Triggerbot Key", "None")
tb.Hint("Keybind modes use the key above. Button modes add a movable on-screen TRIG button.")
tb.Section("Timing")
tb.Slider("Reaction Delay (s)", 0, 2, 0, function(v) TB.react = v end, 0.01)
tb.Slider("Release Delay (s)", 0, 2, 0.05, function(v) TB.release = v end, 0.01)
tb.Section("Hitboxes")
tb.Toggle("Head", true, function(v) TB.head = v end)
tb.Toggle("Torso", true, function(v) TB.torso = v end)
tb.Toggle("Arms", false, function(v) TB.arms = v end)
tb.Toggle("Legs", false, function(v) TB.legs = v end)
tb.Section("Target Filters")
tb.Toggle("Target Teammates", false, function(v) TB.team = v end)
tb.Toggle("Skip Shielded / Invincible", true, function(v) TB.shield = v end)
tb.Toggle("Require Gun Equipped", true, function(v) TB.gunOnly = v end)
tb.Section("Flickbot")
tb.Toggle("Enable Flickbot", false, function(v) TB.fOn = v end)
tb.Dropdown("Flickbot Activation", {"Keybind (Hold)", "Keybind (Toggle)", "Button (Hold)", "Button (Toggle)"}, "Keybind (Hold)", function(v)
TB.fAct = v; TB.fTog = false
local b = FX.MB.flick
if b then b.kind = (v == "Button (Toggle)") and "toggle" or "hold"; b.on = false; b.down = false; b.refresh() end
end)
tb.Keybind("Flickbot Key", "Q")
tb.Toggle("Shoot After Flick", true, function(v) TB.fShoot = v end)
tb.Slider("Shot Delay (ms)", 0, 250, 0, function(v) TB.fDelay = v end, 1)
tb.Slider("Cooldown (ms)", 0, 2000, 250, function(v) TB.fCool = v end, 10)
tb.Slider("Flick Duration (ms)", 30, 400, 110, function(v) TB.fDur = v end, 5)
tb.Slider("Curvature", 0, 50, 12, function(v) TB.fCurve = v end, 1)
tb.Slider("Humanness", 0, 100, 30, function(v) TB.fHuman = v end, 1)
tb.Section("Flick Targeting")
tb.Dropdown("Flick Hit Part", {"Head", "Torso", "Random"}, "Head", function(v) TB.fPart = v end)
tb.Slider("Flick FOV Radius", 20, 800, 250, function(v) TB.fFov = v end, 5)
tb.Toggle("Visible Check (Walls)", true, function(v) TB.fWall = v end)
tb.Hint("Flickbot snaps your camera onto the best target in the FOV along a curved, human-like path, then optionally fires.")
function M.syncWeighted()
local on = A.part == "Weighted"
for _, h in pairs(W) do
if h and h.Frame then h.Frame:SetAttribute("Hid", not on); h.Frame.Visible = on end
end
end
M.syncWeighted()
local aimBtn = FX.MB.new("aim", "AIM", 0.88, 0.5)
FX.MB.aim = aimBtn
aimBtn.kind = (A.act == "Button (Toggle)") and "toggle" or "hold"
aimBtn.want = function()
return (A.on or A.legit or (A.silent and A.sMode == "Camera")) and (A.act == "Button (Hold)" or A.act == "Button (Toggle)")
end
local gGui = Instance.new("ScreenGui")
gGui.Name = "1MagFov"; gGui.ResetOnSpawn = false; gGui.IgnoreGuiInset = true; gGui.DisplayOrder = 1
FX.holdGui(gGui)
pcall(function() gGui.Parent = gui.Parent end)
gui.Destroying:Connect(function() pcall(function() gGui:Destroy() end) end)
local function mkCircle(filled)
local f = Instance.new("Frame")
f.AnchorPoint = Vector2.new(0.5, 0.5); f.BorderSizePixel = 0; f.Visible = false; f.Active = false
f.BackgroundColor3 = Color3.new(1, 1, 1); f.BackgroundTransparency = filled and 0.8 or 1
f.Size = UDim2.fromOffset(10, 10); f.Parent = gGui
Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
local st
if not filled then st = Instance.new("UIStroke"); st.Thickness = 1.5; st.Parent = f end
return f, st
end
local ring, ringSt = mkCircle(false)
local fillC = mkCircle(true)
local ring2, ring2St = mkCircle(false)
local fill2 = mkCircle(true)
local gFill = mkCircle(true)
local gGrad = Instance.new("UIGradient"); gGrad.Parent = gFill
local function wrap(a) return (a + math.pi) % (2 * math.pi) - math.pi end
function M.partFor(ch, mode)
mode = mode or A.part
local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HitboxHead")
local torso = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HitboxBody")
local root = ch:FindFirstChild("HumanoidRootPart")
if mode == "Head" then return head or root end
if mode == "Torso" then return torso or root end
local r = S.rand[ch]
if r and r.Parent then return r end
if mode == "Weighted" then
local total = A.wHead + A.wTorso
if total <= 0 then r = head or root
elseif math.random() * total <= A.wHead then r = head or root
else r = torso or root end
else -- Random
local list = {}
for _, x in ipairs({head, torso}) do if x then list[#list + 1] = x end end
r = list[math.random(math.max(#list, 1))] or root
end
S.rand[ch] = r
return r
end
function M.valid(plr, c, partMode)
if plr == player then return nil end
if not (A.team or M.isEnemy(plr)) then return nil end
local ch = plr.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
local part = ch and M.partFor(ch, partMode)
if not (hum and part and hum.Health > 0) then return nil end
if part.Transparency > 0.95 and part.LocalTransparencyModifier > 0.95 and not part.Name:find("Hitbox", 1, true) then return nil end
return ch, part
end
function M.visible(c, ch, part, wall)
if not wall then return true end
local hit = workspace:Raycast(c.CFrame.Position, part.Position - c.CFrame.Position, params)
return hit == nil or hit.Instance:IsDescendantOf(ch)
end
function M.inFov(c, part, center, fov, ignore)
local p = c:WorldToViewportPoint(part.Position)
if p.Z <= 0 then
if ignore then return 1e5 + (part.Position - c.CFrame.Position).Magnitude end
return nil
end
local d = (Vector2.new(p.X, p.Y) - center).Magnitude
if ignore or d <= (fov or A.fov) then return d end
end
function M.pick(c, center, prefer, o)
params.FilterDescendantsInstances = {player.Character or c, c}
local cur = prefer
if prefer == nil then cur = S.target end
if cur and cur.Parent then
local plr = Players:GetPlayerFromCharacter(cur.Parent)
if plr then
local ch, part = M.valid(plr, c, o.part)
if ch and part == cur and M.inFov(c, part, center, o.fov, o.ignore) and M.visible(c, ch, part, o.wall) then return part end
end
end
local best, bestD
for _, plr in ipairs(Players:GetPlayers()) do
local ch, part = M.valid(plr, c, o.part)
if ch then
local d = M.inFov(c, part, center, o.fov, o.ignore)
if d and (not bestD or d < bestD) and M.visible(c, ch, part, o.wall) then best, bestD = part, d end
end
end
return best
end
function M.step(ey, ep, dt, now)
local s = A.smooth
local err = math.sqrt(ey * ey + ep * ep)
if s <= 0.001 or err < 1e-5 then return ey, ep end          -- 0 = hard snap
local mode = A.mode
local f
if mode == "Linear" then
local speed = math.rad(1500 + (90 - 1500) * s)           -- constant angular speed
f = math.min(1, speed * dt / err)
elseif mode == "Lock" then
local alpha = 1 + (0.1 - 1) * s                          -- exponential catch-up
f = 1 - (1 - alpha) ^ (dt * 60)
elseif mode == "Spring" then
local d = math.min(dt, 1 / 45)
local k = 2500 + (60 - 2500) * s ^ 0.7
local c = 2 * math.sqrt(k) * 0.85
S.vy += (ey * k - S.vy * c) * d
S.vp += (ep * k - S.vp * c) * d
return S.vy * d, S.vp * d
else -- "AI": human-like: reaction delay, ease-out near the target, tiny wobble
if now - S.since < 0.04 + 0.12 * s then return 0, 0 end
local t = math.clamp(math.deg(err) / 20, 0, 1)
local ease = 0.35 + 0.65 * (t * t * (3 - 2 * t))
f = math.min(1, (0.9 + (0.08 - 0.9) * s) * ease * dt * 60)
local w = math.rad(0.12) * s
return ey * f + math.sin(now * 7.3) * w * dt * 60, ep * f + math.cos(now * 5.1) * w * dt * 60
end
return ey * f, ep * f
end
function M.syncViewmodels(c, delta)
local function pivot(m)
if m:IsA("Model") and not m:FindFirstChildOfClass("Humanoid") then
pcall(function() m:PivotTo(delta * m:GetPivot()) end)
end
end
local function scan(root)
for _, ch in ipairs(root:GetChildren()) do
if ch:IsA("Folder") then for _, m in ipairs(ch:GetChildren()) do pivot(m) end else pivot(ch) end
end
end
scan(c)
local vm = workspace:FindFirstChild("ViewModels") or workspace:FindFirstChild("Viewmodels")
if vm then scan(vm) end
end
local function hexC(k, d)
local ok, c = pcall(Color3.fromHex, CONFIG_VALUES[k] or d)
if ok then return c end
return Color3.fromHex(d)
end
local function place(f, center, r)
f.Position = UDim2.fromOffset(center.X, center.Y); f.Size = UDim2.fromOffset(r * 2, r * 2)
end
local function updateCircle(center, now)
local col = hexC("Combat.Aim Assist.FOV Circle.FOV Color", "#F03E3E")
local op = 0.18
if A.anim == "Rainbow" then col = Color3.fromHSV(now * 0.3 % 1, 0.85, 1)
elseif A.anim == "Pulse" then op = 0.18 + 0.14 * math.sin(now * 3.2)
elseif A.anim == "Lock Flash" then op = 0.1 + 0.4 * S.flash end
op = math.clamp(op, 0.03, 0.9)
local aimShow = A.show and A.on
ring.Visible = aimShow; fillC.Visible = aimShow and A.fill
if aimShow then
place(ring, center, A.fov); ringSt.Color = col
place(fillC, center, A.fov); fillC.BackgroundColor3 = col; fillC.BackgroundTransparency = 1 - op
end
local silShow = A.sShow and (A.silent or A.legit) and not A.ignoreFov
local c1 = hexC("Combat.Silent Aim.FOV Circle.Circle Color", "#F03E3E")
local c2 = hexC("Combat.Silent Aim.FOV Circle.Gradient Color", "#3E7BF0")
ring2.Visible = silShow
if silShow then place(ring2, center, A.sFov); ring2St.Color = c1 end
local grad = silShow and A.sGrad
fill2.Visible = silShow and A.sFill and not grad
if fill2.Visible then place(fill2, center, A.sFov); fill2.BackgroundColor3 = c1; fill2.BackgroundTransparency = 0.8 end
gFill.Visible = grad and true or false
if grad then
place(gFill, center, A.sFov)
gFill.BackgroundTransparency = 0.7
gGrad.Color = ColorSequence.new(c1, c2)
gGrad.Rotation = (now * 60) % 360
end
end
local HARD_BLOCK = {["Warper"] = true, ["Medkit"] = true, ["Subspace Tripmine"] = true, ["Warpstone"] = true,
["Flashbang"] = true, ["Grenade"] = true, ["Jump Pad"] = true, ["Molotov"] = true, ["Satchel"] = true,
["Smoke Grenade"] = true, ["War Horn"] = true, ["Grappler"] = true, ["Flamethrower"] = true}
function M.fighterCtrl()
if not S.fc then pcall(function() S.fc = require(player.PlayerScripts.Controllers.FighterController) end) end
return S.fc
end
function M.fighterOf(plr)
local fc = M.fighterCtrl()
if not (plr and fc) then return nil end
local map = rawget(fc, "_player_to_fighter")
if type(map) == "table" then
local f = rawget(map, plr)
if f then return f end
for _, v in pairs(map) do if type(v) == "table" and rawget(v, "Player") == plr then return v end end
end
if type(fc.GetFighter) == "function" then
local ok, r = pcall(fc.GetFighter, fc, plr)
if ok and r then return r end
end
return nil
end
function M.localFighter()
local fc = M.fighterCtrl()
if not fc then return nil end
local f = M.fighterOf(player) or rawget(fc, "LocalFighter")
if not f then local ok, r = pcall(function() return fc.LocalFighter end); f = ok and r or nil end
return f
end
function M.localItem()
local f = M.localFighter()
if not f then return nil end
local it = rawget(f, "EquippedItem")
if it == nil then local ok, r = pcall(function() return f.EquippedItem end); it = ok and r or nil end
return it
end
function M.isEnemy(plr)
local e, me = plr:GetAttribute("EnvironmentID"), player:GetAttribute("EnvironmentID")
if e ~= nil and me ~= nil then
if e ~= me then return false end
local t, mt = plr:GetAttribute("TeamID"), player:GetAttribute("TeamID")
return mt == nil or t ~= mt
end
return plr.Team == nil or plr.Team ~= player.Team
end
function M.ready()
local c = workspace.CurrentCamera
if not c then return false end
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not (hum and hum.Health > 0) then return false end
local f = M.localFighter()
local entity = f and f.Entity
if type(entity) == "table" and rawget(entity, "_is_in_world") ~= true then return false end
return true
end
function M.shielded(plr)
local f = M.fighterOf(plr)
local entity = f and rawget(f, "Entity")
local data = entity and rawget(entity, "Data")
return type(data) == "table" and rawget(data, "IsInvincible") == true
end
function M.hookable(item)
if type(item) ~= "table" or HARD_BLOCK[item.Name] or type(item.StartShooting) ~= "function" then return false end
local info = item.Info
if not info then return item.Name == "Daggers" or item.Name == "Bow" or item.Name == "Slingshot" end
local timed = type(info.ShootCooldown) == "number" or type(info.ShootBurstCooldown) == "number"
or type(info.ShootBurst) == "number" or type(info.QuickShotCooldown) == "number"
or type(info.ChargeReleaseCooldown) == "number" or type(info.BladeCooldown) == "number"
local melee = type(info.AttackCooldown) == "number" and (info.Class == "Melee" or info.Type == "Melee")
return timed or melee or item.Name == "Daggers" or item.Name == "Bow" or item.Name == "Slingshot"
end
function M.cacheWindow(item)
local info, w = item and item.Info, math.huge
for _, v in ipairs({info and info.ShootBurstCooldown, info and info.QuickShotCooldown,
info and info.ShootCooldown, info and info.ChargeReleaseCooldown}) do
if type(v) == "number" and v > 0 then w = math.min(w, v) end
end
if w == math.huge then return 1 / 30 end
return math.clamp(w, 1 / 60, 0.08)
end
function M.resolveHookTarget(item, c)
local center = c.ViewportSize / 2
params.FilterDescendantsInstances = {player.Character or c, c}
local cur, now = S.hook, os.clock()
if cur and cur.Parent and (now - S.hookAt) <= M.cacheWindow(item) then
local plr = Players:GetPlayerFromCharacter(cur.Parent)
local ch, part = nil, nil
if plr then ch, part = M.valid(plr, c, A.part) end
if ch and M.inFov(c, part, center, A.sFov, A.ignoreFov) and M.visible(c, ch, part, not A.wallbang) then S.hook = part; return part end
end
S.rand = setmetatable({}, {__mode = "k"})                    -- Random: new roll per fresh target
local part = M.pick(c, center, false, {fov = A.sFov, ignore = A.ignoreFov, part = A.part, wall = not A.wallbang})
S.hook, S.hookAt = part, part and now or 0
return part
end
function M.prime(part, c)
if not M.ready() then return false end
if not (part and part.Parent and c) then return false end
c.CFrame = CFrame.lookAt(c.CFrame.Position, part.Position)
return true
end
function M.BeginSilentShot(item)
if S.depth > 0 and os.clock() - S.depthAt > 1 then S.depth = 0 end
if S.depth > 0 then return false, nil, nil end
if not (A.silent and A.sMode == "Silent" and M.ready()) then return false, nil, nil end
if A.hitChance < 100 and math.random() * 100 > A.hitChance then return false, nil, nil end   -- missed the roll: normal shot
S.rand = setmetatable({}, {__mode = "k"})                    -- Random / Weighted: new roll for every shot
local c = workspace.CurrentCamera
local part = c and M.resolveHookTarget(item, c)
if not part then return false, nil, nil end
local plr = Players:GetPlayerFromCharacter(part.Parent)
if plr and M.shielded(plr) then return false, nil, nil end
local original = c.CFrame
if not M.prime(part, c) then return false, nil, nil end
S.depth += 1; S.depthAt = os.clock()
return true, c, original
end
function M.FinishSilentShot(didPrime, c, original)
if not didPrime then return end
S.depth = math.max(S.depth - 1, 0)
if c and original and workspace.CurrentCamera == c and M.ready() then c.CFrame = original end
end
function M.unhook()
local item = S.hooked
if not item then return end
if rawget(item, "StartShooting") == S.hookWrap then
pcall(function()
if S.hookHad then item.StartShooting = S.hookOrig else rawset(item, "StartShooting", nil) end
end)
end
S.hooked, S.hookOrig, S.hookWrap = nil, nil, nil
end
function M.ensureHook(item)
if S.hooked == item or not M.hookable(item) then return end
M.unhook()
local orig = item.StartShooting
if S.wrapSet[orig] then S.hooked = item; return end
local wrapped
wrapped = function(self, ...)
local primed, c, original = M.BeginSilentShot(self)
local results = table.pack(pcall(orig, self, ...))
M.FinishSilentShot(primed, c, original)
if not results[1] then warn("[1Mag] silent_start_shooting: " .. tostring(results[2])); return nil end
return table.unpack(results, 2, results.n)
end
S.wrapSet[wrapped] = true
S.hookHad = rawget(item, "StartShooting") ~= nil
local ok = pcall(function() item.StartShooting = wrapped end)
if ok then S.hooked, S.hookOrig, S.hookWrap = item, orig, wrapped end
end
function M.syncHook()
if not (A.silent and A.sMode == "Silent") then M.unhook(); S.hook = nil end
end
local function aimStep(dt)
local c = workspace.CurrentCamera
if not c then ring.Visible = false; fillC.Visible = false; ring2.Visible = false; fill2.Visible = false; gFill.Visible = false return end
local center = c.ViewportSize / 2
local now = os.clock()
local held
if A.act == "Always On" then held = true
elseif A.act == "Button (Hold)" then held = aimBtn.down
elseif A.act == "Button (Toggle)" then held = aimBtn.on
else held = true end
if A.silent and A.sMode == "Silent" then
local item = M.localItem()
if item then M.ensureHook(item) end
end
local o
if A.on then
o = {fov = A.fov, ignore = false, part = "Head", wall = A.wall, react = A.aReact, switch = A.aSwitch}
elseif A.legit or (A.silent and A.sMode == "Camera") then
o = {fov = A.sFov, ignore = A.ignoreFov, part = A.part, wall = not A.wallbang, react = A.lReact, switch = A.lSwitch}
end
local cand = (o and held) and M.pick(c, center, nil, o) or nil
local target = S.target
if cand ~= target then
if not cand then
if target then S.lostAt = now end
target, S.pend = nil, nil
else
if S.pend ~= cand then
S.pend, S.pendAt = cand, now
S.pendDelay = (target or (now - S.lostAt) < 0.35) and o.switch or o.react
end
if now - S.pendAt >= S.pendDelay / 1000 then target, S.pend = cand, nil
else
if target then S.lostAt = now end
target = nil
end
end
end
if target ~= S.target then
S.target = target; S.since = now; S.vy, S.vp = 0, 0
S.rand = setmetatable({}, {__mode = "k"})
end
S.flash += ((target and 1 or 0) - S.flash) * math.min(1, dt * 10)
pcall(updateCircle, center, now)
if not target then return end
local pos = target.Position
if A.mode == "AI" then                                       -- lead moving targets a little
local last = S.vel[target]
local v = last and (pos - last.p) / math.max(now - last.t, 1e-3) or Vector3.zero
if last then v = last.v:Lerp(v, 0.3) end
S.vel[target] = {p = pos, t = now, v = v}
pos = pos + v * 0.06
end
local cf = c.CFrame
local px, py, pz = cf:ToOrientation()
local d = (pos - cf.Position)
if d.Magnitude < 1e-3 then return end
d = d.Unit
local ey = wrap(math.atan2(-d.X, -d.Z) - py)
local ep = math.asin(math.clamp(d.Y, -1, 1)) - px
local dy, dp = M.step(ey, ep, dt, now)
local newCF = CFrame.new(cf.Position) * CFrame.fromOrientation(math.clamp(px + dp, -1.5, 1.5), py + dy, pz)
c.CFrame = newCF
M.syncViewmodels(c, newCF * cf:Inverse())
end
pcall(RunService.UnbindFromRenderStep, RunService, "1MagAim")
RunService:BindToRenderStep("1MagAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
local ok, err = pcall(aimStep, dt)
if not ok then
S.errs = (S.errs or 0) + 1
if S.errs <= 3 then warn("[1Mag] aim step error: " .. tostring(err)) end
end
end)
do -- Triggerbot + Flickbot (ported from Kiciahook)
local trigBtn = FX.MB.new("trig", "TRIG", 0.64, 0.5); FX.MB.trig = trigBtn; trigBtn.kind = "hold"
trigBtn.want = function() return TB.on and (TB.act == "Button (Hold)" or TB.act == "Button (Toggle)") end
local flickBtn = FX.MB.new("flick", "FLICK", 0.64, 0.65); FX.MB.flick = flickBtn; flickBtn.kind = "hold"
flickBtn.want = function() return TB.fOn and (TB.fAct == "Button (Hold)" or TB.fAct == "Button (Toggle)") end
local keyCache, keyAt = {}, 0
local function boundKey(label)
local now = os.clock()
if now - keyAt > 0.3 then keyCache = {}; keyAt = now end
local kc = keyCache[label]
if kc ~= nil then return kc end
kc = false
for k, v in pairs(CONFIG_VALUES) do
if type(k) == "string" and type(v) == "string" and k:find("Combat.Triggerbot.", 1, true) == 1 and k:sub(-(#label + 1)) == "." .. label then
local ok, code = pcall(function() return Enum.KeyCode[v] end)
if ok and code and code ~= Enum.KeyCode.Unknown then kc = code end
break
end
end
keyCache[label] = kc
return kc
end
local function active(act, label, btn, tog)
if act == "Always On" then return true
elseif act == "Keybind (Hold)" then local k = boundKey(label); return k and (UIS:IsKeyDown(k) or UIS:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, k)) or false
elseif act == "Keybind (Toggle)" then return tog
elseif act == "Button (Hold)" then return btn.down
else return btn.on end
end
local inp = UIS.InputBegan:Connect(function(i)
if UIS:GetFocusedTextBox() then return end
local tk, fk = boundKey("Triggerbot Key"), boundKey("Flickbot Key")
if tk and i.KeyCode == tk and TB.act == "Keybind (Toggle)" then TB.tOn = not TB.tOn end
if fk and i.KeyCode == fk and TB.fAct == "Keybind (Toggle)" then TB.fTog = not TB.fTog end
end)
local tParams = RaycastParams.new(); tParams.FilterType = Enum.RaycastFilterType.Exclude
local function partAllowed(n)
if n == "Head" or n == "HitboxHead" or n == "HitboxHeadSmall" then return TB.head end
if n:find("Torso") or n == "HumanoidRootPart" or n == "HitboxBody" or n == "HitboxBodySmall" then return TB.torso end
if n:find("Arm") or n:find("Hand") then return TB.arms end
if n:find("Leg") or n:find("Foot") then return TB.legs end
return false
end
local function crosshairOn(c)
tParams.FilterDescendantsInstances = {player.Character or c, c}
local ctr = c.ViewportSize / 2
local ray = c:ViewportPointToRay(ctr.X, ctr.Y)
local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, tParams)
if not hit then return false end
local model = hit.Instance:FindFirstAncestorOfClass("Model")
local plr = model and Players:GetPlayerFromCharacter(model)
if not plr or plr == player then return false end
if not (TB.team or M.isEnemy(plr)) then return false end
local hum = model:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 then return false end
if not partAllowed(hit.Instance.Name) then return false end
if TB.shield and M.shielded(plr) then return false end
return true
end
local function isGun(item)
if type(item) ~= "table" then return false end
local ok, v = pcall(function() return item.StartShooting end)
return ok and type(v) == "function"
end
local function fire(item)
local f = M.localFighter()
local done = false
if f then
local mt = getmetatable(f)
local idx = type(mt) == "table" and rawget(mt, "__index")
local fn = type(idx) == "table" and rawget(idx, "Input") or nil
if not fn then local ok, r = pcall(function() return f.Input end); fn = ok and r or nil end
if type(fn) == "function" then
local old = getthreadidentity and getthreadidentity()
if setthreadidentity then pcall(setthreadidentity, 8) end
done = pcall(fn, f, "StartShooting")
if old and setthreadidentity then pcall(setthreadidentity, old) end
end
end
if not done then
item = item or M.localItem()
if isGun(item) then pcall(item.StartShooting, item) end
end
end
local hb = RunService.Heartbeat:Connect(function(dt)
if not TB.on or not M.ready() or not active(TB.act, "Triggerbot Key", trigBtn, TB.tOn) then TB.rt = nil; TB.rl = 0; return end
local item = M.localItem()
if TB.gunOnly and not isGun(item) then TB.rt = nil; TB.rl = 0; return end
local c = workspace.CurrentCamera
if not c then return end
local onT = crosshairOn(c)
if onT then TB.rt = (TB.rt == nil) and 0 or (TB.rt + dt) else TB.rt = nil end
if onT and TB.rt >= TB.react then TB.rl = TB.release; fire(item); return end
TB.rl = math.max(0, TB.rl - dt)
if TB.rl > 0 then fire(item) end
end)
-- Flickbot: curved, human-like camera flick onto the best target, then optional shot.
local FL = {state = "Idle", wasActive = false, timer = 0}
local function finishFlick()
FL.traj, FL.part = nil, nil
if TB.fCool > 0 then FL.state = "Cooldown"; FL.timer = TB.fCool / 1000 else FL.state = "Idle" end
end
local function startFlick(c)
local ctr = c.ViewportSize / 2
local part = M.pick(c, ctr, false, {fov = TB.fFov, ignore = false, part = TB.fPart, wall = TB.fWall})
if not part then return end
local sp = c:WorldToViewportPoint(part.Position)
if sp.Z <= 0 then return end
local s, e = Vector2.new(ctr.X, ctr.Y), Vector2.new(sp.X, sp.Y)
local d = e - s
local dist = d.Magnitude
local perp = dist > 0 and Vector2.new(-d.Y, d.X).Unit or Vector2.zero
local side = math.random() < 0.5 and -1 or 1
local ctrl = (s + e) / 2 + perp * dist * (TB.fCurve / 100) * side
local hum = TB.fHuman / 100
local amp = hum * dist * 0.03 * (math.random() * 2 - 1)
local n = math.max(8, math.floor(TB.fDur / 8))
local traj = {}
for i = 0, n do
local t = i / n
local te = t + (t * t * (3 - 2 * t) - t) * (0.5 + 0.5 * hum)
local u = 1 - te
local p = s * (u * u) + ctrl * (2 * u * te) + e * (te * te) + perp * (math.sin(t * math.pi) * amp)
local r = c:ViewportPointToRay(p.X, p.Y)
traj[i + 1] = {d = r.Direction, T = t * TB.fDur}
end
FL.traj, FL.part, FL.el, FL.total, FL.endDir, FL.idx, FL.state = traj, part, 0, TB.fDur, traj[#traj].d, 1, "Flicking"
end
local function flickStep(dt)
local st = FL.state
if st == "Idle" then
local a = TB.fOn and M.ready() and active(TB.fAct, "Flickbot Key", flickBtn, TB.fTog)
if a and (not FL.wasActive or TB.fAct:find("Toggle")) then
local c = workspace.CurrentCamera
if c then startFlick(c) end
end
FL.wasActive = a and true or false
elseif st == "Flicking" then
local c, part = workspace.CurrentCamera, FL.part
if not (c and part and part.Parent and M.ready()) then finishFlick(); return end
FL.el += dt * 1000
local tr, i = FL.traj, FL.idx
while i < #tr and tr[i + 1].T <= FL.el do i += 1 end
FL.idx = i
local a, b = tr[i], tr[i + 1]
local dir, done
if not b then dir, done = tr[#tr].d, true
else
local f = (b.T - a.T) > 0 and math.clamp((FL.el - a.T) / (b.T - a.T), 0, 1) or 1
dir = a.d:Lerp(b.d, f)
end
if FL.el < FL.total then
dir = (dir + ((part.Position - c.CFrame.Position).Unit - FL.endDir) * math.clamp(FL.el / FL.total, 0, 1)).Unit
end
local cf = c.CFrame
local newCF = CFrame.lookAt(cf.Position, cf.Position + dir)
c.CFrame = newCF
M.syncViewmodels(c, newCF * cf:Inverse())
if done then
if TB.fShoot then FL.state = "PostShot"; FL.timer = TB.fDelay / 1000 else finishFlick() end
end
elseif st == "PostShot" then
FL.timer -= dt
if FL.timer <= 0 then fire(); finishFlick() end
elseif st == "Cooldown" then
FL.timer -= dt
if FL.timer <= 0 then FL.state = "Idle" end
end
end
pcall(RunService.UnbindFromRenderStep, RunService, "1MagFlick")
RunService:BindToRenderStep("1MagFlick", Enum.RenderPriority.Camera.Value + 2, function(dt)
local ok, err = pcall(flickStep, dt)
if not ok then FL.state = "Idle"; FL.errs = (FL.errs or 0) + 1; if FL.errs <= 3 then warn("[1Mag] flickbot error: " .. tostring(err)) end end
end)
gui.Destroying:Connect(function()
pcall(function() hb:Disconnect() end); pcall(function() inp:Disconnect() end)
pcall(RunService.UnbindFromRenderStep, RunService, "1MagFlick")
end)
end
gui.Destroying:Connect(function()
pcall(RunService.UnbindFromRenderStep, RunService, "1MagAim")
M.unhook()
pcall(function() gGui:Destroy() end)
end)
end
do -- visual/character scope (keeps main chunk under the local limit)
local V = {}  -- live settings
local function hex3(h) return Color3.fromHex(h) end
local plrs = game:GetService("Players")
local cam = function() return workspace.CurrentCamera end
local hasDraw = type(Drawing) == "table" and type(Drawing.new) == "function"
do
local esp = addSub(mVis, "ESP", "Player ESP.")
esp.Section("ESP Options")
esp.Toggle("ESP Enabled", false, function(v) V.esp = v end)
esp.Toggle("Chams (Highlight)", false, function(v) V.hl = v end)
esp.Toggle("Box", false, function(v) V.box = v end)
esp.Dropdown("Box Style", {"Corner", "Full"}, "Corner", function(v) V.style = v end)
esp.Toggle("Box Fill", false, function(v) V.bfill = v end)
esp.Toggle("Names", false, function(v) V.names = v end)
esp.Toggle("Health Bar", false, function(v) V.health = v end)
esp.Toggle("Distance", false, function(v) V.dist = v end)
esp.Toggle("Tracers", false, function(v) V.tracer = v end)
esp.Dropdown("Tracer Origin", {"Character (HRP)", "Bottom", "Center", "Mouse"}, "Character (HRP)", function(v) V.tOrigin = v end)
esp.Toggle("Look Direction", false, function(v) V.look = v end)
esp.Toggle("Offscreen Arrows", false, function(v) V.arrows = v end)
esp.Toggle("Show Teammates", false, function(v) V.team = v end)
esp.Toggle("Only Draw In Match", true, function(v) V.matchOnly = v end)
esp.Slider("Chams Fill Transparency", 0, 100, 75, function(v) V.fill = v / 100 end)
esp.Slider("Chams Outline Transparency", 0, 100, 0, function(v) V.outl = v / 100 end)
esp.Slider("Max Distance", 100, 3000, 1500, function(v) V.maxd = v end, 50)
esp.Slider("Screen Y Offset", -150, 150, 0, function(v) V.yoff = v end)
esp.Section("Colours")
esp.Color("Visible Color", "@accent")
esp.Color("Hidden Color", "@accenthi")
esp.Color("Look Direction Color", "@accenthi")
V.fill = V.fill or 0.75; V.outl = V.outl or 0; V.maxd = V.maxd or 1500; V.style = V.style or "Corner"
local items = {}
local function colorOf(k, d) return hex3(CONFIG_VALUES["Visual.ESP.Colours." .. k] or d) end
local function dl(kind, props)
local d = Drawing.new(kind)
for k, v in pairs(props) do pcall(function() d[k] = v end) end
d.Visible = false
return d
end
local function mk(plr)
local o = {}
o.hl = Instance.new("Highlight"); o.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; o.hl.Enabled = false
if hasDraw then
o.fillSq = dl("Square", {Filled = true, Transparency = 0.12})
o.edge, o.edgeO = {}, {}
for i = 1, 8 do
o.edgeO[i] = dl("Line", {Thickness = 3, Color = Color3.new(0, 0, 0)})
o.edge[i] = dl("Line", {Thickness = 1.5})
end
o.hpBg = dl("Square", {Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.6})
o.hp = dl("Square", {Filled = true})
o.name = dl("Text", {Center = true, Outline = true, Size = 14, Font = 2, Color = Color3.new(1, 1, 1)})
o.info = dl("Text", {Center = true, Outline = true, Size = 12, Font = 2, Color = Color3.fromRGB(210, 210, 210)})
o.line = dl("Line", {Thickness = 1.5})
o.look = dl("Line", {Thickness = 1.5})
o.arrow = dl("Triangle", {Filled = true})
end
items[plr] = o
end
local function hideAll(o)
o.hl.Enabled = false
if not o.name then return end
o.fillSq.Visible = false; o.hpBg.Visible = false; o.hp.Visible = false; o.name.Visible = false
o.info.Visible = false; o.line.Visible = false; o.look.Visible = false; o.arrow.Visible = false
for i = 1, 8 do o.edge[i].Visible = false; o.edgeO[i].Visible = false end
end
local function rm(plr)
local o = items[plr]; if not o then return end
pcall(function() o.hl:Destroy() end)
if o.name then
for _, k in ipairs({"fillSq", "hpBg", "hp", "name", "info", "line", "look", "arrow"}) do pcall(function() o[k]:Remove() end) end
for i = 1, 8 do pcall(function() o.edge[i]:Remove(); o.edgeO[i]:Remove() end) end
end
items[plr] = nil
end
local espInit = false   -- drawings are created the first time ESP is switched on (not at load)
local c1 = plrs.PlayerAdded:Connect(function(p) if espInit and p ~= player then mk(p) end end)
local c2 = plrs.PlayerRemoving:Connect(rm)
local function setBox(o, x, y, w, h, col, corner)
local L = corner and 0.28 or 0.5
local segs = {
{x, y, x + w * L, y}, {x + w * (1 - L), y, x + w, y},
{x, y + h, x + w * L, y + h}, {x + w * (1 - L), y + h, x + w, y + h},
{x, y, x, y + h * L}, {x, y + h * (1 - L), x, y + h},
{x + w, y, x + w, y + h * L}, {x + w, y + h * (1 - L), x + w, y + h},
}
for i, sg in ipairs(segs) do
for _, ln in ipairs({o.edgeO[i], o.edge[i]}) do
ln.From = Vector2.new(sg[1], sg[2]); ln.To = Vector2.new(sg[3], sg[4]); ln.Visible = true
end
o.edge[i].Color = col
end
end
local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
local camNow
local function P(v3) local p, on = camNow:WorldToViewportPoint(v3); return Vector3.new(p.X, p.Y + (V.yoff or 0), p.Z), on end
local function fin(n) return n == n and n > -1e5 and n < 1e5 end
local function hideAllItems() for _, o in pairs(items) do hideAll(o) end end
local function setHL(o, ch, col)
if o.hlChar ~= ch or not o.hl or o.hl.Parent == nil then
pcall(function() if o.hl then o.hl:Destroy() end end)
local hl = Instance.new("Highlight"); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local okp = pcall(function() hl.Parent = ch end)
if not okp then hl.Parent = gui end
o.hl = hl; o.hlChar = ch
end
local hl = o.hl
hl.Adornee = ch; hl.Enabled = V.hl and true or false
hl.FillColor, hl.OutlineColor = col, col
hl.FillTransparency, hl.OutlineTransparency = V.fill, V.outl
end
local function updatePlayer(plr, o, c, vp, myChar, myRoot, inMatch)
local ch = plr.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
local rootp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head"))
local ok = V.esp and inMatch and rootp and hum and hum.Health > 0 and (V.team or plr.Team ~= player.Team or plr.Team == nil)
local dist = (ok and myRoot) and (rootp.Position - myRoot.Position).Magnitude or 0
if ok and dist > V.maxd then ok = false end
local hd = ch and ch:FindFirstChild("Head")
if ok and hd and hd.Transparency > 0.95 and hd.LocalTransparencyModifier > 0.95 then ok = false end
if not ok then hideAll(o); return end
local head = ch:FindFirstChild("Head") or rootp
local hit = workspace:Raycast(c.CFrame.Position, head.Position - c.CFrame.Position, params)
local visible = (hit == nil) or hit.Instance:IsDescendantOf(ch)
local col = visible and colorOf("Visible Color", "#FF2A3D") or colorOf("Hidden Color", "#FFFFFF")
setHL(o, ch, col)
if not o.name then return end
local pos, on = P(rootp.Position)
local top = P(rootp.Position + Vector3.new(0, 2.9, 0))
local bot = P(rootp.Position - Vector3.new(0, 3.1, 0))
local h = math.abs(bot.Y - top.Y)
local valid = on and pos.Z > 0 and top.Z > 0 and bot.Z > 0 and fin(pos.X) and fin(pos.Y) and fin(h) and h >= 1 and h <= vp.Y * 3
if valid then
local w = h * 0.55
local x, y = math.floor(pos.X - w / 2), math.floor(top.Y)
h = math.floor(h); w = math.floor(w)
if V.box then
setBox(o, x, y, w, h, col, V.style == "Corner")
else for i = 1, 8 do o.edge[i].Visible = false; o.edgeO[i].Visible = false end end
o.fillSq.Visible = (V.box and V.bfill) and true or false
o.fillSq.Position = Vector2.new(x, y); o.fillSq.Size = Vector2.new(w, h); o.fillSq.Color = col
o.name.Visible = V.names and true or false
o.name.Text = plr.DisplayName; o.name.Position = Vector2.new(pos.X, y - 16)
local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
o.hpBg.Visible = V.health and true or false
o.hpBg.Position = Vector2.new(x - 6, y - 1); o.hpBg.Size = Vector2.new(4, h + 2)
o.hp.Visible = V.health and true or false
o.hp.Position = Vector2.new(x - 5, y + h * (1 - pct)); o.hp.Size = Vector2.new(2, h * pct)
o.hp.Color = Color3.fromHSV(pct * 0.33, 0.9, 1)
local info = {}
if V.dist then info[#info + 1] = math.floor(dist) .. "m" end
if V.health then info[#info + 1] = math.floor(hum.Health) .. "hp" end
o.info.Visible = #info > 0
o.info.Text = table.concat(info, " · "); o.info.Position = Vector2.new(pos.X, y + h + 3)
if V.tracer then
local from = Vector2.new(vp.X / 2, vp.Y)
local mode = V.tOrigin or "Character (HRP)"
if mode == "Center" then from = vp / 2
elseif mode == "Mouse" then local ml = UIS:GetMouseLocation(); from = Vector2.new(ml.X, ml.Y)
elseif mode == "Character (HRP)" and myRoot then
local mp = P(myRoot.Position)
local _, mon = camNow:WorldToViewportPoint(myRoot.Position)
if mon and mp.Z > 0 and fin(mp.X) and fin(mp.Y) then from = Vector2.new(mp.X, mp.Y) end
end
o.line.Visible = true; o.line.From = from; o.line.To = Vector2.new(pos.X, pos.Y)
o.line.Color = col; o.line.Transparency = 0.6
else o.line.Visible = false end
if V.look then
local a2 = P(head.Position)
local b2 = P(head.Position + head.CFrame.LookVector * 6)
if a2.Z > 0 and b2.Z > 0 and fin(a2.X) and fin(a2.Y) and fin(b2.X) and fin(b2.Y) then
o.look.Visible = true; o.look.From = Vector2.new(a2.X, a2.Y); o.look.To = Vector2.new(b2.X, b2.Y)
o.look.Color = colorOf("Look Direction Color", "#FFFF00")
else o.look.Visible = false end
else o.look.Visible = false end
o.arrow.Visible = false
else
o.fillSq.Visible = false; o.hpBg.Visible = false; o.hp.Visible = false; o.name.Visible = false
o.info.Visible = false; o.line.Visible = false; o.look.Visible = false
for i = 1, 8 do o.edge[i].Visible = false; o.edgeO[i].Visible = false end
if V.arrows then
local rel = c.CFrame:PointToObjectSpace(rootp.Position)
local ang = math.atan2(rel.X, -rel.Z)
local d = Vector2.new(math.sin(ang), -math.cos(ang)); local n = Vector2.new(-d.Y, d.X)
local p0 = vp / 2 + d * math.min(vp.X, vp.Y) * 0.4
o.arrow.PointA = p0 + d * 12; o.arrow.PointB = p0 - d * 8 + n * 9; o.arrow.PointC = p0 - d * 8 - n * 9
o.arrow.Color = col; o.arrow.Visible = true
else o.arrow.Visible = false end
end
end
RunService:BindToRenderStep("1MagESP", Enum.RenderPriority.Camera.Value + 1, function()
local c = cam()
if not c or not V.esp then hideAllItems(); return end
if not espInit then
espInit = true
for _, p in ipairs(plrs:GetPlayers()) do if p ~= player and not items[p] then pcall(mk, p) end end
end
camNow = c
local myChar = player.Character
local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
local inMatch = (not V.matchOnly) or (myRoot ~= nil and (c.CFrame.Position - myRoot.Position).Magnitude < 40)
params.FilterDescendantsInstances = {myChar or c, c}
local vp = c.ViewportSize
for plr, o in pairs(items) do
local okk = pcall(updatePlayer, plr, o, c, vp, myChar, myRoot, inMatch)
if not okk then hideAll(o) end   -- any error -> hide that player instead of leaving drawings frozen
end
end)
gui.Destroying:Connect(function() pcall(RunService.UnbindFromRenderStep, RunService, "1MagESP"); c1:Disconnect(); c2:Disconnect(); for p in pairs(items) do rm(p) end end)
if not hasDraw then esp.Label("Drawing API missing on this executor - only Highlight works.") end
end
do
local fx = addSub(mVis, "Client Effects", "Camera and screen effects.")
fx.Section("Camera View")
local origFov
local fovOn, fovVal = false, 90
fx.Toggle("Custom Camera FOV", false, function(v)
fovOn = v
local c = cam(); if c and not origFov then origFov = c.FieldOfView end
if not v and c and origFov then c.FieldOfView = origFov end
end)
fx.Slider("Camera FOV", 30, 120, 90, function(v) fovVal = v end)
local fc = RunService.RenderStepped:Connect(function() local c = cam(); if fovOn and c then c.FieldOfView = fovVal end end)
gui.Destroying:Connect(function() fc:Disconnect() end)
fx.Section("Overlay & Effect Removals")
local rem = {}
fx.Toggle("No Flashbang", false, function(v) rem.flash = v end)
fx.Toggle("No Burn Effect", false, function(v) rem.burn = v end)
fx.Toggle("No ADS Vignette", false, function(v) rem.vig = v end)
local kw = { flash = {"flash"}, burn = {"burn", "fire"}, vig = {"vignette"} }
local function hideIn(root)
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("GuiObject") then
local n = d.Name:lower()
for k, words in pairs(kw) do
if rem[k] then for _, w in ipairs(words) do if n:find(w, 1, true) then d.Visible = false end end end
end
end
end
end
local rcAcc = 0
local rc = RunService.Heartbeat:Connect(function(dt)
rcAcc += dt; if rcAcc < 0.4 then return end; rcAcc = 0
if rem.flash or rem.burn or rem.vig then pcall(hideIn, PG) end
if rem.flash then for _, e in ipairs(Lighting:GetChildren()) do if e:IsA("ColorCorrectionEffect") and e.Name:lower():find("flash") then e.Enabled = false end end end
end)
gui.Destroying:Connect(function() rc:Disconnect() end)
end
do -- ===== CROSSHAIR (full custom crosshair: bars, dot, image ID, spin, rainbow, name) =====
local okX, errX = pcall(function()
task.wait()   -- spread the menu build over frames so loading does not freeze
local ch = addSub(mVis, "Crosshair", "Full custom crosshair: bars, dot, image ID, spin, rainbow and a name under it.")
local SUB = "Crosshair"
local hasDraw = type(Drawing) == "table" and type(Drawing.new) == "function"
local FONT_ID = {UI = Enum.Font.GothamMedium, System = Enum.Font.Arial, Plex = Enum.Font.RobotoMono, Monospace = Enum.Font.Code}
local X = {on = false, shape = "Plus", scale = 100,
showBars = true, bars = 4, len = 12, th = 2, gap = 6, barTr = 0, outline = true, outTh = 1,
dot = true, dotSize = 2, dotOutline = true, dotTr = 0,
spin = false, spd = 90, rot = 0,
rbBars = false, rbDot = false, rbName = false, rbImg = false, rbSpd = 0.4,
name = false, text = "Yokai.win", nsize = 18, nfont = "Monospace", noff = 18, nout = true,
img = false, imgAsset = "", imgSize = 64, imgSpin = false, imgSpd = 90, imgRot = 0, imgTr = 0}
local keyCache, memo = {}, {}
local function colorOf(sec, label, def)
local ks = keyCache[sec]; if not ks then ks = {}; keyCache[sec] = ks end
local key = ks[label]; if not key then key = "Visual." .. SUB .. "." .. sec .. "." .. label; ks[label] = key end
local hex = CONFIG_VALUES[key] or def
local c = memo[hex]
if not c then local ok, r = pcall(Color3.fromHex, hex); c = ok and r or Color3.new(1, 1, 1); memo[hex] = c end
return c
end
local function parseAsset(text)
text = tostring(text or "")
local id = text:match("(%d%d%d+)")
if not id then return "" end
return "rbxassetid://" .. id
end
-- ---------- menu ----------
ch.Section("Crosshair")
ch.Toggle("Enable Custom Crosshair", false, function(v) X.on = v end)
ch.Dropdown("Shape", {"Plus", "X"}, "Plus", function(v) X.shape = v end)
ch.Slider("Overall Scale (%)", 25, 300, 100, function(v) X.scale = v end, 5)
ch.Section("Bars")
ch.Toggle("Show Bars", true, function(v) X.showBars = v end)
ch.Color("Bar Color", "@accent")
ch.Slider("Bar Count", 2, 8, 4, function(v) X.bars = math.floor(v) end, 1)
ch.Slider("Bar Length", 1, 60, 12, function(v) X.len = v end, 1)
ch.Slider("Bar Thickness", 1, 10, 2, function(v) X.th = v end, 1)
ch.Slider("Bar Gap", 0, 60, 6, function(v) X.gap = v end, 1)
ch.Slider("Bar Transparency", 0, 100, 0, function(v) X.barTr = v / 100 end, 5)
ch.Toggle("Bar Outline", true, function(v) X.outline = v end)
ch.Slider("Outline Thickness", 1, 5, 1, function(v) X.outTh = v end, 1)
ch.Section("Dot")
ch.Toggle("Center Dot", true, function(v) X.dot = v end)
ch.Color("Dot Color", "@accenthi")
ch.Slider("Dot Size", 1, 20, 2, function(v) X.dotSize = v end, 1)
ch.Slider("Dot Transparency", 0, 100, 0, function(v) X.dotTr = v / 100 end, 5)
ch.Toggle("Dot Outline", true, function(v) X.dotOutline = v end)
ch.Section("Spin & Rotation")
ch.Toggle("Spin", false, function(v) X.spin = v end)
ch.Slider("Spin Speed (deg/s)", -720, 720, 90, function(v) X.spd = v end, 10)
ch.Slider("Rotation (deg)", 0, 360, 0, function(v) X.rot = v end, 1)
ch.Section("Rainbow")
ch.Toggle("Rainbow Bars", false, function(v) X.rbBars = v end)
ch.Toggle("Rainbow Dot", false, function(v) X.rbDot = v end)
ch.Toggle("Rainbow Name", false, function(v) X.rbName = v end)
ch.Toggle("Rainbow Image", false, function(v) X.rbImg = v end)
ch.Slider("Rainbow Speed", 1, 50, 10, function(v) X.rbSpd = v / 25 end, 1)
ch.Section("Name")
ch.Toggle("Show Name Under Crosshair", false, function(v) X.name = v end)
ch.TextBox("Name Text", "Yokai.win", function(v) X.text = (v ~= nil and v ~= "") and v or "Yokai.win" end)
ch.Color("Name Color", "@accent")
ch.Dropdown("Name Font", {"UI", "System", "Plex", "Monospace"}, "Monospace", function(v) X.nfont = v end)
ch.Slider("Name Size", 8, 40, 18, function(v) X.nsize = v end, 1)
ch.Slider("Name Distance", 0, 120, 18, function(v) X.noff = v end, 1)
ch.Toggle("Name Outline", true, function(v) X.nout = v end)
ch.Section("Image ID Crosshair")
ch.Toggle("Use Image Crosshair", false, function(v) X.img = v end)
ch.TextBox("Image ID", "paste an image ID", function(v) X.imgAsset = parseAsset(v) end)
ch.Color("Image Tint", "@accenthi")
ch.Slider("Image Size", 8, 300, 64, function(v) X.imgSize = v end, 2)
ch.Slider("Image Transparency", 0, 100, 0, function(v) X.imgTr = v / 100 end, 5)
ch.Toggle("Spin Image", false, function(v) X.imgSpin = v end)
ch.Slider("Image Spin Speed", -720, 720, 90, function(v) X.imgSpd = v end, 10)
ch.Slider("Image Rotation (deg)", 0, 360, 0, function(v) X.imgRot = v end, 1)
ch.Label("Use an Image ID (not a Decal ID). Size, spin and rotation for the image are separate from the bars and dot.")
-- ---------- image ----------
local iGui = Instance.new("ScreenGui")
iGui.Name = "1MagCrosshairImg"; iGui.ResetOnSpawn = false; iGui.IgnoreGuiInset = true; iGui.DisplayOrder = 1000000
FX.holdGui(iGui)
pcall(function() iGui.Parent = gui.Parent end)
gui.Destroying:Connect(function() pcall(function() iGui:Destroy() end) end)
local img = Instance.new("ImageLabel")
img.BackgroundTransparency = 1; img.AnchorPoint = Vector2.new(0.5, 0.5); img.Position = UDim2.fromScale(0.5, 0.5)
img.Size = UDim2.fromOffset(64, 64); img.Visible = false; img.Active = false; img.Parent = iGui
local nameLbl = Instance.new("TextLabel")
nameLbl.BackgroundTransparency = 1; nameLbl.AnchorPoint = Vector2.new(0.5, 0); nameLbl.Position = UDim2.new(0.5, 0, 0.5, 30)
nameLbl.Size = UDim2.fromOffset(600, 40); nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.TextYAlignment = Enum.TextYAlignment.Top
nameLbl.Text = ""; nameLbl.Visible = false; nameLbl.Active = false; nameLbl.Parent = iGui
-- ---------- bars and dot are GUI frames (same way as the name), so they show on every executor ----------
local function mkFrame()
local f = Instance.new("Frame")
f.BorderSizePixel = 0; f.AnchorPoint = Vector2.new(0.5, 0.5); f.Visible = false; f.Active = false; f.Parent = iGui
local st = Instance.new("UIStroke")
st.Color = Color3.new(0, 0, 0); st.Thickness = 1; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = f
return f, st
end
local B, BS = {}, {}
for i = 1, 8 do B[i], BS[i] = mkFrame() end
local dot, dotS = mkFrame()
local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot
local function hideAll()
for i = 1, 8 do B[i].Visible = false end
dot.Visible = false
nameLbl.Visible = false
img.Visible = false
end
local t0, ang, imgAng, shown = tick(), 0, 0, false
local cc = RunService.RenderStepped:Connect(function(dt)
local active = X.on or X.name or X.img or X.spin or X.imgSpin or X.rbBars or X.rbDot or X.rbName or X.rbImg
if not active then
if shown then hideAll(); shown = false end
return
end
shown = true
local rb = Color3.fromHSV((tick() - t0) * X.rbSpd % 1, 0.9, 1)
local sc = X.scale / 100
if X.spin then ang = (ang + X.spd * dt) % 360 end
if X.imgSpin then imgAng = (imgAng + X.imgSpd * dt) % 360 end
local extent = 0
local total = X.rot + (X.shape == "X" and 45 or 0) + ang
local n = X.bars
local col = X.rbBars and rb or colorOf("Bars", "Bar Color", "#C8FF00")
for i = 1, 8 do
local f = B[i]
if X.showBars and i <= n then
local rot = total + (i - 1) * 360 / n
local a = math.rad(rot)
local mid = Vector2.new(math.sin(a), -math.cos(a)) * ((X.gap + X.len / 2) * sc)
f.Position = UDim2.new(0.5, mid.X, 0.5, mid.Y)
f.Size = UDim2.fromOffset(math.max(1, X.th * sc), math.max(1, X.len * sc))
f.Rotation = rot
f.BackgroundColor3 = col
f.BackgroundTransparency = X.barTr
BS[i].Enabled = X.outline and true or false
BS[i].Thickness = X.outTh
BS[i].Transparency = X.barTr
f.Visible = true
else
f.Visible = false
end
end
if X.showBars then extent = (X.gap + X.len) * sc end
if X.dot then
local d = math.max(2, X.dotSize * 2 * sc)
dot.Size = UDim2.fromOffset(d, d)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.BackgroundColor3 = X.rbDot and rb or colorOf("Dot", "Dot Color", "#C8FF00")
dot.BackgroundTransparency = X.dotTr
dotS.Enabled = X.dotOutline and true or false
dotS.Thickness = X.outTh
dotS.Transparency = X.dotTr
dot.Visible = true
else
dot.Visible = false
end
if X.img and X.imgAsset ~= "" then
local sz = X.imgSize * sc
img.Image = X.imgAsset
img.Size = UDim2.fromOffset(sz, sz)
img.Rotation = X.imgRot + imgAng
img.ImageColor3 = X.rbImg and rb or colorOf("Image ID Crosshair", "Image Tint", "#FFFFFF")
img.ImageTransparency = X.imgTr
img.Visible = true
extent = math.max(extent, sz / 2)
else
img.Visible = false
end
if X.name then
nameLbl.Text = X.text
nameLbl.TextSize = X.nsize
nameLbl.Font = FONT_ID[X.nfont] or Enum.Font.Code
nameLbl.TextColor3 = X.rbName and rb or colorOf("Name", "Name Color", "#C8FF00")
nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
nameLbl.TextStrokeTransparency = X.nout and 0 or 1
nameLbl.Position = UDim2.new(0.5, 0, 0.5, extent + X.noff)
nameLbl.Visible = true
else
nameLbl.Visible = false
end
end)
gui.Destroying:Connect(function()
cc:Disconnect()
pcall(function() iGui:Destroy() end)
end)
end)
if not okX then notify("Crosshair", "Failed to build: " .. tostring(errX), 6) end
end
do
local mv = addSub(mChar, "Movement", "Speed, jump, flight and more.")
local M = {ws = 50, jp = 100, fly = 100, ls = 60, lu = 20, ss = 50, ljMode = "Camera Look", jumpT = 0, nc = {},
slideSpd = 80, slideDur = 0.5, jas = 0.25, saj = 0.5, onlyMove = true, autoJump = true,
flyBtns = UIS.TouchEnabled and not UIS.KeyboardEnabled, slMode = ((UIS.TouchEnabled or UIS.GamepadEnabled) and not UIS.KeyboardEnabled) and "Button (Hold)" or "Keys (Ctrl+Shift)",
ljBtn = UIS.TouchEnabled and not UIS.KeyboardEnabled}
local function hum() local c = player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function grounded(h) return h.FloorMaterial ~= Enum.Material.Air end
mv.Section("Speed & Jump")
mv.Toggle("WalkSpeed", false, function(v)
M.wsOn = v
local h = hum()
if v then if h and not M.baseWs then M.baseWs = h.WalkSpeed end
elseif h then h.WalkSpeed = M.baseWs or 16; M.baseWs = nil end
end)
mv.Slider("WalkSpeed Value", 16, 250, 50, function(v) M.ws = v end)
mv.Toggle("Jump Power", false, function(v)
M.jpOn = v
local h = hum()
if v then
if h and not M.baseUse then M.baseUse = h.UseJumpPower; M.baseJp = h.JumpPower; M.baseJh = h.JumpHeight end
elseif h and M.baseUse ~= nil then
pcall(function() h.UseJumpPower = M.baseUse; h.JumpPower = M.baseJp; h.JumpHeight = M.baseJh end)
M.baseUse = nil
end
end)
mv.Slider("Jump Power Value", 30, 350, 100, function(v) M.jp = v end)
mv.Toggle("Infinite Double Jumps", false, function(v) M.inf = v end)
mv.Section("Slide")
mv.Toggle("Slide Speed", false, function(v) M.slideOn = v end)
mv.Slider("Slide Speed Value", 10, 300, 80, function(v) M.slideSpd = v end)
mv.Label("While sliding (Ctrl + Shift), any move key thrusts you forward.")
mv.Dropdown("Slide Activation", {"Keys (Ctrl+Shift)", "Button (Hold)", "Button (Toggle)", "Always On"},
((UIS.TouchEnabled or UIS.GamepadEnabled) and not UIS.KeyboardEnabled) and "Button (Hold)" or "Keys (Ctrl+Shift)", function(v)
M.slMode = v
local b = FX.MB.slide
if b then b.kind = (v == "Button (Toggle)") and "toggle" or "hold"; b.on = false; b.down = false; b.refresh() end
end)
mv.Keybind("Slide Key", "ButtonL3")
mv.Toggle("Auto Slide", false, function(v) M.autoSlide = v end)
mv.Toggle("Only While Moving", true, function(v) M.onlyMove = v end)
mv.Toggle("Jump After Slide", true, function(v) M.autoJump = v end)
mv.Slider("Slide Duration (s)", 0.1, 2, 0.5, function(v) M.slideDur = v end, 0.05)
mv.Slider("Jump After Slide Cooldown (s)", 0, 2, 0.25, function(v) M.jas = v end, 0.05)
mv.Slider("Slide After Jump Cooldown (s)", 0, 2, 0.5, function(v) M.saj = v end, 0.05)
mv.Section("Flight")
mv.Toggle("Flight", false, function(v) M.flyOn = v end)
mv.Slider("Flight Speed", 25, 500, 100, function(v) M.fly = v end)
mv.Dropdown("Flight Controls", {"Keys", "Buttons"}, (UIS.TouchEnabled and not UIS.KeyboardEnabled) and "Buttons" or "Keys", function(v) M.flyBtns = (v == "Buttons") end)
mv.Label("Fly where you look. Keys: W/A/S/D, Space up, Ctrl down. Buttons: on-screen UP / DOWN.")
mv.Section("Other")
mv.Toggle("Noclip", false, function(v)
M.noclip = v
if not v then for p in pairs(M.nc) do pcall(function() p.CanCollide = true end) end; M.nc = {} end
end)
mv.Toggle("Auto Strafe", false, function(v) M.strafe = v end)
mv.Slider("Auto Strafe Speed", 1, 200, 50, function(v) M.ss = v end)
mv.Section("Long Jump")
mv.Toggle("Long Jump", false, function(v) M.ljOn = v end)
mv.Keybind("Long Jump Key", "E")
mv.Dropdown("Long Jump Trigger", {"Key", "Button"}, (UIS.TouchEnabled and not UIS.KeyboardEnabled) and "Button" or "Key", function(v) M.ljBtn = (v == "Button") end)
mv.Dropdown("Direction", {"Camera Look", "Move Direction"}, "Camera Look", function(v) M.ljMode = v end)
mv.Slider("Force", 0, 300, 60, function(v) M.ls = v end)
mv.Slider("Upward Velocity", 0, 200, 20, function(v) M.lu = v end)
local flyUp = FX.MB.new("flyup", "UP", 0.88, 0.40)
local flyDn = FX.MB.new("flydown", "DOWN", 0.88, 0.60)
flyUp.want = function() return M.flyOn and M.flyBtns end
flyDn.want = flyUp.want
local slBtn = FX.MB.new("slide", "SLIDE", 0.76, 0.5)
FX.MB.slide = slBtn
slBtn.kind = (M.slMode == "Button (Toggle)") and "toggle" or "hold"
slBtn.want = function() return M.slideOn and (M.slMode == "Button (Hold)" or M.slMode == "Button (Toggle)") end
local function enforce()
local h, r, c = hum(), root(), cam()
if not (h and r) then return end
if M.wsOn then h.WalkSpeed = M.ws end
if M.jpOn then pcall(function() h.UseJumpPower = true; h.JumpPower = M.jp end) end
if M.flyOn and c then
local cf = c.CFrame
local look, right = cf.LookVector, cf.RightVector
local f, s, u = 0, 0, 0
if UIS:IsKeyDown(Enum.KeyCode.W) then f += 1 end
if UIS:IsKeyDown(Enum.KeyCode.S) then f -= 1 end
if UIS:IsKeyDown(Enum.KeyCode.D) then s += 1 end
if UIS:IsKeyDown(Enum.KeyCode.A) then s -= 1 end
if f == 0 and s == 0 then   -- touch / gamepad: project the move direction onto the camera
local md = h.MoveDirection
if md.Magnitude > 0.05 then
local fl, fr = Vector3.new(look.X, 0, look.Z), Vector3.new(right.X, 0, right.Z)
if fl.Magnitude > 0.01 then f = md:Dot(fl.Unit) end
if fr.Magnitude > 0.01 then s = md:Dot(fr.Unit) end
end
end
if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUp.down then u += 1 end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) or flyDn.down then u -= 1 end
local d = look * f + right * s + Vector3.new(0, u, 0)   -- full 3D look vector: look up = fly up
r.AssemblyLinearVelocity = (d.Magnitude > 1 and d.Unit or d) * M.fly
return
end
local slideActive = M.sliding or (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and UIS:IsKeyDown(Enum.KeyCode.LeftShift))
or M.slMode == "Always On" or (M.slMode == "Button (Hold)" and slBtn.down) or (M.slMode == "Button (Toggle)" and slBtn.on)
if M.slideOn and slideActive and c then
local hasInput = h.MoveDirection.Magnitude > 0.05 or UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A)
or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D)
if hasInput then
local lv = c.CFrame.LookVector
local flat = Vector3.new(lv.X, 0, lv.Z)
if flat.Magnitude > 0.01 then
local t = flat.Unit * M.slideSpd
local v = r.AssemblyLinearVelocity
r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
end
end
elseif M.wsOn and grounded(h) then
local md = h.MoveDirection
if md.Magnitude > 0.1 then
local v = r.AssemblyLinearVelocity
if Vector3.new(v.X, 0, v.Z).Magnitude < M.ws then
local t = md.Unit * M.ws
r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
end
end
end
if M.noclip and player.Character then
for _, p in ipairs(player.Character:GetDescendants()) do
if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false; M.nc[p] = true end
end
end
end
local c1 = RunService.Stepped:Connect(function()
local h, r = hum(), root()
if not (h and r) then return end
enforce()
local g = grounded(h)
if M.jpOn and M.wasG and not g and not M.flyOn then
local v = r.AssemblyLinearVelocity
if v.Y > 10 and (tick() - M.jumpT < 0.3 or UIS:IsKeyDown(Enum.KeyCode.Space)) and math.abs(v.Y - M.jp) > 2 then
r.AssemblyLinearVelocity = Vector3.new(v.X, M.jp, v.Z)
end
end
M.wasG = g
end)
local c2 = RunService.Heartbeat:Connect(function(dt)
local h, r = hum(), root()
if not (h and r) then return end
enforce()
if M.strafe and not M.flyOn and not grounded(h) then
local md = h.MoveDirection
if md.Magnitude > 0.05 then
local v = r.AssemblyLinearVelocity
local hv = Vector3.new(v.X, 0, v.Z)
local sp = hv.Magnitude
local cur = sp > 1 and hv.Unit or md.Unit
local dir = (cur + md.Unit * math.clamp(dt * 6, 0, 1)).Unit      -- steer toward where you aim/move
local ns = math.max(sp, math.min(M.ss, sp + M.ss * dt * 1.5))      -- and gain speed up to the strafe speed
r.AssemblyLinearVelocity = Vector3.new(dir.X * ns, v.Y, dir.Z * ns)
end
end
end)
local function onJump()
M.jumpT = tick()
local h, r = hum(), root()
if not (h and r) or M.flyOn then return end
if not grounded(h) then
if M.inf then
local jp = M.jpOn and M.jp or (h.UseJumpPower and h.JumpPower or math.sqrt(2 * workspace.Gravity * h.JumpHeight))
local v = r.AssemblyLinearVelocity
r.AssemblyLinearVelocity = Vector3.new(v.X, jp, v.Z)
pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
end
elseif M.jpOn then
task.delay(0.05, function()
local h2, r2 = hum(), root()
if h2 and r2 and M.jpOn and grounded(h2) then
local v = r2.AssemblyLinearVelocity
r2.AssemblyLinearVelocity = Vector3.new(v.X, M.jp, v.Z)
end
end)
end
end
local function longJump()
local h, r, c = hum(), root(), cam()
if not (h and r and c) then return end
local dir
if M.ljMode == "Move Direction" and h.MoveDirection.Magnitude > 0.05 then dir = h.MoveDirection
else dir = c.CFrame.LookVector * Vector3.new(1, 0, 1) end
if dir.Magnitude < 0.05 then dir = r.CFrame.LookVector * Vector3.new(1, 0, 1) end
r.AssemblyLinearVelocity = dir.Unit * M.ls + Vector3.new(0, M.lu, 0)
end
local ljB = FX.MB.new("longjump", "LONG\nJUMP", 0.76, 0.65)
ljB.kind = "tap"
ljB.onTap = function() if M.ljOn then longJump() end end
ljB.want = function() return M.ljOn and M.ljBtn end
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)
local VK = {[Enum.KeyCode.LeftControl] = 0xA2, [Enum.KeyCode.LeftShift] = 0xA0, [Enum.KeyCode.Space] = 0x20}
local function key(code, down)
local ok = false
if VIM then ok = pcall(function() VIM:SendKeyEvent(down, code, false, game) end) end
if not ok and VK[code] then
local f = down and keypress or keyrelease
if f then pcall(f, VK[code]) end
end
end
local function simJump()
local h = hum(); if not h then return end
M.jumpT = tick()
key(Enum.KeyCode.Space, true)
task.delay(0.06, function() key(Enum.KeyCode.Space, false) end)
task.delay(0.07, function()
local h2, r2 = hum(), root()
if h2 and r2 and grounded(h2) then
local jp = M.jpOn and M.jp or (h2.UseJumpPower and h2.JumpPower or math.sqrt(2 * workspace.Gravity * h2.JumpHeight))
local v = r2.AssemblyLinearVelocity
r2.AssemblyLinearVelocity = Vector3.new(v.X, jp, v.Z)
pcall(function() h2:ChangeState(Enum.HumanoidStateType.Jumping) end)
end
end)
end
local alive = true
local function waitFor(t)   -- false if auto slide was switched off while waiting
local t0 = os.clock()
while os.clock() - t0 < t do
if not (alive and M.autoSlide) then return false end
RunService.Heartbeat:Wait()
end
return alive and M.autoSlide
end
local function wantsMove(h)
return h.MoveDirection.Magnitude > 0.05 or UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A)
or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D)
end
task.spawn(function()
while alive do
RunService.Heartbeat:Wait()
local h, r = hum(), root()
if M.autoSlide and h and r and h.Health > 0 and not M.flyOn and grounded(h) and (not M.onlyMove or wantsMove(h)) then
M.sliding = true
key(Enum.KeyCode.LeftControl, true); key(Enum.KeyCode.LeftShift, true)
local still = waitFor(M.slideDur)
key(Enum.KeyCode.LeftControl, false); key(Enum.KeyCode.LeftShift, false)
M.sliding = false
if still and M.autoJump then
if waitFor(M.jas) then          -- cooldown: jump after slide
simJump()
waitFor(M.saj)              -- cooldown: slide after jump
end
elseif still then
waitFor(M.saj)
end
end
end
end)
local c3 = UIS.InputBegan:Connect(function(i, gp)
if gp then return end
if i.KeyCode == Enum.KeyCode.Space or i.KeyCode == Enum.KeyCode.ButtonA then onJump() end
if M.ljOn and i.KeyCode ~= Enum.KeyCode.Unknown
and i.KeyCode.Name == (CONFIG_VALUES["Character.Movement.Long Jump.Long Jump Key"] or "E") then longJump() end
end)
local c4 = UIS.JumpRequest:Connect(function()
if UIS.TouchEnabled and not UIS.KeyboardEnabled then onJump() end
end)
gui.Destroying:Connect(function()
alive = false; M.sliding = false
key(Enum.KeyCode.LeftControl, false); key(Enum.KeyCode.LeftShift, false)
c1:Disconnect(); c2:Disconnect(); c3:Disconnect(); c4:Disconnect()
local h = hum()
if h then
if M.wsOn then h.WalkSpeed = M.baseWs or 16 end
if M.baseUse ~= nil then pcall(function() h.UseJumpPower = M.baseUse; h.JumpPower = M.baseJp; h.JumpHeight = M.baseJh end) end
end
for p in pairs(M.nc) do pcall(function() p.CanCollide = true end) end
end)
end
end -- visual/character scope
do
local function hex3(h) return Color3.fromHex(h) end
local COMMUNITY = {
["Community 1"]={Lf="136187602071243",Rt="88538282136851",Up="118729499049091",Dn="131058158470335",Bk="129073306650663",Ft="97935277643669"},
["Community 2"]={Up="103036335526795",Dn="88097402230894",Lf="125043250825444",Rt="92709807443691",Ft="108214970334646",Bk="82508188595913"},
["Community 3"]={Up="84485882938666",Dn="130132980727727",Lf="86607637878110",Rt="93774890395822",Ft="87463796581591",Bk="74755236867819"},
["Community 4"]={Bk="17279854976",Dn="17279856318",Ft="17279858447",Lf="17279860360",Rt="17279862234",Up="17279864507"},
["Community 5"]={Up="90647585604016",Dn="123267172798726",Lf="92915003993753",Rt="131165128505393",Ft="70590224924610",Bk="88651922011315"},
["Community 6"]={Bk="12635309703",Dn="12635311686",Ft="12635312870",Lf="12635313718",Rt="12635315817",Up="12635316856"},
}
local PRESETS = {
["Aesthetic"]={Stars=3000,Up="1417494643",MoonTex=6444320592,Ft="1417494253",Bk="1417494030",Dn="1417494146",SunTex=8281961896,Sun=0,Lf="1417494402",Rt="1417494499",Moon=0},
["Aesthetic 2"]={Stars=3000,Up="600835177",MoonTex=6444320592,Bk="600830446",Ft="600832720",Lf="600886090",SunTex=8281961896,Sun=0,Dn="600831635",Rt="600833862",Moon=0},
["Aesthetic 3"]={Stars=500,Up="151165227",MoonTex=6444320592,Lf="151165191",Bk="151165214",Ft="151165224",SunTex=8281961896,Sun=0,Dn="151165197",Rt="151165206",Moon=0},
["Aesthetic Mountains"]={Stars=3000,Up="15470207755",MoonTex=6444320592,Lf="15470202648",Bk="15470198023",Ft="15470200128",SunTex=6196665106,Sun=21,Dn="15470151245",Rt="15470204862",Moon=11},
["Alien"]={Stars=0,Up="159248176",MoonTex=6444320592,Ft="159248187",Bk="159248188",Dn="159248183",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="159248173",Rt="159248192",Moon=0},
["Ame"]={Stars=3000,Moon=11,Up="160186148",MoonTex=6444320592,Ft="160186027",Bk="160185927",Dn="160185945",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="160186075",Rt="160186126"},
["Antartica"]={Stars=3000,Up="2118766003",MoonTex="rbxasset://sky/moon.jpg",Ft="2118765204",Bk="2118763079",Dn="2118766919",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="2118764070",Rt="2118761853"},
["Art"]={Stars=3000,Moon=11,Up="9831769868",MoonTex=6444320592,Ft="9831766232",Bk="9831762777",Dn="9831764283",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="9831768023",Rt="9831768909"},
["Beach"]={Stars=0,Up="173380790",MoonTex=6444320592,Dn="173380627",Bk="173380597",Ft="173380642",SunTex=8281961896,Sun=21,Lf="173380671",Rt="173380774",Moon=11},
["Better Night"]={Stars=3000,Up="15470303050",Ft="15470294431",Bk="15470289121",Dn="15470291746",Lf="15470297162",Rt="15470299887"},
["Better Night 2"]={Stars=3000,Bk="248431616",Up="248431605",Dn="248431677",MoonTex=6444320592,Lf="248431686",SunTex=8281961896,Sun=0,Ft="248431598",Rt="248431611",Moon=1.5},
["Better Night 3"]={Stars=500,Up="2670644331",MoonTex=1075087760,Lf="2670643070",Bk="2670643994",Ft="2670643214",SunTex=6196665106,Sun=21,Dn="2670643365",Rt="2670644173",Moon=1.5},
["Better Sky"]={Stars=3000,Up="591059642",MoonTex=6444320592,Lf="591057861",Bk="591058823",Ft="591058104",SunTex=6196665106,Sun=0,Dn="591059876",Rt="591057625",Moon=0},
["Blizzard"]={Stars=3000,Up="16653228333",MoonTex=6444320592,Bk="16653221738",Ft="16653224051",Dn="16653222701",SunTex=6196665106,Sun=21,Lf="16653225849",Rt="16653227200",Moon=0},
["Blue Clouds"]={Stars=3000,Up="591059642",MoonTex=6444320592,Lf="591057861",Bk="591058823",Ft="591058104",SunTex=6196665106,Sun=0,Dn="591059876",Rt="591057625",Moon=0},
["Blue Planet"]={Stars=3000,Up="16889004122",Lf="16888998994",MoonTex=6444320592,Dn="16888991855",Bk="16888989874",SunTex=8281961896,Sun=21,Ft="16888995219",Rt="16889000916",Moon=0},
["Blue Space"]={Stars=3000,Up="16876552681",MoonTex=6444320592,Lf="16876548320",Bk="16876541778",Ft="16876546384",SunTex=8281961896,Sun=21,Dn="16876543880",Rt="16876550345",Moon=0},
["Cloudy"]={Stars=3000,Up="4495867486",Ft="4495865458",Bk="4495864450",Dn="4495864887",Lf="4495866035",Rt="4495866584"},
["Dark Clouds"]={Stars=0,Up="190477146",Dn="190477222",MoonTex=6444320592,Lf="190477185",Bk="190477248",SunTex=8281961896,Sun=0,Ft="190477200",Rt="190477166",Moon=1.5},
["Darkish Pink"]={Stars=3000,Up="570555929",MoonTex=6444320592,Lf="570555840",Dn="570555964",Bk="570555736",SunTex=8281961896,Sun=21,Ft="570555800",Rt="570555882",Moon=11},
["Dark Mountains"]={Stars=3000,Up="5098819127",MoonTex=6444320592,Bk="5098814730",Ft="5098815653",Dn="5098815227",SunTex=6196665106,Sun=0,Lf="5098816155",Rt="5098820352",Moon=0},
["Dawn"]={Stars=3000,Moon=11,Up="250381047",Ft="250380916",Bk="250381017",Dn="254156892",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="250380953",Rt="250380985"},
["Fake Clouds"]={Stars=3000,Up="8496897504",MoonTex=6444320592,Dn="8496896250",Bk="8496892810",Ft="8496892810",SunTex=8281961896,Sun=0,Lf="8496892810",Rt="8496892810",Moon=0},
["Flame"]={Stars=3000,Up="6286790025",MoonTex=6444320592,Lf="6286785801",Bk="6286780109",Ft="6286784186",SunTex=8281961896,Sun=21,Dn="6286782353",Rt="6286788245",Moon=0},
["Flaming Sunset"]={Stars=3000,Up="415688354",MoonTex=6444320592,Bk="415688378",Ft="415688242",Dn="415688193",SunTex=6196665106,Sun=0,Lf="415688310",Rt="415688274",Moon=0},
["FPSBoost"]={Stars=3000,Up="11457548274",MoonTex=6444320592,Ft="11457548274",Lf="11457548274",Dn="11457548274",SunTex=8281961896,Sun=0,Bk="11457548274",Rt="11457548274",Moon=0},
["Funny Storm"]={Stars=3000,Up="6280942402",MoonTex=6444320592,Dn="6280935347",Lf="6280938749",Bk="6280934001",SunTex=8281961896,Sun=21,Ft="6280936575",Rt="6280940989",Moon=0},
["Galaxy"]={Stars=3000,Up="159454288",MoonTex=6444320592,Ft="159454293",Lf="159454293",Dn="159454296",SunTex=8281961896,Sun=0,Bk="159454299",Rt="159454293",Moon=0},
["Galaxy 2"]={Stars=500,Up="14164405298",MoonTex=6444320592,Lf="14164398493",Bk="14164368678",Ft="14164389230",SunTex=8281961896,Sun=0,Dn="14164386126",Rt="14164402782",Moon=0},
["Galaxy 3"]={Stars=3000,Up="14543371676",MoonTex=6444320592,Ft="14543257810",Bk="14543264135",Dn="14543358958",SunTex=8281961896,Sun=0,Lf="14543275895",Rt="14543280890",Moon=0},
["Green Haze"]={Up="160193458",Bk="160193404",Ft="160193461",Sun=0,Lf="160193469",Rt="160193463",Dn="160193466"},
["Hell"]={Stars=3000,Up="11730857150",MoonTex=6444320592,Bk="11730840088",Ft="11730849615",Lf="11730852920",SunTex=8281961896,Sun=0,Dn="11730842997",Rt="11730855491",Moon=11},
["Lunar"]={Stars=3000,Up="179724054",MoonTex="rbxasset://sky/moon.jpg",Ft="179724018",Bk="179723991",Dn="179724005",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="179724029",Rt="179724037",Moon=0},
["Lunar Night"]={Stars=0,Up="187712111",MoonTex=6444320592,Bk="187713366",Ft="187712836",Lf="187713755",SunTex=8281961896,Sun=0,Dn="187712428",Rt="187714525",Moon=0},
["Lunar Night 2"]={Stars=3000,Up="14365026442",MoonTex=6444320592,Dn="14365026242",Lf="14365025904",Bk="14365026085",SunTex=8281961896,Sun=21,Ft="14365025735",Rt="14365025444",Moon=0},
["Magenta Orange"]={Stars=3000,Up="566616187",MoonTex=6444320592,Ft="566616141",Bk="566616113",Dn="566616232",SunTex=8281961896,Sun=0,Lf="566616044",Rt="566616082",Moon=0},
["Midnight"]={Stars=3000,Up="154185031",MoonTex="rbxasset://sky/moon.jpg",Ft="154185021",Bk="154185004",Dn="154184960",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="154184943",Rt="154184972",Moon=0},
["Milkyway"]={Stars=3000,Up="137817405681365",MoonTex=6444320592,Ft="104400530594543",Bk="129876530632297",Dn="108406529909981",SunTex=8281961896,Sun=0,Lf="73372229972523",Rt="87408857415924",Moon=0},
["Moon"]={Stars=3000,Up="17489393055",MoonTex="rbxasset://sky/moon.jpg",Ft="17489388310",Bk="17489386489",Dn="17489387417",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="17489389632",Rt="17489391101"},
["Mountains"]={Stars=3000,Up="15359412677",Lf="15359411633",MoonTex=6444320592,Dn="15359411132",Bk="15359410490",SunTex=8281961896,Sun=21,Ft="15359412131",Rt="15359417656",Moon=0},
["Nebula"]={Stars=3000,Up="5260824661",MoonTex=6444320592,Lf="5260800833",Dn="5260653793",Bk="5260808177",SunTex=8281961896,Sun=0,Ft="5260817288",Rt="5260811073",Moon=0},
["Nebula 2"]={Stars=3000,Up="16932810138",MoonTex=6444320592,Ft="16932800523",Lf="16932803722",Dn="16932797813",SunTex=8281961896,Sun=0,Bk="16932794531",Rt="16932806825",Moon=0},
["Nebula 3"]={Stars=3000,Up="17839226876",MoonTex=6444320592,Bk="17839210699",Ft="17839218166",Lf="17839220800",SunTex=8281961896,Sun=0,Dn="17839215896",Rt="17839223605",Moon=0},
["Nebula 4"]={Stars=3000,Up="17103639457",MoonTex=6444320592,Dn="17103622190",Bk="17103618635",Ft="17103624898",SunTex=8281961896,Sun=0,Lf="17103628153",Rt="17103636666",Moon=0},
["Nebula 5"]={Stars=3000,Up="17124369657",MoonTex=6444320592,Dn="17124359797",Bk="17124357467",Ft="17124362093",SunTex=8281961896,Sun=0,Lf="17124365127",Rt="17124367200",Moon=0},
["Nebula 6"]={Stars=3000,Up="16694204069",MoonTex=6444320592,Lf="16694197080",Dn="16694190947",Bk="16694187412",SunTex=8281961896,Sun=21,Ft="16694194795",Rt="16694200892",Moon=11},
["Nether World"]={Stars=3000,Up="14365019327",MoonTex=6444320592,Ft="14365018399",Lf="14365018705",Dn="14365023350",SunTex=8281961896,Sun=0,Bk="14365019002",Rt="14365018143",Moon=0},
["New York"]={Stars=3000,Up="11333967970",MoonTex=6444320592,Bk="11333973069",Ft="11333964303",Dn="11333969768",SunTex=6196665106,Sun=0,Lf="11333971332",Rt="11333982864",Moon=0},
["Night Mountains"]={Stars=3000,Moon=11,Up="264907379",MoonTex="rbxasset://sky/moon.jpg",Ft="264909420",Bk="264908339",Dn="264907909",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="264909758",Rt="264908886"},
["Orange"]={Stars=3000,Up="150939082",MoonTex=6444320592,Dn="150939038",Bk="150939022",Ft="150939047",SunTex=8281961896,Sun=0,Lf="150939056",Rt="150939063",Moon=0},
["Over Planet"]={Stars=3000,Up="165052345",MoonTex=6444320592,Lf="165052365",Dn="165052286",Bk="165052268",SunTex=8281961896,Sun=21,Ft="165052328",Rt="165052306",Moon=11},
["Pastel"]={Stars=3000,Up="2128462236",MoonTex=6444320592,Dn="2128462480",Bk="2128458653",Ft="2128458653",SunTex=8281961896,Sun=0,Lf="2128462027",Rt="2128462027",Moon=0},
["Pink"]={Stars=3000,Up="271077958",MoonTex=6444320592,Lf="271042310",Bk="271042516",Ft="271042556",SunTex=8281961896,Sun=0,Dn="271077243",Rt="271042467",Moon=0},
["Pink Art"]={Stars=3000,Up="79190209626172",Ft="104560113223878",Lf="80395333901607",Dn="78865378050055",Sun=21,Bk="71607054149497",Rt="87570388049514",Moon=0},
["Pinkie"]={Stars=0,Up="11554996247",MoonTex=6444320592,Dn="11555013415",Bk="11555017034",Ft="11555010145",SunTex=8281961896,Sun=0,Lf="11555006545",Rt="11555000712",Moon=1.5},
["Pink Mountains"]={Stars=3000,Up="160188588",Ft="160188609",Lf="160188589",Dn="160188614",Sun=21,Bk="160188495",Rt="160188597",Moon=0},
["Purple"]={Stars=3000,Up="8539981085",MoonTex=6444320592,Bk="8539982183",Ft="8539981721",Lf="8539981424",SunTex=8281961896,Sun=0,Dn="8539981943",Rt="8539980766",Moon=0},
["Purple 2"]={Stars=3000,Up="8107849791",MoonTex=6444320592,Bk="8107841671",Ft="8107841671",Dn="6444884785",SunTex=6196665106,Sun=11,Lf="8107841671",Rt="8107841671",Moon=0},
["Purple 3"]={Stars=3000,Up="433274285",MoonTex=6444320592,Ft="433274131",Lf="433274370",Dn="433274194",SunTex=8281961896,Sun=0,Bk="433274085",Rt="433274429",Moon=0},
["Purple Clouds"]={Stars=3000,Up="570557727",MoonTex=6444320592,Dn="570557775",Lf="570557620",Bk="570557514",SunTex=8281961896,Sun=21,Ft="570557559",Rt="570557672",Moon=0},
["Purple Mountains"]={Stars=3000,Up="17901365106",MoonTex=6444320592,Lf="17901359687",Dn="17901366771",Bk="17901353811",SunTex=8281961896,Sun=0,Ft="17901356262",Rt="17901362326",Moon=0},
["Purple Night"]={Stars=3000,Up="5084576400",MoonTex=6444320592,Ft="5260817288",Bk="5260808177",Dn="5260653793",SunTex=8281961896,Sun=0,Lf="5260800833",Rt="5260800833",Moon=0},
["Purple Planet"]={Stars=3000,Up="16262366016",MoonTex=6444320592,Ft="16262360469",Lf="16262362003",Dn="16262358026",SunTex=8281961896,Sun=21,Bk="16262356578",Rt="16262363873",Moon=0},
["Purple Space"]={Stars=3000,Up="15983964246",MoonTex=6444320592,Lf="15983967420",Bk="15983968922",Ft="5260817288",SunTex=8281961896,Sun=0,Dn="15983966825",Rt="15983966246",Moon=0},
["Realistic"]={Stars=3000,Up="402560052",MoonTex="rbxasset://sky/moon.jpg",Ft="402559953",Bk="402559900",Dn="402559927",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="402559983",Rt="402560019",Moon=0},
["Red Night"]={Stars=3000,Up="401664936",MoonTex=6444320592,Bk="401664839",Ft="401664960",Lf="401664881",SunTex=8281961896,Sun=0,Dn="401664862",Rt="401664901",Moon=0},
["Retro"]={Stars=3000,Up="16642401907",MoonTex="rbxasset://sky/moon.jpg",Ft="16642398372",Bk="16642396302",Dn="16642397027",SunTex="rbxasset://sky/sun.jpg",Sun=21,Lf="16642399309",Rt="16642400745",Moon=0},
["Space"]={Stars=3000,Up="166510114",MoonTex=6444320592,Dn="166510057",Bk="166509999",Ft="166510116",SunTex=8281961896,Sun=0,Lf="166510092",Rt="166510131",Moon=0},
["Space 2"]={Stars=3000,Up="11844053742",MoonTex=11844121592,Bk="11844076072",Dn="11844069700",Ft="11844067209",Sun=11,Lf="11844063543",Rt="11844058446",Moon=20},
["Storm"]={Up="1618913654",MoonTex=1075087760,Ft="1618913244",Bk="1618912481",Dn="1618913943",SunTex=1084351190,Sun=0,Lf="1618912849",Rt="1618911568",Moon=0},
["Valentines"]={Stars=3000,Up="11427771954",Ft="11427769401",Lf="11427769401",Dn="11427770685",Sun=21,Bk="11427769401",Rt="11427769401",Moon=0},
["Winter"]={Stars=3000,Up="155674931",MoonTex=6444320592,Bk="155657655",Ft="155657609",Lf="155657671",SunTex=8281961896,Sun=21,Dn="155674246",Rt="155657619",Moon=11},
}
local custom = CONFIG_VALUES["World.CustomSkies"]
if type(custom) ~= "table" then custom = {}; CONFIG_VALUES["World.CustomSkies"] = custom end
local W = {}
local function newFx(class)
local e = Instance.new(class); e.Name = "1Mag" .. class; e.Enabled = false; e.Parent = Lighting; return e
end
local bloom, cc, dof = newFx("BloomEffect"), newFx("ColorCorrectionEffect"), newFx("DepthOfFieldEffect")
local rays = newFx("SunRaysEffect")
local fxList = {bloom, cc, dof, rays}
local orig = {Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime,
Brightness = Lighting.Brightness, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
FogColor = Lighting.FogColor, ExposureCompensation = Lighting.ExposureCompensation}
for _, prop in ipairs({"ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
"GeographicLatitude", "ShadowSoftness", "LightingStyle", "TonemapperPreset", "PrioritizeLightingQuality", "ShadowColor"}) do
local ok, v = pcall(function() return Lighting[prop] end)
if ok and v ~= nil then orig[prop] = v end
end
local mySky = Instance.new("Sky"); mySky.Name = "1MagSky"
local stash, skyOn, curSky = {}, false, nil
local function aid(x) x = tostring(x); return x:match("^%d+$") and ("rbxassetid://" .. x) or x end
local function applySky(p)
if not p then return end
curSky = p
mySky.SkyboxBk = aid(p.Bk); mySky.SkyboxDn = aid(p.Dn); mySky.SkyboxFt = aid(p.Ft)
mySky.SkyboxLf = aid(p.Lf); mySky.SkyboxRt = aid(p.Rt); mySky.SkyboxUp = aid(p.Up)
mySky.StarCount = W.stars or tonumber(p.Stars) or 3000
mySky.SunAngularSize = W.sunSize or tonumber(p.Sun) or 21
mySky.MoonAngularSize = tonumber(p.Moon) or 11
mySky.SunTextureId = p.SunTex and aid(p.SunTex) or "rbxasset://sky/sun.jpg"
mySky.MoonTextureId = p.MoonTex and aid(p.MoonTex) or "rbxasset://sky/moon.jpg"
end
local function stashOthers()
for _, c in ipairs(Lighting:GetChildren()) do
if c:IsA("Sky") and c ~= mySky then stash[#stash + 1] = c; c.Parent = nil end
end
end
local function skyEnable(v)
skyOn = v
if v then stashOthers(); mySky.Parent = Lighting
else
mySky.Parent = nil
for _, s in ipairs(stash) do pcall(function() s.Parent = Lighting end) end
stash = {}
end
end
local function findSky(name) return custom[name] or COMMUNITY[name] or PRESETS[name] end
local function skyNames()
local out = {}
for n in pairs(COMMUNITY) do out[#out + 1] = n end
table.sort(out)
local rest = {}
for n in pairs(custom) do rest[#rest + 1] = "[Mine] " .. n end
for n in pairs(PRESETS) do rest[#rest + 1] = n end
table.sort(rest)
for _, n in ipairs(rest) do out[#out + 1] = n end
return out
end
local function lookup(name)
if type(name) == "string" and name:sub(1, 7) == "[Mine] " then return custom[name:sub(8)] end
return findSky(name)
end
local lt = addSub(mWorld, "Lighting", "Time, brightness, ambient, fog and shadows.")
lt.Section("Lighting")
lt.Toggle("Ambient", false, function(v) W.amb = v; if not v then Lighting.Ambient = orig.Ambient; Lighting.OutdoorAmbient = orig.OutdoorAmbient end end)
lt.Color("Indoor Ambient", "#3BCBFF")
lt.Color("Outdoor Ambient", "#01668B")
lt.Toggle("Clock Time", false, function(v) W.clock = v; if not v then Lighting.ClockTime = orig.ClockTime end end)
lt.Slider("Time", 0, 24, 14, function(v) W.time = v end, 0.1)
lt.Toggle("Brightness", false, function(v) W.bri = v; if not v then Lighting.Brightness = orig.Brightness end end)
lt.Slider("Brightness Value", 0, 10, 2, function(v) W.briv = v end, 0.1)
lt.Toggle("Exposure", false, function(v) W.exp = v; if not v then Lighting.ExposureCompensation = orig.ExposureCompensation end end)
lt.Slider("Exposure Value", -5, 5, 0, function(v) W.expv = v end, 0.1)
lt.Toggle("Color Shift", false, function(v) W.cs = v; if not v then Lighting.ColorShift_Top = orig.ColorShift_Top; Lighting.ColorShift_Bottom = orig.ColorShift_Bottom end end)
lt.Color("Color Shift Top", "#64A0FF")
lt.Color("Color Shift Bottom", "#14285A")
lt.Toggle("Environment Diffuse Scale", false, function(v) W.dif = v; if not v and orig.EnvironmentDiffuseScale then Lighting.EnvironmentDiffuseScale = orig.EnvironmentDiffuseScale end end)
lt.Slider("Diffuse Scale", 0, 1, 0, function(v) W.difv = v end, 0.01)
lt.Toggle("Environment Specular Scale", false, function(v) W.spec = v; if not v and orig.EnvironmentSpecularScale then Lighting.EnvironmentSpecularScale = orig.EnvironmentSpecularScale end end)
lt.Slider("Specular Scale", 0, 1, 0, function(v) W.specv = v end, 0.01)
lt.Section("Fog & Shadows")
lt.Toggle("Fog", false, function(v) W.fog = v; if not v then Lighting.FogStart = orig.FogStart; Lighting.FogEnd = orig.FogEnd; Lighting.FogColor = orig.FogColor end end)
lt.Slider("Fog Start", 0, 5000, 0, function(v) W.fs = v end, 10)
lt.Slider("Fog End", 0, 10000, 3000, function(v) W.fe = v end, 50)
lt.Color("Fog Color", "#B070FF")
lt.Toggle("Disable Global Shadows", false, function(v) W.sh = v; if not v then Lighting.GlobalShadows = orig.GlobalShadows end end)
lt.Toggle("Geographic Latitude", false, function(v) W.lat = v; if not v and orig.GeographicLatitude then Lighting.GeographicLatitude = orig.GeographicLatitude end end)
lt.Slider("Latitude", -90, 90, 41.733, function(v) W.latv = v end, 0.001)
lt.Toggle("Shadow Softness", false, function(v) W.soft = v; if not v and orig.ShadowSoftness then Lighting.ShadowSoftness = orig.ShadowSoftness end end)
lt.Slider("Softness", 0, 1, 0.5, function(v) W.softv = v end, 0.01)
lt.Toggle("Lighting Style", false, function(v) W.sty = v; if not v and orig.LightingStyle then Lighting.LightingStyle = orig.LightingStyle end end)
lt.Dropdown("Style", {"Realistic", "Soft"}, "Realistic", function(v) W.styv = v end)
lt.Toggle("Shadow Color", false, function(v) W.shc = v; if not v and orig.ShadowColor then pcall(function() Lighting.ShadowColor = orig.ShadowColor end) end end)
lt.Color("Shadow Color Value", "#B3B3B8")
lt.Toggle("Prioritize Lighting Quality", false, function(v) W.plq = v; if not v and orig.PrioritizeLightingQuality ~= nil then Lighting.PrioritizeLightingQuality = orig.PrioritizeLightingQuality end end)
local sk = addSub(mWorld, "Skybox", "Skybox presets, community skies and your own.")
sk.Section("Skybox")
sk.Toggle("Enable Skybox", false, function(v) skyEnable(v); if v and curSky then applySky(curSky) end end)
local names = skyNames()
local dd = sk.Dropdown("Preset", names, "Community 1", function(n)
local p = lookup(n); if p then applySky(p) end
end)
do -- search box next to the preset dropdown
local box = make("TextBox", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -134, 0, 5),
Size = UDim2.fromOffset(150, 24), Text = "", PlaceholderText = "search skybox...", PlaceholderColor3 = T.Dim,
FontFace = F_BOLD, TextSize = 17, TextColor3 = T.Text, ClearTextOnFocus = false, ZIndex = 6}, dd.Frame)
corner(box, 6); stroke(box, T.Border, 1, 0.4)
box:GetPropertyChangedSignal("Text"):Connect(function()
local q, res = string.lower(box.Text), {}
for _, n in ipairs(skyNames()) do if q == "" or string.find(string.lower(n), q, 1, true) then res[#res + 1] = n end end
dd:SetOptions(res)
if q ~= "" and #res > 0 then dd.Open(true) end
end)
end
sk.Button("Random Skybox", function()
local all = skyNames(); local n = all[math.random(#all)]
dd:Set(n); if not skyOn then W.pendingEnable = true end
notify("Skybox", n, 2)
end)
sk.Slider("Sun Size", 0, 60, 21, function(v) W.sunSize = v; if curSky then mySky.SunAngularSize = v end end)
sk.Slider("Star Count", 0, 5000, 3000, function(v) W.stars = v; if curSky then mySky.StarCount = v end end, 50)
local cs = addSub(mWorld, "Custom Sky", "Build your own skybox from six image IDs.")
cs.Section("Face IDs (number or rbxassetid://...)")
local faces = {}
for _, f in ipairs({{"Up", "Up"}, {"Down", "Dn"}, {"Front", "Ft"}, {"Back", "Bk"}, {"Left", "Lf"}, {"Right", "Rt"}}) do
faces[f[2]] = cs.TextBox(f[1] .. " Face", "image id")
end
local function readFaces()
local p = {}
for k, tb in pairs(faces) do
local v = (tb.Get() or ""):gsub("%s", "")
if v == "" then return nil, k end
p[k] = v
end
return p
end
cs.Section("Actions")
cs.Button("Apply Custom Skybox", function()
local p, missing = readFaces()
if not p then notify("Custom Sky", "Missing a face: " .. tostring(missing), 2.5); return end
applySky(p); skyEnable(true); notify("Custom Sky", "Applied", 2)
end)
local saveName = cs.TextBox("Save As Name", "my sky")
cs.Button("Save To My Skyboxes", function()
local p = readFaces(); local n = (saveName.Get() or ""):gsub("[^%w _%-]", "")
if not p or n == "" then notify("Custom Sky", "Fill all 6 faces and a name", 2.5); return end
custom[n] = p; dd:SetOptions(skyNames()); notify("Custom Sky", "Saved as [Mine] " .. n, 2.5)
end)
cs.Button("Remove Saved (by name)", function()
local n = (saveName.Get() or ""):gsub("[^%w _%-]", "")
if custom[n] then custom[n] = nil; dd:SetOptions(skyNames()); notify("Custom Sky", "Removed " .. n, 2) else notify("Custom Sky", "No saved sky with that name", 2) end
end)
local gr = addSub(mWorld, "Effects", "Bloom, atmosphere, colour grading, depth of field.")
local atmo, atmoMade, atmoOrig
gr.Section("Bloom")
gr.Toggle("Bloom", false, function(v) bloom.Enabled = v end)
gr.Slider("Bloom Intensity", 0, 100, 40, function(v) bloom.Intensity = v / 100 end)
gr.Slider("Bloom Size", 0, 56, 24, function(v) bloom.Size = v end)
gr.Slider("Bloom Threshold", 0, 5, 1, function(v) bloom.Threshold = v end, 0.05)
gr.Section("Atmosphere (haze & glare)")
gr.Toggle("Atmosphere", false, function(v) W.atmoOn = v end)
gr.Slider("Density", 0, 100, 35, function(v) W.aDen = v / 100 end)
gr.Slider("Haze", 0, 100, 15, function(v) W.aHaze = v / 10 end)
gr.Slider("Glare", 0, 100, 40, function(v) W.aGlare = v / 10 end)
gr.Slider("Offset", 0, 100, 25, function(v) W.aOff = v / 100 end)
gr.Color("Atmosphere Color", "#C8AA6C")
gr.Color("Atmosphere Decay", "#5C3C0E")
gr.Section("Colour Grading")
gr.Toggle("Colour Correction", false, function(v) cc.Enabled = v end)
gr.Slider("Saturation", -100, 100, 15, function(v) cc.Saturation = v / 100 end)
gr.Slider("Contrast", -100, 100, 10, function(v) cc.Contrast = v / 100 end)
gr.Slider("Colour Brightness", -50, 50, 0, function(v) cc.Brightness = v / 100 end)
gr.Color("Tint", "#FFFFFF")
gr.Section("Depth Of Field")
gr.Toggle("Depth Of Field", false, function(v) dof.Enabled = v end)
gr.Slider("Focus Distance", 1, 300, 60, function(v) dof.FocusDistance = v end)
gr.Slider("DOF Strength", 0, 100, 30, function(v) dof.FarIntensity = v / 100 end)
gr.Section("Colour Grading Preset")
gr.Toggle("Color Grading", false, function(v) W.tone = v; if not v and orig.TonemapperPreset then Lighting.TonemapperPreset = orig.TonemapperPreset end end)
gr.Dropdown("Tonemapper Preset", {"Default", "Retro"}, "Default", function(v) W.tonev = v end)
gr.Section("Sun Rays")
gr.Toggle("Sun Rays", false, function(v) rays.Enabled = v end)
gr.Slider("Sun Rays Intensity", 0, 1, 0.25, function(v) rays.Intensity = v end, 0.01)
gr.Slider("Spread", 0, 1, 1, function(v) rays.Spread = v end, 0.01)
gr.Section("Stretched Resolution")
gr.Toggle("Stretched Resolution", false, function(v) W.strOn = v end)
gr.Slider("X Ratio", 0.01, 1, 1, function(v) W.strX = v end, 0.01)
gr.Slider("Y Ratio", 0.01, 1, 1, function(v) W.strY = v end, 0.01)
gr.Section("Ambience")
gr.Toggle("Ambience", false, function(v) W.ambOn = v end)
gr.TextBox("Custom Sound (ID or URL)", "sound id or url")
gr.Slider("Ambience Volume", 0, 1.5, 1, function(v) W.ambVol = v end, 0.05)
local ambSnd = Instance.new("Sound"); ambSnd.Name = "1MagAmbience"; ambSnd.Looped = true; ambSnd.Parent = SoundService
RunService:BindToRenderStep("1MagStretch", Enum.RenderPriority.Last.Value, function()
if not W.strOn then return end
local cam = workspace.CurrentCamera
if cam then cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, W.strX or 1, 0, 0, 0, W.strY or 1, 0, 0, 0, 1) end
end)
local function ensureAtmo()
if atmo and atmo.Parent then return atmo end
atmo = Lighting:FindFirstChildOfClass("Atmosphere")
if atmo then
atmoOrig = {Density = atmo.Density, Haze = atmo.Haze, Glare = atmo.Glare, Color = atmo.Color, Decay = atmo.Decay, Offset = atmo.Offset}; atmoMade = false
else
atmo = Instance.new("Atmosphere"); atmo.Name = "1MagAtmosphere"; atmo.Parent = Lighting; atmoMade = true
end
return atmo
end
local lastAtmo = false
local loop = RunService.RenderStepped:Connect(function()
for _, fx in ipairs(fxList) do if fx.Parent ~= Lighting then fx.Parent = Lighting end end
if W.pendingEnable then W.pendingEnable = nil; skyEnable(true); if curSky then applySky(curSky) end end
if skyOn then
if mySky.Parent ~= Lighting then mySky.Parent = Lighting end
for _, c in ipairs(Lighting:GetChildren()) do
if c:IsA("Sky") and c ~= mySky then stash[#stash + 1] = c; c.Parent = nil end
end
end
if W.amb then
Lighting.Ambient = hex3(CONFIG_VALUES["World.Lighting.Lighting.Indoor Ambient"] or "#3BCBFF")
Lighting.OutdoorAmbient = hex3(CONFIG_VALUES["World.Lighting.Lighting.Outdoor Ambient"] or "#01668B")
end
if W.cs then
Lighting.ColorShift_Top = hex3(CONFIG_VALUES["World.Lighting.Lighting.Color Shift Top"] or "#64A0FF")
Lighting.ColorShift_Bottom = hex3(CONFIG_VALUES["World.Lighting.Lighting.Color Shift Bottom"] or "#14285A")
end
if W.dif and W.difv then Lighting.EnvironmentDiffuseScale = W.difv end
if W.spec and W.specv then Lighting.EnvironmentSpecularScale = W.specv end
if W.lat and W.latv then Lighting.GeographicLatitude = W.latv end
if W.soft and W.softv then Lighting.ShadowSoftness = W.softv end
if W.sty and W.styv then pcall(function() Lighting.LightingStyle = Enum.LightingStyle[W.styv] end) end
if W.shc then pcall(function() Lighting.ShadowColor = hex3(CONFIG_VALUES["World.Lighting.Fog & Shadows.Shadow Color Value"] or "#B3B3B8") end) end
if W.plq then Lighting.PrioritizeLightingQuality = true end
if W.tone and W.tonev then pcall(function() Lighting.TonemapperPreset = Enum.TonemapperPreset[W.tonev] end) end
if W.ambOn then
local id = tostring(CONFIG_VALUES["World.Effects.Ambience.Custom Sound (ID or URL)"] or "")
if id ~= "" then
id = aid(id)
if ambSnd.SoundId ~= id then ambSnd.SoundId = id end
ambSnd.Volume = W.ambVol or 1
if not ambSnd.IsPlaying then ambSnd:Play() end
elseif ambSnd.IsPlaying then ambSnd:Stop() end
elseif ambSnd.IsPlaying then ambSnd:Stop() end
if W.sunLock and W.sunTime then Lighting.ClockTime = W.sunTime
elseif W.clock and W.time then Lighting.ClockTime = W.time end
if W.bri and W.briv then Lighting.Brightness = W.briv end
if W.exp and W.expv then Lighting.ExposureCompensation = W.expv end
if W.fog then
Lighting.FogStart = W.fs or 0; Lighting.FogEnd = W.fe or 3000
Lighting.FogColor = hex3(CONFIG_VALUES["World.Lighting.Fog & Shadows.Fog Color"] or "#B070FF")
end
if W.sh then Lighting.GlobalShadows = false end
if cc.Enabled then cc.TintColor = hex3(CONFIG_VALUES["World.Effects.Colour Grading.Tint"] or "#FFFFFF") end
if W.atmoOn then
local a = ensureAtmo()
a.Density = W.aDen or 0.35; a.Haze = W.aHaze or 1.5; a.Glare = W.aGlare or 4
a.Offset = W.aOff or 0.25
a.Color = hex3(CONFIG_VALUES["World.Effects.Atmosphere (haze & glare).Atmosphere Color"] or "#C8AA6C")
a.Decay = hex3(CONFIG_VALUES["World.Effects.Atmosphere (haze & glare).Atmosphere Decay"] or "#5C3C0E")
lastAtmo = true
elseif lastAtmo then
lastAtmo = false
if atmo and atmo.Parent then
if atmoMade then atmo:Destroy(); atmo = nil
elseif atmoOrig then
atmo.Density, atmo.Haze, atmo.Glare = atmoOrig.Density, atmoOrig.Haze, atmoOrig.Glare
atmo.Color, atmo.Decay, atmo.Offset = atmoOrig.Color, atmoOrig.Decay, atmoOrig.Offset
end
end
end
end)
gui.Destroying:Connect(function()
loop:Disconnect()
pcall(RunService.UnbindFromRenderStep, RunService, "1MagStretch")
pcall(function() ambSnd:Destroy() end)
for _, fx in ipairs(fxList) do pcall(function() fx:Destroy() end) end
pcall(function() mySky:Destroy() end)
for _, s in ipairs(stash) do pcall(function() s.Parent = Lighting end) end
if atmo and atmoMade then pcall(function() atmo:Destroy() end) end
for k, v in pairs(orig) do pcall(function() Lighting[k] = v end) end
end)
end
do
local TEX_DIR   = ROOT .. "/Textures"
local CACHE_DIR = ROOT .. "/TextureCache"
ensureFolder(TEX_DIR); ensureFolder(CACHE_DIR)
local function parseConfig(text)
text = tostring(text or "")
if not text:find("%S") then return nil, "Paste a config first" end
local rules = {}
local rest = text:gsub("{%s*ids%s*=%s*{([%d%s,]*)}%s*,?%s*url%s*=%s*\"([^\"]-)\"%s*,?%s*}", function(idStr, url)
local ids = {}
for n in idStr:gmatch("%d+") do ids[#ids + 1] = n end
if #ids == 0 then return nil end
if not (url:find("^https://") or url:find("^rbxassetid://")) then return nil end
rules[#rules + 1] = {ids = ids, url = url}
return ""
end)
if rest:gsub("[%s,{}]", "") ~= "" or #rules == 0 then
return nil, "Only {ids = {...}, url = \"...\"}, entries are allowed"
end
return rules
end
local function serialize(rules)
local out = {}
for _, r in ipairs(rules) do
out[#out + 1] = "{ids = {" .. table.concat(r.ids, ", ") .. "}, url = \"" .. r.url .. "\"},"
end
return table.concat(out, "\n")
end
local J = {}
J.RUNTIME = [=====[

local URL_BASE = ""
local PACKED = [==[

]==]
for line in PACKED:gmatch("[^\n]+") do
	local op, ids, extra = line:match("^(%a)|([^|]*)|?(.*)$")
	if op then
		local list = {}
		for id in ids:gmatch("[^,]+") do list[#list + 1] = id end
		local rule = { name = list[1], replace_ids = list }
		if op == "c" then
			rule.mode = "cdn"
			rule.cdn_url = (extra:sub(1, 4) == "http") and extra or (URL_BASE .. extra)
		elseif op == "r" then
			rule.mode = "id"
		elseif op == "i" then
			rule.mode = "id"
			rule.with_id = extra
		elseif op == "l" then
			rule.mode = "local"
			rule.local_path = extra
		end
		RULES[#RULES + 1] = rule
	end
end

local PREFETCH_MAX = 150

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local genv = (getgenv and getgenv()) or _G
local INST = INST or "x"
local STOP_KEY = "UMM_STOP_" .. INST .. "_" .. NAME
local GEN_KEY, LOG_KEY, MAP_KEY = "UMM_GEN_" .. INST, "UMM_LOG_" .. INST, "UMM_MAP_" .. INST
local MYGEN = genv[GEN_KEY] or 0
if type(genv[LOG_KEY]) ~= "table" then genv[LOG_KEY] = {} end
if typeof(genv[STOP_KEY]) == "function" then pcall(genv[STOP_KEY]) end

local function warnf(...) warn("[" .. NAME .. "]", ...) end

local FS_OK = writefile and readfile and isfile and getcustomasset and true or false
if not FS_OK then
	warnf("Your executor is missing writefile/readfile/isfile/getcustomasset - custom files can't load.")
end

local ROOT = "UMM_Files"
local LOCAL_DIR = ROOT .. "/Local"
local LAZY_DIR = "LazyObjs"
local CACHE_DIR = ROOT .. "/Cache_v3"
if FS_OK then
	for _, d in ipairs({ ROOT, LOCAL_DIR, CACHE_DIR, LAZY_DIR }) do
		if not (isfolder and isfolder(d)) and makefolder then pcall(makefolder, d) end
	end
end

local function httpGet(url)
	local ok, res = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(res) == "string" and #res > 0 then return res end
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local ok2, r = pcall(req, { Url = url, Method = "GET" })
		if ok2 and r and (r.Success or r.StatusCode == 200) and r.Body and #r.Body > 0 then return r.Body end
	end
	return nil
end

local EXT_KIND = {
	obj = { "mesh", "mesh" }, mesh = { "mesh", "mesh" },
	png = { "image", "png" }, jpg = { "image", "jpg" }, jpeg = { "image", "jpg" },
	ogg = { "audio", "ogg" }, mp3 = { "audio", "mp3" }, wav = { "audio", "wav" },
	rbxm = { "anim", "rbxm" }, rbxmx = { "anim", "rbxm" },
}

local function extOf(path)
	local clean = path:gsub("%?.*$", ""):gsub("#.*$", "")
	return (clean:match("%.([%w]+)$") or ""):lower()
end

local function safe(s) return (s:gsub("[^%w_%-]", "_")) end

local FLIP_V = true
local FLIP_WINDING = false

local function objToMesh(text)
	if text:sub(1, 8) == "version " then return text, nil end

	local vs, vts, vns = {}, {}, {}
	local out, faces = {}, 0
	local n = 0

	local function idx(s, count)
		local i = tonumber(s)
		if not i then return nil end
		if i < 0 then i = count + i + 1 end
		return i
	end

	local function push(p, nrm, uv)
		n = n + 1
		out[n] = string.format("[%.5f,%.5f,%.5f][%.5f,%.5f,%.5f][%.5f,%.5f,0]",
			p[1] * 2, p[2] * 2, p[3] * 2, nrm[1], nrm[2], nrm[3], uv[1], uv[2])
	end

	for line in text:gmatch("[^\r\n]+") do
		local tok, rest = line:match("^%s*(%S+)%s*(.*)$")
		if tok == "v" then
			local x, y, z = rest:match("^(%S+)%s+(%S+)%s+(%S+)")
			vs[#vs + 1] = { tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0 }
		elseif tok == "vt" then
			local u, v = rest:match("^(%S+)%s+(%S+)")
			u, v = tonumber(u) or 0, tonumber(v) or 0
			if FLIP_V then v = 1 - v end
			vts[#vts + 1] = { u, v }
		elseif tok == "vn" then
			local x, y, z = rest:match("^(%S+)%s+(%S+)%s+(%S+)")
			vns[#vns + 1] = { tonumber(x) or 0, tonumber(y) or 1, tonumber(z) or 0 }
		elseif tok == "f" then
			local corners = {}
			for part in rest:gmatch("%S+") do
				local a, b, c = part:match("^([^/]*)/?([^/]*)/?([^/]*)$")
				local vi = idx(a, #vs)
				if vi and vs[vi] then
					corners[#corners + 1] = {
						p = vs[vi],
						uv = vts[idx(b, #vts) or 0] or { 0, 0 },
						nrm = vns[idx(c, #vns) or 0],
					}
				end
			end

			for k = 2, #corners - 1 do
				local c1, c2, c3 = corners[1], corners[k], corners[k + 1]
				if FLIP_WINDING then c2, c3 = c3, c2 end
				local flat
				if not (c1.nrm and c2.nrm and c3.nrm) then
					local ax, ay, az = c2.p[1] - c1.p[1], c2.p[2] - c1.p[2], c2.p[3] - c1.p[3]
					local bx, by, bz = c3.p[1] - c1.p[1], c3.p[2] - c1.p[2], c3.p[3] - c1.p[3]
					local nx, ny, nz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
					local len = math.sqrt(nx * nx + ny * ny + nz * nz)
					if len < 1e-12 then flat = { 0, 1, 0 } else flat = { nx / len, ny / len, nz / len } end
				end
				push(c1.p, c1.nrm or flat, c1.uv)
				push(c2.p, c2.nrm or flat, c2.uv)
				push(c3.p, c3.nrm or flat, c3.uv)
				faces = faces + 1
			end
		end
	end

	if faces == 0 then return nil, "no faces found in OBJ" end
	return "version 1.00\n" .. faces .. "\n" .. table.concat(out), faces
end

local AnimationClipProvider
pcall(function() AnimationClipProvider = game:GetService("AnimationClipProvider") end)
local TweenService = game:GetService("TweenService")

local function findKeyframeSequence(objs)
	for _, o in ipairs(objs) do
		if o:IsA("KeyframeSequence") then return o end
		for _, d in ipairs(o:GetDescendants()) do
			if d:IsA("KeyframeSequence") then return d end
		end
	end
end

local EASE_STYLE = {
	Linear = Enum.EasingStyle.Linear, Elastic = Enum.EasingStyle.Elastic,
	Cubic = Enum.EasingStyle.Cubic, CubicV2 = Enum.EasingStyle.Cubic, Bounce = Enum.EasingStyle.Bounce,
}
local EASE_DIR = {
	In = Enum.EasingDirection.In, Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut, OutIn = Enum.EasingDirection.InOut,
}

local function buildPoseData(ks)
	local frames = ks:GetKeyframes()
	table.sort(frames, function(a, b) return a.Time < b.Time end)
	local tracks, length = {}, 0
	for _, kf in ipairs(frames) do
		length = math.max(length, kf.Time)
		for _, pose in ipairs(kf:GetDescendants()) do
			if pose:IsA("Pose") and pose.Weight > 0 then
				local list = tracks[pose.Name]
				if not list then list = {} tracks[pose.Name] = list end
				table.insert(list, {
					t = kf.Time, cf = pose.CFrame,
					style = pose.EasingStyle.Name, dir = pose.EasingDirection.Name,
				})
			end
		end
	end
	return { tracks = tracks, length = length, loop = ks.Loop }
end

local function sample(list, time)
	local n = #list
	if time <= list[1].t then return list[1].cf end
	if time >= list[n].t then return list[n].cf end
	for i = 1, n - 1 do
		local a, b = list[i], list[i + 1]
		if time >= a.t and time < b.t then
			if a.style == "Constant" then return a.cf end
			local alpha = (time - a.t) / (b.t - a.t)
			alpha = TweenService:GetValue(alpha, EASE_STYLE[a.style] or Enum.EasingStyle.Linear,
				EASE_DIR[a.dir] or Enum.EasingDirection.In)
			return a.cf:Lerp(b.cf, alpha)
		end
	end
	return list[n].cf
end

local function motorsFor(animator)
	local model = animator:FindFirstAncestorOfClass("Model") or animator.Parent
	local map = {}
	if model then
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("Motor6D") and d.Part1 then map[d.Part1.Name] = d end
		end
	end
	return map
end

local activeManual = setmetatable({}, { __mode = "k" })
local ourTracks = setmetatable({}, { __mode = "k" })

local function stopManual(animator)
	local s = activeManual[animator]
	if s then activeManual[animator] = nil s() end
end

local function playManual(animator, data)
	stopManual(animator)
	local motors = motorsFor(animator)
	local start = os.clock()
	local conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if data.length > 0 then
			if data.loop then t = t % data.length elseif t > data.length then t = data.length end
		end
		for name, list in pairs(data.tracks) do
			local m = motors[name]
			if m and m.Parent then m.Transform = sample(list, t) end
		end
	end)
	local function stopFn()
		conn:Disconnect()
		for name in pairs(data.tracks) do
			local m = motors[name]
			if m then pcall(function() m.Transform = CFrame.new() end) end
		end
	end
	activeManual[animator] = stopFn
	return function()
		if activeManual[animator] == stopFn then stopManual(animator) end
	end
end

local function tryRegistered(animator, asset, rule)
	if not asset.regId or asset.regOK == false then return nil end
	local a = Instance.new("Animation")
	a.AnimationId = asset.regId
	local ok, tr = pcall(function() return animator:LoadAnimation(a) end)
	if not ok or not tr then asset.regOK = false return nil end
	ourTracks[tr] = true
	if asset.regOK == nil then
		local t0 = os.clock()
		while tr.Length == 0 and os.clock() - t0 < 0.6 do task.wait() end
		asset.regOK = tr.Length > 0
		print(string.format("[%s] animation '%s': %s", NAME, asset.label or "?",
			asset.regOK and "registered track works" or "registration rejected - using built-in player"))
		if not asset.regOK then pcall(function() tr:Stop(0) end) return nil end
	end
	return tr
end

local sourceCache = {}
local unknownCount = 0
local builtCount = 0

local function looksLikeObj(data)
	local head = data:sub(1, 4096)
	return head:find("^v%s+[%-%d%.]") ~= nil or head:find("\nv%s+[%-%d%.]") ~= nil
end

local function sniff(data, hint)
	local h = data:sub(1, 16)
	if h:sub(1, 8) == "version " then return "mesh", "mesh", data end
	if h:sub(1, 4) == "\137PNG" then return "image", "png", data end
	if h:sub(1, 3) == "\255\216\255" then return "image", "jpg", data end
	if h:sub(1, 4) == "OggS" then return "audio", "ogg", data end
	if h:sub(1, 4) == "RIFF" and h:sub(9, 12) == "WAVE" then return "audio", "wav", data end
	if h:sub(1, 3) == "ID3" or (h:byte(1) == 255 and (h:byte(2) or 0) >= 224) then return "audio", "mp3", data end
	if h:sub(1, 7) == "<roblox" then return "anim", "rbxm", data end
	if hint == "obj" or looksLikeObj(data) then
		local converted, tri = objToMesh(data)
		if not converted then return nil, tostring(tri) end
		return "mesh", "mesh", converted, tri
	end
	local info = EXT_KIND[hint]
	if info and info[1] ~= "mesh" then return info[1], info[2], data end
	return nil, "unrecognised file contents"
end

local EXTS = { "mesh", "png", "jpg", "ogg", "mp3", "wav", "rbxm" }
local EXT_TO_KIND = { mesh = "mesh", png = "image", jpg = "image", ogg = "audio", mp3 = "audio", wav = "audio", rbxm = "anim" }

local function hashStr(s)
	local h1, h2 = 5381, 52711
	for i = 1, #s do
		local b = s:byte(i)
		h1 = (h1 * 33 + b) % 4294967296
		h2 = (h2 * 131 + b) % 4294967291
	end
	return string.format("%08x%08x", h1, h2)
end

local function readLocal(rule, label)

	local base = rule.local_path:match("([^/\\]+)$")
	local candidates = {
		LAZY_DIR .. "/" .. NAME .. "/" .. base,
		LAZY_DIR .. "/" .. base,
		base,
		LOCAL_DIR .. "/" .. base,
	}
	local function tryRead(p)
		local okF, exists = pcall(isfile, p)
		if okF and exists then
			local okR, content = pcall(readfile, p)
			if okR and content and #content > 0 then return content end
		end
	end
	for _, p in ipairs(candidates) do
		local d = tryRead(p)
		if d then return d end
	end
	if listfiles then
		local want = base:lower()
		local function scan(dir, depth)
			local okL, items = pcall(listfiles, dir)
			if not okL or type(items) ~= "table" then return end
			for _, p in ipairs(items) do
				local name = p:match("([^/\\]+)$") or p
				if name:lower() == want then
					local c = tryRead(p)
					if c then return c end
				end
				if depth < 3 and isfolder and isfolder(p) then
					local c = scan(p, depth + 1)
					if c then return c end
				end
			end
		end
		local d = scan(LAZY_DIR, 0)
		if d then return d end
	end
	warnf("Local file not found for '" .. label .. "'. Put \"" .. base ..
		"\" in your executor workspace at: " .. LAZY_DIR .. "/" .. NAME .. "/" .. base ..
		"  (or directly in " .. LAZY_DIR .. "/)")
end

local function buildAsset(rule)
	local key = (rule.mode == "cdn") and rule.cdn_url or rule.local_path
	if sourceCache[key] ~= nil then return sourceCache[key] or nil end
	local label = rule.name or key
	if not FS_OK then sourceCache[key] = false return nil end

	local hint = extOf(key)
	local fileName, kind, data

	if rule.mode == "cdn" then
		local h = hashStr(key)
		for _, e in ipairs(EXTS) do
			local p = CACHE_DIR .. "/" .. h .. "." .. e
			local okF, exists = pcall(isfile, p)
			if okF and exists then fileName, kind = p, EXT_TO_KIND[e] break end
		end
		if not fileName then
			data = httpGet(key)
			if not data then
				task.wait(0.4)
				data = httpGet(key)
			end
			if not data then
				warnf("Download failed: " .. key)
				sourceCache[key] = false
				return nil
			end
		end
	else
		data = readLocal(rule, label)
		if not data then sourceCache[key] = false return nil end
	end

	if data then
		local k, ext, out, tri = sniff(data, hint)
		if not k then
			unknownCount += 1
			if unknownCount <= 3 then
				warnf("Skipping '" .. label .. "' (" .. key .. "): " .. tostring(ext))
			elseif unknownCount == 4 then
				warnf("More unsupported files are being skipped quietly.")
			end
			sourceCache[key] = false
			return nil
		end
		if tri then print(string.format("[%s] converted '%s' -> %d triangles", NAME, label, tri)) end
		kind = k
		fileName = CACHE_DIR .. "/" .. hashStr(key) .. "." .. ext
		if not pcall(writefile, fileName, out) then
			warnf("Couldn't write " .. fileName)
			sourceCache[key] = false
			return nil
		end
	end

	local result = { kind = kind, label = label }
	if kind == "anim" then
		local okG, objs = pcall(function() return game:GetObjects(getcustomasset(fileName)) end)
		local ks = okG and type(objs) == "table" and findKeyframeSequence(objs) or nil
		if not ks then
			warnf("Couldn't open animation '" .. label .. "' (" .. fileName ..
				") - your executor's GetObjects/getcustomasset can't read .rbxm, or the file has no KeyframeSequence")
			sourceCache[key] = false
			return nil
		end
		local okD, poseData = pcall(buildPoseData, ks)
		if okD and poseData and next(poseData.tracks) then result.data = poseData end
		pcall(function() result.regId = KeyframeSequenceProvider:RegisterKeyframeSequence(ks) end)
		if not result.regId and AnimationClipProvider then
			pcall(function() result.regId = AnimationClipProvider:RegisterAnimationClip(ks) end)
		end
		if not result.regId and not result.data then
			warnf("Animation '" .. label .. "' has no usable poses")
			sourceCache[key] = false
			return nil
		end
	else
		local okC, asset = pcall(getcustomasset, fileName)
		if not okC or not asset then
			warnf("getcustomasset failed for " .. fileName)
			sourceCache[key] = false
			return nil
		end
		result.content = asset
	end

	builtCount += 1
	if builtCount % 100 == 0 then print(string.format("[%s] %d assets ready", NAME, builtCount)) end
	sourceCache[key] = result
	return result
end

local actions = {}

for _, rule in ipairs(RULES) do
	if rule.enabled ~= false then
		local act
		local mode = rule.mode
		if mode == "id" and rule.with_id then

			act = { asset = { kind = "any", content = "rbxassetid://" .. tostring(rule.with_id) } }
		elseif mode == "id" or mode == "remove" then
			act = { remove = true }
		elseif mode == "cdn" or mode == "local" then
			act = { rule = rule }
		end
		if act then
			for _, id in ipairs(rule.replace_ids) do actions[tostring(id)] = act end
		end
	end
end

local function idFrom(str)
	if type(str) ~= "string" or str == "" then return nil end
	return str:match("rbxassetid://(%d+)") or str:match("[?&]id=(%d+)") or str:match("^(%d+)$")
end

local MAX_ACTIVE = 8
local queue, qHead, qTail, activeCount = {}, 1, 0, 0
local processProp

local function pump()
	while activeCount < MAX_ACTIVE and qHead <= qTail do
		local act = queue[qHead]
		queue[qHead] = nil
		qHead += 1
		activeCount += 1
		task.spawn(function()
			local ok, asset = pcall(buildAsset, act.rule)
			if not ok then warnf("Error while loading '" .. tostring(act.rule.name) .. "': " .. tostring(asset)) end
			act.asset = (ok and asset) or false
			activeCount -= 1
			local waiting = act.waiting
			act.waiting, act.waitSet = nil, nil
			if waiting and act.asset then
				for _, e in ipairs(waiting) do processProp(e[1], e[2], e[3], e[4]) end
			end
			pump()
		end)
	end
end

local function request(act)
	if act.state then return end
	act.state = "queued"
	qTail += 1
	queue[qTail] = act
	pump()
end

local function ensure(act)
	if act.rule then
		if act.asset == nil then
			request(act)
			while act.asset == nil do task.wait(0.05) end
		end
		return act.asset or nil
	end
	return act.asset
end

local PROP_LIST = {
	{ "MeshPart", "MeshId", "mesh" },
	{ "MeshPart", "TextureID", "image" },
	{ "SpecialMesh", "MeshId", "mesh" },
	{ "SpecialMesh", "TextureId", "image" },
	{ "Sound", "SoundId", "audio" },
	{ "Animation", "AnimationId", "anim" },
	{ "Decal", "Texture", "image" },
	{ "Texture", "Texture", "image" },
	{ "ImageLabel", "Image", "image" },
	{ "ImageButton", "Image", "image" },
	{ "ParticleEmitter", "Texture", "image" },
	{ "Beam", "Texture", "image" },
	{ "Trail", "Texture", "image" },
	{ "Tool", "TextureId", "image" },
	{ "SurfaceAppearance", "ColorMap", "image", 0 },
	{ "SurfaceAppearance", "NormalMap", "image", 1 },
	{ "SurfaceAppearance", "MetalnessMap", "image", 2 },
	{ "SurfaceAppearance", "RoughnessMap", "image", 3 },
	{ "MaterialVariant", "ColorMap", "image", 0 },
	{ "MaterialVariant", "NormalMap", "image", 1 },
	{ "MaterialVariant", "MetalnessMap", "image", 2 },
	{ "MaterialVariant", "RoughnessMap", "image", 3 },
	{ "Sky", "SkyboxBk", "image" },
	{ "Sky", "SkyboxDn", "image" },
	{ "Sky", "SkyboxFt", "image" },
	{ "Sky", "SkyboxLf", "image" },
	{ "Sky", "SkyboxRt", "image" },
	{ "Sky", "SkyboxUp", "image" },
	{ "Sky", "SunTextureId", "image" },
	{ "Sky", "MoonTextureId", "image" },
}
local PROPS_BY_CLASS = {}
genv.UMM_PROPS = PROPS_BY_CLASS
if type(genv[MAP_KEY]) ~= "table" then genv[MAP_KEY] = {} end
for _, p in ipairs(PROP_LIST) do
	local list = PROPS_BY_CLASS[p[1]]
	if not list then list = {} PROPS_BY_CLASS[p[1]] = list end
	list[#list + 1] = p
end

local origs = setmetatable({}, { __mode = "k" })
local stopped = false
local function save(inst, prop)
	local t = origs[inst]
	if not t then t = {} origs[inst] = t end
	if not t[prop] then
		local ok, v = pcall(function() return inst[prop] end)
		if ok then
			t[prop] = { v }
			local L = genv[LOG_KEY]
			if L then L[#L + 1] = { inst, prop, v } end
		end
	end
end
local function restoreAll()
	for inst, t in pairs(origs) do
		for prop, box in pairs(t) do
			pcall(function() inst[prop] = box[1] end)
		end
	end
	origs = setmetatable({}, { __mode = "k" })
	-- second pass: anything still showing a custom asset gets its replaced id written back
	local rev = {}
	for key, act in pairs(actions) do
		local c = act.asset and act.asset.content
		local oid = tostring(key):match("^(%d+)")
		if c and oid and not rev[c] then rev[c] = oid end
	end
	if next(rev) then
		for _, inst in ipairs(game:GetDescendants()) do
			local list = PROPS_BY_CLASS[inst.ClassName]
			if list then
				for _, p in ipairs(list) do
					local ok, v = pcall(function() return inst[p[2]] end)
					local oid = ok and rev[v]
					if oid then pcall(function() inst[p[2]] = "rbxassetid://" .. oid end) end
				end
			end
		end
	end
end

local function hide(inst, prop)
	for _, hp in ipairs({ "Transparency", "Scale", "Volume", "Enabled", "ImageTransparency" }) do
		if pcall(function() return inst[hp] end) then save(inst, hp) end
	end
	if inst:IsA("MeshPart") and prop == "MeshId" then
		inst.Transparency = 1
	elseif inst:IsA("SpecialMesh") and prop == "MeshId" then
		inst.Scale = Vector3.new(0, 0, 0)
	elseif inst:IsA("Sound") then
		inst.Volume = 0
	elseif inst:IsA("Decal") or inst:IsA("Texture") then
		inst.Transparency = 1
	elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		inst.ImageTransparency = 1
	elseif inst:IsA("ParticleEmitter") then
		inst.Enabled = false
	end
end

processProp = function(inst, prop, kind, slot)
	if stopped or genv[GEN_KEY] ~= MYGEN then stopped = true return end
	local ok, value = pcall(function() return inst[prop] end)
	if not ok then return end
	local id = idFrom(value)
	if not id then return end
	local act = (slot and actions[id .. ":" .. slot]) or actions[id]
	if not act then return end
	if act.remove then
		pcall(hide, inst, prop)
	elseif act.rule and act.asset == nil then

		local set = act.waitSet
		if not set then set = setmetatable({}, { __mode = "k" }) act.waitSet = set act.waiting = {} end
		local mine = set[inst]
		if not mine then mine = {} set[inst] = mine end
		if not mine[prop] and #act.waiting < 3000 then
			mine[prop] = true
			act.waiting[#act.waiting + 1] = { inst, prop, kind, slot }
		end
		request(act)
	else
		local a = act.asset
		if a and a.content and (a.kind == kind or a.kind == "any") then
			save(inst, prop)
			genv[MAP_KEY][a.content] = id
			pcall(function() inst[prop] = a.content end)
		end
	end
end

local function process(inst)
	local list = PROPS_BY_CLASS[inst.ClassName]
	if list then
		for _, p in ipairs(list) do processProp(inst, p[2], p[3], p[4]) end
	end
end

local hooked = setmetatable({}, { __mode = "k" })
local function hookAnimator(animator)
	if hooked[animator] then return end
	hooked[animator] = true
	animator.AnimationPlayed:Connect(function(track)
		if stopped or genv[GEN_KEY] ~= MYGEN or ourTracks[track] then return end
		local id = idFrom(track.Animation and track.Animation.AnimationId)
		local act = id and actions[id]
		if not act or act.remove then return end

		task.spawn(function()
			local asset = ensure(act)
			if not asset then return end

			if asset.kind == "any" then

				local a = Instance.new("Animation")
				a.AnimationId = asset.content
				local ok, newTrack = pcall(function() return animator:LoadAnimation(a) end)
				if ok and newTrack then
					ourTracks[newTrack] = true
					track:Stop(0)
					newTrack.Priority = track.Priority
					newTrack.Looped = track.Looped
					newTrack:Play(0)
				end
			elseif asset.kind == "anim" then

				pcall(function() track:AdjustWeight(0, 0) end)
				local stopOurs
				local tr = tryRegistered(animator, asset)
				if tr then
					tr.Priority = track.Priority
					if asset.data then tr.Looped = asset.data.loop end
					tr:Play(0)
					stopOurs = function() pcall(function() tr:Stop(0) end) end
				elseif asset.data then
					stopOurs = playManual(animator, asset.data)
				end
				if stopOurs then track.Stopped:Connect(stopOurs) end
			end
		end)
	end)
end

local function handle(inst)
	process(inst)
	if inst.ClassName == "Animator" then hookAnimator(inst) end
end

local conns = {}
genv[STOP_KEY] = function()
	stopped = true
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function()
		local list = {}
		for animator in pairs(activeManual) do list[#list + 1] = animator end
		for _, animator in ipairs(list) do pcall(stopManual, animator) end
	end)
	pcall(function()
		local list = {}
		for tr in pairs(ourTracks) do list[#list + 1] = tr end
		for _, tr in ipairs(list) do pcall(function() tr:Stop(0) end) end
	end)
	pcall(restoreAll)
end
for _, inst in ipairs(game:GetDescendants()) do pcall(handle, inst) end
table.insert(conns, game.DescendantAdded:Connect(function(inst)
	task.defer(handle, inst)
end))

local acc = 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
	if stopped or genv[GEN_KEY] ~= MYGEN then stopped = true return end
	acc += dt
	if acc < 1 then return end
	acc = 0
	local cam = workspace.CurrentCamera
	if cam then for _, i in ipairs(cam:GetDescendants()) do process(i) end end
	local char = Players.LocalPlayer and Players.LocalPlayer.Character
	if char then for _, i in ipairs(char:GetDescendants()) do process(i) end end
end))

local ruleCount, idCount = 0, 0
for _, rule in ipairs(RULES) do ruleCount += 1 end
for _ in pairs(actions) do idCount += 1 end
if ruleCount <= PREFETCH_MAX then
	local seen = {}
	for _, act in pairs(actions) do
		if act.rule and not seen[act] then seen[act] = true request(act) end
	end
end
print(string.format("[%s] ready - %d rules, %d asset ids mapped%s", NAME, ruleCount, idCount,
	ruleCount > PREFETCH_MAX and " (loading on demand)" or ""))
]=====]
function J.q(s)
local x = tostring(s):gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("[\r\n]", " ")
return "\"" .. x .. "\""
end
function J.num(v)
if type(v) == "number" then return string.format("%.0f", v) end
return tostring(v)
end
function J.fix(u)
local user, repo, rest = u:match("^https://github%.com/([^/]+)/([^/]+)/raw/(.+)$")
if user then return "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. rest end
return u
end
function J.isJson(t)
t = tostring(t or "")
return t:find("replacement_rules", 1, true) ~= nil and t:find("^%s*{") ~= nil
end
function J.convert(text, packName)
local ok, data = pcall(function() return HttpService:JSONDecode(tostring(text or "")) end)
if not ok or type(data) ~= "table" or type(data.replacement_rules) ~= "table" then
return nil, "Not a valid texture pack JSON"
end
local lines = {}
local function walk(nodes)
for _, r in ipairs(nodes) do
if type(r) == "table" then
if r.type == "group" then
if type(r.children) == "table" then walk(r.children) end
elseif type(r.replace_ids) == "table" then
local ids = {}
for _, i in ipairs(r.replace_ids) do ids[#ids + 1] = J.q(J.num(i)) end
if #ids > 0 then
local mode = type(r.mode) == "string" and r.mode or "id"
local parts = {"name = " .. J.q(r.name or "rule"), "replace_ids = { " .. table.concat(ids, ", ") .. " }",
"mode = " .. J.q(mode), "enabled = " .. ((r.enabled == false) and "false" or "true")}
if mode == "cdn" and type(r.cdn_url) == "string" and r.cdn_url ~= "" then
parts[#parts + 1] = "cdn_url = " .. J.q(J.fix(r.cdn_url))
elseif mode == "id" and r.with_id ~= nil then
parts[#parts + 1] = "with_id = " .. J.q(J.num(r.with_id))
elseif mode == "local" and type(r.local_path) == "string" then
parts[#parts + 1] = "local_path = " .. J.q(r.local_path)
end
lines[#lines + 1] = "\t{ " .. table.concat(parts, ", ") .. " },"
end
end
end
end
end
walk(data.replacement_rules)
if #lines == 0 then return nil, "No rules found in JSON" end
return "local NAME = " .. J.q(packName) .. "\n\nlocal RULES = {\n" .. table.concat(lines, "\n") .. "\n}\n" .. J.RUNTIME, #lines
end
local function hashStr(s)
local h1, h2 = 5381, 52711
for i = 1, #s do
local b = s:byte(i)
h1 = (h1 * 33 + b) % 4294967296
h2 = (h2 * 31 + b) % 4294967291
end
return string.format("%08x%08x", h1, h2)
end
local assetCache = {}
local function getAsset(url)
if assetCache[url] then return assetCache[url] end
if url:find("^rbxassetid://") then return url end
local ok, result = pcall(function()
if writefile and isfile and getcustomasset then
local fileName = CACHE_DIR .. "/tex_" .. hashStr(url) .. ".asset"
if not isfile(fileName) then
local data = game:HttpGet(url)
if data and #data > 80 then writefile(fileName, data) end
end
if isfile(fileName) then
local a = getcustomasset(fileName)
if a and a ~= "" then return a end
end
end
return url
end)
result = (ok and result) or url
if result ~= url then assetCache[url] = result end
return result
end
local PROPS = {Sound = "SoundId", ImageLabel = "Image", ImageButton = "Image", Decal = "Texture",
Texture = "Texture", MeshPart = "TextureID"}
local genvT = (getgenv and getgenv()) or _G
local function safeName(s) return (tostring(s):gsub("[^%w_%-]", "_")) end
-- applies one entry's replacement map to one object (entry = one loaded config)
local function applyObj(e, obj)
local prop = PROPS[obj.ClassName]
if not prop then return end
local value = obj[prop]
if type(value) ~= "string" then return end
if value:find("^rbxasset://") then return end
local id = value:match("%d+")
local new = id and e.map[id]
if new and new ~= value then
if not e.orig[obj] then e.orig[obj] = {prop, value, new} end
obj[prop] = new
end
end
-- unload exactly ONE loaded config (touches nothing that belongs to another config / sub tab)
local function unloadEntry(e)
local n1, n2 = 0, 0
e.dead = true
if e.kind == "rules" then
if e.conn then e.conn:Disconnect(); e.conn = nil end
for obj, d in pairs(e.orig) do
local ok, cur = pcall(function() return obj[d[1]] end)
if ok and cur == d[3] and pcall(function() obj[d[1]] = d[2] end) then n1 += 1 end
end
e.orig = setmetatable({}, {__mode = "k"})
if next(e.map) ~= nil then
local rev = {}
for id, asset in pairs(e.map) do if not rev[asset] then rev[asset] = id end end
for _, o in ipairs(game:GetDescendants()) do
local prop = PROPS[o.ClassName]
if prop then
local ok, v = pcall(function() return o[prop] end)
local id = ok and rev[v]
if id and pcall(function() o[prop] = "rbxassetid://" .. id end) then n2 += 1 end
end
end
end
else
local f = genvT[e.stopKey]
if type(f) == "function" then pcall(f); n1 = 1 end
genvT[e.stopKey] = nil
end
return n1, n2
end
-- fallback restore for packs, scoped to ONE sub tab (instance id)
local function restoreLog(inst)
local key = "UMM_LOG_" .. inst
local Lg = genvT[key]
genvT[key] = {}
local n = 0
if type(Lg) == "table" then
for i = #Lg, 1, -1 do
local e = Lg[i]
if pcall(function() e[1][e[2]] = e[3] end) then n = n + 1 end
end
end
return n
end
local function restoreIds(inst)
local key = "UMM_MAP_" .. inst
local map, props = genvT[key], genvT.UMM_PROPS
genvT[key] = {}
local n = 0
if type(map) ~= "table" or type(props) ~= "table" or next(map) == nil then return 0 end
for _, ins in ipairs(game:GetDescendants()) do
local list = props[ins.ClassName]
if list then
for _, p in ipairs(list) do
local ok, v = pcall(function() return ins[p[2]] end)
local id = ok and map[v]
if id and pcall(function() ins[p[2]] = "rbxassetid://" .. id end) then n = n + 1 end
end
end
end
return n
end

local BOOT = os.clock()
-- shared between the injector sub tabs: lets the Texture Injector hand a .ttf link to the Font Injector
local FontAPI = {}
-- adds the "Auto Load On Execute" toggle to an injector sub tab (loads the chosen saved config when the script starts)
local function addAutoLoad(ti, title, pick, loadFn)
ti.Section("Auto Load")
local fired = false
ti.Toggle("Auto Load On Execute", false, function(v)
-- a saved "on" is restored while the hub starts: wait for the saved config choice to be restored, then load it once
if v and not fired and os.clock() - BOOT < 25 then
fired = true
task.delay(3, function()
local n = pick.Get()
if n and n ~= "None" then
notify(title, "Auto loading: " .. tostring(n), 2.5)
pcall(loadFn)
end
end)
end
end)
ti.Label("Turn this on and pick a saved config above. That config loads by itself every time the script is executed.")
end
-- One full copy of the injector UI + logic. Every sub tab gets its OWN state, so
-- loading / unloading in one sub tab never touches the others.
--   cfg.id        unique instance id
--   cfg.name      sub tab name
--   cfg.dir       folder (inside 1MagHub) where this sub tab's configs are saved
--   cfg.additive  true  = loading a config keeps the ones already loaded (only Unload removes them)
--                 false = loading a config unloads this sub tab's previous config first
local function buildInjector(ti, cfg)
local TEX_DIR = ROOT .. "/" .. cfg.dir
ensureFolder(TEX_DIR)
local title = cfg.name
local inst = cfg.id
local loaded = {}
local keyPat = "^" .. ((cfg.tab or "Injector") .. "." .. cfg.name .. "."):gsub("%p", "%%%0") .. ".*%.Paste Config$"
local function unloadAll()
local a, b = 0, 0
for i = #loaded, 1, -1 do
local x, y = unloadEntry(loaded[i])
a += x; b += y
loaded[i] = nil
end
genvT["UMM_GEN_" .. inst] = (genvT["UMM_GEN_" .. inst] or 0) + 1
local c, d = restoreLog(inst), restoreIds(inst)
return a, b, c, d
end
local function prepare(name)
if cfg.additive then
for i = #loaded, 1, -1 do
if loaded[i].name == name then unloadEntry(loaded[i]); table.remove(loaded, i) end
end
else
unloadAll()
end
end
local function activeCount()
local n = 0
for _, e in ipairs(loaded) do if not e.dead then n += 1 end end
return n
end
local function loadRules(rules, label)
prepare(label)
local e = {kind = "rules", name = label, orig = setmetatable({}, {__mode = "k"}), map = {}}
loaded[#loaded + 1] = e
task.spawn(function()
notify(title, "Loading textures...", 2)
local pending = #rules
for _, r in ipairs(rules) do
task.spawn(function()
local asset = getAsset(r.url)
for _, id in ipairs(r.ids) do e.map[id] = asset end
pending -= 1
end)
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 30 do task.wait() end
if e.dead then return end
local list = game:GetDescendants()
for i = 1, #list do
local o = list[i]
if PROPS[o.ClassName] then pcall(applyObj, e, o) end
if i % 6000 == 0 then task.wait(); if e.dead then return end end
end
e.conn = game.DescendantAdded:Connect(function(o)
if not e.dead and PROPS[o.ClassName] then task.defer(pcall, applyObj, e, o) end
end)
local extra = cfg.additive and (" | " .. activeCount() .. " active") or ""
notify(title, "Loaded: " .. tostring(label) .. " (" .. #rules .. " entries)" .. extra, 3)
end)
end
local function runPackSrc(n, s)
if type(loadstring) ~= "function" then notify(title, "Executor has no loadstring", 3); return end
-- saved packs carry an old copy of the runtime; keep only their NAME + RULES and use the current runtime
local rs = s:find("local RULES = {", 1, true)
local re = rs and s:find("\n}\n", rs, true)
if re then s = s:sub(1, re + 2) .. J.RUNTIME end
local packName = s:match('local NAME = "([^"]*)"') or safeName(n)
s = 'local INST = "' .. inst .. '"\n' .. s
local fn, e = loadstring(s)
if not fn then notify(title, "Pack error: " .. tostring(e), 4); return end
prepare(n)
local ok, err = pcall(fn)
if ok then
loaded[#loaded + 1] = {kind = "pack", name = n, stopKey = "UMM_STOP_" .. inst .. "_" .. packName}
local extra = cfg.additive and (" | " .. activeCount() .. " active") or ""
notify(title, "Loaded: " .. tostring(n) .. " (1mag processing...)" .. extra, 3)
else
notify(title, "Pack failed: " .. tostring(err), 4)
end
end
local function runPack(n, lpath) runPackSrc(n, readfile(lpath)) end
local function listTexConfigs()
local out = {}
if type(listfiles) == "function" then
pcall(function()
for _, f in ipairs(listfiles(TEX_DIR)) do
local n = tostring(f):match("([^/\\]+)%.raw$") or tostring(f):match("([^/\\]+)%.txt$") or tostring(f):match("([^/\\]+)%.lua$")
if n and not table.find(out, n) then table.insert(out, n) end
end
end)
end
if #out == 0 then out = {"None"} end
table.sort(out)
return out
end
ti.Section("Add Config")
local pasteBox
pasteBox = ti.TextBox("Paste Config", "paste {ids = ...}", function(t)
for k in pairs(CONFIG_VALUES) do
if type(k) == "string" and k:find(keyPat) then CONFIG_VALUES[k] = nil end
end
if not (t or ""):find("%S") then return end
if cfg.forwardFonts and FontAPI.import then
for link in (t or ""):gmatch("https?://[^%s\"',%]%}%[%{]+") do
if link:lower():find("%.ttf$") then pcall(FontAPI.import, link); break end
end
end
if J.isJson(t) then
local src, cnt = J.convert(t, "Preview")
if src then notify(title, cnt .. " rules ready (1mag processing...) - name it and save", 2.5)
else pasteBox:Set(""); notify(title, cnt, 3.5) end
return
end
local rules, err = parseConfig(t)
if rules then
notify(title, #rules .. " entries ready - name it and save", 2.5)
else
pasteBox:Set("")
notify(title, err, 3.5)
end
end)
local nameBox = ti.TextBox("Name Config", "config name")
local pick
ti.Button("Save Config", function()
if J.isJson(pasteBox.Get()) then
local jn = (nameBox.Get() or ""):gsub("[^%w _%-]", "")
jn = jn:match("^%s*(.-)%s*$")
if jn == "" then notify(title, "Type a config name first", 2); return end
local src, cnt = J.convert(pasteBox.Get(), (jn:gsub("[^%w_%-]", "_")))
if not src then notify(title, cnt, 3); return end
if type(writefile) ~= "function" then notify(title, "Executor has no writefile", 2); return end
-- the file keeps exactly what you pasted; it is converted again every time it loads
local ok = pcall(writefile, TEX_DIR .. "/" .. jn .. ".raw", pasteBox.Get())
if not ok then notify(title, "Save failed", 2); return end
pick:SetOptions(listTexConfigs()); pick:Set(jn)
pasteBox:Set("")
notify(title, "Saved: " .. jn .. " (" .. cnt .. " rules, 1mag processing...)", 2.5)
return
end
local rules, err = parseConfig(pasteBox.Get())
if not rules then notify(title, err, 3); return end
local n = (nameBox.Get() or ""):gsub("[^%w _%-]", "")
n = n:match("^%s*(.-)%s*$")
if n == "" then notify(title, "Type a config name first", 2); return end
if type(writefile) ~= "function" then notify(title, "Executor has no writefile", 2); return end
local ok = pcall(writefile, TEX_DIR .. "/" .. n .. ".raw", pasteBox.Get())
if not ok then notify(title, "Save failed", 2); return end
pick:SetOptions(listTexConfigs()); pick:Set(n)
pasteBox:Set("")
notify(title, "Saved: " .. n .. " (" .. #rules .. " entries)", 2.5)
end)
ti.Section("Saved Configs")
pick = ti.Dropdown("Saved Configs", listTexConfigs(), "None")
local function loadSelected()
local n = pick.Get()
local path = TEX_DIR .. "/" .. tostring(n) .. ".txt"
local lpath = TEX_DIR .. "/" .. tostring(n) .. ".lua"
local rpath = TEX_DIR .. "/" .. tostring(n) .. ".raw"
if type(isfile) == "function" and type(readfile) == "function" and isfile(rpath) then
local raw = readfile(rpath)
if J.isJson(raw) then
local src, cnt = J.convert(raw, safeName(n))
if not src then notify(title, tostring(cnt), 3); return end
runPackSrc(n, src); return
end
local rules, err = parseConfig(raw)
if rules then loadRules(rules, n); return end
notify(title, err or "Config is invalid", 3); return
end
if type(isfile) == "function" and type(readfile) == "function" and not isfile(path) and isfile(lpath) then
runPack(n, lpath); return
end
if type(isfile) == "function" and type(readfile) == "function" and isfile(path) then
local rules, err = parseConfig(readfile(path))
if rules then loadRules(rules, n); return end
notify(title, err or "Config is invalid", 3); return
end
notify(title, "Pick a saved config first", 2)
end
ti.Button("Load", loadSelected)
addAutoLoad(ti, title, pick, loadSelected)
ti.Section("Manage")
ti.Button(cfg.unloadLabel, function()
local had = activeCount()
local ok, a, b, c, d = pcall(unloadAll)
if not ok then notify(title, "Unload error: " .. tostring(a), 4); return end
notify(title, "Unloaded " .. had .. " config(s) | restored " .. tostring((a or 0) + (c or 0)) .. " saved + " .. tostring((b or 0) + (d or 0)) .. " by id", 5)
end)
ti.Button("Delete Selected Config", function()
local n = pick.Get()
local path = TEX_DIR .. "/" .. tostring(n) .. ".txt"
local lpath = TEX_DIR .. "/" .. tostring(n) .. ".lua"
local rpath = TEX_DIR .. "/" .. tostring(n) .. ".raw"
if type(delfile) == "function" and type(isfile) == "function" and isfile(rpath) then
pcall(delfile, rpath); pick:SetOptions(listTexConfigs()); pick:Set(listTexConfigs()[1])
notify(title, "Deleted: " .. tostring(n), 2); return
end
if type(delfile) == "function" and type(isfile) == "function" and not isfile(path) and isfile(lpath) then
pcall(delfile, lpath); pick:SetOptions(listTexConfigs()); pick:Set(listTexConfigs()[1])
notify(title, "Deleted: " .. tostring(n), 2); return
end
if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
pcall(delfile, path); pick:SetOptions(listTexConfigs()); pick:Set(listTexConfigs()[1])
notify(title, "Deleted: " .. n, 2)
else notify(title, "Nothing to delete", 2) end
end)
ti.Button("Refresh List", function() pick:SetOptions(listTexConfigs()) end)
end
-- Font Injector: its own form (only .ttf links), separate from the texture-style injectors above
local function buildFontInjector(ti)
local FONT_DIR = ROOT .. "/Fonts"
ensureFolder(FONT_DIR)
local title = "Font Injector"
local STOPKEY = "UMM_STOP_FONTINJ"
local keyPat = "^Injector%.Font Injector%..*%.Paste Config$"
local TEMPLATE = [==[
-- 1mag font form | @NAME@
local HttpService = game:GetService("HttpService")
local genv = (getgenv and getgenv()) or _G

local URL = @URL@
local FILE = @FILE@
local JSONFILE = @JSON@
local FONTNAME = @NAME_Q@

if typeof(genv.UMM_STOP_FONTINJ) == "function" then pcall(genv.UMM_STOP_FONTINJ) end

if not isfile(FILE) then
	writefile(FILE, game:HttpGet(URL))
end

writefile(JSONFILE, HttpService:JSONEncode({
	name = FONTNAME,
	faces = {{
		name = "Regular",
		weight = 400,
		style = "normal",
		assetId = getcustomasset(FILE)
	}}
}))

local font = Font.new(getcustomasset(JSONFILE))
local badfont = tostring(Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"))
local origs = setmetatable({}, {__mode = "k"})
local stopped = false

local function skip(obj)
	if genv.UMM_FONT_HUB and obj:IsDescendantOf(genv.UMM_FONT_HUB) then return true end
	if obj.TextStrokeTransparency ~= 1 then return true end
	local cur = tostring(obj.FontFace)
	return cur == badfont or string.find(cur, "BuilderIcons")
end

local function apply(obj)
	if stopped then return end
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		if not skip(obj) then
			if not origs[obj] then origs[obj] = obj.FontFace end
			obj.FontFace = font
		end
	end
end

for _, v in ipairs(game:GetDescendants()) do
	task.spawn(function()
		apply(v)
	end)
end

local conn = game.DescendantAdded:Connect(function(obj)
	task.spawn(function()
		apply(obj)
	end)
end)

genv.UMM_STOP_FONTINJ = function()
	stopped = true
	pcall(function() conn:Disconnect() end)
	for obj, f in pairs(origs) do
		pcall(function() obj.FontFace = f end)
	end
	origs = setmetatable({}, {__mode = "k"})
end
]==]
-- accepts ONLY a pasted config that starts with { "replacement_rules": [ and contains a link ending in .ttf
-- takes just the first http...ttf link out of it; font name comes from the file name (wo0t2t.ttf -> wo0t2t)
local function parseFontLink(text)
local t = tostring(text or ""):match("^%s*(.-)%s*$")
if t == "" then return nil, "Paste a font config first" end
if not t:find('^{%s*"replacement_rules"%s*:%s*%[') then
return nil, 'Config must start with { "replacement_rules": ['
end
local u
for link in t:gmatch("https?://[^%s\"',%]%}%[%{]+") do
if link:lower():find("%.ttf$") then u = link; break end
end
if not u then return nil, "No link ending in .ttf found in the config" end
local file = u:match("([^/]+)$") or ""
local base = file:gsub("%.[Tt][Tt][Ff]$", "")
base = base:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
base = base:gsub("[^%w_%-]", "_")
if base == "" then base = "font" end
return u, base
end
-- converts the link into the font form (script) that gets saved and later loaded
local function buildForm(url, base)
local out = TEMPLATE
local map = {["@URL@"] = J.q(url), ["@FILE@"] = J.q(base .. ".ttf"), ["@JSON@"] = J.q(base .. ".json"),
["@NAME_Q@"] = J.q(base), ["@NAME@"] = base}
for k, v in pairs(map) do out = out:gsub(k, function() return v end) end
return out
end
local function stopFont()
local f = genvT[STOPKEY]
genvT[STOPKEY] = nil
if type(f) == "function" then pcall(f); return true end
return false
end
local function listFonts()
local out = {}
if type(listfiles) == "function" then
pcall(function()
for _, f in ipairs(listfiles(FONT_DIR)) do
local n = tostring(f):match("([^/\\]+)%.raw$") or tostring(f):match("([^/\\]+)%.lua$")
if n and not table.find(out, n) then table.insert(out, n) end
end
end)
end
if #out == 0 then out = {"None"} end
table.sort(out)
return out
end
ti.Section("Add Config")
local pasteBox, nameBox, pick
pasteBox = ti.TextBox("Paste Config", "paste font config (replacement_rules)", function(t)
for k in pairs(CONFIG_VALUES) do
if type(k) == "string" and k:find(keyPat) then CONFIG_VALUES[k] = nil end
end
if not (t or ""):find("%S") then return end
local url, base = parseFontLink(t)
if url then
if (nameBox.Get() or "") == "" then nameBox:Set(base) end
notify(title, base .. ".ttf ready (1mag processing...) - name it and save", 2.5)
else
pasteBox:Set("")
notify(title, base, 3.5)
end
end)
nameBox = ti.TextBox("Name Config", "font config name")
ti.Button("Save Config", function()
local url, base = parseFontLink(pasteBox.Get())
if not url then notify(title, base, 3); return end
local n = (nameBox.Get() or ""):gsub("[^%w _%-]", "")
n = n:match("^%s*(.-)%s*$")
if n == "" then n = base end
if type(writefile) ~= "function" then notify(title, "Executor has no writefile", 2); return end
local ok = pcall(writefile, FONT_DIR .. "/" .. n .. ".lua", buildForm(url, base))   -- stores the converted form
if not ok then notify(title, "Save failed", 2); return end
pick:SetOptions(listFonts()); pick:Set(n)
pasteBox:Set("")
notify(title, "Saved: " .. n .. " (" .. base .. ".ttf, 1mag processing...)", 2.5)
end)
ti.Section("Saved Configs")
pick = ti.Dropdown("Saved Configs", listFonts(), "None")
local function loadSelected()
local n = pick.Get()
local path = FONT_DIR .. "/" .. tostring(n) .. ".lua"
local rpath = FONT_DIR .. "/" .. tostring(n) .. ".raw"
local src
if type(isfile) == "function" and type(readfile) == "function" and isfile(rpath) then
local u, b = parseFontLink(readfile(rpath))
if not u then notify(title, tostring(b), 3); return end
src = buildForm(u, b)
elseif type(isfile) == "function" and type(readfile) == "function" and isfile(path) then
src = readfile(path)
else
notify(title, "Pick a saved config first", 2); return
end
if type(loadstring) ~= "function" then notify(title, "Executor has no loadstring", 3); return end
local fn, e = loadstring(src)
if not fn then notify(title, "Font config error: " .. tostring(e), 4); return end
stopFont()
genvT.UMM_FONT_HUB = gui
notify(title, "Loading font...", 2)
local ok, err = pcall(fn)
if ok then notify(title, "Loaded: " .. tostring(n) .. " (1mag processing...)", 3)
else notify(title, "Font failed: " .. tostring(err), 4) end
end
ti.Button("Load", loadSelected)
addAutoLoad(ti, title, pick, loadSelected)
-- used by the Texture Injector: a .ttf link found in a pasted config is saved here and loaded automatically
local lastImported
FontAPI.import = function(link)
if lastImported == link then return end
local u, base = parseFontLink('{ "replacement_rules": [ "' .. tostring(link) .. '" ] }')
if not u then return end
if type(writefile) ~= "function" then return end
local ok = pcall(writefile, FONT_DIR .. "/" .. base .. ".lua", buildForm(u, base))   -- stores the converted form
if not ok then return end
lastImported = link
pick:SetOptions(listFonts()); pick:Set(base)
notify(title, "Font link found in the pasted config: saved as " .. base .. " and loading it", 3.5)
loadSelected()
end
ti.Section("Manage")
ti.Button("Unload Fonts (restore originals)", function()
local had = stopFont()
notify(title, had and "Fonts restored" or "No font loaded", 3)
end)
ti.Button("Delete Selected Config", function()
local n = pick.Get()
local path = FONT_DIR .. "/" .. tostring(n) .. ".lua"
if type(delfile) == "function" and type(isfile) == "function" and isfile(FONT_DIR .. "/" .. tostring(n) .. ".raw") then path = FONT_DIR .. "/" .. tostring(n) .. ".raw" end
if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
pcall(delfile, path); pick:SetOptions(listFonts()); pick:Set(listFonts()[1])
notify(title, "Deleted: " .. tostring(n), 2)
else notify(title, "Nothing to delete", 2) end
end)
ti.Button("Refresh List", function() pick:SetOptions(listFonts()) end)
end
-- Kill Sounds Injector: accepts a replacement_rules config, pulls the .mp3 link out of it and builds the kill sound form
local function buildKillSoundInjector(ti)
local SND_DIR = ROOT .. "/KillSounds"
ensureFolder(SND_DIR)
local title = "Kill Sounds Injector"
local STOPKEY = "UMM_STOP_KILLSND"
local keyPat = "^Injector%.Kill Sounds Injector%..*%.Paste Config$"
local TEMPLATE = [==[
-- 1mag kill sound form | @NAME@
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local genv = (getgenv and getgenv()) or _G

local URL = @URL@
local FILE = @FILE@

-- Only play if the dummy was within this many studs of you (set to math.huge for any distance)
local MAX_DISTANCE = 60

if typeof(genv.UMM_STOP_KILLSND) == "function" then pcall(genv.UMM_STOP_KILLSND) end

if not isfile(FILE) then
	writefile(FILE, game:HttpGet(URL))
end

local sound = Instance.new("Sound")
sound.Name = "KillSound"
sound.SoundId = getcustomasset(FILE)
sound.Volume = 1
sound.Parent = SoundService

local player = Players.LocalPlayer
local tracked = {}
local conns = {}
local stopped = false

local function watch(humanoid)
	if stopped or tracked[humanoid] or humanoid.Health <= 0 then return end

	local model = humanoid.Parent
	if not model or Players:GetPlayerFromCharacter(model) then return end -- skip real players

	tracked[humanoid] = true

	table.insert(conns, humanoid.Died:Connect(function()
		tracked[humanoid] = nil
		if stopped then return end

		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local theirRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")

		if myRoot and theirRoot and (myRoot.Position - theirRoot.Position).Magnitude <= MAX_DISTANCE then
			sound:Play()
		end
	end))
end

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Humanoid") then
		watch(obj)
	end
end

table.insert(conns, workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Humanoid") then
		task.defer(watch, obj)
	end
end))

genv.UMM_STOP_KILLSND = function()
	stopped = true
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	conns = {}
	pcall(function() sound:Destroy() end)
end
]==]
-- accepts ONLY a pasted config that starts with { "replacement_rules": [ and contains a link ending in .mp3
-- takes just the first http...mp3 link out of it; file name comes from the link (claudthisname.mp3 -> claudthisname)
local function parseSoundLink(text)
local t = tostring(text or ""):match("^%s*(.-)%s*$")
if t == "" then return nil, "Paste a kill sound config first" end
if not t:find('^{%s*"replacement_rules"%s*:%s*%[') then
return nil, 'Config must start with { "replacement_rules": ['
end
local u
for link in t:gmatch("https?://[^%s\"',%]%}%[%{]+") do
if link:lower():find("%.mp3$") then u = link; break end
end
if not u then return nil, "No link ending in .mp3 found in the config" end
local file = u:match("([^/]+)$") or ""
local base = file:gsub("%.[Mm][Pp]3$", "")
base = base:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
base = base:gsub("[^%w_%-]", "_")
if base == "" then base = "killsound" end
return u, base
end
-- converts the link into the kill sound form (script) that gets saved and later loaded
local function buildForm(url, base)
local out = TEMPLATE
local map = {["@URL@"] = J.q(url), ["@FILE@"] = J.q(base .. ".mp3"), ["@NAME@"] = base}
for k, v in pairs(map) do out = out:gsub(k, function() return v end) end
return out
end
local function stopSound()
local f = genvT[STOPKEY]
genvT[STOPKEY] = nil
if type(f) == "function" then pcall(f); return true end
return false
end
local function listSounds()
local out = {}
if type(listfiles) == "function" then
pcall(function()
for _, f in ipairs(listfiles(SND_DIR)) do
local n = tostring(f):match("([^/\\]+)%.raw$") or tostring(f):match("([^/\\]+)%.lua$")
if n and not table.find(out, n) then table.insert(out, n) end
end
end)
end
if #out == 0 then out = {"None"} end
table.sort(out)
return out
end
ti.Section("Add Config")
local pasteBox, nameBox, pick
pasteBox = ti.TextBox("Paste Config", "paste kill sound config (replacement_rules)", function(t)
for k in pairs(CONFIG_VALUES) do
if type(k) == "string" and k:find(keyPat) then CONFIG_VALUES[k] = nil end
end
if not (t or ""):find("%S") then return end
local url, base = parseSoundLink(t)
if url then
if (nameBox.Get() or "") == "" then nameBox:Set(base) end
notify(title, base .. ".mp3 ready (1mag processing...) - name it and save", 2.5)
else
pasteBox:Set("")
notify(title, base, 3.5)
end
end)
nameBox = ti.TextBox("Name Config", "kill sound config name")
ti.Button("Save Config", function()
local url, base = parseSoundLink(pasteBox.Get())
if not url then notify(title, base, 3); return end
local n = (nameBox.Get() or ""):gsub("[^%w _%-]", "")
n = n:match("^%s*(.-)%s*$")
if n == "" then n = base end
if type(writefile) ~= "function" then notify(title, "Executor has no writefile", 2); return end
local ok = pcall(writefile, SND_DIR .. "/" .. n .. ".raw", pasteBox.Get())
if not ok then notify(title, "Save failed", 2); return end
pick:SetOptions(listSounds()); pick:Set(n)
pasteBox:Set("")
notify(title, "Saved: " .. n .. " (" .. base .. ".mp3, 1mag processing...)", 2.5)
end)
ti.Section("Saved Configs")
pick = ti.Dropdown("Saved Configs", listSounds(), "None")
local function loadSelected()
local n = pick.Get()
local path = SND_DIR .. "/" .. tostring(n) .. ".lua"
local rpath = SND_DIR .. "/" .. tostring(n) .. ".raw"
local src
if type(isfile) == "function" and type(readfile) == "function" and isfile(rpath) then
local u, b = parseSoundLink(readfile(rpath))
if not u then notify(title, tostring(b), 3); return end
src = buildForm(u, b)
elseif type(isfile) == "function" and type(readfile) == "function" and isfile(path) then
src = readfile(path)
else
notify(title, "Pick a saved config first", 2); return
end
if type(loadstring) ~= "function" then notify(title, "Executor has no loadstring", 3); return end
local fn, e = loadstring(src)
if not fn then notify(title, "Kill sound config error: " .. tostring(e), 4); return end
stopSound()
notify(title, "Loading kill sound...", 2)
local ok, err = pcall(fn)
if ok then notify(title, "Loaded: " .. tostring(n) .. " (1mag processing...)", 3)
else notify(title, "Kill sound failed: " .. tostring(err), 4) end
end
ti.Button("Load", loadSelected)
addAutoLoad(ti, title, pick, loadSelected)
ti.Section("Manage")
ti.Button("Unload Kill Sound", function()
local had = stopSound()
notify(title, had and "Kill sound removed" or "No kill sound loaded", 3)
end)
ti.Button("Delete Selected Config", function()
local n = pick.Get()
local path = SND_DIR .. "/" .. tostring(n) .. ".lua"
if type(delfile) == "function" and type(isfile) == "function" and isfile(SND_DIR .. "/" .. tostring(n) .. ".raw") then path = SND_DIR .. "/" .. tostring(n) .. ".raw" end
if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
pcall(delfile, path); pick:SetOptions(listSounds()); pick:Set(listSounds()[1])
notify(title, "Deleted: " .. tostring(n), 2)
else notify(title, "Nothing to delete", 2) end
end)
ti.Button("Refresh List", function() pick:SetOptions(listSounds()) end)
end
buildInjector(addSub(mTex, "Texture Injector", "Paste an id/url config, save it, then load it."),
{id = "tex1", name = "Texture Injector", dir = "Textures", additive = false, forwardFonts = true, unloadLabel = "Unload Textures (restore originals)"})
buildInjector(addSub(mTex, "Custom Skin Tab", "Paste an id/url config, save it, then load it."),
{id = "tex2", name = "Custom Skin Tab", dir = "Textures2", additive = false, unloadLabel = "Unload Textures (restore originals)"})
buildFontInjector(addSub(mTex, "Font Injector", "Paste a font config (.ttf link inside), save it, then load it."))
buildKillSoundInjector(addSub(mTex, "Kill Sounds Injector", "Paste a kill sound config (.mp3 link inside), save it, then load it."))
xpcall(function()
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
task.wait()   -- spread the menu build over frames so loading does not freeze
local ar = addSub(mTex, "Arena Creator", "Swap the arena texture, then tint it and set how reflective it is.")
local TARGET = "7658055825"
local PROPS = {Decal = "Texture", Texture = "Texture", MeshPart = "TextureID", SpecialMesh = "TextureId", SurfaceAppearance = "ColorMap"}
local AR = {color = Color3.fromRGB(255, 0, 0), tint = false, refl = 0, reflOn = false, scanned = false}
local tracked = setmetatable({}, {__mode = "k"})   -- instance -> {orig texture, orig tint}
local partRec = setmetatable({}, {__mode = "k"})   -- part -> {orig color, orig reflectance}
local idBox, scanning, addConn

local function digits(v)
v = tostring(v or "")
return v:match("[%?&]id=(%d+)") or v:match("rbxassetid://(%d+)") or v:match("^%s*(%d+)%s*$")
end
local function partOf(inst)
if inst:IsA("BasePart") then return inst end
local p = inst.Parent
return (p and p:IsA("BasePart")) and p or nil
end
local function readTint(inst)
if inst:IsA("Decal") then return inst.Color3
elseif inst:IsA("SurfaceAppearance") then return inst.Color
elseif inst:IsA("SpecialMesh") then return inst.VertexColor end
end
local function writeTint(inst, c)
if inst:IsA("Decal") then inst.Color3 = c
elseif inst:IsA("SurfaceAppearance") then inst.Color = c
elseif inst:IsA("SpecialMesh") then inst.VertexColor = Vector3.new(c.R, c.G, c.B) end
end

local urlCache, urlN, urlFail = {}, 0, {}
local function resolve(t)
t = tostring(t or ""):gsub("^%s+", ""):gsub("%s+$", "")
if t == "" then return nil end
if t:sub(1, 4):lower() == "http" and not t:find("roblox.com") then
if urlCache[t] then return urlCache[t] end
if urlFail[t] and os.clock() - urlFail[t] < 8 then return nil end
local got = false
pcall(function()
local data = game:HttpGet(t)
if type(data) == "string" and #data > 200 and type(writefile) == "function" and type(getcustomasset) == "function" then
urlN = urlN + 1
local path = ASSETS .. "/arena_" .. urlN .. ".png"
writefile(path, data)
got = getcustomasset(path)
end
end)
if got then urlCache[t] = got else urlFail[t] = os.clock() end
return got or nil
end
local d = digits(t)
return d and ("rbxassetid://" .. d) or nil
end
local function applyOne(inst, rec)
local prop = PROPS[inst.ClassName]
if not prop then return end
local rv = resolve(idBox and idBox.Get())
pcall(function() inst[prop] = rv or rec.orig end)
local part = partOf(inst)
local pr = part and partRec[part]
if AR.tint then
pcall(writeTint, inst, AR.color)
if part then pcall(function() part.Color = AR.color end) end
else
if rec.tint ~= nil then pcall(writeTint, inst, rec.tint) end
if pr then pcall(function() part.Color = pr.color end) end
end
if part then pcall(function() part.Reflectance = AR.reflOn and AR.refl or (pr and pr.refl or 0) end) end
end

local function process(inst)
local prop = PROPS[inst.ClassName]
if not prop then return false end
local rec = tracked[inst]
local isNew = false
if not rec then
local ok, cur = pcall(function() return inst[prop] end)
if not ok or digits(cur) ~= TARGET then return false end
local _, tint = pcall(readTint, inst)
rec = {orig = cur, tint = tint}
tracked[inst] = rec
isNew = true
local part = partOf(inst)
if part and not partRec[part] then partRec[part] = {color = part.Color, refl = part.Reflectance} end
end
applyOne(inst, rec)
return isNew
end

local function fullScan(announce)
if scanning then return end
scanning = true
task.spawn(function()
local okScan = pcall(function()
local n, hits = 0, 0
local cam = Workspace.CurrentCamera
for _, top in ipairs(Workspace:GetChildren()) do
if top ~= cam and not top:IsA("Terrain") and not Players:GetPlayerFromCharacter(top) then
local list = top:GetDescendants()
list[#list + 1] = top
for _, d in ipairs(list) do
if PROPS[d.ClassName] and process(d) then hits += 1 end
n += 1
if n % 2000 == 0 then task.wait() end
end
end
end
end)
scanning = false
AR.scanned = true
if announce then
local total = 0
for _ in pairs(tracked) do total += 1 end
notify("Arena", total > 0 and (total .. " textures updated") or "No textures with ID " .. TARGET .. " found", 3, total > 0 and "ok" or "danger")
end
end)
end

local function refresh()
for inst, rec in pairs(tracked) do
if inst.Parent then applyOne(inst, rec) end
end
end
local function changed()
if AR.scanned then refresh() elseif AR.tint or AR.reflOn then fullScan(false) end
end

local function setAuto(v)
if addConn then addConn:Disconnect(); addConn = nil end
if v then
addConn = Workspace.DescendantAdded:Connect(function(d)
if AR.scanned and PROPS[d.ClassName] then
task.delay(0.25, function() if d.Parent then process(d) end end)
end
end)
end
end

local function resetAll()
for inst, rec in pairs(tracked) do
if inst.Parent then
local prop = PROPS[inst.ClassName]
pcall(function() inst[prop] = rec.orig end)
if rec.tint ~= nil then pcall(writeTint, inst, rec.tint) end
end
end
for part, r in pairs(partRec) do
if part.Parent then pcall(function() part.Color = r.color; part.Reflectance = r.refl end) end
end
end

ar.Section("Arena Texture")
ar.Hint("Every decal, texture and mesh using ID " .. TARGET .. " in the map is swapped for the ID you type below. Leave it empty to keep the original.")
idBox = ar.TextBox("Replacement ID", "image id", function() changed() end)
local presetDD
ar.Button("Reset Texture", function()
idBox.Set(idBox, "")
urlCache, urlFail = {}, {}
if presetDD then presetDD.Set(presetDD, "None") end
if AR.scanned then refresh() end
notify("Arena", "Texture back to original", 2.5, "ok")
end)
ar.Button("Apply Texture", function() fullScan(true) end)
local PRESETS = {
["Blocky Arena"] = "4787109612",
["Basalt Arena"] = "6372755229",
["Blurry Arena"] = "https://raw.githubusercontent.com/FleaNafo/Rivals-Replacements/refs/heads/main/7658055825.png",
["Fear Ground"] = "https://github.com/TexPackSearcher/super-train/blob/main/ChatGPT_Image_26._Apr._2026_18_25_43-removebg-preview.png?raw=true",
["Fear Alt"] = "https://github.com/TexPackSearcher/turbo-octo-system/blob/main/1def8195-79e1-44fe-a894-c405a2fb79ee.jpg?raw=true",
}
presetDD = ar.Dropdown("Preset", {"None", "Blocky Arena", "Basalt Arena", "Blurry Arena", "Fear Ground", "Fear Alt"}, "None", function(v)
if v == "None" then return end
idBox.Set(idBox, PRESETS[v] or "")
fullScan(true)
end)
ar.Section("Color")
local tgTint = ar.Toggle("Color Arena", false, function(v) AR.tint = v == true; changed() end)
local cwArena = ar.ColorWheel("Arena Color", "#FF0000", function(c)
if typeof(c) == "Color3" then AR.color = c
elseif type(c) == "string" then pcall(function() AR.color = Color3.fromHex(c) end) end
if AR.tint then changed() end
end)
ar.Section("Reflectiveness")
local tgRefl = ar.Toggle("Reflective Arena", false, function(v) AR.reflOn = v == true; changed() end)
local slRefl = ar.Slider("Reflectiveness", 0, 100, 0, function(v)
AR.refl = math.clamp((tonumber(v) or 0) / 100, 0, 1)
if AR.reflOn then changed() end
end, 1)
ar.Section("Options")
ar.Toggle("Auto Apply To New Rounds", true, setAuto)
ar.Button("Reset All", function()
idBox.Set(idBox, "")
urlCache, urlFail = {}, {}
pcall(function() tgTint.Set(tgTint, false) end)
pcall(function() tgRefl.Set(tgRefl, false) end)
pcall(function() cwArena.Set(cwArena, "#FF0000") end)
pcall(function() slRefl.Set(slRefl, 0) end)
pcall(function() presetDD.Set(presetDD, "None") end)
AR.tint, AR.reflOn, AR.refl, AR.color = false, false, 0, Color3.fromRGB(255, 0, 0)
resetAll()
notify("Arena", "All arena settings reset", 2.5, "ok")
end)
ar.Hint("Color and reflectiveness only affect parts that carry the target texture or decal.")
end, function(e) warn("[1Mag] arena creator failed: " .. tostring(e)) end)
-- Skybox Cfg Loader (World tab): a full copy of the Texture Injector with its own folder, its own state and its own unload
buildInjector(addSub(mWorld, "Skybox Cfg Loader", "Paste an id/url config, save it, then load it. Standalone: its unload only touches this sub tab."),
{id = "sky1", name = "Skybox Cfg Loader", tab = "World", dir = "SkyboxCfg", additive = false, unloadLabel = "Unload Skybox Config (restore originals)"})
end
do
-- 1magstrap: the old Bloxstrap window rebuilt as hub sub tabs (Appearance / Mods / Engine Settings)
local function buildStrap()
local TITLE = "1magstrap"
local cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game:GetService("HttpService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lplr = Players.LocalPlayer
local genv = (getgenv and getgenv()) or _G
local REPO = "https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/"
local API_URL = "https://api.github.com/repos/qwertyui-is-back/Bloxstrap/contents/"
local say = function(a, b) notify(TITLE, a, b or 3) end

-- folders (paths keep the original name because the downloaded files use them)
for _, d in ipairs({"Bloxstrap", "Bloxstrap/Main", "Bloxstrap/Main/Functions", "Bloxstrap/Main/Configs", "Bloxstrap/Main/Fonts", "Bloxstrap/Images"}) do
pcall(makefolder, d)
end
if not isfile("Bloxstrap/FFlags.json") then pcall(writefile, "Bloxstrap/FFlags.json", "[]") end

-- shared state / config
local Strap = genv.Bloxstrap
if type(Strap) ~= "table" then Strap = {}; genv.Bloxstrap = Strap end
genv._1magstrap = Strap
Strap.TouchEnabled = UserInputService.TouchEnabled
Strap.Config = {
OofSound = false, FPS = 120, AntiAliasingQuality = "Automatic", LightingTechnology = "Chosen by game",
TextureQuality = "Automatic", DisablePlayerShadows = false, DisablePostFX = false, DisableTerrainTextures = false,
GraySky = false, Desync = false, HitregFix = false, customfonttoggle = false, customfontroblox = "Arimo",
customtopbar = false, CustomFont = "", CameraSensitivity = 1, CrosshairImage = "", TouchUiSize = 1,
}
pcall(function()
if isfile("Bloxstrap/Main/Configs/Default.json") then
local saved = HttpService:JSONDecode(readfile("Bloxstrap/Main/Configs/Default.json"))
if type(saved) == "table" then for k, v in pairs(saved) do Strap.Config[k] = v end end
end
end)
local conf = Strap.Config
local built = false
Strap.canUpdate = true
Strap.SaveConfig = function() pcall(writefile, "Bloxstrap/Main/Configs/Default.json", HttpService:JSONEncode(Strap.Config)) end
Strap.UpdateConfig = function(k, v) Strap.Config[k] = v; if built then Strap.SaveConfig() end end
Strap.error, Strap.success, Strap.info = say, say, say
local function flag(k, v) if Strap.ToggleFFlag then return Strap.ToggleFFlag(k, v) end end
local function getflag(k) if Strap.GetFFlag then return Strap.GetFFlag(k) end end

-- download files + load the fflag helpers the first time something needs them
local ready, busy = false, false
local onReady = {}
local function install()
local function get(u) return game:HttpGet(u, true) end
for _, v in ipairs(HttpService:JSONDecode(get(API_URL))) do
if v.name:find(".lua") then
writefile("Bloxstrap/" .. v.name, "return loadstring(game:HttpGet('" .. REPO .. v.name .. "', true))()")
elseif v.name:find(".mp3") or v.name:find(".png") then
writefile("Bloxstrap/" .. v.name, game:HttpGet(REPO .. v.name))
end
end
writefile("Bloxstrap/Main/Bloxstrap.lua", "return loadstring(game:HttpGet('" .. REPO .. "Main/Bloxstrap.lua', true))()")
for _, v in ipairs(HttpService:JSONDecode(get(API_URL .. "Main/Functions"))) do
writefile("Bloxstrap/Main/Functions/" .. v.name, "return loadstring(game:HttpGet('" .. REPO .. "Main/Functions/" .. v.name .. "', true))()")
end
writefile("Bloxstrap/Main/Configs/Default.json", HttpService:JSONEncode(Strap.Config))
end
local function ensureReady()
if ready then return true end
if busy then repeat task.wait() until not busy; return ready end
busy = true
local ok, err = pcall(function()
local okF = isfolder("Bloxstrap") and #listfiles("Bloxstrap") > 6
if not okF then install() end
Strap.ToggleFFlag = loadstring(game:HttpGet(REPO .. "Main/Functions/ToggleFFlag.lua"))()
Strap.GetFFlag = loadstring(game:HttpGet(REPO .. "Main/Functions/GetFFlag.lua"))()
end)
busy = false
if ok then ready = true; for _, f in ipairs(onReady) do task.spawn(f) end
else say("Setup failed: " .. tostring(err), 5) end
return ready
end
local function isalive(p)
p = p or lplr
local a, b = pcall(function()
return p.Character and p.Character.PrimaryPart and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end)
return a and b or false
end
local function gate(def, fn) return function(v) if not built and v == def then return end fn(v) end end
local function listOr(dir, filter)
local out = {}
pcall(function() for _, f in ipairs(listfiles(dir)) do if not filter or tostring(f):find(filter) then table.insert(out, f) end end end)
return out
end

-- ================= Appearance =================
task.wait()   -- spread the menu build over frames so loading does not freeze
local ap = addSub(mStrap, "Appearance", "Camera, gui scale, crosshair and topbar tweaks.")
ap.Section("Player")

local deRender = false
ap.Toggle("De Rendering", conf.DeRendering == true, function(on)
deRender = on
Strap.UpdateConfig("DeRendering", on)
task.spawn(function() if ensureReady() then flag("FFlagDisablePostFx", on) end end)
if on then
while deRender do
for _, p in ipairs(Players:GetPlayers()) do
if not isalive(lplr) then break end
if p ~= lplr and isalive(p) then
local mag = (lplr.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
for _, t in ipairs(p.Character.Humanoid:GetPlayingAnimationTracks()) do t:AdjustSpeed(mag <= 100 and 1 or 0) end
end
end
task.wait()
end
end
end)

pcall(function()
local camInput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
local oldRot = camInput.getRotation
ap.Slider("Camera Sensitivity", 1, 7, tonumber(conf.CameraSensitivity) or 1, function(val)
Strap.UpdateConfig("CameraSensitivity", val)
camInput.getRotation = function(...) return oldRot(...) * val end
end, 0.1)
end)

local guiCon
local guiSets = {}
local function scaleGui(v, sub)
local old = v:FindFirstChildWhichIsA("UIScale", true)
if old then
table.insert(guiSets, {oldscale = old.Scale, scaler = old})
old.Scale = sub and (old.Scale - 0.3) or 0.5
else
local us = Instance.new("UIScale"); us.Scale = 0.7; us.Parent = v
table.insert(guiSets, {oldscale = 9e9, scaler = us})
end
end
ap.Toggle("GUIScaler", conf.GUIScale == true, function(on)
Strap.UpdateConfig("GUIScale", on)
if on then
guiCon = lplr.PlayerGui.ChildAdded:Connect(function(v) if v.Name ~= "TouchGui" then scaleGui(v) end end)
for _, v in ipairs(lplr.PlayerGui:GetChildren()) do if v.Name ~= "TouchGui" then pcall(scaleGui, v) end end
else
pcall(function() guiCon:Disconnect() end); guiCon = nil
for _, v in ipairs(guiSets) do
pcall(function() if v.oldscale == 9e9 then v.scaler:Destroy() else v.scaler.Scale = v.oldscale end end)
end
table.clear(guiSets)
end
end)

local touchVal, touchScale = tonumber(conf.TouchUiSize) or 1.2, nil
ap.Toggle("TouchGui Size", conf.TouchUI == true, function(on)
if on then
pcall(function() touchScale = Instance.new("UIScale"); touchScale.Scale = touchVal; touchScale.Parent = lplr.PlayerGui.TouchGui end)
elseif touchScale then touchScale:Destroy(); touchScale = nil end
end)
ap.Slider("Scale", 1, 2, touchVal, function(val)
Strap.UpdateConfig("TouchUiSize", val)
touchVal = val
if touchScale then touchScale.Scale = val end
end, 0.1)

local chosenImage, xhair, xhairGui = "", nil, nil
local xhairOn = false
ap.Toggle("Crosshair", conf.Crosshair == true, function(on)
xhairOn = on
Strap.UpdateConfig("Crosshair", on)
if on then
xhairGui = xhairGui or Instance.new("ScreenGui"); xhairGui.IgnoreGuiInset = true; xhairGui.Parent = CoreGui
xhair = Instance.new("ImageLabel")
xhair.Size = UDim2.new(0, 19, 0, 19); xhair.AnchorPoint = Vector2.new(0.5, 0.5); xhair.Position = UDim2.new(0.5, 0, 0.5, 0)
xhair.BackgroundTransparency = 1; xhair.Image = chosenImage; xhair.Visible = true; xhair.Parent = xhairGui
while xhairOn do
task.wait()
if isalive() then
local mag = (lplr.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
xhair.Visible = (mag <= 3)
end
end
else
if xhair then xhair:Destroy(); xhair = nil end
end
end)
local images = listOr("Bloxstrap/Images")
local imgDD
imgDD = ap.Dropdown("Image", #images > 0 and images or {"none"}, (conf.CrosshairImage ~= "" and conf.CrosshairImage) or nil, function(val)
if val == "none" or not isfile(val) then return end
Strap.UpdateConfig("CrosshairImage", val)
chosenImage = getcustomasset(val)
if xhair then xhair.Image = chosenImage end
end)
onReady[#onReady + 1] = function()
local l = listOr("Bloxstrap/Images")
if #l > 0 then imgDD:SetOptions(l) end
end

ap.Section("Customizations")
local gradients, fakeBtn, topIcon = {}, nil, nil
pcall(function()
fakeBtn = Instance.new("TextButton")
fakeBtn.BorderSizePixel = 0; fakeBtn.BackgroundTransparency = 0.07; fakeBtn.Text = ""; fakeBtn.Name = "funni"
fakeBtn.ZIndex = 999; fakeBtn.BackgroundColor3 = Color3.new(); fakeBtn.Size = UDim2.new(0, 44, 0, 44)
fakeBtn.Position = UDim2.new(0, -52, 0, 0); fakeBtn.Visible = false
fakeBtn.Parent = CoreGui.TopBarApp.UnibarLeftFrame
fakeBtn.MouseButton1Click:Connect(function()
firesignal(CoreGui.TopBarApp.MenuIconHolder.TriggerPoint.Background.Activated)
end)
topIcon = Instance.new("ImageLabel")
topIcon.Size = UDim2.new(0, 22, 0, 22); topIcon.Position = UDim2.new(0.25, 0, 0.25, 0); topIcon.BackgroundTransparency = 1
topIcon.ImageColor3 = Color3.new(1, 1, 1); topIcon.Parent = fakeBtn
pcall(function() topIcon.Image = getcustomasset("Bloxstrap/icon.png") end)
local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1, 0); uc.Parent = fakeBtn
end)
local function addGrad(parent, rot)
local g = Instance.new("UIGradient"); g.Rotation = rot
g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)), ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))})
g.Parent = parent; table.insert(gradients, g)
end
local topCon
ap.Toggle("1magstrap Topbars", conf.customtopbar == true, function(on)
Strap.UpdateConfig("customtopbar", on)
pcall(function()
local bar = CoreGui.TopBarApp
bar.MenuIconHolder.TriggerPoint.Visible = not on
if fakeBtn then fakeBtn.Visible = on end
local menu = bar.UnibarLeftFrame.UnibarMenu["2"]["3"]
if on then
topCon = menu.chat["5"].ChildAdded:Connect(function(v)
addGrad(v, -60)
pcall(function() v.Text.TextColor3 = Color3.new(); v.Text.TextTruncate = "None" end)
end)
local badge = menu.chat["5"]:FindFirstChild("Badge")
if badge then
addGrad(badge, -60)
pcall(function() badge.Text.TextTruncate = "None"; badge.Text.TextColor3 = Color3.new() end)
end
for _, v in ipairs({menu.chat.IntegrationIconFrame.IntegrationIcon, menu.nine_dot.IntegrationIconFrame.IntegrationIcon.Overflow,
menu.nine_dot.IntegrationIconFrame.IntegrationIcon.Close, topIcon}) do
pcall(addGrad, v, 60)
end
else
pcall(function() topCon:Disconnect() end)
for _, g in ipairs(gradients) do pcall(function() g:Destroy() end) end
table.clear(gradients)
end
end)
end)
local spinOn = false
ap.Toggle("Spin Hotbar", conf.RotatingHotbar == true, function(on)
spinOn = on
Strap.UpdateConfig("RotatingHotbar", on)
local icon
pcall(function() icon = CoreGui.TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon end)
if on then
while spinOn do
if icon then icon.Rotation += 1.5 end
if topIcon then topIcon.Rotation += 1.5 end
task.wait()
end
else
if icon then icon.Rotation = 0 end
if topIcon then topIcon.Rotation = 0 end
end
end)

-- ================= Mods =================
task.wait()   -- spread the menu build over frames so loading does not freeze
local md = addSub(mStrap, "Mods", "Fast flags, game fonts and bannable presets.")
md.Section("Fast Flag Editor")
local ffBox
ffBox = md.TextBox("Paste Fast Flags (json)", "use with caution", function(call)
if not call or not call:find("%S") then return end
if not ensureReady() then return end
pcall(writefile, "Bloxstrap/FFlags.json", call)
local ok, fflags = pcall(function()
return HttpService:JSONDecode((call:gsub('"True"', "true"):gsub('"False"', "false")))
end)
if not ok then say("Invalid fast flags json", 3); return end
for k, v in pairs(fflags) do flag(k, v) end
say("Fast flags applied", 2)
task.defer(function() pcall(function() ffBox:Set("") end) end)   -- clear the box so the long paste never spills over the GUI
end)

md.Section("Presets: Unbannable")
md.Toggle("Gray sky", conf.GraySky == true, function(on)
Strap.UpdateConfig("GraySky", on)
if ensureReady() then flag("FFlagDebugSkyGray", on) end
end)

local updatedFonts, fontName, customFont, fontOn, fontCon = {}, tostring(conf.customfontroblox or "Arimo"), nil, false, nil
if fontName == "" then fontName = "Arimo" end
local function isText(v) return v.ClassName == "TextLabel" or v.ClassName == "TextButton" or v.ClassName == "TextBox" end
local function applyFont(v)
if not isText(v) then return end
local cur = fontName
pcall(function()
table.insert(updatedFonts, {inst = v, font = tostring(v.Font):split(".")[3], connection = v:GetPropertyChangedSignal("Font"):Connect(function()
if customFont then v.FontFace = customFont else v.Font = Enum.Font[cur] end
end)})
if customFont then v.FontFace = customFont else v.Font = Enum.Font[cur] end
end)
end
local function fontsOff()
pcall(function() fontCon:Disconnect() end); fontCon = nil
for _, v in ipairs(updatedFonts) do
pcall(function() v.connection:Disconnect(); v.inst.Font = Enum.Font[v.font] end)
end
table.clear(updatedFonts)
end
local function fontsOn()
fontCon = game.DescendantAdded:Connect(function(v) if fontOn then applyFont(v) end end)
for _, v in ipairs(game:GetDescendants()) do applyFont(v) end
end
md.Toggle("Change Game Fonts", conf.customfonttoggle == true, function(on)
fontOn = on
Strap.UpdateConfig("customfonttoggle", on)
fontsOff()
if on then fontsOn() end
end)
local fontList = {}
for _, v in ipairs(Enum.Font:GetEnumItems()) do table.insert(fontList, tostring(v):split(".")[3]) end
md.Dropdown("Preset-Fonts", fontList, fontName, function(v)
Strap.UpdateConfig("customfontroblox", v)
fontName = v
if fontOn then fontsOff(); fontsOn() end
end)
local ttfs = {"none"}
for _, f in ipairs(listOr("Bloxstrap/Main/Fonts", "%.ttf")) do table.insert(ttfs, f) end
md.Dropdown("Custom Fonts", ttfs, (conf.CustomFont ~= "" and conf.CustomFont) or "none", function(val)
if val == "none" then
customFont = nil
Strap.UpdateConfig("CustomFont", "")
elseif isfile(val) then
Strap.UpdateConfig("CustomFont", val)
local json = val:gsub("%.ttf$", ".json")
pcall(function()
writefile(json, HttpService:JSONEncode({name = "font", faces = {{name = "Regular", weight = 600, style = "normal", assetId = getcustomasset(val)}}}))
customFont = Font.new(getcustomasset(json), Enum.FontWeight.Regular)
end)
end
if fontOn then fontsOff(); fontsOn() end
end)

md.Section("Presets: Bannable")
md.Toggle("Desync", conf.Desync == true, function(on)
Strap.UpdateConfig("Desync", on)
if ensureReady() then flag("DFIntS2PhysicsSenderRate", on and 38000 or 15) end
end)
md.Toggle("Hitreg Fix", conf.HitregFix == true, function(on)
Strap.UpdateConfig("HitregFix", on)
if not on and not built then return end
if not ensureReady() then return end
local FFlags = [[
{
"DFIntCodecMaxIncomingPackets": "100",
"DFIntCodecMaxOutgoingFrames": "10000",
"DFIntLargePacketQueueSizeCutoffMB": "1000",
"DFIntMaxProcessPacketsJobScaling": "10000",
"DFIntMaxProcessPacketsStepsAccumulated": "0",
"DFIntMaxProcessPacketsStepsPerCyclic": "5000",
"DFIntMegaReplicatorNetworkQualityProcessorUnit": "10",
"DFIntNetworkLatencyTolerance": "1",
"DFIntNetworkPrediction": "120",
"DFIntOptimizePingThreshold": "50",
"DFIntPlayerNetworkUpdateQueueSize": "20",
"DFIntPlayerNetworkUpdateRate": "60",
"DFIntRaknetBandwidthInfluxHundredthsPercentageV2": "10000",
"DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
"DFIntRakNetLoopMs": "1",
"DFIntRakNetResendRttMultiple": "1",
"DFIntServerPhysicsUpdateRate": "60",
"DFIntServerTickRate": "60",
"DFIntWaitOnRecvFromLoopEndedMS": "100",
"DFIntWaitOnUpdateNetworkLoopEndedMS": "100",
"FFlagOptimizeNetwork": "true",
"FFlagOptimizeNetworkRouting": "true",
"FFlagOptimizeNetworkTransport": "true",
"FFlagOptimizeServerTickRate": "true",
"FIntRakNetResendBufferArrayLength": "128"
}]]
for k, v in pairs(HttpService:JSONDecode((FFlags:gsub('"True"', "true"):gsub('"False"', "false")))) do flag(k, v) end
end)

-- ================= Engine Settings =================
task.wait()   -- spread the menu build over frames so loading does not freeze
local en = addSub(mStrap, "Engine Settings", "Death sound, graphics and framerate.")
en.Section("Presets")
local deathCon, charCon
local hasCustomDeath = isfile("Bloxstrap/deathsound.mp3")
local function addDeath()
if getcustomasset == nil then return end
pcall(function() deathCon:Disconnect() end); deathCon = nil
local char = lplr.Character or lplr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
deathCon = hum.HealthChanged:Connect(function()
if hum.Health <= 0 then
pcall(function() lplr.PlayerScripts.RbxCharacterSounds.Enabled = false end)
local s = Instance.new("Sound")
s.Parent = workspace
s.SoundId = isfile("Bloxstrap/deathsound.mp3") and getcustomasset("Bloxstrap/deathsound.mp3") or isfile("Bloxstrap/oofsound.mp3") and getcustomasset("Bloxstrap/oofsound.mp3") or ""
s.PlayOnRemove = true; s.Volume = 0.5
s:Destroy()
end
end)
end
en.Toggle(hasCustomDeath and "Use custom death sound" or "Use old death sound", conf.OofSound == true, function(on)
Strap.UpdateConfig("OofSound", on)
if on then
if not hasCustomDeath then ensureReady() end
task.spawn(addDeath)
pcall(function() charCon:Disconnect() end)
charCon = lplr.CharacterAdded:Connect(function()
pcall(function() lplr.PlayerScripts.RbxCharacterSounds.Enabled = true end)
addDeath()
end)
else
pcall(function() deathCon:Disconnect() end); deathCon = nil
pcall(function() charCon:Disconnect() end); charCon = nil
end
end)

en.Dropdown("Anti-aliasing quality (MSAA)", {"Automatic", "1x", "2x", "4x"}, conf.AntiAliasingQuality, gate("Automatic", function(msaa)
if not UserInputService.TouchEnabled then return end
Strap.UpdateConfig("AntiAliasingQuality", msaa)
if ensureReady() then flag("FIntDebugForceMSAASamples", msaa:find("x") and msaa:gsub("x", "") or 0) end
end))
en.Toggle("Disable player shadows", conf.DisablePlayerShadows == true, function(on)
Strap.UpdateConfig("DisablePlayerShadows", on)
if ensureReady() then flag("FIntRenderShadowIntensity", on and 0 or 1) end
end)
en.Toggle("Disable post-processing effects", conf.DisablePostFX == true, function(on)
Strap.UpdateConfig("DisablePostFX", on)
if ensureReady() then flag("FFlagDisablePostFx", on and true or false) end
end)
local origTerrain
en.Toggle("Disable terrain textures", conf.DisableTerrainTextures == true, function(on)
Strap.UpdateConfig("DisableTerrainTextures", on)
if not ensureReady() then return end
if origTerrain == nil then origTerrain = getflag("FIntTerrainArraySliceSize") end
flag("FIntTerrainArraySliceSize", on and 0 or origTerrain)
end)
local origFps
en.TextBox("Framerate limit", "0 = unlimited", function(txt)
local fps = tonumber(txt)
if fps == nil then return end
Strap.UpdateConfig("FPS", fps)
if not ensureReady() then return end
if origFps == nil then origFps = getflag("DFIntTaskSchedulerTargetFps") end
flag("FFlagTaskSchedulerLimitTargetFpsTo2402", fps >= 70)
if fps > 0 then
pcall(setfpscap, fps); flag("DFIntTaskSchedulerTargetFps", fps)
else
pcall(setfpscap, 9e9); flag("DFIntTaskSchedulerTargetFps", origFps)
end
end)
en.Toggle("Display FPS", conf.DisplayFPS == true, function(on)
Strap.UpdateConfig("DisplayFPS", on)
if ensureReady() then flag("FFlagDebugDisplayFPS", on) end
end)

local function changeLighting(l)
pcall(sethiddenproperty, game.Lighting, "Technology", l:find("Voxel") and "Voxel" or l:find("Shadow Map") and "ShadowMap" or "Future")
if UserInputService.TouchEnabled then return end
local s = l:lower()
local v, p2, p3 = false, false, false
if s:find("voxel") then v = true elseif s:find("shadow map") then p2 = true elseif s:find("future") then p3 = true end
flag("DFFlagDebugRenderForceTechnologyVoxel", v)
flag("DFFlagDebugRenderForceFutureIsBrightPhase2", p2)
flag("DFFlagDebugRenderForceFutureIsBrightPhase3", p3)
end
en.Dropdown("Preferred lighting technology", {"Chosen by game", "Voxel (Phase 1)", "Shadow Map (Phase 2)", "Future (Phase 3)"},
conf.LightingTechnology, gate("Chosen by game", function(l)
Strap.UpdateConfig("LightingTechnology", l)
if ensureReady() then pcall(changeLighting, l) end
end))

local function changeTexture(level)
local s = level:lower()
local on, q, mips = true, 0, 0
if s:find("lowest") then q, mips = 0, 2
elseif s:find("low") then q = 0
elseif s:find("medium") then q = 1
elseif s:find("highest") then q = 3
elseif s:find("high") then q = 2
else on, q = false, 3 end
flag("DFFlagTextureQualityOverrideEnabled", on)
flag("DFIntTextureQualityOverride", q)
flag("FIntDebugTextureManagerSkipMips", mips)
end
en.Dropdown("Texture quality", {"Automatic", "Lowest (Requires rejoin)", "Low", "Medium", "High", "Highest"},
conf.TextureQuality, gate("Automatic", function(level)
Strap.UpdateConfig("TextureQuality", level)
if ensureReady() then changeTexture(level) end
end))

built = true
Strap.SaveConfig()
-- download files / load fflag helpers in the background so the first toggle is instant
task.spawn(ensureReady)
end
local ok, err = pcall(buildStrap)
if not ok then notify("1magstrap", "Failed to build tab: " .. tostring(err), 5) end
end
do
local COLS, GAP, CELL_H = 4, 10, 150
local KINDS = {
{kind = "Skin",     tab = "Skins",     desc = "Pick a weapon, then click a skin to equip it (click again to unequip)."},
{kind = "Wrap",     tab = "Wraps",     desc = "Pick a weapon, then click a wrap to apply it (click again to remove)."},
{kind = "Charm",    tab = "Charms",    desc = "Pick a weapon, then click a charm to attach it (click again to remove)."},
{kind = "Finisher", tab = "Finishers", desc = "Pick a weapon, then click a finisher (plays when you finish with that weapon)."},
}
local saved = CONFIG_VALUES["Cosmetics.Equipped"]
if type(saved) ~= "table" then saved = {} end
CONFIG_VALUES["Cosmetics.Equipped"] = saved
do
local pending = false
FX.persistCos = function()
CONFIG_VALUES["Cosmetics.Equipped"] = saved   -- always point at the live table
if pending or type(writefile) ~= "function" then return end
pending = true
task.spawn(function()
task.wait(0.2)   -- batch rapid clicks into one write
pending = false
pcall(function()
local snap = Cosmetic.Snapshot and Cosmetic.Snapshot() or saved   -- live state of what is equipped in the game
writefile(ROOT .. "/cosmetics.json", HttpService:JSONEncode({
Equipped = snap,
Enabled = CONFIG_VALUES["Cosmetics.Skins.Master.Enable Cosmetics"] == true,
Invert = CONFIG_VALUES["Cosmetics.Wraps.Options.Invert Patterns"] == true,
}))
end)
end)
end
end
local invertAll = CONFIG_VALUES["Cosmetics.Wraps.Options.Invert Patterns"] == true
local allWeapons = Cosmetic.Ready and Cosmetic.Weapons() or {}
local function viewportOf(holderF, model)
local vp = make("ViewportFrame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5,
Ambient = Color3.fromRGB(190, 190, 200), LightColor = Color3.new(1, 1, 1)}, holderF)
local ok = pcall(function()
if model:IsA("BasePart") then model.Anchored = true end
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("BasePart") then d.Anchored = true end
end
model.Parent = vp
local cf, size
if model:IsA("Model") then cf, size = model:GetBoundingBox() else cf, size = model.CFrame, model.Size end
local cam = Instance.new("Camera")
cam.FieldOfView = 35
local dist = math.max(size.Magnitude, 0.5) * 1.25
local dir = (cf.RightVector * 1.0 + cf.UpVector * 0.25 + cf.LookVector * 0.35).Unit
cam.CFrame = CFrame.lookAt(cf.Position + dir * dist, cf.Position)
cam.Parent = vp
vp.CurrentCamera = cam
end)
if not ok then vp:Destroy(); pcall(function() model:Destroy() end) end
return ok
end
local function cloneModel(src)
local model
pcall(function()
local arch = {}
local function unlock(i) if not i.Archivable then arch[#arch + 1] = i; i.Archivable = true end end
unlock(src); for _, d in ipairs(src:GetDescendants()) do unlock(d) end
if src:IsA("Folder") then
model = Instance.new("Model")
for _, ch in ipairs(src:GetChildren()) do
local cl = ch:Clone(); if cl then cl.Parent = model end
end
else
model = src:Clone()
end
for _, i in ipairs(arch) do i.Archivable = false end
end)
return model
end
local function drawIcon(btn, kind, name, weapon)
local holderF = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 8),
Size = UDim2.new(1, -16, 1, -40), ZIndex = 4}, btn)
local id = Cosmetic.IconId(name)
if id then
make("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = id,
ScaleType = Enum.ScaleType.Fit, ZIndex = 5}, holderF)
return
end
local src, wrapProps
if kind == "Skin" then
src = Cosmetic.PreviewSource(name)
elseif kind == "Charm" then
src = Cosmetic.CharmModel(name)
elseif kind == "Wrap" then
src = Cosmetic.WeaponModel(weapon)
end
local model = src and cloneModel(src)
if model and kind == "Wrap" then
local ok = pcall(function()
local ctrl = Cosmetic.WrapController()
local props = ctrl:RecordOriginalWrapProperties(model)
ctrl:ApplyWrap(props, {Name = name})
end)
if not ok then pcall(function() model:Destroy() end); model = nil end
end
if model and viewportOf(holderF, model) then return end
make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = string.upper(string.sub(name, 1, 2)),
FontFace = F_HEAVY, TextSize = 34, TextColor3 = T.Dim, ZIndex = 5}, holderF)
end
local NONE, RAND, UNSEL, ALLW = "\1none", "\1rand", "\1unsel", "All Weapons"
local function isSpecial(n) return n == NONE or n == RAND or n == UNSEL end
local function disp(n) return (n == NONE) and "None" or (n == UNSEL) and "Unselected" or (n == RAND) and "Random" or n end
local function weaponPicker(sub, onPick, withAll)
local srcList = {}
if withAll then srcList[1] = ALLW end
for _, w in ipairs(allWeapons) do srcList[#srcList + 1] = w end
local dd = sub.Dropdown("Weapon", srcList, srcList[1], onPick)
local f = dd.Frame
f.LayoutOrder = -500
for _, c in ipairs(f:GetChildren()) do
if c:IsA("TextButton") then c.Visible = false; c.Active = false
elseif c:IsA("Frame") and c:FindFirstChildOfClass("UIListLayout") then c.Visible = false end
end
f.Size = UDim2.new(1, 0, 0, 204)
local box = make("TextBox", {BackgroundColor3 = T.PanelHi, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 5),
Size = UDim2.fromOffset(200, 24), Text = "", PlaceholderText = "search weapon...", PlaceholderColor3 = T.Dim,
FontFace = F_BOLD, TextSize = 17, TextColor3 = T.Text, ClearTextOnFocus = false, ZIndex = 6}, f)
corner(box, 6); stroke(box, T.Border, 1, 0.4)
local scroll = make("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 36),
Size = UDim2.new(1, -16, 0, 160), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 4, ScrollBarImageColor3 = T.Accent, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 5}, f)
make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
local btns = {}
local function paint()
local cur = dd.Get()
for w, b in pairs(btns) do b.BackgroundColor3 = (w == cur) and T.Accent or T.PanelHi end
end
local function render(list)
for _, b in pairs(btns) do b:Destroy() end
btns = {}
for i, w in ipairs(list) do
local b = make("TextButton", {BackgroundColor3 = T.PanelHi, Size = UDim2.new(1, -8, 0, 26), Text = w, FontFace = F_BOLD,
TextSize = 19, TextColor3 = T.Text, AutoButtonColor = false, LayoutOrder = i, ZIndex = 6}, scroll)
corner(b, 6)
b.MouseButton1Click:Connect(function() clickSfx(); dd:Set(w); paint() end)
btns[w] = b
end
paint()
end
render(srcList)
box:GetPropertyChangedSignal("Text"):Connect(function()
local q = string.lower(box.Text)
local res = {}
for _, w in ipairs(srcList) do
if q == "" or string.find(string.lower(w), q, 1, true) then res[#res + 1] = w end
end
render(res)
end)
return dd
end
local function pickRandom(kind, weapon)
local pool = (kind == "Skin") and Cosmetic.SkinsFor(weapon) or Cosmetic.NamesAllowed(kind)
if #pool == 0 then return nil end
return pool[math.random(#pool)]
end
local repaint = {}
local function randomizeKind(kind)
if not Cosmetic.Ready then return 0 end
saved[kind] = type(saved[kind]) == "table" and saved[kind] or {}
local store, n = saved[kind], 0
local global = (kind ~= "Skin") and Cosmetic.NamesAllowed(kind) or nil
for _, w in ipairs(allWeapons) do
local pool = global or Cosmetic.SkinsFor(w)
if #pool > 0 then
local pick = pool[math.random(#pool)]
if Cosmetic.Set(w, kind, pick, kind == "Wrap" and invertAll or nil) then store[w] = pick; n += 1 end
end
end
if repaint[kind] then pcall(repaint[kind]) end
FX.persistCos()
return n
end
local function randomizeAll()
local total = 0
for _, K in ipairs(KINDS) do total += randomizeKind(K.kind) end
notify("Cosmetics", "Randomised " .. total .. " cosmetics across all weapons", 3)
end
local function clearAll()
for _, K in ipairs(KINDS) do
for w in pairs(saved[K.kind] or {}) do Cosmetic.Set(w, K.kind, nil) end
saved[K.kind] = {}
if repaint[K.kind] then pcall(repaint[K.kind]) end
end
FX.persistCos()
notify("Cosmetics", "All cosmetics reset to default", 2)
end
for _, K in ipairs(KINDS) do
local kind = K.kind
local sub = addSub(mCosm, K.tab, K.desc, true)
if K.kind == "Skin" then
sub.Section("Master")
sub.Toggle("Enable Cosmetics", false, function(on)
if Cosmetic.SetActive then
Cosmetic.SetActive(on)
FX.persistCos()
notify("Cosmetics", on and "Cosmetics ON" or "Cosmetics OFF", 2)
else
notify("Cosmetics", "Game modules not loaded - rejoin a lobby and reload", 4)
end
end)
end
sub.Section("Cosmetics")
saved[kind] = type(saved[kind]) == "table" and saved[kind] or {}
local store = saved[kind]
local grid = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
LayoutOrder = 100000, ZIndex = 3}, sub.Page)
make("UIGridLayout", {CellSize = UDim2.new(1 / COLS, -(GAP * (COLS - 1) / COLS), 0, CELL_H),
CellPadding = UDim2.fromOffset(GAP, GAP), SortOrder = Enum.SortOrder.LayoutOrder,
HorizontalAlignment = Enum.HorizontalAlignment.Left}, grid)
make("UIPadding", {PaddingTop = UDim.new(0, 4)}, grid)
local cards, buildToken, currentWeapon = {}, 0, nil
local function curW() return (currentWeapon == ALLW) and allWeapons[1] or currentWeapon end
local function isOn(name)
local v = store[curW()]
if name == UNSEL then return v == nil end
return v == name
end
local function paintCard(c)
local on = isOn(c.name)
tween(c.stroke, 0.15, {Color = on and T.Accent or T.Border, Transparency = on and 0 or 0.4, Thickness = on and 2 or 1})
tween(c.btn, 0.15, {BackgroundColor3 = on and T.PanelHi or T.Element})
c.tag.Visible = on
end
local function paintAll() for _, c in ipairs(cards) do paintCard(c) end end
local showWeaponNow
local function drawQueue(list, my, weapon)
task.spawn(function()
local n = 0
for _, card in ipairs(list) do
if buildToken ~= my then return end
if card.btn.Parent and not isSpecial(card.name) then pcall(drawIcon, card.btn, kind, card.name, weapon) end
n += 1
if n % 6 == 0 then task.wait() end
end
end)
end
showWeaponNow = function(weapon)
buildToken += 1
local my = buildToken
currentWeapon = weapon
for _, c in ipairs(cards) do c.btn:Destroy() end
cards = {}
if not Cosmetic.Ready then return end
local list0 = (kind == "Skin") and Cosmetic.SkinsFor(weapon) or Cosmetic.NamesAllowed(kind)
local list = {NONE, UNSEL, RAND}
for _, n0 in ipairs(list0) do list[#list + 1] = n0 end
for i, name in ipairs(list) do
local btn = make("TextButton", {BackgroundColor3 = T.Element, Text = "", AutoButtonColor = false,
LayoutOrder = i, ZIndex = 3, ClipsDescendants = true}, grid)
corner(btn, 7)
local st = stroke(btn, T.Border, 1, 0.4)
make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 6, 1, -4),
Size = UDim2.new(1, -12, 0, 30), Text = disp(name), FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.Text,
TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6}, btn)
if isSpecial(name) then
make("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4), Size = UDim2.fromOffset(60, 60),
Text = (name == NONE) and "X" or (name == UNSEL) and "-" or "?", FontFace = F_HEAVY, TextSize = 56,
TextColor3 = (name == RAND) and T.AccentHi or T.Dim, ZIndex = 5}, btn)
end
local tag = make("Frame", {BackgroundColor3 = T.Accent, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8),
Size = UDim2.fromOffset(10, 10), BorderSizePixel = 0, Visible = false, ZIndex = 7}, btn)
corner(tag, 5)
onAccent(function() tag.BackgroundColor3 = T.Accent end)
local card = {btn = btn, stroke = st, tag = tag, name = name}
cards[#cards + 1] = card
btn.MouseEnter:Connect(function()
hoverSfx()
if not isOn(name) then tween(btn, 0.15, {BackgroundColor3 = T.ElementHi}) end
end)
btn.MouseLeave:Connect(function() paintCard(card) end)
btn.MouseButton1Click:Connect(function()
clickSfx()
local w = currentWeapon
local inv = (kind == "Wrap") and invertAll or nil
local function apply(t)
if name == UNSEL then store[t] = nil; Cosmetic.Set(t, kind, nil)
elseif name == NONE then store[t] = NONE; Cosmetic.Set(t, kind, nil)
elseif name == RAND then
store[t] = RAND
local pk = pickRandom(kind, t)
if pk then Cosmetic.Set(t, kind, pk, inv) end
elseif Cosmetic.Set(t, kind, name, inv) then store[t] = name end
end
if w == ALLW then
task.spawn(function()
for i2, t in ipairs(allWeapons) do apply(t); if i2 % 5 == 0 then task.wait() end end
FX.persistCos(); paintAll()
notify(K.tab, "All weapons: " .. disp(name), 2)
end)
return
end
if name == RAND and store[w] == RAND then
store[w] = nil; Cosmetic.Set(w, kind, nil); notify(K.tab, w .. ": random off", 2)
elseif not isSpecial(name) and store[w] == name then
store[w] = nil; Cosmetic.Set(w, kind, nil); notify(K.tab, w .. ": default", 2)
elseif not isSpecial(name) and not Cosmetic.Set(w, kind, name, inv) then
notify(K.tab, "Could not equip " .. name, 2)
else
if isSpecial(name) then apply(w) else store[w] = name end
notify(K.tab, w .. ": " .. disp(name), 2)
end
FX.persistCos()
paintAll()
end)
local on = isOn(name)
st.Color = on and T.Accent or T.Border; st.Transparency = on and 0 or 0.4; st.Thickness = on and 2 or 1
btn.BackgroundColor3 = on and T.PanelHi or T.Element; tag.Visible = on
end
if #list <= 3 then
local lbl = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
Text = "Nothing found for " .. weapon, FontFace = F_BOLD, TextSize = 18, TextColor3 = T.Sub, ZIndex = 4}, grid)
cards[#cards + 1] = {btn = lbl, stroke = Instance.new("UIStroke"), tag = Instance.new("Frame"), name = ""}
else
drawQueue(cards, my, curW())
end
end
local pendingWeapon
local function showWeapon(weapon)
if sub.Page.Visible then pendingWeapon = nil; showWeaponNow(weapon)
else pendingWeapon = weapon end
end
sub.Page:GetPropertyChangedSignal("Visible"):Connect(function()
if sub.Page.Visible and pendingWeapon then
local w = pendingWeapon; pendingWeapon = nil
task.defer(showWeaponNow, w)
end
end)
repaint[kind] = function() paintAll() end
if Cosmetic.Ready then
for w, n in pairs(store) do
if n == RAND then local pk = pickRandom(kind, w); if pk then Cosmetic.Set(w, kind, pk, kind == "Wrap" and invertAll or nil) end
elseif n == NONE then Cosmetic.Set(w, kind, nil)
elseif not Cosmetic.Set(w, kind, n, kind == "Wrap" and invertAll or nil) then store[w] = nil end
end
end
if #allWeapons == 0 then
sub.Label("Cosmetic library not found - open the menu in a match lobby and reload.")
else
weaponPicker(sub, function(w) if w then showWeapon(w) end end, kind ~= "Skin")
do
local acts = {
{"Random Cosmetics", true, function()
local w = currentWeapon or pendingWeapon
if not w then return end
if w == ALLW then notify(K.tab, "Randomised " .. randomizeKind(kind) .. " weapons", 2) return end
local pk = pickRandom(kind, w)
if pk and Cosmetic.Set(w, kind, pk, (kind == "Wrap") and invertAll or nil) then store[w] = pk; notify(K.tab, w .. ": " .. pk, 2) end
FX.persistCos(); paintAll()
end},
{"Reset Cosmetics", false, function()
local w = currentWeapon or pendingWeapon
if not w then return end
task.spawn(function()
if w == ALLW then
for i2, t in ipairs(allWeapons) do store[t] = nil; Cosmetic.Set(t, kind, nil); if i2 % 5 == 0 then task.wait() end end
else store[w] = nil; Cosmetic.Set(w, kind, nil) end
FX.persistCos(); paintAll()
notify(K.tab, (w == ALLW and "All weapons" or w) .. ": reset", 2)
end)
end},
}
if kind == "Skin" then
acts[#acts + 1] = {"Random ALL", true, randomizeAll}
acts[#acts + 1] = {"Reset ALL", false, clearAll}
end
local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = -499, ZIndex = 3}, sub.Page)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, row)
local n = #acts
for i2, a in ipairs(acts) do
local b = make("TextButton", {BackgroundColor3 = a[2] and T.Accent or T.Element, AutoButtonColor = false, Text = a[1], FontFace = F_HEAVY, TextSize = 17,
TextColor3 = a[2] and Color3.fromRGB(254, 254, 252) or T.Text, Size = UDim2.new(1 / n, -(6 * (n - 1) / n), 1, 0), LayoutOrder = i2, ZIndex = 4}, row)
corner(b, 8); stroke(b, a[2] and T.AccentHi or T.Border, 1, 0.4)
b.MouseEnter:Connect(function() hoverSfx(); tween(b, 0.12, {BackgroundColor3 = a[2] and T.AccentHi or T.ElementHi}) end)
b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = a[2] and T.Accent or T.Element}) end)
b.MouseButton1Click:Connect(function() clickSfx(); a[3]() end)
end
end
end
if kind == "Wrap" then
sub.Section("Options")
sub.Toggle("Invert Patterns", invertAll, function(on)
invertAll = on
for w in pairs(store) do Cosmetic.SetInverted(w, on) end
CONFIG_VALUES["Cosmetics.Wraps.Options.Invert Patterns"] = on
FX.persistCos()
end)
end
end
end
if Cosmetic.Ready then
FX.cosLive = true   -- startup restore finished: from now on every change is written to cosmetics.json
Cosmetic.OnChanged = function() if FX.cosLive then FX.persistCos() end end
Cosmetic.InventoryChanged = function(w, kind, name)
local st = saved[kind]
if type(st) == "table" then st[w] = name end
if repaint[kind] then pcall(repaint[kind]) end
FX.persistCos()
end
end
local userScale = 1
local fit
local function listProfiles()
local out = {}
if type(listfiles) == "function" then
pcall(function()
for _, f in ipairs(listfiles(PROFILES)) do
local n = tostring(f):match("([^/\\]+)%.json$")
if n then table.insert(out, n) end
end
end)
end
if #out == 0 then out = {"None"} end
table.sort(out)
return out
end
do
local cp = addSub(mCfg, "Config Profiles", "Save, load and manage your settings.")
cp.Section("Profiles")
local nameBox = cp.TextBox("Profile Name", "my profile")
local pick = cp.Dropdown("Profile", listProfiles(), "None")
local function refresh() pick:SetOptions(listProfiles()) end
cp.Section("Actions")
cp.Button("Save Profile", function()
local n = (nameBox.Get() or ""):gsub("[^%w _%-]", "")
if n == "" then notify("Profiles", "Type a profile name first", 2, "danger"); return end
if type(writefile) == "function" then
pcall(function() writefile(PROFILES .. "/" .. n .. ".json", encode()) end)
refresh(); pick:Set(n); notify("Profiles", "Saved profile: " .. n, 2, "ok")
else notify("Profiles", "Executor has no writefile", 2, "danger") end
end)
cp.Button("Load Profile", function()
local n = pick.Get()
local path = PROFILES .. "/" .. tostring(n) .. ".json"
if type(isfile) == "function" and isfile(path) then
local ok, d = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
if ok and type(d) == "table" then applyTable(d); notify("Profiles", "Loaded: " .. n, 2, "ok"); return end
end
notify("Profiles", "Could not load profile", 2, "danger")
end)
cp.Button("Delete Profile", function()
local n = pick.Get()
local path = PROFILES .. "/" .. tostring(n) .. ".json"
if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
pcall(delfile, path); refresh(); notify("Profiles", "Deleted: " .. n, 2)
else notify("Profiles", "Nothing to delete", 2, "danger") end
end)
cp.Button("Refresh List", refresh)
cp.Section("Auto Load")
cp.Toggle("Auto Load On Startup", true)
cp.Button("Set Selected Profile As Autoload", function()
local n = pick.Get()
if not n or n == "None" then notify("Autoload", "Pick a saved profile first", 2, "danger"); return end
if type(writefile) == "function" then
pcall(function() writefile(ROOT .. "/autoload.json", HttpService:JSONEncode({profile = n})) end)
notify("Autoload", n .. " will load on startup", 2.5, "ok")
else notify("Autoload", "Executor has no writefile", 2, "danger") end
end)
cp.Button("Clear Autoload Profile", function()
if type(delfile) == "function" and type(isfile) == "function" and isfile(ROOT .. "/autoload.json") then
pcall(delfile, ROOT .. "/autoload.json"); notify("Autoload", "Cleared (main config still loads)", 2.5)
else notify("Autoload", "No autoload set", 2, "danger") end
end)
cp.Section("Main Config")
cp.Hint("Your live settings. Delete only removes the saved file - what you see now stays until you reload.")
cp.Button("Save Main Config", function()
local ok = saveConfig(); notify("Config", ok and "Saved" or "Save failed", 2, ok and "ok" or "danger")
end)
cp.Button("Load Main Config", function()
local ok = loadConfig(); notify("Config", ok and "Loaded and applied" or "No config found", 2, ok and "ok" or "danger")
end)
cp.Button("Delete Main Config", function()
if type(delfile) == "function" and type(isfile) == "function" and isfile(CONFIG) then
pcall(delfile, CONFIG); notify("Config", "Main config file deleted", 2.5)
else notify("Config", "No main config to delete", 2, "danger") end
end)
cp.Toggle("Auto Save (30s)", true)
cp.Section("Danger Zone")
cp.Hint("Turn Everything Off disables every active feature (interface settings stay). Reset puts every feature back to its default. Settings, profiles and cosmetics are kept.")
cp.Danger("Turn Everything Off", function()
local count = 0
for key in pairs(toggleKeys) do
local isUI = key:find("^Settings%.") or key:find("^Configs%.")
if not isUI and CONFIG_VALUES[key] == true and registry[key] then
pcall(registry[key], false); count += 1
end
end
markDirty()
notify("Config", count > 0 and ("Turned off " .. count .. " features") or "Everything is already off", 3, "danger")
end)
cp.Danger("Reset Config", function()
local keep = function(k) return type(k) == "string" and (k:find("^Settings%.") or k:find("^Configs%.") or k:find("^Cosmetic")) end
local count = 0
for key, fn in pairs(resetters) do
if not keep(key) then pcall(fn); count += 1 end
end
for key in pairs(CONFIG_VALUES) do
if not keep(key) and not resetters[key] then CONFIG_VALUES[key] = nil end
end
saveConfig()
notify("Config", "Reset " .. count .. " settings to default", 3, "danger")
end)
gui.Destroying:Connect(function() saveConfig() end)
task.spawn(function()
while gui.Parent do
task.wait(30)
if flag("Configs.Config Profiles.Main Config.Auto Save (30s)") then saveConfig() end
end
end)
end
do
task.wait()   -- spread the menu build over frames so loading does not freeze
-- ===== Weapon Mod (Always Backstab + Extend Melee Range, ported from Kiciahook) =====
local wm = addSub(mCombat, "Weapon Mod", "Always backstab and extended melee range.")
local RSv = game:GetService("ReplicatedStorage")
local clonefn = clonefunction or function(f) return f end
local WM = {back = false, ext = false, range = 10}
local G = {}          -- game modules, resolved the first time a feature is switched on
local HK = {}         -- installed hooks (so they can be put back)
local BACK = {winning = nil}
local function cmp(a, b) return (compareinstances ~= nil and compareinstances(a, b)) or a == b end

local function waitPath(parent, path, req)
local o = parent
for _, n in ipairs(path) do
if not o then return nil end
o = o:WaitForChild(n, 6)
end
if o and req then
local ok, m = pcall(require, o)
return ok and m or nil
end
return o
end
local function resolve()
if G.ok then return true end
local ps = player:WaitForChild("PlayerScripts", 6)
local cls = waitPath(ps, {"Modules", "ClientReplicatedClasses"})
G.clientItem = waitPath(cls, {"ClientFighter", "ClientItem"}, true)
G.joints     = waitPath(cls, {"ClientFighter", "ClientFighterCharacter", "Joints"}, true)
G.fighterCtrl = waitPath(ps, {"Controllers", "FighterController"}, true)
G.enum       = waitPath(RSv, {"Modules", "EnumLibrary"}, true)
G.useItem    = waitPath(RSv, {"Remotes", "Replication", "Fighter", "UseItem"})
if G.clientItem and G.joints and G.fighterCtrl and G.enum and G.useItem then
G.rawFire = clonefn(Instance.new("RemoteEvent").FireServer)
G.ok = true
end
return G.ok == true
end
local function hasDebug() return debug and debug.getupvalues and debug.setupvalue end

-- ---------- helpers ----------
local function encodeCF(cf)
local rx, ry, rz = cf:ToOrientation()
return {["\0"] = cf.X, ["\1"] = cf.Y, ["\2"] = cf.Z, ["\3"] = rx, ["\4"] = ry, ["\5"] = rz}
end
local function decodeCF(t)
if type(t) ~= "table" then return nil end
local a, b, c, d, e, f = t["\0"], t["\1"], t["\2"], t["\3"], t["\4"], t["\5"]
for _, v in ipairs({a, b, c, d, e, f}) do if type(v) ~= "number" then return nil end end
return CFrame.new(a, b, c) * CFrame.fromOrientation(d, e, f)
end
local function localFighter()
local fc = G.fighterCtrl
if not fc then return nil end
local map = rawget(fc, "_player_to_fighter")
local f
if type(map) == "table" then
f = rawget(map, player)
if not f then for _, v in pairs(map) do if type(v) == "table" and rawget(v, "Player") == player then f = v; break end end end
end
if not f then f = rawget(fc, "LocalFighter") end
if not f and type(fc.GetFighter) == "function" then
local ok, r = pcall(fc.GetFighter, fc, player)
f = ok and r or nil
end
return f
end
local function eachItem(fn)
local f = localFighter()
local items = f and (rawget(f, "Items") or f.Items)
if type(items) ~= "table" then return nil end
for _, it in pairs(items) do
if type(it) == "table" then
local r = fn(it)
if r ~= nil then return r end
end
end
end
local function meleeById(id)
return eachItem(function(it)
local d, info = rawget(it, "Data"), rawget(it, "Info")
if type(d) == "table" and rawget(d, "ObjectID") == id and type(info) == "table" and info.Type == "Melee" then return it end
end)
end
local function hasKnife()
return eachItem(function(it)
local info = rawget(it, "Info")
if rawget(it, "Name") == "Knife" and type(info) == "table" and info.Type == "Melee" then return true end
end) == true
end
local function closestEnemy(pos, maxD)
local best, bd = nil, math.huge
for _, plr in ipairs(Players:GetPlayers()) do
local enemy = false
if plr ~= player then
local e, me = plr:GetAttribute("EnvironmentID"), player:GetAttribute("EnvironmentID")
if e ~= nil and me ~= nil then
local t, mt = plr:GetAttribute("TeamID"), player:GetAttribute("TeamID")
enemy = e == me and (mt == nil or t ~= mt)
else
enemy = plr.Team == nil or plr.Team ~= player.Team
end
end
if enemy then
local ch = plr.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
local root = ch and ch:FindFirstChild("HumanoidRootPart")
if hum and root and hum.Health > 0 then
local d = (root.Position - pos).Magnitude
if d < maxD and d < bd then best, bd = root, d end
end
end
end
return best
end

-- ---------- Extend Melee Range: rewrites the target of a melee swing before it is sent ----------
local function onUseItem(objectId, enc, args)
if not WM.ext or type(args) ~= "table" then return end
local from = rawget(G.enum, "_from_enum")
local typ = from and rawget(from, enc)
if typ ~= "StartShooting" and typ ~= "StartAiming" then return end
if not meleeById(objectId) then return end
local a = args["\1"]
if type(a) ~= "table" then return end
local cf = decodeCF(a["\0"])
if not cf then return end
local root = closestEnemy(cf.Position, WM.range)
if not root then return end
local e = encodeCF(CFrame.new(root.Position) * CFrame.fromOrientation(-math.pi / 2, 0, 0))
a["\0"] = e; a["\1"] = e
end
local function installExtend()
if HK.input then return true end
if not (resolve() and hasDebug()) then return false end
local input = rawget(G.clientItem, "Input")
if type(input) ~= "function" then return false end
for _, up in ipairs(debug.getupvalues(input)) do
if type(up) == "table" then
for k, v in pairs(up) do
if typeof(v) == "Instance" and cmp(v, RSv) then
up[k] = {Remotes = {Replication = {Fighter = {UseItem = {FireServer = function(_, objectId, enc, args, ...)
pcall(onUseItem, objectId, enc, args)
G.rawFire(G.useItem, objectId, enc, args, ...)
end}}}}}
HK.input = {tbl = up, key = k, orig = v}
return true
end
end
end
end
return false
end

-- ---------- Always Backstab: while a Knife is owned, face the same way as the nearest enemy (within 20 studs) ----------
local function quant(x)
local n = math.clamp(math.floor((x % (2 * math.pi)) / (2 * math.pi) * 256 + 0.5), 0, 255)
return n * 2 * math.pi / 256
end
local function installBack()
if HK.joints then return true end
if not (resolve() and hasDebug()) then return false end
local update = rawget(G.joints, "Update")
if type(update) ~= "function" then return false end
rawset(G.joints, "Update", function(self, a, b)
local cfc = rawget(self, "ClientFighterCharacter")
local cf = cfc and rawget(cfc, "ClientFighter")
if cf and rawget(cf, "IsLocalPlayer") == true and BACK.winning and type(b) == "table" then
rawset(b, "CameraRotationRaw", Vector2.new(quant(math.rad(BACK.winning.Pitch)), quant(math.rad(BACK.winning.Yaw))))
end
return update(self, a, b)
end)
HK.joints = {orig = update}
-- keep the replicated camera rotation steady while the override is active
local fc = G.fighterCtrl
local mt = getmetatable(fc)
local proto = mt and rawget(mt, "__index")
local loop = type(proto) == "table" and rawget(proto, "_CameraReplicationLoop")
if type(loop) == "function" then
for idx, up in ipairs(debug.getupvalues(loop)) do
local um = type(up) == "table" and getmetatable(up)
local ui = um and rawget(um, "__index")
if type(ui) == "table" and type(rawget(ui, "EncodeCameraRotation")) == "function" then
debug.setupvalue(loop, idx, {EncodeCameraRotation = function(_, rot)
if BACK.winning then
rawset(fc, "_replication_stopped", false)
local last = rawget(fc, "_last_encoded_camera_rotation")
if last then return last end
end
return up:EncodeCameraRotation(rot)
end})
HK.rep = {fn = loop, idx = idx, orig = up}
break
end
end
end
return true
end
local function uninstall()
BACK.winning = nil
if HK.input then pcall(function() HK.input.tbl[HK.input.key] = HK.input.orig end); HK.input = nil end
if HK.joints then pcall(rawset, G.joints, "Update", HK.joints.orig); HK.joints = nil end
if HK.rep then pcall(debug.setupvalue, HK.rep.fn, HK.rep.idx, HK.rep.orig); HK.rep = nil end
end
track(RunService.Heartbeat:Connect(function()
if not WM.back or not HK.joints then return end
local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not root or not hasKnife() then BACK.winning = nil; return end
local er = closestEnemy(root.Position, 20)
if not er then BACK.winning = nil; return end
local pitch, yaw = er.CFrame:ToOrientation()
BACK.winning = {Pitch = math.deg(pitch), Yaw = math.deg(yaw)}
end))
gui.Destroying:Connect(uninstall)

wm.Section("Melee")
wm.Toggle("Always Backstab", false, function(v)
WM.back = v
if v then
local ok, res = pcall(installBack)
if not (ok and res) then notify("Weapon Mod", "Always Backstab could not hook the game", 3.5, "danger") end
else
BACK.winning = nil
end
end)
wm.Toggle("Extend Melee Range", false, function(v)
WM.ext = v
if v then
local ok, res = pcall(installExtend)
if not (ok and res) then notify("Weapon Mod", "Extend Melee Range could not hook the game", 3.5, "danger") end
end
end)
wm.Slider("Range", 5, 20, 10, function(v) WM.range = v end, 1)
wm.Hint("Extend Melee Range: a melee swing locks onto the nearest enemy within Range studs. Always Backstab needs a Knife.")
end

do
local G = (getgenv and getgenv()) or _G
local function rng(a, b) local lo, hi = math.min(a, b), math.max(a, b); return lo + (hi - lo) * math.random() end
local CFG = {
    hyperslide = {pMin = 55, pMax = 55, pull = 45, air = 0.18, cd = 0.05, maxJumps = 2, ray = 3.5},
    gravityjump = {pMin = 55, pMax = 55, pull = 45, air = 0.18, cd = 0.05, maxJumps = 2, ray = 3.5},
    wallslide = {radius = 5, duration = 5.1, cooldown = 0.3, offset = 3.4, size = 1.5, minSpeed = 2},
    hyperflash = {force = 350, duration = 0.08, cooldown = 0.35},
    phieze = {speed = 60},
    spamslide = {speed = 140, duration = 0.02, recovery = 0, friction = 0},
}
for _, k in ipairs({"hyperslide", "gravityjump"}) do
    local c = CFG[k]
    c.power = function() return rng(c.pMin, c.pMax) end
end
G.KazeSlide = CFG
local SLIDE_SRC = {}
SLIDE_SRC["Hyper Slide"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.hyperslide
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local oldGuiNames = {
    "AirJumpMobileGui", "InstantPullMobileGui", "InstantPullFixedMobileGui",
    "BalancedAirJumpMobileGui", "FloorSnapAirJumpMobileGui", "VectorAirJumpMobileGui",
    "PerfectAirJumpMobileGui", "FixedPerfectAirJumpGui", "VelocityAirJumpFinalGui"
}

for _, guiName in ipairs(oldGuiNames) do
    local foundGui = PlayerGui:FindFirstChild(guiName)
    if foundGui then foundGui:Destroy() end
    local CoreGui = game:GetService("CoreGui")
    local foundCore = CoreGui:FindFirstChild(guiName)
    if foundCore then foundCore:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local AirJumpButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VelocityAirJumpFinalGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999 

AirJumpButton.Name = "AirJumpButton"
AirJumpButton.Parent = ScreenGui
AirJumpButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)

AirJumpButton.BackgroundTransparency = 0.96
AirJumpButton.TextTransparency = 0.96

AirJumpButton.Position = UDim2.new(0.85, 0, 0.72, 0)
AirJumpButton.Size = UDim2.new(0, 55, 0, 55)
AirJumpButton.Text = "" -- Teks dihapus total agar murni transparan bersih
AirJumpButton.Active = true
AirJumpButton.ZIndex = 999

UICorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
UICorner.Parent = AirJumpButton

local isJumping = false 
local jumpCount = 0 -- Variabel penghitung jumlah lompatan

local function checkGrounded(character, rootPart)
    if not character or not rootPart then return false end
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -CYP.ray, 0) -- Menembak laser ke arah bawah kaki
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return raycastResult ~= nil
end

RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if Character and RootPart then
        if checkGrounded(Character, RootPart) then
            jumpCount = 0 -- Reset ke 0 karena posisi sudah menapak di tanah
        end
    end
end)

AirJumpButton.MouseButton1Click:Connect(function()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if RootPart and Humanoid and not isJumping and jumpCount < CYP.maxJumps then
        isJumping = true
        jumpCount = jumpCount + 1 -- Tambah hitungan lompatan (+1)
        
        RootPart.AssemblyLinearVelocity = Vector3.new(RootPart.AssemblyLinearVelocity.X, CYP.power(), RootPart.AssemblyLinearVelocity.Z)
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        task.wait(CYP.air)
        
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.new(RootPart.AssemblyLinearVelocity.X, -CYP.pull, RootPart.AssemblyLinearVelocity.Z)
        end
        
        task.wait(CYP.cd)
        isJumping = false
    end
end)

]==]
SLIDE_SRC["Wall Slide"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.wallslide

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local techEnabled = false 
local isMinimized = false
local floatPlatform = nil
local isCooldown = false 

local function generateRandomName()
    local length = math.random(8, 14)
    local array = {}
    for i = 1, length do array[i] = string.char(math.random(65, 90)) end
    return table.concat(array)
end

local CURRENT_GUI_NAME = "NoNameHub_WallslideV1"
local FAKE_PLATFORM_NAME = generateRandomName()

local function removeFloatPlatform()
    if floatPlatform then
        pcall(function() floatPlatform:Destroy() end)
        floatPlatform = nil
    end
end

local function spawnPerfectStatisPlatform()
    if floatPlatform or isCooldown then return end
    isCooldown = true
    
    floatPlatform = Instance.new("Part")
    floatPlatform.Name = FAKE_PLATFORM_NAME
    floatPlatform.Size = Vector3.new(CYP.size, 0.01, CYP.size)
    floatPlatform.Transparency = 1 
    floatPlatform.CanCollide = true
    floatPlatform.Anchored = true 
    floatPlatform.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
    floatPlatform.Parent = Workspace
    
    floatPlatform.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - CYP.offset, rootPart.Position.Z)
    Debris:AddItem(floatPlatform, CYP.duration)
    
    task.delay(CYP.duration, function()
        floatPlatform = nil
        task.wait(CYP.cooldown)
        isCooldown = false
    end)
end

local function checkSurroundings()
    if not rootPart then return false end
    local directions = {rootPart.CFrame.LookVector, -rootPart.CFrame.LookVector, rootPart.CFrame.RightVector, -rootPart.CFrame.RightVector, rootPart.CFrame.UpVector}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, floatPlatform}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    for _, dir in ipairs(directions) do
        local ray = Workspace:Raycast(rootPart.Position, dir * CYP.radius, raycastParams)
        if ray and ray.Instance and ray.Instance.CanCollide then return true end
    end
    return false
end

local function attemptManualSlideTrigger()
    if not techEnabled or isCooldown or floatPlatform or not rootPart or not humanoid then return end
    if humanoid.FloorMaterial == Enum.Material.Air then
        local velocity = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z).Magnitude
        if velocity > CYP.minSpeed and checkSurroundings() then
            spawnPerfectStatisPlatform()
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.ButtonB then
        attemptManualSlideTrigger()
    end
end)
UserInputService.TouchTapInWorld:Connect(attemptManualSlideTrigger)

RunService.PostSimulation:Connect(function()
    if not techEnabled then return end
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.FloorMaterial ~= nil then
        removeFloatPlatform()
        isCooldown = false
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    removeFloatPlatform()
    isCooldown = false
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CURRENT_GUI_NAME
ScreenGui.ResetOnSpawn = false
local parentSuccess, _ = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not parentSuccess then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 100)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 255) 
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Spi-Der-Hook-By-@af_l"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 20, 20) 
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Encrypt: Offside"
ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)

ToggleButton.MouseButton1Click:Connect(function()
    techEnabled = not techEnabled
    if techEnabled then
        ToggleButton.Text = "Encrypt: Corrupted"
        ToggleButton.TextColor3 = Color3.fromRGB(75, 255, 120)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 35, 25)
    else
        ToggleButton.Text = "Encrypt: Offside"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
        removeFloatPlatform()
        isCooldown = false
    end
end)
]==]
SLIDE_SRC["Hyper Flash"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.hyperflash
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local isBlinking = false
local guiName = "RivalsAutoCenterSlideBlink"

if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end

local function TriggerScytheBlink()
    if isBlinking then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if root and hum and hum.Health > 0 then
        isBlinking = true
        
        task.spawn(function()
            local startTime = os.clock()
            local isMoving = hum.MoveDirection.Magnitude > 0
            local moveDir = isMoving and hum.MoveDirection or root.CFrame.LookVector
            
            while os.clock() - startTime < CYP.duration do
                if not root or not hum then break end
                
                local horizontalDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
                local verticalY = hum.FloorMaterial == Enum.Material.Air and 4 or 0
                
                root.AssemblyLinearVelocity = Vector3.new(
                    horizontalDir.X * CYP.force,
                    verticalY,
                    horizontalDir.Z * CYP.force
                )
                RunService.RenderStepped:Wait()
            end
            
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, hum.FloorMaterial == Enum.Material.Air and root.AssemblyLinearVelocity.Y or 0, 0)
            end
            
            task.wait(CYP.cooldown)
            isBlinking = false
        end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local GhostSlideButton = Instance.new("TextButton")
GhostSlideButton.Name = "GhostLockedSlideButton"

local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")

local defaultSlideBtn = touchFrame and (touchFrame:FindFirstChild("CrouchButton") or touchFrame:FindFirstChild("DynamicSlideButton"))

if defaultSlideBtn then
    GhostSlideButton.Size = defaultSlideBtn.Size
    GhostSlideButton.AnchorPoint = defaultSlideBtn.AnchorPoint
    
    local origPos = defaultSlideBtn.Position
    GhostSlideButton.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 25, origPos.Y.Scale, origPos.Y.Offset)
else
    GhostSlideButton.Size = UDim2.new(0, 80, 0, 80)
    GhostSlideButton.Position = UDim2.new(0.76, 0, 0.78, 0) -- X diganti dari 0.72 menjadi 0.76 (Geser kanan)
end

GhostSlideButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GhostSlideButton.BackgroundTransparency = 0.96 -- 96% Transparan, menyatu sempurna dengan layar asli kamu
GhostSlideButton.Text = "" 
GhostSlideButton.BorderSizePixel = 0 
GhostSlideButton.Active = true
GhostSlideButton.Visible = true
GhostSlideButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = GhostSlideButton

GhostSlideButton.MouseButton1Down:Connect(function()
    TriggerScytheBlink()
end)

print("AUTO CENTER MODIFIED: Posisi sensor gaib digeser agak ke kanan!")

]==]
SLIDE_SRC["Gravity Jump"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.gravityjump
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local oldGuiNames = {
    "AirJumpMobileGui", "InstantPullMobileGui", "InstantPullFixedMobileGui",
    "BalancedAirJumpMobileGui", "FloorSnapAirJumpMobileGui", "VectorAirJumpMobileGui",
    "PerfectAirJumpMobileGui", "FixedPerfectAirJumpGui", "VelocityAirJumpFinalGui"
}

for _, guiName in ipairs(oldGuiNames) do
    local foundGui = PlayerGui:FindFirstChild(guiName)
    if foundGui then foundGui:Destroy() end
    local CoreGui = game:GetService("CoreGui")
    local foundCore = CoreGui:FindFirstChild(guiName)
    if foundCore then foundCore:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
local AirJumpButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VelocityAirJumpFinalGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999 

AirJumpButton.Name = "AirJumpButton"
AirJumpButton.Parent = ScreenGui
AirJumpButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)

AirJumpButton.BackgroundTransparency = 0.96
AirJumpButton.TextTransparency = 0.96

AirJumpButton.Position = UDim2.new(0.85, 0, 0.72, 0)
AirJumpButton.Size = UDim2.new(0, 55, 0, 55)
AirJumpButton.Text = "" -- Teks dihapus total agar murni transparan bersih
AirJumpButton.Active = true
AirJumpButton.ZIndex = 999

UICorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
UICorner.Parent = AirJumpButton

local isJumping = false 
local jumpCount = 0 -- Variabel penghitung jumlah lompatan

local function checkGrounded(character, rootPart)
    if not character or not rootPart then return false end
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -CYP.ray, 0) -- Menembak laser ke arah bawah kaki
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return raycastResult ~= nil
end

RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if Character and RootPart then
        if checkGrounded(Character, RootPart) then
            jumpCount = 0 -- Reset ke 0 karena posisi sudah menapak di tanah
        end
    end
end)

AirJumpButton.MouseButton1Click:Connect(function()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if RootPart and Humanoid and not isJumping and jumpCount < CYP.maxJumps then
        isJumping = true
        jumpCount = jumpCount + 1 -- Tambah hitungan lompatan (+1)
        
        RootPart.AssemblyLinearVelocity = Vector3.new(RootPart.AssemblyLinearVelocity.X, CYP.power(), RootPart.AssemblyLinearVelocity.Z)
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        task.wait(CYP.air)
        
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.new(RootPart.AssemblyLinearVelocity.X, -CYP.pull, RootPart.AssemblyLinearVelocity.Z)
        end
        
        task.wait(CYP.cd)
        isJumping = false
    end
end)

]==]
SLIDE_SRC["Phieze Boost"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.phieze

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

RunService.RenderStepped:Connect(function()
    if Humanoid:GetState() == Enum.HumanoidStateType.Freefall or Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        
        local joystickDirection = Humanoid.MoveDirection
        
        if joystickDirection.Magnitude > 0 then
            
            local currentY = HumanoidRootPart.AssemblyLinearVelocity.Y
            
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                joystickDirection.X * CYP.speed,
                currentY,
                joystickDirection.Z * CYP.speed
            )
        end
    end
end)

]==]
SLIDE_SRC["Spam Slide"] = [==[
local CYP = (getgenv and getgenv() or _G).KazeSlide.spamslide
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local localPlayer = players.LocalPlayer

local mech
local flashSlideEnabled = true

task.spawn(function()
    repeat task.wait(0.1) until game:IsLoaded()
    task.wait(2)
    local ctrl = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers", 8)
    local ok, m = pcall(require, ctrl:WaitForChild("MechanicsController", 8))
    if ok then mech = m end
end)

runService.RenderStepped:Connect(function()
    if not mech then return end

    if mech._sliding_cooldown and mech._sliding_cooldown > 0 then
        mech._sliding_cooldown = 0
    end
    
    if flashSlideEnabled and mech._is_sliding then
        local char = localPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum then
            local moveDir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or root.CFrame.LookVector
            moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit -- Kunci sumbu Y agar tidak tembus tanah/terbang
            
            root.AssemblyLinearVelocity = moveDir * CYP.speed
            
            if mech._sliding_duration then 
                mech._sliding_duration = CYP.duration
            end
            if mech._slide_recovery_time then mech._slide_recovery_time = CYP.recovery end
            if mech._slide_friction then mech._slide_friction = CYP.friction end
        end
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsVelocityOverrideGui"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = coreGui:FindFirstChild("RobloxGui") or coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 255, 150) -- Tema Hijau Cyber Neon
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "  RIVALS OVERRIDE ENGINE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.TextSize = 22
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 240, 0, 45)
toggleBtn.Position = UDim2.new(0.5, -120, 0.5, -10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
toggleBtn.Text = "OVERRIDE ENGINE: ON"
toggleBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Direct Assembly Overwrite Connected"
statusLabel.TextColor3 = Color3.fromRGB(130, 150, 140)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local roundBtn = Instance.new("TextButton")
roundBtn.Name = "RoundOpenButton"
roundBtn.Size = UDim2.new(0, 55, 0, 55)
roundBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
roundBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
roundBtn.Text = "C"
roundBtn.TextSize = 26
roundBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
roundBtn.Visible = false
roundBtn.Active = true
roundBtn.Draggable = true
roundBtn.Parent = screenGui

local roundCorner = Instance.new("UICorner")
roundCorner.CornerRadius = UDim.new(1, 0)
roundCorner.Parent = roundBtn

local roundStroke = Instance.new("UIStroke")
roundStroke.Color = Color3.fromRGB(0, 255, 150)
roundStroke.Thickness = 2
roundStroke.Parent = roundBtn

toggleBtn.MouseButton1Click:Connect(function()
    flashSlideEnabled = not flashSlideEnabled
    if flashSlideEnabled then
        toggleBtn.Text = "OVERRIDE ENGINE: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        toggleBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
    else
        toggleBtn.Text = "OVERRIDE ENGINE: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

minBtn.MouseButton1Click:Connect(function()
    local tweenClose = tweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = mainFrame.Position + UDim2.new(0, 150, 0, 90)
    })
    tweenClose:Play()
    tweenClose.Completed:Connect(function()
        mainFrame.Visible = false
        roundBtn.Visible = true
        mainFrame.Size = UDim2.new(0, 300, 0, 180)
        mainFrame.Position = UDim2.new(0.5, -150, 0.4, -90)
    end)
end)

roundBtn.MouseButton1Click:Connect(function()
    roundBtn.Visible = false
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
    mainFrame.Visible = true
    
    local tweenOpen = tweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 180),
        Position = UDim2.new(0.5, -150, 0.4, -90)
    })
    tweenOpen:Play()
end)

]==]

local SLIDE_MODES = {
    {"Hyper Slide", "hyperslide"}, {"Wall Slide", "wallslide"}, {"Hyper Flash", "hyperflash"},
    {"Gravity Jump", "gravityjump"}, {"Phieze Boost", "phieze"}, {"Spam Slide", "spamslide"},
}
local UIS = game:GetService("UserInputService")
local runtime, track = {}, {}
G.KazeSlideTrack = track
local function stopMode(nm)
    local r = runtime[nm]
    if not r then return end
    runtime[nm] = nil
    for _, c in ipairs(r.conns) do pcall(function() c:Disconnect() end) end
    for _, o in ipairs(r.objs) do pcall(function() o:Destroy() end) end
end
-- Scripts keep working without their own pop-up GUIs: GUIs are created hidden and every
-- trigger (button) is replaced by a hub-side trigger (jump / slide key / crouch button).
local function wireTrigger(nm)
    local r = runtime[nm]
    local T = track[nm]
    if not (r and T) then return end
    local function act() if T.act then task.spawn(T.act) end end
    if nm == "Hyper Slide" or nm == "Gravity Jump" then
        T.C(UIS.JumpRequest, function()
            local ch = Players.LocalPlayer.Character
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if h and h.FloorMaterial == Enum.Material.Air then act() end
        end)
    elseif nm == "Hyper Flash" then
        T.C(UIS.InputBegan, function(i)
            if i.KeyCode == Enum.KeyCode.C or i.KeyCode == Enum.KeyCode.LeftControl or i.KeyCode == Enum.KeyCode.ButtonB then act() end
        end)
        task.spawn(function()
            for _ = 1, 60 do
                if runtime[nm] ~= r then return end
                local pg = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                local tg = pg and pg:FindFirstChild("TouchGui")
                local tf = tg and tg:FindFirstChild("TouchControlFrame")
                local btn = tf and (tf:FindFirstChild("CrouchButton") or tf:FindFirstChild("DynamicSlideButton"))
                if btn then
                    pcall(function() T.C(btn.MouseButton1Down, act) end)
                    return
                end
                task.wait(0.25)
            end
        end)
    end
end
local function startMode(nm)
    if runtime[nm] then return true end
    local r = {conns = {}, objs = {}}
    runtime[nm] = r
    track[nm] = {
        C = function(sig, f)
            local c = sig:Connect(f)
            if runtime[nm] == r then table.insert(r.conns, c) else pcall(function() c:Disconnect() end) end
            return c
        end,
        I = function(cls)
            local o = Instance.new(cls)
            if cls == "ScreenGui" then o.Enabled = false end
            table.insert(r.objs, o)
            return o
        end,
    }
    local src = SLIDE_SRC[nm]
    src = src:gsub("AirJumpButton%.MouseButton1Click:Connect%(function%(%)", "__T.act = (function()")
    src = src:gsub("GhostSlideButton%.MouseButton1Down:Connect%(function%(%)", "__T.act = (function()")
    src = src:gsub("local techEnabled = false", "local techEnabled = true")
    src = src:gsub("([%w_%.]+):Connect%(", "__C(%1, "):gsub("Instance%.new%(", "__I(")
    src = "local __T = (getgenv and getgenv() or _G).KazeSlideTrack[" .. string.format("%q", nm) .. "]\nlocal __C, __I = __T.C, __T.I\n" .. src
    local fn, err = loadstring(src)
    if not fn then runtime[nm] = nil; warn("[1Mag] " .. nm .. ": " .. tostring(err)); return false end
    local ok0, e0 = pcall(fn)
    if not ok0 then warn("[1Mag] " .. nm .. ": " .. tostring(e0)); stopMode(nm); return false end
    wireTrigger(nm)
    return true
end
G.KazeSlideStop = function() for _, m in ipairs(SLIDE_MODES) do stopMode(m[1]) end end
gui.Destroying:Connect(G.KazeSlideStop)

local sl = addSub(mFF, "Slide", "Slide configs. Toggle a slide mode on; with 2+ on, a switcher appears on the right.")
local function subPage()
    for _, s2 in ipairs(mFF.subs) do if s2.name == "Slide" then return s2 end end
end
local subRec = subPage()
local leftPg, rightPg = subRec and subRec.leftPage, subRec and subRec.rightPage
local function snapshot()
    local set = {}
    for _, pg in ipairs({leftPg, rightPg}) do
        if pg then for _, c in ipairs(pg:GetChildren()) do set[c] = true end end
    end
    return set
end
local function capture(fn, target)
    local before = snapshot()
    fn()
    local list = {}
    for _, pg in ipairs({leftPg, rightPg}) do
        if pg then
            for _, c in ipairs(pg:GetChildren()) do
                if c:IsA("GuiObject") and not before[c] then
                    if target and c.Parent ~= target then c.Parent = target end
                    table.insert(list, c)
                end
            end
        end
    end
    return list
end

local on, selected, modeFrames, switchBtns = {}, nil, {}, {}
local placeholder
local switcher
local refresh
local function setShown(frames, show)
    for _, f in ipairs(frames or {}) do
        if f and f.Parent then f:SetAttribute("Hid", not show); f.Visible = show end
    end
end
local function onCount()
    local n = 0
    for _, m in ipairs(SLIDE_MODES) do if on[m[1]] then n += 1 end end
    return n
end
refresh = function()
    if selected and not on[selected] then selected = nil end
    if not selected then
        for _, m in ipairs(SLIDE_MODES) do if on[m[1]] then selected = m[1]; break end end
    end
    for _, m in ipairs(SLIDE_MODES) do setShown(modeFrames[m[1]], selected == m[1]) end
    if placeholder then setShown(placeholder, selected == nil) end
    for nm, b in pairs(switchBtns) do
        b.Visible = on[nm] == true
        local sel = (nm == selected)
        tween(b, 0.18, {BackgroundColor3 = sel and T.ElementHi or T.Element})
        local fill = b:FindFirstChild("Fill")
        if fill then fill.BackgroundColor3 = T.Accent; tween(fill, 0.25, {BackgroundTransparency = sel and 0.7 or 1}) end
        local lb = b:FindFirstChild("Label")
        if lb then tween(lb, 0.18, {TextColor3 = sel and T.Text or T.Sub}) end
        local ed = b:FindFirstChild("Edge")
        if ed then ed.BackgroundColor3 = T.Accent; tween(ed, 0.2, {BackgroundTransparency = sel and 0 or 1}) end
        local dt = b:FindFirstChild("Dot")
        if dt then tween(dt, 0.2, {BackgroundColor3 = sel and T.AccentHi or T.Dim}) end
        local sc = b:FindFirstChild("Scale")
        if sc then tween(sc, 0.18, {Scale = sel and 1.03 or 1}, Enum.EasingStyle.Back) end
    end
end
onAccent(function() if refresh then pcall(refresh) end end)

sl.Section("Slide Modes")
for _, m in ipairs(SLIDE_MODES) do
    local nm = m[1]
    sl.Toggle(nm, false, function(v)
        if v == true then
            if startMode(nm) then
                on[nm] = true
                if onCount() > 1 then selected = nm end
            else
                notify("Slide", nm .. " failed to load", 3.5, "danger")
            end
        else
            stopMode(nm)
            on[nm] = nil
        end
        refresh()
    end)
end
sl.Hint("Modes work without pop-up menus. Jump modes fire on air jump, Hyper Flash on slide / crouch.")

if leftPg then
    local card = make("Frame", {Name = "SlideCredits", BackgroundColor3 = T.Element, Size = UDim2.new(1, 0, 0, 104),
        BorderSizePixel = 0, LayoutOrder = -1000, ZIndex = 3}, leftPg)
    corner(card, 12)
    local cs = make("UIStroke", {Color = Color3.fromRGB(254, 254, 254), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, card)
    local cg = make("UIGradient", {Name = "NoTheme"}, cs)
    onAccent(function() cg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.AccentHi), ColorSequenceKeypoint.new(1, T.Accent)}) end)
    TweenService:Create(cg, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
    local wash = make("Frame", {BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3}, card)
    corner(wash, 12)
    make("UIGradient", {Name = "NoTheme", Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0.95)})}, wash)
    make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -32, 0, 16), Text = "ALL SLIDES CREATED BY",
        FontFace = F_HEAVY, TextSize = 15, TextColor3 = T.Sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, card)
    make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 24), Size = UDim2.new(1, -32, 0, 40), Text = "@arfa1234173",
        FontFace = F_HEAVY, TextSize = 36, TextColor3 = T.AccentHi, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, card)
    make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 68), Size = UDim2.new(1, -32, 0, 24),
        Text = "aka SigeonPex  -  find them on Discord. Thank you!", FontFace = F_BOLD, TextSize = 17, TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5}, card)
end

-- Per-mode configs: every mode keeps its own sliders; only the selected mode is shown on the right.
local function slidersFor(key, defs)
    local c = CFG[key]
    for _, d in ipairs(defs) do
        local label, mn, mx, field, step, int = d[1], d[2], d[3], d[4], d[5], d[6]
        sl.Slider(label, mn, mx, c[field], function(v)
            if int then v = math.floor(v + 0.5) end
            c[field] = v
        end, step)
    end
end
local jumpDefs = {
    {"Jump Power Min", 10, 150, "pMin", 1}, {"Jump Power Max", 10, 150, "pMax", 1},
    {"Pull Down Force", 0, 120, "pull", 1}, {"Air Time (s)", 0.05, 0.6, "air", 0.01},
    {"Re-jump Cooldown (s)", 0, 0.3, "cd", 0.01}, {"Max Air Jumps", 1, 5, "maxJumps", 1, true},
    {"Ground Check Distance", 1, 8, "ray", 0.1},
}
local DEFS = {
    hyperslide = jumpDefs, gravityjump = jumpDefs,
    wallslide = {
        {"Wall Detect Radius", 1, 15, "radius", 0.1}, {"Platform Duration (s)", 0.5, 10, "duration", 0.05},
        {"Cooldown (s)", 0, 2, "cooldown", 0.05}, {"Platform Height Offset", 1, 6, "offset", 0.05},
        {"Platform Size", 0.5, 6, "size", 0.1}, {"Min Speed To Trigger", 0, 30, "minSpeed", 0.5},
    },
    hyperflash = {
        {"Blink Force", 50, 800, "force", 5}, {"Blink Duration (s)", 0.02, 0.4, "duration", 0.01},
        {"Cooldown (s)", 0, 2, "cooldown", 0.01},
    },
    phieze = {{"Boost Speed", 10, 250, "speed", 1}},
    spamslide = {
        {"Slide Speed", 20, 400, "speed", 1}, {"Slide Duration (s)", 0.01, 1, "duration", 0.01},
        {"Recovery Time (s)", 0, 1, "recovery", 0.01}, {"Friction", 0, 1, "friction", 0.01},
    },
}
placeholder = capture(function()
    sl.Section("Config")
    sl.Hint("Turn on a slide mode to edit its settings.")
end, rightPg)
for _, m in ipairs(SLIDE_MODES) do
    local nm, key = m[1], m[2]
    modeFrames[nm] = capture(function()
        sl.Section(nm .. " Config")
        slidersFor(key, DEFS[key])
    end, rightPg)
end

-- Mechanics controller helpers from Kaze (auto slide / auto jump).
capture(function()
    sl.Section("Mechanics Controller")
    local MC
    pcall(function() MC = require(Players.LocalPlayer.PlayerScripts.Controllers.MechanicsController) end)
    local autoSlide, autoJump, autoRate = false, false, 0.3
    sl.Toggle("Auto Slide", false, function(v) autoSlide = v == true end)
    sl.Toggle("Auto Jump", false, function(v) autoJump = v == true end)
    sl.Slider("Auto Interval (s)", 0.1, 2, 0.3, function(v) autoRate = v end, 0.05)
    task.spawn(function()
        local flip = false
        while gui.Parent do
            task.wait(autoRate)
            if MC and autoSlide then pcall(function() task.spawn(MC.Slide, MC) end) end
            if MC and autoJump then flip = not flip; pcall(function() if flip then MC:JumpRequest() else MC:DoubleJumpRequest() end end) end
        end
    end)
end, leftPg)

-- Slide switcher: floats OUTSIDE the hub (docked to its right edge) so it never touches the subtab frames.
switcher = make("Frame", {Name = "SlideSwitcher", BackgroundColor3 = T.Panel, AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 0, -12), Size = UDim2.fromOffset(0, 46), AutomaticSize = Enum.AutomaticSize.X,
    BorderSizePixel = 0, Visible = false, ZIndex = 70}, holder)
corner(switcher, 99)
local swScale = make("UIScale", {Scale = 1}, switcher)
local swStroke = make("UIStroke", {Color = Color3.fromRGB(254, 254, 254), Thickness = 2, Transparency = 0.05, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, switcher)
local swGrad = make("UIGradient", {Name = "NoTheme"}, swStroke)
onAccent(function() swGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.AccentHi), ColorSequenceKeypoint.new(1, T.Accent)}) end)
TweenService:Create(swGrad, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
padding(switcher, 5, 8, 5, 12)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, switcher)
make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, Text = "SLIDES",
    FontFace = F_HEAVY, TextSize = 20, TextColor3 = T.AccentHi, LayoutOrder = 0, ZIndex = 72}, switcher)
for i, m in ipairs(SLIDE_MODES) do
    local nm = m[1]
    local b = make("TextButton", {Name = nm, BackgroundColor3 = T.Element, Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, Visible = false, LayoutOrder = i, Selectable = true, ZIndex = 72}, switcher)
    corner(b, 99)
    stroke(b, T.Border, 1, 0.5)
    padding(b, 0, 14, 0, 0)
    make("UIScale", {Name = "Scale", Scale = 1}, b)
    local fill = make("Frame", {Name = "Fill", BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 72}, b)
    corner(fill, 99)
    make("Frame", {Name = "Edge", BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(18, 2), ZIndex = 74}, b)
    local dt = make("Frame", {Name = "Dot", BackgroundColor3 = T.Dim, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(8, 8), ZIndex = 74}, b)
    corner(dt, 99)
    make("TextLabel", {Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0), Size = UDim2.fromOffset(0, 34),
        AutomaticSize = Enum.AutomaticSize.X, Text = nm, FontFace = F_HEAVY, TextSize = 17, TextColor3 = T.Sub, ZIndex = 74}, b)
    b.MouseEnter:Connect(function() hoverSfx(); if nm ~= selected then tween(b, 0.15, {BackgroundColor3 = T.ElementHi}) end end)
    b.MouseLeave:Connect(function() if nm ~= selected then tween(b, 0.15, {BackgroundColor3 = T.Element}) end end)
    b.MouseButton1Click:Connect(function() clickSfx(); selected = nm; refresh() end)
    switchBtns[nm] = b
end
task.spawn(function()
    local shown
    while gui.Parent do
        local want = (win.Visible and subRec.page.Visible and onCount() >= 2) and true or false
        if want ~= shown then
            shown = want
            if want then
                swScale.Scale = 0.9; switcher.Visible = true
                tween(swScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back)
            else
                switcher.Visible = false
            end
        end
        task.wait(0.1)
    end
end)
refresh()
end
do
task.wait()   -- spread the menu build over frames so loading does not freeze
local ge = addSub(mSet, "General", "Interface, binds, startup, and notifications.")
build(ge, {
{"sec", "Interface"}, {"t", "Sound FX", true}, {"t", "Show Keybinds", true, function(v) FX.Binds.show = v end},
{"t", "Background Blur", true, function(v) blurOn = v; refreshBlur() end},
{"s", "UI Scale %", 60, 110, 100, 1, function(v) userScale = v / 100; if fit then fit() end end},
{"sec", "Binds"}, {"k", "Toggle Hub", "RightShift"},
{"sec", "Startup"}, {"t", "Show Welcome Notification", true}, {"t", "Open Menu On Startup", false},
{"sec", "Notifications"}, {"t", "Enable Notifications", true},
{"sec", "Danger Zone"}, {"dg", "Unload 1Mag.ez", function() gui:Destroy() end},
})
local W = Color3.new(1, 1, 1)
local function mk(acc, bg, txt, hi)
return {Accent = acc, AccentHi = hi or acc:Lerp(W, 0.28), Bg = bg, Panel = bg:Lerp(W, 0.03):Lerp(acc, 0.03),
PanelHi = bg:Lerp(W, 0.06):Lerp(acc, 0.04), Element = bg:Lerp(W, 0.08):Lerp(acc, 0.05),
ElementHi = bg:Lerp(W, 0.14):Lerp(acc, 0.08), Border = bg:Lerp(W, 0.12):Lerp(acc, 0.22),
Text = txt, Sub = txt:Lerp(bg, 0.35), Dim = txt:Lerp(bg, 0.62)}
end
local C = Color3.fromRGB
local TXT = C(244, 244, 248)
local THEMES = {
Silver         = {C(170, 184, 210), C(8, 10, 15),   C(110, 190, 255), C(236, 242, 252)},
Gold           = {C(255, 184, 28),  C(14, 9, 2),    C(255, 238, 120), C(255, 245, 222)},
Diamond        = {C(80, 214, 255),  C(3, 8, 20),    C(185, 130, 255), C(244, 252, 255)},
Pearl          = {C(255, 150, 205), C(18, 8, 18),   C(150, 230, 255), C(255, 240, 250)},
Oceanic        = {C(0, 140, 255),  C(2, 9, 20),     C(0, 245, 210),   C(226, 246, 255)},
Synthwave      = {C(255, 46, 151),  C(14, 8, 28),   C(0, 229, 255),   C(250, 236, 255)},
Midnight       = {C(88, 101, 242),  C(8, 10, 22),   C(140, 200, 255), C(232, 236, 255)},
Sakura         = {C(255, 143, 177), C(20, 12, 16),  C(255, 214, 230), C(255, 240, 245)},
Mocha          = {C(203, 166, 247), C(17, 17, 27),  C(245, 194, 231), C(205, 214, 244)},
Dracula        = {C(189, 147, 249), C(24, 25, 33),  C(255, 121, 198), C(248, 248, 242)},
["Tokyo Night"] = {C(122, 162, 247), C(20, 21, 30),  C(187, 154, 247), C(192, 202, 245)},
["Rose Pine"]  = {C(235, 111, 146), C(22, 20, 33),  C(246, 193, 119), C(224, 222, 244)},
Nord           = {C(136, 192, 208), C(28, 32, 41),  C(163, 190, 140), C(229, 233, 240)},
Gruvbox        = {C(254, 128, 25),  C(27, 29, 30),  C(250, 189, 47),  C(235, 219, 178)},
Aurora         = {C(0, 255, 170),   C(6, 14, 18),   C(120, 120, 255), C(230, 255, 248)},
Inferno        = {C(255, 69, 0),    C(14, 7, 6),    C(255, 200, 0),   C(255, 240, 225)},
Cyberpunk      = {C(252, 238, 10),  C(10, 10, 14),  C(255, 0, 60),    C(250, 250, 232)},
Ocean          = {C(30, 140, 255),  C(7, 12, 20),   C(0, 235, 220),   TXT},
Matrix         = {C(0, 220, 90),    C(5, 12, 8),    C(190, 255, 120), C(225, 255, 235)},
Monochrome     = {C(210, 210, 218), C(9, 9, 10),    C(255, 255, 255), TXT},
Vaporwave      = {C(255, 113, 206), C(13, 6, 26),   C(1, 205, 254),   C(255, 240, 255)},
["Blood Moon"] = {C(206, 16, 30),   C(14, 4, 6),    C(255, 72, 72),   C(255, 232, 232)},
Toxic          = {C(166, 255, 0),   C(8, 12, 5),    C(0, 255, 150),   C(240, 255, 225)},
Abyss          = {C(0, 120, 255),   C(3, 6, 16),    C(120, 0, 255),   C(225, 240, 255)},
["Gold Rush"]  = {C(255, 196, 77),  C(14, 11, 5),   C(255, 236, 168), C(255, 246, 225)},
["Lavender Haze"] = {C(180, 140, 255), C(14, 10, 24), C(255, 170, 230), C(245, 238, 255)},
["Neon Mint"]  = {C(0, 255, 200),   C(4, 14, 13),   C(255, 255, 120), C(230, 255, 250)},
Sunset         = {C(255, 94, 98),   C(18, 8, 12),   C(255, 195, 113), C(255, 238, 230)},
Galaxy         = {C(123, 97, 255),  C(6, 4, 18),    C(0, 212, 255),   C(235, 232, 255)},
Ice            = {C(120, 220, 255), C(6, 12, 18),   C(255, 255, 255), C(235, 248, 255)},
Lava           = {C(255, 60, 0),    C(12, 4, 2),    C(255, 160, 0),   C(255, 235, 215)},
["Cherry Cola"] = {C(186, 10, 48),  C(10, 5, 7),    C(255, 100, 140), C(255, 232, 238)},
Emerald        = {C(16, 230, 130),  C(3, 13, 9),    C(130, 255, 225), C(232, 255, 244)},
Royal          = {C(106, 76, 255),  C(8, 6, 20),    C(255, 215, 0),   C(240, 236, 255)},
Candy          = {C(255, 105, 180), C(18, 8, 20),   C(120, 230, 255), C(255, 240, 250)},
Void           = {C(160, 160, 255), C(2, 2, 6),     C(255, 60, 200),  C(232, 232, 255)},
Ember          = {C(255, 140, 0),   C(10, 6, 3),    C(255, 60, 60),   C(255, 240, 225)},
Hologram       = {C(0, 255, 255),   C(4, 10, 16),   C(255, 0, 255),   C(230, 255, 255)},
}
local ORDER = {"Synthwave", "Midnight", "Sakura", "Mocha", "Dracula", "Tokyo Night", "Rose Pine", "Nord", "Gruvbox", "Aurora", "Inferno", "Cyberpunk", "Ocean", "Matrix", "Monochrome", "Vaporwave", "Blood Moon", "Toxic", "Abyss", "Gold Rush", "Lavender Haze", "Neon Mint", "Sunset", "Galaxy", "Ice", "Lava", "Cherry Cola", "Emerald", "Royal", "Candy", "Void", "Ember", "Hologram", "Custom"}
do
local top = {"Silver", "Gold", "Emerald", "Diamond", "Pearl", "Oceanic"}
local seen, no = {}, {}
for _, n in ipairs(top) do seen[n] = true; table.insert(no, n) end
for _, n in ipairs(ORDER) do if not seen[n] then table.insert(no, n) end end
ORDER = no
end
local TKEYS = {"Accent", "AccentHi", "Bg", "Panel", "PanelHi", "Element", "ElementHi", "Border", "Text", "Sub", "Dim"}
local function hx(c) return math.floor(c.R * 255 + 0.5) * 65536 + math.floor(c.G * 255 + 0.5) * 256 + math.floor(c.B * 255 + 0.5) end
local function applyTheme(new)
local same = true
for _, k in ipairs(TKEYS) do if T[k] ~= new[k] then same = false; break end end
if same then return end
local map = {}
for _, k in ipairs(TKEYS) do
local h = hx(T[k])
if map[h] == nil then map[h] = new[k] end
end
for _, k in ipairs(TKEYS) do T[k] = new[k] end
local function m(c) local n = map[hx(c)]; return n end
for _, o in ipairs(gui:GetDescendants()) do
pcall(function()
if o:IsA("GuiObject") then
local n = m(o.BackgroundColor3); if n then o.BackgroundColor3 = n end
if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
n = m(o.TextColor3); if n then o.TextColor3 = n end
if o:IsA("TextBox") then n = m(o.PlaceholderColor3); if n then o.PlaceholderColor3 = n end end
elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
n = m(o.ImageColor3); if n then o.ImageColor3 = n end
elseif o:IsA("ScrollingFrame") then
n = m(o.ScrollBarImageColor3); if n then o.ScrollBarImageColor3 = n end
end
elseif o:IsA("UIStroke") then
local n = m(o.Color); if n then o.Color = n end
elseif o:IsA("UIGradient") and o.Name ~= "Shimmer" and o.Name ~= "NoTheme" then
local ks, ch = {}, false
for i, kp in ipairs(o.Color.Keypoints) do
local n = m(kp.Value)
if n then ch = true end
ks[i] = ColorSequenceKeypoint.new(kp.Time, n or kp.Value)
end
if ch then o.Color = ColorSequence.new(ks) end
end
end)
end
for _, f in ipairs(accentHooks) do pcall(f) end
end
local curPreset = "Blood Moon"
local cust = {AR = 210, AG = 210, AB = 218, BR = 9, BG = 9, BB = 10, TR = 244, TG = 244, TB = 248}
local function compute()
if curPreset == "Custom" then
return mk(C(cust.AR, cust.AG, cust.AB), C(cust.BR, cust.BG, cust.BB), C(cust.TR, cust.TG, cust.TB), cust.hi)
end
local p = THEMES[curPreset] or THEMES.Monochrome
return mk(p[1], p[2], p[4] or TXT, p[3])
end
-- Force the selected preset as the canonical palette; do not inherit stale monochrome defaults.
applyTheme(compute())
local pending = false
local function queue()
if pending then return end
pending = true
task.delay(0.05, function()
pending = false
local nt = compute()
applyTheme(nt)
-- No full-screen colour burst: theme changes apply cleanly without startup-style VFX.
end)
end
local function wheelTo(kr, kg, kb, vMin, vMax)
return function(hexv)
local ok, c = pcall(Color3.fromHex, hexv)
if not ok then return end
local hh, ss, vv = c:ToHSV()
c = Color3.fromHSV(hh, ss, math.clamp(vv, vMin, vMax))
if kr == "AR" then cust.hi = nil end
cust[kr], cust[kg], cust[kb] = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
if curPreset == "Custom" then queue() end
end
end
task.wait()   -- spread the menu build over frames so loading does not freeze
local th = addSub(mSet, "Theme", "Pick a preset or build your own.")
build(th, {
{"sec", "Presets"},
{"d", "Preset", ORDER, "Blood Moon", function(v) curPreset = (v == "Crimson") and "Monochrome" or v; queue() end},
{"b", "Random Theme", function()
local h = math.random()
cust.AR, cust.AG, cust.AB = math.floor(Color3.fromHSV(h, 0.8, 1).R * 255), math.floor(Color3.fromHSV(h, 0.8, 1).G * 255), math.floor(Color3.fromHSV(h, 0.8, 1).B * 255)
cust.hi = Color3.fromHSV((h + 0.12) % 1, 0.65, 1)
local b = Color3.fromHSV(h, 0.55, 0.09)
cust.BR, cust.BG, cust.BB = math.floor(b.R * 255), math.floor(b.G * 255), math.floor(b.B * 255)
curPreset = "Custom"; queue()
end},
{"sec", "Custom Accent"},
{"cw", "Accent Colour", "#D2D2DA", wheelTo("AR", "AG", "AB", 0, 1)},
{"sec", "Custom Background"},
{"cw", "Background Colour", "#0A0A0D", wheelTo("BR", "BG", "BB", 0, 0.27)},
{"sec", "Custom Text"},
{"cw", "Text Colour", "#F4F4F8", wheelTo("TR", "TG", "TB", 0.47, 1)},
{"b", "Apply Custom Theme", function() curPreset = "Custom"; queue() end},
{"sec", "Hub Flame"}, {"t", "Hub Flame", true, function(v) FX.Flame.on = v end},
{"s", "Flame Intensity", 8, 100, FX.Flame.n, 2, function(v) FX.Flame.n = v end},
})
do
local thRec
for _, s2 in ipairs(mSet.subs) do if s2.name == "Theme" then thRec = s2 end end
local pg = thRec and thRec.leftPage
if pg then
end
end
task.wait()   -- spread the menu build over frames so loading does not freeze
local ms = addSub(mSet, "Mobile", "On-screen buttons for touch devices.")
build(ms, {
{"sec", "On-Screen Buttons"},
{"t", "Show Buttons", true, function(v) FX.MB.show = v end},
{"t", "Lock Button Positions", false, function(v) FX.MB.locked = v end},
{"s", "Button Size", 44, 110, 64, 2, function(v) FX.MB.size = v end},
{"b", "Reset Button Positions", function() FX.MB.reset() end},
{"sec", "Hub Button (the logo that opens the menu)"},
{"t", "Lock Hub Button", false, function(v) FX.HB.locked = v end},
{"s", "Hub Button Size", 24, 90, 40, 1, function(v) FX.HB.size = v; FX.HB.apply() end},
{"s", "Hub Button Transparency", 0, 100, 0, 5, function(v) FX.HB.trans = v / 100; FX.HB.apply() end},
{"l", "At 95% or more the hub button is invisible and its position locks by itself, so you can't lose it. Tap where it was to open the menu."},
{"l", "Choose a mode in each feature's tab. Drag a button to move it."},
{"l", "The hub button (logo) can be dragged too."},
})
task.wait()   -- spread the menu build over frames so loading does not freeze
local hs = addSub(mSet, "HUD", "Watermark and array list overlay.")
hs.Section("Overlay")
hs.Toggle("Show HUD (above all UIs)", true, function(v) HUD.on = v; HUD.apply() end)
hs.Section("Watermark")
hs.Toggle("Show Watermark", true, function(v) HUD.wm = v; HUD.apply() end)
hs.Dropdown("Watermark Position", {"Top Left", "Top Right", "Bottom Left", "Bottom Right"}, "Top Left", function(v) HUD.wmPos = v; HUD.apply() end)
hs.Toggle("Show Name", true, function(v) HUD.name = v; HUD.apply() end)
hs.Toggle("Show FPS", true, function(v) HUD.fps = v; HUD.apply() end)
hs.Toggle("Show Ping", true, function(v) HUD.ping = v; HUD.apply() end)
hs.Section("Array List")
hs.Toggle("Show Array List", true, function(v) HUD.arr = v; HUD.apply() end)
hs.Dropdown("Array Side", {"Right", "Left"}, "Right", function(v) HUD.side = v; HUD.apply() end)
hs.Toggle("Rainbow Colours", false, function(v) HUD.rainbow = v end)
end
do
task.wait()   -- spread the menu build over frames so loading does not freeze
local op = addSub(mSet, "Optimisation", "Hide everything outside your view in first person.")
local OPT = {on = false, fov = 140}
local MAXFOV = 140
local partSet, fxSet, fxOwner = {}, {}, {}
local hiddenParts, hiddenFx, ignored = {}, {}, {}
local conns, active, bound = {}, false, false
local BIND = "LitOptimise"
local function fxProp(i)
if i:IsA("Decal") then return "Transparency" end
if i:IsA("ParticleEmitter") or i:IsA("Beam") or i:IsA("Trail") or i:IsA("Fire") or i:IsA("Smoke")
or i:IsA("Sparkles") or i:IsA("Light") or i:IsA("Highlight") or i:IsA("BillboardGui") or i:IsA("SurfaceGui") then
return "Enabled"
end
end
local function ownerOf(i)
local p = i:FindFirstAncestorWhichIsA("BasePart")
if p then return p end
local par = i.Parent
if par and par:IsA("Model") then return par.PrimaryPart or par:FindFirstChildWhichIsA("BasePart", true) end
if i:IsA("Highlight") and i.Adornee then
local a = i.Adornee
if a:IsA("BasePart") then return a end
return a:FindFirstChildWhichIsA("BasePart", true)
end
end
local function trackInst(i)
if i:IsA("BasePart") then
if i:IsA("Terrain") then return end
local c = workspace.CurrentCamera
if c and i:IsDescendantOf(c) then return end
partSet[i] = true
elseif fxProp(i) then
local c = workspace.CurrentCamera
if c and i:IsDescendantOf(c) then return end
fxSet[i] = true; fxOwner[i] = ownerOf(i)
end
end
local function untrack(i)
partSet[i] = nil; hiddenParts[i] = nil; ignored[i] = nil
fxSet[i] = nil; fxOwner[i] = nil; hiddenFx[i] = nil
end
local function restoreAll()
for p, orig in pairs(hiddenParts) do
pcall(function() p.LocalTransparencyModifier = orig end)
end
for i, st in pairs(hiddenFx) do
pcall(function() i[st[1]] = st[2] end)
end
hiddenParts, hiddenFx = {}, {}
active = false
end
local function firstPerson(c)
if player.CameraMode == Enum.CameraMode.LockFirstPerson then return true end
local char = player.Character
local head = char and char:FindFirstChild("Head")
if head and head:IsA("BasePart") then
return (c.CFrame.Position - head.Position).Magnitude < 1.6
end
return false
end
local function step()
local c = workspace.CurrentCamera
if not c or not firstPerson(c) then
if active then restoreAll() end
return
end
active = true
local cf = c.CFrame
local cp, look = cf.Position, cf.LookVector
local half = math.rad(math.clamp(OPT.fov, 20, MAXFOV) / 2)
local cosH, sinH = math.cos(half), math.sin(half)
local char = player.Character
for p in pairs(partSet) do
local d = p.Position - cp
local dist = d.Magnitude
local rad = p.Size.Magnitude * 0.5
local cull = false
if dist > rad + 1 then
local s = rad / dist
local cosM = math.sqrt(1 - s * s)
local limit = cosH * cosM - sinH * s   -- cos(half + margin)
cull = (d:Dot(look) / dist) < limit
end
local was = hiddenParts[p] ~= nil
if cull and not was then
if ignored[p] or (char and p:IsDescendantOf(char)) then
ignored[p] = true
else
hiddenParts[p] = p.LocalTransparencyModifier
p.LocalTransparencyModifier = 1
end
elseif was and not cull then
p.LocalTransparencyModifier = hiddenParts[p]
hiddenParts[p] = nil
end
end
for i in pairs(fxSet) do
local o = fxOwner[i]
if o and not partSet[o] then o = nil end
local hide = o ~= nil and hiddenParts[o] ~= nil
local st = hiddenFx[i]
if hide and not st then
local prop = fxProp(i)
hiddenFx[i] = {prop, i[prop]}
i[prop] = (prop == "Transparency") and 1 or false
elseif st and not hide then
i[st[1]] = st[2]
hiddenFx[i] = nil
end
end
end
local function start()
if bound then return end
bound = true
for _, i in ipairs(workspace:GetDescendants()) do trackInst(i) end
conns[1] = workspace.DescendantAdded:Connect(trackInst)
conns[2] = workspace.DescendantRemoving:Connect(untrack)
RunService:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value + 3, function() pcall(step) end)
pcall(step)
end
local function stop()
if not bound then return end
bound = false
pcall(function() RunService:UnbindFromRenderStep(BIND) end)
for _, cn in ipairs(conns) do cn:Disconnect() end
conns = {}
restoreAll()
partSet, fxSet, fxOwner, ignored = {}, {}, {}, {}
end
op.Section("View Culling")
op.Toggle("Optimisation", false, function(v)
OPT.on = v
if v then start() else stop() end
end)
op.Slider("Culling FOV", 60, MAXFOV, 140, function(v)
OPT.fov = math.min(v, MAXFOV)
if bound then pcall(step) end
end, 1)
op.Hint("In first person, everything outside this view cone (max 140) is hidden: parts, meshes, decals, textures, players and effects. Updates every frame and restores instantly when turned off or when you leave first person.")
gui.Destroying:Connect(stop)
end
fit = function()
local vp = gui.AbsoluteSize
local s = math.min((vp.X - 2 * (SQ + 26)) / WIN_W, (vp.Y - 30) / WIN_H, 1)
holderScale.Scale = math.max(0.35, s) * userScale
end
track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
fit()
do
local dragging, startMouse, startPos
top.InputBegan:Connect(function(i)
if isPress(i) then
dragging = true; startMouse, startPos = i.Position, holder.Position
i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
end
end)
track(UIS.InputChanged:Connect(function(i)
if dragging and isMove(i) then
local d = i.Position - startMouse
holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end
end))
end
local toggle = make("TextButton", {Name = "Squircle", BackgroundColor3 = T.Panel, AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(FX.HB.size, FX.HB.size), Text = "", AutoButtonColor = false, ZIndex = 600}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, toggle)
local tStroke = stroke(toggle, T.Accent, 1.5, 0)
local tRing = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(FX.HB.size, FX.HB.size), BorderSizePixel = 0, ZIndex = 599}, toggle)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, tRing)
local ringStroke = stroke(tRing, T.Accent, 2, 0.4)
onAccent(function() tStroke.Color = T.Accent; ringStroke.Color = T.Accent end)
if LOGO_ID then
logoImg({BackgroundTransparency = 1, Size = UDim2.fromScale(0.74, 0.74), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(0.5, 0.5), ScaleType = Enum.ScaleType.Fit, ZIndex = 601}, toggle)
else
make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "1M", FontFace = F_HEAVY, TextSize = 17,
TextColor3 = T.AccentHi, ZIndex = 601}, toggle)
end
-- Static ring: avoids a permanent tween loop and keeps the hub lightweight.
toggle.MouseEnter:Connect(function() hoverSfx(); tween(toggle, 0.2, {BackgroundColor3 = T.ElementHi}) end)
toggle.MouseLeave:Connect(function() tween(toggle, 0.2, {BackgroundColor3 = T.Panel}) end)
FX.HB.apply = function()
local s, t = FX.HB.size, FX.HB.trans or 0
toggle.Size = UDim2.fromOffset(s, s)
tRing.Size = UDim2.fromOffset(s, s)
tRing.Visible = t < 0.5
toggle.BackgroundTransparency = t
tStroke.Transparency = t
for _, d in ipairs(toggle:GetDescendants()) do
if d:IsA("ImageLabel") or d:IsA("ImageButton") then d.ImageTransparency = t
elseif d:IsA("TextLabel") then d.TextTransparency = t
elseif d:IsA("UIStroke") and d ~= ringStroke then d.Transparency = t end
end
if t >= 0.95 and not FX.HB.warned then
FX.HB.warned = true
if not LOADING then notify("Hub button", "Invisible: its position is locked. Tap where it was to open the menu.", 4) end
end
if t < 0.95 then FX.HB.warned = false end
end
FX.sq = {id = "hub", px = 14 / math.max(gui.AbsoluteSize.X, 1), py = 0.5}
FX.MB.attach(toggle, FX.sq)
FX.Binds.build(toggle)
local isOpen, token = false, 0
refreshBlur = function() tween(blurFx, 0.35, {Size = (isOpen and blurOn) and 8 or 0}) end
local function setOpen(v)
if isOpen == v then return end
isOpen = v; token += 1
refreshBlur()
local my = token
if v then
win.Visible = true; shadow.Visible = true
sweep.Visible = true; sweep.Position = UDim2.fromOffset(-120, 0)
tween(sweep, 0.75, {Position = UDim2.fromOffset(WIN_W + 20, 0)}, Enum.EasingStyle.Quad).Completed:Connect(function() sweep.Visible = false end)
tween(winScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
tween(win, 0.3, {GroupTransparency = 0})
tween(shadow, 0.4, {ImageTransparency = 0.55})
else
tween(winScale, 0.25, {Scale = 0.88}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
tween(shadow, 0.25, {ImageTransparency = 1})
tween(win, 0.25, {GroupTransparency = 1}).Completed:Connect(function()
if token == my and not isOpen then win.Visible = false; shadow.Visible = false end
end)
end
end
toggle.MouseButton1Click:Connect(function() if FX.sq.wasDragged then return end clickSfx(); setOpen(not isOpen) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
track(UIS.InputBegan:Connect(function(i, gp)
if gp then return end
if i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode.Name == (flag("Settings.General.Binds.Toggle Hub") or "RightShift") then
setOpen(not isOpen)
end
end))
gui.Destroying:Connect(function()
for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
pcall(function() blurFx:Destroy() end)
pcall(Cosmetic.Unload)
local ld = PG:FindFirstChild("1MagLoading"); if ld then ld:Destroy() end
end)
-- ===================== RAGE (ported from Kaze, trimmed down) =====================
do (function()
local RS_ = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local R = {on = false, act = "Always", held = false, toggled = false, sort = "Closest", maxd = 5000, team = false,
wsel = {"Primary"}, spMode = "Random", spPick = nil, height = 8, park = true, settle = 0.05, hold = 0.12, mDelay = 0.25, kDelay = 1.25,
mPos = "Behind", mRange = 2.5, evade = "Off", rndInt = 1.5, rndNext = 0, rndPick = nil, tcDist = 10, tcInt = 0.3, tcNext = 0, tcVec = nil,
vsWait = 1, vsDepth = 5000, vsUp = 0.2, vsPhase = nil, vsUntil = 0, vsUpAt = 0, orR = 15, orSpd = 360, orH = 3,
watch = true, watchMode = "Far Away", watchAngle = 35, watchRange = 600, watchSide = 9,
shotAt = -100, lockUntil = 0, nextShot = 0, nextMelee = 0, nextReload = 0, nextEquip = 0, hitUntil = 0, hitNext = 0,
posSince = nil, lastCF = nil, oldCF = nil, root = nil, tgt = nil, dead = false, physOn = false, physH = nil, noPark = false, stay = false, atk = true, jumpTh = 3, wpReady = true}
local K = "Combat.Rage."
local rg = addSub(mCombat, "Rage", "Auto-targeting rage. Teleports to the target and fires.")

rg.Section("Activation")
rg.Toggle("Enable Rage", false, function(v) R.on = v == true end)
rg.Dropdown("Activation", {"Always", "Toggle", "Hold"}, "Always", function(v) R.act = v end)
rg.Keybind("Rage Key", "B")
rg.Section("Targeting")
rg.Dropdown("Target Sort", {"Closest", "Lowest Health", "Highest Health", "Fastest"}, "Closest", function(v) R.sort = v end)
rg.Slider("Max Distance", 50, 5000, 5000, function(v) R.maxd = v end, 50)
rg.Toggle("Target Teammates", false, function(v) R.team = v == true end)
rg.Section("Weapon")
rg.MultiDropdown("Rage Weapons", {"Primary", "Secondary", "Melee"}, {"Primary"})
rg.Section("Shooting")
rg.Dropdown("Shoot Position", {"Random", "Above", "Inside"}, "Random", function(v) R.spMode = v; R.spPick = nil end)
rg.Slider("Above Height", 2, 40, 8, function(v) R.height = v end, 0.5)
rg.Toggle("Hide Between Shots", true, function(v) R.park = v == true end)
rg.Slider("Shot Settle (s)", 0, 0.2, 0.05, function(v) R.settle = v end, 0.005)
rg.Slider("Shot Hold (s)", 0, 0.5, 0.12, function(v) R.hold = v end, 0.01)
rg.Section("Melee")
rg.Dropdown("Melee Position", {"Inside", "Behind", "Front", "Above", "On Target"}, "Behind", function(v) R.mPos = v end)
rg.Slider("Stab Distance", 0.5, 6, 2.5, function(v) R.mRange = v end, 0.1)
rg.Slider("Melee Delay (s)", 0.05, 1, 0.25, function(v) R.mDelay = v end, 0.01)
rg.Slider("Knife Heavy Delay (s)", 0.3, 2, 1.25, function(v) R.kDelay = v end, 0.01)
rg.Section("Awareness")
rg.Toggle("Evade If Aimed At", true, function(v) R.watch = v == true end)
rg.Dropdown("Evade Style", {"Far Away", "Side Step"}, "Far Away", function(v) R.watchMode = v end)
rg.Slider("Aim Detect Angle", 5, 90, 35, function(v) R.watchAngle = v end, 1)
rg.Slider("Aim Detect Range", 20, 2000, 600, function(v) R.watchRange = v end, 10)
rg.Slider("Side Step Distance", 2, 30, 9, function(v) R.watchSide = v end, 0.5)
rg.Section("Evasion")
rg.Dropdown("Evasion Method", {"Off", "Random", "Translocate", "Void Spam", "Orbit"}, "Off", function(v) R.evade = v; R.vsPhase = nil; R.tcVec = nil; R.rndNext = 0; R.rndPick = nil end)
rg.Slider("Random: Switch Interval (s)", 0.2, 5, 1.5, function(v) R.rndInt = v end, 0.1)
rg.Slider("Translocate: Distance", 2, 60, 10, function(v) R.tcDist = v end, 0.5)
rg.Slider("Translocate: Interval (s)", 0.1, 2, 0.3, function(v) R.tcInt = v end, 0.01)
rg.Slider("Void Spam: Wait Time (s)", 0.1, 5, 1, function(v) R.vsWait = v end, 0.05)
rg.Slider("Void Spam: Depth (studs)", 500, 50000, 5000, function(v) R.vsDepth = v end, 100)
rg.Slider("Void Spam: Surface Time (s)", 0.1, 1, 0.2, function(v) R.vsUp = v end, 0.01)
rg.Slider("Orbit: Radius", 3, 60, 15, function(v) R.orR = v end, 0.5)
rg.Slider("Orbit: Speed (deg/s)", 30, 720, 360, function(v) R.orSpd = v end, 10)
rg.Slider("Orbit: Height", -10, 30, 3, function(v) R.orH = v end, 0.5)

-- game access
local G2 = {}
local rawFireFn = (clonefunction or function(f) return f end)(Instance.new("RemoteEvent").FireServer)
local function res()
if G2.ok then return true end
pcall(function()
local en = require(RS_:WaitForChild("Modules", 4):WaitForChild("EnumLibrary", 4))
G2.toEnum = rawget(en, "_to_enum") or en._to_enum
G2.useItem = RS_:WaitForChild("Remotes", 4):WaitForChild("Replication", 4):WaitForChild("Fighter", 4):WaitForChild("UseItem", 4)
G2.fc = require(player:WaitForChild("PlayerScripts", 4):WaitForChild("Controllers", 4):WaitForChild("FighterController", 4))
end)
G2.ok = G2.toEnum ~= nil and G2.useItem ~= nil and G2.fc ~= nil
return G2.ok
end
local function myFighter()
local objs = G2.fc and rawget(G2.fc, "Objects")
if type(objs) ~= "table" then return nil end
for _, o in pairs(objs) do if type(o) == "table" and rawget(o, "Player") == player then return o end end
end
local function weaponList(f)
local list, gi = {}, 0
local its = rawget(f, "Items")
if type(its) ~= "table" then return list end
for _, it in pairs(its) do
local info, data = rawget(it, "Info"), rawget(it, "Data")
if type(info) == "table" and type(data) == "table" and data.ObjectID then
local slot
if info.Type == "Melee" then slot = "Melee"
elseif info.Type == "Throwable" then slot = nil
else
gi = gi + 1
slot = tostring(info.Slot or info.Category or "")
if slot ~= "Primary" and slot ~= "Secondary" then slot = gi == 1 and "Primary" or "Secondary" end
end
if slot then list[#list + 1] = {item = it, id = data.ObjectID, name = data.Name, ty = info.Type, slot = slot, ammo = data.Ammo, reserve = data.AmmoReserve, ray = info.IsRaycast} end
end
end
return list
end
local function cfEnc(cf)
local rx, ry, rz = cf:ToOrientation()
return {["\0"] = cf.X, ["\1"] = cf.Y, ["\2"] = cf.Z, ["\3"] = rx, ["\4"] = ry, ["\5"] = rz}
end
local hitRP = RaycastParams.new(); hitRP.FilterType = Enum.RaycastFilterType.Include
local function hitLocal(from, part)
hitRP.FilterDescendantsInstances = {part}
local r = WS:Raycast(from, part.Position - from, hitRP)
if r then local l = part.CFrame:PointToObjectSpace(r.Position); if l ~= Vector3.zero then return l end end
local l2 = part.CFrame:PointToObjectSpace(part:GetClosestPointOnSurface(from))
return l2 ~= Vector3.zero and l2 or Vector3.zero
end

local function keyDown(k) local b = CONFIG_VALUES[k]; return b end
local function matches(i)
local b = CONFIG_VALUES[K .. "Activation.Rage Key"]
if not b or b == "None" then return false end
return (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode.Name == b) or i.UserInputType.Name == b
end
track(UIS.InputBegan:Connect(function(i, gp) if gp or not matches(i) then return end R.held = true; R.toggled = not R.toggled end))
track(UIS.InputEnded:Connect(function(i) if matches(i) then R.held = false end end))
local function active()
if not R.on then return false end
if R.act == "Always" then return true end
if R.act == "Hold" then return R.held end
return R.toggled
end

local function pickTarget(hrp)
local best, bs
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= player and not (not R.team and false) and not (not R.team and plr.Team ~= nil and plr.Team == player.Team) then
local c = plr.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
local r = c and c:FindFirstChild("HumanoidRootPart")
local head = c and c:FindFirstChild("Head")
if h and r and head and h.Health > 0 then
local d = (r.Position - hrp.Position).Magnitude
if d <= R.maxd then
local sc = d
if R.sort == "Lowest Health" then sc = h.Health * 1000 + d
elseif R.sort == "Highest Health" then sc = -h.Health * 1000 + d
elseif R.sort == "Fastest" then sc = -r.AssemblyLinearVelocity.Magnitude * 1000 + d end
if not bs or sc < bs then best, bs = {plr = plr, char = c, hum = h, root = r, head = head, dist = d}, sc end
end
end
end
end
return best
end

local function physSync(on)
if R.physOn == on then return end
R.physOn = on
pcall(function()
if on then
if R.physH == nil then R.physH = WS.FallenPartsDestroyHeight end
WS.FallenPartsDestroyHeight = 0 / 0
elseif R.physH ~= nil then WS.FallenPartsDestroyHeight = R.physH end
end)
end
local function voidPos(p)
local fh = R.physH
if not (type(fh) == "number" and fh == fh) then fh = -500 end
if fh > -1e7 then p = Vector3.new(p.X, math.max(p.Y, fh + 60), p.Z) end
return CFrame.new(p)
end

local function evadeCF(t, base)
local now = os.clock()
local m = R.evade
R.atk = true; R.noPark = false; R.stay = false; R.jumpTh = 3
if m == "Off" or not t then R.vsPhase = nil; R.tcVec = nil; return nil end
R.noPark = true
local hp = t.head.Position
local bp = (base and base.Position) or hp
local holding = now < R.shotAt + R.hold
if m == "Random" then
if now >= R.rndNext and not holding then
R.rndNext = now + R.rndInt
local pool = R.curWp == "Melee" and {"Void Spam"} or {"Translocate", "Void Spam", "Orbit"}
local pick = pool[math.random(#pool)]
if pick ~= R.rndPick then R.vsPhase = nil; R.tcVec = nil end
R.rndPick = pick
end
m = R.rndPick or "Translocate"
end
if m == "Void Spam" then
if not R.vsPhase then R.vsPhase = "void"; R.vsUntil = now + R.vsWait end
if R.vsPhase == "void" then
if now >= R.vsUntil and R.wpReady ~= false then R.vsPhase = "up"; R.vsUpAt = now end
else
local up = now - R.vsUpAt
local shot = R.shotAt >= R.vsUpAt
local leave
if shot then leave = up >= R.vsUp and now >= R.shotAt + R.hold else leave = up >= R.vsUp + 0.6 end
if leave then R.vsPhase = "void"; R.vsUntil = now + R.vsWait end
end
if R.vsPhase == "up" then return CFrame.new(bp) end
R.atk = false; R.stay = true
return voidPos(bp - Vector3.new(0, R.vsDepth, 0))
elseif m == "Translocate" then
if (now >= R.tcNext and not holding) or not R.tcVec then
R.tcNext = now + R.tcInt
local right = t.root.CFrame.RightVector
local D = R.tcDist
local pick = math.random(4)
if pick == 1 then R.tcVec = -right * D elseif pick == 2 then R.tcVec = right * D
elseif pick == 3 then R.tcVec = Vector3.new(0, D, 0) else R.tcVec = Vector3.new(0, -D, 0) end
end
return CFrame.new(hp + R.tcVec)
elseif m == "Orbit" then
R.jumpTh = 30
local a = now * math.rad(R.orSpd)
return CFrame.new(hp + Vector3.new(math.cos(a) * R.orR, R.orH, math.sin(a) * R.orR))
end
return nil
end

local function fireGun(w, t, org)
local to = G2.toEnum
local lh = hitLocal(org, t.head)
local cf = cfEnc(CFrame.lookAt(org, t.head.Position))
local sh = {["\0"] = cf, ["\1"] = cf, ["\2"] = t.head, ["\3"] = cfEnc(CFrame.new(lh))}
local args = (w.ray == true) and {["\1"] = sh, ["\2"] = true} or {["\1"] = sh}
rawFireFn(G2.useItem, w.id, to["StartShooting"], args, nil)
end
local function attackMelee(w, t, org)
local to = G2.toEnum
if not R.atk then return false end
local now = tick()
local lh = hitLocal(org, t.head)
local rr = t.root.CFrame
local cf = cfEnc(CFrame.new(org) * (rr - rr.Position))
local sh = {["\0"] = cf, ["\1"] = cf, ["\2"] = t.head, ["\3"] = cfEnc(CFrame.new(lh))}
if w.name == "Knife" then
if now < R.hitUntil then
if now < R.hitNext then return false end
R.hitNext = now + 0.06
elseif now < R.nextMelee then return false
else
R.hitUntil = now + 0.625; R.nextMelee = now + R.kDelay; R.hitNext = now + 0.06
end
rawFireFn(G2.useItem, w.id, to["StartAiming"], {["\1"] = sh, ["\2"] = to["HeavyAttackAnimation1"] or to["HeavyAttack1"]}, nil)
else
if now < R.nextMelee then return false end
local an = to["AttackAnimation1"] or to["Attack1"]
rawFireFn(G2.useItem, w.id, to["StartShooting"], {["\1"] = sh, ["\2"] = an}, nil)
R.nextMelee = now + R.mDelay
end
return true
end
local function reload(w)
local now = tick()
if now < R.nextReload then return end
R.nextReload = now + 0.7
local r = G2.toEnum["Reload"]
rawFireFn(G2.useItem, w.id, G2.toEnum["StartReloading"], {["\1"] = r, ["\2"] = r}, nil)
end
local function equip(w)
local now = tick()
if now < R.nextEquip then return end
R.nextEquip = now + 0.12
pcall(function() local fn = w.item.Equip; if type(fn) == "function" then fn(w.item) end end)
end
local function shootBase(t)
local hp = t.head.Position
local mode = R.spMode
if mode == "Random" then
if not R.spPick or R.spTgt ~= t.plr then R.spPick = math.random(2) == 1 and "Above" or "Inside"; R.spTgt = t.plr end
mode = R.spPick
end
if mode == "Above" then return CFrame.new(hp + Vector3.new(0, R.height, 0)) end
return CFrame.new(hp + Vector3.new(0, -0.7, 0.05))
end

local function step(dt)
if R.dead then return end
local ch = player.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
if not (active() and hum and hrp and hum.Health > 0 and res()) then R.tgt = nil; R.lastCF = nil; physSync(false); return end
physSync(true)
local t = pickTarget(hrp)
local now = os.clock()
R.tgt = t
local base = t and shootBase(t) or nil
local forcePark = false
if t and R.watch then
local me = t.head.Position
local wl
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player then
local hd = p.Character and p.Character:FindFirstChild("Head")
if hd then
local d = me - hd.Position
local m = d.Magnitude
if m > 0.1 and m <= R.watchRange and hd.CFrame.LookVector:Dot(d / m) >= math.cos(math.rad(R.watchAngle)) then wl = hd.CFrame.LookVector; break end
end
end
end
if wl then
if R.watchMode == "Far Away" then forcePark = true; base = nil
else
local side = wl:Cross(Vector3.yAxis).Unit
if math.floor(os.clock() * 5) % 2 == 0 then side = -side end
base = CFrame.new(t.head.Position + side * R.watchSide + Vector3.new(0, 1.5, 0))
end
end
end
local fighter = myFighter()
local list = fighter and weaponList(fighter) or {}
-- pick first selected weapon in Primary > Secondary > Melee order that exists
local sel = CONFIG_VALUES[K .. "Weapon.Rage Weapons"] or R.wsel
local has = {}
for _, w in ipairs(sel) do has[w] = true end
local chosen
for _, s in ipairs({"Primary", "Secondary", "Melee"}) do
if has[s] then for _, w in ipairs(list) do if w.slot == s then chosen = w; break end end end
if chosen then break end
end
R.curWp = chosen and chosen.slot or "Primary"
local evCF = evadeCF(t, base)
if forcePark then R.atk = false; evCF = nil end
local posCF = evCF or base
local org = posCF and posCF.Position or nil
local function settled(pos)
local last = R.lastCF
if not R.posSince or not last or (pos - last.Position).Magnitude > R.jumpTh then R.posSince = now end
return now - R.posSince >= R.settle
end
local ready, plan = false, nil
if fighter and chosen then
local eq = rawget(fighter, "EquippedItem")
local eqId = type(eq) == "table" and type(rawget(eq, "Data")) == "table" and rawget(eq, "Data").ObjectID or nil
R.wpReady = true
if eqId ~= chosen.id then R.wpReady = false; equip(chosen)
elseif t then
if chosen.ty == "Melee" then
ready = tick() < R.hitUntil or tick() >= R.nextMelee
R.wpReady = ready
local rc = t.root.CFrame
local rp = t.root.Position
local pos
if R.mPos == "Inside" then pos = t.head.Position + Vector3.new(0, -0.7, 0.05)
elseif R.mPos == "Front" then pos = rp + rc.LookVector * R.mRange
elseif R.mPos == "Above" then pos = rp + Vector3.new(0, R.mRange + 1, 0)
elseif R.mPos == "On Target" then pos = rp
else pos = rp - rc.LookVector * R.mRange end
plan = CFrame.lookAt(pos, pos + rc.LookVector)
evCF = nil
if settled(plan.Position) and attackMelee(chosen, t, plan.Position) then R.shotAt = now end
elseif type(chosen.ammo) == "number" and chosen.ammo <= 0 then
R.wpReady = false
if type(chosen.reserve) ~= "number" or chosen.reserve > 0 then reload(chosen) end
else
local cd = rawget(chosen.item, "_shoot_cooldown")
if type(cd) ~= "number" then cd = 0 end
R.wpReady = tick() >= cd and tick() >= R.nextShot
if R.atk and R.wpReady then
ready = true
if settled(org or hrp.Position) then
R.lockUntil = now + R.hold; R.shotAt = now; R.nextShot = tick()
fireGun(chosen, t, org or hrp.Position)
end
end
end
end
end
if R.stay then plan = nil end
local cf = plan or posCF
if t and ((R.park and not R.noPark and not ready and now >= R.lockUntil) or forcePark) then
cf = CFrame.new(math.random(-1000000, 1000000), math.random(5000, 10000), math.random(-1000000, 1000000))
end
R.lastCF = cf
if cf then
if not R.oldCF then R.oldCF = hrp.CFrame end
R.root = hrp
hrp.CFrame = cf
end
end
local function restore()
if R.oldCF and R.root and R.root.Parent then R.root.CFrame = R.oldCF end
R.oldCF = nil
end
pcall(function() RunService:UnbindFromRenderStep("1MagRageRestore") end)
RunService:BindToRenderStep("1MagRageRestore", Enum.RenderPriority.First.Value, function() pcall(restore) end)
local hb = RunService.Heartbeat:Connect(function(dt) pcall(step, dt) end)
gui.Destroying:Connect(function()
R.dead = true; R.on = false
pcall(physSync, false)
pcall(function() hb:Disconnect() end)
pcall(restore)
pcall(function() RunService:UnbindFromRenderStep("1MagRageRestore") end)
end)
end)() end

selectMain(mHome)
badgeRefresh()
task.delay(0.15, function()
if not gui.Parent then return end
LOADING = true
pcall(function()
if type(delfile) == "function" then
if isfile(ROOT .. "/applying.txt") then delfile(ROOT .. "/applying.txt") end
if isfile(ROOT .. "/badkeys.json") then delfile(ROOT .. "/badkeys.json") end
end
end)
local LAST = {["Combat.Aim Assist.Aim Assist.Aim Assist"] = true, ["Combat.Silent Aim.Silent Aim.Silent Aim"] = true,
["Combat.Silent Aim.Legit.Legit Aim Assist"] = true, ["Combat.Rage.Activation.Enable Rage"] = true}
local late, n = {}, 0
for k, v in pairs(SAVED) do
if not gui.Parent then break end
-- Ignore stale saved monochrome selection: Blood Moon is the default on every fresh run.
if k == "Settings.Theme.Presets.Preset" then
    CONFIG_VALUES[k] = "Blood Moon"
elseif LAST[k] then late[#late + 1] = {k, v}
elseif CONFIG_VALUES[k] ~= v then
CONFIG_VALUES[k] = v
if registry[k] then pcall(registry[k], v) end
n += 1
if n % 12 == 0 then task.wait() end
end
end
task.wait(0.15)
for _, kv in ipairs(late) do
if not gui.Parent then break end
if CONFIG_VALUES[kv[1]] ~= kv[2] then
CONFIG_VALUES[kv[1]] = kv[2]
if registry[kv[1]] then pcall(registry[kv[1]], kv[2]) end
task.wait()
end
end
LOADING = false
if arrayRefresh then pcall(arrayRefresh) end
SAVED = {}
CFG_READY = true
pcall(clearDirty)
pcall(badgeRefresh)
FX.releaseGuis()
-- Quiet startup: no welcome popup and no forced menu opening.
end)
end
-- wait until the game has fully loaded before touching anything (auto-execute runs before the game UI is ready)
if not game:IsLoaded() then game.Loaded:Wait() end
do
local lp = game:GetService("Players").LocalPlayer
while not lp do task.wait(); lp = game:GetService("Players").LocalPlayer end
lp:WaitForChild("PlayerGui")
-- Build as soon as PlayerGui exists; character-dependent features resolve lazily.
end
loadMain()
