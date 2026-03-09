import "globals"
import "asteroid"
import "player"
import "CoreLibs/object"

-- Configuration variables
local bulletSpeed = 20
local bulletLength = 10
local bulletMaxCooldown = 0.2 -- unit: seconds
local bulletDamage = 30

-- Convenience variables
local gfx <const> = playdate.graphics
local bulletArray = GAMESTATE.bulletArray

-- Assets
local bulletpng = gfx.image.new("images/bullet")

-- Class definition
class("Bullet", {rotx=0, roty=0, speed=0, damage=0}).extends(gfx.sprite)
function Bullet:init(posx, posy, rottx, rotty)
    Bullet.super.init(self)
    self:setImage(bulletpng)
    self:moveTo(posx, posy)
    self.speed = bulletSpeed
    self.damage = bulletDamage
    self.rotx = rottx
    self.roty = rotty 
    self:setSize(bulletLength, bulletLength*2)
    self:setCollideRect(bulletLength-2, bulletLength-1, 2, 2)
    self:add()
end

-- Create a bullet, primed to fire towards the provided aim direction.
-- This respects and updates `bulletCooldown`.
function FireBullet(aimDir)
    local bulletCooldown = GAMESTATE.player.bulletCooldown
    local player = GAMESTATE.player
    if bulletCooldown == 0 then
        bulletCooldown = bulletMaxCooldown
        local newBullet = 
            Bullet(player.firex + math.cos(ToRadian(aimDir/2))*bulletLength, player.y - math.sin(ToRadian(aimDir/2))*bulletLength, 
            math.cos(ToRadian(aimDir/2)), -math.sin(ToRadian(aimDir/2)))
        table.insert(bulletArray, newBullet)
    end
    GAMESTATE.player.bulletCooldown = bulletCooldown
end

-- This function handles bullet traveling, drawing, and destroying when out of frame.
-- It also handles dealing damage to asteroids.
function UpdateBullet()
    local bulletArray = GAMESTATE.bulletArray
    for i = #bulletArray, 1, -1 do
        -- move the bullet with collision
        local bullet = bulletArray[i]

        local _, _, collisions, numCollisions =
            bullet:moveWithCollisions(bullet.x + bullet.rotx*bullet.speed, bullet.y + bullet.roty*bullet.speed)
        local hitAsteroid = false
        -- if inside of an asteroid, deal damage then destroy.
        for colNum = 1,numCollisions do
            if collisions[colNum].other:getTag() == ENTITY_TAGS.enemy then
                collisions[colNum].other.hp -= bulletDamage
                table.remove(bulletArray, i)
                bullet:remove()
                hitAsteroid = true
                break
            end
        end
        if hitAsteroid == false then
            -- if out of bound, destroy it.
            if bullet.x > WindowWidth+20 or bullet.x < -20 or bullet.y > WindowHeight+20 or bullet.y < -20 then
                table.remove(bulletArray, i)
                bullet:remove()
            end
        end
    end
end

-- Bullets have their collision at the tip
function Bullet:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawLine(bulletLength, bulletLength, bulletLength - self.rotx*bulletLength, bulletLength - self.roty*bulletLength)
end

function Bullet:update()
    self:markDirty()
end