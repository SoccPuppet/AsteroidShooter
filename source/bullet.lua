import "globals"
import "asteroid"

-- Configuration variables
local bulletSpeed = 20
local bulletMaxCooldown = 0.2 -- unit: seconds
local bulletLength = 5
local bulletDamage = 30

-- Convenience variables
local gfx <const> = playdate.graphics
local bulletArray = GAMESTATE.bulletArray

-- Create a bullet, primed to fire towards the provided aim direction.
-- This respects and updates `bulletCooldown`.
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

-- This function handles bullet traveling, drawing, and destroying when out of frame.
-- It also handles dealing damage to asteroids.
function UpdateBullet()
    for index, bullet in ipairs(bulletArray) do
        local hitAsteroid = false
        -- if inside of an asteroid, deal damage then destroy.
        for _, asteroid in ipairs(GAMESTATE.asteroidArray) do
            if PointCheck(bullet.x, bullet.y, asteroid) then
                asteroid.hp -= bulletDamage
                table.remove(bulletArray, index)
                hitAsteroid = true
                break
            end
        end
        if hitAsteroid == false then
            -- if out of bound, destroy it.
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
end