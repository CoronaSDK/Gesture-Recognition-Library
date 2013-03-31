local Gesture = require("lib_gesture")
local pointsTable = {}
local line

local myText = display.newText("Result: ", 50, 50, native.systemFont, 32)
myText:setTextColor(255, 255, 255)

local function drawLine ()

	if (line and #pointsTable > 2) then
		line:removeSelf()
	end
	
	local numPoints = #pointsTable
	local nl = {}
	local  j, p
		 
	nl[1] = pointsTable[1]
		 
	j = 2
	p = 1
		 
	for  i = 2, numPoints, 1  do
		nl[j] = pointsTable[i]
		j = j+1
		p = i 
	end
	
	if ( p  < numPoints -1 ) then
		nl[j] = pointsTable[numPoints-1]
	end
	
	if #nl > 2 then
			line = display.newLine(nl[1].x,nl[1].y,nl[2].x,nl[2].y)
			for i = 3, #nl, 1 do 
				line:append( nl[i].x,nl[i].y);
			end
			line:setColor(255,255,0)
			line.width=5
	end
end

local function Update(event)		
	if "began" == event.phase then
		pointsTable = nil
		pointsTable = {}
		local pt = {}
		pt.x = event.x
		pt.y = event.y
		table.insert(pointsTable,pt)
	
	elseif "moved" == event.phase then
	
		local pt = {}
		pt.x = event.x
		pt.y = event.y
		table.insert(pointsTable,pt)
	
	elseif "ended" == event.phase or "cancelled" == event.phase then
			drawLine ()
			myText.text = Gesture.GestureResult()
	end
end

Runtime:addEventListener( "touch"		, Update )