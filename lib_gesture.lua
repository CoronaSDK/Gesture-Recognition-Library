--[[
----------------------------------------------------------------
GESTURE FOR CORONA SDK
----------------------------------------------------------------
PRODUCT  :		GESTURE FOR CORONA SDK
VERSION  :		0.2
AUTHOR   :		GRZEGORZ TATARKIN / CONCAT GRZEGORZ TATARKIN
WEB SITE :		http:www.concat.pl
SUPPORT  :		grzegorz.tatarkin@concat.pl
PUBLISHER:		CONCAT GRZEGORZ TATARKIN
COPYRIGHT:		(C)2012 CONCAT GRZEGORZ TATARKIN

----------------------------------------------------------------

]]--


-- OBJECT TO HOLD LOCAL VARIABLES AND FUNCTIONS
local V = {}

----------------------------------------------------------------
-- CHANGE THIS TO YOUR NEEDS:
----------------------------------------------------------------
V.debug				= false

----------------------------------------------------------------
-- DO NOT CHANGE ANYTHING BELOW THIS LINE
-- UNLESS YOU KNOW WHAT YOU ARE DOING !
----------------------------------------------------------------
V.PI 				= 4*math.atan(1)
V.PI2				= 2*V.PI
V.Abs  				= math.abs
V.Cos  				= math.cos
V.Sin  				= math.sin
V.Rnd  				= math.random
V.Ceil 				= math.ceil
V.Atan2 			= math.atan2
V.Sqrt				= math.sqrt
V.linePoints = {}
V.anglesMap = {}
V.recording 		= false
V.tolerance 		= 20
V.minimumLinePoints = 2
V.defaultGesture = "n/a" -- (or set to nil, or anything else you want)
V.finalResult		= 0

----------------------------------------------------------------
-- SET DEBUG MODE
----------------------------------------------------------------
if V.debug then print("--> GESTURE READY"); end

----------------------------------------------------------------
-- SET DEBUG MODE
----------------------------------------------------------------
local EnableDebug = function(state)
	V.debug = state == true and true or false
end
V.EnableDebug = EnableDebug
----------------------------------------------------------------
-- TOUCH PATTERN
----------------------------------------------------------------

		-- Add new gestures here
		-- gestures["RETURNDATA"] = "FINGERSEQUENCE";

		-- Define gestures

V.gestures = {
		"53",
		"67612",
		"53032",
		"6212",
		"7612",
		"260123401234",
		"43210",
		"26701234",
		"2107654",
		"4321043210",
		"42",
		"432107650",
		"267012",
		"234",
		"3456701",
		"46",
		"6172",
		"626",
		"616",
		"432107654",
		"012345670",
		"6701234",
		"601234",
		"4321076540",
		"67012341",
		"612302",
		"6134012",
		"67023412",
		"432101234",
		"02",
		"21076",
		"35",
		"2716",
		"1076543",
		"21076234567",
		"030",
		"0",
		"4",
		"2",
		"6",
		"0246",
		"2064",
		"0642",
		"2460",
		"4206",
		"305",
		"053",
		"146",
		"247",
		"14676",
		"7614",
		"7624"
}

V.gesturesSign = {
		"A",
		"A",
		"A",
		"A",
		"A",
		"B",
		"C",
		"D",
		"D",
		"E",
		"F",
		"G",
		"H",
		"J",
		"K",
		"L",
		"M",
		"N",
		"N",
		"O",
		"O",
		"P",
		"P",
		"Q",
		"R",
		"R",
		"R",
		"R",
		"S",
		"T",
		"U",
		"V",
		"W",
		"X",
		"Y",
		"Z",
		"SwipeR",
		"SwipeL",
		"SwipeD",
		"I",
		"Square",
		"Square",
		"Square",
		"Square",
		"Square",
		"Triangle",
		"Triangle",
		"Triangle",
		"Triangle",
		"Triangle",
		"Triangle",
		"Triangle"
}
----------------------------------------------------------------
-- LOCAL DISTANCE
----------------------------------------------------------------
local function Distance ( u, v )
	local x = ( u.x - v.x )
	local y = ( u.y - v.y )
	return V.Sqrt( (x*x)+(y*y) )

end
----------------------------------------------------------------
-- PRIVATE: FIND MINIMUM MOVES - LEV DISTANCE
----------------------------------------------------------------

local function Levenshtein(s, t)
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

----------------------------------------------------------------
-- PRIVATE: FIND MINIMUM MOVES - DEPRECIATED!!!!
----------------------------------------------------------------
local function FindMinimumMoves(string1, string2)

        local str1, str2, distance = {}, {}, {}
        str1.len, str2.len = string.len(string1), string.len(string2)
        string.gsub(string1, "(.)", function(s) table.insert(str1, s) end)
        string.gsub(string2, "(.)", function(s) table.insert(str2, s) end)


        for i = 0, str1.len do
          distance[i] = {}
          distance[i][0] = i
        end

        for i = 0, str2.len do
          distance[0][i] = i
        end

        for i = 1, str1.len do
                for j = 1, str2.len do
                        local tmpdist = 1;
                        if(str1[i-1] == str2[j-1]) then tmpdist = 0; end
                        distance[i][j] = math.min(
                                distance[i-1][j] + 1, distance[i][j-1]+1, distance[i-1][j-1] + tmpdist);
                end
        end
        return distance[str1.len][str2.len];
end

----------------------------------------------------------------
-- PRIVATE: DEGREES TO SECTOR TABLE
----------------------------------------------------------------

