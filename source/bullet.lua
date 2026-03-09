import "globals"

-- Configuration variables
local bulletSpeed = 16
local bulletMaxCooldown = 0.2 -- unit: seconds
local bulletLength = 5

-- Convenience variables
local gfx <const> = playdate.graphics
local bulletArray = GAMESTATE.bulletArray

function FireBullet(aimDir)
    local bulletCooldown = GAMESTATE.bulletCooldown
    local player = GAMESTATE.player
    if bulletCooldown == 0 then
        bulletCooldown = bulletMaxCooldown
        local newBullet = {x=player.x, y=player.y, 
            rotx=math.cos(ToRadian(aimDir/2)), roty=-math.sin(ToRadian(aimDir/2))}
        table.insert(bulletArray, newBullet)
    end
    GAMESTATE.bulletCooldown = bulletCooldown
end

-- This function handles bullet traveling, drawing, and destroying when out of frame
function UpdateBullet()
    for index, bullet in ipairs(bulletArray) do
        -- if out of bound, destroy
        if bullet.x > WindowWidth+20 or bullet.x < -20 or bullet.y > WindowHeight+20 or bullet.y < -20 then
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