import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "util"

-- Convenience variables
local gfx <const> = playdate.graphics

-- Global constants
local windowWidth <const> = 400
local windowHeight <const> = 240
local center = {x=windowWidth/2, y=windowHeight/2}

-- Configurable settings
local playerPos = {x=20, y=windowHeight/2}
local playerSize = 10
local bulletSpeed = 16
local bulletMaxCooldown = 0.2 -- unit: seconds
local bulletLength = 5

-- Global variables
local bulletArray = {}
local bulletCooldown = 0 -- unit: seconds
local asteroidArray = {}

function GetAimDir()
    local crankPos = playdate.getCrankPosition()
    local ccP = crankPos
    if crankPos > 180 then
        ccP = crankPos - 360
    end

    ccP *= 1.4
    ccP = math.max(-60, math.min(60, ccP))
    return ccP
end

function FireBullet(aimDir)
    if bulletCooldown == 0 then
        bulletCooldown = bulletMaxCooldown
        local newBullet = {x=playerPos.x, y=playerPos.y, 
            rotx=math.cos(ToRadian(aimDir/2)), roty=-math.sin(ToRadian(aimDir/2))}
        table.insert(bulletArray, newBullet)
    end
end

-- This function handles bullet traveling, drawing, and destroying when out of frame
function UpdateBullet()
    for index, bullet in ipairs(bulletArray) do
        -- if out of bound, destroy
        if bullet.x > windowWidth+20 or bullet.x < -20 or bullet.y > windowHeight+20 or bullet.y < -20 then
            table.remove(bulletArray, index)
        else
            -- draw the bullet
            gfx.pushContext()
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineWidth(2)
            gfx.drawLine(bullet.x, bullet.y, bullet.x - bullet.rotx*bulletLength, bullet.y - bullet.roty*bulletLength)
            gfx.popContext()
            -- move the bullet
            bullet.x += bullet.rotx * bulletSpeed
            bullet.y += bullet.roty * bulletSpeed
        end
    end
end

function UpdateTimers()
    if bulletCooldown > 0 then
        bulletCooldown = math.max(0, bulletCooldown - 1/playdate.display.getRefreshRate())
    end
end

function playdate.update()
    gfx.clear()

    local aimDir = GetAimDir()
    -- draw the final wall 
    gfx.pushContext()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, playerPos.x, windowHeight)
    gfx.popContext()
    -- draw the player relative to the crank position
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawCircleAtPoint(playerPos.x,  playerPos.y, playerSize)
    -- draw the aim guideline
    gfx.setLineWidth(1)
    gfx.setPattern({ 0xef, 0xff, 0xef, 0xff, 0xef, 0xff, 0xef, 0xff })
    gfx.drawLine(playerPos.x+math.cos(ToRadian(aimDir/2))*playerSize, playerPos.y-math.sin(ToRadian(aimDir/2))*playerSize, 
        playerPos.x+math.cos(ToRadian(aimDir/2))*800, playerPos.y-math.sin(ToRadian(aimDir/2))*800)
    
    -- bullet firing logic
    if playdate.buttonIsPressed(playdate.kButtonA) then
        FireBullet(aimDir)
    end
    -- bullet update
    UpdateBullet()
    -- update all timers
    UpdateTimers()
end