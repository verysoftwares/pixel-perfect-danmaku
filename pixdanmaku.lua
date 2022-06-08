-- title:  pixel-perfect danmaku
-- author: verysoftwares
-- desc:   an easy base that you can expand with your own stages.
-- script: lua

t=0              -- time in frames. used for score.
x=96;   y=24+80  -- player x, y position.
sw=240; sh=136   -- TIC screen width & height.

sin=math.sin
cos=math.cos
abs=math.abs

bullets={}

-- current stage update function.
-- it is the game state that changes.
-- at the end of file, we can define this to 'attack1'.
    stage=nil   

function TIC()
  
    -- 4-way input with arrow keys.
    if btn(0) then y=y-1 end
    if btn(1) then y=y+1 end
    if btn(2) then x=x-1 end
    if btn(3) then x=x+1 end
  
    cls(14)   -- yellow background
    
    stage()   -- create more bullets
  
    bullet_update()     -- move, draw & remove bullets
        
    pixelperfect()  -- collision with current state of screen.
    
    t=t+1
end

function bullet_update()
    -- we read through the table in reverse, so
    -- it is safe to remove bullets from table.
    -- if we would read it from 1 to #bullets,
    -- removing a bullet would skip one index 'i'!
    for i=#bullets,1,-1 do
        local b= bullets[i] 

        -- move and draw each bullet. 
        b.x=b.x+b.dx; b.y=b.y+b.dy

        spr(1,b.x,b.y,14,1,0,0,2,2)
  
        -- if the distance from center is too much,
        -- then the bullet is off-screen,
        -- and we remove it.
        if abs(b.x+8-sw/2)>sw/2+8 or abs(b.y+8-sh/2)>sh/2+8 then 
            table.remove(bullets,i) 
        end
    end
end

function pixelperfect()
    -- collide with non-transparent pixels currently on screen.
    local player= 11    -- green colour for the player.
    
    -- for each player pixel..
    for sy=0,4 do
    for sx=0,4 do
        
        -- ..read the pixel on screen below player pixel.
        local hitpixel=pix(x+sx,y+sy)
        
        -- if not transparent and not colours in goal sprite,
        -- the game is reset.
        -- reading from outside the screen gives 0,
        -- so the game also resets if you try to escape the game area.
        if not (hitpixel==14 or hitpixel==15 or hitpixel==1) then
            pichuun()
        end

        -- if it's a colour in the goal sprite,
        -- then we go to next attack.
        -- in this simple code, the 2nd attack is just
        -- a victory screen that shows your time.
        if hitpixel==15 or hitpixel==1 then
            score=t
            stage=attack2
        end

        -- don't forget to draw the player rectangle, pixel by pixel. 
        pix(x+sx,y+sy,player)

    end
    end
end

function pichuun()
    -- this function could play a sound effect,
    -- like the 'pichuun~' death sound in Touhou Project!
    -- right now, it only resets the game.
    reset()
end

function attack1()
    -- spawn bullets every third frame.
    -- x position and direction depend on trigonometry.
    if t%3==0 then
        table.insert(bullets,
            { x=120+sin(t*0.12)*20,  y=50,
             dx=cos(t*0.2)*0.6,     dy=sin(t*0.2)*0.6,
            }
        )
    end
    -- draw moving goal sprite, it has colours 1 and 15.
    -- in 'pixelperfect', if player collides with its colours,
    -- the 'stage' function is updated to 'attack2'.
    -- then we won't need to draw it anymore.
    spr(3, 120-cos(t*0.02)*50, 50-sin(t*0.03)*35, 14,1,0,0,2,2)
end

function attack2()
    -- prints a victory text.
    -- because it is drawn before 'pixelperfect',
    -- we can still collide with the text. :)
    local victory= string.format('how could i be so easily defeated??\n\ntime: %d',score)
    local colour= 2+(t*0.2)%13
    print(victory,0,0,colour)
end

-- don't forget to set the stage!
stage=attack1
-- <TILES>
-- 001:eeeeee66eeeee666eeee6669eee6669eee6669eee6669ee66669ee66669ee66e
-- 002:66eeeeee666eeeee9666eeeee9666eeeee9666ee6ee9666e66ee9666e66ee966
-- 003:eeeeee11eeeee111eeee1111eeef1111ee11ffffe111ffff1111ffff1111ffff
-- 004:ffeeeeeefffeeeeeffffeeeeffff1eee1111ffee1111fffe1111ffff1111ffff
-- 017:669ee66e6669ee66e6669ee6ee6669eeeee6669eeeee6669eeeee666eeeeee66
-- 018:e66ee96666ee96666ee9666eee9666eee9666eee9666eeee666eeeee66eeeeee
-- 019:ffff1111ffff1111efff1111eeff1111eee1ffffeeeeffffeeeeefffeeeeeeff
-- 020:ffff1111ffff1111ffff111effff11ee1111feee1111eeee111eeeee11eeeeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

