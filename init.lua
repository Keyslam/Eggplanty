local PATH = (...):gsub('%.init$', '')

local Json = require(PATH..".lib.json")

local Eggplanty = {}

Eggplanty.__index = Eggplanty

function Eggplanty.new(dataFile, imageData)
	assert(dataFile ~= nil, "No JSON data!")

	local self = setmetatable({}, Eggplanty)

	self.json_path = dataFile

	if type(dataFile) == "table" then
		self._jsonData = dataFile
	else
		self._jsonData = Json.decode(love.filesystem.read(dataFile))
	end

	self.image = imageData or love.graphics.newImage(self._jsonData.meta.image)
	self.slices = {}

	self:_checkImageSize()
	self:_initializeSlices()

	return self
end

--- Get the json path passed in the object
-- @usage
-- Get the (string) JSON path
-- local str_json = obj:getJSON()
function Eggplanty:getJSON()
	return self.json_path
end

--- Draw the animation's current frame in a specified location.
-- @tparam number x the x position.
-- @tparam number y the y position.
-- @tparam number rot the rotation to draw at.
-- @tparam number sx the x scaling.
-- @tparam number sy the y scaling.
-- @tparam number ox the origin offset x.
-- @tparam number oy the origin offset y.
function Eggplanty:draw(name, x, y, rot, sx, sy, ox, oy)
	local quad = self.slices[name]

	if (not quad) then
		error("Unknown slice name: '"..name.."'")
		return
	end

	love.graphics.draw(self.image, quad, x, y, rot or 0, sx or 1, sy or 1, ox or 0, oy or 0)
end

--- Internal: loads all of the slices
--
-- Called from Eggplanty.new
function Eggplanty:_initializeSlices()
	assert(self._jsonData ~= nil, "No JSON data!")
	assert(self._jsonData.meta ~= nil, "No metadata in JSON!")
	assert(self._jsonData.meta.slices ~= nil, "No slices in JSON! Make sure you exported them in Aseprite!")

	local sx, sy = self.image:getDimensions()

	for _, slice in ipairs(self._jsonData.meta.slices) do
		local name = slice.name
		local bounds = slice.keys[1].bounds
		local quad = love.graphics.newQuad(bounds.x, bounds.y, bounds.w, bounds.h, sx, sy)

		self.slices[name] = quad
	end
end

--- Internal: checks that the loaded image size matches the metadata
--
-- Called from Eggplanty.new
function Eggplanty:_checkImageSize()
	local imageWidth, imageHeight = self._jsonData.meta.size.w, self._jsonData.meta.size.h
	assert(imageWidth == self.image:getWidth(), "Image width metadata doesn't match actual width of file")
	assert(imageHeight == self.image:getHeight(), "Image height metadata doesn't match actual height of file")
end

return Eggplanty