local function degreesToSector (x1,y1,x2,y2)

		local a1 = x2 - x1
		local b1 = y2 - y1
		local radians = V.Atan2(a1,b1)
		local degrees = radians / (V.PI / 180)
		local degreesBack = (degrees - 90)

		--[[

		SECTORS

		0 - 22 ,-23
		1 - -24, -59
		2 - -60, -105
		3 - -106, -150
		4 - -151, -196
		5 - -197, -241
		6 - -242, 63
		7 - 23, 62
		]]--

		-- RECORDED ANGLE TO SECTORS

		if ( degreesBack < 22 ) and ( degreesBack > -23 ) then
			 	if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 0 then
					table.insert(V.anglesMap , 0)
				end
		elseif ( degreesBack < -24 ) and ( degreesBack > -59 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 1 then
					table.insert(V.anglesMap , 1)
				end
		elseif ( degreesBack < -60 ) and ( degreesBack > -105 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 2 then
					table.insert(V.anglesMap , 2)
				end
		elseif ( degreesBack < -106 ) and ( degreesBack > -150 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 3 then
					table.insert(V.anglesMap , 3)
				end
		elseif ( degreesBack < -151 ) and ( degreesBack > -196 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 4 then
					table.insert(V.anglesMap , 4)
				end
		elseif ( degreesBack < -197 ) and ( degreesBack > -241 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 5 then
					table.insert(V.anglesMap , 5)
				end
		elseif ( degreesBack > 60 ) and ( degreesBack > -242 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 6 then
					table.insert(V.anglesMap , 6)
				end
		elseif ( degreesBack < 62 ) and ( degreesBack > 23 ) then
				if (V.anglesMap[table.maxn (V.anglesMap)]) ~= 7 then
					table.insert(V.anglesMap , 7)
				end
		end

end

----------------------------------------------------------------
-- PRIVATE: TABLE UTIL
----------------------------------------------------------------

local function val_To_Str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

local function key_To_Str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. val_To_Str( k ) .. "]"
  end
end

local function table_To_Str( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, val_To_Str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        key_To_Str( k ) .. "=" .. val_To_Str( v ) )
    end
  end
  return table.concat(result)
  --table.concat( result, "," )
end

----------------------------------------------------------------
-- LOCAL DISTANCE
----------------------------------------------------------------
local function LowPointsToMatch( linePoints, tolerance )

		 local numPoints = #linePoints
		 local nl = {}
		 local  j, p
		 local patternArray = {}
		 V.linePoints = linePoints
		 V.tolerance = tolerance

		 nl[1] = V.linePoints[1]

		 j = 2
		 p = 1

		 for  i = 2, numPoints, 1  do
			  if ( Distance(V.linePoints[i],V.linePoints[p]) < V.tolerance ) then
			   else
				 nl[j] = V.linePoints[i]
				 j = j+1
				 p = i
			  end
		 end

		 if ( p  < numPoints -1 ) then
			nl[j] = V.linePoints[numPoints-1]
		 end

		 if #nl > 2 then
		 	--- TUTAJ USTALAMY LINIE W SEKTORZE !!!!!!!!!!!!!
			-- LINE1 FOR DEMO ONLY!!!!!!
			--local line1 = display.newLine(nl[1].x,nl[1].y,nl[2].x,nl[2].y)
			degreesToSector (nl[1].x,nl[1].y,nl[2].x,nl[2].y)
				for i = 3, #nl, 1 do
							--line1:append(nl[i].x,nl[i].y)
							degreesToSector (nl[i-1].x,nl[i-1].y,nl[i].x,nl[i].y)
				end
				--line1:setColor(255,255,0)
				--line1.width=5
		end
end
V.LowPointsToMatch = LowPointsToMatch

----------------------------------------------------------------
-- START RECORCD TOUCH
----------------------------------------------------------------
local function Start(event)

	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local pt = {}
		pt.x = event.x
		pt.y = event.y
		table.insert(V.linePoints,pt)

		elseif "moved" == phase then
			local pt = {}
			pt.x = event.x
			pt.y = event.y
			table.insert(V.linePoints,pt)
			V.recording = true
		elseif "ended" == phase or "cancelled" == phase then
			V.recording = false
			LowPointsToMatch( V.linePoints, V.tolerance )
			local findGestureId
			local findGestureValue
			-- !!! FOR DEBUG ONLY
			--print (table_To_Str( V.anglesMap ))
			--
			for i = 1, #V.gestures do

					if ( findGestureId == nil ) then
						findGestureId = i
						findGestureValue = Levenshtein(table_To_Str( V.anglesMap ), V.gestures[i])
					elseif ( findGestureValue > Levenshtein(table_To_Str( V.anglesMap ), V.gestures[i]) ) then
						findGestureId = i
						findGestureValue = Levenshtein(table_To_Str( V.anglesMap ), V.gestures[i])
					end
			end

			--V.finalResult = V.gesturesSign[findGestureId]

			if(#V.linePoints >= V.minimumLinePoints)then
                V.finalResult = V.gesturesSign[findGestureId]
            else
                V.finalResult = V.defaultGesture
            end
			V.linePoints = {}
			V.anglesMap = {}
		end

	return true

end
V.Start = Start

----------------------------------------------------------------
-- RETRIEVE GESTURE RESULT
----------------------------------------------------------------
function GestureResult()
	if ( V.finalResult == nil ) then
		return false
	else
		return V.finalResult
	end
end
V.GestureResult = GestureResult

----------------------------------------------------------------
-- EXIT
----------------------------------------------------------------
function Exit()

	Runtime:removeEventListener( "touch", Start )

	-- RESET ACCUMULATED FREEZE-TIME
	V.gLostTime 	  		= 0
	V.linePoints = nil
	V.linePoints = {}
	V.anglesMap = nil
	V.anglesMap = {}

	collectgarbage("collect")

	if V.debug then print ("--> GESTURE.CleanUp(): FINISHED.") end
end
V.Exit = Exit


Runtime:addEventListener( "touch", Start )

return V