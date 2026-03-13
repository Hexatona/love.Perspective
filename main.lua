M = require "Perspective"

function love.load()
love.graphics.setDefaultFilter('nearest', 'nearest', 0)
  image = love.graphics.newImage("uv.png")
  tl = {x=0, y=50}
  tr={x=200, y=0}
  bl={x=0, y=300}
  br={x=200, y=350}
  local vertices = {tl=tl,tr=tr,bl=bl,br=br}
  myMesh = M.getWarpedImage(image, vertices,16)
end

function love.update(dt)
	tl.x = tl.x + love.math.random(-1,1)
	tl.y = tl.y + love.math.random(-1,1)
	tr.x = tr.x + love.math.random(-1,1)
	tr.y = tr.y + love.math.random(-1,1)
	
	bl.x = bl.x + love.math.random(-1,1)
	bl.y = bl.y + love.math.random(-1,1)
	br.x = br.x + love.math.random(-1,1)
	br.y = br.y + love.math.random(-1,1)
	
	local vertices = {tl=tl,tr=tr,bl=bl,br=br}
	M.updateWarpedMesh(myMesh,vertices,16)
end

-- Create a Mesh with three vertices
function love.draw()
   -- Draw the Mesh on the screen  
	love.graphics.draw(myMesh,100,100)
	love.graphics.setColor(1,1,1)
	love.graphics.points(tl.x+100, tl.y+100, tr.x+100, tr.y+100,bl.x+100,bl.y+100,br.x+100,br.y+100)

end   