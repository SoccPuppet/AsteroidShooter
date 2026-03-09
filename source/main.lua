import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "util"
import "bullet"
import "globals"
import "player"

-- Convenience variables
local gfx <const> = playdate.graphics

-- Assets
local wallpng = gfx.image.new("images/wall")

-- Important variables
local player = Player()
local guideline = Guideline()

-- Draw the wall
local wallsprite = gfx.sprite.new(wallpng)
wallsprite:setCenter(0, 0)
wallsprite:moveTo(0, 0)
wallsprite:setCollideRect(0, 0, 20, WindowHeight)
wallsprite:add()

function playdate.update()
    local player = GAMESTATE.player

    -- Creation Corner --
    -- bullet firing logic
    if playdate.buttonIsPressed(playdate.kButtonA) then
        FireBullet(player.aimDir)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SpawnAsteroid()
    end
    
    -- Update Corner -- 
    gfx.sprite.update()
    -- bullet update
    UpdateBullet()
    -- Update asteroids 
    UpdateAsteroids()
end