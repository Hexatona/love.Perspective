-- Aaron Arendt, 2026

-- Draw an image mapped onto an arbitrary screen-space quad
-- by subdividing it into a grid of triangles (affine per cell),
-- approximating perspective.
-- uses meshes only, and no external shaders.

local Perspective = {}

local function lerp(a, b, t) return a + (b - a) * t end

-- Bilinear interpolation inside a quad defined by tl, tr, bl, br
local function bilerp(tl, tr, bl, br, u, v)
  local ax = lerp(tl.x, tr.x, u)
  local ay = lerp(tl.y, tr.y, u)
  local bx = lerp(bl.x, br.x, u)
  local by = lerp(bl.y, br.y, u)
  return lerp(ax, bx, v), lerp(ay, by, v)
end

--- Draws image warped to quad corners via grid tessellation.
-- @param image love.graphics.Image
-- @param corners table { tl={x=..,y=..}, tr={..}, bl={..}, br={..} }
-- @param grid integer (optional) number of subdivisions per axis; default 16
function Perspective.getWarpedImage(image, corners, grid)
  local tl, tr, bl, br = corners.tl, corners.tr, corners.bl, corners.br
  local GRID = math.max(1, grid or 16)

  -- Build vertex list (position, uv, color) for all small cells (2 tris per cell)
  local verts = {}
  -- Precompute (GRID+1) rows of mapped positions to minimize recomputation
  local rowCacheX, rowCacheY = {}, {}

  for j = 0, GRID do
    local v = j / GRID
    rowCacheX[j], rowCacheY[j] = {}, {}
    for i = 0, GRID do
      local u = i / GRID
      local x, y = bilerp(tl, tr, bl, br, u, v)
      rowCacheX[j][i], rowCacheY[j][i] = x, y
    end
  end

  local function pushVert(i, j, u, v)
    local x = rowCacheX[j][i]
    local y = rowCacheY[j][i]
    verts[#verts+1] = { x, y, u, v, 1, 1, 1, 1 }
  end

  for j = 0, GRID - 1 do
    local v0, v1 = j / GRID, (j + 1) / GRID
    for i = 0, GRID - 1 do
      local u0, u1 = i / GRID, (i + 1) / GRID

      -- Indices in our cached grid
      local i0, i1, j0, j1 = i, i+1, j, j+1

      -- Two triangles per cell: (i0,j0)-(i1,j0)-(i0,j1) and (i1,j0)-(i1,j1)-(i0,j1)
      -- Tri 1
      pushVert(i0, j0, u0, v0)
      pushVert(i1, j0, u1, v0)
      pushVert(i0, j1, u0, v1)
      -- Tri 2
      pushVert(i1, j0, u1, v0)
      pushVert(i1, j1, u1, v1)
      pushVert(i0, j1, u0, v1)
    end
  end

  local mesh = love.graphics.newMesh(
    {{"VertexPosition","float",2},{"VertexTexCoord","float",2},{"VertexColor","byte",4}},
    verts,
    "triangles",
    "stream" -- we build per-draw call; stream avoids driver trying to keep it static
  )
  mesh:setTexture(image)

  return mesh
end

function Perspective.updateWarpedMesh(mesh, corners, grid)
  local tl, tr, bl, br = corners.tl, corners.tr, corners.bl, corners.br
  local GRID = math.max(1, grid or 16)

  -- Build vertex list (position, uv, color) for all small cells (2 tris per cell)
  local verts = {}
  -- Precompute (GRID+1) rows of mapped positions to minimize recomputation
  local rowCacheX, rowCacheY = {}, {}

  for j = 0, GRID do
    local v = j / GRID
    rowCacheX[j], rowCacheY[j] = {}, {}
    for i = 0, GRID do
      local u = i / GRID
      local x, y = bilerp(tl, tr, bl, br, u, v)
      rowCacheX[j][i], rowCacheY[j][i] = x, y
    end
  end

  local function pushVert(i, j, u, v)
    local x = rowCacheX[j][i]
    local y = rowCacheY[j][i]
    verts[#verts+1] = { x, y, u, v, 1, 1, 1, 1 }
  end

  for j = 0, GRID - 1 do
    local v0, v1 = j / GRID, (j + 1) / GRID
    for i = 0, GRID - 1 do
      local u0, u1 = i / GRID, (i + 1) / GRID

      -- Indices in our cached grid
      local i0, i1, j0, j1 = i, i+1, j, j+1

      -- Two triangles per cell: (i0,j0)-(i1,j0)-(i0,j1) and (i1,j0)-(i1,j1)-(i0,j1)
      -- Tri 1
      pushVert(i0, j0, u0, v0)
      pushVert(i1, j0, u1, v0)
      pushVert(i0, j1, u0, v1)
      -- Tri 2
      pushVert(i1, j0, u1, v0)
      pushVert(i1, j1, u1, v1)
      pushVert(i0, j1, u0, v1)
    end
  end

  mesh:setVertices(verts,1)
end

return Perspective